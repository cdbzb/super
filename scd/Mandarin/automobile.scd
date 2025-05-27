
(
~song = ();
~song.quarter = 132.reciprocal * 60;
~song.bassTrackFunc = {Effect({|i| CrossoverDistortion.ar(i) => Limiter.ar(_, 0.05) /2 + i })};
~song.bassTrack = ~song.bassTrackFunc.();
~song.bassLines = [
	[1.dup(8), -7.dup(3), -4.dup(4), -3, -6.dup(8),  3.dup(3), -7.dup(4), -6].df(\c, 3, \minor).flat.q,
	[1.dup(8), -7.dup(3), -4.dup(4), -3 ].df(\c, 3, \minor).flat.q(2),
	[1.dup(8), -7.dup(8), -6.dup(8), -3.5.dup(8), -4.dup(8), -2.dup(4), -4.dup(4), -5.dup(8)].df(\c, 3, \minor).flat.q
].collect { |i|
	{
		~song.bassTrack.synth.isRunning.not.if{ ~song.bassTrack = ~song.bassTrackFunc.() };
		[
			dur: ~song.quarter/2,
			// out: Effect.bus({|i| CrossoverDistortion.ar(i) => Limiter.ar(_, 0.05) /2 + i })  
			out: ~song.bassTrack.bus.index
		]
		++[ freq: i]
		=> _.pp
	}
};

~song.traps = [
	{
		[
			[
				dur: "q e e q q".beats.q(4) * ~song.quarter,
				instrument: \cp_808,
				rest: [\r, 1, 1, \r, 1].q(4)

			].p
			,
			[
				dur: "q q q q".beats.q(4) * ~song.quarter,
				instrument: \bd_808

			].p
		]
		=> Ppar(_)
		=> _.play
	}
];

~song.tunes = [
	[\r, 3,  4,  5, 1, -7, 2,  1, \r].df(\c, \mixolydian),
	[\r, -6, -7, 1, 3, 5,  6,  4, \r].df(\c, \minor),
	[\r, 3,  4,  5, 1, 7,  11, 6, \r].df(\c, \mixolydian),
	[\r, 3, 4, 5, 1, -7, 2, 1, -7, -6, -5, \r].df(\c, \mixolydian),

	[\r, 1, 2, 3, 5, 7, 4].df(\c, \mixolydian),
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

~song.chords = 
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
	{ 
		// fork{
		4*~song.quarter.wait;
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
];

~song.singer = \jun;
~song.verseVox = ();
[\lead, \dbl].do{ |take takeNum|
	~song.verseVox.put( 
		take, 
		~song.words.collect{ |i x|
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
}
)

(
Song.playSection(\intro); (lag:0.2,amp:0.02, instrument: \cymbalsDS).play;
8.do{|i| {fork{Song.chords[i % 2].()}}.sched(i * 8 + 4 * Song.quarter -0.1)};
4.do{|i| {Song.lick[i % 2].(\sawSynthSustain)}.sched(i * 8 * Song.quarter) };
SystemClock.sched(Song.quarter * 16 + 0.2, {(instrument:\cymbalsDS, amp:0.02).play})
)
(
( lag:0.2,amp:0.02, instrument: \cymbalsDS).play;
~song.verseVox.lead.size.do{|x|
	// [\lead, \dbl]
	[\lead]
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
		}.sched( x * 8 * ~song.quarter + 0.2);
	}
};
[0,0,0,1].dup.flat.do{|i x|  {fork{~song.chords[i].()}}.sched(x * 8 + 4 * ~song.quarter -0.1)};
// [0,2,0,1].do{|i x| {~song.lick[i].(\sawSynthSustain)}.sched(x * 8 * ~song.quarter) };
[1, 0].dup.flat.do{|i x| ~song.bassLines[i].sched(x * 16 * ~song.quarter + 0.2) };
4.do{|i| ~song.traps[0].sched(i + 4 * 8 * ~song.quarter + 0.2 )};
SystemClock.sched(~song.quarter * 16 + 0.2, {(instrument:\cymbalsDS, amp:0.02).play})
)
(
var q = Song.quarter;
[
[6.5, 6, 5.5].df(\c).q,
[12, 11, 7].df(\c).q
].do {|i x|
	{ 
		[
			freq: i,
			dur: Song.quarter * 2,
			instrument: [\harp, \stringyy],
			amp: [0.02, 0.15],
			coef: 0.15
		].pp
	}.sched(4 + (16 * x) * Song.quarter + 0.2);
};
3.do{|i| Song.traps[0].sched(i * 8 * Song.quarter + 0.2 )};
[2].do{|i x| Song.bassLines[i].sched(x * 16 * Song.quarter + 0.2) };

[4, 5].do{|i x| {Song.lick[i].(\sawSynthSustain)}.sched(x * 8 * Song.quarter) };
)
