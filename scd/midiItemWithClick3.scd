(

b = MicroKeys();
b.synth_( {
	var gate = \gate.kr(1);
	Pulse.ar(\freq.kr(400) * ( \poly.kr / 64 ).midiratio , 0.1, 0.1)
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

~item = MIDIItem("withClick_241027_091120").play(a)
~item2 = MIDIItem("_241027_093140", mk: b);
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
		VarSaw.ar(\freq.kr(400) * ( \poly.kr / 64 ).midiratio , 0.1)
		=> MoogFF.ar(_, 
			CC(1, \freq.asSpec, a ).bus.ar => Gate.ar(_, gate) => _.lag2(0.1)  
		)
		* Env.adsr(CC(24, ControlSpec(0.05, 1.2)).bus.kr, 0.1, 0.5, 5).kr(2,gate:gate)
		=> PanAz.ar(5, _, \num.kr(0)/127 * 5)
	}.asDefName).tuning_(\just)

	;
	// MIDIItem("_241101_092647")
	MIDIItem("_241102_092338") //bendy thing in 5
	// =>
	// .record(a)
	.player({|e| e.reject{|i| i.midinote.notNil.if{ i.midinote >68 }{false}}})
	.play(a);
	MIDIItem("_241102_095929")
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
		Pulse.ar(\freq.kr(400) * ( \poly.kr / 64 ).midiratio , 0.1)
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
	MIDIItem("_241030_130953") // .player.midiEvents.select{|e| e.type == \setDamper}
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
	VarSaw.ar(\freq.kr(400) * ( \poly.kr / 64 ).midiratio , 0.1)
	=> MoogFF.ar(_, 
		CC(1, \freq.asSpec, a ).bus.ar => Gate.ar(_, gate) => _.lag2(0.1)  
	)
	* Env.adsr(CC(24, ControlSpec(0.05, 1.2)).bus.kr, 0.1, 0.5, 5).kr(2,gate:gate)
	=> PanAz.ar(5, _, \num.kr(0)/127 * 5)
}.asDefName).tuning_(\just);
MIDIItem("_241102_102434")
.play(a);
MIDIItem("bass_241102_102824")

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
MIDIItem("sn_241102_141915")
// .save
// .record(b)
.play(b);
MIDIItem("hat_241102_143700")
// .save
// .record(b)
.play(b)
)
( //working on quantization

m = MIDIItem("_241102_102434").makeNotes
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
		// lag: 0.2,
	].pp
});
P(\item, music: { |p b e|
	a = MicroKeys();
	a.synth_( {
		var gate = \gate.kr(1);
		Pulse.ar(\freq.kr(400) * ( \poly.kr / 64 ).midiratio , 0.1, 0.1)
		=> MoogFF.ar( 
			_, 
			// CC(1, \freq.asSpec, b ).bus.ar => Gate.ar(_, gate) => _.lag2(0.1)  
			5000
		)
		* Env.adsr(CC(24, ControlSpec(0.05, 1.2)).bus.kr, 0.1, 0.5, 1).kr(2,gate:gate)
		=> PanAz.ar(5, _, \num.kr(0)/127 * 5)
	}.asDefName);
	a.tuning_(\just);
	c = MicroKeys(\saw);
	c.synth_(\sawSynth);
	m =
	MIDIItem("line_241103_103347");
	// m.record(a);
	// m.play(a);
	
	n = "qqx x x xxx x xqqx x x xxx x xqqx x x xxx x xqqx x x xxx x x".beats;
	n = "q q q q q q q qq q q q q q q q ".beats; //where the notes should end up

	~notes = ( m.makeNotes.select{|e| e.midicmd == \noteOn});

	t = ~notes.collect(_.timestamp) ; //where the notes are
	// t =  m.makeNotes.select{|e| e.midicmd == \noteOn}.collect(_.timestamp) ; //this shouldn't be necessary!!
	// ~durs = t.differentiate.drop(1); 
	~env = Env([0] ++ n.integrate, t.differentiate);
	~averageOffset = t.collect{|i| ~env[i] - i}.mean;
	m
	// play(a)
	// .record(a)
	.player
	.collect( {|i|
			i.timestamp_( 
				~env[i.timestamp] + ~averageOffset 
			); 
			i
		};
	)
	.play(a);
	// m.filter({|e| e.amp_(0.01)}).play(c)
	// ;

});
)
(
m.play(a);
n = MIDIItem("_241105_083448");
n.synth_(\default);
n
// .r.ecord(b)
.play(b)

)
(
m.player.quantize(
	"q q q q q q q q q q ex q q e e q".beats, 
	choiceFunc: {|notes| notes[[0, 3, 4, 5, 6, 7, 8, 9, 10, 11]]},
	recalcSustains: true
)
.play(a)
)
(
m.player.quantize(
	"q q e e q q q q q q ex q q e e q e".beats, 
	{ ~e.timestamp_(~env[~e.timestamp] + 0.05.rrand(-0.05))},
	choiceFunc: {|notes| notes[[0, 3, 4, 5, 6, 7, 8, 9, 10, 11]]},
	recalcSustains: true
)
	.play(a)
	// .outEvents.select{|e| e.midicmd==\noteOn}[2]
	
)
)
(
Song(\midiItemTest, []).current;
    Song.mk = MicroKeys();
	Song.mk.synth_( {
		var gate = \gate.kr(1);
		Pulse.ar(\freq.kr(400) * ( \poly.kr / 64 ).midiratio.poll , 0.1, \amp.kr(0.1))
		=> MoogFF.ar( 
			_, 
			// CC(1, \freq.asSpec, b ).bus.ar => Gate.ar(_, gate) => _.lag2(0.1)  
			5000
		)
		* Env.adsr(CC(24, ControlSpec(0.05, 1.2)).bus.kr, 0.1, 0.5, 1).kr(2,gate:gate)
		=> PanAz.ar(5, _, \num.kr(0)/127 * 5)
	}.asDefName);
	Song.mk.tuning_(\just);

	MIDIItem("_241102_092338").player.addLine("test");
	/*
	["test"].addLine
	*/

	Song.setTempoMap("test", "eeee e eee g e e eee g e e eee g e e eee e e");
	P.tune(_ <> [ instrument: \stringyy ].p);
	Song.durs[\test].list;
	P(\cymbals, music: { |p b e|
		e.tempoMap.beats.postln;
		[
			dur: "eeeee qqe qqe qqe qqe qq".beats.warpTo(e.tempoMap).q,
			instrument: \cymbalsDS,
			amp: 0.01, 
			rest: [\r, 1, 1, 1, 1].q
		].pp
	});
	P(\item,  music: { |p b e|
	// TempoClock.default = TempoClock(queueSize: 8192)	;
	MIDIItem("_241102_092338").player({|e| e.collect{|i| i.amp_(0.03).postln}}).play(p.mk)
	// MIDIItem("_241102_092338").player.outEvents.select{|e| e.type == \rest}
	});
)
