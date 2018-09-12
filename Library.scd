(
	Library.put(\synthdefs,\clk,
		SynthDef(\clk, {
		Out.ar([0,1],Impulse.ar(0));
	}));
)

Library.at(\synthdefs,\clk).add;
Pbind(	\instrument, \clk, \dur, 0.5 ).play

s.meter;

Library.postTree;
