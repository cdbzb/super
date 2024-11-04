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
["1", "5 6 5 4 5 4 3 4 3 2 3 2 5 6 5 4 5 4 3 4 3 2 3 2 5 6 5 4 5 4 3 4 3 2 3 2 5 6 5 4 5 4 3 4 3 2 3 2".dm(\c) ].addLine;
P(\click, music: { |p b e|
	[amp: 0.1,instrument: \hihat, dur: b.q].pp
});
P(\item, music: { |p b e|
	TempoClock.default = TempoClock(queueSize: 8192);
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

	;
	// MIDIItem2("_241101_092647")
	MIDIItem2("_241102_092338") //bendy thing in 5
	// =>
	// .record(a)
	.player({|e| e.reject{|i| i.midinote.notNil.if{ i.midinote >68 }{false}}})
	.play(a);
	MIDIItem2("_241102_095929")
	// .record(a)
	.player({|e| e.reject{|e| e.type == \setPoly and: e.midinote.notNil.if{e.midinote > 80}{false}} })
	.play(a)

	// .player.outEvents[55]
	// .copy.mk_(a)
	// {|m|
	// 	m.player({|a| a.reject{|e| e.midinote.notNil.if{(e.midinote < 60)}{true}}}).play(a);
	// // 	// .play(a);
	// 	m.player({|a| a.reject{|e| e.midinote.notNil.if{(e.midinote > 60)}{true}}}).play(p.twang);
	// }
	
	// .filterTrack(\noteOn, {|e|  (e.midinote < 60).if{e.mk = Song.twang}{e.mk = a}})
	// .play(Song.twang)
	// .play(a)

});

// MIDIIn.connectAll
// MIDIdef.noteOn(\test, {|a b c d| [a, b, c, d].postln})
	TempoClock.default = TempoClock(queueSize: 8192);
	// var c;
	Song.twang = MicroKeys(\twang);
	Song.twang.synth_( {
		
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
P(\itemTwo, music: { |p b e|
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
	// .play(p.twang)

	;
});
)

(
TempoClock.default = TempoClock(queueSize:8192);
//chordal songlet
//issue with noteoffs (when a second voice plays - need to allow mk.keys[num] have an array)
a = MicroKeys();
a.synth_( {
	var gate = \gate.kr(1);
	VarSaw.ar(\freq.kr(400) * ( \poly.kr / 64 + 1).midiratio , 0.1)
	=> MoogFF.ar(_, 
		CC(1, \freq.asSpec, a ).bus.ar => Gate.ar(_, gate) => _.lag2(0.1)  
	)
	* Env.adsr(CC(24, ControlSpec(0.05, 1.2)).bus.kr, 0.1, 0.5, 5).kr(2,gate:gate)
	=> PanAz.ar(5, _, \num.kr(0)/127 * 5)
}.asDefName).tuning_(\just);
MIDIItem2("_241102_102434")
.play(a);
MIDIItem2("bass_241102_102824")

// .record(a)
// .play(Song.twang)
.play(a);
b = MicroKeys(\sn);
b.synth_({|e|
	switch(e.num,
		60, {Synth(\bd_808)},
		62, {Synth(\sn_808)},
		64, {Synth(\hat_808)}
	)
});
MIDIItem2("sn_241102_141915")
// .save
// .record(b)
.play(b);
MIDIItem2("hat_241102_143700")
// .save
// .record(b)
.play(b)
)
( //working on quantization

m = MIDIItem2("_241102_102434").makeNotes
.select{|i x| i.midicmd==\noteOn and: i.midinote == 77 }
.select{|i x| x != 2}
// .do{|i| TempoClock.sched(i.timestamp, {i.mk_(a);i.play})} //this could be a.sched( array )
// .collect(_.timestamp);
;
~playFrom = {|from array|
	array.select{|e| e.timestamp >= from}.do {|e|
		TempoClock.sched(e.timestamp - from, {e.mk_(a); e.play}  )
	}
};

~playFrom.(m[0].timestamp, m)
)
(
Song(\quantizeMidiItems, []).current;
["one", 1!16.dm(\c), 0.7!16].addLine;
P(\click, music: { |p b e|
	[
		instrument: \hat_808,
		lag: 0.2,
	].pp
});
P(\item, music: { |p b e|
	a = MicroKeys();
	a.synth_( {
		var gate = \gate.kr(1);
		Pulse.ar(\freq.kr(400) * ( \poly.kr / 64 + 1).midiratio , 0.1, 0.1)
		=> MoogFF.ar( 
			_, 
			// CC(1, \freq.asSpec, b ).bus.ar => Gate.ar(_, gate) => _.lag2(0.1)  
			5000
		)
		* Env.adsr(CC(24, ControlSpec(0.05, 1.2)).bus.kr, 0.1, 0.5, 1).kr(2,gate:gate)
		=> PanAz.ar(5, _, \num.kr(0)/127 * 5)
	}.asDefName);
	a.tuning_(\just);
	b = MicroKeys(\saw);
	b.synth_(\sawSynth);
	m =MIDIItem2("line_241103_103346");
	// m.record(a);
	// m.play(a);
	n = "qqx x x xxx x xqqx x x xxx x xqqx x x xxx x xqqx x x xxx x x".beats;
	n = "q e eq q q q q qq ".beats;

	~notes = (m.initialRest ++ m.makeNotes.select{|e| e.midicmd == \noteOn});


	t = ~notes.collect(_.timestamp) ; //this shouldn't be necessary!!
	// t =  m.makeNotes.select{|e| e.midicmd == \noteOn}.collect(_.timestamp) ; //this shouldn't be necessary!!
	// ~durs = t.differentiate.drop(1); 
	~env = Env([0] ++ n.integrate, t.differentiate);
	// m.makeNotes.collect{|e| var f = e.copy.timestamp_( ~env[e.timestamp] + 0.40  ); f }

	// .do({ |i| TempoClock.sched(i.timestamp, {i.mk_(a); s.bind{ i.play }})});
	m
	// play(a)
	// .record(a)

	.player(
		{|e| 
			//quantize function here!!
			e.collect{|i|
				i.timestamp_( 
					~env[i.timestamp] 
					- (s.latency * 3)
					// s.latency_(0.2)
				); 
				i
			};
			// e
		}
	).play(a);

	~averageOffset = t.collect{|i| ~env[i] - i}.mean;


	// m.play(b);

	// m.makeNotes.collect{|e| e.timestamp}.collect{|e| [e, e * ~env[e]]}.do(_.postln)

 

});
)
