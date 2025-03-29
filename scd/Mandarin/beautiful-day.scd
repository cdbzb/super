(
Song(\beautiful,[]).current;
["ch1", "r"].addLine;
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
	language: \Mandarin
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
