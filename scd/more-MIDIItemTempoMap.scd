(
a=MicroKeys(\dd);
a.split( [
	[\sn_808, {|x| [62, 64].includes(x)}, (tone: 600)],
	[\bd_808, {|x| [60, 48].includes(x)}, (tone: 100)],
	[\hat_808, {|x| [67, 69].includes(x)},(tone: 100)],
	// [\default, nil, (pan:1)]
]);
m = MIDIItem("drumset_241119_155106")
.reject{|e| [67, 69].includes(e.midinote)}
// .fromNoteTo(18, 23)
)
m.play(a)
t = MIDIItemTempoMap(m.fromNoteTo(18, 23), beats:"xe x q xe x q".beats);
m.fromNoteTo(18, 23)[0].timestamp
m[23].timestamp
m.notes.collect(_.timestamp).indexOf(7.821978755)
m.notes.collect(_.timestamp).indexOf(9.437479806)
(
[ type:\mi, player:m.player, mk:a,from:18, to:23 ].p.play;
// [ type:\mi, player:n.player, mk:a,from:48, to:61 ].p.play;
t = MIDIItemTempoMap(m.fromNoteTo(18, 24), beats:"xe x q xe x q".beats);
// (lag: t[(0..6)/2].postln,instrument:\hihat, midinote: (50..56)).play
[ dur: "e e x x x x e e e x x".asBeats.warpTo(t.tempoMap).q(24),instrument:\hat_808, midinote: (50..56) ].p.play;
[
	dur: "e e e e x xe x xe ".beats.warpTo(t.tempoMap).q(10),
	instrument: \kick_gentle, vol:0.5
].pp;
[
	freq: [-1, 1].df('c').q(inf),
	dur: 0.5.dup(8).warpTo(t.tempoMap.quantize).q(inf),
	instrument:\bl
].pp;
[
	instrument:\sawSynthSustain,
	freq:[\r].q ++ [ 6, 7, 7.5, 11, 1].df(\c,3, \mixolydian).q(inf),
	dur: "qx".beats.warpTo(t.tempoMap).q ++ " e e e x qqx".beats.warpTo(t.tempoMap).q(inf) 

].ppm;
n=MIDIItem("drumset_241119_155106")
.player
	.filter({|e| e.do{|i| [67, 69].includes(i.midinote).not.if{i.amp_(0.1)}; e}})
	// .play(a)
=> {|i| [type:\mi, player:i.player
// .select{|e| [67, 69].includes(e.midinote)}
	,mk:a,  from:48, to: 61].pp }
)

(
t[t.beats] - t.quantize[t.beats] => _.plot
t[t.timesInBeats] - t.quantize()[t.timesInBeats] * 1000 => _.floor => _.do(_.postln)
=> _.plot
t.beats
)


// (lag: t.tempoMap[1].postln).play
//
//tempoMap:at gives me *time* at beat so totally not work as durationin a pbind!!!!!
//
m.fromNoteTo(18, 31).midiEvents.collect(_.timestamp.round(0.01)).differentiate.drop(1)
t.durs
t.beats
t.tempoMap.timesInBeats
t.tempoMap.timesInDurs
t[1]
t[(0..4) / 2]
t[0.75]
m.dur
t.tempoMap.env.plot
