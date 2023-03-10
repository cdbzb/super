(
SynthDef(\gray,{ var out,env;
	out = PinkNoise.ar;
	out = LPF.ar(out,500);
	env= EnvGen.kr(Env.perc(0.1,3,1));
	Out.ar(0,out*env);
}).add
)

Synth(\gray);

s.boot;
(

c = TempoClock(1.5); // create a new clock with 1.5 beats-per-second, ie: 1.5 * 60 = 90bpm

c.schedAbs(

	1, // time delay from evaluation (in beats)

	{arg ...args;

		[c.bar, args[0], args[1]].postln; // post current bar, current beat nr and elapsed time

		Synth(\gray); // make some sound

	2.0}); // repeat every second beat

)

c.tempo_(3); // double the tempo

c.elapsedBeats.postln; // you can also ask what the current beat nr is

c.elapsedBeats.ceil; // or get the next beat

c.stop; //stop the clock


