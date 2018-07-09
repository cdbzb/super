s.boot;

(

SynthDef(\mySin, { 
	arg freq=500, decay=2, dur=2, pan=0;
	var env = Env([0,0.5,0],[0.01,dur]);
	Out.ar(pan,
		SinOsc.ar(freq)* EnvGen.kr(env, doneAction: 2)
	)
	}).add;
)

(
var durations, pitches, output;
durations=Pbind (
	\instrument, \mySin,
	\dur , Pseq([1,2,3,],inf),);

pitches= Pbind (\freq , Pseq([200,300,400,500,600],inf));

t=Ppar([durations,pitches]).play;
)

(
var a, b, c, t;
a = Pbind(\x, Pseq([1, 2, 3, 4]), \dur, 1);
b = Pbind(\x, Pseq([10, 20, 30, 40]), \dur, 0.4);
c = Ppar([a, b]);
t = c.asStream;
20.do({ t.next(Event.default).postln; });
)
