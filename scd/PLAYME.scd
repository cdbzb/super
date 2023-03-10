(
~func = {|i|
		Pulse.ar(i.freqSeq.lag(i.lag.dq.zeroPad.demand(i.gateSeq)),i.width) * 0.1 
		* 
		i.amp
		*
		(
			Env.asr(0.1,1,i.rel).kr(0,gate:i.gateSeq)
			+ Env.perc().kr(0,gate:(i.gateSeq* i.trigSeq ))
		)
	};
fork{
	var length = 7.9;
	6.do{
		4.do{		 
			0.2.rand.wait;
			MegaBind(
				[
					[3, 3,  2,  3,  4,  5, 4,  6,  5, 4,  3,  2, 1,  2,  3,  2],
					[1, \_, \_, \_, \_, 6, \_, \_, 2, \_, \r, 5, \r, \r, \r, \r]
				].df(\a,tuning:\sept1,octave:[3,4,5,6].choose),
				1!16/(rrand(1,3.0)),
				[
					width:[0.1,{SinOsc.ar(5).range(0.1,0.5)}],
					lag:[ 0,0.4 ],
					rel:[2,4],
					amp: [{|e| Env.triangle(e.dur.sum).kr(0,gate:1) },1]
				],
				~func,
				{|i v|
					FreeVerb.ar(i,Line.ar(1,0,v.durs.sum),1.0.rand).tanh.tanh
				}
			).play;

			MegaBind(
				[
					[1, 3,  5,  6,  6, 5,  2,  3],
					[1, \_, \_, \_, -7, \_, \r, \r]
				].df(\d),
				( 1!8 ),
				[
					width:[0.9,0.9],
					lag:[ 0,0.4 ],
					rel:[2,4],
					amp:[1,1]
				],
				~func,
				{|i v|
				    Mix.ar(_) =>
					FreeVerb.ar(i,1,1)

				}
			).play
		};
		length.wait;
	}
		}
	)

// idea

//"|  3 (2 11) | _ _ | (13 \r) 12".split(Char.space)
