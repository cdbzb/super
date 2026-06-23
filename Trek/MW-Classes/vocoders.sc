VocoderPattern {
//	var durs , <pattern, <item, effect, out, bypass, hop, fftSize, window=1;
	var pattern,key,effect,<inputEffect,fftSize,hop,window,<>warp,out,amp,pan,loop,rate,durs,>dry;
	var <modulator,verb,<carrier,<synthOut,<synth,<item;
	classvar <>server;
	*initClass {
		server = Server.default;
                Class.initClassTree(SynthDescLib);
                Class.initClassTree(FluidPitch); // populate FluidPitch.featuresLookup before we build \fluidPitchToBuf
                {
                  SynthDef(\busVersion, {
                    |out = 0, carrier = 1,modulator=0 fftsize=2048 hop=0.5 dry=0  window| //carrier is a bufnum
                    var in, in2, chain, carrierChain, chain3, cepsch, cepsch2;
                    var modulatorEnvelope=LocalBuf(fftsize); var carrierEnvelope=LocalBuf(fftsize);
                    In.ar(bus: modulator )
                    => FFT(LocalBuf(fftsize), _,hop,window)
                    => Cepstrum(LocalBuf(fftsize/2), _)
                    => PV_BrickWall(_, -0.92)
                    => ICepstrum(_, modulatorEnvelope);
                    // get cepstrum of carrier signal
                    carrierChain = 
                    In.ar(carrier)
                    => FFT(LocalBuf(fftsize), _,hop,window);
                    cepsch2 = 
                    Cepstrum(LocalBuf(fftsize/2), carrierChain)
                    => PV_BrickWall(_, \smoothCarrier.kr(-0.92))
                    => ICepstrum(_, LocalBuf(fftsize));
                    // 3. divide spectrum of each carrier frame by smooth spectral envelope (to flatten)
                    // 4. multiply flattened spectral carrier frame with smooth spectral envelope of modulator
                    carrierChain = 
                    PV_MagDiv(carrierChain,cepsch2)
                    => PV_MagMul(_, modulatorEnvelope)
                    => PV_BrickWall(_,0.02);//remove ultra low hopefully
                    Out.ar( out
                      , 
                      Pan2.ar(
                        dry * In.ar( carrier ) 
                        + ( (dry-1) * IFFT(carrierChain,window) ) 
                        * \amp.kr(0.1)
                        ,
                        \pan.kr(0)
                      ) 
                    );
                  }).add;
                  SynthDef(\bufferVersion, {
                    |out = 0, carrier = 1,modulator=0 fftsize=2048 hop=0.5 dry=0 rate=1  window| //carrier is a bufnum
                    var in, in2, chain, carrierChain, chain3, cepsch, cepsch2;
                    var modulatorEnvelope=LocalBuf(fftsize); var carrierEnvelope=LocalBuf(fftsize);
                    //  In.ar(bus: modulator )
                    PV_PlayBuf(LocalBuf(fftsize),modulator,rate)
                    //  => FFT(LocalBuf(fftsize), _,hop,1)
                    => Cepstrum(LocalBuf(fftsize/2), _)
                    => PV_BrickWall(_, -0.92)
                    => ICepstrum(_, modulatorEnvelope);
                    // get cepstrum of carrier signal
                    carrierChain = 
                    In.ar(carrier)
                    => FFT(LocalBuf(fftsize), _,hop,window);
                    cepsch2 = 
                    Cepstrum(LocalBuf(fftsize/2), carrierChain)
                    => PV_BrickWall(_, \smoothCarrier.kr(-0.92))
                    => ICepstrum(_, LocalBuf(fftsize));
                    // 3. divide spectrum of each carrier frame by smooth spectral envelope (to flatten)
                    // 4. multiply flattened spectral carrier frame with smooth spectral envelope of modulator
                    carrierChain = PV_MagDiv(carrierChain,cepsch2)
                    => PV_MagMul(_, modulatorEnvelope)
                    => PV_BrickWall(_,0.02);//remove ultra low hopefully
                    Out.ar( out
                      , 
                      Pan2.ar(
                        dry * In.ar( carrier ) 
                        + ( (dry-1) * IFFT(carrierChain,window) ) 
                        * \amp.kr(0.1)
                        ,
                        \pan.kr(0)) );

                      }).add;
                  // Formant-preserving pitch correction.
                  // Plays `voice` (a vocal buffer) and re-tunes it using a
                  // FluidBufPitch curve in `pitchBuf` (2 chan: [pitch(MIDI), confidence],
                  // analysed at `analysisHop` samples, unit:1). Same cepstral envelope
                  // as the vocoders above, with a PV_BinShift inserted between the
                  // MagDiv (flatten) and MagMul (re-impose formants) so pitch moves
                  // while formants stay put. analysisHop MUST match the FluidBufPitch hopSize.
                  SynthDef(\autotuneVersion, {
                    |out=0, voice=0, pitchBuf, fftsize=2048, hop=0.5, analysisHop=256,
                     window=0, corrAmt=1, snap=1, confThresh=0.7, glide=0.02,
                     rate=1, loop=0, dry=0|
                    var sig, pos, frame, note, conf, target, voiced, ratio, chain, wet;
                    var env=LocalBuf(fftsize);
                    // play the voice buffer, exposing sample position for curve sync
                    pos = Phasor.ar(0, rate * BufRateScale.kr(voice), 0, BufFrames.kr(voice));
                    sig = BufRd.ar(1, voice, pos, 0, 4);
                    // read the FluidBufPitch curve at the matching analysis frame
                    frame = A2K.kr(pos) / analysisHop;
                    #note, conf = BufRd.kr(2, pitchBuf, frame, 0, 2);
                    note = Lag.kr(note, glide);
                    target = note.round(snap);                 // snap=1 -> chromatic
                    voiced = (conf > confThresh) * (note > 0); // note>0 rejects -999 unvoiced flag
                    ratio = ((target - note) * corrAmt * voiced).midiratio;
                    // cepstral envelope = formants (your method)
                    chain = FFT(LocalBuf(fftsize), sig, hop, window);
                    Cepstrum(LocalBuf(fftsize/2), chain)
                    => PV_BrickWall(_, -0.92)
                    => ICepstrum(_, env);
                    // flatten -> transpose flat source -> re-impose ORIGINAL envelope
                    chain = PV_MagDiv(chain, env)
                    => PV_BinShift(_, ratio, 0, 1)   // interp=1: smooth the bin shift (matches \autotuneNotes)
                    => PV_MagMul(_, env)
                    => PV_BrickWall(_, 0.02);
                    wet = IFFT(chain, window);
                    // free at end of buffer unless looping (Phasor wrap => pos drops)
                    FreeSelf.kr(A2K.kr(pos < Delay1.ar(pos)) * (1 - loop));
                    Out.ar(out, Pan2.ar(
                      XFade2.ar(wet, sig, (dry * 2) - 1),      // dry=0 -> wet, dry=1 -> original
                      \pan.kr(0)) * \amp.kr(0.5));
                  }).add;
                  // Realtime pitch tracker -> curve buffer. Uses FluidPitch.kr (realtime
                  // UGen ABI is stable in 3.14-dev; FluidBufPitch's NRT path crashes there).
                  // Plays `voice` at rate 1 and writes [pitch(MIDI), confidence] into `curve`
                  // at `hop` spacing -> exactly the pitchBuf shape \autotuneVersion expects.
                  SynthDef(\fluidPitchToBuf, {
                    |voice=0, curve, hop=256, minFreq=60, maxFreq=1200, windowSize=1024|
                    var pos, sig, note, conf, frame;
                    pos = Phasor.ar(0, BufRateScale.kr(voice), 0, BufFrames.kr(voice));
                    sig = BufRd.ar(1, voice, pos, 0, 2);
                    #note, conf = FluidPitch.kr(sig, algorithm: 2,
                      minFreq: minFreq, maxFreq: maxFreq, unit: 1,
                      windowSize: windowSize, hopSize: hop);
                    frame = A2K.kr(pos) / hop;
                    BufWr.kr([note, conf], curve, frame);
                    FreeSelf.kr(A2K.kr(pos < Delay1.ar(pos))); // free at buffer end (Phasor wrap)
                  }).add;
                  // Note-aware autotune. Reads a 4-channel tuned curve from *tuneCurve:
                  // [measured, measuredCenter, targetCenter, confidence]. Corrects the NOTE
                  // CENTER (constant shift per note => no intra-note jumping) while preserving
                  // (modAmt=1) or scaling/removing (modAmt<1, 0=flat) the vibrato around it.
                  // glide smooths note-to-note transitions. Same cepstral formant engine.
                  SynthDef(\autotuneNotes, {
                    |out=0, voice=0, curve, fftsize=2048, hop=0.25, analysisHop=64, window=1,
                     corrAmt=1, modAmt=1, confThresh=0.5, glide=0.03, liftK=0.5, taper=1.3, rate=1, loop=0, dry=0, startPos=0, playDur=0|
                    var sig, pos, frame, measured, mcenter, tcenter, conf, voiced;
                    var desired, shift, ratio, chain, wet, f0, nb, cb, wipe1, wipe2, e1, e2;
                    var env=LocalBuf(fftsize), env2=LocalBuf(fftsize);
                    pos = Phasor.ar(0, rate * BufRateScale.kr(voice),
                      startPos * BufSampleRate.kr(voice),   // window start (0 = whole buffer)
                      Select.kr(playDur > 0, [BufFrames.kr(voice), (startPos + playDur) * BufSampleRate.kr(voice)]));
                    sig = BufRd.ar(1, voice, pos, 0, 4);
                    frame = A2K.kr(pos) / analysisHop;
                    #measured, mcenter, tcenter, conf = BufRd.kr(4, curve, frame, 0, 2);
                    // gate on note presence (tcenter, constant per note), NOT per-frame conf:
                    // a confidence gate flickers at the control rate and zippers the ratio by an
                    // amount that grows with the transposition -> 750 Hz buzz on far-shifted notes.
                    voiced = (tcenter > 0);
                    // target center + (scaled) vibrato around the measured center
                    desired = tcenter + ((measured - mcenter) * modAmt);
                    shift = (desired - measured) * corrAmt * voiced;  // semitones
                    ratio = Lag.kr(shift, glide).midiratio;           // const per note; glides at edges
                    // pitch-adaptive tapered lifter: cut the cepstrum just below the pitch
                    // period so the envelope keeps formants but excludes the harmonic comb.
                    // Lower f0 -> comb peak at higher quefrency -> keep more detail. Two walls
                    // (cutoff and cutoff*taper) blended via PV_Add give a soft taper instead of
                    // a hard brick; both envelopes are zero-phase so magnitudes add cleanly.
                    // taper=1 => single adaptive wall. liftK scales the cutoff (ear-tune).
                    f0 = (mcenter.max(40)).midicps;
                    nb = fftsize / 2;
                    cb = liftK * SampleRate.ir / f0;             // cepstral cutoff bin (quefrency)
                    wipe1 = (1 - (cb / nb)).neg.clip(-0.98, -0.05);
                    wipe2 = (1 - ((cb * taper) / nb)).neg.clip(-0.98, -0.05);
                    chain = FFT(LocalBuf(fftsize), sig, hop, window);
                    e1 = ICepstrum(PV_BrickWall(Cepstrum(LocalBuf(fftsize/2), chain), wipe1), env);
                    e2 = ICepstrum(PV_BrickWall(Cepstrum(LocalBuf(fftsize/2), chain), wipe2), env2);
                    PV_Add(e1, e2);                              // blend -> env (e1's buffer)
                    chain = PV_MagDiv(chain, env)
                    => PV_BinShift(_, ratio, 0, 1)   // interp=1: smooth the bin shift
                    => PV_MagMul(_, env);
                    // (dropped PV_BrickWall(_,0.02): it was a ~480 Hz highpass = 2% of Nyquist,
                    // gutting the low end. LeakDC removes only DC; add HPF(80) if sub-rumble.)
                    wet = LeakDC.ar(IFFT(chain, window));
                    FreeSelf.kr(A2K.kr(pos < Delay1.ar(pos)) * (1 - loop));
                    Out.ar(out, Pan2.ar(
                      XFade2.ar(wet, sig, (dry * 2) - 1),
                      \pan.kr(0)) * \amp.kr(0.5));
                  }).add;
                  // True-envelope variant: iterate  Vi = lifter( max(|X|, V{i-1}) )  so the
                  // envelope traces the spectral PEAKS instead of riding through the harmonic
                  // comb -> cleaner formant/pitch separation (esp. high notes). teN = iteration
                  // count (build-time; recompile to change). Single wall (no taper blend).
                  SynthDef(\autotuneNotesTrue, {
                    |out=0, voice=0, curve, fftsize=2048, hop=0.25, analysisHop=64, window=1,
                     corrAmt=1, modAmt=1, glide=0.03, liftK=0.5, rate=1, loop=0, dry=0, startPos=0, playDur=0|
                    var sig, pos, frame, measured, mcenter, tcenter, conf, voiced;
                    var desired, shift, ratio, chain, wet, f0, nb, cb, wipe;
                    var env = LocalBuf(fftsize);   // current envelope kept as a BUFFER (see below)
                    var teN = 4;   // true-envelope iterations
                    pos = Phasor.ar(0, rate * BufRateScale.kr(voice),
                      startPos * BufSampleRate.kr(voice),
                      Select.kr(playDur > 0, [BufFrames.kr(voice), (startPos + playDur) * BufSampleRate.kr(voice)]));
                    sig = BufRd.ar(1, voice, pos, 0, 4);
                    frame = A2K.kr(pos) / analysisHop;
                    #measured, mcenter, tcenter, conf = BufRd.kr(4, curve, frame, 0, 2);
                    voiced = (tcenter > 0);
                    desired = tcenter + ((measured - mcenter) * modAmt);
                    shift = (desired - measured) * corrAmt * voiced;
                    ratio = Lag.kr(shift, glide).midiratio;
                    f0 = (mcenter.max(40)).midicps;
                    nb = fftsize / 2;
                    cb = liftK * SampleRate.ir / f0;
                    wipe = (1 - (cb / nb)).neg.clip(-0.98, -0.05);
                    chain = FFT(LocalBuf(fftsize), sig, hop, window);
                    // V0 = lifter(|X|) -> env buffer
                    ICepstrum(PV_BrickWall(Cepstrum(LocalBuf(fftsize/2), chain), wipe), env);
                    // Vi = lifter( max(|X|, V{i-1}) ). env stays a BUFFER: reusing a cepstral
                    // CHAIN across PV ops trips SC's auto-copy fftSize resolver on the cep buffer.
                    (teN - 1).do {
                      var ai = PV_Copy(chain, LocalBuf(fftsize));   // mutable copy of |X|
                      var nextEnv = LocalBuf(fftsize);
                      ai = PV_Max(ai, env);                         // fill valleys up to current env
                      ICepstrum(PV_BrickWall(Cepstrum(LocalBuf(fftsize/2), ai), wipe), nextEnv);
                      env = nextEnv;
                    };
                    chain = PV_MagDiv(chain, env)
                    => PV_BinShift(_, ratio, 0, 1)
                    => PV_MagMul(_, env);
                    wet = LeakDC.ar(IFFT(chain, window));
                    FreeSelf.kr(A2K.kr(pos < Delay1.ar(pos)) * (1 - loop));
                    Out.ar(out, Pan2.ar(
                      XFade2.ar(wet, sig, (dry * 2) - 1),
                      \pan.kr(0)) * \amp.kr(0.5));
                  }).add;
                  // RubberBand engine. Same note-aware tuned-curve tracking as \autotuneNotes
                  // (4-chan curve: [measured, measuredCenter, targetCenter, confidence]), but the
                  // transposition + formant correction are handled by RubberBand.ar (phase-locked,
                  // transient-preserving PV with native formant preservation) instead of the
                  // cepstral/PV_BinShift chain. No FFT, no lifter. engine=1 -> R3 "Finer".
                  // NB: RubberBand drives its OWN buffer playback; the Phasor below exists only to
                  // index the pitch curve in sync. RubberBand primes/skips a start-delay, so its
                  // output lags the curve by ~that latency -- correcting slowly-varying note CENTERS
                  // (not per-frame) tolerates it; compensate the offset by ear later. dry-mix combs
                  // until that offset is corrected (wet is delayed vs the dry BufRd).
                  SynthDef(\autotuneRB, {
                    |out=0, voice=0, curve, analysisHop=64, corrAmt=1, modAmt=1, confThresh=0.5,
                     glide=0.03, rate=1, loop=0, dry=0, formant=1, transients=0, detector=0,
                     phase=0, engine=1, look=0, dryLatency=0, startPos=0, playDur=0|
                    var pos, frame, measured, mcenter, tcenter, conf, voiced;
                    var desired, shift, ratio, wet, dryS;
                    // parallel position -> curve frame (audio playback is RubberBand's own).
                    // `look` (samples) offsets the curve read to compensate any RB input
                    // lookahead so the ratio is ready for the content RB is about to process.
                    pos = Phasor.ar(0, rate * BufRateScale.kr(voice),
                      startPos * BufSampleRate.kr(voice),
                      Select.kr(playDur > 0, [BufFrames.kr(voice), (startPos + playDur) * BufSampleRate.kr(voice)]));
                    frame = A2K.kr(pos + look) / analysisHop;
                    #measured, mcenter, tcenter, conf = BufRd.kr(4, curve, frame, 0, 2);
                    voiced = (tcenter > 0);                               // note-presence gate
                    desired = tcenter + ((measured - mcenter) * modAmt);  // center + scaled vibrato
                    shift = (desired - measured) * corrAmt * voiced;      // semitones
                    ratio = Lag.kr(shift, glide).midiratio;               // scale factor, glided
                    wet = RubberBand.ar(1, voice, rate: rate, pitchShift: ratio, trig: 1,
                      startPos: startPos * BufSampleRate.kr(voice), loop: loop,
                      doneAction: (1 - loop) * 2,   // full-buffer free (latency-aware)
                      formant: formant, transients: transients, detector: detector,
                      phase: phase, engine: engine);
                    // windowed playback (fromNote): stop at the window end. Full play (playDur=0)
                    // leaves this disabled and relies on RubberBand's own doneAction.
                    FreeSelf.kr(A2K.kr(pos < Delay1.ar(pos)) * (1 - loop) * (playDur > 0));
                    // delay the dry by RB's output latency so the dry/wet crossfade aligns
                    dryS = DelayN.ar(BufRd.ar(1, voice, pos, 0, 4), 1.0, dryLatency);
                    Out.ar(out, Pan2.ar(
                      XFade2.ar(wet, dryS, (dry * 2) - 1),
                      \pan.kr(0)) * \amp.kr(0.5));
                  }).add;
                  // single-note audition: clicking a note in .gui calls .playNote -> this.
                  // Plays the original buffer segment from `start` (s) for `dur` (s), self-freeing.
                  SynthDef(\retunePreview, {
                    |out=0, voice=0, start=0, dur=0.3, amp=0.6|
                    var sig = PlayBuf.ar(1, voice, BufRateScale.kr(voice), 1,
                      start * BufSampleRate.kr(voice), 0);
                    var env = EnvGen.kr(Env.linen(0.005, dur, 0.03), doneAction: 2);
                    Out.ar(out, Pan2.ar(sig * env, \pan.kr(0)) * amp);
                  }).add;
                    }.value
                  }
	// Analyse `path` with FluidPitch in real time, writing a [pitch(MIDI), confidence]
	// curve buffer at `hop` spacing. Calls onDone.(voiceBuffer, curveBuffer) when finished;
	// feed both straight into \autotuneVersion as \voice and \pitchBuf (with \analysisHop = hop).
	*trackPitch { |path, hop=256, minFreq=60, maxFreq=1200, onDone|
		var p, sf, numFrames, sr, voice, curve;
		p = path.standardizePath;
		// read the header language-side so we can size `curve` before any async work
		sf = SoundFile.openRead(p);
		sf.isNil.if { ("VocoderPattern.trackPitch: cannot open " ++ p).warn; ^nil };
		numFrames = sf.numFrames; sr = sf.sampleRate; sf.close;
		// allocate both buffers now; the Buffer objects are valid immediately,
		// the server fills voice (read) and curve (the tracking pass) asynchronously
		voice = Buffer.read(server, p);
		curve = Buffer.alloc(server, (numFrames / hop).ceil.asInteger + 2, 2);
		fork {
			server.sync; // wait for read + alloc to land on the server
			Synth(\fluidPitchToBuf, [\voice, voice, \curve, curve,
				\hop, hop, \minFreq, minFreq, \maxFreq, maxFreq]);
			((numFrames / sr) + 0.3).wait; // realtime pass: waits the file's duration
			("VocoderPattern.trackPitch: " ++ curve.numFrames ++ " frames @ hop " ++ hop).postln;
			onDone.value(voice, curve);
		};
		^(voice: voice, curve: curve, analysisHop: hop)
	}
	// Offline (NRT) sibling of trackPitch: renders far faster than realtime in a separate
	// scsynth, leaving the live server untouched. Uses FluidPitch.kr (realtime UGen -> works
	// in 3.14-dev) recorded at control rate via the OfflineProcess quark. Returns
	// (voice:, curve:, analysisHop:) immediately; curve fills when the render finishes,
	// signalled by onDone.(voice, curve). Curve spacing is the NRT blockSize (64), so the
	// returned analysisHop is 64 (feed it to \autotuneVersion); `hop` here is only
	// FluidPitch's internal analysis hop.
	*trackPitchOffline { |path, hop=256, minFreq=60, maxFreq=1200, windowSize=2048, algorithm=2, onDone|
		var p, sf, numFrames, blockSize=64, nCtrl, voice, curve, proc, run, fftSize;
		p = path.standardizePath;
		sf = SoundFile.openRead(p);
		sf.isNil.if { ("VocoderPattern.trackPitchOffline: cannot open " ++ p).warn; ^nil };
		numFrames = sf.numFrames; sf.close;
		nCtrl = (numFrames / blockSize).ceil.asInteger + 2;
		fftSize = windowSize.nextPowerOfTwo.max(1024);   // fftSize must be >= windowSize
		voice = Buffer.read(server, p);
		curve = Buffer.alloc(server, nCtrl, 2);
		proc = OfflineProcess();
		// single 2-channel kr pass -> [pitch(MIDI), confidence]; input.asArray.first = mono in.
		// windowSize 2048 (~43ms) gives YinFFT enough low-pitch periods to stay confident on
		// notes near minFreq; 1024 starves low notes and they read as unvoiced.
		proc.putKr(\pitch, { |input|
			FluidPitch.kr(input.asArray.first, algorithm: algorithm,
				minFreq: minFreq, maxFreq: maxFreq, unit: 1,
				windowSize: windowSize, hopSize: hop, fftSize: fftSize);
		});
		run = proc.process(p); // kicks off NRT render in a separate scsynth
		fork {
			run.wait; // resolves when the offline render completes
			curve.read(run.resultFile(\pitch), action: { |b|
				("VocoderPattern.trackPitchOffline: " ++ b.numFrames ++ " frames @ hop " ++ blockSize).postln;
				onDone.value(voice, b);
			});
		};
		^(voice: voice, curve: curve, analysisHop: blockSize)
	}

	// ---- note segmentation + center-correction (Melodyne-lite) ----
	// Takes the event from trackPitch / trackPitchOffline (after its onDone has fired, so the
	// curve is filled) and builds a 4-channel tuned curve for \autotuneNotes. The measured
	// pitch is median-filtered, split into note segments, each note's robust center (median)
	// is quantized to `scale` (array of pitch classes; nil/empty = chromatic). Calls
	// onDone.(event) with (voice:, curve:, analysisHop:, segments:).
	*tuneCurve { |inEvent, scale, root=0, confThresh=0.7, minNoteMs=80, jumpThresh=0.7, medianMs=60, coarseMs=200, onDone|
		var curve = inEvent[\curve];
		var aHop = inEvent[\analysisHop] ? 64;
		var sr = (server.sampleRate ? 48000);
		curve.loadToFloatArray(action: { |raw|
			var nframes = raw.size div: 2;
			var pitch, conf, voiced, folded, smoothed, segs, mcenter, tcenter, interleaved, a, b;
			var medWin = ((medianMs / 1000 * sr / aHop).round.asInteger).max(1);
			var minFrames = ((minNoteMs / 1000 * sr / aHop).round.asInteger).max(1);
			pitch = Array.newClear(nframes);
			conf  = Array.newClear(nframes);
			nframes.do { |i| pitch[i] = raw[2*i]; conf[i] = raw[(2*i)+1] };
			voiced = nframes.collect { |i| (conf[i] > confThresh) and: { pitch[i] > 0 } };
			// fold octave errors toward a coarse running median (median is robust to the
			// brief octave jumps themselves), then median-smooth for vibrato/jitter
			folded = VocoderPattern.prOctaveFold(pitch, voiced,
				((coarseMs / 1000 * sr / aHop).round.asInteger).max(1));
			smoothed = VocoderPattern.prMedianFilter(folded, voiced, medWin);
			segs = VocoderPattern.prSegment(smoothed, voiced, minFrames, jumpThresh);
			// enforce minimum note length: drop phantom blips (octave glitches, transients)
			segs = segs.select { |seg| (seg[1] - seg[0] + 1) >= minFrames };
			mcenter = Array.fill(nframes, 0);
			tcenter = Array.fill(nframes, 0);
			segs.do { |seg|
				var lo = seg[0], hi = seg[1], vals, center, target;
				vals = (lo..hi).select { |i| voiced[i] }.collect { |i| smoothed[i] };
				center = vals.isEmpty.if({ 0 }, { VocoderPattern.prMedian(vals) });
				target = VocoderPattern.prQuantize(center, scale, root);
				(lo..hi).do { |i| mcenter[i] = center; tcenter[i] = target };
			};
			// merge: one constant center per maximal run of equal target, so the offset
			// stays constant across a whole sung note (kills warble from over-segmentation)
			a = 0;
			while({ a < nframes }, {
				var t = tcenter[a], vals2, c;
				b = a;
				while({ (b < nframes) and: { tcenter[b] == t } }, { b = b + 1 });
				(t != 0).if {
					vals2 = (a..(b-1)).select { |k| voiced[k] }.collect { |k| smoothed[k] };
					vals2.isEmpty.not.if {
						c = VocoderPattern.prMedian(vals2);
						(a..(b-1)).do { |k| mcenter[k] = c };
					};
				};
				a = b;
			});
			// channel 0 = median-smoothed pitch (clean vibrato; raw jitter stays out of
			// the modulation term used when modAmt < 1)
			interleaved = nframes.collect { |i|
				[smoothed[i], mcenter[i], tcenter[i], conf[i]]
			}.flatten;
			Buffer.loadCollection(server, interleaved, 4, { |b|
				("VocoderPattern.tuneCurve: " ++ segs.size ++ " notes / " ++ nframes ++ " frames").postln;
				onDone.value((voice: inEvent[\voice], curve: b, analysisHop: aHop, segments: segs));
			});
		});
	}

	// fold each voiced pitch by octaves to within 6 semitones of a coarse running median,
	// correcting octave-jump detection errors without disturbing the true melody
	*prOctaveFold { |arr, voiced, win|
		var coarse = VocoderPattern.prMedianFilter(arr, voiced, win);
		^arr.size.collect { |i|
			var p = arr[i];
			voiced[i].if({
				while({ (p - coarse[i]) > 6 }, { p = p - 12 });
				while({ (p - coarse[i]) < -6 }, { p = p + 12 });
				p
			}, { p });
		};
	}

	*prMedian { |arr|
		var s = arr.copy.sort, n = arr.size;
		(n == 0).if { ^0 };
		^((n % 2) == 1).if({ s[n div: 2] }, { (s[(n div: 2) - 1] + s[n div: 2]) / 2 });
	}

	*prMedianFilter { |arr, voiced, win|
		var n = arr.size, half = win div: 2;
		^n.collect { |i|
			var lo = (i - half).max(0), hi = (i + half).min(n - 1), w;
			w = (lo..hi).select { |j| voiced[j] }.collect { |j| arr[j] };
			w.isEmpty.if({ arr[i] }, { VocoderPattern.prMedian(w) });
		};
	}

	// Returns a List of [startFrame, endFrame] note segments. A new note starts when a
	// voiced frame deviates from the running note center by > jumpThresh (once the current
	// note has lasted minFrames); unvoiced gaps longer than minFrames close a note.
	*prSegment { |pitch, voiced, minFrames, jumpThresh|
		var segs = List.new, n = pitch.size;
		var inNote = false, start = 0, center = 0, count = 0, gap = 0;
		n.do { |i|
			voiced[i].if({
				inNote.if({
					((pitch[i] - center).abs > jumpThresh and: { count >= minFrames }).if({
						segs.add([start, i - 1]);
						start = i; center = pitch[i]; count = 1; gap = 0;
					}, {
						center = center + ((pitch[i] - center) / (count + 1));
						count = count + 1; gap = 0;
					});
				}, {
					inNote = true; start = i; center = pitch[i]; count = 1; gap = 0;
				});
			}, {
				inNote.if({
					gap = gap + 1;
					(gap > minFrames).if({ segs.add([start, i - gap]); inNote = false });
				});
			});
		};
		inNote.if { segs.add([start, n - 1]) };
		^segs;
	}

	*prQuantize { |midi, scale, root=0|
		var allowed;
		(scale.isNil or: { scale.isEmpty }).if { ^midi.round(1) };
		allowed = (0..127).select { |m| scale.includes((m - root) % 12) };
		^allowed.minItem { |m| (m - midi).abs };
	}

	// Fft arguments are set by the item when you use warp
	*new {
		|pattern key effect inputEffect fftSize=2048 hop=0.5 window warp=0 out amp=0.1 pan=( -1 ) loop=0 rate=1 durs dry=0|
		^super.newCopyArgs(pattern,key,effect,inputEffect,fftSize,hop,window,warp,out,amp,pan,loop,rate,durs,dry)
		.init;
	}
	init { 
//		|pattern key effect inputEffect fftSize hop window warp out amp pan durs|

		modulator=Bus.audio(server,1);
		carrier=Bus.audio(server,2);
		verb=Bus.audio(server,2);
		// Should I add these buffers ceterato the infrastructure
		item = Item(key);
		fork{1.wait;\fftSize.postln;fftSize.postln;item.getFFT(fftSize,hop,window)};
		effect.isNil.if{
			synthOut = out
		} {
			synthOut = verb.index
		};
	}
	play {
		warp.isNil.if{
			this.playClean
		}{
			item.armed.not.if{
				this.playWarp
			}{
				this.playClean
			}
			
		}
	}
	playClean { 
		var bypass=0;
		pattern <> (out:carrier.index) => _.play;
		item.armed.if{ 
			bypass=1 ;
			item.play;
			\recording.postln
		} {
			( bypass==0 ).if {
					\playing.postln;
					server.bind{
						{
							item.playbuf(loop:loop,rate:rate) 
							=> ( inputEffect ? {|i|i} )
						}.play(server ,modulator.index);
					}
					
				
			}{
				{SoundIn.ar()}.play(server,modulator.index) ;
			};
			effect.isNil.if{
				synthOut = out
			} {
				synthOut = verb.index
			};
//			server.sync;
			synth = Synth.new(\busVersion, [
				\window,window,
				\carrier,carrier.index,
				\modulator,modulator.index,
				\hop,0.25,
				\out,synthOut,
				\smoothCarrier,-0.92,
				\pan,pan,
				\amp,amp,
				\dry,dry
			]);
		NodeWatcher.register(synth, assumePlaying: true);
		};

		fork{
			while ( {synth.isPlaying},{1.wait} );
			\freeing_Bus.postln;
//			carrier.free; modulator.free;
		};
		(effect.isNil.not).if{
			effect={ In.ar(verb.index,2) => effect } =>_.play(server,out,addAction:\addToTail);
		};

	}
	playWarp { 
		var bypass=0, bus=Bus.control;
		\durs++" "++durs=>_.postln;
		effect.isNil.if{
			synthOut = out
		} {
			synthOut = verb.index
		};
		fork{
			//??
			server.sync;
			pattern <> (out:carrier.index) => _.play;
			server.bind{
				synth = Synth.new(\bufferVersion, [
					\window,window,
					\carrier,carrier.index,
					\modulator,item.pvBuffer.bufnum,
					\rate,rate,
					\fftsize,fftSize,
					\window,window,
					\hop,hop,
					\out,synthOut,
					\smoothCarrier,-0.92,
					\pan,pan,
					\amp,amp,
					\dry,dry
				]) 
			};
			durs.isNil.not.if {
				var rateEnvelope=item.stamp(durs);
				{rateEnvelope.kr}.play(server,bus);
				synth.map(\rate,bus);
			};
		NodeWatcher.register(synth, assumePlaying: true);
		fork{
			while ( {synth.isPlaying},{1.wait} );
			\freeing_Bus.postln;
//			carrier.free; modulator.free;
		};
		};
		(effect.isNil.not).if{
			effect={ In.ar(verb.index,2) => effect } =>_.play(server,out,addAction:\addToTail);
		};
	}
	arm {|bus| item.armSection(bus:bus) }
}
