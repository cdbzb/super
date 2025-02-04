(
//lyrics from Qwen
春风拂面来 
花开满园香飘远 
心随梦飞翔 
爱永恒 

春风拂面来 (5)
花开满园香飘远 (7)
心随梦飞翔 (5)
爱永恒 (3)
)
(
//bridge lyrics from DeepSeek
	() ) | 星光 | 闪烁 | 夜空 | 中 | 心 | 跳 | 动
	( ) | 你我 | 相拥 | 在这 | 一刻 | 爱 | 永 | 恒

	Transliteration (Pinyin):

	( ) | xīng guāng | shǎn shuò | yè kōng | zhōng | xīn | tiào | dòng
	( ) | nǐ wǒ | xiāng yōng | zài zhè | yī kè | ài | yǒng | héng

	Translation in English:

	( ) | Starlight | flickers | in the night sky | heart | beats | on
	( ) | You and I | embrace | in this | moment | love | eternal | forever
)
(
MicroKeys(\vocalLine).synth_(\sawSynthSustain)
.monitor
;
MIDIItem("_250119_101434").take(1).play('vocalLine') //2nd or third time aroung has a nice transition
MIDIItem("_250119_102256").play('vocalLine')
MIDIItem("_250119_103705").play('vocalLine')
// .record('vocalLine')
)
(
~quarter = 0.52;
MicroKeys(\port).synth_(\defaultPorto);//.monitor;
// MIDIItem("250121_120748").take(2).play(\vocalLine);
MIDIItem("_250120_094839").play(\port);
(instrument: \cymbalsDS, amp: 0.02).play;
[
	instrument: \JWSnare,
	dur: "q e eq q".beats.q(inf) * ~quarter,
	rest: [\r, 1, 1, 1].q(inf),
	amp: 0.25
	// dur: 
].pp;
[
	instrument: \bd_808,
	dur: "e eq qq".beats * ~quarter => _.q(inf),
	amp: 0.6

].pp;
// ~quarter = 0.46;
[
	instrument: [\harp, \sawSynth],
	freq: [1, 1, 1, 1, 1, 1, 1, 1, 5, 5, 5, 6, 4, 4, 5, 5, ].df(\c, [3, 4]).q(8),
	dur: ~quarter / 2,
	legato: 0.4,
	att: 0, rel: 0.5,
	amp: [0.05, 0.2]
].pp;
[
	freq: [1, 4, 5, 6 ,4, 5, 1, 4, 5, 6 , 4, 5].df(\c, [3]).q(8),
	dur: "eee e ex x e e".beats * ~quarter * 2 => _.q(16),
	amp: 0.3
].pp;
MicroKeys(\lead).synth_({ arg out=0,  amp = 0.1, att = 0.1, rel = 2, lofreq = 1000, hifreq = 3000, lagTime = 0.3, spread = 1, center = 0;
	var env, snd, freq;
	// freq = Lag.ar(
		freq = MicroKeys.freq.(~mk).()
		 => Lag.kr(_, lagTime)

		// ,lagTime);
		;
	env = Env.perc(
		attackTime: att,
		releaseTime: rel,
		level: amp
	).kr(doneAction: 2);
	snd = Saw.ar(freq: freq * [0.99, 1, 1.001, 1.008], mul: env);
	snd = LPF.ar(
		in: snd,
		freq: LFNoise2.kr(1).range(lofreq, hifreq)
	);
	snd = Splay.ar(snd,spread:spread,center:center);
	Out.ar(out, snd);
}.asDefName);
// MicroKeys(\lead).monitor
MIDIItem("_250119_105441").take(11).play('vocalLine', clock: TempoClock.new(0.52 / ~quarter, qeueSize: 2**12  ))
// .take(7).play('vocalLine')
// .record('vocalLine')
)
( // song
/*
时代的风吹过长安街
人群像落叶随风飘
年轻的眼睛寻找答案
但真相藏在雾里逃
*/
Song(\Wind, []).current;

Song.keySig=\c;
Song.quarter = 0.52;

["countoff", "r", [1]].addLine;
P.synthV(\an, take: \leadQwen, lag: -0.08, pbind: 
	MIDIItem("_250119_105441").take(11)
	.collect({|i x| (x >= 1).if { i.timestamp = i.timestamp - (Song.quarter * 4) - 1 }; i })
	.synthVPbind
	,
// need to make Legato
	params: {|p b| [
		// lyrics: " r 时 代 的 风 吹 过 长 安 
		// 人 群 像 落 叶 随 风 飘 
		// 年  轻 的 眼 睛 寻 找 答 案
		// 但 真 相 藏 在 雾 里 逃
		// 时 代 的 风 吹 过 长 安
		// ",
		lyrics: "r 
		春 风 拂 面 来 
		花 开 满 园 香 飘 远 
		心 随 梦 飞 翔 
		爱 永 恒 
		星 夜 静 如 水 
		月 光 洒 落 思 乡 情 
		梦 回 故 乡 路 
		心 依 恋 
		",
		pitchTake: 1,
		legato: [1, 1, 1, 1, 1, 0.9, 1, 1, 1, 1, 1, 1, 0.5, 1, 1, 1, 1, 1, 1, 1, 0.5]
		,
		language: \Mandarin
	]}, 
	music:{|p b e|
		{
			e.playbuf
			/3
			=> Pan2.ar(_, 0)
			// => p.synthVTracks.at(e.key).()
		}.play
});
[ "V1L1", "r", Song.quarter.dup(8)].addLine;
P(\keys,music: {|p b e|
	MicroKeys(\vocalLine).synth_(\yowbass);
	MicroKeys(\harp).synth_(\harp, params: [coef: 0.1]);
	MIDIItem("_250119_105441").take(11)
	.filter{|e| e.collect{|i| i.amp.notNil.if{i.amp = i.amp / 8}; i}}
	.recalcSustains
	.play([\vocalLine, \harp], clock: TempoClock.new(0.52 / Song.quarter, queueSize: 2**12  ))
});
P.synthV(\jun, take: \lead,
	pbind: MIDIItem("250122_113217").take(2)
	// .collect({|i x| (x >= 1).if { i.timestamp = i.timestamp - (Song.quarter * 4)  }; i })
	// .from(Song.quarter * 4)
	.synthVPbind,
	params: {|p b| [
	lyrics: "r aaah aah ah - ah",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		/3
		=> Pan2.ar(_,SinOsc.ar(0.12))
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(\jun, take: \lower,
	pbind: 
	[
		dur: 
		MIDIItem("250122_113217").take(2)
		.from(Song.quarter * 4)
		.synthVPbind.patternpairs.asEvent[\dur]
		,
		midinote: 
		"r 5 4 4 5 4  5 4 4 5 4 5 4 4 5 4".dm(Song.keySig,6)
		,
	].p
	,
	params: {|p b| [
	lyrics: "r aaah aah ah - ah",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		/3
		=> Pan2.ar(_,SinOsc.ar(0.12))
		// => p.synthVTracks.at(e.key).()
	}.play
});
~quarter = Song.quarter;
P(\bgVox, music: { |p b e|
MIDIItem("250122_113217").take(2)
//.play(\vocaline)
});
P(\arrangement, music: { |p b e|
	(instrument: \cymbalsDS, amp: 0.02).play;
	[
		instrument: \JWSnare,
		dur: "q e eq q".beats.q(inf) * ~quarter,
		rest: [\r, 1, 1, 1].q(inf),
		amp: 0.25
		// dur: 
	].pp;
	[
		instrument: \bd_808,
		dur: "e eq qq".beats * ~quarter => _.q(inf),
		amp: 0.6

	].pp;
	// ~quarter = 0.46;
	[
		instrument: [\harp, \sawSynth],
		freq: [1, 1, 1, 1, 1, 1, 1, 1, 5, 5, 5, 6, 4, 4, 5, 5, ].df(\c, [3, 4]).q(8),
		dur: ~quarter / 2,
		legato: 0.4,
		att: 0, rel: 0.5,
		amp: [0.05, 0.2]
	].pp;
	[
		freq: [1, 4, 5, 6 ,4, 5, 1, 4, 5, 6 , 4, 5].df(\c, [3]).q(8),
		dur: "eee e ex x e e".beats * ~quarter * 2 => _.q(16),
		amp: 0.3
	].pp;

});
)
(
Song(\Wind, []).current;
Song.quarter = 0.52 / 1;
["line1", "1 4 3 1 3 4 3 2 3 2 -7 -5/f 4 3 1/e- 5 6 5 4 5 4 3 1/d".dm2, "e e e e e x xx x xex e e ee e e e e x xx x xex e e e".beats * Song.quarter * 2].addLine;
P.synthVs(\an, take: [\lead, \dbl], params: {|p b| [
	lyrics: "r 星 光 闪 烁  夜 空  中 - 心 跳 动
 你 我  相 拥  在 这  一 - 刻  爱  永  恒",
	pitchTake: 1,
	language: \Mandarin
] }, music:{|p b e|
	{
		e.playbuf
		/3
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.tune();
P(\arrangement, music: { |p b e|
	(instrument: \cymbalsDS, amp: 0.02).play;
	[
		instrument: \JWSnare,
		dur: "q ee q q".beats.q(inf) * ~quarter,
		// rest: [\r, 1, 1, 1].q(inf),
		rest: [\r, 1, \r, 1].q(inf),
		amp: 0.25
		// dur: 
	].pp;
	[
		instrument: \bd_808,
		dur: "qe e qq".beats * ~quarter => _.q(inf),
		dur: "qee e q e".beats * ~quarter => _.q(inf),
		amp: 0.6

	].pp;
	// ~quarter = 0.46;
	// [
	// 	instrument: [\harp, \sawSynth],
	// 	freq: [1, 1, 1, 1, 1, 1, 1, 1, 5, 5, 5, 6, 4, 4, 5, 5, ].df(\c, [3, 4]).q(8),
	// 	dur: ~quarter / 2,
	// 	legato: 0.4,
	// 	att: 0, rel: 0.5,
	// 	amp: [0.05, 0.2]
	// ].pp;
	[
		freq: [1, 4, 5, 6 ,4, 5, 1, 4, 5, 6 , 4, 5].df(\c, [3]).q(8),
		dur: "eee e ex x e e".beats * ~quarter * 2 => _.q(16),
		amp: 0.3
	]//.pp;

});
P.tune( _ <> [instrument: \sawSynthSustain].pm  );
P(\chords, music: { |p b e|
	[
		freq: [
			[5, 11, 13].df('b-', 4),
			[1, 3, 5].df('f'),
			[-5, 1, 3].df(\a, \minor),
			[1, 4, 5].df('e-'),
			[2, 3, 5, 7 ].df('d', \mixolydian),
			[1, 3, 5, 11 ].df('d', \mixolydian)
		].q,
		instrument: \stringyy,
		wet: 0.1, amp: 0.3,
		dur: 
		"q q q q q q".beats * Song.quarter * 4
		=> _.q
	].ppm
});
P(\bass, music: { |p b e|
	var div = 8;
	[\pluckD, \default].do{ |i x|
		[
			freq: [4, 1, -7, -6.5, -7, 1.5].df(\f, 2).dupEach(8).q,
			freq: [
				4, 4, 4, 4, 4, 4, 5, 6,
				1, 1, 1, 1, 1, 1, 6, 5,
				-7, -7, -7, -7, -7, -7, 5, 4.5,
				-6.5, -6.5, -6.5, -6.5, -6.5, -6.5, 4, 3,
				-7, -7, -7, -7, -7, -7, 1.5, 3,
				-6, -6, -6, -6, -6, -6, 3, 6
			].df(\f, 2).q,
			dur:  Song.quarter * div / 8 / 2 ,
			instrument: i,
			out: Effect.bus({|i| 2 * i/( [4,0.5][x] ) => Pan2.ar(_, x * 2 -1) },)
		].ppm
	}
});
//these are loud
["line2", "1 4 3 1 3 4 3 2 3 2 -7 -5/f 4 3 1/e- 5 6 5 4 5 4 3 1/d".dm2, "e e e e e x xx x xex e e ee e e e e x xx x xex e e e".beats * Song.quarter * 2].addLine;
P.clone("line1", [\TUNE, \bass, \chords]); 
)
MIDIItem("sketch_250128_143314").save
MIDIItem("_250128_144049").save.take(1).play(\harp)
MIDIItem("_250128_144049").play(\harp)
MIDIItem("_250128_145058").play(\harp)
MIDIItem("_250128_145059").play(\harp)
MIDIItem("_250128_145059").gui
MicroKeys(\default).
.monitor
MIDIItem("_250130_150609").play([\harp, \stringyy])
MIDIItem("_250130_150609").play(\harp)
(// third section
/*
梦在风中破碎，
心在雾中徘徊
*/
Song(\Wind, []).current;
Song.quarter = 0.52 * 2;
["G chorus line 1", "3 -7 -6 4 3 4  6 4 2 7 6 5".dm(\g, \mixolydian), "e e x x e qq  e e x x e qq".beats * (Song.quarter ? (0.52 * 2))].addLine;
P.tune();
P.synthV(\jun, take: 
	// \lead_melisma
	\lead
	, params: {|p b| [
	lyrics: " 梦 在 风 中 破 碎 心 在 雾 中 徘 徊 ",
	// lyrics: " 梦 - - 中 - 碎 心 - - 中 - 徊 ",
	pitchTake: 1,
	language: \mandarin,
	phoneset: \xsampa
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
	}.play
});
P(\line, music: { |p b e|
	[
		freq: [\r, 4, 2, -6, -7, 6].df(\g, \mixolydian).q,
		dur: b.parse([5, 1/4, 1/4, 1/4, 1/4, 3]).q ,
		instrument: \stringyy,
		wet: 0,
		amp: 1
	].ppm;
	[
		freq: [\r, 2, 3, -7, 1 ].df(\g, \mixolydian).q,
		dur: b.parse([8, [3, 1/4], 1/4, 1/4, 1/4]).q ,
		instrument: \stringyy,
		wet: 0,
		amp: 1
	].ppm;

});
P(\beat, music: { |p b e|
	[
		dur: "e t t t t eeeee t t t t".beats.q(2) * Song.quarter,
		instrument: 
		// \cp_808
		\MT_808
		,
		rest: [\r, 1, 1, 1, 1].q(4),
		amp: 0.5
	].pp
});
P.synthV(\jun, take: \lower, params: {|p b| [
	filter: (midinote: _ - 12),
	lyrics: " 梦 在 风 中 破 碎 心 在 雾 中 徘 徊 ",
	pitchTake: 2,
	language: \mandarin,
	phoneset: \xsampa
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
	}.play
});
P(\bass, music: { |p b e|
	[
		freq: [11, 7].df(\g,[3, 2], \mixolydian).q(4),
		dur: "qe e".beats.q(4)* Song.quarter
	].pp
});
["repeat", "r","e e x x e qq  e e x x e qq".beats * (Song.quarter)].addLine;
Song.cloneDursAndTempoMap('G chorus line 1');
P.clone('G chorus line 1', [\bass, \line])


)
MIDIItem("_250204_105204").play(\default)//different bridge chords
MIDIItem("_250205_105204").play(\default)//different bridge chords
MIDIItem("_250205_105206").play(\default)//different bridge chords
( // idea
MIDIItem("_250202_105204").play(\default)
MIDIItem("_250203_105204").play(\default)//with falling bassline
)
