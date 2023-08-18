
().play
Song.playOnly(\alt, \TU)
s.newBusAllocators
Song.rhythmRecorder(Song.sections)
Song.renderAllSynthVs
Song.at(2).do(_.p)
(
{
	PinkNoise.ar(0.1)
	=> Out.ar(
		(0..4).dq(inf)
		=> Demand.ar( Impulse.ar(1/4),1,_ ),

		TExpRand
		_
	)
}.play
)
(
SynthDef (\nh_guit,
{ var freq = \freq.kr(220, 0.1) / 2;

Pluck.ar(
	SinOsc.ar(
		Env.perc(0.001,0.1).ar(0,1).linexp(0,1,SinOsc.kr(0.13).range(800,8000),16000),

	),
	1,
	freq.reciprocal,
	freq.reciprocal,
	5,
	coef: \coef.kr(0.1)
) 
// /10
=> MoogFF.ar(_,3000,1.5)
=> _.tanh
=> Out.ar(\out.kr(0), _)
	}
).add
)
Song.at(5)
(
[
	instrument: \nh_guit,
	midinote: [1,4,11,13,21,25].dm(\e,3).bubble.q(inf),
	ctranspose: [0,5,7] => Prand(_,inf),
	strum:0.07,
	out: Pwhite(0,4,inf),
	legato: Pwhite(0.9,1.1,inf)
].pp
)
