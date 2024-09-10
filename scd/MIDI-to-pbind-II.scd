(
KeyStage.func({ |v n c s|
	Synth(\stringyy, [freq: n.midicps, amp: v/128, release: 1])
});
m = MIDIItem("line_240910_103436", false);
// m.record
// m.stop
// m.save
n = MIDIItem("chords_240910_103619");
// n.record(true); m.asPbind.play
// n.stop
// n.save
n.asPbind <> [instrument: \stringyy].p => _.bubble ++ m.asPbind => Ppar(_) =>_.play


m.notes.q.play

)
(
// split notes!!
e = m.notes.collect({ |i| ( i.midinote > 73 ).if{var k = i.copy;k.instrument=\stringyy}{var j = i.copy; j.dur = Rest(j.dur); j}});
f = m.notes.collect({ |i| ( i.midinote <= 73 ).if{var k = i.copy; k.instrument = \harp; k}{var j = i.copy; j.dur = Rest(j.dur); j.instrument = \harp; j}});
f[6].dur=f[6].dur.value;
e[6].dur=Rest(e[6].dur);
f.q.play;e.q.play; n.asPbind.play
)
m.notes.collect(_.dur).round(0.01)
(
Song(\midiTest,[]).current;
["first line", "3 1 4 3 2 1 2 -7.5 1 3 1 4 3 2".dm(\c, \minor, \6), [0.685, 0.733, 0.606, 0.635, 1.336, 0.341, 0.343, 0.32, 0.379, 0.733, 0.71, 0.636, 0.692, 1.277] ].addLine;
P.tune();
Song.setTempoMap(\first, "e e e e ee x x x x e e e e eeee");
P(\chords, music:{
		n = MIDIItem("chords_240910_103619");
		n.asPbind <> [instrument: \stringyy].p => _.play
	}
);
P(\drum, music: { |p b e|
	[
		instrument: \bd_808,
		dur: "q q q ex x q q qq".asBeats.warpTo(e.tempoMap).q
	].pp
});
)
