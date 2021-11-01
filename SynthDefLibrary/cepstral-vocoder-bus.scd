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
	|out = 0, modulator = 0, carrier = 1| // takes bus indices
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
}).add;
