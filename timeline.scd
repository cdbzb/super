(
	SystemClock.sched(0,{b=Synth("default",[\freq,400])});
	SystemClock.sched(4,{b.release});
)

(

b = Array.series(7, 0.125, 0.125).reverse; // use this to create a bit more complex timing 

SystemClock.sched(

	0.5, // time delay from evaluation  

	{Synth(\gray, ([\freq, 1200.rrand(400) , \amp, 1.rrand(0.5)])); // function for the clock to perform, made slightly more interesting

	b.choose}  // pick any value from that array

	);

)


(

SynthDef(\gray, {arg outBus = 0, freq = 400, amp = 1, dur = 1;

	var env, src, fdbin, fdbout;

	env = EnvGen.kr(Env([0, 1, 0], [0.05, 0.95], \sin), timeScale: dur, levelScale: amp, doneAction: 2);

	src = LPF.ar(GrayNoise.ar(amp), freq, env);

	Out.ar(outBus, Pan2.ar(src, Rand.new(-0.7, 0.7)));

}).load(s);

)
