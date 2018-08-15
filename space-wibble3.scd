a=Instr(\modsin).add
~verb=Bus.audio(s);
( // redo these Pmonos as functions (encapsulate)
	v={Verb(~verb)!2}.play;
	{
	p=Pmono(  a.name,  
		\out, [0,1,~verb], 
		\freq, Pseq([200,230,210,Pxrand ([260,250,250,250,250])+5],inf),
		\dur, 0.6,
		\width, Pseq([Pxrand([8,8,8,8,8,9,55]),10,50,12],inf)/200 ,
		\amp, Pseg(Pseq([[0.1,0.1, 0],[0,0, 0.3]],inf),Pseq([3,Pxrand ([3,3.5,1])]),\linear,inf) 
	).play;
2.wait;
	p=Pmono(  a.name,  
		\out, [0,1,~verb], 
		\freq, Pseq([200,230,210,Pxrand ([260,250,250,250,250])+5],inf)*2,
		\dur, 0.75,
		\width, Pseq([Pxrand([8,8,8,8,8,9,55]),10,50,12],inf)/200*0.8 ,
		\amp, Pseg(Pseq([[0.1,0.1, 0],[0,0, 0.3]],inf),Pseq([3,Pxrand ([3,3.5,1])]),\linear,inf)*0.08;
	).play;
	2.wait;

	p=Pmono(  a.name,  
		\out, [0,1,~verb], 
		\freq, Pseq([200,230,210,Pxrand ([260,250,250,250,250])+5],inf)*2.125,
		\dur, 0.73,
		\width, Pseq([Pxrand([8,8,8,8,8,9,55]),10,50,12],inf)/200 ,
		\amp, Pseg(Pseq([[0.1,0.0, 0],[0,0, 0.3]],inf),Pseq([3,Pxrand ([3,3.5,1])]),\linear,inf)*0.03;
	).play;
}.fork
	)


	s.meter;
p.stop;
q[1] = \filter ->  {arg in,mix; FreeVerb.ar(in, mix:mix, room:0.9)};
r=NodeProxy(s);
r.play;
d.set(\mix,1);
q[1].set(\mix, 0.5);

x=NodeProxy(s);
x.source = 
a.play
a.stop;
c={Send(a,v,0,1)}.play;
c.play;

a=Patch(\modsin).play;
a.set(\width,55);
a.set(\rate,8.58);
a.set(\freq,350);
a;
c.set(\wet,0.0);
s.queryAllNodes;
(
	a = NodeProxy.new.play;
	a.source = { RLPF.ar(\in.ar(0!2), [4600, 7000], 0.1) };
	b = NodeProxy.new.source_ { Impulse.ar([5, 7] / 2) };
	a <<> b;
)
