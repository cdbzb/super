(
Song(\megabindTest,[]).current;
["test",[3,2,1,2,3,-3,3,3,2.5].dm(\d)].addLine;
P(\fft,start:\test,music:{|p b e| 
	MegaBind(
		[
			[3,  2,  1,  2,  3,  \r, 3, 3,  2.5],
			[\r, \r, \r, \r, \r, \r, 1,  -7, -7],
			[-5, \_, \_, \_, \_, \r, -6, \_, -5],
			[1,  \_, \_, \_, \_, \r, 1,  \_, -7]
		].df(\e),
		b,
		[
			amp:[ 0.1,0.1,1 ],
			decay:[[ 2 ],[2,1],[5],[5]]
		],
		{|i x|
			case 
			{x<2} {
				var mod = SinOsc.kr(5,0,5);

				Gendy2.arWidth(freq:i.freqSeq / 2,width:1.05) * 0.1 +
				SinOsc.ar( 
					{ 800.0.pareto(19) }!20 
					,mod,0.1)
					+WhiteNoise.ar(0.005)
					=>MoogFF.ar(_, i.freqSeq*.t [1,6],3.5 )=>Mix.ar(_) *0.1
					* Env.asr(1,1,8).kr(0,gate:i.gateSeq)
					* Env.perc(0.5,i.decay.dq(inf).demand(i.dur)).kr(0,gate:i.dur.dropLast.tduty * i.gateSeq, levelBias:0.5,levelScale:0.5)
					* 5
				+( x==0 ).if{VarSaw.ar(i.freqSeq + SinOsc.kr(5+LFNoise1.kr(1)),width:0.5)*0.1 * Env.asr().kr(0,gate:i.gateSeq)}{0}
				}
				{x>=2} {
					Saw.ar(i.freqSeq.lag(0.05)+LFBrownNoise1.kr(1)) * Env.asr(0.1,1,5).kr(0,gate:i.gateSeq) * 0.1
				}
		},
		{|i v|
			Mix.ar(i)
			//=>FreeVerb.ar(_,0.5,1)
			=>DWGReverbC1C3.ar(_,mix:0.1)*0.5
		},
		release:30
	).play
});
)
