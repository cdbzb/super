s.options.dump
s.options.numOutputBusChannels=9
s.reboot
( 
	[
	out:Prand([0,1,2,4,5,6],inf),
	freq:Pwhite(100,2000),
	dur:Pwhite(0.01,0.1),
	pan:-1,
	legato:Prand([1,1,1,10],inf)
	].pp ;

//s.metee
)

a={ Saw.ar(( 200!7 ).rand+100,0.1)=>Out.ar(\out.kr(0,5),_) }.play
a.set(\out,[1,2,3,4,5,6,0].scramble)
(
	8.do{ {var sig = ( Env.asr(6,1,8).kr(2,gate:\gate.kr(1))*Saw.ar(rrand(70,1900),0.05)=>Pan2.ar(_,SinOsc.kr(0.2.rand).range(-1,1) ));sig[0]=>Out.ar(8.rand,_);sig[1]=>Out.ar(8.rand,_)}.play.dur(30,8) }
)
a={WhiteNoise.ar(0.1)=>Out.ar(\out.kr(0),_)}.play
a.set(\out,0)
a.set(\out,1)
a.set(\out,3)
a.set(\out,4)
a.set(\out,5)
a.set(\out,6)
a.set(\out,7)
// quad is [0,1,4,5]
m=Monitor.new.play(2,2,4,2)
Prout
s.meter
{PinkNoise.ar(0.1)=>Pan4.ar(_,SinOsc.kr(1/3,0),SinOsc.kr(1/9,pi))}.play(s,15);
Pproto
PbindFx.help
EventShortcuts
Environment
([
	note:Prand([1,2,4,5,5.5],inf),
	dur:Prand([1/2,1/4,1/8],inf),
	effect: Effect({|i|EchoCubic.ar(i,1,
		SinOsc.kr(
			1/6+(0.1.rand!2)
			+(LFBrownNoise2.kr(1/2).range(-1,0)*0.2)
		)
			.range(0.1,0.6)
		,\len.kr(4,4))},out:0,inputChannels:2) ,
		//fix this!!! in Effect.sc
	mod: Pfunc({|e|e.effect.synth.set(\len,rrand(0.1,4.6)).postln}),
	instrument:{
		Saw.ar(\freq.kr(200,1),0.1)
		* Env.perc(0.1,Rand(9)).kr(2,gate:\gate.kr(1))
		=>MoogVCF.ar(_,Rand(1900),Rand(2.0))
		* \amp.kr(0.05)
		=>Out.ar(\out.kr(0),_)
	}.asDefName ,
	amp:Pbrown(0.03,0.06,0.02),
	out: Pfunc({|e| e.effect.bus.index+2.rand})
].p
//.trace
.play
)
(
	[

		instrument: 
	{Saw.ar(\freq.kr(200,1),0.1)* Env.perc(0.1,9).kr(2,gate:\gate.kr(1))=>Out.ar(\out.kr(0),_)}.asDefName 
	,
		note:Pwhite(-20,90),
		dur:0.77777777,
		pan:-1,
		legato:Pwhite(0.9,2),
		legato:Pwhite(0.9,2),
		effect:Effect.new({
			|i| 
			EchoNone.ar(i,1,1*LFBrownNoise2.kr(0.3).range(0.1,0.9),7).tanh 
			=>Phaser2.ar(_,1,1/12,-2.9)
			=> DetectSilenceDry.ar(_,doneAction:2,time:10)
		},inputChannels:4,out:10),
		out:Pfunc({|i|var out= 4.rand+i.effect.bus.index;out })
	].p.trace.play;
m=Monitor.new.play(10,2,0,2); m=Monitor.new.play(12,2,4,2);
s.meter;s.plotTree;
)
s.meter
DetectSilenceDry.ar(_,doneAction:A
	DetectSilence.ar()()
	s.reboot
	HS
	Fb1
Fb1.new(func, in, outSize: 0, inDepth: 1, outDepth: 2, inInit:64, outInit:64, blockSize: 64, blockFactor: 1, graphOrderType: 1, leakDC: true, leakCoef: 0.995) 
