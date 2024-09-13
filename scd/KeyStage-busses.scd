(
KeyStage.addBus(\mod, 1);
KeyStage.addBus(\width, 24);
KeyStage.keyBus;
// {SinOsc.ar( 300 * In.kr(KeyStage.busses.mod.index).poll.lag(0.2).poll ) * 0.1}.play;
~func = { {VarSaw.ar( KeyStage.cc(\keys).midicps * ( KeyStage.cc(\mod).lag(0.2) => DelayN.ar(_, 0.2, [0, 0.2, 0.41, 0.583])), 0, KeyStage.cc(\width)  ) * 0.1 * 
	EnvGen.ar(Env.asr(1, 1, 9), \gate.kr(1), doneAction: 2)
}.play 
};
MIDIdef.noteOn(\on, {a.isPlaying.postln.if { a.set(\gate, 1) }{ a = ~func.().register }});
MIDIdef.noteOff(\off, {a.().set(\gate, 0)}); 
)
