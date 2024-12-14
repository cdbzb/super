(
MicroKeys(\keys).synth_( \default ).tuning_(\just);
MicroKeys(\harp).synth_( \harp, [coef: 0.1, out: 1]).tuning_(\just).add(\quiet,{|e| e.vel= e.vel/ 2},  \addBefore, \synth);
// m.record;
a = MIDIItem("241214_105959").save;
a.take(0).recalcSustains.play(\keys);
a.take(2).play(\harp);
~tremolo = Effect.bus({|i| i => Pan2.ar(_, SinOsc.ar(0.4)) },time: 4);
a.take(8).filter({|e| e.collect({|i| i.params = i.params ++ (out: ~tremolo)})}).play(\harp);
a.takes.do{|i| i.size.postln};
)
