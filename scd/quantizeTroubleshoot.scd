(
// first check/fix first note issue
a = MicroKeys();
a.synth_(\default);
a.activate;

m = MIDIItem("test_241122_092623");
m
// .save
// .record(a)
.player
.fromNoteTo(0, 9)
// .midiEvents[19]
.quantize(
	"q q  e e e e q e q".beats
)
.recalcSustain
.play(a)
)

(
// a.activate
// m.player.fromNoteTo(17, 31).select{|e| [62, 64, 60, 48].includes(e.midinote)}.play(a);
m = MIDIItem("drumset_241119_155106");
Song(\drumStuff_241121_144124, []).current;
m.player.fromNoteTo(17, 32).addLine("pattern 1", {|notes| notes.select{|e| [62, 64, 60, 48].includes(e.midinote)} });
Song.durs.filter('pattern 1', {|e| var last = e.last; e.dropLast ++ (last - 0.145)});
Song.setTempoMap('pattern 1', "ex x q ex x q".beats);
P(\midiItemTwo, music: { |p b e|
	var	m = MIDIItem("drumset_241119_155106");
	var a =MicroKeys(\dd);
	a.split( [
	[\sn_808, {|x| [62, 64].includes(x)}, (tone: 600)],
	[\bd_808, {|x| [60, 48].includes(x)}, (tone: 100)],
	[\hat_808, {|x| [67, 69].includes(x)},(tone: 100)],
	// [\default, nil, (pan:1)]
]);
	m
	.player
	// .midiEvents[1]
	// .filter({|e| e.collect{|f| f.amp.notNil.if{f.amp = f.amp/220};f}})
	.fromNoteTo(17, 31)
	.reject{|e| [67,69].includes(e.midinote)}
	.reject{|e| e.type == \rest}
	.reject{|e| e.midinote.isNil}
	.quantize("ex x q ex x q ".beats.warpTo(e.tempoMap
		// .quantize(0.99)
	))
		// { ~e.timestamp_(~env[~e.timestamp] + 0.05.rrand(-0.05))},
		// {~e.ddd = (\a); ~e},
	.play(a);

});
P(\testTwo, music: { |p b e|
	[
		// dur: "ex xq ex xq".beats.warpTo(e.tempoMap).q,
		dur: "e*8".beats.warpTo(e.tempoMap.quantizeDft()).q
	].pp
});
P(\chords, music: { |p b e|
	var a = MicroKeys(\chord);
	var m = MIDIItem("chords_241122_094938");
	a.synth_(\sawSynthSustain);
	a.velCurve_(1, [0,0.3])
	// a.activate;
	;
m
// .save
// .record(a, 0.2)
.play(a)

});
P(\midiItem,lag:0, music:{
	var a = MicroKeys(\dd);
	m.player
	// .midiEvents[1]
	// .filter({|e| e.collect{|f| f.amp.notNil.if{f.amp = f.amp/220};f}})
	.fromNoteTo(17, 31)
	.select{|e| [67,69].includes(e.midinote)}
	// .quantize("".beats,  )
	.play(a);

});

P(\test, music: { |p b e|
	[
		freq: [1, 11, 1, 11].df(\d, 3).q,
		instrument: \sawSynthSustain,
		dur: "q q ".asBeats.warpTo(e.tempoMap).q
		// instrument: \hat_808
	].ppm
});
m.player.fromNoteTo(17, 31).addLine("pattern 2", {|notes| notes.select{|e| [62, 64, 60, 48].includes(e.midinote)} });
Song.setTempoMap('pattern 2', "ex x q ex x x".beats);
P(\midiItemTwo, music: { |p b e|
	var	m = MIDIItem("drumset_241119_155106");
	var a = MicroKeys(\dd);
	m.player
	// .midiEvents[1]
	// .filter({|e| e.collect{|f| f.amp.notNil.if{f.amp = f.amp/220};f}})
	.fromNoteTo(17, 31)
	.reject{|e| [67,69].includes(e.midinote)}
	.reject{|e| e.type == \rest}
	.reject{|e| e.midinote.isNil}
	.quantize("ex x q e xx q ".beats.warpTo(e.tempoMap) ,
	// 	// { ~e.timestamp_(~env[~e.timestamp] + 0.05.rrand(-0.05))},
	// 	// {~e.ddd = (\a); ~e},
	)
	.play(a);

});
P(\testTwo, music: { |p b e|
	[
		// dur: "ex xq ex xq".beats.warpTo(e.tempoMap).q,
		dur: "e*8".beats.warpTo(e.tempoMap.quantizeDft()).q
	].pp
});
P(\midiItem,lag:0, music:{
	m.player
	// .midiEvents[1]
	// .filter({|e| e.collect{|f| f.amp.notNil.if{f.amp = f.amp/220};f}})
	.fromNoteTo(17, 31)
	.select{|e| [67,69].includes(e.midinote)}
	// .quantize("".beats,  )
	.play(MicroKeys(\dd));

});

P(\test, music: { |p b e|
	[
		freq: [1, 11, 1, 11].df(\d, 3).q,
		instrument: \sawSynthSustain,
		dur: "q q ".asBeats.warpTo(e.tempoMap).q
		// instrument: \hat_808
	].ppm
});
)
