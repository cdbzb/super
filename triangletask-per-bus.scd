s.boot;
s.reboot;
( // triangle synth 43s
SynthDef("mysine",{arg freq = 200, bus = 0, dur = 43; var env, envGen;
	env=Env.triangle(dur: 43); // dur, lev
	envGen=EnvGen.kr(env,doneAction:2,levelScale:0.2);
       	Out.ar(bus,SinOsc.ar(freq,-1,envGen))}).add
)

( // function returns a task (so as you can set the bus!)
f ={ arg bus;
	Task ({ 
		inf.do({
		x=Synth("mysine",[freq: (rrand(300,570)), bus: bus, dur: rrand(1,20)+20]);
		g=rrand(28,49);
		g.wait
		});
	});
});


( // sets a trio  of these in motion - run twice for muchness
t=f.value(bus: 0);
t.play;
u=f.value(bus: 1);
u.play;
v=f.value(bus: [0,1]);
v.play;
)
f.stop

// alternate 2 notes

(
f = { arg bus, offset=0; var one , two, funca, funcb; Task({
	one = 100+offset;
	two = 140+offset;
	funca={arg freq=100+offset; Out.ar(bus, SinOsc.ar(freq,0,0.05))};
	funcb=funca.play;
	inf.do({
		rrand(53,87).wait;
		funcb.set(\freq , two);
		rrand(53,87).wait;
		funcb.set(\freq , one);
	});
    };)
};
)

(
8.do({
t=f.value(bus: (rrand(0,1)), offset: rrand(0,8)*80);
t.start;
}
);
)
 s.meter;
)







b={rrand(400,500)};
b.value;
x.set(\freq, [200,201,202]);
x.stop
a.value;
{a.value(dur: 200)}.play;
a.play;
s.reboot;
s.meter;


