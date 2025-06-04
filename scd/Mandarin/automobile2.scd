(
var parent = (
        clock: TempoClock.new.permanent_(true),
		p: {|song order solo mute|
			var durs = [0] ++ order.collect{|i| song.debug("SONG").sections[i].dur }.integrate;
			song.clock.tempo_(song.quarter.reciprocal);
			order.do { |sec x | 
				var start = durs[x].debug("X");
				var parts = song.sections[sec].parts;
				solo.notNil.debug("SOLO").if {
					
					parts = parts.select{|i k| solo.asArray.includes(k)};
					parts.debug("PPP")
				};
				mute.notNil.if {
					parts = parts.reject{|i k| mute.asArray.includes(k)}
				};
				parts.do(
					_.value(start - song.transport, song.clock)
				)
			}
	}
);
~song = (
	parent: parent,
	// quarter: 0.0,
	quarter: 132.reciprocal * 60,
	transport: 0,

);
~song.use {

	// resources
	//bass
	~bassTrackFunc = {Effect({|i| CrossoverDistortion.ar(i) => Limiter.ar(_, 0.05) /2 + i })};
	~bassTrack = ~bassTrackFunc.();
	~bassLines = [
		[1!8, -7!3, -4!4, -3, -6!8,  3!3, -7!4, -6].df(\c, 3, \minor).flat.q,
		[1!8, -7!3, -4!4, -3 ].df(\c, 3, \minor).flat.q(2),
		[1!8, -7!8, -6!8, -3.5!8, -4!8, -2!4, -4!4, -5!8].df(\c, 3, \minor).flat.q,
		//transition/bridge ([3])
		[
			1!8, -7!3, -4!4, -3, 
			-6!8,  -3.5!3, -1!4, -17!1, 
			-4!8, -2!4, -4!4, -5!8,
			-4!4, -5!4, -6.5!8,
			-2!4, -4!4, -5!8
		].df(\c, 3, \minor).flat.q,
	].collect { |i|
		{
			~song.bassTrack.synth.isRunning.not.if{
				~song.bassTrack = ~song.bassTrackFunc.() 
			};
			[
				dur: 1/2 * ~song.quarter,
				out: ~song.bassTrack.bus.index,
				freq: i, 
				legato: 0.5
			].p.play
			// ++[ freq: i]
			// => _.p.play
		}
	};

	//traps
	~traps = [
		{ |c|
			[
				[
					dur: "q e e q q".beats.q(4),
					instrument: \cp_808,
					rest: [\r, 1, 1, \r, 1].q(4),
					amp: 0.15
				].p
				,
				[
					dur: "q q q q".beats.q(4) ,
					instrument: \bd_808,
					amp: 0.15 * 3.dbamp
				].p
			]
			=> Ppar(_) 
			=> _.play(~song.clock)
		}
	];


	~tunes = [
		[\r, 3,  4,  5, 1, -7, 2,  1, \r].df(\c, \mixolydian),
		[\r, -6, -7, 1, 3, 5,  6,  4, \r].df(\c, \minor),
		[\r, 3,  4,  5, 1, 7,  11, 6, \r].df(\c, \mixolydian),
		[\r, 3, 4, 5, 1, -7, 2, 1, -7, -6, -5, \r].df(\c, \mixolydian),
		//transition
		[\r, 1, 2, 3, 5, 7 ].df(\c, \mixolydian),
		[\r, 1, 2, 3, 5, 11, 7, 6, 4, 2].df(\c, \dorian),
		[11, 7, 6, 5, 4, 3, 4].df(\c),
		[12, 11, 12, 12, 13, 12, 11, 7].df(\c)
		
	];

	~licks = ~tunes.collect{ |i x|
		{ |instrument|
			[
				lag:0.2,
				amp:0.06,
				freq: i.q,
				dur: (x != 5).if {
					"q e e q q q e ee e e e q".beats.q
				}{
					"q e e q q h h h h h".beats.q 
				} * ~song.quarter,

				// legato: [10,10,10,10,9,10,10,9].q/10,
				instrument: instrument,
				lofreq: 2000, hifreq: 8000
			].ppm
		}
	};

	~chords = 
	[
		[
			[-4, -7, 2],
			[ -4, -6, 1]
		].df(\c, \mixolydian),
		[
			[-5, -7, 3],
			[-4, -7, 2]
		].df(\c, \minor),
	].collect {|chords|
		{ |c t| 
			// fork{
			// 4.wait;
			{
				chords
				.flop.collect {|i| i.dq.demand("qe e".beats * ~song.quarter)}
				=> Pulse.ar(_, 0.2, 0.1)
				=> BPF.ar(_, 900)

				* EnvGen.cutoff(wait: 3*~song.quarter, release:2)
				// => {|i| Convolution.ar(i, Dust.ar(4.df(\c)) => Decay.ar(_,0.02)=> FreeVerb.ar(_,0.5,0.1)) => HPF.ar(_, 1000) + i}
				=> Splay.ar(_, spread:0.3, center:-0.3)
				=> FreeVerb.ar(_,0.5,1)
			}.play
			// }
		}
	};

	~words= [
		//V1
		"r 夜 深 梦 醒 时 你 在",
		"r 霓 虹  闪 烁 像 你 笑",
		"r 心 跳 快 到 疯 狂 啊",
		"r 跟我 跳 进 这 节 奏 ",
		//V2
		"r 夜 风 轻 吻 你 侧 脸",         
		"r 霓 虹 中 目 光 交 叠",         
		"r 心 跳 声 淹 没 一 切",         
		"r 共 舞 到 晨 光 熄 灭",         
		// transition
		"r 时  间 停 止 了",
		"r 心 跳 声 越 来 越 快 了 啊 ",
		"时  间 停 - - 止 了", // this is just a copy - check for nonsense
		"越 来 越 快 了 啊" //dummy - change this!
	];

	// singer: \jun;
	~singer = \ninezero;

	~verseVox = ();

	[\lead, \dbl].do{ |take takeNum|
		~verseVox.put( 
			take, 
			~words[(..7)].collect{ |i x|
				SynthV.build("automobile", "verse" ++ x, ~singer, take, (
					lyrics:  i,
					midinote: ~tunes[[0,2,0,1]].wrapAt(x).collect({ |i| i.cpsmidi.asInteger}) ,
					dur: "q e e q q q e eq".beats * ~quarter ,
					language: \mandarin,
					phoneset: \xsampa,
					pitchTake: 2 + takeNum
				).postln)
			}
		)
	};
	~transitionVox = ();
	[\lead, \dbl].do{ |take takeNum|
		~transitionVox.put( 
			take, 
			~words[[8,9, 10, 11]].collect{ |i x|
				SynthV.build("automobile", "transition" ++ x, ~singer, take, (
					lyrics:  i,
					midinote: ~tunes[[4, 5, 6, 7]].wrapAt(x).collect({ |i| i.cpsmidi.asInteger}) ,
					dur: [
						"q e e q q qqx ",
						"q e e q q h h h h he",
						"h qe ee e q q q",
						// "qe e E E E q"
						"hQ Q Q Q Q Q q q"
					][x].beats * ~quarter ,
					language: \mandarin,
					phoneset: \xsampa,
					pitchTake: 2 + takeNum
				).postln)
			}
		)
	};

	~transition = [
		[6.5, 6, 5.5].df(\c).q,
		[12, 11, 7].df(\c).q
	].collect{|i x|
		{
			[
				freq: i,
				dur: ~song.quarter * 2,
				instrument: [\harp, \stringyy],
				amp: [0.02, 0.15],
				coef: 0.15
			].pp
		}
	};

	~figure = [
		[1, 6, 5, 3, 1, 6, 5, 1, 2, 4, 7, 6, 1, 4, 5, 6].df(\c,5, \mixolydian).dup(3) ++ "3 11 7 5 3 11 7  3 5 6 7 2 4.5 7 6 4.5".df('a-', 4) => _.flat => _.q(2),
		"3 5 11 5 3 5 11 5 2 4 7 4 1 4 6 1".df(\c, 5, \mixolydian).dup(3) ++ "5 11 13 11 5 11 13 11 5 7 12 7 4 6 12 6".df('a-', 4, \lydian) => _.flat => _.q(2)
	].collect {|i|
		{
			[
				freq: i,
				instrument: \harp, coef: 0.1,
				dur: ~song.quarter /2,
				instrument: \bl,
				amp:0.04,
				// legato: 0.9,
				lagTime:0
			].ppm
		}
	};

	~sections = ();
		// bass: {|t c| { (freq:358).play }.sched(0.5 +t, c) },
	~sections.verse = (dur: 64);
	~sections.verse.parts = ( 
			vox: { |t c|
				~song.verseVox.lead.size.do{ |x|
					[\lead, \dbl]
					// [\lead]
					.do{ |take|
						{ 
							s.bind{
								{ 
									~song.verseVox[take][x].playbuf
									/ 4  * -3.dbamp 
									=> {|i| CombN.ar(i, ~song.quarter/2, ~song.quarter, 5) / 4 + i}
									=> Pan2.ar(_,0) 
								}.play
							} 
						}
						.sched( x * 8 + 0.2 + t, c);
					}
				}
			},
			chords: 
			{ |t c| [0,0,0,1].dup.flat.do{|i x|  {Routine{~song.chords[i].(t,c)}.play(c,0)}.sched(x * 8 + 4 + 0.5 + t, c)}}
			,
			// [0,2,0,1].do{|i x| {~song.lick[i].(\sawSynthSustain)}.sched(x * 8 * ~song.quarter) };
			bass: {|t c| [1, 0].dup.flat.do{|i x| ~song.bassLines[i].sched(x * 16  + 0.2 + t, c) }},
			traps: {|t c| 2.do{|i| ~song.traps[0].sched(i + 2 * 16 + 0.2 + t, c )}},
			// fill
			fill: {|t c|
				{
					[
						instrument: [\cp_808, \cp_808, \bd_808, [ \bd_808, \cymbalsDS ]].q,
						dur: "e e e e".beats.q,
						amp:[1, 1, 1, [1, 0.02]].q * -5.dbamp
					].p.play(clock: ~song.clock)
				}.sched( 4 * [ 8, 16 ] - 1.5  + 0.2 + t, c)},

				crash: {|t c| {(instrument:\cymbalsDS, amp:0.01).play}.sched( 32 + 0.2 + t, c)},
				figure: {|t c| ~song.figure[1].sched(0.2 + t, c)}
			);
		};
///////////repeat
~song.sections.verse2 = ~song.sections.verse.deepCopy;
~song.sections.verse2.parts.traps = ( {|t c| 4.do{|i| ~song.traps[0].sched(i + 0 * 16 + 0.2 + t, c )}});
//////////
~song.sections.bridge = (
	dur: 16,
	parts: (
		bass: {|t c| [3].do{|i x| ~song.bassLines[i].sched(x * 16 + 0.2 + t, c) } },
		transitionLead: {|t c| ~song.transition.do{|i x| i.sched(16 * (x ) + 4 * ~song.quarter + 0.2 - t)}},
		// [4, 5].do{|i x| {~song.licks[i].(\sawSynthSustain)}.sched( x+8  * 8 * ~song.quarter - ~song.t ) => _.postln };
		vox: {|t c|
			~song.transitionVox.lead.do{|i x|
				[\lead, \dbl]
				// [\lead]
				.do{ |take|
					{ 
						s.bind{
							{ 
								~song.transitionVox[take][x].playbuf
								/ 4  * -3.dbamp 
								=> {|i| CombN.ar(i, ~song.quarter/2, ~song.quarter, 5) / 4 + i}
								=> Pan2.ar(_,0) 
							}.play
						} 
					}
					.sched([0,1,3.5, 4.5][x] * 8 + 0.2 + t, c);
				}
			};
		}
	)
);
// ~song.p([\verse, \verse2 ]);
// s.record("/tmp/auto.mp3");

	);
// // ~song.sections.foo.parts.more_({(freq:166).play});
// // ~song.sections.bar.parts.more_({(freq:666).play});
// ~song.transport = 0.0; ~song.p([\foo, \bar, \foo]);

