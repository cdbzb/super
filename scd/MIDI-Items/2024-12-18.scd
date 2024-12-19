(
~standardControls = {|e mk| e * (\poly.kr() / 127+ CC.bend(mk: ~mk, rawScale: 16384).bus.kr => _.midiratio)};
{ ~standardControls.(\freq.kr(400), \pluck) }.play
MicroKeys(\pluck, 
	a=
		{ |gate=1 out=0 freq = 400|
			var decaytime = \decaytime.kr(10);
			var in=PinkNoise.ar(1);
			var sig=Pluck.ar(
				in: in,
				gate: gate,
				maxdelaytime: 0.02,
				// delaytime: freq * (\poly.kr() / 127 + CC.bend(mk:~mk, rawScale: 16384).bus.kr => _.midiratio)   + [0.5, 0, -0.1]=> _.reciprocal,
				delaytime: ~standardControls.(freq, ~mk ) =>  _.reciprocal,
				decaytime: decaytime,
				coef:  CC(24, mk: ~mk).bus.kr + [0, 0.1, 0.2],
			)
			=> Splay.ar(_)
			* \amp.kr(0.1) * 10
			* Env.asr().kr(2,gate:gate)
			* EnvGen.cutoff(decaytime - 0.1, 0.1)
			=> LeakDC.ar(_);
			Out.ar(out,sig);
		}
	
)
)
a.(mk:\pluck).asSynthDef.play
a
CC.all
m = MIDIItem("241218_072744");
m.play(\pluck)
