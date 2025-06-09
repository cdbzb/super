(
a = MIDIItem("chords_250609_161522");
// a.play(\default)
// a.gui
~anchors = [0, 7, 12, 17, 28, 33, 38, 43, 55, 61, 67, 74, 86, 92, 98, 106, 111, 118, 124, 132, 140, 146, 152]
~anchors.size
a.notes[152].timestamp / 23 / 1.2;
~func = {|e x env| e.timestamp = e.timeStamp * 1.0352 + e.timestamp[env] / 2; e };
a.fromNote(0, 154).quantize( 1.2 ! 16, nil, {|notes| notes[~anchors]}).play(\sawSynth);
a.fromNote(0, 154).play(\harp)
b = a.fromNote(0, 154).quantize( 1.2 ! 16, { ~e.timestamp_( ~env[~e.timestamp] /2 ); ~e}, {|notes| notes[~anchors]})
b.fromNote(0).play(\sawSynth)
)
