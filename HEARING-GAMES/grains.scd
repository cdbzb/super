(
	SynthDef(\grain,{
		var env=EnvGen.ar(Env.sine(0.02),doneAction:2);
		var sig=SinOsc.ar(Rand(160,3000),0,env);
		//var sig=SinOsc.ar(Rand(9160,13000),0,env);
		Out.ar(0,sig!2);
	}).add
)

Pbind(\instrument,\grain,\dur,Pwhite(0,0.3)).play;
