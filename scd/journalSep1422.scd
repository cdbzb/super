(
{
	SinOsc.ar (
		Saw.ar([1.3, 1 ]).range(300),
		SinOsc.ar(_) <> SinOsc.ar(1,0,1).range(200,300),
		Pulse.ar([ 2 ])/10
	) => FreeVerb.ar(_,0.8,0.3) => SineShaper.ar(_)
}.play
)
