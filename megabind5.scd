
(~func = {|i|
		Pulse.ar(i.freqSeq.lag(i.lag.dq.zeroPad.demand(i.gateSeq)),i.width) * 0.1 
		* 
		i.amp
		*
		(
			Env.asr(0.1,1,i.rel).kr(0,gate:i.gateSeq)
			+ Env.perc().kr(0,gate:(i.gateSeq* i.trigSeq ))
		)
	};
a=MegaBind(
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
		//TwoTube.ar()
		FreeVerb.ar(i,Line.ar(1,0,v.durs.sum),1.0.rand).tanh.tanh
	}
)
)
