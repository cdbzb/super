(
~freq = { {\freq.kr(900) * (\poly.kr() / 127+ CC.bend(mk: ~mk, rawScale: 16384).bus.kr => _.midiratio)} };
// { ~standardControls.(\freq.kr(400), \pluck) }.play
MicroKeys(\pluck).dump; 
MicroKeys(\pluck).synth_({ |gate=1 out=0 |
	var decaytime = \decaytime.kr(10);
	var in=PinkNoise.ar(1);
	var sig=Pluck.ar(
		in: in,
		gate: gate,
		maxdelaytime: 0.02,
		delaytime: MicroKeys.freq.().reciprocal,
		decaytime: CC(25, ControlSpec(0.01, 20), mk: \pluck ).bus.kr,
		// decaytime: 10,
		coef:  CC(24, mk: \pluck).bus.kr + [0, 0.1, 0.2],
	)
	=> Splay.ar(_)
	* \amp.kr(0.1) * 10
	// * CC(26, mk: ~mk).bus.kr
	* Env.asr().kr(2,gate:gate)
	* EnvGen.cutoff(decaytime - 0.1, 0.1)
	=> LeakDC.ar(_);
	Out.ar(out,sig);
	// CC(25).bus.index
}
)
.monitor
// .record;

)
s.makeWindow
MIDIdef.all.size
/*
MIDIItem("241220_082301").play(\pluck); //little chord and bass fig in C
MIDIItem("241220_075134").play(\pluck) // more C - C# ideas 
*/
CC.all

m = MIDIItem("241218_072744"); //ending idea
m.play(\pluck)
