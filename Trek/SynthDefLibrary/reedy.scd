(
SynthDef( \reedyAsr , { |freq = 400 amp = 0.1 attack=0.5 sustain=1 release=9| //	      var numberOfPartials = s.sampleRate/freq/2 => _.floor => _.asInteger;
	var cents = {|i| i/100 => _.midiratio};
	var numberOfPartials =120;
	var nyquist = s.sampleRate.isNil.not.if  {s.sampleRate/2}{22050};
	var detune = 25;//cents
	var noise = {Rand(cents.(detune),cents.(detune).reciprocal)} ! numberOfPartials;
	var line = Line.kr(1,0,10)+LFBrownNoise1.kr().range(0,0.5);
	var blur = noise*line+(1-line);
	var tone =  ({Rand(0,4)<3} ! numberOfPartials);
	var freqs = (1..numberOfPartials) * freq;
	SinOsc.ar(
		freqs
		+SinOsc.kr(5).range(0,1)
		*blur,
		0
		,
		amp *
		((1..numberOfPartials)*2).reciprocal
		//higher number is darker
		**rrand(1.0,2.0)
		//makes  organ-y
		* tone
		* (freqs<nyquist)
		//decrease the volume variation
		=> {|i| i*(i.mean/2+0.0004/(i.mean))}
	)
	=>Mix.ar(_) =>_.tanh
	* Env.asr(attack,sustain,release).kr(0,gate:\gate.kr(1))
	=> Out.ar(\out.kr(0),_)
}
	).add.tag(\key,\pad);
SynthDef( \reedy , { |freq = 400 amp = 0.1 attack=0.5 sustain=3 release=9| //	      var numberOfPartials = s.sampleRate/freq/2 => _.floor => _.asInteger;
	var cents = {|i| i/100 => _.midiratio};
	var numberOfPartials =120;
	var nyquist = s.sampleRate.isNil.not.if  {s.sampleRate/2}{22050};
	var detune = 25;//cents
	var noise = {Rand(cents.(detune),cents.(detune).reciprocal)} ! numberOfPartials;
	var line = Line.kr(1,0,10)+LFBrownNoise1.kr().range(0,0.5);
	var blur = noise*line+(1-line);
	var tone =  ({Rand(0,4)<3} ! numberOfPartials);
	var freqs = (1..numberOfPartials) * freq;
	SinOsc.ar(
		freqs
		+SinOsc.kr(5).range(0,1)
		*blur,
		0
		,
		amp *
		((1..numberOfPartials)*2).reciprocal
		//higher number is darker
		**rrand(1.0,2.0)
		//makes  organ-y
		* tone
		* (freqs<nyquist)

		//decrease the volume variation
		=> {|i| i*(i.mean/2+0.0004/(i.mean))}

	)
	=>Mix.ar(_) =>_.tanh
	* Env.linen(attack,sustain,release).kr(2,gate:1)
	=> Out.ar(\out.kr(0),_)
}
	).add.tag(\key,\pad)
)
