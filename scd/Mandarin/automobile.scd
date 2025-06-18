( // song
~parent = (
	markers: (),
	t: 0
);
~song = (parent: ~parent);
~song.quarter = 132.reciprocal * 60;
( //bass
~song.bassTrackFunc = {Effect({|i| 
	CrossoverDistortion.ar(i) 
	=> Limiter.ar(_, 0.05) /2 + i
	* \gain.kr(1, 0.05)
})};
~song.bassTrack = ~song.bassTrackFunc.();
~song.bassLines = [
	[1!8, -7!3, -4!4, -3, -6!8,  3!3, -7!4, -6].df(\c, 3, \minor).flat.q,
	[1!8, -7!3, -4!4, -3 ].df(\c, 3, \minor).flat.q(2),
	[1!8, -7!8, -6!8, -3.5!8, -4!8, -2!4, -4!4, -5!8].df(\c, 3, \minor).flat.q
].collect { |i|
	{
		~song.bassTrack.synth.isRunning.not.if{
			~song.bassTrack = ~song.bassTrackFunc.() 
		};
		[
			dur: ~song.quarter/2,
			out: ~song.bassTrack.bus.index
		]
		++[ freq: i]
		=> _.pp
	}
};
);
( //traps
~song.traps = [
	{|dur|
		[
			[
				dur: "q e e q q".beats.q(4) * ~song.quarter,
				instrument: \cp_808,
				rest: [\r, 1, 1, \r, 1].q(4),
				amp: 0.25
			].p
			,
			[
				dur: "q q q q".beats.q(4) * ~song.quarter,
				instrument: \bd_808,
				decay: 15,
				amp: 0.25,
				pan: 0
			].p
		]
		=> Ppar(_) 
		=> _.findur( dur)
		=> _.play
	}
];
);

~song.tunes = [
	[\r, 3,  4,  5, 1, -7, 2,  1, \r].df(\c, \mixolydian),
	[\r, -6, -7, 1, 3, 5,  6,  4, \r].df(\c, \minor),
	[\r, 3,  4,  5, 1, 7,  11, 6, \r].df(\c, \mixolydian),
	[\r, 3, 4, 5, 1, -7, 2, 1, -7, -6, -5, \r].df(\c, \mixolydian),
//transition
	[\r, 1, 2, 3, 5, 7 ].df(\c, \mixolydian),
	[\r, 1, 2, 3, 5, 11, 7, 6, 4, 2].df(\c, \dorian)
];

~song.licks = ~song.tunes.collect{ |i x|
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

~song.chordNotes = [
	[
		[-4, 7, 2],
		[ -4, 6, 1]
	].df(\c, 4, \mixolydian),
	[
		[-5, 7, 3],
		[-4, 7, 2]
	].df(\c,4, \minor),
];
~song.chords = ~song.chordNotes.collect {|chords|
	{ 
		// fork{
		// 3.9*~song.quarter => _.wait;
		// ~song.quarter.wait;
		{
			chords[[0,0,1]] 
			//.put(1, [10, 10, 10])  
			.flop.collect {|i| i.dq.demand("q e e".beats + [0.0, 0, 0]   * ~song.quarter )}
			// => DelayN.ar(_, 0.1, [0, 0.02, 0.04])
			=> Pulse.ar(_, 0.2, 0.1)
			* 
			(
				Impulse.kr(0) / 4 +
				TDuty.ar("q e ".beats * ~song.quarter => _.dq, 0, restFirst:false, level: [1, 0.000001, 1].dq)
				=> Decay.ar(_, [0.08, 0.02 + 0.02, 0.45 * ~song.quarter].dq.demand("q e e".beats * ~song.quarter).poll)
				/2

				// /5
			)

			// * EnvGen.cutoff(~song.quarter * 3, 0.2)
			=> Mix.ar(_)
			=> { |i| CrossoverDistortion.ar(i)/ 10   } 
			* Env([1, 1, 0], [4*~song.quarter, [0.04, 0.05, 0.0613]] ).kr()
			=> { |i| BPF.ar(i, 2900, rq: 0.3) + (i/2)}
			=> HPF.ar(_, 800)
			=> RLPF.ar(_, 5000)
			// => RHPF.ar(_, 400, 0.4)
			// => Pan2.ar(_,1)
			// /10
			=> FreeVerb.ar(_,0.2,1)
			// * -5.dbamp
			// * 10.dbamp
			=> Out.ar(1, _)
		}.play
				// }
	}
};

~song.words= [
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
];

// ~song.singer = \jun;
~song.singer = \ninezero;

~song.verseVox = ();
~song.transitionVox = ();
	
[\lead, \dbl].do{ |take takeNum|
	~song.verseVox.put( 
		take, 
		~song.words[(..7)].collect{ |i x|
			SynthV.build("automobile", "verse" ++ x, ~song.singer, take, (
				lyrics:  i,
				midinote: ~song.tunes[[0,2,0,1]].wrapAt(x).collect({ |i| i.cpsmidi.asInteger}) ,
				dur: "q e e q q q e eq".beats * ~song.quarter ,
				language: \mandarin,
				phoneset: \xsampa,
				pitchTake: 2 + takeNum
			).postln)
		}
	)
};
[\lead, \dbl].do{ |take takeNum|
	~song.transitionVox.put( 
		take, 
		~song.words[[8,9]].collect{ |i x|
			SynthV.build("automobile", "transition" ++ x, ~song.singer, take, (
				lyrics:  i,
				midinote: ~song.tunes[[4, 5]].wrapAt(x).collect({ |i| i.cpsmidi.asInteger}) ,
				dur: ["q e e q q q ", "q e e q q h h h h he"][x].beats * ~song.quarter ,
				language: \mandarin,
				phoneset: \xsampa,
				pitchTake: 2 + takeNum
			).postln)
		}
	)
};

~song.transitionLicks = [
	[6.5, 6, 5.5].df(\c).q,
	[12, 11, 7].df(\c).q
];
~song.transition = ~song.transitionLicks.collect{|i x|
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

~song.transitionBgs = ();
[\lead, \dbl].do{ |take takeNum|
	~song.transitionBgs.put( 
		take, 
			SynthV.build("automobile", "transition_Bg" ++ x, \feng, take, (
				lyrics:  
				Strang.newFrom(~song.words[9]).drop(14).asString
				,
				midinote: 
				~song.transitionLicks [1].list .collect({ |i| i.cpsmidi.asInteger}) 
				,
				dur: "h h hq ".beats * ~song.quarter ,
				language: \mandarin,
				phoneset: \xsampa,
				pitchTake: 2 + takeNum
			).postln)
	)
};
~song.figure = [
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
~song.p = { |song sections start offset|
	~song.markers = ~song.markers ? ();
	start = start ? 0;
	start.isKindOf(Symbol).if{start = ~song.markers[start] + (offset ? 0)};
	~song.t = start;
	// ~song.durTill = ~song.sections.collect( _.dur) => _.integrate;
	fork{
		sections.do { |sec x|
			sec.postln;
			song[sec].() - start => _.wait;
			song.t=0
			// {song[sec].p()}.sched(~song.durTill[x])
		}
	}
};
// ~song.p = { |song start offset|
	// (lag:0.2,amp:0.02, instrument: \cymbalsDS).play;
	~song.verse = { |song|
		~song.verseVox.lead.size.do{|x|
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
				.sched( x * 8 * ~song.quarter + 0.2 - ~song.t);
			}
		};
		[0,0,0,1].dup.flat.do{|i x|  {fork{~song.chords[i].()}}.sched(x * 8 + 4 * ~song.quarter + 0.4 - ~song.t)};
		// [0,2,0,1].do{|i x| {~song.lick[i].(\sawSynthSustain)}.sched(x * 8 * ~song.quarter) };
		[1, 0].dup.flat.do{|i x| ~song.bassLines[i].sched(x * 16 * ~song.quarter + 0.2 - ~song.t) };
		2.do{|i| ~song.traps[0].sched(i + 2 * 16 * ~song.quarter + 0.2 - ~song.t )};
		// fill
		{
			[
				instrument: [\cp_808, \cp_808, \bd_808, [ \bd_808, \cymbalsDS ]].q,
				dur: "e e e e".beats.q * ~song.quarter,
				amp:[1, 1, 1, [1, 0.02]].q * -3.dbamp
			].pp
		}.sched( 4 * [ 8, 16 ] - 1.5 * ( ~song.quarter )   + 0.2 - ~song.t);

		{(instrument:\cymbalsDS, amp:0.01).play}.sched(~song.quarter * 32 + 0.2 - ~song.t);
		~song.figure[1].sched(0.2 - ~song.t);
		4 * 16 * ~song.quarter
	};
	//bridge
~song.bridge = {
	//bass
	[2].do{|i x| ~song.bassLines[i].sched(x * 16 * ~song.quarter + 0.2 - ~song.t) };
	//bass cutoff for hit
	{ ~song.bassTrack.synth.set(\gain, 0) }.sched(7 * 4 * ~song.quarter + 0.5 - ~song.t);
	~song.traps[0].sched( 0.2 - ~song.t );
	{ ~song.traps[0].(dur: ~song.quarter * 12) }.sched( ~song.quarter * 16 + 0.2 - ~song.t );
	// strings and harp
	~song.transition.do{|i x| i.sched(16 * (x ) + 4 * ~song.quarter + 0.2 - ~song.t)};
	// [4, 5].do{|i x| {~song.licks[i].(\sawSynthSustain)}.sched( x+8  * 8 * ~song.quarter - ~song.t ) => _.postln };
		[\lead, \dbl]
		// [\lead]
		.do{ |take|
			{ 
				s.bind{
					{ 
						~song.transitionBgs[take].playbuf
						/ 4  * -8.dbamp 
						=> {|i| CombN.ar(i, ~song.quarter/2, ~song.quarter, 5) / 4 + i}
						=> Pan2.ar(_,0) 
					}.play
				} 
			}
			.sched(  16 + 4 * ~song.quarter + 0.2 - ~song.t );
	};
	~song.transitionVox.lead.size.do{|x|
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
			.sched(  x  * 8 * ~song.quarter + 0.2 - ~song.t );
		}
	};
	//hit
		SynthDef(\ring, { |gate=1 out=0 freq = 400|
			var in=PinkNoise.ar(1);
			var sig=Pluck.ar(in: in,  gate: gate,  maxdelaytime: 0.02,  delaytime: 1/freq,  decaytime: \decaytime.kr(10),  coef: \coef.kr(0.5),  mul: 0.7,  add: 0);
			sig = sig * \amp.kr(0.1) * 10;
			sig = LeakDC.ar(sig);
			sig => DiodeRingMod.ar(car: sig , mod: SinOsc.ar(freq * SinOsc.ar(4).range(0.98,1.02)) )
			=> Out.ar(out,_);
			DetectSilence.ar(sig,doneAction:2);
		}).add;
	{ |def|
		[
			freq: [5, 7, 13].dup ++ [5, 7, 12].dup ++ [5, 7, 13].bubble => _.df(\c) => _.q,
			dur: "q e ee e q".beats.q * ~song.quarter,
			instrument:\ring
		].pp
	}.sched( 4 * 7 * ~song.quarter + 0.2 - ~song.t );

	32 * ~song.quarter;
	};


)
~song.p(\bridge)
s.record("/tmp/song.wav");~song.p
~song.figure.()
~song.p
(
var q = ~song.quarter;
3.do{|i| ~song.traps[0].sched(i * 8 * ~song.quarter + 0.2 )};

)

(
Song.playSection(\intro); (lag:0.2,amp:0.02, instrument: \cymbalsDS).play;
8.do{|i| {fork{Song.chords[i % 2].()}}.sched(i * 8 + 4 * Song.quarter -0.1)};
4.do{|i| {Song.lick[i % 2].(\sawSynthSustain)}.sched(i * 8 * Song.quarter) };
SystemClock.sched(Song.quarter * 16 + 0.2, {(instrument:\cymbalsDS, amp:0.02).play});
)
