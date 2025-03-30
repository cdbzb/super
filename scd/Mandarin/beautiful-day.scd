(
Song(\beautiful,[]).current;
Song.pianoQuarters = 
MIDIItem(\foo).take(1).fromNote(0, 98)
// MIDIItem(\foo).take(1).fromNote(0, 98).gui
.filter({|e| e.select{|i| i.midicmd == \noteOn}[[0, 9, 13, 19, 22, 31, 39, 44, 48, 55, 62,  70, 72, 80, 85, 92]]})
// .gui
.notes.collect{|i| i.timestamp}.differentiate;
["ch1", "r", Song.pianoQuarters].addLine;
Song.setTempoMap("ch1", 1 ! 17);

P(\tamb,lag: Song.pianoQuarters[0], music: { |p b e|
	{
		var levels = [3,1,2,1] /3 => _.dq(inf);
		var durs =  
		1/4 ! 16 
		// * Song.quarter
		+ ( [1, -1] /80 => _.dup(8) ) //swing amt
		=> _.flat 
		=> _.warpTo(e.tempoMap.quantizeWindow(1, 8))
		=> _.dq(8);
		var triggers = TDuty.kr( durs, 0,1,gapFirst:0 );
		var energy = EnvGen.ar( Env.linen(0, 0.00, 0.015), triggers, doneAction:0   ) 
		* Demand.kr(triggers,0,levels 
		);
		Shakers.ar(3, energy:energy   , decay: 1).tanh
		* 8
		=> Pan2.ar(_, 0.8)
		// * EnvGen.cutoff(b.parse([4]).unbubble,3)
		=> DWGReverbC1C3.ar(_,mix:0.05)
		/12
		=> Pan2.ar(_,0.75)
		=> Out.ar(1, _)

	}.play;
	[
		instrument: \hat_808, 
		dur: "x x e x x e  x x x x x x e".beats.q(16) * ~tempo / 2,
		pan:0.5,
		amp: 0.05
	].pp;
	(instrument: \cymbalsDS, amp:0.02).play

});
P(\click, music: { |p b e|
	[
		amp: 0.4,
		rest: MuteFirst(),

		instrument: \JWSnare, // make this a flam
		dur: 1.dup(15).warpTo(e.tempoMap
			// .quantizeDft()
			.quantizeWindow(1, 8)
		).q
	].pp
});
P(\keys, music: { |p b e|
	MIDIItem(\foo).take(1).play(\default);
	// .filter({|e|e.select{|f| f.midinote == 5.dm(\c) or: (f.midinote == 6.dm(\c))}[(4..8)]}).start_(0)
});
P.synthV(\an, take: \lead, 
	pbind: 
	MIDIItem(\foo).take(1).filter({|e|e.select{|f| f.midinote == 5.dm(\c) or: (f.midinote == 6.dm(\c))}[(4..8)++(9..15)]}).start_(0)//.play(\default)//1.714
	.synthVPbind,
	params: {|p b| [
	lyrics: " r 美 好 天  回 忆 里 -",
 // 美好天 (měi hǎo tiān) - Beautiful day
	pitchTake: 1,
	language: \mandarin,

] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(\an, take: \endUpper, 
	pbind: 
	MIDIItem(\foo).take(1).fromNote(37, 50).filter{|e| e.select{|i| i.midicmd==\noteOn}[[2, 4, 7, 10]]}
	// MIDIItem(\foo).take(1).fromNote(1, 48).gui
	//.play(\default)//1.714
	.synthVPbind
	.patternpairs ++ [midinote: [1, 7, 7, 11 ].dm(\c)] => _.p,
	params: {|p b| [
	lyrics: " r   梦 不 停 r ",
	legato: [1, 1, 1,  3],
 // 美好天 (měi hǎo tiān) - Beautiful day
	pitchTake: 3,
	language: \Mandarin
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(\xuan, take:  \lead , 
	pbind: 
	MIDIItem(\foo).take(1).fromNote(0, 75)
	.filter{|e| e.select{|i| i.midicmd==\noteOn}[[48, 51, 53, 58, 61, 62]]}
	// .gui
	.synthVPbind
	.patternpairs
	++ [midinote: "-1 1 2 3 3 2 4".dm(\c)] => _.p
	,
	params: {|p b| [
	lyrics: "r 快 乐 的 日 子 像 -",// 流 水 不 停 歇",
	pitchTake: [ 1, 4 ],
	legato: [1, 1, 1, 1, 1,1,  9],
	language: \mandarin,
	phoneset: \xsampa
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(\an, take: \end, 
	pbind: 
	MIDIItem(\foo).take(1).fromNote(37, 50).filter{|e| e.select{|i| i.midicmd==\noteOn}[[2, 4, 7, 10]]}
	// MIDIItem(\foo).take(1).fromNote(1, 48).gui
	//.play(\default)//1.714
	.synthVPbind,
	params: {|p b| [
	lyrics: " r   梦 不 停 -",
	legato: [1, 1, 1, 1, 4],
 // 美好天 (měi hǎo tiān) - Beautiful day
	pitchTake: 1,
	language: \Mandarin
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(\an, take: \lower, 
	pbind: 
	MIDIItem(\foo).take(1).filter({|e|e.select{|f| f.midinote == 4.dm(\c) or: (f.midinote == 3.dm(\c))}[(4..8)++(9..15)]})
	// .midiEvents[0] //1.398 714-398
	.start_(0).synthVPbind,
	params: {|p b| [
	lyrics: " r 美 好 天  回 忆 里 -",
	lag: [0, (0.714-0.39), 0, 0 , 0, 0, 0 ],
 // 美好天 (měi hǎo tiān) - Beautiful day
	pitchTake: 2,
	
	language: \Mandarin
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
	}.play
});
{
	MIDIItem(\foo).take(1).filter({|e|e.select{|f| f.midinote == 5.dm(\c) or: (f.midinote == 6.dm(\c))}[(4..8)]}).start_(0).synthVPbind
}
)










//always works
MIDIItemPlayer( {|e|e.select{|f| f.midinote == 5.dm(\c) or: (f.midinote == 6.dm(\c))}}.(MIDIItem(\foo).midiEvents.deepCopy), MIDIItem(\foo) )
MIDIItem(\foo).take(1).play(\default);
MIDIItem(\foo).take(1).filter({|e|e.select{|f| f.midinote == 4.dm(\c) or: (f.midinote == 3.dm(\c))}[(4..8)]}).play(\default)
//intermittent
MIDIItem(\foo).take(1).filter({|e|e.select{|f| f.midinote == 5.dm(\c) or: (f.midinote == 6.dm(\c))}}).play(\default);
midiitem(\foo).take(1).filter({|e|e.select{|f| f.midinote == 4.dm(\c) or: (f.midinote == 3.dm(\c))}[(4..8)]}).play(\default)
MIDIItem(\foo).take(1).notes[(3..5)]=> MIDIItemPlayer(_, restFirst:true) => _.start_(0) => _.play(\default)
MIDIItem(\foo).filterNotes({|e| e[(3..4)]}).play(\default)


.midiEvents
.fromNote(2, 5)
.play(\default)
.fromNote(3, 6).play(\default);
// MIDIItem(\foo).take(1).play(\default)
)

a = MIDIItem(\foo)
a.fromNote(3)
[1]
a.takes
		MIDIItemPlayer(takes[num], this).recalcSustains
.bounds
.fromNote(4)
.play(\default);
a.take(1).
(
a = MIDIItem(\foo);
{|e| 

	var indices = a.noteIndices;
			var res =a.chaseCCs(indices[3]) 
			++ e[indices[3]..indices[5- 1]].setDurs;

			{
				indices[5+ 1].notNil.if {
					res.drop(-1)
				}{
					res
				}
			}
}.( a.midiEvents).() => _.class

)
)
.respondsTo(\fromNote)
.fromNote(3,5)
			a.chaseCCs(a.noteIndices[3]) 
.gui
			a[a.noteIndices[3]..a.noteIndices[5 - 1]].setDurs;
MIDIItem(\foo) .take(1) .select({|i| i.midinote == 3.dm(\c) or: (i.midinote == 4.dm(\c))}).gui
.recalcSustains.play(\default)
.gui
.gui
.play(\default);
