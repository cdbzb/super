(
Song(\vstTest,[]).current;
["verse", [1, 3, 5, 4, 5, 4, 3, 2].dm(\c), 1.dup(8)].addLine;
// Song.setTempoMap(\verse, "e e x e e ex x e");
P.synthVVST(\xuan2,take:\lead, start:\verse,
	params: {|song durs key| [
		lyrics: "hi how are you r elephant chicken picket",
		midinote: [1, 3, 5, 4, 5, 4, 3, 2].dm(\c),
		dur: durs,
		lag: 0.15.dup(8)
	]},
	filters: _.morphPhonemes([\korean, \english, \mandarin], randomSeed:4) ,
	music: {|p b e|
		{
			e.bus
			=> FreeVerb.ar(_, 0.3, 1)
			=> Pan2.ar(_, 0)
			// / 4
		}.play
	}
);
P.synthVVST(\uni2, start:\verse,
	params: {|song durs key| [
		lyrics: "hi how are you r elephant chicken picket",
		midinote: [1, 3, 5, 4, 5, 4, 3, 2].dm(\g),
		dur: durs,
		lag: 0.15.dup(8)
	]},
	filters: {|sv| sv.morphPhonemes([\korean,\english, \mandarin], randomSeed:4) },
	music: {|p b e|
		{
			e.bus
			=> FreeVerb.ar(_, 0.5, 1)
			=> Pan2.ar(_, -0.7)
			// / 4
		}.play
	}
);
P(\drums, start:\verse, music: {|p b e|
	[
		instrument: [\bd_808, \bd_808, \sn_808].q(3),
		dur: "e e q".beats.q(3),
		amp: 4,
		lag:0.15
	].pp
});
["Two", [1, 3, 5, 4, 5, 4, 3, 2].dm(\c), 1.dup(8)].addLine;
P(\line, music: { |p b e|
	[
		freq: [3, 5.5, 7,7, 12, [ 12, 14 ], [ 12, 14 ], [ 12, 14 ], [ 13, 15 ], [ 13, 15 ], 7, 7, ].df(\c, 4).q,
		dur: "q q q q q E E E e e e e".beats.q,
		amp:0.3,
		out: Effect.bus({|i| Pan2.ar(i,1) },),
		lag:0.15,
		instrument:\sparkTriangle,
		att:0.3,
		rel:1
	].pp
});
// Song.setTempoMap(\verse, "e e x e e ex x e");
Song.lyric2= "under + a gou r underwear mighty chicken";
P(\bassline, music: { |p b e|
	[
		freq: [11, 7, 6, 5, 4, 13, 14].df(\c, [3,4]).q,
		att:[ 1.2, 2, 2, 2, 2, 0.05, 2 ].q,
		legato:[1,1,1,1,0.95,1,1].q,
		dur: "q q q q ex x qq".beats.q,
		lag:0.15,
		instrument:\sawSynthSustain,
		amp:0.5,
	].ppm
});
P.synthVVST(\kevin2, 1,
	params: {|song durs key| [
		lyrics:Song.lyric2,
		midinote: [1, 3, 5, 4, 5, 4, 3, 2].dm(\c),
		vocalMode:\Soft,
		singers:2,
		dur: durs,
		lag: 0.15.dup(8),
	]},
	filters: {|sv| sv.morphPhonemes([\korean, \english, \mandarin], randomSeed:4) },
	music: {|p b e|
		{
			e.bus
			=> FreeVerb.ar(_, 0.3, 1)
			=> Pan2.ar(_, 0)
			// * 0
			 
		}.play
	}
);
P.synthVVST(\uni, 1,
	params: {|song durs key| [
		lyrics:Song.lyric2,
		midinote: [1, 3, 5, 4, 5, 4, 3, 2].dm(\g),
		dur: durs,
		lag: 0.15.dup(8)
	]},
	filters: {|sv| sv.morphPhonemes([\korean,\english, \mandarin], randomSeed:4) },
	music: {|p b e|
		{
			e.bus
			=> FreeVerb.ar(_, 0.5, 1)
			=> Pan2.ar(_, -0.7)
			*2
			// / 4
		}.play
	}
);
P(\drums,  music: {|p b e|
	[
		instrument: [\bd_808, \bd_808, \sn_808].q(3),
		dur: "e e q".beats.q(3),
		amp: 4,
		lag:0.15
	].pp
});
["Three", [1, 3, 5, 4, 5, 4, 3, 2].dm(\c), 1.dup(8)].addLine;
P(\line, music: { |p b e|
	[
		freq: [3, 5.5, 6,6, 12, [ 12, 14 ], [ 12, 14 ], [ 12, 14 ], [ 13, 15 ], [ 13, 15 ], 7, 7, ].df(\c, 5).q,
		dur: "q q q q q E E E e e e e".beats.q,
		amp:0.1,
		out: Effect.bus({|i| Pan2.ar(i,1) },),
		lag:0.15,
		instrument:\sparkTriangle,
		att:0.3,
		rel:1
	].pp
});
// Song.setTempoMap(\verse, "e e x e e ex x e");
P.synthVVST(\choirZh2,take:\dbl, start:\Three,
	params: {|song durs key| [
		lyrics: "hi how are you - - - - ",
		midinote: [11, 5, 6, 5, 4, 3, 3, 2].dm(\c),
		dur: "q q e e e e q q".beats,
		lag: 0.15.dup(8),
		singers:8,
		spacing:0.3 
	]},
	filters: _.morphPhonemes([\korean, \english, \mandarin], randomSeed:4) ,
	music: {|p b e|
		{
			e.bus
			=> FreeVerb.ar(_, 0.3, 1)
			=> Pan2.ar(_, 0)
			// / 4
		}.play
	}
);

P(\bassline, music: { |p b e|
	[
		freq: [11, 7, 6, 5, 4, 13, 14].df(\c, [3,4]).q,
		att:[ 1.2, 2, 2, 2, 2, 0.05, 2 ].q,
		legato:[1,1,1,1,0.95,1,1].q,
		dur: "q q q q ex x qq".beats.q,
		lag:0.15,
		instrument:\sawSynthSustain,
		amp:0.5
	].ppm
});
P.synthVVST(\choirEn2,take:\lead, start:\Three,
	params: {|song durs key| [
		lyrics: "hi how are you r elephant chicken picket",
		midinote: [1, 3, 5, 4, 5, 4, 3, 2].dm(\c),
		dur: durs,
		lag: 0.15.dup(8),
		singers:8,
		spacing:0.1 
	]},
	filters: _.morphPhonemes([\korean, \english, \mandarin], randomSeed:4) ,
	music: {|p b e|
		{
			e.bus
			=> FreeVerb.ar(_, 0.3, 1)
			=> Pan2.ar(_, 0)
			// / 4
		}.play
	}
);
P.synthVVST(\uni2, start:\verse,
	params: {|song durs key| [
		lyrics: "hi how are you r elephant chicken picket",
		midinote: [1, 3, 5, 4, 5, 4, 3, 2].dm(\g),
		dur: durs,
		lag: 0.15.dup(8)
	]},
	filters: {|sv| sv.morphPhonemes([\korean,\english, \mandarin], randomSeed:4) },
	music: {|p b e|
		{
			e.bus
			=> FreeVerb.ar(_, 0.5, 1)
			=> Pan2.ar(_, -0.7)
			// / 4
		}.play
	}
);
P(\drums, start:\verse, music: {|p b e|
	[
		instrument: [\bd_808, \bd_808, \sn_808].q(3),
		dur: "e e q".beats.q(3),
		amp: 4,
		lag:0.15
	].pp
});
["Four", [1, 3, 5, 4, 5, 4, 3, 2].dm(\c), 1.dup(8)].addLine;
// Song.setTempoMap(\verse, "e e x e e ex x e");
P.synthVVST(\choirZh2,take:\dbl, start:\Three,tail:4,
	params: {|song durs key| [
		lyrics: "hi how are you - - - - ",
		midinote: [11, 5, 6, 5, 4, 3, 3, 2].dm(\c),
		dur: "q q e e e e q q".beats,
		lag: 0.15.dup(8),
		singers:8,
		spacing:0.3 
	]},
	filters: _.morphPhonemes([\korean, \english, \mandarin], randomSeed:5) ,
	music: {|p b e|
		{
			e.bus
			=> FreeVerb.ar(_, 0.3, 1)
			=> Pan2.ar(_, 0)
			// / 4
		}.play
	}
);

P(\bassline, music: { |p b e|
	[
		freq: [11, 7, 6, 5, 4, 13, 14].df(\c, [3,4]).q,
		att:[ 1.2, 2, 2, 2, 2, 0.05, 2 ].q,
		legato:[1,1,1,1,0.95,1,1].q,
		dur: "q q q q ex x qq".beats.q,
		lag:0.15,
		instrument:\sawSynthSustain,
		amp:0.5
	].ppm
});
P.synthVVST(\choirEn2,take:\lead, start:\Four,tail:4,
	params: {|song durs key| [
		lyrics: "hi how are you r elephant chicken picket",
		midinote: [1, 3, 5, 4, 5, 4, 3, 2].dm(\c),
		dur: durs,
		lag: 0.15.dup(8),
		singers:8,
		spacing:0.1 
	]},
	filters: _.morphPhonemes([\korean, \english, \mandarin], randomSeed:5) ,
	music: {|p b e|
		{
			e.bus
			=> FreeVerb.ar(_, 0.3, 1)
			=> Pan2.ar(_, 0)
			// / 4
		}.play
	}
);
P.synthVVST(\uni2, start:\Four,tail:4,
	params: {|song durs key| [
		lyrics: "hi how are you r elephant chicken picket",
		midinote: [1, 3, 5, 4, 5, 4, 3, 2].dm(\g),
		dur: durs,
		lag: 0.15.dup(8)
	]},
	filters: {|sv| sv.morphPhonemes([\korean,\english, \mandarin], randomSeed:5) },
	music: {|p b e|
		{
			e.bus
			// => FreeVerb.ar(_, 0.5, 1)
			=> Pan2.ar(_, 0.0)
			// / 4
		}.play
	}
);
P(\drums, start:\verse, music: {|p b e|
	[
		instrument: [\bd_808, \bd_808, \sn_808].q(3),
		dur: "e e q".beats.q(3),
		amp: 4,
		lag:0.15
	].pp
});
)
