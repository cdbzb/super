
~cents=2**((1200/_).reciprocal);
( ~reedy = { |freq = 400 sustain = 3 release = 9 amp = 0.1|
	{
		var numberOfPartials = s.sampleRate/freq/2 => _.floor => _.asInteger;
		var detune = 25;//cents
		var noise = Array.rand(numberOfPartials,~cents.(detune),~cents.(detune).reciprocal);
		var line = Line.kr(1,0,10)+LFBrownNoise1.kr().range(0,0.5);
		var blur = noise*line+(1-line);
		SinOsc.ar(
			freq
			+SinOsc.kr(5).range(0,1)
			*(1..numberOfPartials) *blur,
			0
			,
			amp *
			((1..numberOfPartials)*2).reciprocal
			//higr number is darker
			** rrand(1.0,2.0)
			//makes is organ-y
			*Array.fill(100,{[0,1,1,1].choose})

		)

		=>Mix.ar(_) =>_.tanh
		* Env.linen(0.5,sustain,release).kr(2,gate:\gate.kr(1))
		=> Out.ar((0..3).choose,_)
	}.play };
Event.addEventType(\reedy,{var args= [ ~freq,~sustain,~release,~amp ]; topEnvironment.use{~reedy.(*args)}},(type:\note,amp:0.1,freq:300,sustain:3,release:9));
);

SynthDef(\x,{  
	var freqs = NamedControl.kr(\freqs, { Rand(400,500) }!64);
	var sig = freqs.collect{|i| (i==0).if{0}{SinOsc.ar(i,0,0.1)}};
	sig=Mix.ar(sig);
	Out.ar(1,sig)
}).add

/*
a=Synth(\x,[\freqs,[100,120,1230,1990,2000,8000,8001,4000]]);
a.set(\freqs,[500,506,0,0,0,0,0,0]);
*/
*/
