s.boot
(
	{
		SinOsc.ar(400,0,0.1)
	}.scope
)

FreqScope.new


{ LPF.ar (WhiteNoise.ar(0.1),Line.kr(10000,1000,10))}.scope

{Resonz.ar(LFNoise0.ar(400),Line.kr(10000,1000,10),0.1)}.scope

{SinOsc.ar([200,300],0,0.1)}.scope


(1..10)

( var n=10; {Mix(SinOsc.ar(250*(1..n),0,1/n))}.scope)

{0.1*SinOsc.ar}.scope

a= {arg freq=440; SinOsc.ar(freq)*0.05}.play
a.set(\freq,230)
SynthDef(\sine, {Out.ar([0,3],SinOsc.ar(Rand(440,5550),0,0.1))}).add;
c=Synth(\sine);
c.free

Server.default.makeGui
s.boot

s.meter;



