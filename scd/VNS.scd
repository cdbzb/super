rrand(170,4750);
(
	SynthDef(\tone, { 
	var freq=Rand(170,4650);
	var env = EnvGen.kr(Env.linen(0.05,0.5,0.05),doneAction:2);
	var sig=SinOsc.ar(freq,0,(Rand(0.05,0.2)*env));
	sig=Pan2.ar(sig,Rand(-1,1));
	Out.ar(0,sig);
	}).add;
	
)

x = Synth.new(\tone);
Pbind(\instrument, \tone, \dur, 3 ).play;
a={PinkNoise.ar(0.1)}.play;
s.queryAllNodes;
s.meter;
.free;
s;

