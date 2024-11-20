
(
a =MicroKeys(\dd);
// a = MicroKeys(\test).synth_(\sn_808);
a.split([ {|x| x == 62 or: (x == 64)}, {|x| x ==60 or: (x == 48)}, {|x| [67, 69].includes(x)} ], [\sn_808, \bd_808, \hat_808], [ (tone:900), (tone:300), (tone:500) ]); // a.synth_(
// 	
// (instrument: \sn_808, tone:300).play;
// 	[\sn_808, {|x| [62, 64].contains(x)}, [a: 1]],
// 	[\bd_808, {|x| [60, 48].contains(x)}, [a: 1]],
// 	[\hat_808, {|x| [67, 69].contains(x)}, [a: 1]]
// 	
//
// );
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

.player
.play(a)
)
(d, f)
