(
a = MIDIItem("chords_250609_161522");
// a.play(\default)
// a.gui
~anchors = [0, 7, 12, 17, 28, 33, 38, 43, 55, 61, 67, 74, 86, 92, 98, 106, 111, 118, 124, 132, 140, 146, 152, ];
// a.notes[152].timestamp / 23 / 1.2;
~func = {|e x env| e.timestamp = e.timeStamp * 1.0352 + e.timestamp[env] / 2; e };
c = a.fromNote(0, 157).quantize( 1.2 ! 23, nil, {|notes| notes[~anchors]});
c.start_(0).play(\harp);
a.from(0, 150).play(\sawSynth)
a.start
// a.fromNote(1, 157).play(\default);
b = a.fromNote(0, 157).quantize( 1.2 ! 23, { ~e.timestamp_( ~env[~e.timestamp -a.fromNote(0, 157).start  ]  ) }, {|notes| notes[~anchors]});
b = a.fromNote(0, 157).quantize( 1.2 ! 23, { ~e.timestamp_( ~quantized + 0.1.rrand(-0.1)  ) }, {|notes| notes[~anchors]});
d = a.fromNote(0, 157).quantize( 1.2 ! 23, { ~e }, {|notes| notes[~anchors]});
b.play(\harp); c.play(\default)
)
// a.fromNote(0, 154).midiEvents.select{|i| i.timestamp==0} .quantize( 1.2 ! 16, nil, {|notes| notes[~anchors]}).start
// a.fromNote(0, 154).play(\harp)
a.fromNote(1, 157).quantize( 1.2 ! 23, { ~e.timestamp_( ~env[~e.timestamp - a.fromNote(1, 7).start ]  ) }, {|notes| notes[~anchors]})
a.fromNote(1, 5).start
.play(\harp)
a.start
b.fromNote(0).play(\sawSynth)
a.play(\default);d.play(\sawSynth)
a.notes.select {|i| i.type == \rest}[0]
a.notes[0]
a.fromNote(0, 157).start
b.fromNote(0, 157).start
c.fromNote(0, 157).start


b.notes.collect(_.timestamp)
d =b.notes.collect(_.timestamp).differentiate.drop(1)
d = d - c.notes.collect(_.timestamp).differentiate.drop(1)

- c.notes.collect(_.timestamp).differentiate.drop(1) => _.select({| i| i> 0.000000001})

b.notes[0].keysDo{|i| [i, b.notes[0][i].postln]}
[b, c].do{|i| i.notes[0].asArray.pairsDo{|i j| [i,j].postln}}
a.notes[1].timestamp
b.start
c.start
a.fromNote(1).start
b.fromNote(0).start

