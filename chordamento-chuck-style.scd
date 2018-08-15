s.reboot;
s.meter;
(
SynthDef(\slider,{ arg bus, freq = 400;
	freq = Lag.kr( freq, 5 );
	Out.ar(bus, 
		SinOsc.ar( freq, 0, 0.1))
	}).send;

SynthDef (\patch,{ arg in, out;
	Out.ar (out, In.ar(in,1))
	}).send;
)	
(
b = Bus.audio(s,2);
b.index;
a = Synth (\slider, [\bus, b.index, \freq , 480] );


Synth (\patch, [\in, b.index,\out , 0], addAction: 'addToTail');

(
{
 a.set(\freq,500);
 1.wait;
 a.set(\freq,800);
 2.wait;
 a.set(\freq,900);
 3.wait;

 a.free;
 }.fork
)
)

s.queryAllNodes;
