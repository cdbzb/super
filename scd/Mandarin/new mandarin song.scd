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
		instrument: \sawSynthSustain,
		pulse:0.3

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
		amp:0.045,
		out: Effect.bus({|i| i * [0.01,1] => FreeVerb.ar(_, 0.3, 1) },)

	] =>
	{|i|
		i ++ [instrument: \sparkTriangle] => _.ppm;
		i ++ [
			instrument: \harpS,
			amp:0.04,
			rest: [1, 1, 1, 1, 1, \r, \r, \r, 1].q,
			coef:0.3,
			out: Effect.bus({|i| Pan2.ar(i, Line.kr(1, -1, b.sum)) },)
		] => _.p => _.trace => _.play;
	}
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
		amp:0.2,
		instrument: \default
	].ppm
});
P(\line, music: { |p b e|
	[
		freq: [3, 2, 1, -7, -5, ].df(\c, tuning:\just).q,
		dur: b.parse([1, 1, 1, 1, 1, 1, 1, 1, 1]).q, 
		// instrument:\stringyy
		instrument: \sawSynthSustain,
		// amp:0.03,
		out: Effect.bus({|i| i * [0.01,1] => FreeVerb.ar(_, 0.3, 1) },),
		pulse: 0.3

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
["等待黎明的第一道光","3 3  3 3 4 3 -5 3 -6 3".dm(\d) , "q q q qe e q q q qqqq".beats * 0.6].addLine;
P(\drum, music: { |p b e|
	[
		instrument: \hat_808,
		dur: "q q q q q q q q q q q q".beats.q * 0.6 * 2,
	].pp;
	[
		instrument: \sn_808, amp:0.2, 
		dur: "q qq qq qq qq qq qq qq q".beats.q * 1.2,
		rest: MuteFirst(),
		instrument: \JWSnare, amp:0.15,
		out: Effect.bus({|i| CombN.ar(i,delaytime: 0.202, decaytime:5)/2 + i => _.dup }, time:1)
	].pp
});
P(\liveDrum, music: {|p b e|
	var echo = Effect.bus({|i| CombN.ar(i, decaytime:5)/4 + i => _.dup }, time:1);
	MicroKeys(\sn).synth_(\sn_808).range_([60, 48]);
	MicroKeys(\bd).synth_(\bd_808).range_([62,64]);
	MicroKeys(\hat).synth_(\hat_808).range_([67,69]);
	MIDIItem("241215_154339_traps").record([\sn, \bd, \hat]);
});
P(\stringz, lag: 0.2, music: { |p b e|
	var m;
	c = MicroKeys(\stringz)	;
	c.synth_(\stringyy);
	c.add(\quiet, {|e|  e.vel = e.vel/ 100}, addAction: \addBefore, target: \synth);
	m = MIDIItem("stringz_241114_124431");
	m
	// .record(c)
	// .save
	.player
	.play(c, 
		log:[\noteOn]
	)
});
P(\testtt,lag:0.2, music: { |p b e|
	var c = MicroKeys(\sn_808)	;
	var m;
	c.synth_(\default, [\out, Effect.bus({|i| FreeVerb.ar(i, 1, 1) /5 },)]);
	c.add(\quiet, {|e| e.vel = e.vel/ 100}, addAction: \addBefore, target: \synth);

	m = MIDIItem("241114_124432");
	m
	// .record(c)
	.play(c)
});
P(\bassLine, music: { |p b e|
	
var a = MicroKeys(\test);
a.synth_({
	var m;
	Saw.ar(\freq.kr(400) * (\poly.kr(0) / 1227 => _.midiratio))
	* \amp.kr(0.1)
	/4
	/2
	* Env.asr().kr(2,gate:\gate.kr(1))
}.asDefName, [sustain: 3]);
a.velCurve_(2);
a.tuning_(\just);
// a.activate
m = MIDIItem("bassline_241112_104446");

// m = m.player
m.filter({|e| e.collect{|i| i.parent_(nil)}})
// .record(a)

// .filterOnlyMidicmd(\noteOn,{|e x| (x == 5).if{ e.amp_(0.3) }})
// .filterOnlyMidicmd(\noteOn,{|e x| (x == 28).if{ e.amp_(0.25) }})
// .filterOnlyMidicmd(\noteOn,{|e x| (x == 35).if{ e.amp_(0.3) }})
// .filterOnlyMidicmd(\noteOn,{|e x| (x == 40).if{ e.amp_(0.28) }})
// .filterOnlyMidicmd(\noteOn,{|e x| (x == 48).if{ e.amp_(0.28) }})
// .filterOnlyMidicmd(\noteOn,{|e x| ((54 >= x) and: (x >= 49)).if{ e.amp_(e.amp+0.1) }})
// .quantize(
// 	"q e e q e e q e e q e e q e e q e e e e e e e e e e e ".beats * 1.2,
// 	{ ~e.timestamp_(~env[~e.timestamp] + 0.02);  },
// 	{ |notes| notes},
// 	false,
// 	// recalcSustains: true
// )

.collect{|e| e.latency_(0.2)}
.play(a)

});
P(\bassLine2, music: { |p b e|
var a = MicroKeys(\two);
var m;
a.synth_({
	Saw.ar(\freq.kr(400) * (\poly.kr(0) / 127 => _.midiratio) + \detune.kr(0))
	* \amp.kr(0.1)
	* Env.asr().kr(2,gate:\gate.kr(1))
	=> MoogFF.ar(_, \ffreq.kr(4000))
	=> Pan2.ar(_, 0)
}.asDefName, [ffreq: [ 4000, 4000 ], pan:[-1,1], detune:[-0.81,1]]);
a.velCurve_(2);
a.tuning_(\just);
// a.activate
m = MIDIItem("bassline_241112_104447");

// .record(a)
// .save
m.filter({|e| e.collect{|i| i.parent_(nil)}})
// .recalcSustains
.collect{|e| e.latency_(0.2)}
.play(\two, log:[\noteOn], overdub:false)

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
	lyrics: "等 待 黎 明 的 第 一 道 光 -" ,
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

["帶我找到回家的方向","4 4 4 4 5 4 3 5 4 -5 3 2 -6".dm(\d) , "q q q qe e q q q qq qq".beats * 0.6].addLine;
// dài wǒ zhǎo dào huí jiā de fāng xiàng
// To guide me home
P(\drum, music: { |p b e|
	[
		instrument: \hat_808,
		dur: "q q q q q q q q q q q q".beats.q * 0.6 * 2,
	].pp;
	[
		instrument: \sn_808, amp:0.2,
		dur: "q qq qq qq qq qq q".beats.q * 1.2,
		rest: MuteFirst(),
		instrument: \JWSnare, amp:0.15,
		out: Effect.bus({|i| CombN.ar(i, decaytime:4)/2 + i => _.dup }, time:1)
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
	"帶 我 找 到 回 家 的 方 向 -" 
	,
	language: \Mandarin,
	pitchTake: [ 1, 3 ]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\monoDouble,lag: 0.2, music: { |p b e|
	var m;
	var a = MicroKeys.mono(\lead);

	a.synth_({
		SinOsc.ar( \num.kr(40).midicps.lag(0.3) * (\poly.kr / 127 ).midiratio, 0, 0.05 )
		* Env.asr().kr(2,gate:\gate.kr(1))

		* 3
		=> CrossoverDistortion.ar(_)
		// => _.distort
		/4
		=> FreeVerb.ar(_, 0.2, 1)
		=> Pan2.ar(_, 1)
	}.asDefName);
	// a.activate
	m = MIDIItem("line_241114_095359");
	// m.player.midiEvents.select{|i| i.midicmd ==\noteOn}[3].play
	m
	// m.player.midiEvents.collect(_.type)
	// .record(a)
	.play(a)

	
	
});
["每一步都是新的希望", "6.5 6 4 1 -5.5 4 3 4 3 -7".dm(\c) ,"q q q q q qe e q qq qq".beats * 0.6].addLine;
// měi yī bù dōu shì xīn de xī wàng
// Each step brings new hope
P.synthVs(\feng, take: [ \hm1, \hm2 ],
	pbind: [[ 1, 1, 1 ], [4, 4, 5]].collect{|i| {|p b| [
		midinote: i.dm(\c, 6, ),
		dur: b.parse([4, 4, 2]).q
	].p } },
	params: {|p b| [
	lyrics: "each step hope r",
	pitchTake: [ 1, 3 ],
	// pitchDelta: [Env([0,0],b.sum), Env([0, 0, 200, 200], b.parse([3,1, 2]), -3) ]
] }, music:{|p b e|
	{
		e.playbuf
		/3
		// => PitchShift.ar(_, pitchRatio:)
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.synthVs(\xuan, take: [\lead, \dbl], params: {|p b| [
	lyrics: "每 一 步 都 是 新 的 希 望 -",
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()

	}.play
});
["connector", "-5 -5 -6 -7 ".dm(\c, tuning:\just), "q q ee q " => _.beats * 0.6] .addLine;
P(\line, music: { |p b e|
	[
		freq: [5,5,4,3,2,  -5, 4, 3, -5].df(\c, tuning:\just).q,
		dur: e.bAll.parse([1, 1, 1, 1,5, 1 ]).q,
		pulse:0.3,

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
// ["城市的燈火漸漸熄滅", "-5 -5 -6 -7 1 1 2 1 3".dm(\c, tuning:\just), "q q ee q q qe e q qqqq" => _.beats * 0.6] .addLine;
["Verse 2","-5 -5 -6 -7 1 1 2 1 3".dm(\c, tuning:\just)].addLine;
Song.cloneDursAndTempoMap("城市的燈火漸漸熄滅");
P.synthV(\xuan, take: \lead, params: {|p b e| [
	lyrics: 
	// "城 市 的 燈 火 漸 漸 熄 滅" 
	"霓 虹 的 倒 影 慢 慢 消 散"
	,
	language: \Mandarin,
	legato: [1, 1, 1, 1, 1, 1, 1, 1, 0.9],
	pitchTake: 2
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
		instrument: \sawSynthSustain,
		pulse:0.3

	]//.ppm
});
P(\chords, music: { |p b e|
	[
		freq: [ [1, 3,  5], [1, 4, 6], [-6, 1, 3, 5] ].df(\c, tuning:\just).q,
		dur: b.parse([4, 4, 1]).q,
		instrument: \stringyy,
		amp:0.2
	].ppm
});
["V2Two","-5 -5 -6 -7 1 3 4 3 3 2".dm(\c, tuning:\just) ,"q q ee q q qe e q qq qq" => _.beats * 0.6].addLine;
	P.synthV(\feng, take: \lead, 
		pbind: {|p b| 
			var a = Pbrown(1, 7,1).asStream;
			[
				dur: (1/8*0.6) ! 32,
				midinote: Array.fill(32, {a.next} ).dm(\c)
			].p
		},
		params: {|p b| [
		lyrics: "aah  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> {|i| CombN.ar(i, 0.4,0.4,4)/3 + i}
			// => p.synthVTracks.at(e.key).()
			/10
			=> Pan2.ar(_,1)
		}.play
	});
	P.synthV(\feng, take: \lead2, 
		pbind: {|p b| 
			var a = Pbrown(1, 7,1).asStream;
			[
				dur: (1/6*0.6) ! 72,
				midinote: Array.fill(72, {a.next} ).dm(\c, 6)
			].p
		},
		params: {|p b| [
		lyrics: "aah  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> {|i| CombN.ar(i, 0.4,0.4,4)/3 + i}
			/10
			=> Pan2.ar(_,0)
			// => p.synthVTracks.at(e.key).()
		}.play
	});
	P.synthV(\feng, take: \lead3, 
		pbind: {|p b| 
			var a = Pbrown(1, 7,1).asStream;
			[
				dur: (1/4*0.6) ! 32,
				midinote: Array.fill(32, {a.next} ).dm(\c)
			].p
		},
		params: {|p b| [
		lyrics: "aah  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> {|i| CombN.ar(i, 0.4,0.4,4)/3 + i}
			/10
			// => p.synthVTracks.at(e.key).()
		}.play
	});
P.synthV(\xuan, take: \lead, params: {|p b e| [
	lyrics: 
	// "寂 寞 的 街 道 只 剩 我 和 月" 
	"遠 處 的 呢 喃 在 耳 邊 迴 盪 -"
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
	// "思 念 像 雨 滴 落 在 心 裡 -" 
	"回 憶 像 煙 霧 飄 在 夜 裡 - "
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
		amp:0.2,
		instrument: \default
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

