(
f = {|out=0 modulator=0 carrier=1 release=0.05 attack = 0.01|
	var numbands = 16;
	var sig = PlayBuf.ar(numChannels:1, bufnum:modulator, rate:BufRateScale.kr(modulator), trigger:1.0, startPos:0.0, loop:1.0, doneAction:0);

	var bandrq = \rq.kr(0.05);
	carrier = PlayBuf.ar(numChannels:1, bufnum:carrier, rate:BufRateScale.kr(modulator), trigger:1.0, startPos:0.0, loop:1.0, doneAction:0);
	carrier= SelectX.ar((ZeroCrossing.ar(sig).cpsmidi.lag(0.05) > 5000.cpsmidi).lag(0.05), [carrier, PinkNoise.ar]);

	sig = Array.fill(numbands, {|bandNum|
		var bandfreq = bandNum.linexp(0,numbands-1, \minFreq.ir(100), \maxFreq.ir(8000));
		var filtered = BPF.ar(in:sig, freq:bandfreq, rq:bandrq, mul:1.0, add:0.0);

		var osc = BPF.ar(carrier, bandfreq, bandrq);
		var thisGain = "bandGain%".format(bandNum+1).asSymbol.kr(1);
		var atk = "bandAttack%".format(bandNum+1).asSymbol.kr(0.01);
		var rel = "bandRelease%".format(bandNum+1).asSymbol.kr(0.05);
		osc * thisGain * Amplitude.ar(in:filtered, attackTime:atk, releaseTime:rel) * bandrq.reciprocal
	});
	sig = sig.sum;
	Out.ar(out, sig * \amp.kr(1))
}
)
