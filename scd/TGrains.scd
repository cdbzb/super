i = Item('5-8-grainsource')
/*
i.arm(s,9,1,5);
i.record
*/

{ i.playbuf }.play
( // NICE!!! another fire sounds? or other pain? (i know is everything in SC pain!)
{
	
i.refresh;
	TGrains.ar(
		2,
		trigger: GaussTrig.ar(90,0.9),
		pan: WhiteNoise.ar(1),
		dur: [0.001, 0.01, 0.0001, 1, 1  ],
		//Dust.kr(100),
		bufnum: i.buffer.bufnum,
		rate: (1..5)/2,
		centerPos: LFBrownNoise1.kr([0.1,0.11,0.101, 0.1/3, 0.99/3 ]).range(0,BufDur.kr(i.buffer.bufnum)),
		amp:1
	) => Splay.ar(_)
}.play
)



