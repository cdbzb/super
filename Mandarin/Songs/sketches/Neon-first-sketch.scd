(
~lyrics = [
"(boom) Néng hóng dēng zhào liàng wǒ de liǎn", "\r 霓 虹 灯 照 亮 我 的 脸",
"(boom) Shǒu jī píng mù yòu àn yòu lěng", "r 手 机 屏 幕 又 暗 又 冷",
"(boom) Wàn jiā dēng huǒ xiàng xīng xīng   gǎn jué hǎo gū jì", "r 万 家 灯 火 像 星 星    但 我 依 然 感 觉 好 孤 寂 ",
"(boom) Huá dòng píng mù xún zhǎo gòng míng", "r 滑 动 屏 幕 寻 找 共 - 鸣",
"ming Wǒ de xīn què màn màn lěng qīng", "r 数 据 海 洋 中 迷 失 自 己"
].clump(2).flop.collect{|i| i.q.asStream };
)

(
Song(
	// \neon
	\neon2 //faster
	, []).current;
Song.synthVTracks=EventWithDefault(\default, {{|i| i/4 }});
["(boom) Néng hóng dēng zhào liàng wǒ de liǎn", "1 1 -7 1 3 2 1 2 -6".dm(\d)].addLine;
Song.setTempoMap('Néng', "e x xe x xe x xe x xqq");
P.synthV(\an, take: \lead, params: {|p b| [
	lyrics: "\r 霓 虹 灯 照 亮 我 的 脸",
	pitchTake: 1,
	language: \Mandarin,
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
// P.tune();
P(\bass, music: { |p b e|
	[
		freq: [11, 7, 6, 5, 4.5].df(\d,2).dupEach(4).q,
		dur: "x*16".beats.warpTo(e.tempoMap.quantizeDft(0.5)).q,
		instrument: [\harp, \sawSynth ], 
		coef:0.8, amp:[0.03, 0.1],
		rel:0, att:0.1
	].pp
});
["la la", "1 -7".dm(\d)].addLine;
P.tune();
P(\organ, music: { |p b e|
	[
		freq: [
			[1, -7,  1],
			[-5, -5, -6]
		].flop.df(\d).q,
		dur: e.bAll[ ..2 ].q,
		instrument:\stringyy,
		mix:0
	].ppm
});
["(boom) Shǒu jī píng mù yòu àn yòu lěng", "-1 3 2 3 6 4 3 2 5".dm(\d)].addLine;
Song.setTempoMap('Shǒu', "e x xe x xe x xe x xqq");
P(\bass, music: { |p b e|
[
	freq: [11, 7, 4, 5, 4.5].df(\d,2,\mixolydian).dupEach(4).q,
	dur: "x*16".beats.warpTo(e.tempoMap.quantizeDft(0.5)).q,
	instrument: [\harp, \sawSynth ], 
	coef:0.8, amp:[0.03, 0.1],
	rel:0, att:0.1
].pp
});
P.synthV(\an, take: \lead, params: {|p b| [
	lyrics: "r 手 机 屏 幕 又 暗 又 冷",
	pitchTake: 1, 
	language: \Mandarin
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
["(boom) Wàn jiā dēng huǒ xiàng xīng xīng   gǎn jué hǎo gū jì", "-1 5 2 3 1/f 7.5 3 4 5 11 1 3 4/b/minor/4 4 3 -5/d".dm2].addLine;
Song.setTempoMap('Wàn', 
	"e x xe x xe x xe x xe x xe x xeq e ee e"
	// "Q E Q E Q E Q E Q E Q E Q"
	// "x x x x x x x x x x x x x x "
	
	
);
"qqqq".beats.warpTo(Song.tempoMap[0])/4=>_.reciprocal * 60;
P.synthV(\an, take: \lead, params: {|p b| [
	lyrics: "r 万 家 灯 火 像 星 星    但 我 依 然 感 觉 好 孤 寂 ",
	pitchTake: 1,
	language: \Mandarin
] }, music:{|p b e|
	{
		e.playbuf
		=> {|i| CombN.ar(i, 0.4, 0.4)/3 + i}
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\bass, music: { |p b e|
	[
		freq: [11, 7, 6, 5].df('f',2,\mixolydian).dupEach(2).q,
		dur: "e*16".beats.warpTo(e.tempoMap
			.quantizeWindow(1, 4)
		).q,
		instrument: [\harp, \sawSynth ], 
		coef:0.8, amp:[0.03, 0.1],
		out: Effect.bus({|i| i + DelayN.ar(
			i, 
			"e".beats.warpTo(e.tempoMap) /2, 
			"e".beats.warpTo(e.tempoMap) /2, 
		)}),
		rel:0, att:0.1
	].pp
});
	 ["(boom) Huá dòng píng mù xún zhǎo gòng míng", [\r, 3, 5, 11, 6, 4, 6, 14, 13].dm(\d)].addLine;
	 // Song.durs.filter('Huá', {|i| i * 2 /53 * 44});
	 // Song.setTempoMap('Huá', "q q q q q q q e e");
P(\bass, music: { |p b e|
	[
		freq: [11, 7, 6, 5].df('f',2,\mixolydian).dupEach(4).q,
		dur: "x*16".beats.warpTo(e.tempoMap
			.quantizeWindow(0.5)
		).q,
	].pp
});
	 P(\bass, music: { |p b e|
	 	[
	 		dur: "x*32".beats.warpTo(e.tempoMap).q,
			freq: "11 7 6 5 4 3 2 1".df(\d, 2).dupEach(4).q,
		instrument: [\harp, \sawSynth ], 
		coef:0.8, amp:[0.03, 0.1],
		rel:0, att:0.1

	 	].pp
	 });
	 P.synthVs(\an, take: [ \lead, \dbl ], 
		 pbind: Song.enlarge(1),
		 params: {|p b| [
			 lyrics: "r 滑 动 屏 幕 寻 找 共 - 鸣",
			 pitchTake: [ 1, 3 ]
		 ]}, music:{|p b e|
			 {
				 e.playbuf
				 // => p.synthVTracks.at(e.key).()
				 /4
			 }.play
	 });
	 ["ming Wǒ de xīn què màn màn lěng qīng","13 15 14 13 12 11 5 4 3".dm(\d)].addLine;
	 // Song.durs.filter('xīn ', {|i| i * 2 /53 * 44});
	 P.synthVs(\an, take: [ \lead, \dbl ], params: {|p b| [
	 	lyrics: "r 数 据 海 洋 中 迷 失 自 己",
	 	pitchTake: 1
	 ] }, music:{|p b e|
	 	{
	 		e.playbuf
			/4
	 		// => p.synthVTracks.at(e.key).()
	 	}.play
	 });
	 ["chorus repeat", [\r, 3, 5, 11, 6, 4, 6, 14, 13].dm(\d)].addLine;
	 Song.cloneDursAndTempoMap("(boom) Huá dòng píng mù xún zhǎo gòng míng");
	 // Song.durs.filter('Huá', {|i| i * 2 /53 * 44});
	 // Song.setTempoMap('Huá', "q q q q q q q e e");
P(\bass, music: { |p b e|
	[
		freq: [11, 7, 6, 5].df('f',2,\mixolydian).dupEach(4).q,
		dur: "x*16".beats.warpTo(e.tempoMap
			.quantizeWindow(0.5)
		).q,
	].pp
});
	 P(\bass, music: { |p b e|
	 	[
	 		dur: "x*32".beats.warpTo(e.tempoMap).q,
			freq: "11 7 6 5 4 3 2 1".df(\d, 2).dupEach(4).q,
		instrument: [\harp, \sawSynth ], 
		coef:0.8, amp:[0.03, 0.1],
		rel:0, att:0.1

	 	].pp
	 });
	 P.synthVs(\an, take: [ \lead, \dbl ], 
		 pbind: Song.enlarge(1),
		 params: {|p b| [
			 lyrics: "r 滑 动 屏 幕 寻 找 共 - 鸣",
			 pitchTake: [ 2, 4 ]
		 ]}, music:{|p b e|
			 {
				 e.playbuf
				 // => p.synthVTracks.at(e.key).()
				 /4
			 }.play
	 });
	 ["ming Wǒ de xīn què màn màn lěng qīng","13 15 14 13 12 11 5 4 3".dm(\d)].addLine;
	 // Song.durs.filter('xīn ', {|i| i * 2 /53 * 44});
	 P.synthVs(\an, take: [ \lead, \dbl ], params: {|p b| [
	 	lyrics: "r 数 据 海 洋 中 迷 失 自 己",
	 	pitchTake: 1
	 ] }, music:{|p b e|
	 	{
	 		e.playbuf
			/4
	 		// => p.synthVTracks.at(e.key).()
	 	}.play
	 });
 )
 )
 (
 Song(\neonQuarters,[]).current;

~lyrics = [
"(boom) Néng hóng dēng zhào liàng wǒ de liǎn", "\r 霓 虹 灯 照 亮 我 的 脸",
"(boom) Shǒu jī píng mù yòu àn yòu lěng", "r 手 机 屏 幕 又 暗 又 冷",
"(boom) Wàn jiā dēng huǒ xiàng xīng xīng   gǎn jué hǎo gū jì", "r 万 家 灯 火 像 星 星    但 我 依 然 感 觉 好 孤 寂 ",
"(boom) Huá dòng píng mù xún zhǎo gòng míng", "r 滑 动 屏 幕 寻 找 共 - 鸣",
"ming Wǒ de xīn què màn màn lěng qīng", "r 数 据 海 洋 中 迷 失 自 己"
].clump(2).flop.collect{|i| i.q.asStream };

["(boom) Néng hóng dēng zhào liàng wǒ de liǎn", "1 3 -7 1 2 3 2".dm(\B), "e e e e e e ee".beats  ].addLine;
P.synthV(\an, take: \lead, params: {|p b| [
	lyrics: " 霓 虹 灯 照 亮 我 的 脸",
	pitchTake: 1 ,
	language: \Mandarin
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
	}.play
} );
P(\arp, music: { |p b e|
	[
		freq: [1, 11].df(\B).dupEach(2).q(inf),
		dur: 0.125
	].pp
});
P(\sus, music: { |p b e|
	[
		freq: [
			[4, 3],
			[1, 1]
		].df(\B).flop.q,
		dur: b.parse()
	].ppm
});
P(\bass, music: { |p b e|
	[
		freq: [11, 7, 4, 5, 5, 5, 5,  ].df(\B, 3).dupEach(4).q,
		dur: 1/4,
		instrument: [\sawSynth, \NC_DistortedGuitar ]
	].pp
});
 )
