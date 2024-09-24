MIDIClient.init;
MIDIIn.connectAll;
CC.initClass
(
a = MicroKeys();
a.func = {|e| {

	var gate = \gate.kr(1);
	Saw.ar( Vibrato.kr( e.num.midicps, 5, 
		CC(1, ControlSpec(0, 0.02)).asControl(\freq, 0.02)
	))
	// / 10  
	* e.vel 
	* Env.asr(releaseTime: 0.2).kr(0,gate:gate) 
	=> MoogFF.ar(_, CC(24, \freq.asSpec).asBus)
	=> {|i| CombN.ar(i, 0.3, 0.25, 3)/3 + i}
	=> Out.ar(5.rand, _);
	Env.cutoff(1).kr(2, gate: gate)
}.play };
a.tuning_(\just);
a.velCurve_(1);
a.play;
)

m = CC(1)
m.ctl
		MIDIdef.cc(\fooo, {|v| synth.set(, v) }, 1);

b = MIDIItem2(\chords);
b.initialCCValues
b.initialCCValues_(CC.getValues)
b.save
b.record
b.stop
b.save
CC(24).bus.get
MIDIdef.all
b.play

c = MIDIItem2(\ccOverdub);


c.makeCCs.ccTracks[24]
c.ccPbind(24).trace.play
CC(24).bus.scope
s.makeWindow
c.ccEvents(24).collect(_.asKeyValuePairs).flop.collect{|i| ( i[0].class == Symbol ).if { i[0] }{ i.q }}
(
c.midiEvents.select({|e| e.midicmd == \control})
.sort({ |i j| i.ctlNum < j.ctlNum})
.sort({|i j| i.timestamp < j.timestamp})
.collect(_.timestamp).differentiate
)
[1, 5, 3].sort({|i j| i<j})
c.midiEvents.sort[]
p = c.ccsAsArraysOfPoints[24].sort({|i j| i.x<j.x})
p.collect(_.y).plot.domain_(p.collect(_.x)).domainSpecs_([619, 1500].asSpec)

c.record; b.play;
c.ccEvents(24).collect(_.asKeyValuePairs).flop.collect{|i| (i[0].class==Symbol).if {i[0]}{i.q}}
c.ccEvents(24).eventsToPatternPairs
c.stop
c.save

(
d = c.midiEvents.select{ |e| e.midicmd == \control};
~durs = d.collect{|e| e.timestamp}.differentiate.drop(1) ++ 1;
e = d.copy.do{|i| i.dur = ~durs.removeAt(0)};
// b.play;e.q.play
g.q.play;e.q.play
)


CC.getValues

b.save
b.dump
b.notes
Bus
