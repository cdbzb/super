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
MIDIItem("250121_120748").take(2).play(\vocalLine);
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
(
/*
时代的风吹过长安街
人群像落叶随风飘
年轻的眼睛寻找答案
但真相藏在雾里逃
*/
Song(\Wind, []).current;

Song.key=\c;
Song.quarter = 0.52;

[ "V1L1", "r", Song.quarter.dup(8)].addLine;
P(\keys,music: {|p b e|
	MicroKeys(\vocalLine).synth_(\sawSynthSustain);
	MIDIItem("_250119_105441").take(11).fromNoteTo(0, 100).filter{|e| e.collect{|i| i.amp.notNil.if{i.amp = i.amp / 3}}}.play('vocalLine', clock: TempoClock.new(0.52 / ~quarter, queueSize: 2**12  ))
});
P.synthV(\an, take: \lead, pbind: 
	MIDIItem("_250119_105441").take(11).synthVPbind
	,
// need to make Legato
	params: {|p b| [
		lyrics: " r 时 代 的 风 吹 过 长 安 
		人 群 像 落 叶 随 风 飘 
		年  轻 的 眼 睛 寻 找 答 案
		但 真 相 藏 在 雾 里 逃
		时 代 的 风 吹 过 长 安
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
~quarter = Song.quarter;
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
