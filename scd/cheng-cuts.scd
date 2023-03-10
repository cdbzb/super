(
~cuts = [
	2.920, // clack
	7.2, // x-fade
	27.600, //closeup
	44.600,  //new charachter
	149.500, //minor
	201.400, //new charachter
];
~cluster = {
	var key = ~seq.next*2;
	{
		//[1,5,7,13].df(key,tuning:\just,octave:6)
		key
		=> SinOsc.ar(_,0,0.1)
		* Env([1,0],4).kr(2,gate:1)
	}.play
};
)
~cluster.()




(
~seq = [
	[400,600,750,320],
	[400,600,750,320],
	[400,600,750,320],
	[400,600,750,320],

].q.asStream;
Reaper.play(1,245);
Reaper.sched(2.920,

	{
	[dur:60/46.05, note:[ [0].q(8*4),[1].q(15*4) ].q].pp
});
~cuts[[0,2,3,5]].do{ |i|
	Reaper.sched(i + 0.2,~cluster)
}
)


44.6-2.9/ (60/46.05) /4 // 8 bars @ 47
121-44/ (60/47) /4 // 15 bars to chengs father

( // orchestra-ey
var fiveOne = MegaBind(
	[
		[-3,   -3, \r,\r,\r,\r,\r,\r],
		[-1,   -1, \r,\r,\r,\r,\r,\r],
		[-15,  -15, \r,\r,\r,\r,\r,\r],
		[-25, -11, \r,\r,\r,\r,\r,\r],
	].df(\g)
	,
	46.05.reciprocal ! 7 * 60
	,
	[

	],
	{ |i x|
		{ Gendy1.arWidth(freq:i.freqSeq ,width:1.05,ampdist:0.7,durdist:0,knum:3)
			+ Gendy2.arWidth(freq:i.freqSeq ,width:1.05,ampdist:0.7,durdist:0,knum:3)
			* 
			(
				Env.asr(1,1,0.5).kr(0,gate:i.gateSeq) / 9
				+ Env.perc(0.3).kr(0,gate:(i.gateSeq* i.trigSeq ))
			)
			+ ( x |==| 3).if {
				Pulse.ar(i.freqSeq/[1,0.5],0.5) * Env.perc(0.01,1).kr(0,gate:( i.trigSeq * i.gateSeq))
				=> FreeVerb.ar(_,0.6,0.6)
			}{
				0
			}}
		
	},
	{ |i v|
		Splay.ar(i)
		=> MoogFF.ar(_,1900)
		=>LPF.ar(_,600)
		*0.4
	}

);

b = 

MegaBind(
		[
		//[\r, \r, 1, -6.5, \_, -6, -5, \r,  \r, \r, -1, -16.5, \_, -16, -15, \r,  ],
		//[\r, \r, 1, \_,   2,  3,  4,  \r,  ]
		[7,\_,6,\_,5,4,3,\_,2,\_]
	].df(\g,octave:5,scale:\mixolydian),
	46.05.reciprocal * 60,
	[],
	{|i x|
		VarSaw.ar(i.freqSeq*2 , SinOsc.ar(3)*[0.999,1.009,1],0.5)
		* 
		(
			Env.asr(release:3).kr(0,gate:i.gateSeq) /3
			+ Env.perc(0.1,2).kr(0,gate:(i.gateSeq*i.trigSeq))
		)
		* 0.04
	},
	{|i|
		Mix.ar(i)
		=> FreeVerb.ar(_,1,0.9)
	}
	);
//a.play
Reaper.play(0,313);
3.do{ |x|
Reaper.sched(
	2.9 + ( 60*46.05.reciprocal *( 3 + (x * 8) ) ) + 0.2,
	{
		fiveOne.play;
	}

)
};

Reaper.sched(
	2.9 + ( 60*46.05.reciprocal *5 ) + 0.2,
	{ 
		Convolution.ar(
			Saw.ar([200,150,430]*1.1),
			//Saw.ar([880,883+SinOsc.kr(0.6),880*1.5,880*5/4]/4),
			Crackle.ar(2)
			=> LPF.ar(_,1800)
		) 
		=> HPF.ar(_,200) 
		=> FreeVerb.ar(_,0.2,1) 
		*0.005
	}.play
);
Reaper.sched(
	
	2.9 + ( 60*46.05.reciprocal *( 5 ) ) + 0.2 ,
	{b.play}
)
)
)
