
(
MegaBind(
	[
		[1,2,11],
		[7,6,17+rrand(-8,8)],
		[2.5,\r,9.5]
	].df(\e),
	a={rrand(0.2,1)}!3,
	[
		wave:[
			SinOsc,Pulse,Impulse
		],
		mul:[1,0.5,1]/3,
		amp:[ 1,  [10,0.4,8], [1,5,10] ],
		lag:[0,4,10],
		location:[ #[0,2,2],#[4,12,1],#[1,2,2]]
	],
	{|i|
		i.wave.ar(i.freqSeq,width:0.01) * i.mul
		* Env.asr().kr(0,gate:i.gateSeq)
		* i.seq.(i.amp).lag(i.lag) 
	=> EarlyRef.ar(_,  source:i.location,  receiver:#[3,2,2],  roomsize:[6,5,4],  hw: SinOsc.kr(1).range(0.1,0.3),  b: 0.97,  n: 0,  p: 0,  allp_lens: nil,  allp_c: 0.7)
	},
	{|i|
		Mix.ar(i)
		=> DWGReverbC1C3_16.ar(_, 2000* SinOsc.ar(3.0.rand).range(0.99,1.01),  c1: 1,  c3: 5,  mix: 1.0,  coefs: nil,  perm: nil,  doprime: 0)
		+i
}
	
).play
)
