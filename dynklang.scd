DynKlang
(
SynthDef(\dyn,{ |freq=100|
	var partials = (1..100);
	var nyquist= s.sampleRate/2 - 1000;
	var freqs = partials * freq;
	var mask = freqs < nyquist;
	var amps = partials.reciprocal/50;
	SinOsc.ar(freqs,0,amps*mask) =>Mix.ar(_)
	//DynKlang.ar(`[freqs,(amps*mask),0])
	=>Out.ar(1,_)
}).add;
SynthDef(\dyn200,{ |freq=200|
	var partials = (1..100);
	var nyquist= s.sampleRate/2 - 1000;
	var freqs = partials * freq;
	var mask = freqs < nyquist;
	var amps = partials.reciprocal/50;
	//SinOsc.ar(freqs,0,amps*mask) =>Mix.ar(_)
	DynKlang.ar(`[freqs,(amps*mask),0])
	=>Out.ar(1,_)
}).add;
SynthDef(\dyn200b,{ |freq=200 |
	var partials = (1..100);
	var blur = 100.collect{Rand(~cents.(25),~cents.(25).reciprocal)};
	var line = Line.kr(0.03,0,10);
	var deviance=blur*blur+(1-line);
	var nyquist= s.sampleRate/2 - 1000;
	var freqs = partials * freq;
	var mask = freqs < nyquist;
	var amps = partials.reciprocal/50;
	//SinOsc.ar(freqs,0,amps*mask) =>Mix.ar(_)
	DynKlang.ar(`[freqs*deviance,(amps*mask),0])
	=>Out.ar(1,_)
}).add;
SynthDef(\dynTest,{
	var freqs =NamedControl(\freqs,Array.rand(500,100,2000.0),lags:5);
	var amps = NamedControl(\amps,0!500);
	var phase = Array.rand(1000,-pi,pi);
	DynKlang.ar(`[freqs,amps,0])
	=> Out.ar(1,_)
}).add
)
s.options.numWireBufs_(128)
s.options.numWireBufs
s.reboot
a=Synth(\dynTest)
a.set(\amps,0.005!1000)
a.set(\freqs,Array.rand(500,20,700))
a.set(\freqs,Array.fill(500,{100.pareto}))
a.set(\freqs,Array.fill(500,{1000.gaussian(1000)}))
a.set(\amps,0.005!1000);s.makeGui
~cents.(25)
\dyn200(400)
Synth(\dyn200,[\freq,60])
Synth(\dyn200b,[\freq,600])
Synth(\dyn,[\freq,60])
Synths(\dyn,\freq,);s.makeGui
