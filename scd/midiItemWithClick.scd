(
a = MicroKeys();
a.synth_( {
	var gate = \gate.kr(1);
	VarSaw.ar(\freq.kr(400) * ( \poly.kr / 64 + 1).midiratio , 0.1)
	=> MoogFF.ar(_, 
		CC(1, \freq.asSpec, a ).bus.ar => Gate.ar(_, gate) => _.lag2(0.1)  
		)
		* Env.adsr(CC(24, ControlSpec(0.05, 1.2)).bus.kr, 0.1, 0.5, 5).kr(2,gate:gate)
		=> PanAz.ar(5, _, \num.kr(0)/127 * 5)
}.asDefName
);
a.tuning_(\just);
)
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
	 ~item.mk_(a);
	 ~item.stop
	 ~item.record
	 ~item.reset
	 ~item2.reset
	 ~item2.record
	 ~item2.stop
	~item.play
	~item2.play
	~item.midiEvents.select{|e| e.type == \mk}[5]
	~item.notes[1]
	.play
	~item2.play
	~item.play
	~item.stop
	~item.reset
	
	~item.midiEvents.select{|e| e.type == \setCC}[2].play 
});
P(\itemTwo, music: { |p b e|
/* 	
~item2.mk_(b)
~item2.reset
~item2.record
~item2.stop
~item2.play
~item.play
*/
// ~item2.play
// ~item2.mk == b
// ~item2.midiEvents.select{|e| e.type == \setCC}[3].mk == b
	// MIDIItem2.newPart(e, mk: a)
	// (e.key.asString ++ Song.current)=> _.postln;
	// e.parent.key.postln
});

)

