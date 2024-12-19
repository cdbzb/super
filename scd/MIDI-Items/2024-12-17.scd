(
~standardControls = {|e mk| e * (\poly.kr() / 127+ CC.bend(mk: \pluck, rawScale: 16384).bus.kr => _.midiratio)};
MicroKeys(\pluck);
MicroKeys(\pluck).synth = { |gate=1 out=0 freq = 400|
	var decaytime = \decaytime.kr(10);
	var in=PinkNoise.ar(1);
	var sig=Pluck.ar(
		in: in,
		gate: gate,
		maxdelaytime: 0.02,
		// delaytime: freq * (\poly.kr() / 127 + CC.bend(mk:MicroKeys(\pluck), rawScale: 16384).bus.kr => _.midiratio)   + [0.5, 0, -0.1]=> _.reciprocal,
		delaytime: ~standardControls.(freq, \pluck) =>  _.reciprocal,
		decaytime: decaytime,
		coef:  CC(24, mk: \pluck).bus.kr + [0, 0.1, 0.2],
	)
	=> Splay.ar(_)
	* \amp.kr(0.1) * 10
	* Env.asr().kr(2,gate:gate)
	* EnvGen.cutoff(decaytime - 0.1, 0.1)
	=> LeakDC.ar(_);
	Out.ar(out,sig);
}.asDefName;
// MicroKeys(\pluck).record;
// MIDIItem("241217_102915").take(1).start_(127.5).play(\pluck);
// MicroKeys(\chordOd).synth_(\sawSynth).record;
)
// MIDIItem("241217_094128").take(7).play(\pluck)
MIDIItem("241217_102915").take(8).start_(70).play(\pluck) // Rocking between c and c#
MIDIItem("241217_120932").take(0).fromNoteTo(14, 50).play(\pluck) //nice descending 7ths figure
MIDIItem("241217_132422").take(1).play(\pluck) //effort to integrate to two
// TempoClock.default = TempoClock.new(queuSize: 2**24)
)

(
var dur = 0.43;
[
	[
		degree: [1, 5, 6, 9, 13, 9, 6, 5] - 1 => _.q(inf),
		root: -3,
		mtranspose: Pseries(0, -1).dupEach(8),
		scale: Scale.aeolian,
		dur: dur,
		legato: [7, 1, 5, 1, 1, 1, 1, 1].q(inf)
	].p,
	[
		degree: [14, 13].q(inf),
		root: -3,
		mtranspose: Pseries(0, -1).dupEach(2),
		scale: Scale.aeolian,
		dur: [1, 7].q(inf) * dur
	].p.trace
] => {|array|
	Ptpar([
		dur , array[0],
		0, array[1]
	])
} => _.play

)
