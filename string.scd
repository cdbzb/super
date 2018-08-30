(
{ Streson.ar
	(Saw.ar(
		[(220+LFNoise1.ar(0.1,50, 1))   , (180+LFNoise2.ar(0.08,50, 1))], 0, mul:EnvGen.kr(Env.asr(6, 1, 0.02), 1.0) * 0.2)
		, LinExp.kr(LFCub.kr(0.01, 0.5*pi), -1, 1, 280, 377).reciprocal, 0.99, 0.3) }.play
)


s.meter;