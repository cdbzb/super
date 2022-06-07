VocoderPattern {
//	var durs , <pattern, <item, effect, out, bypass, hop, fftSize, window=1;
	var pattern,key,effect,<inputEffect,fftSize,hop,window,<>warp,out,amp,pan,loop,rate,durs,>dry;
	var <modulator,verb,<carrier,<synthOut,<synth,<item;
	classvar <>server;
	*initClass {
		server = Server.default;
                Class.initClassTree(SynthDescLib);
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
                    }.value
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
