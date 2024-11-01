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
	a = MicroKeys();
	a.synth_( {
		var gate = \gate.kr(1);
		VarSaw.ar(\freq.kr(400) * ( \poly.kr / 64 + 1).midiratio , 0.1)
		=> MoogFF.ar(_, 
			CC(1, \freq.asSpec, a ).bus.ar => Gate.ar(_, gate) => _.lag2(0.1)  
		)
		* Env.adsr(CC(24, ControlSpec(0.05, 1.2)).bus.kr, 0.1, 0.5, 5).kr(2,gate:gate)
		=> PanAz.ar(5, _, \num.kr(0)/127 * 5)
	}.asDefName).tuning_(\just)
	// .activate
	;
	c = MIDIItem2("_241029_093922" )
	// MIDIItem2.all.keys.do({ |i| i.class.postln})
	// MIDIItem2.all["_241029_093922"]
	// .reset
	// .record(a)
	.play(a)
	// c.stop
	// c.mk.debug("mk: ");
	;
	// c.stop
	// c.midiEvents
	// MIDIItem2.all
	// c.play

});

// MIDIIn.connectAll
// MIDIdef.noteOn(\test, {|a b c d| [a, b, c, d].postln})
P(\itemTwo, music: { |p b e|
	TempoClock.default = TempoClock(queueSize: 8192);
	// var c;
	a = MicroKeys(\twang);
	a.synth_( {
		
		var gate = \gate.kr(1);
		Pulse.ar(\freq.kr(400) * ( \poly.kr / 64 + 1).midiratio , 0.1)
		=> {|i| MoogFF.ar(i , 
		CC(1, \freq.asSpec, a ).bus.ar => Gate.ar(_, gate) => _.lag2(0.1)  ,
		3
	)
}		
		* Env.adsr(CC(24, ControlSpec(0.05, 1.2), a).bus.kr, 0.1, 0.5, 0.1).kr(2,gate:gate)
		=> PanAz.ar(5, _, \num.kr(0)/127 * 5)
	}.asDefName).tuning_(\just)
	;
	MIDIItem2("_241030_130953") // .player.midiEvents.select{|e| e.type == \setDamper}
	// .record(a)
	// .player({|i| i.collect{|e|if(e.midicmd == \control and: (e.ctlNum == 1)) {e.control = 20 + 15.rand + e.control / 2; e}{e}}})
	// .record(_)
	// .player
	// .filterChoice({|e| e.midicmd == \control and: (e.ctlNum == 1)}, {|e| e.control = 20 + 15.rand + e.control / 2; e} )
	// .filterTrack(1, {|e| e.control = 20 + 15.rand + e.control / 2; e} )

	// .player.filter({|e| if(e.midicmd == \control and: (e.ctlNum == 1)) {e.control = 20 + 15.rand + e.control / 1; e}{e}})
	// .player({|e| e.collect{|i| if( i.midicmd == \control and: (i.ctlNum == 1) ) { var f = i.copy; f.control = 120; f  } { i } }})
	// .outEvents
	// .filterTrack(1, {|e|  e.debug("i: "); e.control=( 20 )})
	// // .filterTrack(24, {|e| e.do{|i| i.control_(100)}})
	// 
	.play(a)
	;
});
)

