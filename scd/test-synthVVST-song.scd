(
Song(\vstTest,[]).current;
["verse", [1, 3, 5, 4, 5, 4, 3, 2].dm(\c), 1.dup(8)].addLine;
Song.setTempoMap(\verse, "e e x e e ex x e");

P.synthVVST(\xuan2, start:\verse,
	params: {|song durs key| [
		lyrics: "hi how are you r elephant chicken",
		midinote: [1, 3, 5, 4, 5, 4, 3, 2].dm(\c),
		dur: durs,
		lag: 0.15.dup(8)
	]},
	filters: {|sv| sv.morphPhonemes([\korean, \english, \mandarin], randomSeed:4) },
	music: {|p b e|
		"MUSIC".postln;
		{
			e.bus
			=> FreeVerb.ar(_, 0.3, 1)
			=> Pan2.ar(_, 0)
			/ 4
		}.play
	}
);


P.synthVVST(\uni, start:\verse,
	params: {|song durs key| [
		lyrics: "hi how are you r elephant chicken",
		midinote: [1, 3, 5, 4, 5, 4, 3, 2].dm(\g),
		dur: durs,
		lag: 0.15.dup(8)
	]},
	filters: {|sv| sv.morphPhonemes([\korean, \mandarin], randomSeed:7) },
	music: {|p b e|
		{
			e.bus
			=> FreeVerb.ar(_, 0.5, 1)
			=> Pan2.ar(_, -0.7)
			/ 4
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
