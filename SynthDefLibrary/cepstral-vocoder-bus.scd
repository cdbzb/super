(
SynthDef('cepstral-vocoder-bus', {
	|out = 0, carrier = 1,modulator=0 fftsize=2048 hop=0.5| 
	var in, in2, chain, carrierChain, chain3, cepsch, cepsch2;
	var modulatorEnvelope=LocalBuf(fftsize); var carrierEnvelope=LocalBuf(fftsize);
	In.ar(bus: modulator )
	=> FFT(LocalBuf(fftsize), _,hop,1)
	=> Cepstrum(LocalBuf(fftsize/2), _)
	=> PV_BrickWall(_, -0.92)
	=> ICepstrum(_, modulatorEnvelope);
	// get cepstrum of carrier signal
	carrierChain = 
	In.ar(carrier)
	=> FFT(LocalBuf(fftsize), _,hop,1);
	cepsch2 = 
	Cepstrum(LocalBuf(fftsize/2), carrierChain)
	=> PV_BrickWall(_, \smoothCarrier.kr(-0.92))
	=> ICepstrum(_, LocalBuf(fftsize));
	// 3. divide spectrum of each carrier frame by smooth spectral envelope (to flatten)
	// 4. multiply flattened spectral carrier frame with smooth spectral envelope of modulator
	carrierChain = PV_MagDiv(carrierChain,cepsch2)
	=> PV_MagMul(_, modulatorEnvelope);
	Out.ar( out, Pan2.ar(IFFT(carrierChain) *\amp.kr(0.5),\pan.kr(0)) );
}).add.tag(\vocoder);

SynthDef('cepstral-vocoder-buffer', {
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
	Out.ar( out , Pan2.ar(
		dry * In.ar( carrier ) + ( (dry-1) * IFFT(carrierChain,window) ) * \amp.kr(0.1) , \pan.kr(0)) );

	}).add;

	SynthDef(\soundInMorph, {
		|out = 0, modulator = 0, carrier = 1, dur = 10| // takes bus indices
		var in, in2, chain, chain2, chain3, cepsch, cepsch2, fftsize = 2048;
		var modulatorEnvelope=LocalBuf(fftsize); var carrierEnvelope=LocalBuf(fftsize);
		var modulatorCepstrum=LocalBuf(fftsize/2); var carrierCepstrum=LocalBuf(fftsize/2);
		fftsize = 2048;
		in = In.ar(modulator);
		chain = FFT(LocalBuf(fftsize), in);
		cepsch = Cepstrum(modulatorCepstrum, chain);
		in2 = In.ar(carrier);
		chain2 = FFT(LocalBuf(fftsize), in2);
		cepsch2 = Cepstrum(carrierCepstrum, chain2);
		cepsch = PV_BrickWall(cepsch, -0.92);
		ICepstrum(cepsch, modulatorEnvelope);
		cepsch2 = PV_BrickWall(cepsch2, \smoothCarrier.kr(-0.92));
		ICepstrum(cepsch2, carrierEnvelope);
		chain2 = PV_MagDiv(chain2,carrierEnvelope);
		chain2 = PV_MagMul(chain2, modulatorEnvelope);
		Out.ar( out, Pan2.ar(IFFT(chain2) *\amp.kr(0.5),\pan.kr(0)) );
		Line.kr(0,1,dur,doneAction:2)
	}).add;

	SynthDef(\soundInMorphNoise, {
		|out = 0, modulator = 0, carrier = 1, dur = 10| // takes bus indices
		var in, in2, chain, chain2, chain3, cepsch, cepsch2, fftsize = 2048;
		var modulatorEnvelope=LocalBuf(fftsize); var carrierEnvelope=LocalBuf(fftsize);
		var modulatorCepstrum=LocalBuf(fftsize/2); var carrierCepstrum=LocalBuf(fftsize/2);
		in = In.ar(modulator);
		chain = FFT(LocalBuf(fftsize), in);
		cepsch = Cepstrum(modulatorCepstrum, chain);
		in2 = In.ar(carrier);
		in2 = SelectX.ar(
			(ZeroCrossing.ar(in).lag(0.05) > 5000).lag(0.05), 
			[in2, PinkNoise.ar]
		);
		chain2 = FFT(LocalBuf(fftsize), in2);
		cepsch2 = Cepstrum(carrierCepstrum, chain2);
		cepsch = PV_BrickWall(cepsch, -0.92);
		ICepstrum(cepsch, modulatorEnvelope);
		cepsch2 = PV_BrickWall(cepsch2, \smoothCarrier.kr(-0.92));
		ICepstrum(cepsch2, carrierEnvelope);
		chain2 = PV_MagDiv(chain2,carrierEnvelope);
		chain2 = PV_MagMul(chain2, modulatorEnvelope);
		Out.ar( out, Pan2.ar(IFFT(chain2) *\amp.kr(0.5),\pan.kr(0)) );
		Line.kr(0,1,dur,doneAction:2)
	}).add;

[8, 16, 32].do{|numbands|
    var defname = "vocoder%bands".format(numbands).asSymbol.postln;
    var defname2;

    SynthDef(defname, {|out=0 modulator=0 carrier=1 release=0.05 attack = 0.01|
        // Input signal. Should be replaced with Input.ar 
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

        sig = sig.sum!2;

        Out.ar(out, sig * \amp.kr(1))
    }).add;

    defname2 = "vocoder%bands-bus".format(numbands).asSymbol.postln;

    SynthDef(defname2, {|out=0 modulator=0 carrier=1 release=0.05 attack = 0.01|
        // Input signal. Should be replaced with Input.ar 
        var sig = In.ar(modulator,1);
        var bandrq = \rq.kr(0.05);
        carrier = In.ar(carrier,1);
	carrier= SelectX.ar((ZeroCrossing.ar(sig).cpsmidi.lag(0.05) > 5000.cpsmidi).lag(0.05), [carrier, PinkNoise.ar(1)]);

        sig = Array.fill(numbands, {|bandNum|
            var bandfreq = bandNum.linexp(0,numbands-1, \minFreq.ir(100), \maxFreq.ir(8000));
            var filtered = BPF.ar(in:sig, freq:bandfreq, rq:bandrq, mul:1.0, add:0.0);

            var osc = BPF.ar(carrier, bandfreq, bandrq);
            var thisGain = "bandGain%".format(bandNum+1).asSymbol.kr(1);
            var atk = "bandAttack%".format(bandNum+1).asSymbol.kr(0.01);
            var rel = "bandRelease%".format(bandNum+1).asSymbol.kr(0.05);
            osc * thisGain * Amplitude.ar(in:filtered, attackTime:atk, releaseTime:rel) * bandrq.reciprocal
        });

        sig = sig.sum!2;

        Out.ar(out, sig * \amp.kr(1) *20)
    }).add;

}

//fixed!!

)
