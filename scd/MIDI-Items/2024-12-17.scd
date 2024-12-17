CC(\bend).bus.get.postln; CC(\bend).val.postln
CC(1).bus.get
(
~standardControls = {|e mk| e * (\poly.kr() / 127+ CC.bend(mk: mk, rawScale: 16384).bus.kr => _.midiratio)};
MicroKeys(\pluck);
MicroKeys(\pluck).synth = { |gate=1 out=0 freq = 400|
	var decaytime = \decaytime.kr(10);
	var in=PinkNoise.ar(1);
	var sig=Pluck.ar(
		in: in,
		gate: gate,
		maxdelaytime: 0.02,
		// delaytime: freq * (\poly.kr() / 127 + CC.bend(mk:MicroKeys(\pluck), rawScale: 16384).bus.kr => _.midiratio)   + [0.5, 0, -0.1]=> _.reciprocal,
		delaytime: ~standardControls.(freq, MicroKeys(\pluck)) =>  _.reciprocal,
		decaytime: decaytime,
		coef:  CC(24, mk: MicroKeys(\pluck)).bus.kr + [0, 0.1, 0.2],
	)
	=> Splay.ar(_)
	* \amp.kr(0.1) * 10
	* Env.asr().kr(2,gate:gate)
	* EnvGen.cutoff(decaytime - 0.1, 0.1)
	=> LeakDC.ar(_);
	Out.ar(out,sig);
}.asDefName;
MicroKeys(\pluck).record;
// MIDIItem("241217_102915").take(1).start_(127.5).play(\pluck);
// MicroKeys(\chordOd).synth_(\sawSynth).record;
)
// MIDIItem("241217_094128").take(7).play(\pluck)
MIDIItem("241217_102915").take(8).start_(70).play(\pluck)
MicroKeys(\pf).
