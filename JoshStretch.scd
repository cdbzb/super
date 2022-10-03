(
s.options.memSize_(32768);
s.waitForBoot({
	var fftBuf1, fftBuf2, fftRecordBuf, liveInputBuf;
	var bufTime, iBufTime, fftSize, hop;
	var startTime;

	bufTime = 120.0; // in seconds
	iBufTime = bufTime.reciprocal; // handy for the time pointers
	fftSize = 4096; // must be power of 2... larger means more delay / offset
	hop = 0.25;
	liveInputBuf = Buffer.alloc(s, bufTime * s.sampleRate);
	fftRecordBuf = Buffer.alloc(s, bufTime.calcPVRecSize(fftSize, 0.25, s.sampleRate));
	s.sync;
	"Buffers loaded".postln;

	// for cleaning up
	CmdPeriod.doOnce({
		liveInputBuf.free;
		fftRecordBuf.free;
		"Buffers Freed".postln;
	});

	SynthDef(\recordInput, {arg inBus, recordBuffer, fftRecordBuffer, fftSize;
		var in, chain;
		in = Limiter.ar(In.ar(inBus, 1), -3.dbamp);
		chain = FFT(LocalBuf.new(fftSize), in, hop, 1);
		PV_RecordBuf(chain, fftRecordBuffer);
		RecordBuf.ar(in, recordBuffer);
	}).add;

	SynthDef(\stretch, {arg recordBuffer, fftRecordBuffer, fftSize, warpScale = 1.0,
		fftScale = 1.0, pan, startPoint, endPoint, duration, outBus;
		var warp, fftStretch, out, pointer, env, envGen, chain;
		pointer = Line.kr(startPoint, endPoint, duration);
		env = Env([0, 1, 1, 0], [0.1, 0.8, 0.1], \sin);
		envGen = EnvGen.kr(env, timeScale: duration, doneAction: 2);
		warp = Warp1.ar(1, recordBuffer, pointer, 1, 0.11, -1, 8, 0.1) * warpScale;
		fftStretch = 0.0;
		chain = PV_BufRd(LocalBuf.new(fftSize), fftRecordBuffer, pointer);
		fftStretch = IFFT.ar(chain) * fftScale;
		out = Pan2.ar((warp + fftStretch) * envGen, pan);
		Out.ar(outBus, out);
	}).add;


	// start recording... 1st input
	Synth(\recordInput, [\inBus, s.options.numOutputBusChannels,
		\recordBuffer, liveInputBuf,
		\fftRecordBuffer, fftRecordBuf,
		\fftSize, fftSize
	]);
	Task({
		var winSize = 12.0, overlaps = 4, stretch = 0.1; // stretch < 1 is stretched out
		var outBus = 0;
		s.sync;
		startTime = Main.elapsedTime;

		inf.do({arg i;
			var waitTime, now, noteOffset, start, end, pan;
			"New note".postln;
			now = Main.elapsedTime - startTime; // how long has this been playing?
			noteOffset = 0.1; // start our stretch a little before now to avoid glitches
			start = now - noteOffset;
			end = start + (winSize * stretch); // we want our pointer calculations done here
			start = start * iBufTime; // find where in the buffer to point to
			end = end * iBufTime; // find where in the buffer to point to
			pan = 1.0.rand2; // random pan for funsies
			Synth(\stretch, [
				\recordBuffer, liveInputBuf,
				\fftRecordBuffer, fftRecordBuf,
				\fftSize, fftSize,
				\warpScale, -6.dbamp, // futz with these numbers to find a good balance for your input
				\fftScale, -3.dbamp,
				\pan, pan,
				\startPoint, start,
				\endPoint, end,
				\duration, winSize,
				\outBus, outBus]);
			waitTime = winSize / overlaps;
			waitTime.wait;
		})
	}).play;
})
)
