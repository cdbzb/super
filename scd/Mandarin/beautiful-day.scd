(
Song(\beautiful,[]).current;
Song.pianoQuarters = 
MIDIItem(\foo).take(1)//.play(\default)
.fromNote(0, 98)
// .gui
.filter({|e| e.select{|i| i.midicmd == \noteOn}[[0, 9, 13, 19, 22, 31, 39, 44, 48, 55, 62,  70, 72, 80, 85, 94]]})
// .gui
.notes.collect{|i| i.timestamp}.differentiate;
["ch1", "r", Song.pianoQuarters[..8] ].addLine;
Song.setTempoMap("ch1", 1 ! 17);
P(\weeew,lag: Song.pianoQuarters[(..2)].sum + 0.2, music: { |p b e|
fork{
	5.do{|i|
		{
			Gendy1.arWidth(width:1.05 + (i /10),freq: Line.kr(400,100,3))
			/ (i + 1)
			* EnvGen.cutoff(2, 3)
			/5
			=> Pan2.ar(_, -1.rrand(1))
			=> HPF.ar(_, 100)
		}.play;
		0.5 => _.wait;
	}
}
});
P(\tamb,lag: Song.pianoQuarters[0], music: { |p b e|
	{
		var levels = [3,1,2,1] /3 => _.dq(inf);
		var durs =  
		1/4 ! 16 
		// * Song.quarter
		+ ( [1, -1] /80 => _.dup(8) ) //swing amt
		=> _.flat 
		=> _.warpTo(e.tempoMap.quantizeWindow(0.3, 8))
		=> _.dq(2);
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
		=> Out.ar(0, _)

	}.play;
	[
		instrument: \hat_808, 
		dur: "x x e x x e  x x x x x x e".beats.q(16) * ~tempo / 2,
		pan:0.5,
		amp: 0.05
	].pp;
	(instrument: \cymbalsDS, amp:0.02).play

});
P(\bd, music: { |p b e|
	[
		amp:0.5,
		rest: MuteFirst(),

		instrument: \kick_gentle, // make this a flam
		// amp:1.9,
		// strum: Pwhite(0.02, 0.04, inf),
		dur: [1] ++ [1, 1.5, 1, 0.5].dup(4).flat =>_.warpTo(e.tempoMap ++ e.tempoMap
			=>_.quantize()
			// .quantizeWindow(0.5, 8)
		) =>_.q
	].pp
});
P(\click, music: { |p b e|
	[
		amp: [ 0.4, 0.3 ] ,
		rest: MuteFirst(),

		instrument: \JWSnare, // make this a flam
		// amp:1.9,
		strum: Pwhite(0.02, 0.04, inf),
		dur: 1.dup(17).warpTo(e.tempoMap ++ e.tempoMap
			.quantize()
			// .quantizeWindow(0.5, 8)
		).q
	].pp
});
P(\keys, music: { |p b e|
	var keyFX = Effect.bus(BPF.ar(_, 1100, rq: 3.0));
	MIDIItem(\foo).take(1).fromNote(0, 100)
	.quantize(
		[ 0.57, 0.57 ].dup(9).flat, 
		nil, 
		{|notes| [(timestamp:0)] ++ notes[[0, 9, 13, 19, 22, 31, 39, 44, 48, 55, 62,  70, 72, 80, 85, 94 ]] }
	)
	.filter { |e| //remove bad note (should be method?) 
	  var note =  e.select{ |i| i.midicmd == \noteOn }[59];
	  var off = e.select{|i| i.midicmd == \noteOff and: (i.timestamp >= note.timestamp)}.sort({|x y| x.timestamp < y.timestamp})[0];
	  e.remove(note); e.remove(off);e
	 }
	 .filter{|e| e.collect{|i| i.params_((out: keyFX ))}}
	 .recalcSustains
	 // .gui
  .play(\default)
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
	phoneset: \xsampa

] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(\an, take: \lower, 
	// offset: Song.pianoQuarters[..4].sum,
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
["second halfCh1", "r", Song.pianoQuarters[8..15]].addLine;
P(\ktest, music: { |p b e|
	(instrument: \cymbalsDS).play
});
P.synthV(\xuan, take:  \lead ,  offset: Song.pianoQuarters[..8].sum, 
	pbind: 
	MIDIItem(\foo).take(1).fromNote(0, 75)
	.filter{|e| e.select{|i| i.midicmd==\noteOn}[[48, 51, 53, 58, 61, 62]]}
	// .gui
	.start_(Song.pianoQuarters[..7].sum)
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
		=> Pan2.ar(_,0)
		// => p.synthVTracks.at(e.key).()
	}.play
});
// P.synthV(\an, take: \lead2, //lag: 4, offset: true,
// 	pbind: 
// 	MIDIItem(\foo).take(1).fromNote(0, 200).notes[[63, 67, 69, 72, 76, 80, 83]]
// 	=> MIDIItemPlayer(_) 
// 	=> _.start_(0)//.play(\default)//1.714
// 	=> _.synthVPbind
// 	,
// 	params: {|p b| [
// 	lyrics: " r 美 好 天  回 忆 里 -",
//  // 美好天 (měi hǎo tiān) - Beautiful day
// 	pitchTake: 1,
// 	language: \Mandarin,
// ] }, music:{|p b e|
// 	{
// 		e.playbuf
// 		// => p.synthVTracks.at(e.key).()
// 	}.play
// });
// P.synthV(\an, take: \lower2, 
// 	pbind: 
// 	MIDIItem(\foo).take(1).fromNote(0, 200)
// 	// .gui
// 	.notes[[64, 66, 70, 73, 75, 81, 84	]]
// 	=> MIDIItemPlayer(_) 
// 	// =>_.gui
// 	=> _.start_(0)//.play(\default)//1.714
// 	=> _.synthVPbind
// 	,
// 	params: {|p b| [
// 	lyrics: " r 美 好 天  回 忆 里 -",
//  // 美好天 (měi hǎo tiān) - Beautiful day
// 	pitchTake: 2,
// 	language: \Mandarin,
// 	// phoneset: \xsampa
// ] }, music:{|p b e|
// 	{
// 		e.playbuf
// 		// => p.synthVTracks.at(e.key).()
// 	}.play
// });
{
	MIDIItem(\foo).take(1).filter({|e|e.select{|f| f.midinote == 5.dm(\c) or: (f.midinote == 6.dm(\c))}[(4..8)]}).start_(0).synthVPbind
}
)
(

  MIDIItem(\foo).take(1).fromNote(0, 98)
  .quantize( [ 0.57, 0.57 ].dup(8).flat, nil, {|notes| notes [[0, 9, 13, 19, 22, 31, 39, 44, 48, 55, 62,  70, 72, 80, 85, 94]]})
   .filter{|e| 
	  var note =  e.select{ |i| i.midicmd == \noteOn }[59];
	  var off = e.select{|i| i.midicmd == \noteOff and: (i.timestamp >= note.timestamp)}.sort({|x y| x.timestamp < y.timestamp})[0];
	  e.remove(note); e.remove(off);e
	 }
	 // .gui
	.recalcSustains
  .play(\sawSynth)
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
