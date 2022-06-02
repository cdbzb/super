
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
( //rising gongs no globals version
~gong = { |freq group tolerance = 0.03 lowest=400 amp=0.1 release=20 |
	freq.isNil.if  { \help.postln; }
	{ {
		var even = Array.rand(100,lowest,20000);
		var near = { |fund| even.collect({|i| (nearHarmonic.(fund,i)<tolerance).if{0}{1}  })};
		var nearHarmonic = {|freq x| 20.collect({|i| (i*freq / x)-1 }).abs.inject(100,_ min: _)};
		var blend = 1-(Line.kr(0,1,9)*near.(freq));
		SinOsc.ar(even*VarLag.kr(\transpose.kr(1),\lag.kr(5),warp:\exp),0,0.01*blend)
		* blend
		=> Mix.ar(_)
		* Env.linen([ 0,0,0,5 ].choose,8,release).kr(2,gate:1)
		* 10 * amp
		=> Out.ar(4.rand,_)
	}.play(group ? s); }
    };
Event.addEventType(\tuningGong,{
	    var args = [~freq,~group,~tolerance,~lowest,~amp,~release];
	    topEnvironment.use{~gong.(*args)}
    },(freq:400,lowest:300,tolerance:0.03,group:s))
);
//{ ~gong.(400,g,lowest:1000) }.sched([1,2,4]);
//{ g.set(\transpose,1.1) }.sched(10);

( //tune up sound - sounds good with gongs...
~tuneUp = { |freq=150 amp=0.2 out=0.1|
var numberOfPartials = s.sampleRate/freq/2;
var noise = Array.rand(numberOfPartials,100,s.sampleRate/2).sort;
var tone = (numberOfPartials-1).asInteger.collect({|i| ( i + 1 ) * freq });
	{
		var line = Line.kr(0,1,10);
		var freq = line * tone + ( (1-line) * noise );
		(1..(numberOfPartials+1)).reciprocal;
		//Array.geom(~numberOfPartials,0.01,0.98);
		SinOsc.ar(freq,0,amp)
		=> Mix.ar(_)
		* Env.linen(1,1,11).kr(2,gate:1)
		* amp

	}.play(s,out);
};
Event.addEventType(\tuneUp,{var args = [~freq,~amp,~out]; topEnvironment.use{~tuneUp.(*args)}},(type:\on,freq:300,amp:0.001,out:0));
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
