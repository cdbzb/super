//TODO IEnvGen
(
SynthDef(\shakem,{
		//var env = Env([4,0,1,0,2,0,1,0,4,0]*10,[1,1,1,1,1,1,1,1,1,1,1]/16,loopNode:0,releaseNode:8,curve:\lin).kr(2,gate:\gate.kr(1));
		//var env = DemandEnvGen.ar([4,0,1,0,2,0,1,0].dq(inf)*10,[1/16].dq(inf));
		var env = DemandEnvGen.ar([1,0,4,0,2,0,4,0].dq(inf)*10,[1/16].dq(inf));
		Shakers.ar(instrument:3,energy:env,resonantFreq:SinOsc.ar(0.2).unipolar,decay:SinOsc.ar(0.13).unipolar)
		=> Out.ar(\out.kr(0),_)
	}
).add;
{AnalogBassDrum.ar(trig:\trig.tr(0),tone:0.1)!2 * 6 => Out.ar(0,_)} => SynthDef(\abd,_) =>_.add;
{AnalogSnareDrum.ar(trig:\trig.tr(0),tone:0.1)!2 * Env.perc().kr(0,gate:\trig.tr-0.1) *0.7 => Out.ar(\out.kr(0),_)} => SynthDef(\asd,_) =>_.add;
)
(

Pdef(\shakem,[
	0.0,(instrument:\shakem,out:Effect(DWGReverbC1C3.ar(_,mix:0.1)).bus.index),
	//0.065,[dur:[2,2,2,0.5,1.5,2].q(inf),instrument:\bd_808,trig:1].pm(\abd),
	0.075,[dur:1,instrument:\bd_808,trig:[0,1].q(inf)].pm(\asd),
	//0.075,[dur:1,instrument:\bd_808,trig:[0,1].q(inf),out:Effect(EchoCubic.ar(_,0.3,0.166,3),inputChannels:2).bus.index].pm(\asd),
	0.065,[dur:2/8,instrument:\hat_808,amp:0.7,out:2].p,
	0.065,[ 
		freq:[1,1,3,5,6,5,6,5,5,5,5,6,11,6].df(\e,octave:2).q(inf),
	dur:[4,3,2,1,2,2,2,4,3,2,1,2,2,2].q(inf)/8,
		instrument:\sawSynth
		].pm(\sawSynthSustain)
] => Ptpar(_)) ;
Pdef(\shakem).play;
Pdef(\shakem).quant(2)
)


(
IEnvGen
DemandEnvGen
)
(
b={
	Shakers.ar(
		instrument:3,
		energy: 
		//{var t = Env([4,0,1,0,2,0,1,0]/4*19,1/2,\lin); t.kr(2,gate:1).min(1) }.plot(1)
		//SinOsc.ar(3,0,0.5).unipolar**6 ,
		//SinOsc.ar(6,0,0.5).unipolar**6 ,
		//Env([0,4,0,1,0,2,0,1,0,4,0]*10,[0.1,1,1,1,1,1,1,1,1,1,1]/16,loopNode:0,releaseNode:9,curve:\lin).kr(2,gate:\gate.kr(1))
		//LFPulse.ar(4,0.5)*8 =>Integrator.ar(_,0.1) 
		//Env([0,1,1,0],[1,17,2]/20).kr(2,gate:1)
		a.kr(2),
		//1,
		  //Impulse.ar(3/4)*100=>Decay.ar(_,0.05) 
		decay:100
	)
}.play(s,0)
)
b.set(\onamp,0)
a= Env([0,1,1,0,0],[0.01,01,0.01,10],curve:5)//.plot
a=Env([0,1,0,0,0.5,0],[0.02,0.01,1,0.01,0.1])
a=Env([0,1,1,0.1,0.01,0.01],[0.01,1,0.01,0.1,1])
a.plot

(
SynthDef(\env_test,{
	var env = \env.kr(Env.newClear(4)) => EnvGen.ar(_,1);
	SinOsc.ar(env*300,0,0.1)
	=> Out.ar(0,_)
}).add
)
Synth(\env_test,[\env, Env([1,2+4.rand,1],[0.1,3.rand+0.2])]) 
{WhiteNoise.ar(0.1) => HPF.ar(_,7000)}.play

Env( [1,0,0,1,0],1).plot
(
SynthDef(\shakeEnv,{

	var time = \time.kr(0.05);
	var env = Env([0,1,0,0] ,[0.05,0.00,10]).kr(0,gate:\up.tr(0));
	var env2=Env([0,1,0,0],[0,time,0]);
	env2= EnvGen.ar(env2,\down.tr(0));
	Shakers.ar(
		energy: env + env2 * \amp.kr(1)
	)
	=> Out.ar(0,_)
}).add
)
(
[time:[0.05,1,0.1].q(inf),amp:0.2,resonantFreq:60,dur:1/8,up:[1,0].q(inf),down:[0,1],q(inf)].pm(\shakeEnv).play;
[instrument:\bd_808].pp;
[instrument:\hat_808,amp:[[1].q([3,5,6].q(1)),0].q(inf)/10,dur:1/16,out:Pwhite(0,5,inf)].pp;
[freq:[1,4,6.5,12.5].df(\c,octave:[3,2]).q(inf).stutter(4),dur:0.25,legato:0.3,amp:0.15,out:Effect(DelayC.ar(_,0.1,SinOsc.ar(6).range(0,0.001)).tanh).bus.index].pp;
[instrument:\yowbass,freq:[1,4,6.5,12.5].df(\c,octave:[3,2]).q(inf).stutter(4),dur:0.25,legato:0.3,amp:0.015,out:2].pp;
[freq:[\r,3,2,4,3,2,1].df(\c)++[3,2,4,3,2,1].df('f',octave:6)=>_.q(inf),dur:[2,1,1,1,1,1,3,1,1,1,1,1,1].q(inf)/4,instrument:\stringyy].pp;
[freq:[\r,3,2,4,3,2,1].df(\f)++[3,2,4,3,2,1].df('b-',octave:6)=>_.q(inf),dur:[2,1,1,1,1,1,3,1,1,1,1,1,1].q(inf)/4,instrument:\stringyy,out:2].pp;
[freq:[\r,5,13,12,\r].df(\c).q(inf),dur:[15,1,3,6,7].q(inf)/4,instrument:\sawSynthSustain,legato:1.1].pp;
//there's a better way to write these echoing lines!
[freq:[\r,12,11,\r].df(\c).q(inf),out:3,amp:0.07,dur:[24,3,6,7].q(inf)/4,instrument:\sawSynthSustain,legato:1.1].pp;
[freq:[\r,11,6.5,\r].df(\c).q(inf),out:2,amp:0.06,dur:[32,3,6,7].q(inf)/4,instrument:\sawSynthSustain,legato:1.1].pp;
[freq:[\r,6.5,6,\r].df(\c).q(inf),out:2,amp:0.05,dur:[40,3,6,7].q(inf)/4,instrument:\sawSynthSustain,legato:1.1].pp;
[dur:"..xx..x.".asDrumPat(4,inf),amp:0.1,instrument:\sn_808].pp

)
a=Synth(\shakeEnv);
a.set(\amp,0.1);
a.set(\up,1)
a.set(\down,1)
(
[
	type:\set,
	id:a.nodeID,
	params:#[\up,down],
	up:[1,-1].q(inf),
	down:[0,1].q(inf)
].p.trace.play
)
Pbind


