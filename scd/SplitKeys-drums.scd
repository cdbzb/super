(
a =MicroKeys(\dd);
a.split( [
	[\sn_808, {|x| [62, 64].includes(x)}, (tone: 600)],
	[\bd_808, {|x| [60, 48].includes(x)}, (tone: 100)],
	[\hat_808, {|x| [67, 69].includes(x)},(tone: 100)],
	// [\default, nil, (pan:1)]
]);
a.activate
)
b = try{ a.noteOnFunction.(60,60) }
().play
b
a.test
(
m = MIDIItem("drumset_241119_144955");
// .record(a)
m
.play(a)
)
(
m = MIDIItem("drumset_241119_155106");
// m.player.noteIndices[8];
// m.player.filter{|e| e[6..m.player.noteIndices[8]]}
m.player.noteIndices[5]
m.player.filter({|e| ~indices.postln; e[ ~indices[2]..~indices[8] ]}).play(a)
m.player.filter({|e| ~indices.postln; e[ ~indices[(2..8)] ]}).play(a)
m.player.filter({|e| ~indices.postln; e[ ~indices[9]..~indices[16] ]}).play(a)
~len = m.player.filter({|e|  e[ ~indices[17]..~indices[24] ]}).midiEvents.collect(_.timestamp).differentiate.drop(1).sum
fork{
	loop{
		m.player.filter({|e|  e[ ~indices[17]..~indices[23] ]}).play(a);
		~len.wait;
	}
}
Event.addEventType(\mi, {  ~player.filter({|e| e[(~from..~to)] }).play(~mk) }, )
Event.addEventType(\test, {~a.().postln}, (a: {~b+1}, b:0))

(type:\mi, mk: a, player: m.player, from:17,to: 23).play
[ type:\mi, mk: a, player: m.player, from:[ 17, 24 ].q(inf),to: [ 23, 31 ].q(inf), stretch:[ 1.01, 1.03 ].q(inf) ].pp
m.player.fromNoteTo(9, 18).play(a)
Event.addEventType(\mi, {~dur=5; ~player.fromNoteTo(~from, ~to).play(~mk) })
Event.addEventType(\mi, {~dur=~player[~to+1].timestamp - ~player[~from].timestamp; ~player.fromNoteTo(~from, ~to).play(~mk) }, parent: (type: \durEvent))
(type: \durEvent, dur:3, stretch:5).play

// .save
// .record(a);
)
