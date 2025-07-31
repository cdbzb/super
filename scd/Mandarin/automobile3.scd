(
Song(\automobile, []).current;
Song.clock = TempoClock.new;
Song.clock.permanent_(true);
Song.quarter = 132.reciprocal * 60;
Song.clock.tempo_(Song.quarter.reciprocal);

	// resources
	//bass
Song.bassTrackFunc = {Effect({|i| CrossoverDistortion.ar(i) => LeakDC.ar(_) => Limiter.ar(_, 0.05) /2 + i })};

// Song.bassTrack = {Song.bassTrackFunc.()};
// Song.bassTrack.free;

Song.bassLines = [
	[1!8, -7!3, -4!4, -3, -6!8,  3!3, -7!4, -6].df(\c, 3, \minor).flat.q,
	//bridge no passing tones
	[1!8, -7!3, -4!4, -3 ].df(\c, 3, \minor).flat.q(2),
	// shortBridge
	[1!8, -7!8, -6!8, -3.5!8, -4!8, -2!4, -4!4, -5!8].df(\c, 3, \minor).flat.q,
	// long bridge ([3])
	[
		1!8, -7!3, -4!4, -3, 
		-6!8,  -3.5!3, -1!4, -7!1, 
	].df(\c, 3, \minor).flat.q,
	// variant [4]
	[
		1!8, -7!8,-6!8, -3.5!7, -7,
		-4!8, -2!4, -4!4, -5!8,
		-4!4, -5!4, -6.5!8,
		-2!4, -4!4, -5!8
	].df(\c, 3, \minor).flat.q

].collect { |i|
	{
		Song.bassTrack.notNil.if
		{
			Song.bassTrack.synth.isRunning.not.if{
				s.freeMyDefaultGroup;
				Song.bassTrack = Song.bassTrackFunc.() 
			}
		}{
				s.freeMyDefaultGroup;
				Song.bassTrack = Song.bassTrackFunc.() 
		};
		[
			dur: 1/2 * Song.quarter,
			out: Song.bassTrack.bus.index,
			freq: i, 
			legato: 0.5
		].p.play
		// ++[ freq: i]
		// => _.p.play
	}
};

//traps
Song.traps = [
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
		=> _.play(Song.clock)
	},
	{ |c|
		[
			[
				dur: "q e e q qq qq q".beats.q(6),
				instrument: \cp_808,
				rest: [\r, 1, 1,\r, 1, 1, 1  ].q(6),
				amp: 0.15
			].p
			,
			[
				dur: "q q q q".beats.q(12) ,
				instrument: \bd_808,
				amp: 0.15 * 3.dbamp
			].p
		]
		=> Ppar(_) 
		=> _.play(Song.clock)
	},

	{
		[
			[
				dur: "q e e q qq qq q".beats.q(4),
				instrument: \cp_808,
				rest: [\r, 1, 1,\r, 1, 1, 1  ].q(4),
				amp: 0.15
			].p
			,
			[
				dur: "q q q q".beats.q(8) ,
				instrument: \bd_808,
				amp: 0.15 * 3.dbamp
			].p
		]
		=> Ppar(_) 
		=> _.findur(Song.quarter * 31 * 2)
		=> _.play(Song.clock)
	}
];


Song.tunes = [
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

Song.licks = Song.tunes.collect{ |i x|
	{ |instrument|
		[
			lag:0.2,
			amp:0.06,
			freq: i.q,
			dur: (x != 5).if {
				"q e e q q q e ee e e e q".beats.q
			}{
				"q e e q q h h h h h".beats.q 
			} * Song.quarter,

			// legato: [10,10,10,10,9,10,10,9].q/10,
			instrument: instrument,
			lofreq: 2000, hifreq: 8000
		].ppm
	}
};

Song.chords = 
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
			.flop.collect {|i| i.dq.demand("qe e".beats * Song.quarter)}
			=> Pulse.ar(_, 0.2, 0.1)
			=> BPF.ar(_, 900)

			* EnvGen.cutoff(wait: 3*Song.quarter, release:2)
			// => {|i| Convolution.ar(i, Dust.ar(4.df(\c)) => Decay.ar(_,0.02)=> FreeVerb.ar(_,0.5,0.1)) => HPF.ar(_, 1000) + i}
			=> Splay.ar(_, spread:0.3, center:-0.3)
			=> FreeVerb.ar(_,0.5,1)
		}.play
		// }
	}
};

Song.words= [
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
Song.singer = \ninezero;

Song.verseVox = ();

[\lead, \dbl].do{ |take takeNum|
	Song.verseVox.put( 
		take, 
		Song.words[(..7)].collect{ |i x|
			SynthV.build("automobile", "verse" ++ x, Song.singer, take, (
				lyrics:  i,
				midinote: Song.tunes[[0,2,0,1]].wrapAt(x).collect({ |i| i.cpsmidi.asInteger}) ,
				dur: "q e e q q q e eq".beats * Song.quarter ,
				language: \mandarin,
				phoneset: \xsampa,
				pitchTake: 2 + takeNum
			).postln)
		}
	)
};
Song.transitionVox = ();
[\lead, \dbl].do{ |take takeNum|
	Song.transitionVox.put( 
		take, 
		Song.words[[8,9, 10, 11]].collect{ |i x|
			SynthV.build("automobile", "transition" ++ x, Song.singer, take, (
				lyrics:  i,
				midinote: Song.tunes[[4, 5, 6, 7]].wrapAt(x).collect({ |i| i.cpsmidi.asInteger}) ,
				dur: [
					"q e e q q qqx ",
					"q e e q q h h h h he",
					"h qe ee e q q q",
					// "qe e E E E q"
					"hQ Q Q Q Q Q q q"
				][x].beats * Song.quarter ,
				language: \mandarin,
				legato: (x == 2).if {[1, 1, 1, 1, 1, 1, 0.9]},
				lag: (x == 3).if {[0.05, 0,0,0,0,0,0,0]},
				phoneset: \xsampa,
				pitchTake: 2 + takeNum
			).postln)
		}
	)
};

Song.transition = [
	[6.5, 6, 5.5].df(\c).q,
	[12, 11, 7].df(\c).q
].collect{|i x|
	{
		[
			freq: i,
			dur: Song.quarter * 2,
			// dur:  1,
			instrument: [\harp, \stringyy],
			amp: [0.02, 0.15],
			coef: 0.15
		].pp
	}
};

Song.figure = [
	[1, 6, 5, 3, 1, 6, 5, 1, 2, 4, 7, 6, 1, 4, 5, 6].df(\c,5, \mixolydian).dup(3) ++ "3 11 7 5 3 11 7  3 5 6 7 2 4.5 7 6 4.5".df('a-', 4) => _.flat => _.q(2),
	"3 5 11 5 3 5 11 5 2 4 7 4 1 4 6 1".df(\c, 5, \mixolydian).dup(3) ++ "5 11 13 11 5 11 13 11 5 7 12 7 4 6 12 6".df('a-', 4, \lydian) => _.flat => _.q(2)
].collect {|i|
	{
		[
			freq: i,
			instrument: \harp, coef: 0.1,
			dur: Song.quarter /2,
			instrument: \bl,
			amp:0.04,
			// legato: 0.9,
			lagTime:0
		].ppm
	}
};
[\verse, "r", [64*Song.quarter]].addLine;
// could make a line per phrase
Song.verseVox.lead.do{|i x|
	[\lead, \dbl].do{ |take|
		P(\vox++"_"++x++"_"++take,lag:x*8*Song.quarter, music:{
			{ 
				Song.verseVox[take][x].playbuf
				/ 4  * -3.dbamp 
				=> {|i| CombN.ar(i, Song.quarter/2, Song.quarter, 5) / 4 + i}
				=> Pan2.ar(_,0) 
			}.play
		} 
	)
}
};
P(\chords, music:{
[0,0,0,1].dup.flat.do{|i x|  
	{Routine
		{Song.chords[i].(0, Song.clock)}.play
		// {Song.chords[0].(0, Song.clock)} .play
	}.sched(x * 8 + 4 + 0.5, Song.clock)
}
});
P(\bass,music: { {|t c| [1, 0].dup.flat.do{|i x| Song.bassLines[i].sched(x * 16  + t, c) }}.(0,Song.clock) });
P(\traps, music:  
{
	{|t c| 2.do{|i| Song.traps[0].sched(i + 2 * 16  + t, c )}
}.(0,Song.clock)
});
P(\fill, music: { {|t c|
{
	[
		instrument: [\cp_808, \cp_808, \bd_808, [ \bd_808, \cymbalsDS ]].q,
		dur: "e e e e".beats.q,
		amp:[1, 1, 1, [1, 0.02]].q * -5.dbamp
	].p.play(clock: Song.clock)
}.sched( 4 * [ 8, 16 ] - 1.5 + t, c)}.(0, Song.clock) },
);
P( \crash, music: {{|t c| 
	{(instrument:\cymbalsDS, amp:0.01).play}.(0,Song.clock).sched( 32 + t, c)}.(0, Song.clock)},
);
P(\figure, music: { 
	{|t c| Song.figure[1].sched( t, c)}.(0, Song.clock) }
);
["V2", "r", Song.secDur["verse"].bubble].addLine;
P(\traps,
	music: {
		{|t c| 4.do{|i| Song.traps[0].sched(i + 0 * 16 + t, c )}}.(0, Song.clock)
	}
);
["bridge", "r", [48 * Song.quarter]].addLine;
P(\bass, music: { {|t c| [4].do{|i x| Song.bassLines[i].sched(x * 16 + t, c) } }.(0, Song.clock) });
P(\traps, music: {{|t c| 2.do{|i| Song.traps[1].sched(0 + t, c )}}.(0, Song.clock)};
);
P( \transitionLead, music: {
	{|t c| Song.transition.do{|i x| i.sched(16 * (x ) + 4 * Song.quarter  - t)}}.(0, Song.clock)
});
P(\vox, music: { {|t c|
		Song.transitionVox.lead.do{|i x|
			[\lead, \dbl]
			// [\lead]
			.do{ |take|
				{ 
						{ 
							Song.transitionVox[take][x].playbuf
							/ 4  * -3.dbamp 
							=> {|i| CombN.ar(i, Song.quarter/2, Song.quarter, 5) / 4 + i}
							=> Pan2.ar(_,0) 
						}.play
				}
				.sched([0,1,3.5, 4.5][x] * 8 + 0.5 + t, c);
			}
		};
	}.(0, Song.clock) 
});
["shortBridge", "r", [28*Song.quarter]].addLine;
P(\bass, music: { {|t c| [2].do{|i x| Song.bassLines[i].sched(x * 16 + t, c) } }.(0, Song.clock) });
P(\traps, music: {{|t c| 1.do{|i| Song.traps[2].sched(0 + t, c )}}.(0, Song.clock)};
);
P( \transitionLead, music: {
	{|t c| Song.transition.do{|i x| i.sched(16 * (x ) + 4 * Song.quarter  - t)}}.(0, Song.clock)
});
P(\vox, music: { {|t c|
		Song.transitionVox.lead[[0,1]].do{|i x|
			[\lead, \dbl]
			// [\lead]
			.do{ |take|
				{ 
						{ 
							Song.transitionVox[take][x].playbuf
							/ 4  * -3.dbamp 
							=> {|i| CombN.ar(i, Song.quarter/2, Song.quarter, 5) / 4 + i}
							=> Pan2.ar(_,0) 
						}.play
				}
				.sched([0,1,3.5, 4.5][x] * 8 + 0.5 + t, c);
			}
		};
	}.(0, Song.clock) 
});
["connector","r", [8 * Song.quarter]].addLine;
P(\connector, music: {
		[
			freq: [5, 7, 13].dup ++ [5, 7, 12].dup ++ [5, 7, 13].bubble => _.df(\c, 3) => _.q,
			dur: "q e ee e q".beats.q * Song.quarter,
			instrument:\ring,
			instrument: \defaultPorto
		].pp;
		[
			freq: [5, 7, 13].dup ++ [5, 7, 12].dup ++ [5, 7, 13].bubble => _.df(\c) => _.q,
			dur: "q e ee e q".beats.q * Song.quarter,
			instrument:\ring
		].pp;
		(lag:Song.quarter*4,amp: [0.05, 0.1],instrument: [\harp,\wash], freq: [-1, 1].df(\g, [3,4])).play;
	});
	P(\lick,lag:Song.quarter * 5, music: {

			[
				// lag:Song.quarter*5,
				freq: [ 2, 3, 4, 2, -5, -11].df(\c, 5).q,
				dur: "e e Q Q Q q".beats.q * Song.quarter,
				instrument: \sparkTriangle,
				pulse: 0.7,
				lagTime: 0,
				amp: 0.1
			].ppm
	});
		SynthDef(\ring, { |gate=1 out=0 freq = 400|
			var in=PinkNoise.ar(1);
			var sig=Pluck.ar(in: in,  gate: gate,  maxdelaytime: 0.02,  delaytime: 1/freq,  decaytime: \decaytime.kr(10),  coef: \coef.kr(0.5),  mul: 0.7,  add: 0);
			sig = sig * \amp.kr(0.1) * 10;
			sig = LeakDC.ar(sig);
			sig => DiodeRingMod.ar(car: sig , mod: SinOsc.ar(freq * SinOsc.ar(4).range(0.98,1.02)) )
			=> Out.ar(out,_);
			DetectSilence.ar(sig,doneAction:2);
		}).add;
)

///////////repeat
// ~song2.sections.verse2 = ~song2.sections.verse.deepCopy;
// ~song2.sections.verse2.parts.traps = ( );
//////////

