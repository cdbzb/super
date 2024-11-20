
(
a =MicroKeys(\dd);
a.split( [
	[\sn_808, {|x| [62, 64].includes(x)}, (tone: 600)],
	[\bd_808, {|x| [60, 48].includes(x)}, (tone: 500)],
	[\hat_808, {|x| [67, 69].includes(x)},(tone: 100)]
]);
a.activate
)
a = MicroKeys()
a.synth_('default')
a.activate
a.dump
[ [1],[2],[3,5] ].flop
(
m = MIDIItem("drumset_241119_144955");
// .record(a)
m
.play(a)
)
(
MIDIItem("drumset_241119_155106")
// .save
// .record(a);
.play(a)
)
