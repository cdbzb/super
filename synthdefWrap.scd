(
~bag = { |freqA, ampA=1| LFTri.ar(freqA, 0, ampA) };
~otherBag = { |blend, freqB, ampB=1| 
	SynthDef.wrap(~bag).blend(
		LFPar.ar(freqB, 0, ampB),
		blend
	)
};

~def = SynthDef(\doubleBag, {
	Out.ar(
		\out.kr(0), 
		Env.perc(0, 1).kr(\gate.kr(1), doneAction:2) 
		* SynthDef.wrap(~otherBag).tanh
		* [1, 1]
	);	
}).add;

~def.allControlNames.collect(_.name).do(_.postln);

Pbind(
	\instrument, \doubleBag,
	\dur, 1/8,
	\ampA, Prand([0.3, 2.8, 5.2], inf),
	\ampB, Prand([0.1, 2.3, 4.9], inf),
	
	\freqA, 50 + Pwalk([0, 5, 6, 9, 36], Prand([-1, 1], inf), -1),
	\freqB, 52 + Pwalk([0, 5, 6, 9, 24], Prand([-1, 1], inf), -1),
	
	\blend, Pseg([0, 0.6, 0], [16, 16]).repeat
).play
)

Quarks.install("https://codeberg.org/madskjeldgaard/komet")
