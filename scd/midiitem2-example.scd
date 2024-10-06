MIDIIn.connectAll;
(
b = Effect.bus(FreeVerb.ar(_,CC(24).bus.kr,1), time: 3000);
a = MicroKeys(
{
	Saw.ar( \freq.kr(400) * (
		CC(1).bus.kr => SinOsc.ar(6.rrand(5.0), 0, _	) =>_.range(-1.midiratio, 1.midiratio) 
		* CC.bend(ControlSpec(-2, 2)).bus.kr.midiratio
		* \poly.kr(1).linlin(0, 127, 1, 1.1)
	), 0.1 )
	* Env.asr().kr(2,gate:\gate.kr(1))
	=> Out.ar(b, _)
}
).tuning_(\werckmeister);
m = MIDIItem2("test_24008_09",true,  mk: a)
)

m.record
m.play
m.stop

m.ppar.play

(
c = Effect.bus(DWGReverbC1C3.ar(_,CC(25).bus.kr * 2000, mix: 0.1), time: 3000);
d = MicroKeys(
{
	Pulse.ar( \freq.kr(400) * [0.999,1, 1.0081] * (
		CC(1).bus.kr => SinOsc.ar(6.rrand(5.0), 0, _	) =>_.range(-1.midiratio, 1.midiratio) 
		* CC.bend(ControlSpec(-2, 2)).bus.kr.midiratio
		* \poly.kr(1).linlin(0, 127, 1, 1.1)
	), 0.1, 0.1 )
	=> Mix.ar(_)
	* Env.adsr().kr(2,gate:\gate.kr(1))
	* \amp.kr(0.1)
	=> Out.ar(c, _)
}
).tuning_(\werckmeister);
n = MIDIItem2("test_24008_0",true,  mk: d)
)
m = MIDIItem2("test_24008_09",true,  mk: a)

n.save;m.save 

m.ppar.play; n.record

m.ppar.play;n.ppar.play
n.record
n.stop
n.ppar.play
n.midiEvents
