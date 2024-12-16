(
MicroKeys(\keys).synth_( \default ).tuning_(\just);
MicroKeys(\harp).synth_( \harp, [coef: 0.1, out: 1]).tuning_(\just).add(\quiet,{|e| e.vel= e.vel/ 2},  \addBefore, \synth);
// m.record;
~transport = 10;
a = MIDIItem("241214_105959");
a.take(0).recalcSustains.start_(~transport).play(\keys);
a.take(2).start_(~transport).play(\harp);
~tremolo = Effect.bus({|i| i => Pan2.ar(_, SinOsc.ar(0.4)) },time: 4);
a.take(8).filter({|e| e.collect({|i| i.params = i.params ++ (out: ~tremolo)})}).start_(~transport).play(\harp);
a.takes.do{|i| i.size.postln};

fork{
	a.take(0).notes[95].timestamp - ~transport => _.wait;
	MIDIItem("_241214_153107").save
	.play(\keys)
};
MicroKeys(\keys).record
)
