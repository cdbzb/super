Instr (\sin, {arg f, freq=f; SinOsc.ar(freq, 0, 0.1)});
a=Patch(\sin,());
a.play;
a.free;