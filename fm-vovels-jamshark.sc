(
s.waitForBoot {
	var cond = CondVar.new;
	var k = "IEAOU".collectAs({ |chr| ("alto" ++ chr).asSymbol }, Array);
	var formantBuf;
	var formantBus = Bus.control(s, 15);
	var freqBus = Bus.control(s, 1);
	
	// [[ 5freqs, 5bws, 5amps ], [ 5freqs, 5bws, 5amps ]]
	var formants = k.collect { |id| FormantTable.at(id) };
	
	// [[ 5freqs, 5freqs, 5freqs ... ], [ 5bws, 5bws, 5bws ... ] ...]
	formants = formants.flop;
	
	// [[ low formants for 5 vowels, 2nd formants for 5 vowels etc... ]]
	formants = formants.collect(_.flop);
	
	formantBuf = Buffer.sendCollection(s, formants.flat, 1, action: {
		cond.signalOne
	});
	
	~vowelSelector = SynthDef(\vowelSelector, { |out, bufnum, freqOut|
		var vowel = MouseY.kr(0, 3.999);
		var offset5 = Array.series(5, 0, 5);
		// using BufRd for automatic linear interpolation
		var freqs = BufRd.kr(1, bufnum, vowel + offset5, loop: 0);
		var bws = BufRd.kr(1, bufnum, vowel + (offset5 + 25), loop: 0);
		var amps = BufRd.kr(1, bufnum, vowel + (offset5 + 50), loop: 0);
		Out.kr(out, freqs ++ bws ++ amps);
		Out.kr(freqOut, MouseX.kr(50, 800, 1));
	}).play(args: [out: formantBus, freqOut: freqBus, bufnum: formantBuf]);
	
	~fm = SynthDef(\fmFormants, { |out, freq = 440, formantBus, index = 1.44, amp = 0.2|
		var freqs, bws, amps;
		var quotient, xfades, evenCar, oddCar, sig;

		// Chowning: fundamental frequency --> modulator
		var mod = SinOsc.ar(freq);
		
		#freqs, bws, amps = In.kr(formantBus, 15).clump(5);
		
		// smaller bw --> lower mod index --> fewer sidebands (narrower formant)
		mod = mod * index * bws;
		
		// freqs need to be rounded to integer ratios and crossfaded
		quotient = freqs / freq;
		xfades = quotient.fold(0, 1);
		// evenCar is for a formant frequency rounded to an even integer multiple
		evenCar = SinOsc.ar(quotient.round(2) * freq, mod);
		// oddCar is for a formant frequency rounded to an odd integer multiple
		oddCar = SinOsc.ar(((quotient + 1).round(2) - 1) * freq, mod);
		
		sig = XFade2.ar(evenCar, oddCar, xfades * 2 - 1, amps).sum * amp;
		
		// empirically, 2000-4000 Hz formants are too prominent
		sig = MidEQ.ar(sig, 3000, 1.9, -24);
		
		Out.ar(out, LeakDC.ar(sig).dup);
	}).play(args: [formantBus: formantBus, freq: freqBus.asMap]);
	
	// just for fun, chorus and reverb
	~fx = {
		var sig = In.ar(0, 2);
		sig = sig + DelayC.ar(sig, 0.2,
			Array.fill(2, {
				var predelay = Rand(0.005, 0.01);
				var width = Rand(0.7, 0.98);
				SinOsc.kr(ExpRand(0.1, 0.4), Rand(0.5, 3.0))
				* (width * predelay) + predelay
			})
		);
		ReplaceOut.ar(0, FreeVerb2.ar(sig[0], sig[1], 0.4, 0.8, 0.3))
	}.play(target: s.defaultGroup, addAction: \addToTail);
	
	~fm.onFree({
		[formantBus, freqBus, formantBuf].do(_.free);
	});
};
)t
