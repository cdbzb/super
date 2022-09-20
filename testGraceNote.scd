(
Song(\testGrace,[]).current;
["a","1 2 3 3 4 5".dm].addLine;
Song.setTempoMap(\a,"q q q g q q");
P.tune(\a);
P('lick',start:\a,music: {|p b e|
	[
		freq: Pwhite(300,400,inf) /2,
		amp:0.2,
		dur: "q q q q q".asBeats.postln.warpTo(e.tempoMap).postln.q
	].pp
});
)
