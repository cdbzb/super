a=Instr(\modsin).add;
a=Instr(\modsin).gui;

Synth(ms2);
(
	SynthDef( \ms2 ,{|freq=400,rate=5,width=0.05,amp=0.1, release=1, out=0,gate=1| var env,sig; 
		env=EnvGen.kr(Env.asr(0.01,1,release),gate,doneAction:2);
		//env=1;
		sig=ModSin(freq,rate, width,amp)*env;
		Out.ar(out,sig)}
	).add

	SynthDef(\echo, { arg wet=0.5 , out=0, maxdtime=0.2, dtime=0.2, decay=2, gate=1;
		    var env, in;
		    env = Linen.kr(gate, 0.05, 1, 0.1, 2)*wet;
		    in = In.ar(out, 2);
in+		    XOut.ar(out, env, in+CombL.ar(in * env, maxdtime, dtime, decay, 1, in));
	}, [\ir, \ir, 0.1, 0.1, 0]).add;
)


(
~bass=Pmono(\ms2,
	\degree, Pseq([1, 3, 5, 7, 8, 5, 4, 6],inf)-1 ,
	\octave, 4 ,
	\dur, 0.5,
	\out , [0,1]
);

~tune=PmonoArtic(\ms2,
	\out, 1,
	\degree, Pseq([ 
			Pseq([8, 6, 5, 5, \r  ]), 
			Pseq([8, 9.02, 6, 5, 5, \r]) ] , inf) -1,
	\dur,  	Pseq([ 
			Pseq ( [3,0.5,0.5,3,1] ), 
			Pseq ( [2.5, 0.5 ,0.5,0.5,3,1])] , inf ),
	\rate, 	Pseq([5,5,5, 4.7,5.3],inf),
	\legato, Pseq([1,1,1,1,0.7, 1,1,1,1,1,0.7],inf),
	\amp, 0.15
);

~echo = Pfx(~tune, \echo, \dtime, 0.4, \decay, 8,\out,1,\wet, 0.4);

~chords=PmonoArtic(\ms2,
	\out, 0,
	\degree, Pseq([[3, 5 ], [1,4],[1, 3], \r, ]-1,inf),
	\dur, Pseq([3,1,3,1],inf),
	\legato,1
);

e= Pmono(\default,
	\out,3,
	\degree, Pseq([11,8,9,10]-0,inf)-1,
	\dur, 0.5,
	//\amp, 0.1
).play;

h=PmonoArtic( \ms2,
	\degree, Pseq([1, 2, 3.01, 1, (5-7), 1, 2, 3  ], inf)-1,
	\dur, Pseq([1.5, 0.5, 2 , 0.5, 0.5 , 0.5,  0.5, 2 ],inf),
	\amp, 0.02,
	\legato, Pseq([1, 1, 0.8],inf),
	\width, 0.015,
	//\octave, [4,8],
	\out, [0,1],
);
i=PmonoArtic( \ms2,
	\note, Pseq([ \r, 5, 4],inf)+1,
	\dur , Pseq([ 0.5, 0.5, 3],inf),
	\octave, 6,
	\width, 0.01,
	\amp, 0.01,
	\out, 0,
);
j=PmonoArtic( \ms2,
	\note, Pseq([ \r, 5, 4],inf)+1,
	\dur , Pseq([ 0.5, 0.5, 3],inf),
	\octave, 6,
	\width, 0.01,
	\amp, 0.006,
	\out, 1,
)
)

(
	{
	~bass=~bass.play;
	~chords=~chords.play;
	~echo=~echo.play;
	~accomp=h.play;
	i.play;
	TempoClock.sched(2, {j.play});

	inf.do({
		16.wait;
		~chords.stop;
		~accomp.stop;
		16.wait;
		~accomp.reset;
		~accomp.play;
		~chords.reset;
		~chords.play;
	});
}.fork
)

(
h=PmonoArtic( \ms2,
	\degree, Pseq([1, 2, 3], inf)+13,
	\dur, Pseq([1.5, 0.5, 2],inf),
	\amp, 0.2,
	\legato, Pseq([1, 1, 0.8],inf),
	\width, 0.015
).play
)
h.free;
	
v=Synth(\ms2);
v.release;

{Out.ar([0,1],In.ar(3)*2)}.play;

)

s.plotTree;
s.queryAllNodes;
s.meter;
