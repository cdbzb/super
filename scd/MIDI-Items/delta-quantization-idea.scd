(
a=MicroKeys(\dd);
a.split( [
	[\sn_808, {|x| [62, 64].includes(x)}, (tone: 600)],
	[\bd_808, {|x| [60, 48].includes(x)}, (tone: 100)],
	[\hat_808, {|x| [67, 69].includes(x)},(tone: 100)],
	// [\default, nil, (pan:1)]
]);
m = MIDIItem("drumset_241119_155106");
n = m
.player
.fromNoteTo(17, 31)
// .select{|e| [67, 69].includes(e.midinote)}
.play(a);

~length = m.player[32].timestamp - m.player[17].timestamp
// (type:\mi, mk:a, player:m.player, from:17, to:31, tempo:1).play


)
(

m = MIDIItem("drumset_241119_155106") .player
// .reject{|e| [67, 69].includes(e.midinote)}
.fromNoteTo(17, 31)
.reject{|e| e.midicmd==\noteOff}
// .filter({|e| e.select{[48, 60].includes(e.midinote)}})
;
// m.play(a);
p = MIDIItemTempoMap(m,
	beats:
	"ex x q ex x q".beats * m.dur / 4  ,
	// choiceFunc: {|e| e.reject{|e| [67, 69].includes(e.midinote)}}
);

/*
p.times
p.beats
m.dur
p.env.plot
p.env.cs
p.env[3]
p.env[p.beats]
n.midiEvents.do{|e| e.midicmd.bubble ++e.dur ++ e.type ++ e.timestamp =>_.postln}
m.midiEvents.q.play
m.player.dur
m.player.play(a)
*/
p.offsets.do(_.postln);
n = m.player.fromNoteTo(17, 31)
.reject{|e| [67, 69].includes(e.midinote)}
.reject{|e| e.type == \rest}
.reject{|e| e.midinote.isNil}
.quantize("ex x q ex x q".beats, 
	// {|e| e},
	// choiceFunc: {|e| e.reject{|e| [67, 69].includes(e.midinote)}}
)
.play(a)


// m.play(a)


)
m.player.fromNoteTo(17, 31).midiEvents.collect(_.dur).reject(_.isNil).sum
m.dur
m.midiEvents.collect({|e| e.mk_(a)}).q(inf).play
.play
m.play(a)
