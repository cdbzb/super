(
MicroKeys(\vocalLine).synth_(\sawSynthSustain)
// .monitor
;
MIDIItem("_250119_101434").take(1).play('vocalLine') //2nd or third time aroung has a nice transition
MIDIItem("_250119_102256").play('vocalLine')
MIDIItem("_250119_103705").play('vocalLine')
// .record('vocalLine')
)
(
~quarter = 0.52;
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
