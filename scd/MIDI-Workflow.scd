MIDIClient.init;
MIDIIn.connectAll;
(
a = MicroKeys({|e| {

	var gate = \gate.kr(1);
	Saw.ar( Vibrato.kr( e.num.midicps, 5, CC(1, ControlSpec(0, 0.02)).bus => In.kr(_) ))
	// / 10  
	* e.vel 
	* Env.asr(releaseTime: 0.2).kr(0,gate:gate) 
	=> MoogFF.ar(_, CC(24, \freq.asSpec).asBus)
	=> {|i| CombN.ar(i, 0.3, 0.25, 3)/3 + i}
	=> Out.ar(5.rand, _);
	Env.cutoff(1).kr(2, gate: gate)

}.play
});
a.tuning_(\just);
a.velCurve_(1);
a.play;
)

b = MIDIItem2(\chords);
b = MIDIItem2(\chords2)
b.record
b.stop
b.makeNotes
b.reset
b.midiEvents
b.save
c= b.asPbind(a)
CC.setValues(b.initialCCValues);
CC(24).bus.set(4000)
(type: \midi, midiout:MIDIOut(0), midiCmd:\noteOn).play
b.initialCCValues => CC.setValues(_)
c.patternpairs.do(_.postln)
c.trace.play
b.makeNotes
CC.initClass
(
d = MIDIItem2(\bassline, restFirst:true);
d.reset;
c.play; d.record;
d.stop
)
d.makeNotes
e = d.asPbind(a)
fork{ d.play; 0.2.wait;c.play }

b.initialCCValues_(CC.getValues)
b.save
b.record
b.stop
b.save

(
f = a.namedList.array.reverse.inject(I.d, _<>_);
b.makeNotes;
Event.addEventType(\foo, {var syn = f.(~amp * 120, ~midinote);fork{~sustain.wait; syn.release}});
e = b.notes.collect({|i| var j = i.copy; j.type = \foo; j.out = 2});
e.q <> (out: 2) => _.trace => _.play
)
//get CC levels
CC.all.keys.do({ |i| "%: %".format(i, CC.all[i].val).postln})

/*
24: 0.6875
1: 0.328125 
*/

b.save
b.dump
b.notes

