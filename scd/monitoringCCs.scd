MIDIClient.init;
MIDIIn.connectAll;
(
a = {
	SinOsc.ar(  
		Select.kr(
			\monitoring.kr(0), [
				CC(1, \freq.asSpec).asBus,
				\freq.kr(333)
			]
		),
		0, 0.1 )
	}.play
)
a.set(\monitoring, 1)
a.set(\freq, 320)
a.get(\freq)

(
~monitoringCC = {| num spec param default|
	{
		NamedControl.kr(\monitorCC, 0)
		=> Select.kr( _, 
			[
				CC(num, spec).asBus,
				NamedControl.kr(param, default)
			]
		)
	}
}
)
(
a = {
	SinOsc.ar( ~monitoringCC.(1, \freq.asSpec, \freq, 333), 0, 0.1 )
}.play
)
a.set(\monitorCC, 1)
a.set(\freq, 3200)
(
a = MicroKeys();
a.func = {
	{
		SinOsc.ar( ~monitoringCC.(1, \freq.asSpec, \freq, 333), 0, 0.1 )
	}.play
};
a.tuning_(\just);
a.velCurve_(0)
a.play
)
