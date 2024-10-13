(
Song(\mauraFruit,[]).current;
["one", "5 5 5 5 5 5 5 6 6 6 6 7 7 6 6 5  5 5 5 5 5 5 5 6 6 6 6 7 7 6 6 5".dm(\d, \mixolydian) ].addLine;
P.tune(\one);
P(\chords, music: { |p b e|
	[
		freq: [
			[1, 3, 5]!7,
			[1, 4, 6]!4, 
			[2, 4, 7]!2,
			[1, 4, 6]!2, 
			[1, 3, 5].bubble
		].flatten.df(\d, \mixolydian).q,
		dur: b.q,
		instrument: \defaultPiano, coef: 0.1
	].pp
});
["two", "5 5 5 5 5 5 5 6 6 6 6 7 7 6 6 5  5 5 5 5 5 5 5 6 6 6 6 7 7 6 6 5".dm('c#', \mixolydian) ].addLine;
P.tune(\two);
)
