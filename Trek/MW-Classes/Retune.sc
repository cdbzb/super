// Pitch correction built on the cepstral formant-preserving engine in vocoders.sc.
// Mirrors the MIDIItem / MIDIItemPlayer split:
//   RetuneItem   : immutable per-take analysis (notes + per-frame data), saved once
//   RetunePlayer : filtered, non-destructive views that render + play
// Source audio is an AudioItem Take; entry points:
//   aTake.retune            -> RetuneItem (load <take>.retune, else analyze + save)
//   aTake.retune.play       -> plays (spins up a player; waits for analysis if needed)
//   aTake.retune.player.move(5,2).snapToScale([0,2,4,5,7,9]).play
// Detection/segmentation and the \autotuneNotes SynthDef are reused from VocoderPattern.

// Shared base: retune notes ARE the events; filters wrap RetunePlayer (not MIDIItemPlayer).
AbstractRetune : AbstractMidiEvents {
	notes { ^this.midiEvents }   // one noteOn-style Event per note; no on/off pairing

	// piano-roll for finding note indices to filter. Blue block = target pitch (labelled
	// with its index); red line = as-sung center. Also posts an index table to the window.
	// piano-roll editor. left-click = audition, double-click = split at click,
	// right-click = merge with next, drag a note's right edge = move boundary,
	// "save split-take" button = freeze edits. Blue block = target (labelled with index),
	// red line = as-sung center. Edits accumulate on a mutable working player.
	gui {
		var notes0, work, dragIndex, postTable, kstr, nav, view;
		var w = 1200, h = 460, pad = 46, t1, lo, hi, xOf, yOf, tOf, font;
		notes0 = this.notes;
		(notes0.isNil or: { notes0.isEmpty }).if {
			^"Retune.gui: no notes yet (analysis not ready?)".warn
		};
		work = this.player;   // mutable working player; each edit reassigns it
		t1 = notes0.collect({ |n| n.timestamp + (n.dur ? 0) }).maxItem.max(0.001);
		lo = notes0.collect({ |n| min(n.midinote, n.measuredCenter ? n.midinote) }).minItem - 1.5;
		hi = notes0.collect({ |n| max(n.midinote, n.measuredCenter ? n.midinote) }).maxItem + 1.5;
		// shared piano-roll navigation (zoom/scroll/pitch keys, same as MIDIItem.gui)
		nav = PianoRollNav(0, t1, lo, hi, w, h, pad);
		xOf = { |t| nav.xOf(t) };   // all transforms route through nav -> respond to zoom/scroll
		yOf = { |m| nav.yOf(m) };
		tOf = { |mx| nav.tOf(mx) };
		font = Font("Helvetica", 9);
		kstr = { |k| (k.asFloat.frac == 0).if({ k.asInteger.asString }, { k.asString }) };
		postTable = {
			("=== % notes ===".format(work.notes.size)).postln;
			work.notes.do { |n, i|
				("  key %  t=%s  dur=%ms  %->%".format(kstr.(n[\key] ? i), n.timestamp.round(0.01),
					((n.dur ? 0) * 1000).round,
					(n.measuredCenter ? n.midinote).round(0.1), n.midinote.round(0.1))).postln;
			};
		};
		postTable.value;
		{
			var win = Window("Retune", Rect(80, 80, w, h + 30)).front;
			Button(win, Rect(8, 4, 150, 22)).states_([["save split-take"]])
				.action_({ work.save });   // freeze the EDITED working notes as a split-take
			StaticText(win, Rect(166, 4, w - 174, 22))
				.string_("h/l scroll   H/L zoom   J/K octave   0 reset   dbl-clk split   R-clk merge   drag right-edge")
				.font_(font).stringColor_(Color.grey(0.45));
			view = UserView(win, Rect(0, 30, w, h)).background_(Color.grey(0.97)).drawFunc_({
				Pen.width = 1;
				(nav.loNote.ceil.asInteger .. nav.hiNote.floor.asInteger).do { |m|
					var y = yOf.(m);
					Pen.strokeColor = ((m % 12) == 0).if({ Color.grey(0.6) }, { Color.grey(0.9) });
					Pen.line(Point(pad, y), Point(w - pad, y)); Pen.stroke;
					((m % 12) == 0).if {
						Pen.stringAtPoint(m.asString, Point(6, y - 6), font, Color.grey(0.4));
					};
				};
				work.notes.do { |n, i|
					var a = n.timestamp, b = n.timestamp + (n.dur ? 0), x, x2, yt, ym;
					nav.overlaps(a, b).if {   // cull notes outside the visible window
						x = xOf.(a); x2 = xOf.(b);
						yt = yOf.(n.midinote); ym = yOf.(n.measuredCenter ? n.midinote);
						Pen.strokeColor = Color(0.85, 0.2, 0.2, 0.7);     // as-sung center
						Pen.line(Point(x, ym), Point(x2, ym)); Pen.stroke;
						Pen.strokeColor = Color.grey(0.5);                // boundary handle (right edge)
						Pen.line(Point(x2, yt - 7), Point(x2, yt + 7)); Pen.stroke;
						Pen.fillColor = Color(0.2, 0.5, 0.9, 0.55);       // target block
						Pen.fillRect(Rect(x, yt - 5, (x2 - x).max(2.0), 10));
						Pen.stringAtPoint(kstr.(n[\key] ? i), Point(x + 1, yt - 19), font, Color.black);
					};
				};
			})
			.mouseDownAction_({ |v, mx, my, mod, btn, clicks|
				var t = tOf.(mx);
				var hit = work.notes.detectIndex({ |n|
					(mx >= xOf.(n.timestamp)) and: { mx <= xOf.(n.timestamp + (n.dur ? 0)) }
						and: { (my - yOf.(n.midinote)).abs < 12 }
				});
				var bIdx = work.notes.detectIndex({ |n|
					((mx - xOf.(n.timestamp + (n.dur ? 0))).abs < 6)
						and: { (my - yOf.(n.midinote)).abs < 14 }
				});
				dragIndex = nil;
				case
				{ btn == 1 } {   // right-click: merge with next
					(hit.notNil and: { (hit + 1) < work.notes.size }).if {
						work = work.merge([hit, hit + 1]); v.refresh; postTable.value;
					};
				}
				{ clicks >= 2 } {   // double-click: split at the click time
					hit.notNil.if { work = work.splitAt(hit, t); v.refresh; postTable.value };
				}
				{ bIdx.notNil } { dragIndex = bIdx }    // begin boundary drag
				{ hit.notNil } { work.prPreview(work.notes[hit].timestamp, work.notes[hit].dur ? 0.3) };  // audition exact fragment
			})
			.mouseUpAction_({ |v, mx, my|
				dragIndex.notNil.if {
					work = work.moveBoundary(dragIndex, tOf.(mx)); v.refresh; postTable.value;
					dragIndex = nil;
				};
			})
			.keyDownAction_({ |v, char|
				nav.keyDown(char).if({ v.refresh }, {   // nav keys consume h/l/H/L/J/K
					switch (char,
						$0, { nav.resetView; v.refresh },
						$q, { win.close },
						$?, { ("Retune.gui keys: h/l scroll  H/L zoom  J/K octave  0 reset view  "
							"q close | mouse: dbl-clk split, right-clk merge, drag right-edge, click audition").postln }
					)
				});
			});
			view.focus(true);   // take key focus so nav works without clicking first
		}.defer;
		^this
	}

	// any collection op (collect/select/reject/drop...) -> new RetunePlayer over the result
	doesNotUnderstand { |selector ...args, kwargs|
		^this.midiEvents.respondsTo(selector).if({
			RetunePlayer(
				this.midiEvents.deepCopy.performArgs(selector, args, kwargs ? #[]),
				this.source
			).copyBounds(this)
		}, {
			DoesNotUnderstandError(this, selector, args).throw
		})
	}
	noteOns {
		^RetunePlayer(this.midiEvents.select{|e| e.midicmd == \noteOn }, this.source).copyBounds(this)
	}
	// ---- stable note keys (see RetuneItem.prBuildModel) ----
	// Each note carries a \key that never renumbers under split/merge, so references survive
	// edits. Integer N addresses the WHOLE original note [N, N+1) incl. any split fragments;
	// a fractional key (e.g. 12.5) addresses one specific fragment.
	prKeyMatch { |key|   // predicate fn: events whose key is referenced by `key`
		var upper = (key.asFloat.frac == 0).if({ key + 1 }, { key + 1e-9 });
		^{ |e| ((e[\key] ? -1) >= key) and: { (e[\key] ? -1) < upper } }
	}
	prSelectKeys { |first, last|   // notes whose key falls in the reference range [first..last]
		var upper = (last.asFloat.frac == 0).if({ last + 1 }, { last + 1e-9 });
		^this.notes.select { |e| ((e[\key] ? -1) >= first) and: { (e[\key] ? -1) < upper } }
	}
	prNotesForKey { |key| ^this.notes.select(this.prKeyMatch(key)) }
	prKeyStr { |k| ^(k.asFloat.frac == 0).if({ k.asInteger.asString }, { k.asString }) }

	// sub-player of the notes whose stable keys fall in [first..last] (key-based, stable across
	// edits; cf. MIDIItem.fromNote). Integer endpoints address whole original notes; nil
	// endpoints span all notes. Playback windows to that range plus `tail` seconds of ring-out;
	// notes keep absolute timestamps.
	fromNote { |first, last, tail = 0.3|
		var ns = this.notes, sub, out;
		(ns.isNil or: { ns.isEmpty }).if { ^"Retune.fromNote: no notes".warn };
		first = first ? (ns.first[\key] ? 0);
		last  = last  ? (ns.last[\key] ? (ns.size - 1));
		sub = this.prSelectKeys(first, last);
		sub.isEmpty.if {
			^("Retune.fromNote: no notes in key range %..%".format(first, last)).warn
		};
		out = RetunePlayer(sub, this.source);
		out.playStart = sub.first.timestamp;
		out.playEnd = sub.last.timestamp + (sub.last.dur ? 0) + tail;
		^out
	}
	from { |first, last, tail = 0.3| ^this.fromNote(first, last, tail) }   // alias
	// append the current (possibly edited) notes as a new immutable split-take under the
	// source item's directory. Never overwrites -> append-only, like MIDIItem selections.
	// Works on item (source=self) or player (source=item, supplies the per-frame arrays).
	save {
		var src = this.source, dir = src.splitTakeDir, n = src.splitTakes;
		File.exists(dir).not.if { File.mkdir(dir) };
		(
			retuneVersion: 1, name: src.name, num: src.num,
			midiEvents: this.notes, smoothed: src.smoothed, conf: src.conf,
			analysisHop: src.analysisHop, sampleRate: src.sampleRate, scale: src.scale
		).writeArchive(src.splitTakePath(n));
		("Retune: saved split-take % (% notes) -> %".format(n, this.notes.size, dir.basename)).postln;
		^n
	}
	// computed bounds (RetunePlayer overrides with stored vars)
	start { ^(this.midiEvents ? []).notEmpty.if({ this.midiEvents.first.timestamp }, { 0 }) }
	end {
		^(this.midiEvents ? []).notEmpty.if({
			var l = this.midiEvents.last; l.timestamp + (l.dur ? 0)
		}, { 0 })
	}
}

RetuneItem : AbstractRetune {
	var <>midiEvents;                          // note Events (the editable source)
	var <>name, <>num, <>voice;                // identity + audio buffer (buffer not archived)
	var <>smoothed, <>conf;                    // fixed per-frame analysis arrays
	var <>analysisHop, <>sampleRate, <>scale;
	var ready = false, pending, <currentTake;   // index of the loaded split-take

	*new { |take| ^super.new.prInit(take) }

	prInit { |take|
		var dir, legacy, latest;
		pending = [];
		name = take.name;
		num = take.num;
		voice = take.buffer;
		scale = nil;                           // chromatic targets at analysis; re-snap via player
		dir = this.splitTakeDir;
		// migrate the old single-file cache -> split-take 0
		legacy = this.retuneFolder +/+ (name ++ "_" ++ num.asString ++ ".retune");
		(File.exists(legacy) and: { File.exists(dir).not }).if {
			File.mkdir(dir);
			Object.readArchive(legacy).writeArchive(this.splitTakePath(0));
			("RetuneItem: migrated legacy cache -> %/0.retune".format(dir.basename)).postln;
		};
		latest = this.splitTakes - 1;
		(latest >= 0).if({
			this.prLoadSplitTake(latest);
			// become ready only once the voice buffer has actually loaded, else play reads an
			// unloaded bufnum (stale 4-ch curve data) -> garble + channel mismatch
			fork { Server.default.sync; this.prSetReady };
		}, {
			this.prAnalyze;   // sets ready when its async work completes
		});
		^this
	}
	// split-takes live in a per-(name,num) directory of numbered archives, mirroring
	// AudioItem's per-name take dir. Kept under _retune/ (a sibling of the take dirs) so it
	// can't match AudioItem.takePath's "<num>.*" glob or inflate its entries-based count.
	retuneFolder { ^AudioItem.folder +/+ "_retune" }
	splitTakeDir  { ^this.retuneFolder +/+ (name ++ "_" ++ num.asString) }
	splitTakePath { |n| ^this.splitTakeDir +/+ (n.asString ++ ".retune") }
	splitTakes {   // count of N.retune versions on disk
		var dir = this.splitTakeDir;
		^File.exists(dir).if({ (dir +/+ "*.retune").pathMatch.size }, { 0 })
	}
	splitTake { |n|   // load a specific version (default load is the most recent)
		((n < 0) or: { n >= this.splitTakes }).if {
			^("RetuneItem: split-take % out of range (0..%)".format(n, this.splitTakes - 1)).warn
		};
		this.prLoadSplitTake(n);
		^this
	}
	source { ^this }
	buffer { ^voice }
	isReady { ^ready }
	whenReady { |func| ready.if({ func.value(this) }, { pending = pending.add(func) }) }
	prSetReady { ready = true; pending.do(_.value(this)); pending = [] }

	prLoad { |d|
		midiEvents = d[\midiEvents];
		smoothed = d[\smoothed]; conf = d[\conf];
		analysisHop = d[\analysisHop]; sampleRate = d[\sampleRate]; scale = d[\scale];
		// migrate pre-key split-takes: birth keys == position
		midiEvents.do { |e, i| e[\key] = (e[\key] ? i) };
		// readiness is set by the caller once the voice buffer is confirmed loaded
	}
	prLoadSplitTake { |n|
		this.prLoad(Object.readArchive(this.splitTakePath(n)));
		currentTake = n;
		("RetuneItem: loaded %/%.retune (% notes)".format(this.splitTakeDir.basename, n, midiEvents.size)).postln;
	}

	prAnalyze {
		this.prRender({ |raw|
			this.prBuildModel(raw);
			this.save;                          // first analysis -> split-take 0
			currentTake = this.splitTakes - 1;
			this.prSetReady;
			"RetuneItem: % notes".format(midiEvents.size).postln;
		});
	}

	// Re-run analysis from the audio and APPEND it as a new split-take (most recent ->
	// becomes the default load), preserving earlier/edited versions. Use when the saved
	// model is stale (notes missed by an older analysis). onDone.(this) fires after save.
	reanalyze { |onDone|
		this.prRender({ |raw|
			var saved;
			this.prBuildModel(raw);
			saved = this.save;                  // append-only
			currentTake = saved;
			this.prSetReady;                    // harmless if already ready
			"RetuneItem: re-analyzed -> split-take % (% notes)".format(saved, midiEvents.size).postln;
			onDone.value(this);
		});
		^this
	}

	// render the offline pitch track for this take, then call action.(raw [pitch,conf])
	prRender { |action|
		var path = AudioItem.takePath(AudioItem.folder +/+ name, num);
		"RetuneItem: analyzing % ...".format(path.basename).postln;
		VocoderPattern.trackPitchOffline(path, hop: 256, onDone: { |voiceBuf, curveBuf|
			voice = voiceBuf;
			curveBuf.loadToFloatArray(action: action);
		});
	}

	// segment a raw [pitch,conf] interleaved array into note Events; sets the per-frame
	// arrays + midiEvents and returns midiEvents. Shared by prAnalyze and reanalyze.
	prBuildModel { |raw|
		var nframes = raw.size div: 2;
		var pitch = Array.newClear(nframes), cf = Array.newClear(nframes);
		var voiced, folded, sm, segs;
		var aHop = 64, sr = (Server.default.sampleRate ? 48000);
		var medWin    = (60/1000 * sr / aHop).round.asInteger.max(1);
		var minFrames = (80/1000 * sr / aHop).round.asInteger.max(1);
		var coarseWin = (200/1000 * sr / aHop).round.asInteger.max(1);
		analysisHop = aHop; sampleRate = sr;
		nframes.do { |i| pitch[i] = raw[2*i]; cf[i] = raw[(2*i) + 1] };
		voiced = nframes.collect { |i| (cf[i] > 0.4) and: { pitch[i] > 0 } };
		folded = VocoderPattern.prOctaveFold(pitch, voiced, coarseWin);
		sm = VocoderPattern.prMedianFilter(folded, voiced, medWin);
		segs = VocoderPattern.prSegment(sm, voiced, minFrames, 1.0);
		segs = segs.select { |s| (s[1] - s[0] + 1) >= minFrames };
		smoothed = sm; conf = cf;
		// birth keys = 0,1,2,... (== position). Splits/merges later keep these stable so
		// references survive editing; integer N addresses the whole original note [N, N+1).
		midiEvents = segs.collect { |seg, segIdx|
			var lo = seg[0], hi = seg[1];
			var vals = (lo..hi).select { |i| voiced[i] }.collect { |i| sm[i] };
			var center = vals.isEmpty.if({ 0 }, { VocoderPattern.prMedian(vals) });
			(
				midicmd: \noteOn, type: \note,
				key: segIdx,
				timestamp: lo * aHop / sr,
				dur: (hi - lo + 1) * aHop / sr,
				sustain: (hi - lo + 1) * aHop / sr,
				midinote: VocoderPattern.prQuantize(center, scale, 0),
				measuredCenter: center
			)
		};
		^midiEvents
	}

	player { ^RetunePlayer(midiEvents.deepCopy, this) }
	play     { |rate = 1 ...args, kwargs| this.whenReady({ this.player.performArgs(\play,     [rate] ++ args, kwargs) }); ^this }
	playTrue { |rate = 1 ...args, kwargs| this.whenReady({ this.player.performArgs(\playTrue, [rate] ++ args, kwargs) }); ^this }
	playRB   { |rate = 1 ...args, kwargs| this.whenReady({ this.player.performArgs(\playRB,   [rate] ++ args, kwargs) }); ^this }
	playNote { |key|
		var sub = this.prNotesForKey(key);
		sub.isEmpty.if { ^("RetuneItem.playNote: no note with key %".format(key)).warn };
		^Synth(\retunePreview, [\voice, voice, \start, sub.first.timestamp,
			\dur, sub.last.timestamp + (sub.last.dur ? 0) - sub.first.timestamp]);
	}
	// tune the whole item to a reference melody (see RetunePlayer.tuneTo)
	tuneTo { |reference, amount = 1| ^this.player.tuneTo(reference, amount) }
}

RetunePlayer : AbstractRetune {
	var <>midiEvents, <source, <>start, <>end;
	var <synth, <curve;
	var <>playStart, <>playEnd;   // playback window in seconds (nil = whole buffer); set by fromNote

	*new { |midiEvents, source| ^super.new.prInit(midiEvents, source) }
	prInit { |evts, src|
		midiEvents = evts; source = src;
		(evts.notNil and: { evts.notEmpty }).if {
			start = evts.first.timestamp;
			end = evts.last.timestamp + (evts.last.dur ? 0);
		};
		^this
	}
	player { ^this }
	copyBounds { |mi| start = mi.start; end = mi.end; ^this }
	setBounds { |e| start = e.start; end = e.end; ^this }

	// ---- filters: each returns a new RetunePlayer (collect is forwarded by doesNotUnderstand) ----
	transpose { |semis|
		^this.collect { |e| var n = e.copy; n.midinote = n.midinote + semis; n }
	}
	// index args are stable note keys (integer N = whole original note [N, N+1))
	move { |key, semis|
		var m = this.prKeyMatch(key);
		^this.collect { |e| m.(e).if({ var n = e.copy; n.midinote = n.midinote + semis; n }, { e }) }
	}
	set { |key, midi|
		var m = this.prKeyMatch(key);
		^this.collect { |e| m.(e).if({ var n = e.copy; n.midinote = midi; n }, { e }) }
	}
	bypass { |key|
		var m = this.prKeyMatch(key);
		^this.collect { |e| m.(e).if({ var n = e.copy; n.midinote = n.measuredCenter; n }, { e }) }
	}
	snapToScale { |scale, root = 0|
		^this.collect { |e| var n = e.copy; n.midinote = VocoderPattern.prQuantize(n.midinote, scale, root); n }
	}
	// reference-guided tuning (retune-project.md §2d / milestone 7). Set each note's
	// target (midinote) from a reference melody. `reference` is a MIDIItem or a compact
	// spec ([midinote:..., dur:...]) coerced via asMIDIItem; both reduce to (refPitch,
	// refBeat). v0 alignment: normalize the detected onsets (sec) and the reference onsets
	// (beats) each to [0,1] over their span and match each detected note to the nearest
	// reference note in normalized time (graceful when the counts differ; pitch is not yet
	// used in the match -- DTW is §8, so the reference should cover the same phrase as this
	// player). Target = the reference pitch-class at the octave nearest the sung center
	// (snaps pitch, keeps the singer's register, repairs small errors), blended from
	// measuredCenter by `amount` (1 = full snap, 0 = uncorrected). Records the matched
	// (refMidi, refBeat) on each note -- the warp anchors ride on the note model, so they
	// persist with split-takes and feed the later onset-warp. Onsets are NOT moved here:
	// the time axis is frozen (milestone 9).
	tuneTo { |reference, amount = 1|
		var ref, refNotes, refPitch, refBeat, det, detOn, dlo, dspan, rlo, rspan, detN, refN;
		ref = reference.isKindOf(MIDIItem).if({ reference }, { reference.asMIDIItem });
		refNotes = ref.player.notes;
		refNotes.isEmpty.if { ^"Retune.tuneTo: reference has no notes".warn };
		refPitch = refNotes.collect(_.midinote);
		refBeat  = refNotes.collect(_.timestamp);
		det = this.notes;
		det.isEmpty.if { ^this };
		detOn = det.collect(_.timestamp);
		dlo = detOn.first;   dspan = (detOn.last  - dlo).max(1e-9);
		rlo = refBeat.first; rspan = (refBeat.last - rlo).max(1e-9);
		detN = detOn.collect  { |t| (t - dlo) / dspan };
		refN = refBeat.collect { |t| (t - rlo) / rspan };
		^this.collect { |e, i|
			var dn = detN[i], mc = e.measuredCenter ? e.midinote;
			var j = (0 .. refN.lastIndex).minItem { |k| (refN[k] - dn).abs };
			var rp = refPitch[j];
			var snapped = rp + (12 * ((mc - rp) / 12).round);
			var n = e.copy;
			n.midinote = mc + ((snapped - mc) * amount);
			n.refMidi = rp; n.refBeat = refBeat[j];
			n
		}
	}

	// ---- structural edits: re-segment from the source's retained per-frame data ----
	// build a fresh note Event for span [t0,t1] (seconds): center = median of smoothed over
	// the voiced frames, target = quantized center. This is the analysis logic, reusable.
	prNoteForSpan { |t0, t1|
		var src = this.source, aHop = src.analysisHop, sr = src.sampleRate;
		var sm = src.smoothed, cf = src.conf, nf = src.smoothed.size, lo, hi, vals, center;
		lo = (t0 * sr / aHop).round.asInteger.clip(0, nf - 1);
		hi = (t1 * sr / aHop).round.asInteger.clip(0, nf - 1);
		vals = (lo..hi).select({ |i| (cf[i] > 0.4) and: { sm[i] > 0 } }).collect({ |i| sm[i] });
		center = vals.isEmpty.if({ 0 }, { VocoderPattern.prMedian(vals) });
		^(
			midicmd: \noteOn, type: \note,
			timestamp: t0, dur: (t1 - t0), sustain: (t1 - t0),
			midinote: VocoderPattern.prQuantize(center, src.scale, 0),
			measuredCenter: center
		)
	}
	// split note at `index` (array position): left half keeps the note's key, right half gets
	// the midpoint to the next key (last note -> floor(k)+1) -> sorts between, nothing else
	// renumbers. e.g. note 12 -> 12 and 12.5; re-splitting 12 -> 12 and 12.25.
	splitAt { |index, time|
		var ns = this.notes, n = this.notes[index], a, b, k, nextKey, left, right, out;
		n.isNil.if { ^this };
		a = n.timestamp; b = n.timestamp + (n.dur ? 0);
		((time <= a) or: { time >= b }).if { ^this };   // outside the note -> no-op
		k = n[\key] ? index;
		nextKey = ns[index + 1].notNil.if({ ns[index + 1][\key] ? (k.floor + 1) }, { k.floor + 1 });
		left  = this.prNoteForSpan(a, time);    left[\key]  = k;
		right = this.prNoteForSpan(time, b);    right[\key] = (k + nextKey) / 2;
		out = ns.keep(index) ++ [left, right] ++ ns.drop(index + 1);
		^RetunePlayer(out, this.source).copyBounds(this)
	}
	merge { |indices|   // merge a contiguous run of note positions into one; keeps the lower key
		var ns = this.notes, s = indices.asArray.sort, lo, hi, a, b, merged, out;
		(s.size < 2).if { ^this };
		lo = s.first; hi = s.last;
		(ns[lo].isNil or: { ns[hi].isNil }).if { ^this };
		a = ns[lo].timestamp; b = ns[hi].timestamp + (ns[hi].dur ? 0);
		merged = this.prNoteForSpan(a, b);
		merged[\key] = ns[lo][\key] ? lo;   // lower key wins; higher keys retire
		out = ns.keep(lo) ++ [merged] ++ ns.drop(hi + 1);
		^RetunePlayer(out, this.source).copyBounds(this)
	}
	moveBoundary { |index, time|   // move boundary between positions index/index+1; keys unchanged
		var ns = this.notes, a, c, ka, kb, left, right, out;
		(ns[index].isNil or: { ns[index + 1].isNil }).if { ^this };
		a = ns[index].timestamp;
		c = ns[index + 1].timestamp + (ns[index + 1].dur ? 0);
		((time <= a) or: { time >= c }).if { ^this };
		ka = ns[index][\key]; kb = ns[index + 1][\key];
		left  = this.prNoteForSpan(a, time);    left[\key]  = ka;
		right = this.prNoteForSpan(time, c);    right[\key] = kb;
		out = ns.copy;
		out[index] = left;
		out[index + 1] = right;
		^RetunePlayer(out, this.source).copyBounds(this)
	}

	// ---- build the 4-ch curve [smoothed, mcenter, target, conf] from notes + item data ----
	render { |action|
		var aHop = source.analysisHop, sr = source.sampleRate;
		var sm = source.smoothed, cf = source.conf, nframes = sm.size;
		var mc = Array.fill(nframes, 0), tc = Array.fill(nframes, 0), interleaved;
		midiEvents.do { |e|
			var lo = (e.timestamp * sr / aHop).round.asInteger.clip(0, nframes - 1);
			var hi = ((e.timestamp + (e.dur ? 0)) * sr / aHop).round.asInteger.clip(0, nframes - 1);
			(lo..hi).do { |i| mc[i] = e.measuredCenter ? 0; tc[i] = e.midinote ? 0 };
		};
		interleaved = nframes.collect { |i| [sm[i], mc[i], tc[i], cf[i]] }.flatten;
		// each play frees its OWN curve when its synth ends (see prPlay) -> no leak, and no
		// shared-ivar double-free if the same player is re-rendered while a synth is still live
		curve = Buffer.loadCollection(Server.default, interleaved, 4, { action.value(this) });
		^this
	}
	prPlay { |defName, rate, kwargs|
		var s = playStart ? 0;
		var d = playEnd.notNil.if({ playEnd - (playStart ? 0) }, { 0 });   // 0 = whole buffer
		this.render({
			var c = curve;   // this play's curve; capture so onFree can't free a later one
			synth = Synth(defName,
				[\voice, source.buffer, \curve, c, \analysisHop, source.analysisHop,
				 \startPos, s, \playDur, d, \rate, rate] ++ (kwargs ? []));
			// free the curve buffer when playback ends (doneAction / FreeSelf), else 4-ch curves
			// leak and their bufnums eventually clobber the 1-ch voice buffer
			synth.onFree({ c.free });
		});
		^this
	}
	// rate = playback speed (time stretch). On RB it is decoupled from pitch (0.5 = half speed,
	// same pitch); the cepstral engines resample (couples pitch + mis-indexes the correction by
	// 12*log2(rate)) so they refuse rate != 1 -- see retune-project.md §2a. Extra keyword args
	// (amp:, dry:, glide:, modAmt:, formant:, liftK: ...) pass straight through to the SynthDef.
	play     { |rate = 1 ...args, kwargs| ^this.prPlay(\autotuneNotes,     this.prCepstralRate(rate), kwargs) }
	playTrue { |rate = 1 ...args, kwargs| ^this.prPlay(\autotuneNotesTrue, this.prCepstralRate(rate), kwargs) }
	playRB   { |rate = 1 ...args, kwargs| ^this.prPlay(\autotuneRB,        rate, kwargs) }
	prCepstralRate { |rate|   // cepstral mistunes at rate != 1; clamp to 1 with a warning
		^(rate != 1).if({
			("Retune: cepstral engines mistune at rate != 1 (off by 12*log2(rate)); "
			 "use .playRB for time-stretch. Forcing rate 1.").warn; 1
		}, { rate })
	}
	// audition the original audio of the note(s) referenced by `key` (integer N -> whole
	// original note [N, N+1); fractional -> one fragment)
	playNote { |key|
		var sub = this.prNotesForKey(key);
		sub.isEmpty.if { ^("Retune.playNote: no note with key %".format(key)).warn };
		^this.prPreview(sub.first.timestamp,
			sub.last.timestamp + (sub.last.dur ? 0) - sub.first.timestamp);
	}
	// play a raw [t0, dur] slice of the source audio (gui click auditions one exact fragment)
	prPreview { |t0, dur|
		^Synth(\retunePreview, [\voice, source.buffer, \start, t0, \dur, (dur ? 0.3)]);
	}
	free { synth !? _.free; curve !? _.free; ^this }
}
