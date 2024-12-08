(
a = 
MicroKeys.mono(\lead)
.synth_({
	Saw.ar( \num.kr(400).midicps.lag(\lag.kr(0.5))
	* (\poly.kr(1) / 127 => _.midiratio))
	/2
	* Env.asr().kr(2,gate:\gate.kr(1))
	=> {|i| DelayN.ar(i) / 2 + i}
	=> MoogFF.ar(_, CC(24, \freq.asSpec).bus.kr)
}.asDefName);
MIDIItem("test_241206_112813")
// .record(a)
.play(a)
)
m = MIDIItem("test_241206_112813")
m.midiEvents.do(_.postln)
