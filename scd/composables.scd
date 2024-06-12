(
b = [
	{ Impulse.ar([ 4, 6 ]) },
	FreeVerb.ar(_, 1, 1)  
];
c = {|ffreq=900 hi=65| [
	{ Saw.ar( SinOsc.ar(1).range(60, hi).floor.midicps ) },
	LPF.ar(_, ffreq)
] };
{
	b.insert(2, {|i| Phaser2.ar(i,rate:0.2, fb:0.9)});
	b.insert(1, {|i| i*2});
	b.reduce( {|x y| x => y} );
}.play;
{
	c = c.(ffreq: SinOsc.ar(0.2).exprange(300,3000), hi: 72.rrand(66))
	.add( {|i| i * SinOsc.ar(1) /8} );
	c = c.add( Pan2.ar(_,-0.8.rrand(0.8)));
	c.reduce( {|x y| x => y} )
}.play
)
(
a = [ 
	Effect.bus({|i| FreeVerb.ar(i,1,1) }, inputChannels:2) ,
	[freq: Pwhite(500, 700), out: _].pp
];
a.insert(1, 0);
a.reduce( {|x y| x => y} );
)
(
[
	FreeVerb.ar(_,[ 1, 0.9 ],1),
	_ * 0.9,
	Effect.bus(_, out: 4.rrand(1)),
	[out: _, freq: Pwhite(300,800)],
	_.pp,
]
// .reverse
.insert(1, _/2)
.insert(5, _ ++ [dur:0.1])
.reduce( {|x y| x => y} );
)
(
a =[
	FreeVerb.ar(_,[ 1, 0.9 ],1),
	_ * 0.9,
	Effect(_, out: 4.rrand(1)),
	{|i| i.bus.index},
	[out: _, freq: Pwhite(300,800)],
	_.pp,
]
)
(
	b = 
	[ // the whole array
		[ //chain 0
			{ Impulse.ar([ 4, 6 ]) },
			FreeVerb.ar(_, 1, 1)  
		],
		[ // chain 1
			{
				Saw.ar( 200.rrand(800) )
				* SinOsc.ar(3.3.rrand(4))
				/10
			},
			Monitors.az( _, LFSaw.ar(0.1))
		],
		[
			{
				{
					Demand.ar(
						Dust.ar(10),
						0,
						Dwhite(400, 800)
					) => SinOsc.ar(_, 0, 0.1)
				}.dup(5)
				/30
			},
			(_ * 1)
		];
	];

	b.do({|i| i.add( _ * 2)}); // added to the tail of both
	b[2].add( _ * 1 );

	b.do{ |i|
		{
			i.reduce({|x y| x => y})
		}.play
	}


)
b
