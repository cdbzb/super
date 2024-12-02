(
a = MicroKeys.mono(\mono);
a.synth_({
	var gate = \gate.kr(1);
	SinOsc.ar( \num.kr(40).midicps.lag(0.3) * (\poly.kr / 127 ).midiratio, 0, 0.05 )
	* Env.asr().kr(2,gate:gate)

	* 3
	=> CrossoverDistortion.ar(_, smooth: Env.cutoff(1).kr(2, gate).linlin(0, 1, 0.999, 0.5).poll)
	// => _.distort
	/4
	=> FreeVerb.ar(_, 0.2, 1)
	=> Pan2.ar(_, 1)
}.asDefName);
a.activate;
)
