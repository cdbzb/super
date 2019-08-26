( // outer space
	SynthDef(\plate,{|out=0|
		var sig= In.ar(out, 2);
		ReplaceOut.ar(0,
		 PlateReverb.ar(sig,  size: 0.8,  decayTime: 0.5,  damping: 0.6,  diffusion: 1))
	 }).add;

		(Pfx(
			Pbind(*[
				instrument: \default,
				dur: Pseq.new([1,3,4]/[2,3,4,10].choose,inf),
				note: Pseq.new([1,2,4,6,8]*[1,2,3,0.4].choose*5 , inf, )+ Pwhite.new(0, 1.0, inf),
				amp: Pwhite.new(0, 3.0, inf),
			]),
			\plate
		).play
		)
)
