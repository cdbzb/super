SynthDef('cepstral-vocoder-bus', {
	|out = 0, carrier = 1,modulator=0 fftsize=2048 hop=0.5| //carrier is a bufnum
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

