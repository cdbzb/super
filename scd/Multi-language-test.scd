
~phonemes = "I would like some kimchi + and rice".morphPhonemes(\uni, [ \english, \korean]);
~phonemes
(
Song(\babelTest,[]).current;
["english", "1 2 3 4 3 4 2 5".dm(\g, 5), [0.9504120349884, 0.53408051729202, 1.2251254916191, 0.88254528045654, 1.0220561981201, 1.146061372757, 1.2214063405991, 0.60947215557098]
].addLine;
P.synthVMulti(\xuan2,randomSeed:3,languages:[\english, \korean],start:0, take:1, version: 2,
	lyrics: "I would like some kimchi + and rice",
params: {|p b| [
	language: \mandarin,
	phoneset:\xsampa,
	// phonesetOverride:\arpabet,
	pitchTake: 1,
] }, music:{|p b e|
	{
		e.playbuf
		=> FreeVerb.ar(_,0.2,1)
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.synthVMulti(\uni,randomSeed:3,languages:[\english, \korean],start:0, take:\high, version: 2,
lyrics: "I would like some kimchi + and rice",
pbind:{|p b|[ midinote: [11, 11, 7, 11, 6, 5, 7, 6, 5].dm( \g,5),
dur:b
].p},

params: {|p b| [
language: \mandarin,
phoneset:\xsampa,
// phonesetOverride:\arpabet,
pitchTake: 1,
] }, music:{|p b e|
{
	e.playbuf
	=> FreeVerb.ar(_,0.2,1)
	// => p.synthVTracks.at(e.key).()
}.play
});
P.synthVMulti(\uni,randomSeed:3, languages:[\korean, \english],start:0, take:3, version: 2,
	lyrics: "I would like some kimchi + and rice",
	params: {|p b| [
	language: \mandarin,
	phoneset:\xsampa,
	// phonesetOverride:\arpabet,
	pitchTake: 1,
] }, music:{|p b e|
	{
		e.playbuf
		=> FreeVerb.ar(_,0.2,1)
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(\uni, take:4, version: 2, params: {|p b| [
	lyrics: "I would like some kimchi + and rice",
	language: \mandarin,
	phoneset:\xsampa,
	// phonesetOverride:\arpabet,
	pitchTake: 1,
	phonemes: 
	"I would like some kimchi + and rice".vowelRun(\xuan2,  [\mandarin], 7,10)
] }, music:{|p b e|
	{
		e.playbuf
		=>PitchShift.ar(_,pitchRatio:[1, 1.3 ])
		=> FreeVerb.ar(_,0.5,1)
		// => p.synthVTracks.at(e.key).()
	}//.play
});
P.synthV(\xuan2,start:0, take:2, version: 2, params: {|p b| [
	lyrics: "I would like some kimchi + and rice",
	language: \mandarin,
	phoneset:\xsampa,
	languageOverride:\english,
	phonesetOverride:\arpabet,
	pitchTake: 1,
	phonemes: 
	// "I would like some kimchi + and rice".morphPhonemes(\xuan2, [ \mandarin, \korean])
 ["th ah", "D @", "S i", "Z i", "tS i", "dZ i", "r\\ @", "{ t"]
	,
	// languageOverride: \Korean,
	// phoneset: \xsampa,
	// language: \Korean
] }, music:{|p b e|
	{
		e.playbuf
		=> FreeVerb.ar(_,0.5,1)
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
