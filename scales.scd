Scale
(
~notes=Pbind(*[
	scale:Scale.minor,
	root:1,
	octave:4,
	degree:Pseq([0,2,4],2)
]);
)

Scale.directory

~notes.nextN(5);
~notes.play;
~notes.nextN(8);
(
fork)
NodeProxy
s.plotTree;
(
	~cisMajor=(scale:Scale.major,root:8,dur:0.6);
	Pdef(\gg,
		Ppar([
			Pseq([
				(degree:[1,3,5]-1),
				(degree:[1,3,5]-1),
				(degree:[1,4,6]-1),
				(degree:[1,4,6]-1),
				(degree:[2,4,6.0]-1),
				(degree:[2,4,6.2]-1),
				(degree:[1,4,6]-1),
				(degree:[1,4,5.9]-1),
			],inf)<>~cisMajor,
			Pbind(*[
				instrument:{|tension=0.05 gate=0| 
					MembraneCircle.ar(
						Impulse.ar(0!2)
						,
						tension:tension)*
						EnvGen.kr(Env.cutoff(1),doneAction:2)},
					//Env.cutoff(1).kr(doneAction:2)},
				dur:0.5,
				//tension:
			])
		]);
	).play(k)
)
s.options.memSize(2**17);
s.reboot;

( //1
k=TempoClock(1).permanent_(true);
a=NodeProxy.audio;
a.clock=k;
b=NodeProxy.audio.play;
b.source={|tension=0.008| MembraneCircle.ar(a,tension,0.9999)};
c=NodeProxy.control;
c.source={SinOsc.kr(0.1)*0.002+0.010};
b.map(\tension,c);
)
( //2
a.source=Pbind(*[ instrument:{|out=0 gate=1| 
		Out.ar(out,PinkNoise.ar(0.1!2)*
		Env.perc(0.00,0.2).kr(2,gate))},
		dur: Pwrand([0.5,Pseq([0.25],2)],[0.9,0.1],inf)
	]);
)
Pdef(\gg).play
s.plotTree;
( //3
	d=NodeProxy.audio;
	d.clock=k;
	d.source= Pbind(*[ dur:0.125, instrument:{|out=0 gate=1| Out.ar(out,Impulse.ar(0!2)*Env.cutoff(0.05).kr(2,gate))} ]);
	d.play;
	d[1]=\filter->{|in|Ringz.ar(in,900)*0.01+(in*0.07)*1.1};
	d[2]=\filter->{|in|Phaser1.ar(in,rate:0.1)}
)

(//4
	e=NodeProxy.audio;
	e.clock=k;
	e.source= Pbind(*[amp:0.05, degree:Pseq([Pseq([[1,3,5]],2),Pseq([[1,4,6]],2)],inf), ]);
	e.quantize;
	e.play;
	//e.stop;
)
s.boot;
~a=~synful.();
~a.patch(\violin,\arco,0);
~a.node[1]=\filter->{|in| FreeVerb.ar(in,0.7,0.7)*3};
~a.activate(0);
~a.expr[0].source={LFNoise1.ar(1)*2-1};
10.do{|i| ~a.expr[i].source={LFNoise1.ar(1/(3.rand))*2-1}; }

(//chaossss!	
	{
		10.do{
			~a.shuffle;
			10.do{|i|
				p=Pbind(*[
					type:\midi,
					midiout:~a.controller.midi,
					degree:(Pwhite(-28,24,90)), //try Pbrown!!
					legato:1.05,
					scale:Pseq([Pseq([Scale.major],10),Pseq([Scale.pelog],10) ],inf),
					dur:0.1*2.0.rand*Prand([1,1,2,0.5,0.33],inf),
					chan:i,
					amp:(Pbrown(0,0.40,0.02));
				]).play
			};
			11.wait;
		}
	}.fork
)
~a.patch(\violin,\arco,0)
p.stop;
k.tempo_(0.92);
d.play;
e=NodeProxy.audio.play;
d.stop;
e.play
s.plotTree






