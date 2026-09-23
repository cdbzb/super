// The Take window (audio-beat-marking-plan.md step 5): mark beats on an audio take
// the way AbstractMidiEvents.gui does on a MIDI take, including material with no
// pitch. A HOST, like the MIDI gui: window, waveform, transport, clicks. The
// editing model is the same two controllers —
//   BeatMarkMode over the take's TRANSIENTS (TakeTransients) — where the beats are
//   MapEditor over the beat grid — what the tempo should be
// — so everything they do on MIDI (e/E, h/l/j/k, m + span ops, u/U, W) works here.
//
// Everything on screen is FILE SECONDS (physical position in the take), so there
// is no t0 shift while auditioning; what you mark is what take.tempoMap answers.
//
//   Take(\drums, 3).gui;
//   Take(\drums, 3).gui(thresh: 0.2, odftype: \power);   // detector params
//
// Mouse, outside a grid: click a transient tick to select / deselect it (pick
// two, then e or E); click elsewhere to move the cursor.
// Mouse, with a grid up: drag a line and release — it snaps to the nearest
// transient within `snapPx` pixels (alt: no snap, a free pin); double-click puts a
// free pin on the nearest line; right-click unpins the nearest line.
// Keys: space play/stop · c clicks · C count-in · w save marks · r clear · 0 reset
// view · h/l scroll, H/L zoom (outside a grid) · q close · ? help.
TakeGui {
	classvar <>snapPx = 8;
	var <take, <path, <sampleRate, <numFrames, <numChannels, <dur;
	var <transients, <beatMark, <mapEd, <nav, <params;
	var <marks;                  // the marks version loaded at open (nil = none)
	var savedTimes;              // beat times from the loaded marks, when no grid is up
	var peakMin, peakMax, peakBin = 256;
	var window, view, width = 1400, height = 520, waveTop = 130;
	var <cursorTime = 0, playhead, isPlaying = false, playSynth, clickClock;
	var playStartWall, playOrigin, clickEnabled = false, countIn = 0;
	var dragLine, dragX;

	*new { |take, params| ^super.new.prInit(take, params) }

	prInit { |aTake, someParams|
		var sf;
		take = aTake;
		params = TakeTransients.params(someParams);
		path = AudioItem.takePath(AudioItem.folder +/+ take.name.asString, take.num);
		sf = SoundFile.openRead(path);
		sf.isNil.if { ^"TakeGui: cannot open %".format(path).warn };
		sampleRate = sf.sampleRate; numFrames = sf.numFrames; numChannels = sf.numChannels;
		sf.close;
		dur = numFrames / sampleRate;
		mapEd = MapEditor.new;
		mapEd.sourceFunc = { [this.beatTimes ? [], 1] };
		mapEd.onChange = { this.refresh };
		mapEd.audition = { |times| this.prClickTimes(times) };
		mapEd.onSave = { |map| this.prSaveMap(map) };
		clickClock = TempoClock(1, queueSize: 2048);
		this.prPreviewDef;   // sent now, so play never has to wait on a sync
		this.prReadPeaks;
		this.prLoadMarks;
		this.prOpen;
		TakeTransients.forTake(take.name, take.num, path,
			{ |t| { this.prSetTransients(t) }.defer }, false, params);
		^this
	}

	// ---- model ----------------------------------------------------------------

	// The beat grid the lane, the clicks and the map read: the live grid first,
	// else the loaded marks.
	beatTimes { ^(beatMark !? { beatMark.gridTimes }) ?? { savedTimes } }

	prSetTransients { |t|
		transients = t;
		beatMark = BeatMarkMode(transients, dur);
		beatMark.salienceFunc = TakeTransients.salienceFor(transients);
		beatMark.onChange = { this.refresh };
		beatMark.onGridChange = { mapEd.invalidate; this.refresh };
		beatMark.ensureVisible = { |t| this.prEnsureVisible(t) };
		beatMark.onSave = { |sel| this.prSaveSelection(sel) };
		(marks !? { marks[\selection] }).notNil.if {
			beatMark.resume(marks[\selection]);
			mapEd.invalidate;
		};
		"TakeGui: % transients".format(transients.size).postln;
		this.refresh;
	}

	prLoadMarks {
		marks = TakeArchive.loadMarks(take.name, take.num);
		marks.isNil.if { ^this };
		savedTimes = marks[\anchors].collect(_[\src]);
		// an edited map has no beat grid to re-read: hand the map itself over
		marks[\selection].isNil.if {
			mapEd.loadMap(AnchorMap.fromAnchors(
				marks[\anchors].collect(_[\beat]), savedTimes,
				fromFrame: \beat, toFrame: \sec));
		};
		"TakeGui: loaded marks version % (% anchors)"
			.format(marks[\version], marks[\anchors].size).postln;
	}

	prSaveSelection { |sel|
		var v;
		sel[\anchors].isNil.if { ^"TakeGui: no beat grid up — nothing to save (e/E first)".postln };
		v = TakeArchive.writeMarks(take.name, take.num, sel[\anchors], sel,
			(transientParams: params));
		savedTimes = sel[\anchors].collect(_[\src]);
		"TakeGui: saved marks version % (% beats)".format(v, sel[\anchors].size).postln;
	}

	prSaveMap { |map|
		var v = TakeArchive.writeMarks(take.name, take.num,
			[map.ys, map.xs].flop, nil, (transientParams: params, edited: true));
		"TakeGui: saved edited map as marks version %".format(v).postln;
	}

	// ---- peaks: min/max per `peakBin` frames of the analysed channel ----------

	prReadPeaks {
		var sf = SoundFile.openRead(path), chunk = 65536, nBins, buf, pos = 0, bin = 0;
		var ch = params[\channel];
		nBins = (numFrames / peakBin).ceil.asInteger;
		peakMin = FloatArray.newClear(nBins); peakMax = FloatArray.newClear(nBins);
		buf = FloatArray.newClear(chunk * numChannels);
		while { pos < numFrames } {
			var n = (numFrames - pos).min(chunk), frames;
			(n < chunk).if { buf = FloatArray.newClear(n * numChannels) };
			sf.readData(buf);
			frames = buf.clump(numChannels).collect { |f|
				(ch == \mix).if { f.sum } { f.wrapAt(ch ? 0) }
			};
			frames.clump(peakBin).do { |seg|
				(bin < nBins).if {
					peakMin[bin] = seg.minItem; peakMax[bin] = seg.maxItem;
					bin = bin + 1
				}
			};
			pos = pos + n;
		};
		sf.close;
	}

	// ---- transport ---------------------------------------------------------

	prPreviewDef {
		var name = ("takeGuiPreview" ++ numChannels).asSymbol, nch = numChannels;
		SynthDescLib.global.at(name).isNil.if {
			SynthDef(name, { |buf, start = 0, amp = 1|
				var sig = PlayBuf.ar(nch, buf, BufRateScale.kr(buf), 1,
					start * BufSampleRate.kr(buf), doneAction: 2);
				Out.ar(0, (nch == 1).if { sig ! 2 } { sig } * amp)
			}).add;
		};
		^name
	}

	togglePlay { ^isPlaying.if { this.stop } { this.play(cursorTime) } }

	play { |from|
		var defName = this.prPreviewDef, sched, offset, server = Server.default;
		this.stop;
		sched = BeatMarkMode.clickSchedule(this.beatTimes ? [], from, countIn, clickEnabled);
		offset = sched[\offset];
		((countIn > 0) and: { offset == 0 }).if { "count-in: no beat grid — starting immediately".postln };
		isPlaying = true;
		playOrigin = from;
		playStartWall = SystemClock.seconds + offset;
		sched[\clicks].do { |c|
			clickClock.sched(c[0], {
				var ev = (instrument: \hihat);
				c[1] !? { ev[\amp] = c[1] };
				ev.play; nil
			})
		};
		// the media on the SAME clock as the clicks, after the count-in, bundled with
		// the same server latency the click Events use — so they line up
		clickClock.sched(offset, {
			server.makeBundle(server.latency, {
				playSynth = Synth(defName, [\buf, take.buffer, \start, from])
			});
			nil
		});
		Routine({
			var lat = server.latency ? 0;
			while { isPlaying and: { (playhead ? 0) <= dur } } {
				playhead = (from + (SystemClock.seconds - playStartWall - lat)).max(from);
				this.refresh;
				(1/30).wait;
			};
			isPlaying.if { this.stop };
		}).play(AppClock);
	}

	stop {
		isPlaying = false;
		clickClock.clear;
		playSynth !? { playSynth.free; playSynth = nil };
		playhead = nil;
		this.refresh;
	}

	// audition: click at these times (MapEditor's P), relative to the first
	prClickTimes { |times|
		var t0 = times.first;
		clickClock.clear;
		times.do { |t, i|
			clickClock.sched(t - t0, { (instrument: \hihat, amp: (i == 0).if { 0.2 }{ 0.1 }).play; nil })
		}
	}

	// ---- view --------------------------------------------------------------

	refresh { view !? { { view.refresh }.defer } }

	prEnsureVisible { |t|
		((t < nav.viewStart) or: { t > nav.viewEnd }).if {
			var d = nav.dur;
			nav.viewStart = (t - (d * 0.25)).max(0);
			nav.viewEnd = nav.viewStart + d;
		}
	}

	prOpen {
		nav = PianoRollNav(0, dur, 0, 1, width, height, 0);
		{
			window = Window("Take % / %".format(take.name, take.num), Rect(60, 60, width, height)).front;
			window.onClose = { this.stop };
			view = UserView(window, Rect(0, 0, width, height))
				.background_(Color.grey(0.97))
				.drawFunc_({ this.prDraw })
				.mouseDownAction_({ |v, x, y, mod, btn, clicks| this.prMouseDown(x, y, mod, btn, clicks) })
				.mouseMoveAction_({ |v, x, y, mod| this.prMouseMove(x, y, mod) })
				.mouseUpAction_({ |v, x, y, mod| this.prMouseUp(x, y, mod) })
				.keyDownAction_({ |v, char| this.prKey(char) });
			view.focus(true);
		}.defer;
	}

	prDraw {
		var vs = nav.viewStart, ve = nav.viewEnd, xOf = { |t| nav.xOf(t) };
		var mid = (waveTop + height) / 2, halfH = (height - waveTop) / 2 - 10;
		var binsPerPx = ((ve - vs) * sampleRate / peakBin / width).max(1e-9);
		// tempo lane first, so nothing is drawn under it twice
		mapEd.drawLane(vs, ve, width);
		// waveform: one min/max bar per pixel
		Pen.color = Color.grey(0.45);
		width.do { |px|
			var b0 = ((vs * sampleRate / peakBin) + (px * binsPerPx)).floor.asInteger;
			var b1 = (b0 + binsPerPx.ceil.asInteger).min(peakMin.size);
			var lo = 0, hi = 0;
			(b0 < peakMin.size and: { b0 >= 0 }).if {
				b0.for(b1 - 1) { |b| lo = lo.min(peakMin[b]); hi = hi.max(peakMax[b]) };
				Pen.line(px @ (mid - (hi * halfH)), px @ (mid - (lo * halfH)));
			}
		};
		Pen.stroke;
		// transient ticks, alpha by strength; selected ones in orange
		transients.notNil.if {
			var sal = beatMark.salienceFunc, sel = beatMark.selectedIndices.asSet;
			transients.do { |e, i|
				var t = e[\timestamp], x;
				((t >= vs) and: { t <= ve }).if {
					x = xOf.(t);
					Pen.color = sel.includes(i).if { Color(1, 0.5, 0, 0.95) } {
						Color(0, 0.3, 0.8, 0.25 + (0.6 * sal.(e)))
					};
					Pen.line(x @ (waveTop), x @ (waveTop + 14));
					Pen.stroke;
				}
			};
			beatMark.draw(xOf, { |t| (t >= vs) and: { t <= ve } }, height);
		} {
			Pen.stringAtPoint("detecting transients…", 10 @ 30, Font("Helvetica", 12), Color.grey(0.4));
		};
		// saved marks, when no grid is up
		(beatMark.isNil or: { beatMark.extrapolateMode.not }).if {
			savedTimes !? {
				Pen.color = Color(0.2, 0.6, 0.2, 0.5);
				savedTimes.do { |t| ((t >= vs) and: { t <= ve }).if {
					Pen.line(xOf.(t) @ waveTop, xOf.(t) @ height)
				} };
				Pen.stroke;
			}
		};
		// drag preview
		dragX !? { Pen.color = Color(0.9, 0.2, 0.2, 0.5); Pen.line(dragX @ 0, dragX @ height); Pen.stroke };
		// cursor and playhead
		Pen.color = Color.black;
		Pen.line(xOf.(cursorTime) @ waveTop, xOf.(cursorTime) @ height); Pen.stroke;
		playhead !? { Pen.color = Color.red; Pen.line(xOf.(playhead) @ 0, xOf.(playhead) @ height); Pen.stroke };
		mapEd.drawEditOverlay(vs, ve, width, height);
		Pen.stringAtPoint("space play · c clicks% · C count-in % · w save · e/E grid · m map edit · ?"
			.format(clickEnabled.if(" on", ""), countIn), 10 @ (height - 16),
			Font("Helvetica", 10), Color.grey(0.4));
	}

	prMouseDown { |x, y, mod, btn, clicks|
		var t = nav.tOf(x), grid, hit;
		mapEd.mouseDown(x, y, nav.viewStart, nav.viewEnd, width).if { ^this };
		beatMark.isNil.if { cursorTime = t; ^this.refresh };
		grid = beatMark.extrapolateMode;
		grid.if {
			var li = beatMark.lineNear(t);
			case
			{ btn == 1 } { li !? { beatMark.unpinLine(li) } }
			{ clicks >= 2 } { li !? { beatMark.pinLine(li, t) } }
			{ li.notNil and: { (nav.xOf(beatMark.gridLines[li][\time]) - x).abs < 6 } } {
				dragLine = li; dragX = x
			}
			{ cursorTime = t };
			^this.refresh
		};
		// no grid: a click near a transient toggles it; elsewhere moves the cursor
		hit = beatMark.nearestIndex(t, snapPx * nav.dur / width);
		hit.notNil.if {
			beatMark.selectedIndices.includes(hit).if {
				beatMark.selectedIndices = beatMark.selectedIndices.reject { |i| i == hit }
			} {
				beatMark.selectedIndices = beatMark.selectedIndices ++ [hit]
			};
			mapEd.invalidate;
		} { cursorTime = t };
		this.refresh;
	}

	prMouseMove { |x, y, mod|
		mapEd.mouseMove(x, y, nav.viewStart, nav.viewEnd, width).if { ^this };
		dragLine !? { dragX = x; this.refresh };
	}

	prMouseUp { |x, y, mod|
		var snap;
		mapEd.mouseUp.if { ^this };
		dragLine !? {
			snap = mod.isAlt.not.if { snapPx * nav.dur / width };
			beatMark.moveLine(dragLine, nav.tOf(x), snap);
			dragLine = nil; dragX = nil;
			this.refresh;
		};
	}

	prKey { |char|
		(mapEd.keyDown(char, cursorTime)).if { ^this.refresh };
		(beatMark.notNil and: { beatMark.keyDown(char) }).if { ^this.refresh };
		nav.keyDown(char).if { ^this.refresh };
		switch(char,
			$ , { this.togglePlay },
			$c, {
				clickEnabled = clickEnabled.not;
				clickEnabled.not.if { clickClock.clear };
				("Beat clicks " ++ clickEnabled.if("on", "off")).postln;
			},
			$C, {
				countIn = (countIn + 2) % 6;
				("Count-in " ++ (countIn == 0).if { "off" } { countIn.asString ++ " beats" }).postln;
			},
			$w, { beatMark !? { beatMark.save } },
			$r, { beatMark !? { beatMark.clear; mapEd.invalidate; "cleared".postln } },
			$0, { nav.resetView },
			$q, { window.close },
			$?, { ("TakeGui keys: space play/stop · c clicks · C count-in · w save marks · r clear · "
				"e/E beat grid (then h/l line, j/k re-pick) · m map edit (i/o span, Q V N R S F B, "
				"P audition, u/U, Z, W commit+save) · h/l scroll, H/L zoom · 0 reset · q close\n"
				"mouse: click tick = select · drag line = move (alt: free) · dbl-click = free pin · "
				"right-click = unpin").postln }
		);
		this.refresh;
	}
}

+ Take {
	// The Take window: waveform, transients, beat marking, tempo lane. Keyword args
	// are TakeTransients detector params (thresh:, odftype:, channel: ...).
	gui { |...args, kwargs|
		var params = ();
		(kwargs ? []).pairsDo { |k, v| params[k] = v };
		^TakeGui(this, params)
	}
}
