(
Song(\ocean, []).current;
["I live on the ocean floor the sun is around me", "3 2 1 -7 -6 -5 1, -2 -4 -6 -7 -5 -2".dm(\e), "e e e e e e eee e e ee e e eee".asBeats  * 40/60 ].addLine;
Song.setTempoMap(\ocean,"e e e e e e eee e e ee e e eee");
P.tune();
P.synthVs(\an, take: [ \lead, \bg ], params: {|p b| [
	lyrics: "I liv on the ocean + floor r r r r r r",
	pitchTake: [ 1, 3 ]
] }, music:{|p b e|
	{
		e.playbuf
		/4
		// => p.synthVTracks.at(e.key).()
	}.play
});
P(\bass, music: { |p b e|
	[
		freq: [1, 3, 4, 3, 2, 4, 5, -5].df(\e, 3).q,
		dur: "qe e qe e qe e qe e".asBeats.warpTo( e.tempoMap ).q ,
		instrument: \sawSynth
	].pp
});
P.synthVs(\kevin, take: [ \lead, \bg ], params: {|p b| [
	lyrics: "r r r r r r r the sun is around + me",
	legato: [[1, 1, 1, 1, 1, 1, 1, 1, 1, 0.5, 1, 1, 0.5, ]],
	vocalMode: \Soft,
	paramBreathiness: 1,
	paramVoicing: 0.5,
	pitchTake: [ 1, 3 ]
] }, music:{|p b e|
	{
		e.playbuf
		=> FreeVerb.ar(_,0.2,1)
		// => p.synthVTracks.at(e.key).()
	}.play
});
)
