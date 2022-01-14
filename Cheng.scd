Reaper.ip ="192.168.1.234";

( //first effort "scary" strings
Reaper.play(120,265);
Reaper.sched(125.5,{ 
	fork{
		7.do{
			var amp = 0.02;
			(amp:amp,instrument: \stringyy,attack:5,dur:3,freq:[1,2,3,5,6].df(\d)).play ;
			2.wait;
			(amp:amp,instrument: \stringyy,dur:3,freq:[1,2,3,5,6].df(\c)).play ;
			2.wait;
			(amp:amp,instrument: \stringyy,dur:3,freq:[1,2,3,5,6].df(\b,octave:4)).play ;
			4.5.wait;
		}
	}
});
Reaper.sched(202.10,{
	(freq:400,dur:6).play
});
Reaper.sched(149,{
	(freq:500,dur:5).play
});
)

( //idea for sound to play on cut
Reaper.play(148,200);
Reaper.sched(149.07,{
	(freq:[101,100,103.2,222,224,2543],dur:15,rel:5,amp:0.002).play;
})
)


( //cuts scene 1
~cutsScene1 = [
	27.4,
	44.4,
	149.2,
	201.2
];//.collect(_.seconds);

Reaper.play(23,211);
~cutsScene1.do(
	//Reaper.sched(_,~playOne)
	Reaper.sched(_,
		{
			{PinkNoise.ar(0.1!2)* Env([1,1,0],[0.09,0]).kr(2,gate:1)}.play;

	~playOne.(0.1);
	'!'.postln ;
		}
	)

)
)

( //cloud shimmer sound
~cloud =  {|key=\b amp=0.1|
	var freq = [2,3,6,7,5] +.x [0,10]  => _.df(key) ;
	{
		{
			var len = ~aerial - ~black;
			Blip.ar(freq,30)
			* amp
			* Env([0,1,0.8,0],[3, len - 3, 3]).kr(2,gate:1)
			=> DelayC.ar(_,1,LFBrownNoise1.ar({0.1.rand}!6).range(0.2,0.001),8)
			=> Splay.ar(_)

		}.play
	}
}
)
( // B Roll
	Reaper.play(227,240);
	~black = 229; //fade up is 3 frames 333 ms
	~aerial = 238.4;
	~street = 245.8;
	~black2 = 252.6; 
	//.()
	//;

	Reaper.sched( 
		~black + 0.333 , 
		~cloud.()
	);
	Reaper.sched(
		~aerial - 0.333, ~cloud.(\a)
	)
)
( // tinkles
var tinklesBus=Bus.audio(s,1);
Reaper.play(2020,2051);
~claps = [
	2020.883,
		2020.873,
		2021.284,
		2022.301,
		2023.380,
		2024.299,
		2024.954,
		2025.522,
		2023.375,
		2024.188,
		2024.689,
		2026,350,
		2026,453,
		2027,860,
		2029.044,
		2030,204,
		2031,238,
		2031.586,
		2031.927,
		2032.481,
		2033.506,
		2034.120,
		2035.044,
		2035.762,
		2037,471,
		2038.920,
		2040.084,
		2041.147,
		2042.446,
		2043.310,
		2044.768,
		2045.760,
		2046.824,
		2047,875,
		2048.481,
		2049.510,
		2050.084
]
.do{|i|
	Reaper.sched( i, {
		{
			var ringTime = Array.fill(17,{|i| 0.5/(17-i+1)});
			Klank.ar(
				`[
					Array.fill(17,{ exprand(2500,8000) }).sort,
					//nil,
					ringTime,
					ringTime+3
				],
				Impulse.ar(0)
			)
			*0.1
			=> EchoNone.ar(_,0.5,rrand(0.1,0.3),5)
			=> Pan2.ar(_,rrand(-1.0,1))
		}.play(s,tinklesBus.index);

	})
};

		{
			In.ar(tinklesBus.index)
		=> Phaser2.ar(_,0.1,0.9,fb:0.5)
		//=> FreeVerb.ar(_,0.95,1)
		 /3
		//=> EchoNone.ar(_,0.5,0.42,15)
	}.play;
	Reaper.sched(2105.493,{Synth(\kaya)})
)

(
SynthDef(\kaya,	
{
	DWGPlucked2.ar(
		\freq.kr(200) * SinOsc.ar(4).exprange(0.9,1.1),
		\amp.kr(0.1),
		\gate.kr(1),
		\position.kr(0.24),
		1/\decay.kr(1),
		\damping.kr(90),
		Impulse.ar(0)*\volume.kr(0.1),
		\detune.kr(1.08),
		\coupling.kr(0.05))
		=> Out.ar(\out.ir(0),_)
	}
).add;
[
	degree: Pwhite(1,8,inf),
	octave:3,
	root:8,
	dur:Pwhite(1,3.0),
	out: Effect(
		DWGSoundBoard.ar(_,10,80)
		*3
	).bus.index,
	instrument:\kaya	
].pp;
)
Synth(\kaya)
( // a bunch of kaya

Reaper.play(2102,2120);
	Reaper.sched(2104.800,{
		~soundBoard = Effect(
		DWGSoundBoard.ar(_,[10,11],80)
		*10,
		inputChannels:2,out:[0,1]
	).bus.index;

		//Synth(\kaya,[\freq:(120),\out,~soundBoard,amp:1]);
		[
			instrument:\kaya,
			out:~soundBoard,
			amp:1,
			freq:Pwhite(110,400,inf),
			dur:Prand([2,5,7]*3,inf)
		].pp
	});
)

(//pentatonix
	SynthDef(\fourNotes,{ |dur=0.2|
		Env( 
			(3..0)+ Rand(0,5)
			=> _.midicps
			,dur,7 ).kr()
		=> Saw.ar(_,0.1)
		=> Out.ar(\out.kr(0),_)
	}).play;
)
(//pattern version
	Pdef(\down4,[
		degree:(3..0).q(5),
		mtranspose:Pwhite(0,20).stutter(4),
		dur:[Pwhite(0.12,0.21,1).stutter(3),0.5].q(inf),
		scale:Scale.zhi,
		root:-3,
		tuning:\just,
		legato:[1,1,1,0.7]=>_.q(inf),
		pan:Pwhite(-1,1).stutter(4),
		lagTime:[0.1,0.2,0.01,0].q(inf),
		out: Effect(BPF.ar(_,Rand(1900,8000),2)).bus.index
,

	].pma(\sawSynthSustain)).play;

)
~cloud.([\e,\a,\d].choose,0.01).()
(type:\phrase, phrase: \down4,dur:5,legato:9,instrument:\default,amp:0.04 ).play


(//arirang down
	~cloud.([\e,\a,\d].choose,0.01).();
	[
		freq:(6-[1,2,1,2,3,4,3,4,5,4,5,3,2,-1]).df(\a,scale:\zhi).q,
		dur:[3,1,1,1,3,1,1,1,2,1,1,1,1,6].q/1.65	,
		legato:2,
		instrument:\sawSynthSustain
	].pm(\kaya).play;
Pdef(\down4).play;
[ type:\phrase, phrase: \down4,dur:3,legato:9,instrument:\default,amp:0.04 ].p.play

)

(
~freq = [5,4,5,4,3,2,3,2,1].df(\a,scale:\zhi);
~dur = [5,1,1,1,6,1,1,1,5];
~one = 6.do {
	[freq:~freq.q,dur:~dur.q*1.12,lag:Pbrown(-0.2.rand,0.4,0.01,inf),legato:1].pma(\sawSynthSustain).play;
}
)
