( 
	
	fork{
		var amplitudes = [0, 1, 1, -2, 1, 1, -2, 1, 0.5, 0.3, 0.2];
		var amplitudesAlt = [1, 1, 2, -1, 1, 1, 0, 1, 0.1, 0.0, 0.1];
		//var amplitudesBrite = [0,-1,1,0.1,0.2,0.3,0.4,0.5,0.6,0.7,1,0,1];
		var sigs = [
			Signal.chebyFill(256+1, amplitudes, normalize: true, zeroOffset: true),
			Signal.chebyFill(256+1, amplitudes, normalize: true, zeroOffset: false),
			Signal.chebyFill(256+1, amplitudesAlt, normalize: true, zeroOffset: false),
		//	Signal.chebyFill(256+1, amplitudesBrite, normalize: true,zeroOffset:false)

		];
		b = sigs.collect{ arg sig; Buffer.loadCollection(s, sig.asWavetableNoWrap) };
		c =  Buffer.loadCollection(s, sigs[2].asWavetableNoWrap) ;
		//d =  Buffer.loadCollection(s, sigs[3].asWavetableNoWrap) ;
		s.sync;
		x={
			{
				var in = SinOsc.ar([101,102.3, 100 ]
				//*([1,1,0.5].scramble)
				* (Scale.minor.ratios.choose)
				*([0.5,1,2,4].choose)
				, 0,Env.perc(1.0.rand,rrand(1,4)).kr(gate:1));
				LeakDC.ar(Shaper.ar([c, b[1] ].choose, in*(1+PinkNoise.ar(0.01))))
				=> FreeVerb.ar(_,0.1,0.9).tanh
				=> DetectSilenceDry.ar(_,doneAction:2)
			}.play(s,1);
			2.0.rand
		}
	};
TempoClock.sched(1,x)
 )
x.value
x=nil
