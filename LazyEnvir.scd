(
a=LambdaEnvir((
	pbind:{ 
		[
			note:Pwhite(1.0,2,inf),
			out:~verb,
			pan:Pbrown(-1,1)
		].p },
	effect: { Effect({|in | FreeVerb.ar(in,\mix.kr(1),1)},inputChannels:2) },
	verb: {~effect.bus.index},
	pbind2: {
		var verb= ~verb;
		[

			note:Pwhite(4.0,5.0,inf),
			dur:Pwhite(0.1,0.2,inf),
			out:1,
			pan:Pbrown(-1,1),
			instrument:~def,
			width:Pwhite(10,100),
			amp:0.01
		].p
	},
	def:{ SynthDef(
		\ff,
		{
			var freq=\freq.kr(300,0.1), 
			width=\width.kr(10,5);
			Gendy1.ar(ampdist:0.01,minfreq:freq-width,maxfreq:freq+width) 
			*\amp.kr(0.1)
			* Env.asr(attackTime: 0.01,  sustainLevel: 1.0,  releaseTime: 3.0,  curve: -4.0).kr(2,gate:\gate.kr(1))
			=> Out.ar(\out.kr(0),_)
		}
	).add.name},
	lfo: {{SinOsc.kr(0.1).unipolar}.play(s,~lfobus.index)},
	lfobus: Bus.control

) 
);
a[\pbind2].play;
a[\pbind].play
)
(
a=LambdaEnvir((
	c: { Synth(\default,[\out,~effectBus]) },
	effectBus:{~verb.bus.index},
	f: {~l; ~c.map(\freq,~lfo.index) },
	l: {{SinOsc.kr(5).range(100,500)}.play(s,~lfo)},
	lfo:Bus.control(s,1),
	play: {~f},
	verb: Effect({|i| Allpass2.ar(i,SinOsc.kr(0.3!4).range(400,2000)) 
	=> Pan2.ar(_,LFBrownNoise2.kr().range(-1,1))!2
	=> CombC.ar(_,0.3,SinOsc.kr(0.34).range(0.05,0.2),decaytime:8)
	//=> Pan2.ar(_,LFBrownNoise2.kr().range(-1,1))
	=> AllpassC.ar(_,0.3,SinOsc.kr(0.39).range(0.05,0.2),decaytime:6)
	//=> Pan2.ar(_,LFBrownNoise2.kr().range(-1,1))
	=> AllpassC.ar(_,0.3,SinOsc.kr(0.19).range(0.05,0.2),decaytime:6)
	//=> Pan2.ar(_,LFBrownNoise2.kr().range(-1,1))
	=> AllpassC.ar(_,0.3,SinOsc.kr(0.19).range(0.05,0.2),decaytime:6)
	=> HPF.ar(_,30)
	//=> LPF.ar(_,40) // under the pier!
},numInputs:4)
)).play
)
(
{Impulse.ar(LFBrownNoise1.kr(0.5).range(1,30))}.play(s,a[\verb])
{SinOsc.kr(0.1)}
a[\effect].synth.map(\mix,a[\lfobus].index)
a[\lfo]
a[\lfobus].index
a[\effect].synth.set(\mix,1)
a[\effect].synth.set(\room,0)
b=LazyEnvir((c:3,a:~b,b:2,d:~a-4}))
b[\d]
