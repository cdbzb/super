(
a=MicroKeys(\dd);
a.split( [
	[\sn_808, {|x| [62, 64].includes(x)}, (tone: 200)],
	[\bd_808, {|x| [60, 48].includes(x)}, (tone: 100)],
	[\hat_808, {|x| [67, 69].includes(x)},(tone: 100)],
	// [\default, nil, (pan:1)]
]);
m = MIDIItem("drumset_241119_155106")
.reject{|e| [67, 69].includes(e.midinote)};

[ type:\mi2, player: 
	[
		m.fromNoteTo(18, 23).setParams (
			[
				tone: ([500, 200, 100, 200, 100, 100, 100, 100, 100, 100, 100, 100].q(inf)),
				out: [ Effect.bus({|i| FreeVerb.ar(i,0.5,0.9) }),0,0,0,0,0,].q
			]
		),
		m.fromNoteTo(18, 23).setParams (
			[
				tone: ([450, 200, 100, 200, 100, 100, 100, 100, 100, 100, 100, 100].q(inf)),
				out: [ Effect.bus({|i| FreeVerb.ar(i,0.5,0.9) => Pan2.ar(_, 1)}),0,0,0,0,0,].q
			]
		),
	].q(inf)
	, mk:a  
].p.play;

// move setParams into params field in typw \mi2 Event


t = MIDIItemTempoMap(m.fromNoteTo(18, 23), beats:"xe x q xe x q".beats);

// t.bounds //hoho!!

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
	pulse:0.8,
	freq:[\r].q ++ [ 6, 7, 7.5, 11, 1].df(\c,3, \mixolydian).q(inf),
	dur: "qx".beats.warpTo(t.tempoMap).q ++ " e e e x qqx".beats.warpTo(t.tempoMap).q(inf) 

].ppm;

n=MIDIItem("drumset_241119_155106")
.select({|e| [67, 69].includes(e.midinote)})
.copyBounds(m.fromNoteTo(18, 23))
=> {|i| [type:\mi2, player:i ,mk:a  ].pp }
)

(
t[t.beats] - t.quantize[t.beats] => _.plot
t[t.timesInBeats] - t.quantize()[t.timesInBeats] * 1000 => _.floor => _.do(_.postln)
=> _.plot
t.beats
)


// (lag: t.tempoMap[1].postln).play
//
//tempoMap:at gives me *time* at beat so totally not work as duration in a pbind!!!!!
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
