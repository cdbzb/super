( //SETUP
)
( //animation 1
// Reaper.play(29, 45);
"Maura-Leverage-defs.scd".load;
Reaper.play(*~region);


~upperLine = [ [34f:16,36f:21 ], [45f:18,47f:2 ],[54f:6, 55f:16]];
~rightLine = [ [40f:10, 41f:08], [49f:20, 50f:16], [ 56f:8, 57 ], ];
~lowerLine = [ [43f:2, 44f:20], [ 51f:6, 52f:14 ],[57f:12, 58f:18]];


~upperLine.do{|i| i.postln;~drawLine.(*i)};
~rightLine.do{|i| ~drawLine.(*i)};
~lowerLine.do{|i| ~drawLine.(*i)};


~collection = (
	initial: 34f:14,
	grow1: (start: 45, end: 45f:15),
	grow2: (start: 52f:14, end: 53f:15),
	grow3: (start: 58f:18, end: 59f:5),
);
~len = {|i| ~collection[i].end - ~collection[i].start};

// ~drawLine.(32f:3, 34f:3 ); //circle

Reaper.sched( 32f:4,  
	{
		{
			Dust.ar(50) 
			=>Decay.ar(_,0.0001)
			=> Pan2.ar(_, 
				Env([0 , 1, 0, -1, 0], 0.5, \sin).kr(2).range(-0.3, -0.8)
			)
			=> BPF.ar(_, 
				Env([0 , 1, 0, -1, 0], 0.5, \sin).kr(2).range(500, 2000)
			)
		}.play
	}
);


Reaper.sched(30, { a = Synths(\stringyy,  //Title
	\attack, 3, 
	\freq, [300,400,555,676,880], 
	\amp, 0.2 
)});

Reaper.sched(34f:14,{ //paintings in circle 
	(
		instrument: \harpGendyPan,
		pan: [-0.6,-0.4,00.2,-0.33],
		freq: [500,600,375],
		freq: [-6, 1, 3, 5].df(\e, 6),
		modWidth:0.05,
		strum: 0.01,
		amp: 0.02,
		out: Effect.bus({|i| FreeVerb.ar(i, 0.9, 1) },)
	).play
});

Reaper.sched(32.03,{ a.release(4) });
//circle
//four paintings

[\grow1, \grow2, \grow3].collect{ |i x|
	Reaper.sched( ~collection[i][\start], {
		// fork{ ~len.(i).wait; Synth( \stringyy, [freq: [100, 125, 140][x]*2.5, amp:0.05]); };
		(instrument: \stringyy, freq: [100, 125, 140][x]*2.5, amp:0.05, lag: ~len.(i) - 0.2, sustain: ~black - ~collection[i][\start], release: 3 ).play;
		Synth(\suddenGrowth, [
			\len, ~len.(i) + 0.2,
			\startFreq, [100,125,140][x],
			\endFreq, [100,125,140][x] * 5,
			\amp,0.1
		]) 
	})
};

~black = 101.seconds.asInteger f:08;

~drawLine.(34f:15, 36f:20);
//boxed words
~boxed = (
	loan: (
		initial: 36f:20, 
		grow1: (start: 47f:7, end: 47f:15),
		grow2: (start: 55f:18, end: 56f:02)
	),
	empty: 50f:14,
	emptyUpper: 56f:22,
	art:41f:4 
);
Reaper.sched( 35f:6, {
	(instrument: \sawSynth,freq: 250, att: 3,freq: 350, amp:0.02).play
});
Reaper.sched(36f:20, { 
	(freq: 700 * [1, 1.2], rel:4, amp:0.1, out: Effect.bus({|i| FreeVerb.ar(i,1,1) * [0.1, 0.9] })).play
});
~drawLine.(40f:08, 41f:07);
)

( // pigtail
Reaper.play(1201, 1217);
[
	1203f:22
	, 1205f: 20, 
	1206f: 21,
	// 1206f: 22
].do{|i x|
	Reaper.sched(i , {
		[1, 3.1, 6.2].df(\d)[x] => (instrument: \harp, freq: _) => _.play
	} )
};
1208f:3 => Reaper.sched(_, {
	{
		SinOsc.ar([1300, 500, 650, 750])
		* EnvGen.cutoff(14f:10-(8f:3), 0.1)
		* XLine.kr(1, 0.1, 5)
		/100
	}.play
})
//three disappointments
)
(
//twisty up
Reaper.play( 1308, 1320 );
Reaper.sched( 1309f:9 + 0.2, 
	{
		{
			Env( [1, 5, 2, 7].df(\e), [9f:9, 10f:6, 10f:22, 11f:12].differentiate.drop(1) ).kr(2)
			=> Saw.ar(_)
			/80
		}.play
	}
)
)
( //dustheads
Reaper.play(1512, 1610);
~fourPointFive = 1542f:16;
~embezzlement = [1544f:12, 1545f:9] ;
~malaysian = [1545f:18, 1546f:13];


~drawLine.(1525f:23, 1526f:21);
~drawLine.(1520f:21, 1522f:06);
~fourPointFive => Reaper.sched(_, {
	( instrument:  \stringyy , freq: [1, -1].df('c#') ).play;
	( instrument: \harpGendyPan,modWidth: 0.02, amp: 0.02, freq: [-1, -15].df(\e) ).play
});
[ ~embezzlement, ~malaysian ].collect{|i x|
	Reaper.sched(i[0], {
		var dyad = {
			Saw.ar([7, 12].df([\a, \b][x], \mixolydian), 0.1)
			* (Impulse.ar(18) => Decay.ar(_,0.1))
			* EnvGen.cutoff(i.differentiate[1], 0)
			/5
		}.play;
	})
}

)
(
//hole
Reaper.play(813, 840);
~holeSound = {
	BrownNoise.ar()
	/4000
	=> Klank.ar(`[[150, 200 ]], _)
	*EnvGen.cutoff(26f:20 - (14f:4), 0.1)
};
Reaper.sched( 814f:4, { ~holeSound.play } )
)
(

//earlyhole
"Maura-Leverage-defs.scd".load;
Reaper.play(430, 555);

~opening = [ 432f:17, 435f:09, 435f:22, 435f:05, 437f:03   ];
~openingEnv = Env([4, 10, 20, 40, 100]/1000,~opening.differentiate.drop(1), \exp);
~holeSound = {
	BrownNoise.ar()
	/600
	=> Klank.ar(`[[150, 125 ] * 1.5], _)
	* ~openingEnv.kr(0).poll
	* Env.asr(0).kr(2,gate:\gate.kr(1))
	// *EnvGen.cutoff(26f:20 - (14f:4), 0.1)
};
Reaper.sched( 432f:17, { ~holeSound = ~holeSound.play } );
~firstTitle = 503f:13;
Reaper.sched( ~firstTitle, {
	~holeSound.release(15);
	(
		instrument: [\harp, \stringyy ],
		amp: [0.01, 0.1],
		freq: [1].df('f#'),
		coef: 0.1
	).play
} )
)
(
//titles in hole
"Maura-Leverage-defs.scd".load;

~holeSound = {
	BrownNoise.ar()
	/6000
	=> Klank.ar(`[[150, 125 ] * 1.5], _)
	// * ~openingEnv.kr(0).poll
	* Env.asr(0).kr(2,gate:\gate.kr(1))
	// *EnvGen.cutoff(26f:20 - (14f:4), 0.1)
};
~title = {|start end freq=400| 
	Reaper.sched(start -0.2, {
		var dur = end - start;
		s.bind{
			{
				Impulse.ar(
					// freq
					-5.rrand(15).df(\g, 4)
				)
				* EnvGen.cutoff(dur, 5)
				/20
				=> Pan2.ar(_, -1.rrand(1))
			}.play;
		};
				(instrument: [\harp, \stringyy], freq: 300.rrand(500), amp: [0.01, 0.05]).play;
			~holeSynth = ~holeSound.play;
			fork{ dur.wait; ~holeSynth.release(1) }
		}
	)
};

Reaper.play(515, 551);

~title.(516f:21,517f:22, 300 );
~title.(519f:5,520f:4, 400 );
~title.(521f:5,522f:11, 500 );
~title.(523f:9,524f:6, 500 );
~title.(525f:22,526f:16, 500 );
~title.(528f:23,531f:16, 500 );
~title.(536f:2,537f:2, 500 );
~title.(537f:2,538f:22, 500 );
~title.(538f:22,539f:19, 500 );
~title.(540f:11,541f:11, 500 );
~title.(542f:11,544f:6, 500 );
)
(
//downturn
"Maura-Leverage-defs.scd".load;

	SynthDef.new("rampDown", {arg start=20000, end=400,out = 0, amp = 0.05, len = 5;
		var sine, env_gen, env, pEnv;
		env_gen = LFGauss.ar(len,0.25,loop:0);
		pEnv = XLine.ar(start,end,len); //was 12k - 40
		sine = SinOsc.ar(pEnv,0,amp*env_gen);
		Out.ar(out, sine);
	}).add;
	~falling = [start: 3000, end: 1500,instrument: \rampDown,amp: 0.01, len:20, dur: Pwhite(2.2, 3.4, 5)].p;
	Reaper.sched(908f:13, ~falling.play);
	Reaper.play(906, 950)
)
( //graph
	Reaper.play(949, 1010);
	"Maura-Leverage-defs.scd".load;
	~interestEnv = [[941, 0.66], [941f:14, 1], [941f:20, 1], [942f:22, 0.45], [943, 0.5], [943f:13, 0.1], [944f:16, 0.1], [945f:19, 0.55], [946f:15, 0.1], [946f:23, 0.1], [948f:14, 0.9]].flop.reverse
	=> {|i| Env(i[0], i[1].differentiate.drop(1), \exp)};

	Reaper.sched(938f:18,{ //interest rates
		(freq: [1, 3, 5, 7].df('e-'), instrument: \stringyy).play
	});
	Reaper.sched(958f:15,{ //speculative investment activity
		(freq: [1, 3, 5, 7].df('e'), instrument: \stringyy).play
	});
	~dotted2 = 	{ | dur |
		{ 

			Dust.ar(50) 
			=>Decay.ar(_,0.0001)
			=>TwoTube.ar(_,loss:0.8,d1length:rrand(20,30))
			=>MoogFF.ar(_,
				// LFBrownNoise1.kr(2).range(4700,6000) +
				~interestEnv.kr* 4000,
				gain: 3
			)
			=>Pan2.ar(_,0.5,0.7)
		}.play(s,0) .dur(dur)
	};
	~drawLine2 = {| start end | Reaper.sched(start, {~dotted2.value(~duration.(start, end) )})};

	~drawLine2.(941, 948f:14);

	Reaper.sched(945f:21, { //0 percent
		(instrument: \harpGendyPan,modWidth: 0.01, freq: [-1, 1, 12].df('a-')).play;
		(instrument: \stringyy,modWidth: 0.01, freq: [-1, 1, 12].df('a-')).play
	});

	Reaper.sched(953f:19, { //12 years
		(instrument: \harpGendyPan,modWidth: 0.01, freq: [-1, 1, 12].df('b-')).play;
		(instrument: \stringyy,modWidth: 0.01, freq: [-1, 1, 12].df('b-')).play
	});

	Reaper.sched(950f:3, { //brackets
		var end = 952f:14;
		var len = end - (950f:3);
		(
			instrument: \sawSynthSustain,
			hifreq: 9000,
			freq: [1, 2, 3, 4, 5].df(\f),
			att: len,
			amp: 0.02,
			dur: len,
			rel: 8
		).play
	});
)
