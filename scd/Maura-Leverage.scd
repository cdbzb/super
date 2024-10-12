( //animation 1
	Reaper.play(29, 145);
	"Maura-Leverage-defs.scd".load;
	// Reaper.play(*~region);

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

	[\empty, \emptyUpper, \art].do({ |i x| ~boxed[i] => Reaper.sched(_,{ (
		freq: [200, 250, 280][x] * 2,
		amp:0.03,
		coef:0.2,
		out:Effect.bus({|i| FreeVerb.ar(i, 0.7, 1) }),
		instrument:\harp
	).play })});
	Reaper.sched(~boxed.loan.initial, {
		{
			Impulse.ar(
				Env([100, 100, 125, 125, 140, ], [36f:20, 47f:7, 47f:15, 55f:18, 56f:02].differentiate.drop(1), \exp).kr(0,gate:1)
			)
			/10
			* EnvGen.cutoff(~black - ~boxed.loan.initial, 0.1)
		}.play
	});

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
	~record.("yacht", 1610-1512);
	~fourPointFive = 1542f:16;
	~embezzlement = [1544f:12, 1545f:9] ;
	~malaysian = [1545f:18, 1546f:13];


	~drawLine.(1525f:23, 1526f:21);
	~drawLine.(1520f:21, 1522f:06);
	~fourPointFive => Reaper.sched(_, {
		( instrument:  \stringyy , freq: [1, -1].df('c#') ).play;
		( instrument: \harpGendyPan,modWidth: 0.02, amp: 0.02, freq: [-1, -15].df(\e) ).play
	});
	~drawLine.(1535f:4, 1537f:13);
	[ ~embezzlement, ~malaysian ].collect{|i x|
		Reaper.sched(i[0], {
			var dyad = {
				Saw.ar([7, 12].df([\a, \b][x], \mixolydian), 0.1)
				* (Impulse.ar(18) => Decay.ar(_,0.1))
				* EnvGen.cutoff(i.differentiate[1], 0)
				/5
			}.play;
		})
	};
	~drawLine.(1552f:2, 1553f:3);

	Reaper.sched(1601f:3, {
		( freq: [1, 3].df(\A),instrument: [\wash, \harp],amp: [0.05, 0.01], coef:0.1 ).play
	});
	Reaper.sched(1602f:21, {
		( freq: [1, 3].df('G#', 4), instrument: \wash,amp: [0.03, 0.02], coef:0.1 ).play
	})

)
( //hole
	Reaper.play(813, 840);
	~holeSound = {
		BrownNoise.ar()
		/4000
		=> Klank.ar(`[[150, 200 ]], _)
		*EnvGen.cutoff(26f:20 - (14f:4), 0.1)
	};
	Reaper.sched( 814f:4, { ~holeSound.play } )
)
( //earlyhole
	Reaper.play(430, 555);
	"Maura-Leverage-defs.scd".load;

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
( //titles in hole
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
					Impulse.ar( freq)
					* EnvGen.cutoff(dur, 5)
					/20
					=> Pan2.ar(_, -1.rrand(1))
				}.play;
			};
			(instrument: [\harp, \stringyy], freq: 300.rrand(500), amp: [0.01, 0.05]).play;
			~holeSynth = ~holeSound.play;
			fork{ dur.wait; ~holeSynth.release(1) }
		}) 
	};

	Reaper.play(515, 551);
	~notes = [1, 3, 4.5, 4, 5, 2, 2.5, 6, 5, 4.5, 1].df(\c).q.asStream;
	[
		[516f:21, 517f:22],
		[519f:5,  520f:4],
		[521f:5,  522f:11],
		[523f:9,  524f:6],
		[525f:22, 526f:16],
		[528f:23, 531f:16],
		[536f:2,  537f:2],
		[537f:2,  538f:22],
		[538f:22, 539f:19],
		[540f:11, 541f:11],
		[542f:11, 544f:6],
	].do{|i| ~title.(i[0], i[1], ~notes.next)}
	)
	( //downturn
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
	( //interest rates
		Reaper.play(939, 1010);
		"Maura-Leverage-defs.scd".load;
		~interestEnv = [[941, 0.66], [941f:14, 1], [941f:20, 1], [942f:22, 0.45], [943, 0.5], [943f:13, 0.1], [944f:16, 0.1], [945f:19, 0.55], [946f:15, 0.1], [946f:23, 0.1], [948f:14, 0.9]].flop.reverse
		=> {|i| Env(i[0]* 4000, i[1].differentiate.drop(1), \exp)};

		Reaper.sched(938f:18,{ //interest rates
			(freq: [1, 3, 5, 7].df('e-'), instrument: \stringyy).play
		});
		Reaper.sched(958f:15,{ //speculative investment activity
			(freq: [1, 3, 5, 7].df('e'), instrument: \stringyy).play
		});

		~drawLineEnv.(941, 948f:14, ~interestEnv, {Line.kr(-0.5, 0.5, 8)});

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
( //last filing
	// ~record.("lastArtistList", 1630 - 1611);
	"Maura-Leverage-defs.scd".load;
	Reaper.play(1611, 1630 );
	~dates = { ~dates = 
		// Synths(\sparkTriangle,\rel, 5, \amp, 0.015,\out, [0, 1], \freq, [300, 400] * 1.2, \depth, 0.01).dur(1.5)
		(
			instrument: \sparkTriangle,
			rel: 5, 
			amp: 0.015, 
			out: Effect.bus({|i| DWGReverbC1C3.ar(i, mix: 0.1) }),
			freq: [300, 400]* 1.2,
			dur: 0.5,
			att: 0
		
		).play
	};
	~sheet = { ~sheet = 
		{
		Dust.ar([18, 13.1]) / 2
		=> FreeVerb.ar(_, 1,  )
		* Env.asr().kr(2,gate:\gate.kr(1))
	}.play; 
	~dates.release };
	~five = { ~five = 
		(freq: [1, 3, 5, 7, 12].df(\d), instrument: \wash, amp: 0.02, ).play.nodeID
	};
	~wade = { ~wade = 
		(
			instrument: \harp,
			coef: 0.2,
			amp: 0.05,
			freq: [1, 5].df('e-'),
			out: Effect.bus({|i| FreeVerb.ar(i, 0.5 ) => Pan2.ar(_, 0) },)
		).play
	};
	~warhol = 1625f:19;

	[
		1614f:17, ~dates,
		1617f:4, ~sheet,
		1619f:19, ~five,
		1621f:05, ~wade
	] => {|i| i.pairsDo{|x y| Reaper.sched(x, y)}};

	~line = [1622f:19, 1623f:17, 1624f:8, 1625, ]
	.do {|i x| Reaper.sched(i, {
		~lineSyn = ~lineSyn.isPlaying.not.if {
			{
				Impulse.ar( \freq.kr(1.df(\b).dup).lag3(0.2) ) / 20
				* Env.asr().kr(2,gate:\gate.kr(1))
			}.play.register
		} {
			~lineSyn.set(\freq, [1, 3, 4.5, 2, [ 1, 6 ]].df(\b)[x])
		}
	});
	~warhol => Reaper.sched(_, { (amp: 0.01, coef: 0.1, instrument: \harp, freq: 999).play;~lineSyn.release(1); ~sheet.release(1) })
	 }
)
(
	Reaper.play(1735);
	~record.("IOU-corkscrew-firstPart", 1755 - 1735 );
	"Maura-Leverage-defs.scd".load;
	~drawLineEnv.(1735f:13, 1743f:17, 
		Env(
			[0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1,0, 1, 0, 1,  0, 1, 0, 1, 0, 1, 0, 1] * 2000 + 1500,
			[1735f:12, 1735f:19, 1736f:3, 1736f:12, 1736f:18, 1737f:2, 1737f:10, 1737f:17, 1738, 1738f:7, 1738f:16, 1739, 1739f:7, 1739f:14, 1739f:22, 1740f:5, 1740f:12, 1740f:16 ].differentiate.drop(1)
		),
		{Line.kr(-1, 1, 8)} 
	);
	~crests = List[];
	~morph = 1740f:20 ;
			[1735f:12, 1735f:19, 1736f:3, 1736f:12, 1736f:18, 1737f:2, 1737f:10, 1737f:17, 1738, 1738f:7, 1738f:16, 1739, 1739f:7, 1739f:14, 1739f:22, 1740f:5, 1740f:12, 1740f:16 ].do({|i x| x.odd.if {
					Reaper.sched(i, {~crests.add({ Impulse.ar(300.rrand(500)) / 20 * Env.asr(0.5, 1, 3).kr(2,gate:\gate.kr(1))}.play)} )
				}
			});
	Reaper.sched(~morph, 
		{
		var num = 12;
		var deltas = {-100.rrand(100)}.dup(num);
		{
			SinOsc.ar( (1..num) * 333 + Line.kr(deltas, 0, 1) )
			/20
			* Env.linen(0.2, 0.5, 1).kr(2)
		}.play
	}
	);
	Reaper.sched(1742f:3, {
		~crests.do(_.release)
	})
)
(
	~record.("IOU-corkscrew", 1802 - 1750 );
	Reaper.play(1750);
		~interestEnv = [[941, 0.66], [941f:14, 1], [941f:20, 1], [942f:22, 0.45], [943, 0.5], [943f:13, 0.1], [944f:16, 0.1], [945f:19, 0.55], [946f:15, 0.1], [946f:23, 0.1], [948f:14, 0.9]].flop.reverse
		=> {|i| Env(i[0]* 4000, i[1].differentiate.drop(1) * 0.57, \exp)};
		~drawLineEnv.(1751f:23, 1756f:15, ~interestEnv, {Line.kr(-0.5, 0.5, 8)});
		Reaper.sched (1756f:22, {
			(amp: 0.05, instrument: \harpGendyPan,modWidth: 0.01, freq: [-1, 1, 12].df('b-')).play;
			(amp: 0.1,instrument: \stringyy,modWidth: 0.01, freq: [-1, 1, 12].df('b-')).play
		} )

)
