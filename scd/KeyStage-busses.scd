(
KeyStage.addBus(\mod, 1);
KeyStage.addBus(\width, 24);
KeyStage.keyBus;
MIDIIn.addFuncTo(\bend, {|a b i| i.postln })
MIDIdef.bend(\kbend,{|b| b.postln} )
MIDIIn.connectAll
// {SinOsc.ar( 300 * In.kr(KeyStage.busses.mod.index).poll.lag(0.2).poll ) * 0.1}.play;
~func = { {VarSaw.ar( KeyStage.cc(\keys).midicps * [0.99, 1.009] * ( 0.5 => DelayN.ar(_, 0.2, [0, 0.2, 0.41, 0.583])), 0, KeyStage.cc(\width)  ) * 0.1 * 
	EnvGen.ar(Env.asr(0.05, 1, 1), \gate.kr(1), doneAction: 2)
	=> MoogFF.ar(_, KeyStage.cc(\mod).lag(0.1) * 1500 + 50)
}.play 
};
MIDIdef.noteOn(\on, {a.isPlaying.postln.if { a.set(\gate, 1) }{ a = ~func.().register }});
(type: \midi, channel: 1).play
MIDIdef.noteOff(\off, {a.().set(\gate, 0)}); 
)
MIDIClient.reset
(
s.waitForBoot {
	b = {|v n c s| Synth(\sawSynthSustain,[freq: n.midicps, amp: v/128, rel: 0.05] )};
	a = MIDIItem(\trshee, synthFunc:b);
	a.record(mono: true)
	a.stop;
	a.save
	a.reset;
	//bad why??
	a.asPbind <> [instrument: \sawSynthSustain, rel: 0.05].pma => _.trace => _.play
	//good (run these 4 lines)
	d = [legato: a.notes.collect(_.legato).postln.q, instrument: \sawSynthSustain, rel: 0.05, amp: a.notes.collect(_.amp).q].pma <> a.asPbind => _.fin(23)  => _.play;
	c = TempoMap(a.notes.collect(_.dur), " e e e x x x x e e x x e e e x x x x e x x x x e e ".asBeats );
	e = [instrument: \bd_808, amp: 0.5, dur: "e*8".beats.warpTo(c.quantizeDft(0.5)).q].p ;
	f = Ppar([d, e],3).play


	[dur: 0.2,rel: 0.05,instrument: \sawSynthSustain, legato:[2, 1, 0.5].q(inf), degree: [1, 3, 4, 3, 2].q(inf)].ppma
	[ legato: a.notes.collect(_.legato).q, instrument: \sawSynthSustain, midinote: a.notes.collect(_.midinote).q, rel: 0.05, dur: a.notes.collect(_.dur).q ].ppma
	a.asPbind <> [instrument:\sawSynth].pma =>_.play
	[a.notes[0] , a.notes[1]].q.play
	a.notes.do(_.postln)
	a.notes.do(_.postln)
	.play
	[legato:[2, 0.3].q, midinote: [40, 60].q, instrument: \sawSynthSustain].ppma
	a.notes.do(_.postln)
	a.notes.collect(_.legato)
}
)
a.synths[0].set(\freq, 399)
a.synths[0].set(\gate, 0)
a.mono

)
MIDIClient.destinations.do(_.postln)
.list
MIDIIn.connectAll
