(
[
	freq: Pwhite(100,1000,inf),
//env: Env([0,2,0],[8,4]),
//legato:[1.5,0.5].q(inf),
lag:[0,0.5].q(inf),
//lag:Pkey(\env),
pan:-1
//stretch: [1,0.5].q(inf)
//stretch: [1,0.5].q(inf)
].pm(\default) 

=> Pset(\stretch,Env([1,2,0.1],[8,9]),_)
+=
(
[
	freq: Pwhite(100,500,inf),
	pan:1,
//	amp:0
	//stretch: env([0.9,1.1],5)
	//stretch: [1,0.5].q(inf)
	//stretch: [1,0.5].q(inf)
].p
=> Pset(\stretch,Env([1,2,0.1],[8,9]),_)
)
=> _.play
)
(
MegaBind(
		[
			[11, 3, 4, 7, 11, 4.5, 5]
		].df(\g, octave:3,),
		[3,1,3,1,3,1]/3,
		[],
		{|i|
			SinOsc.ar( i.freqSeq, 0, 0.1 )
			* Env.asr().kr(gate:i.gateSeq)
		},
		{|i|
			Mix.ar(i)
		}
	).play
)
