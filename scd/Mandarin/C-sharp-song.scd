(
Song('c#', []).current;
Song.quarter = 0.687;
["夏雨薇", "3 4 5 4 3 2 4 ".dm(\c), "e e qqqe e e e qq".beats * Song.quarter].addLine;
P.synthV(\jun, take: \lead, params: {|p b| [
	lyrics: "夏 雨 薇 风 轻 轻 唱",
	pitchTake: 1,
	language: \mandarin,
	phoneset: \xsampa,
	vocalMode: \tsubaki
] }, music:{|p b e|
	{
		e.playbuf
		/4
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(\kevin, take: \lead, params: {|p b| [
	lyrics: "夏 雨 薇 风 轻 轻 唱",
	pitchTake: 1,
	language: \mandarin,
	phoneset: \xsampa
] }, music:{|p b e|
	{
		e.playbuf
		/4
		// => p.synthVTracks.at(e.key).()
	}//.play
});
(Song.verseBassReleases = [
	1, 0.1, 1, 0.1
];
 Song.bassParams = [
	instrument: \pluckDEnvPan,
	amp:0.025,
	pan:-1.0,
	release:1,
]
);
P(\bass, music: { |p b e|
	var bassline = "1 1 1 1 1 2 2 3 4 4 4 4 4 5 5 6".df(\c, 3) ;
	p.bassParams ++
	[ 
		freq: bassline.q + Pwhite(-1.0.rrand(1.0)),
		dur: "e".beats * p.quarter => _.q(inf),
		release: 1.dup(15) ++ Song.verseBassReleases.wrapAt(e.start) => _.q
	] => _.ppm
	;

});
P(\lowBass, music: {|p b e|
	var bassline = "1 1 1 1 1 2 2 3 4 4 4 4 4 5 5 6".df(\c, 3);
	[
		freq: bassline.dupEach / 2 => _.q,
		freq: bassline / 2 => _.q,
		dur: "x".beats * p.quarter => _.q(inf),
		dur: "e".beats * p.quarter => _.q(inf),
		amp: ~lowBassAmp ? 0.05,
	].pp
});
P(\chords, music: { |p b e|
	{

		Env.perc(0,2.4).kr(0,gate: Impulse.kr(p.quarter.reciprocal /2  ) -0.001) *
		Saw.ar(
			[
				[1, 3, 5],
				[1, 4, 6],
				[1, 4, 6],
				[2, 5, 7]
			].df(\c, 5).dq(2).demand([4, 4, 4, 4, 4, 4] * p.quarter)
		)
		=> DelayN.ar(_,0.05, [0, 0.02, 0.0271])
		/ 30
		=> Phaser2.ar(_, rate:0.2)
	}.play
});
["花 瓣 落 如 诗- 一- 样-", "-1 2 3 4 3 2 1 2 3 2 1".dm(\c), "q e e qqe e e e e e e e".beats * Song.quarter].addLine;
Song.bassFxFunc = {Song.bassFx.notNil.if {Song.bassFx.synth.running.not.if {Song.bassFx = Effect.bus {|i| i/4}}{Song.bassFx}}{Song.bassFx = Effect.bus({|i| i/4})}};

P(\bass, music: { |p b e|
	p.bassParams ++
	[ 
		freq: "2 2 2 2 2 3 3 4 5 5 5 5 5 6 5 6 ".df(\c, 3).q,
		dur: "e".beats * p.quarter => _.q(inf),
		release: 1.dup(15) ++ Song.verseBassReleases.wrapAt(e.start) => _.q
	] => _.ppm

});
P(\lowBass, music: { |p b e|
	var bassline = "2 2 2 2 2 3 3 4 5 5 5 5 5 6 5 6 ".df(\c, 3);
	[
		freq: bassline.dupEach / 2 => _.q,
		freq: bassline / 2 => _.q,
		dur: "x".beats * p.quarter => _.q(inf),
		dur: "e".beats * p.quarter => _.q(inf),
		amp: ~lowBassAmp ? 0.05,
	].pp

});
P.synthV(\jun, take: \lead, params: {|p b| [夏雨薇
	// lyrics: " r 花 瓣 落 如 诗 - 一 - 样 -",
	lyrics: "r 月 光 下 她 的 泪 闪 着 光 -",
	pitchTake: 1,
	language: \mandarin,
	phoneset: \xsampa,
	vocalMode: \tsubaki
] }, music:{|p b e|
	{
		e.playbuf
		/4
		// => p.synthVTracks.at(e.key).()
	}.play
});
["verseRepeat", "3 4 5 4 3 2 4 ".dm(\c), "e e qqqe e e e qq".beats * Song.quarter].addLine;
P.synthV(\jun, take: \lead, params: {|p b| [
	lyrics: "夏 雨 薇 风 轻 轻 唱",
	pitchTake: 2,
	language: \mandarin,
	phoneset: \xsampa,
	vocalMode: \tsubaki
] }, music:{|p b e|
	{
		e.playbuf
		/4
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(\kevin, take: \lead,
	pbind: {|p b|
		[
			dur: "e e qqq".beats * Song.quarter,
			midinote: "1 2 3".dm(\c)
		].p
	},
	params: {|p b| [
	lyrics: "夏 雨 薇 风 轻 轻 唱",
	pitchTake: 1,
	language: \mandarin,
	phoneset: \xsampa
] }, music:{|p b e|
	{
		e.playbuf
		/4
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.clone('夏雨薇',[ \bass, \lowBass ]);
["verseRepeat2", "-1 2 3 4 3 2 1 2 3 2 1".dm(\c), "q e e qqe e e e e e e e".beats * Song.quarter].addLine;
P.synthV(\jun, take: \lead, params: {|p b| [
	lyrics: "r 月 光 下 她 的 泪 闪 着 光 -",
	pitchTake: 2,
	language: \mandarin,
	phoneset: \xsampa,
	vocalMode: \tsubaki
] }, music:{|p b e|
	{
		e.playbuf
		/4
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(\kevin, take: \lead,
	pbind: {|p b|
		[
			dur: "e e qqq".beats * Song.quarter,
			midinote: "-6 1 2".dm(\c)
			// * 3.dbamp
		].p
	},
	params: {|p b| [
	lyrics: "月 光 下",
	pitchTake: 1,
	language: \mandarin,
	phoneset: \xsampa
] }, music:{|p b e|
	{
		e.playbuf
		/4
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.clone('花 瓣 落',[ \bass, \lowBass ]);
["chorus1", "r", Song.quarter * 16].addLine;
( MicroKeys(\pluck).synth = { |gate=1 out=0 |
	var decaytime = \decaytime.kr(10);
	var in=PinkNoise.ar(1);
	var sig=Pluck.ar(
		in: in,
		gate: gate,
		maxdelaytime: 0.02,
		// delaytime: freq * (\poly.kr() / 127 + CC.bend(mk:MicroKeys(\pluck), rawScale: 16384).bus.kr => _.midiratio)   + [0.5, 0, -0.1]=> _.reciprocal,
		delaytime: MicroKeys.freq.() + [0.5, 0, -0.1] => _.reciprocal ,
		decaytime: decaytime,
		coef:  CC(24, mk: \pluck).bus.kr + [0, 0.1, 0.2],
	)
	=> Splay.ar(_)
	* \amp.kr(0.1) * 10
	* Env.asr().kr(2,gate:gate)
	* EnvGen.cutoff(decaytime - 0.1, 0.1)
	=> LeakDC.ar(_)
	/40;
	Out.ar(out,sig);
};
);
P(\click, music: { |p b e|
	[
		instrument: \hihat,
		dur: p.quarter,
		amp: 1
	]//.pp
});
P(\pluck,lag: -0.08, music: { |p b e|
	MIDIItem("241217_102915").take(8).fromNote(218, ~pluckEnd)//.gui
.start_(73)		
// .filter({|i| i.collect{|e| e.amp.notNil.if{e.amp_ (e.amp -30); e}{e}}})
.play(\pluck); // Rocking between c and c#
});
P(\vocalLine, music: { |p b e|
	MIDIItem("vox_250424_164001").take(2)//.gui
	.filter{|i|i.collect{|e| e.amp.notNil.if{e.amp_(e.amp/10
		* 3.dbamp
	);e}{e}}}
	.play(\sawSynthSustain);
});
P(\crash, music: { |p b e|
	(
		instrument: \cymbalsDS,
		amp:0.02,
		att: 0.05
	).play
});
P(\lead, music: { |p b e|
	MicroKeys.mono(\ld).synth_(\stringyy, [release: 3]);//.add(\quiet, {|e| e.vel.notNil.if{ e.vel = e.vel / 2 }; e}, \addBefore, \synth);
	// .monitor
	// .record
	MIDIItem("241220_132623")
	// .record(\ld) 
	.filter({|i| i.collect{|e| e.amp.notNil.if{e.amp_ (e.amp * 2  ); e}{e}}})
	// .start_(3)
	.fromNote(2)
	.play(\ld);
});
P.synthVs(\jun, take: [ \lead, \dbl ], 
	pbind: {|p b|
		[
			midinote: [5, 5, 6, 5, 6, 5, 0].dm('c#') ++ [5, 5, 6, 5, 0].dm(\c) ++ [ 5, 5, 6, 5, 4, 3, 4].dm(\c),
			dur: "e e e e e eee qq e e e eee ee e e e e e e e ".beats * Song.quarter
		].p
	},
	params: {|p b| [
		lyrics: 
		"夏 雨 薇 风 - - r  夏 雨 薇 风 r 轻 轻 地 在 唱 - - "
		,
		legato: [
			[1, 1, 1, 1, 1, 0.5, 1, 1, 1, 1, 1, 1,  1, 1, 1, 1, 1, 1, 1]
		],
        lag:  [0.1.dup(12) ++ 0.0.dup(7)],
		pitchTake: [ 1, 2 ], 
        language: \mandarin,
        phoneset: \xsampa
] }, music:{|p b e|
	{
		e.playbuf
		=> DelayN.ar(_, 2, 2.5 * p.quarter - 0.1) 
		=> FreeVerb.ar(_,0.3,1)
		* -6.dbamp
		// => p.synthVTracks.at(e.key).()
	}.play
});
["chLine2", "r",Song.quarter * 16].addLine;
// Find the half notes using .gui and use them as the tune
( // ["testPluck" ].addline
MIDIItem("241217_102915").take(8).fromNote(218)//.gui
.addLine("testPluck", {|e| e[[1, 5, 11, 16, 20, 24, 30, 35, 39, 45, 51, 55, 59/*, 66, 72, 77, 81, 87, 94, 108 */ ]] });
Song.durs[\testPluck] = Song.durs[\testPluck].list.drop(-1).q;
// Set the tempoMap
Song.setTempoMap("testPluck", "h h h h h h h h h h h h h h h h");
);
// this SynthV rhythm is warped to the tempoMap above
P.synthVs(\jun, take: [ \lead, \dbl ], pbind: {|p b|
		[
			midinote: [5, 5, 6, 5, 6, 5, 0].dm('c#') 
			++ [5, 5, 6, 5, 0].dm(\c) 
			++ [ 5, 5, 6, 5, 4, 3, 4, 0].dm(\c)
			++ [5, 5, 6, 5, 4, 3, 4, 5, 6, 5].dm('c#')
			,
			dur: "e e e e e eee qq e e e eee ee e e e e e e e  e e e e e e e e e e e ".beats.warpTo(Song.tempoMap[\testPluck]) 
		].p
	},
	params: {|p b| [
		lyrics: 
		"夏 雨 薇 风 - - r  夏 雨 薇 风 r 轻 轻 地 在 唱 - - r 星 河 流 转 时 光 慢 慢 飘 散"
		,
		legato: [
			[1, 1, 1, 1, 1, 0.5, 1, 1, 1, 1, 1, 1,  1, 1, 1, 1, 1, 1, 1,  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
		],
        lag:  [0.1.dup(12) ++ 0.1.dup(8) ++ 0.1.dup(10) => _.flat],
		pitchTake: [ 1, 2 ], 
        language: \mandarin,
        phoneset: \xsampa
] }, music:{|p b e|
	{
		e.playbuf
		=> DelayN.ar(_, 2, 2.5 * p.quarter - 0.1) 
		=> FreeVerb.ar(_,0.3,1)
		* -6.dbamp
		// => p.synthVTracks.at(e.key).()
	}.play
});
// P.tune(); //bass notes
P.tune({ |i| var bn=~bassNoteAmp ? 0.5; i <>(instrument:\sawSynth, amp:bn)}); //bass notes
P(\lead, music: { |p b e|
	MicroKeys.mono(\ld).synth_(\stringyy, [release: 3]);//.add(\quiet, {|e| e.vel.notNil.if{ e.vel = e.vel / 2 }; e}, \addBefore, \synth);
	// .monitor
	// .record
	MIDIItem("241220_132623")
	// .record(\ld) 
	.filter({|i| i.collect{|e| e.amp.notNil.if{e.amp_ (e.amp * 2  ); e}{e}}})
	.filterNotes({|i| [5, 4, 3, 3].dm('c#', 6).do {|num x| i[26 + x].midinote_(num)}; i})
	// .start_(3)
	.fromNote(2, 31)
	.play(\ld);
});
// MIDIItem("241217_102915").take(8).fromNote(218)//.gui
["V2","3 4 5 4 3 2 4 ".dm(\c), "e e qqqe e e e qq".beats * Song.quarter].addLine;
P.clone('夏雨薇', [\bass, \lowBass, \chords, \kevin]);
P.synthV(\jun, take: \lead, params: {|p b| [
	lyrics: "星 河 转 时 光 飘 散 ",
	pitchTake: 1,
	language: \mandarin,
	phoneset: \xsampa,
	vocalMode: \tsubaki
] }, music:{|p b e|
	{
		e.playbuf
		/4
		// => p.synthVTracks.at(e.key).()
	}.play
});
P(\cymbal, music: {|p b e|
	(
		instrument:  \cymbalsDS,
		amp:0.02
	).play
});
["v2Repeat","-1 2 3 4 3 2 1 2 3 2 1".dm(\c), "q e e qqe e e e e e e e".beats * Song.quarter].addLine;
P.synthV(\jun, take: \lead, params: {|p b| [
	lyrics: "r 梦 境 中 她 的 影 不 消 散 -",
	pitchTake: 1,
	language: \mandarin,
	phoneset: \xsampa,
	vocalMode: \tsubaki
] }, music:{|p b e|
	{
		e.playbuf
		/4
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.clone('花 瓣 落', [\bass, \lowBass, \chords, ]);
P(\cymbal, music: {|p b e|
	(
		instrument:  \cymbalsDS,
		amp:0.02
	)//.play
});
// .addLine("moreTestPluck", {|e| e[[82, 86, 93, 99, 106, 117, 126, 133, 142]] });
// Song.setTempoMap(\moreTestPluck, "h h h h h h h h");
// P.tune(_ <>(instrument:\sawSynth, amp:0.5)); //bass notes
// P.synthVs(\jun, take: [ \lead, \dbl ], pbind: {|p b|
// 		[
// 			midinote: [5, 5, 6, 5, 4, 3, 4, 5, 6, 5].dm('c#'),
// 			dur: "e e e e e e e e e ee".beats.warpTo(Song.tempoMap[\moreTestPluck]) 
// 		].p
// 	},
// 	params: {|p b| [
// 		lyrics: 
// 		"夏 雨 薇 风 - - r  夏 雨 薇 风 r 轻 轻 地 在 唱 - - "
// 		,
// 		legato: [
// 			[1, 1, 1, 1, 1, 0.5, 1, 1, 1, 1, 1, 1,  1, 1, 1, 1, 1, 1, 1]
// 		],
//         lag:  [0.1.dup(12) ++ 0.1.dup(7)],
// 		pitchTake: [ 1, 2 ], 
//         language: \mandarin,
//         phoneset: \xsampa
// ] }, music:{|p b e|
// 	{
// 		e.playbuf
// 		=> DelayN.ar(_, 2, 2.5 * p.quarter - 0.1) 
// 		=> FreeVerb.ar(_,0.3,1)
// 		* -6.dbamp
// 		// => p.synthVTracks.at(e.key).()
// 	}.play
// });
)



