(
MegaBind(
	[
		[1,3,5,6,5,7,6,5,4,5,4,6,5,4,3,2],
		[1,\_,5,6,5,7,6,5,4,3,2]
	].df(\e,tuning:\just,scale:\minor,),
	Prand([1,2,3,4],inf).asStream.nextN(12)/4,
	[
		index1: { SinOsc.ar(3.0.rand).unipolar * 2 },
		index2: { SinOsc.ar(4).unipolar *3 },
	],
	{|i|
		SinOsc.ar( i.freqSeq * [1,2,4] ) 
		=> Pan2.ar(_,1)
		//=> Mix.ar(_)
		//=> {|j|  SinOsc.ar( i.freqSeq, j * i.index1 ) } 
		//=> {|j|  SinOsc.ar( i.freqSeq/2, j * i.index2 ) } 
		* Env.asr().kr(0,gate:i.gateSeq)
		*0.1
	},
	{|i|
FreeVerb.ar(i,1,1)
	}


	
).play;

s.meter
)
{SinOsc.ar(1005)=>Pan2.ar(_,1)}.play

(
a={ MegaBind(
	[
		[1,2,3,4,5,6,4,5],
		[-7,\_,\_,\_,-4],
		[-5,\_,-2,\_,\r, 1,\_]
	].df([ \e, \b, \a ].choose),
	[1,1,1,1,1*rrand(0.95,1.05)],
	[
		cutoff:[1800,1200,1000]
	],
	{
		|i|
		Saw.ar( i.freqSeq,0.1) 
		* Env.asr().kr(0,gate:i.gateSeq)
		=> MoogFF.ar(_,i.cutoff*2,3)

	},
	{|i v|
		Mix.ar(i)	
		=>EarlyRef.ar(_,[2,2,2],[3.rand,SinOsc.kr(0.2).unipolar,LFBrownNoise2.kr(1).range(2.5,4)],[5,4,7])
		=> DWGReverbC1C3.ar(_,9000,mix:0.9)//.wet(0.5)
		=> Phaser2.ar(_,rate:0.1)
	}
);
 };
 fork{
	16.do{
		a.().play;
		[ 8.rand,8 ].choose.wait;
	}
}
)

(
	 {
	 //Saw.ar(LFBrownNoise2.ar(1).range(300,400),0.1)
	 Saw.ar( [-1,-5].df(\c) ++ Demand.kr(Dust.kr(5),1,[1,3,5,4,5,6,5,2,3,4,3,2].df(\c).dq(inf))+LFBrownNoise2.ar(0.3).range(0,100),0.1)
	 * [1,1,3]/3
	 => {|i| [i[0] + i[1], i[2]]}
	 => TwoTube.ar(_,0.5,[0.98, 0.99 ],[110,112]).wet(0.5)
	 //=> _.wet(1.0)
	 }.play
	)

( // spastic pad
{
	var trig = Impulse.ar(1/4);
	var chords = Demand.ar(
		trig, 1,
		[
			[-1,1,3,5,7],
			[-1,2,4,6,11],
			[-2,1,4,5,6]
		].df(\c).dq(inf)
	);
	Gendy1.arWidth(freq:chords).fold(SinOsc.ar(SinOsc.ar({ 1/3.0.rand }!3).unipolar*300.rrand({ 400.rrand(600) }!4)))
	=> Splay.ar(_)
	=> FreeVerb.ar(_,1,1).wet(0.2)
	=> LPF.ar(_,8000)
	=> HPF.ar(_,80)
}.play
)
(
fork{
	10.do{
		MegaBind(
			[
				[1,3,4,6],
				[11,\_,15,\_],
				[\r,14,\_,13],

			].df([ \b,\f,\g ].choose) * [1,0.5].choose,
			1!4,
			[

				width: [
					0,
					{ Env([10,100,10],[2,2]).kr(0,gate:1) },
					{Env([1000,10,1000],[2,2]).kr(0,gate:1)},

				]
			],
			{|i x|
				case
				{x == 0} {Pulse.ar(i.freqSeq/2 => _.lag2) * Env.asr().kr(0,gate:i.gateSeq)}
				{x >= 1} {
					Saw.ar(i.freqSeq + SinOsc.kr(3.0.rand).exprange(100.rand,300.rand)) * Env.asr().kr(0,gate:i.gateSeq)  
					+
					Gendy2.arWidth(freq:i.freqSeq) * Env.asr(3,1,2).kr(0,gate:i.gateSeq,width:i.width)
				}
				=> Phaser2.ar(_,rate:3.0.rand)

			},
			{|i|
				Splay.ar(i)
				=> FreeVerb.ar(_,0.5,0.5)

			}
		).play;
		4.wait
	}
}
)


