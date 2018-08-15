a=Instr(\modsin).add
SynthDef(\tri,{|freq,dur| Out.ar([0,1],SinOsc.ar(freq)*EnvGen.kr(Env.triangle(dur),doneAction:2))}).add;
(
	v={Verb(~verb)!2}.play;
	Pspawner( {|spawn|
		spawn.par(
			Pmono(  a.name,  
			\out, [0,1,~verb], 
			\freq, Pseq([200,230,210,Pxrand ([260,250,250,250,250])+5],inf),
			\dur, 0.6,
			\width, Pseq([Pxrand([8,8,8,8,8,9,55]),10,50,12],inf)/200 ,
			\amp, Pseg(Pseq([[0.1,0.1, 0],[0,0, 0.3]],inf),Pseq([3,Pxrand ([3,3.5,1])]),\linear,inf) 
		));
	
		spawn.seq(Pbind(\instrument, \tri,
			\dur,Pseq([1,4],1),
			\freq, Pseq([300,400],2),
		));
		spawn.seq(Pbind(\instrument, \tri,
			\freq,600,
			\dur,Pseq([5])));
		//spawn.suspendAll;
	}).play;
)

