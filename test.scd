{SinOsc.ar(440,0,0.2)}.play




s.reboot;
a = 3;
a.value;
a=Rand(1,9)*0.1*1000;
(
SynthDef("mysine",{arg dur = 200, bus = 0; var env, envGen;
	env=Env.triangle(dur: 13); // dur, lev
	envGen=EnvGen.kr(env,doneAction:2,levelScale:0.2);
       	Out.ar(bus,SinOsc.ar(dur,0,envGen))}).add
)
a.postln;
a.value;
(
f =Task ({
	inf.do({
	x=Synth("mysine",[dur: (rrand(300,570)), bus: (rrand(0,1))]);
	g=rrand(4,13);
	g.wait
});
});
)

f.start;








b={rrand(400,500)};
b.value;
x.set(\freq, [200,201,202]);
x.stop
a.value;
{a.value(dur: 200)}.play;
a.play;
s.reboot;
s.meter;


