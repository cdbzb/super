(
Song(\mandarin1, []).current;
Song.synthVTracks=EventWithDefault(
	\xuan,
	{
		{|i|
			i / 2 => Pan2.ar(_)
		}
	}
);
// ## Verse 1
// ["城市的燈火漸漸熄滅", "-5 -5 -6 -7 1 1 2 1 3".dm(\c), "q qe e q q qe e q qqqq" => _.beats * 0.6] .addLine;
["城市的燈火漸漸熄滅", "-5 -5 -6 -7 1 1 2 1 3".dm(\c, tuning:\just), "q q ee q q qe e q qqqq" => _.beats * 0.6] .addLine;
P.synthV(\xuan, take: \lead, params: {|p b e| [
	lyrics: 
	"城 市 的 燈 火 漸 漸 熄 滅" 
	,
	language: \Mandarin,
	legato: [1, 1, 1, 1, 1, 1, 1, 1, 0.9],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\line, music: { |p b e|
	[
		freq: [5,5,4,3,3,  3, 4, 3, -5].df(\c, tuning:\just).q,
		dur: b.parse([1, 1, 1, 1, 1, 1, 1, 1, 1]).q, 
		// instrument:\stringyy
		instrument: \sawSynthSustain

	].ppm
});
P(\chords, music: { |p b e|
	[
		freq: [ [1, 3,  5], [1, 4, 6], [-6, 1, 3, 5] ].df(\c, tuning:\just).q,
		dur: b.parse([4, 4, 1]).q,
		instrument: \stringyy,
		amp:0.2
	].ppm
});
// chéng shì de dēng huǒ jiàn jiàn xī miè
// The city lights slowly fade

["寂寞的街道只剩我和月","-5 -5 -6 -7 1 3 4 3 3 2".dm(\c, tuning:\just) ,"q q ee q q qe e q qq qq" => _.beats * 0.6].addLine;
P.synthV(\xuan, take: \lead, params: {|p b e| [
	lyrics: 
	"寂 寞 的 街 道 只 剩 我 和 月" 
	,
	language: \Mandarin,
	legato: [1, 1, 1, 1, 1, 1, 1, 1, 1, 0.9],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\chords, music: { |p b e|
	[
		freq: [ [-7, 3,  5], [-6, 3, 5], [-5, 1,  3], [-5, -7, 2] ].df(\c, tuning:\just).q,
		dur: b.parse([4, 4, 1, 1]).q,
		instrument: \stringyy,
		amp:0.2,
		instrument:\sawSynthSustain, amp:0.05,
	].ppm
});
P(\line, music: { |p b e|
	[
		freq: [5,5,4,3,2,  2, 2,2, 1, -7].df(\c, tuning:\just).q,
		dur: b.parse([1, 1, 1, 1, 1, 1, 1, 1, 1]).q, 
		// instrument:\stringyy
		instrument: \sparkTriangle,
		amp:0.03,
		out: Effect.bus({|i| i * [0.01,1] => FreeVerb.ar(_, 0.3, 1) },)

	].ppm
});
// jì mò de jiē dào zhī shèng wǒ hé yuè
// On the lonely street, just me and the moon remain
["思念像雨滴落在心裡","5 4 3 2 1 4 3 -7 -7 -6".dm(\c) , "q q ee q q qe e q qq qq".beats * 0.6].addLine;
P.synthV(\xuan, take: \lead, 
	// pbind: Song.enlarge(1),
	params: {|p b e| [
	lyrics: 
	"思 念 像 雨 滴 落 在 心 裡 -" 

	,
	legato: [1, 1, 1, 1, 1, 1, 1, 1, 1, 0.9],
	language: \Mandarin,
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\chords, music: { |p b e|
	[
		freq: [ [-7, 2, 5], [-6, 3, 5], [-6, 1,  3], [-5, -7, 2] ].df(\c, tuning:\just).q,
		dur: b.parse([4, 4, 2]).q,
		instrument: \stringyy,
		amp:0.2,
		instrument:\sawSynthSustain, amp:0.05,
	].ppm
});
P(\bassBend, music: { |p b e|
	[
		freq: [5, 6, 13].df(\c, 3).q,
		dur: b.parse([4, 4, 2]).q,
		amp:0.2
	].ppm
});
P(\line, music: { |p b e|
	[
		freq: [3, 2, 1, -7, -5, ].df(\c, tuning:\just).q,
		dur: b.parse([1, 1, 1, 1, 1, 1, 1, 1, 1]).q, 
		// instrument:\stringyy
		instrument: \sawSynthSustain,
		// amp:0.03,
		out: Effect.bus({|i| i * [0.01,1] => FreeVerb.ar(_, 0.3, 1) },)

	].ppm
});
P(\connector, music: { |p b e|
	[
		freq: [\r, -5, 3].df(\d, [5, 6]).q,
		instrument: \sparkTriangle,
		dur: e.bAll.parse([9, 1, 4]).q,
		freqLag:1,
		amp:0.07
	].ppm
});
// sī niàn xiàng yǔ dī luò zài xīn lǐ
// Memories fall like raindrops in my heart 

// ## Chorus
["等待黎明的第一道光","3 3  3 3 4 3 -6 3 -6 3".dm(\d) , "q q q qe e q q q qqqq".beats * 0.6].addLine;
P(\drum, music: { |p b e|
	[
		instrument: \hat_808,
		dur: "q q q q q q q q q q q q".beats.q * 0.6 * 2,
	].pp;
	[
		instrument: \sn_808, 
		dur: "q qq qq qq qq".beats.q * 1.2,
		rest: MuteFirst(),
		amp:0.2, 
		out: Effect.bus({|i| CombN.ar(i, decaytime:5)/2 + i => _.dup }, time:1)
	].pp
});
P(\bassLine, music: { |p b e|
a = MicroKeys(\test);
a.synth_({
	Saw.ar(\freq.kr(400) * (\poly.kr(0) / 127 => _.midiratio))
	* \amp.kr(0.1)
	* Env.asr().kr(2,gate:\gate.kr(1))
}.asDefName, [sustain: 3]);
a.velCurve_(2);
a.tuning_(\just);
// a.activate
m = MIDIItem("bassline_241112_104446");
m
// .record(a)
// .save
.collect{|e| e.latency_(0.2)}
.play(a)

});
P(\bassLine2, music: { |p b e|
var a = MicroKeys(\two);
a.synth_({
	Saw.ar(\freq.kr(400) * (\poly.kr(0) / 127 => _.midiratio))
	* \amp.kr(0.1)
	* Env.asr().kr(2,gate:\gate.kr(1))
	=> MoogFF.ar(_, 4000)
	=> Pan2.ar(_, 0)
}.asDefName, [sustain: 3]);
a.velCurve_(2);
a.tuning_(\just);
// a.activate
m = MIDIItem("bassline_241112_104447");
m
// .record(a)
// .save
.collect{|e| e.latency_(0.2)}
.play(a)

});
P(\chord, music: { |p b e|
	(
		instrument:\stringyy, 
		freq: [1, 3, 5, 7].df(\d, [5, 6], tuning:\just),
		dur: 3, 
		amp: 0.22,

	).play
});
P(\bassnote, music: { |p b e|
	(
		freq: 1.df(\d, [3,4]),
		out: Effect.bus({|i| DWGReverbC1C3.ar(i) },),
		instrument:\sawSynthSustain,
		dur:2
	).play
});
P(\cymbal, music: { |p b e|
	(
		instrument: \cymbalsDS,
		att:0.1, amp:0.02
	).play
});
P.synthVs(\xuan, take: [ \lead, \dbl ], params: {|p b e| [
	lyrics: 
	"等 待 黎 明 的 第 一 道 光 -" 
	,
	language: \Mandarin,
	pitchTake: [ 1, 3 ]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\connector, music: { |p b e|
	[
		freq: [\r, -6, 4].df(\d, [5, 6]).q,
		instrument: \sparkTriangle,
		dur: e.bAll.parse([8, 1, 4]).q,
		freqLag:1,
		amp:0.07
	].ppm
});
// děng dài lí míng de dì yī dào guāng
// Waiting for the first ray of dawn

["帶我找到回家的方向","4 4 4 4 5 4 3 5 4 3 2".dm(\d) , "q q q qe e q q q qqqq".beats * 0.6].addLine;
P(\drum, music: { |p b e|
	[
		instrument: \hat_808,
		dur: "q q q q q q q q q q q q".beats.q * 0.6 * 2,
	].pp;
	[
		instrument: \sn_808, 
		dur: "q qq qq qq qq".beats.q * 1.2,
		rest: MuteFirst(),
		amp:0.2,
		out: Effect.bus({|i| CombN.ar(i, decaytime:5)/2 + i => _.dup }, time:1)
	].pp
});
P(\chord, music: { |p b e|
	(
		instrument:\stringyy, 
		freq: [1, 3, 5, 7].df(\g, [5, 6], tuning:\just),
		dur: 3, 
		amp: 0.22
	).play
});
P(\bassnote, music: { |p b e|
	(
		freq: [  2 ].df(\d, [3,4]),
		out: Effect.bus({|i| DWGReverbC1C3.ar(i) },),
		instrument:\sawSynthSustain,
		dur:2
	).play
});
P.synthVs(\xuan, take: [ \lead, \dbl ], params: {|p b e| [
	lyrics: 
	"帶 我 找 到 回 家 的 方 向" 
	,
	language: \Mandarin,
	pitchTake: [ 1, 3 ]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
// dài wǒ zhǎo dào huí jiā de fāng xiàng
// To guide me home

["每一步都是新的希望", "6.5 6 4 1 -5.5 4 3 4 3 -7".dm(\c) ,"q q q q q qe e q qq qq".beats * 0.6].addLine;
P.synthVs(\xuan, take: [\lead, \dbl], params: {|p b| [
	lyrics: "每 一 步 都 是 新 的 希 望 -",
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
// měi yī bù dōu shì xīn de xī wàng
// Each step brings new hope
["verse 2", "-5 -5 -6 -7 1 1 2 1 3".dm(\c, tuning:\just), "q q ee q q qe e q qqqq" => _.beats * 0.6] .addLine;
P.synthV(\xuan, take: \lead, params: {|p b e| [
	lyrics: 
	"城 市 的 燈 火 漸 漸 熄 滅" 
	,
	language: \Mandarin,
	legato: [1, 1, 1, 1, 1, 1, 1, 1, 0.9],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\line, music: { |p b e|
	[
		freq: [5,5,4,3,3,  3, 4, 3, -5].df(\c, tuning:\just).q,
		dur: b.parse([1, 1, 1, 1, 1, 1, 1, 1, 1]).q, 
		// instrument:\stringyy
		instrument: \sawSynthSustain

	].ppm
});
P(\chords, music: { |p b e|
	[
		freq: [ [1, 3,  5], [1, 4, 6], [-6, 1, 3, 5] ].df(\c, tuning:\just).q,
		dur: b.parse([4, 4, 1]).q,
		instrument: \stringyy,
		amp:0.2
	].ppm
});
// chéng shì de dēng huǒ jiàn jiàn xī miè
// The city lights slowly fade
["寂寞的街道只剩我和月Two","-5 -5 -6 -7 1 3 4 3 3 2".dm(\c, tuning:\just) ,"q q ee q q qe e q qq qq" => _.beats * 0.6].addLine;
P.synthV(\xuan, take: \lead, params: {|p b e| [
	lyrics: 
	"寂 寞 的 街 道 只 剩 我 和 月" 
	,
	language: \Mandarin,
	legato: [1, 1, 1, 1, 1, 1, 1, 1, 1, 0.9],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\chords, music: { |p b e|
	[
		freq: [ [-7, 3,  5], [-6, 3, 5], [-5, 1,  3], [-5, -7, 2] ].df(\c, tuning:\just).q,
		dur: b.parse([4, 4, 1, 1]).q,
		instrument: \stringyy,
		amp:0.2,
		instrument:\sawSynthSustain, amp:0.05,
	].ppm
});
P(\line, music: { |p b e|
	[
		freq: [5,5,4,3,2,  2, 2,2, 1, -7].df(\c, tuning:\just).q,
		dur: b.parse([1, 1, 1, 1, 1, 1, 1, 1, 1]).q, 
		// instrument:\stringyy
		instrument: \sparkTriangle,
		amp:0.03,
		out: Effect.bus({|i| i * [0.01,1] => FreeVerb.ar(_, 0.3, 1) },)

	].ppm
});
// jì mò de jiē dào zhī shèng wǒ hé yuè
// On the lonely street, just me and the moon remain

["思念像雨滴落在心裡Two","5 4 3 2 1 4 3 -7 -7 -6".dm(\c) , "q q ee q q qe e q qq qq".beats * 0.6].addLine;
P.synthV(\xuan, take: \lead, 
	// pbind: Song.enlarge(1),
	params: {|p b e| [
	lyrics: 
	"思 念 像 雨 滴 落 在 心 裡 -" 

	,
	legato: [1, 1, 1, 1, 1, 1, 1, 1, 1, 0.9],
	language: \Mandarin,
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\chords, music: { |p b e|
	[
		freq: [ [-7, 2, 5], [-6, 3, 5], [-6, 1,  3], [-5, -7, 2] ].df(\c, tuning:\just).q,
		dur: b.parse([4, 4, 2]).q,
		instrument: \stringyy,
		amp:0.2,
		instrument:\sawSynthSustain, amp:0.05,
	].ppm
});
P(\bassBend, music: { |p b e|
	[
		freq: [5, 6, 13].df(\c, 3).q,
		dur: b.parse([4, 4, 2]).q,
		amp:0.2
	].ppm
});
P(\line, music: { |p b e|
	[
		freq: [3, 2, 1, -7, -5, ].df(\c, tuning:\just).q,
		dur: b.parse([1, 1, 1, 1, 1, 1, 1, 1, 1]).q, 
		// instrument:\stringyy
		instrument: \sawSynthSustain,
		// amp:0.03,
		out: Effect.bus({|i| i * [0.01,1] => FreeVerb.ar(_, 0.3, 1) },)

	].ppm
});
P(\connector, music: { |p b e|
	[
		freq: [\r, -5, 3].df(\d, [5, 6]).q,
		instrument: \sparkTriangle,
		dur: e.bAll.parse([9, 1, 4]).q,
		freqLag:1,
		amp:0.07
	].ppm
});
// sī niàn xiàng yǔ dī luò zài xīn lǐ
// Memories fall like raindrops in my heart 

// ## Chorus
)

