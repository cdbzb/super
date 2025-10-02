
(
Song(\kimchi,[]).current;
["english", "1 2 3 4 3 4 2 5".dm(\g, 4)].addLine;
P.synthV(\xuan2, take: \lead, version: 2, params: {|p b| [
	lyrics: "I would like some kimchi + and rice",
	language: \english,
	phoneset:\arpabet,
	// phonesetOverride:\arpabet,
	pitchTake: 1,
	// languageOverride: \Korean,
	// phoneset: \xsampa,
	// language: \Korean
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
	}.play
});
P(\bassline, music: { |p b e|
	[
		freq: [11, 7, 6, 5.5, 5].df(\g, 3).q,
		instrument: \sparkTriangle,
		depth:0.01,
		dur: e.bAll.parse([2, 2, 3, 1, 3]).q
	].ppm
});
P(\chords, syl:6,music: { |p b e|
	[
		freq: [[-5.5, -7, 2, 4],[-1, 1, 3, 5]].df(\g, 4).q,
		instrument: \harp,
		dur: b.drop(1)[0]
	].ppm
});
["korean", "3 4 5  2 4 3 1 6".dm(\g, 4)].addLine;
P(\accent, music: { |p b e|
	(instrument:\cymbalsDS, att:1, amp:0.02).play;
	(freq: [3, 7, 13, 15, 17, 21].df(\g),instrument:\stringyy ).play
});
P.synthV(\xuan2, take: \lead, version: 2, params: {|p b| [
	lyrics: "김치 + 와  밥 을 주세요 + +",
	pitchTake: 1,
	// languageOverride: \Korean,
	phoneset: \xsampa,
	language: \Korean
] }, music:{|p b e|
	{
		e.playbuf
		=> Pan2.ar(_,1)
		=> FreeVerb.ar(_,0.2, 0.9)
		// => p.synthVTracks.at(e.key).()
	}.play
});
P(\bassNote,syl:6,lag:-0.2, music: { |p b e|
	[
		freq: [-5, 5, 7, 12].df(\d, 2),
		out: Effect.bus({|i| FreeVerb.ar(i, 1, [0.9, 1 ]) },),
		instrument: \sawSynthSustain,
		rel:5,
		dur: 1.q
	].pp
});
)
