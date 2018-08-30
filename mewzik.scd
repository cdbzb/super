
a=Instr(\modsin).add;
(
b=Pmono(a.name,
	\out, [0,1],
	\degree, Pseq([1, 3, 5, 7, 8, 5, 4, 6],inf)-1 ,
	\octave, 4,
	\dur, 0.5
).play;

c=Pmono(a.name,
	\out, 1,
	\degree, Pseq([8, 6, 5, 5, \r , ]-1, inf),
	\dur, Pseq([3,0.5,0.5,3,1],inf),
	\rate, Pseq([5,5,5, 4.7,5.3],inf)
);

	q = Pfx(c, \echo, \dtime, 0.4, \decay, 8,\out,1).play;

d=Pmono(a.name,
	\out, 0,
	\degree, Pseq([[3, 5 ], [1,4],[1, 3], \r, ]-1,inf),
	\dur, Pseq([3,1,3,1],inf)
).play;

e= Pmono(\default,
	\out,3,
	\degree, Pseq([[11],8,9,10]-0,inf),
	\dur, 0.5,
	\amp, 0.1
).play
)
{Out.ar([0,1],In.ar(3)*0.4)}.play;
s.meter;
(
	SynthDef(\echo, { arg out=0, maxdtime=0.2, dtime=0.2, decay=2, gate=1;
		    var env, in;
		    env = Linen.kr(gate, 0.05, 1, 0.1, 2);
		    in = In.ar(out, 2);
in+		    XOut.ar(out, env, in+CombL.ar(in * env, maxdtime, dtime, decay, 1, in));
	}, [\ir, \ir, 0.1, 0.1, 0]).add;
)
)


