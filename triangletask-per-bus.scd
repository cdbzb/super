s.boot;
s.reboot;
( \\ triangle synth 43s
SynthDef("mysine",{arg dur = 200, bus = 0; var env, envGen;
	env=Env.triangle(dur: 43); // dur, lev
	envGen=EnvGen.kr(env,doneAction:2,levelScale:0.2);
       	Out.ar(bus,SinOsc.ar(dur,0,envGen))}).add
)

( \\ function returns a task (so as you can set the bus!)
f ={ arg bus;
	Task ({ 
		inf.do({
		x=Synth("mysine",[dur: (rrand(300,570)), bus: bus]);
		g=rrand(28,49);
		g.wait
		});
	});
});


( \\ sets a pair of these in motion
t=f.value(bus: 0);
t.play;
u=f.value(bus: 1);
u.play;
)
f.stop









b={rrand(400,500)};
b.value;
x.set(\freq, [200,201,202]);
x.stop
a.value;
{a.value(dur: 200)}.play;
a.play;
s.reboot;
s.meter;


