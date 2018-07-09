s.reboot
s.meter;
s.plotTree;

(
SynthDef(\mySin, { 
	arg freq=500, decay=2, dur=2, pan=0;
	var env = Env([0,0.5,0],[0.01,dur]);
	Out.ar(pan,
		SinOsc.ar(freq)* EnvGen.kr(env, doneAction: 2)
	)
	}).add;
)


~scale=[200,300,400,500,600]
~scaleTwo=[150,300,450,500,600]

c=Pseq(~scale , inf)

(
a=Pbind (\instrument, \mySin,
	\dur , Pseq([1,2,3,],inf),
	\freq , Pseq([200,300,400,500,600],inf)
);

b=Pbind (\instrument, \mySin,
	\pan , 1,
	\freq , Pseq(~scale,inf),
	\dur , Pseq([1,2,3,],inf),
);
)

~chords = Pseq([ [200,300,400,500] , [150,250,350,450] ], inf).asStream;
( //function version
a={ arg chord;
       	Pbind (\instrument, \mySin,
	\dur , Pseq([1,2,3,],inf),
	\freq , Pseq(chord,inf),
);}
)

b=a.value(~chords.next);	
b=b.play;
b.stream = a.value(~chords.next).asStream;

a=a.play;

(
a.stream = Pbind (
		\instrument, \mySin,
		\freq , Pseq([150,200,250,300],inf) ,
		\dur , Pseq([1,2,3,],inf),
).asStream;
)




(
a.stream = Pbind (
		\instrument, \mySin,
		\freq , Pseq([200,300,400,500,600],inf) ,
		\dur , Pseq([1,2,3,],inf),
).asStream;
)

a;
b.play;
b.stop;

(
c=Routine { //these wait times not so awesome
	a.play;
	3.5.wait;
	a.play;
	1.wait;
	b.play
}.play
)


// play a - wait 2.3 secs play a - then play b 
// TODO automate and take through multiple harmonies
(
SynthDef(\sinegrain,
    { arg out=0, freq=440, sustain=0.02;
        var env;
        env = EnvGen.kr(Env.perc(0.001, sustain), 1, doneAction:2);
        Out.ar(out, SinOsc.ar(freq, 0, env * 0.1))
    }).add;
)

(
a = Pbind(\dur, 0.5, \instrument, \sinegrain);
a = Pset(\freq, Pseq([500, 600, 700], inf), a);
a = Pset(\legato, Pseq([0.01, 1],inf), a);
a.play;
)


(

e = Pbind(

	\degree, Pwhite(0,12),

	\dur, 0.2,

	\instrument, \mySin

).play; // returns an EventStream

)



// the event stream's stream can be changed while it is running:



(

e.stream = Pbind(

			\degree, Pseq([0,1,2,4,6,3,4,8],inf),

			\dur, Prand([0.2,0.4,0.8],inf),

			\amp, 0.05, \octave, 5,

			\instrument, \mySin, \ctranspose, 0

).asStream;

)

( //from TUT
	var pattern;
pattern = Pbind( \dur, Pseq
	([1,2,3],inf) );
Pseq([
	Pbindf(pattern, \degree, Pseq([1,2,4,7],1)),
	Pbindf(pattern, \degree, Pseq([1,3,5,8],2))
],inf).play
)

b= Psetp(\degree, Pseq([1,2,1.1,9],inf),a);
b.play;
b= Pset(\degree, Pseq([1,2,4,9],inf),b).play;
