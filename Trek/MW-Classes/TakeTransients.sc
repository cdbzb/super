// Transient detection for audio takes (audio-beat-marking-plan.md step 3): the
// note model BeatMarkMode and MIDIBeatTracker need for material that has no
// pitch. Each detected hit is an Event
//     (timestamp: <file seconds>, amp: <envelope at the hit>, strength: <ODF peak>)
// in time order, which is exactly what BeatMarkMode reads (timestamp) and what
// MIDIBeatTracker's salience can use (strength).
//
// Vocabulary: "transient" is an audio hit; "onset" keeps meaning a MIDI note-on
// (MIDIItemPlayer.onsets). `strength` is the detector's ODF peak; `salience`
// stays the tracker's derived weight (salienceFor turns one into the other).
//
// Detection runs NRT in a separate scsynth through the OfflineProcess quark (the
// VocoderPattern.trackPitchOffline precedent), so the live server is never
// touched: Onsets.kr (trigger) + Onsets.kr rawodf (strength) + Amplitude.kr,
// recorded at control rate, read back with SoundFile. Onsets fires about one FFT
// window late, so each hit is walked back to the leading edge of the waveform
// envelope (backtrack), bounded by the window and the previous hit.
//
// Results are cached per take and per parameter set under
//     _transients/<name>_<num>/<hash>.archive
// — deliberately NOT under _retune/<name>_<num>/: creating that directory for an
// old take would block RetuneItem's legacy-cache migration.
TakeTransients {

	*defaults {
		^(
			odftype: \rcomplex,   // \power suits clean percussion; \rcomplex is the all-rounder
			thresh: 0.3,          // Onsets threshold (lower = more hits)
			relaxtime: 1,
			floor: 0.1,
			mingap: 10,           // Onsets mingap, in FFT frames
			fftSize: 512,
			channel: 0,           // which input channel to analyse; \mix sums all
			edge: 0.2,            // backtrack: the attack is where |x| last reaches edge * peak
			gap: 0.001,           // backtrack: quieter stretches shorter than this (s) are bridged
			minAmp: 0.01          // drop hits quieter than this fraction of the loudest (noise-floor triggers)
		)
	}

	*folder { ^AudioItem.folder +/+ "_transients" }
	*dir { |name, num| ^this.folder +/+ (name.asString ++ "_" ++ num.asString) }

	// The cache key: every parameter plus the audio file's size and mtime, so a
	// re-recorded or edited file never answers a stale detection.
	*cachePath { |name, num, path, params|
		var key = params.asSortedArray.asCompileString
			++ File.fileSize(path) ++ File.mtime(path);
		^this.dir(name, num) +/+ (key.hash.abs.asString ++ ".archive")
	}

	*params { |overrides|
		var p = this.defaults;
		overrides !? { overrides.keysValuesDo { |k, v| p[k] = v } };
		^p
	}

	// Cached transients for a take, or nil. Never renders.
	*load { |name, num, path, params|
		var cp = this.cachePath(name, num, path, this.params(params));
		^File.exists(cp).if { Object.readArchive(cp) }
	}

	// Transients for (name, num) at `path`. On a cache hit `action` fires
	// synchronously and the Array is answered; on a miss the NRT render starts,
	// nil is answered, and `action` fires (on a Routine) when it lands. Routine
	// callers that want to block can wrap the call in a Condition.
	*forTake { |name, num, path, action, force = false, params|
		var p = this.params(params), cp = this.cachePath(name, num, path, p), cached;
		(force.not and: { File.exists(cp) }).if {
			cached = Object.readArchive(cp);
			action.value(cached);
			^cached
		};
		this.detect(path, p, { |result|
			File.exists(this.folder).not.if { File.mkdir(this.folder) };
			File.exists(this.dir(name, num)).not.if { File.mkdir(this.dir(name, num)) };
			result.writeArchive(cp);
			action.value(result);
		});
		^nil
	}

	// Uncached detection: NRT render, peak pick, backtrack. action.(transients).
	*detect { |path, params, action|
		var p = this.params(params), proc, run, sf, sr;
		path = path.standardizePath;
		sf = SoundFile.openRead(path);
		sf.isNil.if { ^"TakeTransients.detect: cannot open %".format(path).warn };
		sr = sf.sampleRate; sf.close;
		proc = OfflineProcess();
		proc.putKr(\transients, { |input|
			var sig = (p[\channel] == \mix).if { input.asArray.sum } {
				input.asArray.wrapAt(p[\channel] ? 0)
			};
			var chain = FFT(LocalBuf(p[\fftSize]), sig);
			[
				Onsets.kr(chain, p[\thresh], p[\odftype], p[\relaxtime], p[\floor], p[\mingap]),
				Onsets.kr(chain, p[\thresh], p[\odftype], p[\relaxtime], p[\floor], p[\mingap],
					rawodf: 1),
				Amplitude.kr(sig, 0.001, 0.05)
			]
		});
		run = proc.process(path);
		fork {
			var data, events;
			run.wait;
			data = run.resultData(\transients);   // [trig, odf, amp] Signals
			events = this.pick(data, run.controlRate, p);
			events = this.backtrack(path, events, p);
			"TakeTransients: % transients in %".format(events.size, path.basename).postln;
			action.value(events);
		};
		^run
	}

	// Pure: control-rate [trig, odf, amp] channels -> transient Events. A hit is a
	// RISING edge of the trigger (Onsets holds its output for a whole FFT hop, i.e.
	// several control blocks); its strength is the ODF maximum within +-2 frames
	// (the raw ODF peaks around, not exactly on, the frame the detector fires).
	// Hits quieter than minAmp times the loudest are dropped: Onsets also fires on
	// the noise floor, e.g. at the very start of a file.
	*pick { |data, controlRate, params|
		var p = this.params(params), trig = data[0], odf = data[1], amp = data[2];
		var out = [], prev = 0, loud;
		trig.do { |v, i|
			((v > 0) and: { prev <= 0 }).if {
				var lo = (i - 2).max(0), hi = (i + 2).min(odf.size - 1);
				out = out.add((
					timestamp: i / controlRate,
					strength: odf[lo..hi].maxItem,
					amp: amp[(i + 2).min(amp.size - 1)]   // Amplitude.kr lags the attack
				))
			};
			prev = v;
		};
		loud = out.collect(_[\amp]).maxItem ? 0;
		^out.select { |e| e[\amp] >= (loud * p[\minAmp]) }
	}

	// Walk each hit back to its leading edge. Reads only a window of audio per hit
	// (never the whole file): from one FFT window and a half before the detected
	// time (or the previous hit, whichever is later) to a quarter window after.
	// From the window's peak, walk BACK through samples at or above `edge` times
	// that peak, bridging quieter stretches shorter than `gap` seconds (|x| dips to
	// zero every half cycle, so a plain threshold crossing would stop at the first
	// zero crossing before the peak). The earliest sample reached is the edge.
	*backtrack { |path, events, params|
		var p = this.params(params), sf, sr, nch, win, gapN, prevT = 0, out;
		sf = SoundFile.openRead(path.standardizePath);
		sf.isNil.if { ^events };
		sr = sf.sampleRate; nch = sf.numChannels;
		win = p[\fftSize];
		gapN = (p[\gap] * sr).round.asInteger.max(1);
		out = events.collect { |e|
			var a = ((e[\timestamp] * sr) - (win * 1.5)).max(prevT * sr).max(0).asInteger;
			var b = ((e[\timestamp] * sr) + (win * 0.25)).min(sf.numFrames).asInteger;
			var n = b - a, buf, mono, peak = 0, peakI = 0, thr, edgeI, found, t, c;
			(n > 8).if {
				buf = FloatArray.newClear(n * nch);
				sf.seek(a, 0);
				sf.readData(buf);
				mono = (p[\channel] == \mix).if {
					buf.clump(nch).collect { |f| f.sum.abs }
				} {
					buf.clump(nch).collect { |f| f.wrapAt(p[\channel] ? 0).abs }
				};
				mono.do { |x, i| (x > peak).if { peak = x; peakI = i } };
				thr = peak * p[\edge];
				edgeI = peakI;
				found = true;
				while { found and: { edgeI > 0 } } {
					var lo = (edgeI - gapN).max(0);
					found = false;
					lo.for(edgeI - 1) { |q|
						(found.not and: { mono[q] >= thr }).if { edgeI = q; found = true }
					};
				};
				t = (a + edgeI) / sr;
			} {
				t = e[\timestamp]
			};
			prevT = t + (1 / sr);
			c = e.copy;
			c[\timestamp] = t;
			c
		};
		sf.close;
		^out
	}

	// A MIDIBeatTracker salienceFunc over these transients: strength normalised to
	// 0..1 by the loudest hit (the default func would read amp and add chord bonuses).
	*salienceFor { |transients|
		var mx = (transients.collect { |e| e[\strength] ? 0 }.maxItem ? 1).max(1e-9);
		^{ |note| (note[\strength] ? 0) / mx }
	}
}

+ Take {
	// Transients of this take (TakeTransients.forTake): the cached Array on a hit
	// (action fires at once), else nil and action fires when detection lands.
	//     Take(\drums, 3).transients({ |t| t.size.postln }, thresh: 0.2)
	transients { |action, force = false ...args, kwargs|
		var params = ();
		(kwargs ? []).pairsDo { |k, v| params[k] = v };
		^TakeTransients.forTake(name, num,
			AudioItem.takePath(AudioItem.folder +/+ name.asString, num), action, force, params)
	}
}
