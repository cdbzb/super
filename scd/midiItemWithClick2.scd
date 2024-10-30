(

b = MicroKeys();
b.synth_( {
	var gate = \gate.kr(1);
	Pulse.ar(\freq.kr(400) * ( \poly.kr / 64 + 1).midiratio , 0.1, 0.1)
	=> MoogFF.ar( 
		_, 
		CC(1, \freq.asSpec, b ).bus.ar => Gate.ar(_, gate) => _.lag2(0.1)  
	)
	* Env.adsr(CC(24, ControlSpec(0.05, 1.2)).bus.kr, 0.1, 0.5, 1).kr(2,gate:gate)
	=> PanAz.ar(5, _, \num.kr(0)/127 * 5)
}.asDefName
);
b.tuning_(\just);
)

~item = MIDIItem2("withClick_241027_091120",mk: a);
~item2 = MIDIItem2("_241027_093140", mk: b);
~item2.play
s.latency_(0.2);
CC(1, mk:a).bus.scope
~item.midiEvents.select({|e| e.type == \setCC})[6].play
(
Song(\testMIDIItem, []).current;
["1", 1.dm(\c), [8]].addLine;
P(\click, music: { |p b e|
	[instrument: \hihat].pp
});
P(\item, music: { |p b e|
	// var c;
	var a = MicroKeys();
	a.synth_( {
		var gate = \gate.kr(1);
		VarSaw.ar(\freq.kr(400) * ( \poly.kr / 64 + 1).midiratio , 0.1)
		=> MoogFF.ar(_, 
			CC(1, \freq.asSpec, a ).bus.ar => Gate.ar(_, gate) => _.lag2(0.1)  
		)
		* Env.adsr(CC(24, ControlSpec(0.05, 1.2)).bus.kr, 0.1, 0.5, 5).kr(2,gate:gate)
		=> PanAz.ar(5, _, \num.kr(0)/127 * 5)
	}.asDefName).tuning_(\just);
	c = MIDIItem2("_241029_093922", mk:a)
	// MIDIItem2.all.keys.do({ |i| i.class.postln})
	// MIDIItem2.all["_241029_093922"]
	// .reset
	// .record
	.play
	// c.stop
	// c.mk.debug("mk: ");
	;
	// c.stop
	// c.midiEvents
	// MIDIItem2.all
	// c.play

});
P(\itemTwo, music: { |p b e|
	// var c;
	var a = MicroKeys();
	a.synth_( {
		var gate = \gate.kr(1);
		Pulse.ar(\freq.kr(400) * ( \poly.kr / 64 + 1).midiratio , 0.1)
		=> MoogFF.ar(_, 
			CC(1, \freq.asSpec, a ).bus.ar => Gate.ar(_, gate) => _.lag2(0.1)  
		)
		* Env.adsr(CC(24, ControlSpec(0.05, 1.2)).bus.kr, 0.1, 0.5, 0.1).kr(2,gate:gate)
		=> PanAz.ar(5, _, \num.kr(0)/127 * 5)
	}.asDefName).tuning_(\just);
	MIDIItem2("_241029_101340", mk:a)
	// MIDIItem2.all.keys.do({ |i| i.class.postln})
	// MIDIItem2.all["_241029_093922"]
	// .reset
	// .reset.record
	// .play
	.stop.play
	// c.mk.debug("mk: ");
	;
	// c.stop
	// c.midiEvents
	// MIDIItem2.all
	// c.play

});
)

