(// 24 billion
	Reaper.play(13);
	~record.("24 billion", 12);
	"Maura-Leverage-defs.scd".load;
	Reaper.sched(13f:6,{
		(instrument: \stringyy, freq: [1, 3, 5, 7].df('f#')).play;
		(out: Effect.bus({|i| DWGReverbC1C3.ar(i) }),freq: 5.df('f#', [2,3]), amp: 0.05).play
	});
	Reaper.sched(19f:3, {
			(instrument: [\harp, \wash], freq: [5, 1, 11].df('e-'), coef: 0.2, amp: [0.02, 0.1]).play
		}
	);
	~drawLine.(23f:15, 24f:16)
)
( //animation 1
	Reaper.play(29, 145);
	~record.("animation1", 80);
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

	~black = 101.seconds.asInteger f:09;

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
		amp:0.045,
		coef:0.2,
		out:Effect.bus({|i| FreeVerb.ar(i, 0.6, 1) }),
		instrument:\harp
	).play })});

	Reaper.sched(~boxed.loan.initial, {
		{
			Impulse.ar(
				Env([100, 100, 125, 125, 140, ], [36f:20, 47f:9, 47f:23, 55f:16, 56f:03].differentiate.drop(1), \exp).kr(0,gate:1) * [1, 1.5] => Mix.ar(_)
			)
			/15

			* EnvGen.cutoff(~black - ~boxed.loan.initial, 0.1)
			=> Pan2.ar(_, 0.5)
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
( //2013 - 2019
	Reaper.play(102 );
	~record.("2013-2019",70 );

	~dateRange = { |freq1 freq2 amp=0.1 |
		var freq = [freq1, freq2];
		{
			{
				Gendy3.arWidth(freq: freq, width: 1.040)
				/2
				+ Gendy1.arWidth(freq: freq, width: 1.040)
				/2
				* amp
				* Env.perc(0.005, 10).kr(2,gate:1)
			}.play
		}
	}; 
	// ~dateRange.(300, 360, 0.05);
	Reaper.sched(102f:23, ~dateRange.(300, 360, 0.05));

	106f:5 => Reaper.sched(_, {
		{
			SinOsc.ar([1300, 500, 650, 750])
			* EnvGen.cutoff(14f:10-(8f:3), 0.1)
			* XLine.kr(1, 0.01, 15)
			/100
			/2
		}.play
	});
	~bumplet = {|time pitch out amp|
		{
			{
				SinOsc.ar(pitch, 0, Env.perc(0.5, 5).kr(0)) / 8
				* amp
			}.play(s, out);
		} => Reaper.sched(time, _)
	};
	~bumplet.(110f:5, 750, 1, 0.01);
	// ~chart = {
	// 	Dust.ar([18, 13.1]) / 2
	// 	=> FreeVerb.ar(_, 1,  )
	// 	* Env.asr().kr(2,gate:\gate.kr(1))
	// 	// * EnvGen.cutoff()
	// }; 
	// Reaper.sched( 106f:7, {
	// 	~chart.play.dur(110f:5 - (106f:7) => _.abs) ;
	// 	[
	// 		instrument: \wash,
	// 		freq:[[600, 700, 800, 900],[600, 700,800,900]*0.95].q,
	// 		amp: 0.03,
	// 		rel: 8,
	// 		att:1,
	// 		// dur: 2,
	// 		dur: 110f:5 - (106f:7)
	// 	].pm.play
	// });
	Reaper.sched(120f:2, ~dateRange.(250, 400, 0.05));
	Reaper.sched(120f:3, {
			(
				instrument: \stringyy,
				width: 10,
				freq: [100, 150],
				dur: 205.seconds.asInteger f:4 - (120.seconds.asInteger f:3) ,
				amp: 0.05
			).play
		}
	);
	// Reaper.play(125 );
	Reaper.sched(128f:17, { //circle
			{
				Dust.ar(50) 
				=>Decay.ar(_,0.0001)
				=> Pan2.ar(_, 
					Env([0 , 1, 0, -1, 0], 0.8, \sin).kr(2).range(-0.3, -0.8)
				)
				=> BPF.ar(_, 
					Env([0 , 1, 0, -1, 0], 0.8, \sin).kr(2).range(500, 2000)
				)
			}.play
		}
	);
	~holeSound = {
		BrownNoise.ar()
		/4000
		/3
		=> Klank.ar(`[[150, 200 ]], _)
		*EnvGen.cutoff(28f:17 - (26f:22), 0.1)
		// * Env.perc(0.1, 10).kr(2)
	};
	Reaper.sched( 126f:22, {
	~holeSound.play	
	} )
)
(// debt theory
	~record.("Debt Theory Title", 10);
	Reaper.play(205);
	Reaper.sched(206f:13, {
		(freq: [1, 3, 5, 7].df(\f), instrument: \stringyy).play
	})
)
(//fruit
	Reaper.play(215 );
	~record.("fruit", 90);
	Song.cursor_(0);
	"Maura-Leverage-defs.scd".load;
	TempoClock.tempo_(0.92);
	Reaper.sched(251f:23, { TempoClock.tempo_(0.88) });
	Reaper.sched(254f:23, { TempoClock.tempo_(0.86) });
	Reaper.sched(256f:23, { TempoClock.tempo_(0.84) });
	Reaper.sched(300f:23, { TempoClock.tempo_(0.825) });
	Reaper.sched(303f:23, { TempoClock.tempo_(0.85) });
	Reaper.sched(306f:23, { TempoClock.tempo_(0.86) });
	Reaper.sched(309f:23, { TempoClock.tempo_(0.88) });
	Reaper.sched(312f:23, { TempoClock.tempo_(0.9) });
	"Maura-Leverage-Fruit.scd".load;
	Reaper.sched(216f:15 ,
		{
			Song.play
		}
	);
	// Reaper.play(302);
	Reaper.sched(303f:14, {
		(instrument: \ooh, freq: 1.df(\d, [7, 6 ]), amp: 0.05).play
	});
)
( // pigtail
	Reaper.play(1201, 1217);
	~record.("pigtail", 28);
	[
		1203f:22
		, 1205f: 20, 
		1206f: 21,
		// 1206f: 22
	].do{|i x|
		Reaper.sched(i , {
			[1, 3.1, 6.2].df(\d)[x] => 
			(
				instrument: \harpGendyPan,
				modWidth:0,
				pan: [-0.5,0,0.5][x],
				freq: _,
			)
			=> _.play
		} )
	};
	~drawLine.(1204f:2, 1205f:20);
	~drawLine.(1206f:2, 1206f:19);
	1208f:3 => Reaper.sched(_, {
		{
			SinOsc.ar([1300, 500, 650, 750])
			* EnvGen.cutoff(14f:10-(8f:3), 0.1)
			* XLine.kr(1, 0.01, 15)
			/100
		}.play
	});


	//three disappointments
)
(
//friendship twisty
	Reaper.play( 1308, 1320 );
	~record.("twisty", 14);
	Reaper.sched( 1309f:9 + 0.2, 
		{
			{
				Env( [1, 5, 2, 7].df(\e), [9f:9, 10f:6, 10f:22, 11f:12].differentiate.drop(1) ).kr(2)
				=> Saw.ar(_)
				/80
				=> Pan2.ar(_, 0)
			}.play
		}
	)
)
( //dustheads
	Reaper.play(1512, 1610);
	// ~record.("yacht", 1610-1512);
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
( //close hole
	Reaper.play(813, 940);
	"Maura-Leverage-defs.scd".load;
	~record.("close-hole", 940.seconds - 813.seconds);
	~dateRange = { |freq1 freq2 amp=0.1 |
		var freq = [freq1, freq2];
		{
			{
				Gendy3.arWidth(freq: freq, width: 1.040)
				/2
				+ Gendy1.arWidth(freq: freq, width: 1.040)
				/2
				* amp
				* Env.perc(0.1, 10).kr(2,gate:1)
			}.play
		}
	}; 
	~holeSound = {
		BrownNoise.ar().dup
		/4000
		=> Klank.ar(`[[ 50, 200,  ], [0.5, 1],[0.5, 0.5]], _)
		// *EnvGen.cutoff(26f:20 - (14f:4), 0.1)
		*Env([1, 0.7, 0.7, 0.3, 0.1, 0],[14f:4, 15f:12,24f:19,25f:18, 27].differentiate.drop(1) ++ 20).kr(0,gate:1)
		/2
	};
	Reaper.sched( 814f:4, { ~holeSound.play } );
	// Reaper.sched(818f:2, ~dateRange.(400, 500, 0.01));
	// Reaper.sched(835f:4, ~dateRange.(400/1.2, 500/1.166, 0.01));

	~drawLine.(842f:3, 843f:13);
	~drawLine.(842f:20, 844f:6);
	~drawLine.(844f:7, 845f:1);
	~drawLine.(848f:9, 849f:17);
	 ~drawLine.(850f:14, 851f:13);
	~drawLine.(852f:4, 852f:19);
	~drawLine.(853f:1, 853f:20);
	~drawLine.(854f:1, 855f:5);

)
( //hole1
	Reaper.play(430, 555);
	~record.("hole1", 90);
	"Maura-Leverage-defs.scd".load;
	~opening = [ 432f:17, 435f:09, 435f:22, 435f:05, 437f:03, 517f:22   ];
	~openingEnv = Env([4, 10, 20, 40, 100, 100, 0]/1000,~opening.differentiate.drop(1) , \exp);
	~holeSound = {
		BrownNoise.ar().dup
		/600
		/3
		=> Klank.ar(`[[150, 125 ] * 1.5,nil ,0.7], _)
		* ~openingEnv.kr(0).poll
		* Env.asr(0).kr(2,gate:\gate.kr(1))
		// *EnvGen.cutoff(26f:20 - (14f:4), 0.1)
	};
	Reaper.sched( 432f:17, { ~holeSound = ~holeSound.play } );
	~firstTitle = 503f:13;
	Reaper.sched( ~firstTitle, {
		// ~holeSound.release(15);
		(
			instrument: [\harp, \stringyy ],
			amp: [0.01, 0.1],
			freq: [-1].df('f#'),
			coef: 0.1,
			dur: 2
		).play
	});
	~holeSound2 = {|att = 1|
		// var att = 1;
		BrownNoise.ar().dup
		/6000
		/3
		=> Klank.ar(`[[-1.df(\g),150, 125 ] * 1.5, nil, 0.5], _)
		// * ~openingEnv.kr(0).poll
		* Env.asr(~att, 1, 2).kr(2,gate:\gate.kr(1))
		
		// *EnvGen.cutoff(26f:20 - (14f:4), 0.1)
	};
	~title = {|start end freq=400 num| 
			var dur = end - start;
		Reaper.sched(start -0.2, {
			fork{
				s.bind{
					{
						Impulse.ar( freq)
						* EnvGen.cutoff(dur, 5)
						/20
						=> Pan2.ar(_, -1.rrand(1))
					}.play
				}
			};
			// (instrument: [\harp, \stringyy], freq: [1, 3, 4.5, 2, 6, 5.5, 5, 4, 5].df(\c)[x], amp: [0.01, 0.05]).play;
			(instrument: [\harp, \stringyy], freq: freq, amp: [0.01, 0.05]).play;
		}) ;
		Reaper.sched(start , {
			fork{//to get the firstOne
				dur.wait;
				try{~holeSound.release(2)};
			};
			(num.isStrictlyPositive).if {
				~holeSynth = ~holeSound2.play;
				fork{ dur.wait;  ~holeSynth.release(2) }
			}
		}
		)
	};

	~notes = [1, 3, 4.5, 4, 5, 2, 2.5, 6, 5, 4.5, 1].df(\c);
	~notes = [1, 3, 2, 4, 3, 5,  4, 6,  5,  7, 6 ].df(\c);
	~notes = [1, 5, 3, 7, 5, 2, 7, 5, 2, 6, 3].df(\c);
	~att = 3;
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
	].do{|i x| ~title.(i[0], i[1], ~notes[x], x)};
	Reaper.sched(546f:21, {~holeSynth.release(1)});
)
( //downturn
	Reaper.play(906, 950);
	"Maura-Leverage-defs.scd".load;
	~record.("downturn", 24);
	~drawLineEnv.(915f:14, 919f:22, Env([1,0.4, 0.4, 0.1 ]* 4000,[915f:4, 917f:16, 919f:22].differentiate.drop(1)), {Line.kr(-0.2, 025, 4)});
	SynthDef.new("rampDown", {arg start=20000, end=400,out = 0, amp = 0.05, len = 5;
		var sine, env_gen, env, pEnv;
		env_gen = LFGauss.ar(len,0.25,loop:0);
		pEnv = XLine.ar(start,end,len); //was 12k - 40
		sine = SinOsc.ar(pEnv,0,amp*env_gen);
		Out.ar(out, sine);
	}).add;
	~falling = [start: 3000, end: 1500,instrument: \rampDown,amp: Pseg([0.001, 0.01, 0.01, 0.001], [3, 0, 6], \exp), len:20, dur: Pwhite(2.2, 3.4, 5)].p;
	Reaper.sched(908f:13, ~falling.play);
	// Reaper.sched(917f:16,{
	// 	(
	// 		instrument: [\harp, \wash],
	// 		freq: [1, 1].df('g#'),
	// 		coef: 0.2, 
	// 		amp: [0.02, 0.04]
	// 	).play
	// });
)
( //interest rates
		Reaper.play(936, 1020);
		~record.("interest", 1015.seconds-936.seconds);
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

		Reaper.sched(958f:11, { //speculative investment activity
			(instrument: [\wash, \harp], coef: 0.15, freq: [500, 400], amp: [0.1, 0.03]).play
		});

		~drawLineEnv.(1001f:5, 1003f:4, Env([0.1, 0.1] * 4000,3), {Line.kr(-1, 1, 2)});

		Reaper.sched(1003, {
			(instrument: \harpGendyPan,modWidth: 0.01, freq: [-1, 1, 12].df('a-')).play;
			(instrument: \stringyy,modWidth: 0.01, freq: [-1, 1, 12].df('a-')).play
		});
		~drawLineEnv.(1004f:9, 1007f:19, Env([0.2, 1]*4000,3f:10), {Line.kr(-0.5, 0.5, 3f:10)});
		Reaper.sched(1006f:13, {
			(instrument: \harpGendyPan,modWidth: 0.01, freq: [-1, 1, 12].df('a-')* 4/3).play;
			(instrument: \stringyy,modWidth: 0.01, freq: [-1, 1, 12].df('a-') * 4/3).play
		});
		Reaper.sched(1008f:6, { //brackets
			var end = 1009f:15;
			var len = end - (1008f:6);
			(
				instrument: \sawSynthSustain,
				center: 0.8,
				hifreq: 9000,
				freq: [1, 2, 3, 4, 5].df(\c),
				att: len,
				amp: 0.02,
				dur: len,
				rel: 8
			).play
		});
)
(//spiral
	Reaper.play(1018);
	// ~record.("spiral", 20);
	~times = [1018f:7, 1019f:11, 1020f:2, 1020f:14, 1021, 1021f:19, 1022f:13, 1023f:1, 1023f:12, 1024f:7, 1025f:6, 1025f:16, 1026f:6, 1027f:4, 1028f:4, 1028f:16, 1029f:4, 1029f:19, 1030f:12];
	~spiralEnv = Env([1, 2, 4, 3, 2, 3, 5, 4, 3, 4, 6, 5, 4, 5, 7, 6, 5, 6, 8] / 8 * 5000 ,~times.differentiate.drop(1));

	~drawLineEnv.(1018f:16, 1030f:10, ~spiralEnv, 0);
	~synths = List[];
	Reaper.sched(~times[0], {
		~effect = Effect.bus(
			{|i| MoogFF.ar(i, Env([5000, 5000, 20], [1033f:22 - ~times[0], 1f:15]).kr(0), 2.5) },inputChannels:2)
		});
	~times.select({|i x| x%4==1}).do{|i x|
		Reaper.sched(i, {
			var pitch = [1, 3, 5, 7,  ].df(\c)[x];
			var endPitch = [1, 2, 3, 4].df(\B)[x];
			~synths.add(
				{
					SinOsc.ar(Env([pitch,pitch, endPitch],[1031f:10 - i, 2f:7] ).kr(0), 0, 0.02).tanh
					* Env.asr(0).kr(2,gate:\gate.kr(1))
					=> Out.ar(~effect, _)
					// => Pan2.ar(_, -1)
				}.play 
			)
		})
	};
	~times.select({|i x| x%4==3}).do{|i x|
		Reaper.sched(i, {
			var pitch = [1, 3, 5, 6, 12,].df(\g)[x];
			var endPitch = [1, 2, 3, 4, 5].df('f#')[x];
			~synths.add(
				{
					SinOsc.ar(Env([pitch,pitch, endPitch],[1031f:10 - i, 2f:7]).kr(0), 0, 0.02).tanh
					* Env.asr(0).kr(2,gate:\gate.kr(1))

					=> Out.ar(~effect + 1, _)
					// => Pan2.ar(_, 1)
				}.play
			)
		})
	};
	Reaper.sched(1035f:9, {
		~synths.do(_.release)
	})
)
(//2016 filing
	Reaper.play(1052);
	~record.("2016-filing", 60);
	Reaper.sched(1052f:17, {

	 
		// Synths(\sparkTriangle,\rel, 5, \amp, 0.015,\out, [0, 1], \freq, [300, 400] * 1.2, \depth, 0.01).dur(1.5)
		(
			instrument: \sparkTriangle,
			rel: 5, 
			amp: 0.015, 
			out: Effect.bus({|i| DWGReverbC1C3.ar(i, mix: 0.1) }),
			freq: [300, 400]* 1.2 * 1.2,
			dur: 2,
			att: 0
		
		).play;
	});
	~bumplet = {|time pitch out amp|
		{
			{
				SinOsc.ar(pitch, 0, Env.perc(0.5, 5).kr(0)) / 8
				* amp
			}.play(s, out);
		} => Reaper.sched(time, _)
	};
		Reaper.sched(1057f:6, {

		{
			SinOsc.ar([1300, 500, 650, 750])
			// * EnvGen.cutoff(14f:10-(8f:3), 0.1)
			* XLine.kr(1, 0.01, 20)
			/300
		}.play
		});
	~bumplet.(1102f:13, 1300, 1, 0.1);
	~bumplet.(1105, 650, 0, 0.05);
	~bumplet.(1107f:8, 750, 1, 0.02);
		Reaper.sched(1122f:1, {
		{
			SinOsc.ar([1300, 500, 650, 750].scramble +1).tanh
			// * EnvGen.cutoff(14f:10-(8f:3), 0.1)
			* XLine.kr(1, 0.01, 20)
			/300
			/2
		}.play
		});
		~drawLine.(1119f:15, 1120f:16);
		~drawLine.(1135f:23, 1137f:4);
		Reaper.sched(1139f:20, {
			var done = 1141f:19;
			var out = 1144f:19;
			{
				Impulse.ar(
					[
						Line.kr(5.df(\e), 1.df(\e), done-(1139f:13)),
						Line.kr(1.df(\e), 5.df(\e), done-(1139f:13))
					]
				)
				/10
				=> {|i| CombC.ar(i, 0.4, 0.4, 5)/3+i}
				* EnvGen.cutoff(done - (1139f:13), 3)
			}.play;
		});
		Reaper.sched(1141f:19, {
			(amp: 0.03,instrument: \wash, freq: [1, 5, 12, 16, 17].df(\b)).play
		});
)
(//after the parade
	Reaper.play(1155);
	~dateRange = { |freq1 freq2 amp=0.1 |
		var freq = [freq1, freq2];
		{
			{
				Gendy3.arWidth(freq: freq, width: 1.040)
				/2
				+ Gendy1.arWidth(freq: freq, width: 1.040)
				/2
				* amp
				* Env.perc(0.1, 10).kr(2,gate:1)
			}.play
		}
	}; 

		Reaper.sched(1158f:17,{ 
			~dateRange.(300, 375, 0.02).play
		})
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
	// ~record.("IOU-corkscrew-firstPart", 1755 - 1735 );
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
	// ~record.("IOU-corkscrew", 1802 - 1750 );
	Reaper.play(1750);
		~interestEnv = [[941, 0.66], [941f:14, 1], [941f:20, 1], [942f:22, 0.45], [943, 0.5], [943f:13, 0.1], [944f:16, 0.1], [945f:19, 0.55], [946f:15, 0.1], [946f:23, 0.1], [948f:14, 0.9]].flop.reverse
		=> {|i| Env(i[0]* 4000, i[1].differentiate.drop(1) * 0.57, \exp)};
		~drawLineEnv.(1751f:23, 1756f:15, ~interestEnv, {Line.kr(-0.5, 0.5, 8)});
		Reaper.sched (1756f:22, {
			(amp: 0.05, instrument: \harpGendyPan,modWidth: 0.01, freq: [-1, 1, 12].df('b-')).play;
			(amp: 0.1,instrument: \stringyy,modWidth: 0.01, freq: [-1, 1, 12].df('b-')).play
		} )

)
(//ending
Reaper.play(1803);
~record.("end cue", 28);
Reaper.sched(1804f:1, {
		[
			freq: [
				[1, 3, 5, 7].df('f#'),
				[1, 3, 4.5, 6].df('f#'),
				[-7, 2.5, 4.5, 6].df('f#'),
				[-7, 2.5, 4.5, 5.5].df('f#'),
			].q,
			wet:0,
			dur: [1804f:1,1807f:7, 1809f:11, 1811f:23, 1812f:23 ].differentiate.drop(1).q,
			instrument: \stringyy,
			wet: 0.1,
			amp: 0.05
		].ppm
});
Reaper.sched(1814,{
		[
			wet:0,
			freq: [
				[-1, 1, 3, 5, 7],
				[-1, 1, 3, 4, 6],
				[-6.5, 6.5, 2, 4, 6],
				[-7, 7, \r, 3, 5.5],
				[-6, \r, \r, \r, 11.5]
			].df('c', 6).q,
			dur: [1814, 1816f:4,1818f:17, 1821, 1825f:5, 1830f:5].differentiate.drop(1) .dropLast ++ 1 =>_.q,
			legato: [1, 1, 1, 1, 0.1].q,
			instrument: \stringyy,
			wet: 0.1,
			amp: [10, 10, 9, 7, 4] /230 => _.q
		].ppm
})
)
