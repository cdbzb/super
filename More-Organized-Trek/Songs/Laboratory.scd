( s.waitForBoot{
Song(\laboratory,[]).current;
[ "/*[Laboratory]*/","r" ].addLine;
Song.synthVTracks = EventWithDefault.new(
	\default, {
		{|i| Pan2.ar(i,0)}
	}
);
[ "/*(There is a shiny plastic person on the table now.) */","r" ].addLine;
[ "/*MULHALL:*/ Why pretend to work on that thing, Henoch? ","1 2 3 5 6 -5 5 3 7 -6 6 4".dm(\c,\mixolydian) ].addLine;
P.tune( _ => Pset(\amp,Pfunc({|i| (i.midinote < 1.dm(\c)).if{0}{0.1} }),_) );
P(\dyads, music: { |p b e|
	[
		freq: [\r, [4,6],[3,5],  [2,4,7],[1,4,6], [-5,5,-15] ].df(\c,\mixolydian).q,
		dur: e.bAll.parse([4, 1, 3, 1, 3, 1]).q,
		instrument: \sawSynth
	].pp
});
P.synthV(role: \thalassa, take: \lead, params: {|p b| [
	lyrics: "Why pretend + to work r on that thing, r Henock +",
	pitchTake: 1,
	phonemes: [ "w a :\\i"," ph r\\` i"," th e n t"," th u"," w a r\\` kh",""," A n"," t a th"," s i\\ N","","","n A kh" ] ,
	// legato: [1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, ],
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P(\bass, music: { |p b e|
	[
		freq: [1, 2, 3, 5, 4, 3, 2,1].df(\c,3).q,
		dur: b.parse([1,1,1,1,1,3,1,3]).q,
		amp: 0.15,
		instrument: \harp,
		coef:0.8,
		legato: [1, 1, 1, 0.9, 1, 0.8,1,1 ].q,
	].ppma
});
P(\horn, music: { |p b e|
	[
		freq: [\r, 4, 5].df(\c).q,
		dur: e.bAll.parse([8,4,1]).q,
		instrument: \defaultPorto
	].ppm
});
[ "-boom- You know you never intended to leave Spock's body. ","-5 5 12 11 7 6 5 4 5 6 2 5 4 3".dm(\c) ].addLine;
P(\lowBass, music: { |p b e|
	[
		instrument: \sawSynthSustain,
		att: [1.5, 0.1, 0.1, 0.1, 0.1].q,
		freq: [-15, -5, -4,-2,-1].df(\c,4).q,
		dur: b.parse([2,5,3,2,2]).q
	].pp
});
P(\chord,syl:1, music: { |p b e|
	(
		instrument: "defaultPorto",
		freq: [3,5].df(\g),
		amp: 0.2
	).play
});
P.synthV(role: \thalassa, take: \lead, params: {|p b| [
	lyrics: "r You know you never intended + + to leave Spock's body. + ",
	pitchTake: 1,
	phonemes: [ "","j u"," n @U"," j u"," n e w"," a r\\`"," i\\ n ","th e n"," t i\\ t"," th u"," l i w","s ph A kh s"," p A "," t i" ],
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.tune();
[ "/*SPOCK:*/ This is your new home, Thalassa. "," 5 3 11 6.5 7 4 3 2".dm(\f,\minor) ].addLine;
P.tune();
P(\bassline, music: { |p b e|
	[
		freq: [\r, 3, [ -7, 11, 13, 15, 17 ]].df(\f,3,\minor).q,
		dur: b.parse([2,2,2]).q,
		instrument: \stringyy,
		amp: 0.3

	].pp
});
P(\bassNotes,syl: 5, music: { |p b e|
	[
		freq: [ 1, -7, -6.5  ].df(\f,[3,4], \minor).q,
		dur: b.drop(1).sum.bubble ++ e.bNext.parse([2,3]) => _.flat => _.q
	].p.trace.play
});
P.synthV(role: \henoch, take: \lead, params: {|p b| [
	lyrics: "this is your new home, thalassa + +",
	filter: (midinote: _ - 12), 
		legato: [1, 1, 0.8 ,1, 0.9, 1, 1, 1 ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		/5
	}.play

});
[ "-boom- Once occupied","-1,5 11 5 3".dm(\d)].addLine;//boom=e-flat

P(\roll,syl:1, music: { |p b e|
	(
		freq: [1,3,5,11].df(\d,4),
		strum: 0.05,
		instrument: \harp
	).play
});
P.synthV(role: \henoch, take: \lead,
	pbind: Song.enlarge(13),
	params: {|p b| [
	lyrics: "r once occupied + + I'll add female + features + and some texturing - + +",
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		/ 5
	}.play

});
[" I'll add female features and some texturing. ","1 3 2 1 -7 1 -6 2 3 2 1 -5".dm(\e,6) ].addLine;
P(\bassline, music: { |p b e|
	[
		freq:[1,3,2,1,-7,-6,-5].df(\e,[3,4,5]).q,
		dur:b.parse([1,1,1,1,2,3,3]).q,
		instrument: \stringyy, amp: 0.25
	].ppm
});
[ "You no doubt want the mechanism to at least appear to be a woman. ","r" ].addLine;
[ "(he tests its hand movement.) It is ready, Thalassa.  ","r" ].addLine;
[ "/*MULHALL:*/ No! ",
//next up: Plastic person
 ].addLine;
[ "/*SPOCK:*/ You have no excuse to keep the real body any longer. ","r" ].addLine;
[ "Sargon would've required that you enter the mechanism immediately. ","r" ].addLine;
[ "/*MULHALL:*/ I cannot live in that thing.","r" ].addLine;
}
)
