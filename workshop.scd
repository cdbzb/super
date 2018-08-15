s.reboot;
p = ProxySpace(s).push;
(
~out.play;
~out2.play;
~out3.play;
~out4.play;
~out5.play
)

~out = { Out.ar(0, SinOsc.ar(440,0,0.2)) }
(
~out2 = { var env = Env.new( [0,30], 10 );
       	Out.ar(0, SinOsc.ar((440 + EnvGen.kr( env, doneAction: 2 )),0,0.2)) }
)
(
~out = { Out.ar(0, SinOsc.ar(440,0,0.2)) }
~out2 = { Out.ar(1, SinOsc.ar(880,0,0.1)) }
~out3 = { Out.ar([0,1], SinOsc.ar(1320,0,0.05)) }
~out4 = { Out.ar([0,1], SinOsc.ar(1760,0,0.02)) };
~out5 = { Out.ar([0,1], SinOsc.ar(2640,0,0.01)) };
)
~out.free;

a = { SinOsc.ar(441,0,0.2) }.play;
a.free;

b = { SinOsc.ar(442,0,0.2) }.play;
b.free;


