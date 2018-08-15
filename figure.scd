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

(
Pdefn (\durs,Pseq([1,2,3],5));
Pdefn (\pitches,Pseq([
	[200,300,400,500,600],
	[150,300,450,500,600]
		],inf));


a={ arg chord; //fifteen note figure
	Pbind(
		\inst , \mySin ,
		\dur , Pdefn(\durs) ,
		\freq , Pseq(chord,3)  ,
	)};


b=Pdefn(\pitches).asStream;

c=a.value(b.next);	
Routine.new({ //figure repeated
	d=c.play;
	2.5.wait;
	e=c.play;
}).play;

)
