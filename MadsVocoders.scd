b = Buffer.read(s, Platform.systemAppSupportDir +/+ "sounds" +/+ "a11wlk01.wav");


(
[8, 16, 32].do{|numbands|
    var defname = "vocoder%bands".format(numbands).asSymbol.postln;

    SynthDef(defname, {|out=0|
        // Input signal. Should be replaced with Input.ar 
        var sig = PlayBuf.ar(numChannels:1, bufnum:b, rate:BufRateScale.kr(b), trigger:1.0, startPos:0.0, loop:1.0, doneAction:0);

        var inputSig = SawDPW.ar(\freq.ar(100));
        var bandrq = \rq.kr(0.05);

        sig = Array.fill(numbands, {|bandNum|
            var bandfreq = bandNum.linexp(0,numbands-1, \minFreq.ir(100), \maxFreq.ir(8000));
            var filtered = BPF.ar(in:sig, freq:bandfreq, rq:bandrq, mul:1.0, add:0.0);

            var osc = BPF.ar(inputSig, bandfreq, bandrq);
            var thisGain = "bandGain%".format(bandNum+1).asSymbol.kr(1);
            var atk = "bandAttack%".format(bandNum+1).asSymbol.kr(0.01);
            var rel = "bandRelease%".format(bandNum+1).asSymbol.kr(0.01);
            osc * thisGain * Amplitude.ar(in:filtered, attackTime:atk, releaseTime:rel) * bandrq.reciprocal
        });

        sig = sig.sum!2;

        Out.ar(out, sig * \amp.kr(1))
    }).add;

}
)

// Pretty straightforward
(
~synth = Synth(\vocoder16bands, [
    \rq, 0.05,
    \freq, 100,
]);
)

~synth.set(\freq, 550);
~synth.set(\freq, 50, \rq, 0.01);

(
~synth2 = Synth(\vocoder8bands, [
    \rq, 0.05,
    \freq, 250,
    \bandAttack1, 0.005, \bandAttack2, 0.001, \bandAttack3, 0.0005,
    \bandRelease1, 0.05, \bandRelease2, 0.01, \bandRelease3, 0.005,
    \bandGain1, 1, \bandGain2, 2, \bandGain3, 2, \bandgain4, 4,
]);
)

(
{
	var voicedCarrier;
	var snd, numBands, bandFreqs, carrier;
	numBands = 32;
	bandFreqs = (0..numBands - 1).linexp(0, numBands - 1, 100, 8000);
	snd = PlayBuf.ar(1, ~buffer, BufRateScale.kr(~buffer));
	voicedCarrier = Saw.ar((60 + [0, 3, 7]).midicps);
	carrier = SelectX.ar((ZeroCrossing.ar(snd).cpsmidi.lag(0.05) > 5000.cpsmidi).lag(0.05), [voicedCarrier, PinkNoise.ar]);
	snd = Amplitude.ar(BPF.ar(snd, bandFreqs, 0.05), 0.01, 0.05);
	snd = BPF.ar(carrier, bandFreqs, 0.05) * snd;
	snd = snd.sum;
	snd = snd * 30.dbamp;
	snd = Limiter.ar(snd);
	snd ! 2;
}.play;
)
