().play
MIDIIn.connectAll;
(
a = MicroKeys();
a.synth_({|e| {
	var gate = \gate.kr(1);
	VarSaw.ar(e.num.midicps * ( \poly.kr / 64 + 1).midiratio , 0.1)
	=> MoogFF.ar(_, 
		CC(1, \freq.asSpec).bus.ar => Gate.ar(_, gate) => _.lag2(0.1)  
		)
		* Env.adsr(CC(24, ControlSpec(0.05, 1.2)).bus.kr, 0.1, 0.5, 5).kr(2,gate:gate)
		=> PanAz.ar(5, _, e.num/127 * 5)
}.play
	
});
a.tuning_(\just);
b = MIDIItem2(\test3, mk: a);
)
CC(1).bus.get
b.record
b.reset
b.stop
b.muteCC(1)
fork{b.midiEvents.do{|i| i.play; i.postln; 0.5.wait}}
b.midiEvents.select({|e| e.ctlNum == 1})
CC(24).bus.scope
b.playRaw

b.playbackFilters
Object
b.muteCC(24).playRaw
b.deepCopy.playRaw
b.playbackFilters
=== b.muteCC(1)
CC.all
CC(24)
b.ccTracks[1].unbubble.collect{|i| i.asAssociations.sort.asPairs.flop}
	.collect{|i| ( i[0].class == Symbol ).if { i[0] }{ i.q } }}
b.ccEvents(1)
b.stop
b.playRaw
b.playBackFilters
b.ppar
b.save
(
Ppar(
	[
		// b.ccPbinds[0]
		// ,
	z = 	b.notesPbind
		,
	y = 	b.ccPbinds
	[z,y].flat => Ppar(_) => _.play
	b.playRaw
	]
)
	)
b.ccTracks[\poly]
b.playRaw
b.play
[b.notesPbind] ++ 
b.ccPpar
b.ccPpar.play
b.ccTracks.keys
b.ccPbind(\bend)

.do({b.ccPbind(_).postln})
b.p
b.ccPbind(1).trace.play
b.play
b.mieventsToPatternPairs
b.notesPbind.play
b..keys.do(b.ccPbind(_).postln)
b.ccTracks.keys.collect{|i|try{ b.ccPbind(i); };i.postln }
CC.all
b.ccEvents(1)
b.ccPbind(1).play
[].q
b.ppar
b.makeCCs
b.reset
b.play

s.reboot
b.notesPbind.play
b.ppar.play
(
~on = b.notes.select({|e| e.midicmd == \noteOn}).copy;
~off = b.notes.select({|e| e.midicmd == \noteOff}).copy;
~findMatch = {|midinote| ~off.collect{|e| e.midinote}.indexOf(midinote)}; //returns index
~on.do{|e| var match = ~off.removeAt(~findMatch.(e.midinote)).postln; e.sustain = match.timestamp - e.timestamp; };
~on.collect(_.timestamp).differentiate.drop(1) ++ 1 => _.do{|i x|
	~on[x].dur = i
};
~on.q.play
)
~on[0].play
