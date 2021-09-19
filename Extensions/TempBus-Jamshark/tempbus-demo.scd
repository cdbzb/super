s.boot;

// a kr synth
(
SynthDef(\ctlEnv, { |out, levelScale = 1, levelBias = 0, time = 1, connect = 1|
	var env = \env.kr(Env.newClear(12).asArray);
	var init = In.kr(out, 1);
	var start = Select.kr(connect, [env[0], init]);
	Out.kr(out, EnvGen.kr(env, 1, levelScale, levelBias, time, doneAction: 2));
}).add;
)

// use an envelope to control pan
(
(type: \notemap,
pan: (
	instrument: \ctlEnv,
	env: Env([-1, 1, -1, 1], [1, 1, 1] / 3),
	time: 5,
	addAction: \addBefore
),
sustain: 5
).play;
)

(
(type: \notemap,
pan: (
	instrument: \ctlEnv,
	env: Env([-1, 1, -1, 1], [1, 1, 1] / 3),
	time: 5,
	addAction: \addBefore
),
// ok, 'detunedFreq' is a bit ugly...
detunedFreq: (
	instrument: \ctlEnv,
	env: Env(
		Array.fill(8, { exprand(200, 1000) }),
		Array.fill(7, { rrand(1.0, 5.0) }).normalizeSum,
		\exp
	),
	time: 5,
	addAction: \addBefore
),
sustain: 5,
amp: 0.3
).play;
)

(
(type: \notemap,
pan: Array.fill(2, { |i|
	(
		instrument: \ctlEnv,
		env: Env([-1, 1, -1, 1].rotate(i), [1, 1, 1] / 3),
		time: 5,
		addAction: \addBefore
	)
}),
detunedFreq: Array.fill(2, { (
	instrument: \ctlEnv,
	env: Env(
		Array.fill(8, { exprand(200, 1000) }),
		Array.fill(7, { rrand(1.0, 5.0) }).normalizeSum,
		\exp
	),
	time: 5,
	addAction: \addBefore
) }),
sustain: 5,
amp: 0.3
).play;
)



// demo of modulation
(
SynthDef(\testMod, { |out, gate = 1, amp = 0.1|
	var eg = EnvGen.kr(Env.asr(0.01, 1, 0.1), gate, doneAction: 2);
	var freq = ModControl.kr(\freq, 440, \exp);
	Out.ar(out, (SinOsc.ar(freq) * (eg * amp)).dup);
}).add;

SynthDef(\lfo, { |out, gate = 1, rate = 2|
	FreeSelf.kr(gate <= 0);
	Out.kr(out, LFTri.kr(rate))
}).add;

SynthDef(\ctlEnv, { |out, levelScale = 1, levelBias = 0, time = 1, connect = 1|
	var env = \env.kr(Env.newClear(12).asArray);
	var init = In.kr(out, 1);
	var start = Select.kr(connect, [env[0], init]);
	Out.kr(out, EnvGen.kr(env, 1, levelScale, levelBias, time/*, doneAction: 2*/));
}).add;
)

SynthDescLib.at(\testMod);
Controls:
ControlName  P 0 out control 0.0
ControlName  P 1 gate control 1.0
ControlName  P 2 amp control 0.10000000149012
ControlName  P 3 freq control 440.0
ControlName  P 4 freqMod control 1.0       <<-- added for you
ControlName  P 5 freqModDepth control 2.0  <<-- added for you
   O audio Out out 2

(
(
type: \notemap,
instrument: \testMod,
degree: 2,
amp: 0.5,
freqMod: (instrument: \lfo, addAction: \addBefore),
freqModDepth: (
	instrument: \ctlEnv,
	env: Env([1, 1.5], [2], 4),
	time: 1,
	addAction: \addBefore
),
sustain: 3
).play;
)
