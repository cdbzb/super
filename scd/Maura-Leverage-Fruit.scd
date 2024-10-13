(
Song(\mauraFruit,[]).current;
~make = {|i| [[7, 4, 2, 2, 1], i].flop.collect({|i| i[1].dup(i[0])})};
["one", "5 5 5 5 5 5 5 6 6 6 6 7 7 6 6 5  5 5 5 5 5 5 5 6 6 6 6 7 7 6 6 5".dm(\d, \mixolydian) ].addLine;
P.tune(\one);
P(\chords, music: { |p b e|
	[
		freq: [[1, 3, 5], [1, 4, 6], [2, 4, 7], [1, 4, 6], [1, 3, 5],].df(\d, \mixolydian) => ~make.(_) => _.flatten
		++ ([[1, 3, 5], [1, 4, 6], [2, 4, 7], [1, 4, 6], [1, 2.5, 5],].df(\d, \mixolydian) => ~make.(_) => _.flatten)		=> _.q,
		dur: b.quantizeWindow().q,
		// amp: [2, 1, 1, 1, 1, 1, 1, 1.5, 2, 1, 1, 1, 2, 1, 2, 1] / 20 + 0.2 => _.q(2) ,
		instrument: [\defaultPiano, \twang, ], coef: 0.1, fatness: 0.4
	].pp
});
["two", "5 5 5 5 5 5 5 6 6 6 6 7 7 6 6 5  5 5 5 5 5 5 5 6 6 6 6 7 7 6 6 5".dm('c#', \mixolydian) ].addLine;
P.tune(\two);
P(\chords, music: { |p b e|
	[
		freq: [[1, 3, 5], [1, 4, 6], [2, 4, 7], [1, 4, 6], [1, 4, 5],] => ~make.(_) => _.flatten
		++ ([[1, 3, 5], [1, 4, 6], [2, 4, 7], [1, 4, 6], [2, 4, 7],] => ~make.(_) => _.flatten)	
		=> _.df('c#') => {|i| i.size.debug("size"); i} => _.q,
		dur: b.quantizeWindow().q,
		// amp: [2, 1, 1, 1, 1, 1, 1, 1.5, 2, 1, 1, 1, 2, 1, 2, 1] / 20 + 0.2 => _.q(2) ,
		instrument: [\defaultPiano, \twang, ], coef: 0.1, fatness: 0.4
	].pp
});
["three", "5 5 5 5 5 5 5 6 6 6 6 7 7 6 6 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7  ".dm('c', \mixolydian) ].addLine;
P.tune(\three);
P(\chords, music: { |p b e|
	[
		freq: [[3, 5, 11], [4, 6, 11], [5, 7, 11], [4, 6, 11], [5, 7, 11],] => ~make.(_) => _.flatten => _.df(\c, \mixolydian)
		++(
			"11 11 11 11.5 11.5 11 11 11.5 12 12 12 12.5 12.5 12 12 12.5 13 13 13 13 13 13 13 13".df(\c).collect({ |i|  [5, 7].df(\c, \mixolydian) ++ [i]}) 
		)
		=> _.q,
		// dur: 0.2,
		dur: b.quantizeWindow().q,
		// amp: [2, 1, 1, 1, 1, 1, 1, 1.5, 2, 1, 1, 1, 2, 1, 2, 1] / 20 + 0.2 => _.q(3) => _.fin(24) ,
		instrument: [\defaultPiano, \twang, ], coef: 0.1, fatness: 0.4
	].pp
});
["four", 3.dup(7) ++ 4.dup(8) ++ 3.dup(8) ++ 4.dup(8) ++ [3] => _.flat  => _.dm(\dd) ].addLine;
// P.tune();
P(\chords, music: { |p b e|
	[
		freq: 
		[ [5, 11, 13], [6, 11, 14], [7, 12, 14], [6, 11, 14], [7, 7, 14]] => ~make.(_) => _.flatten => _.df(\d, \mixolydian)
		=> _.q(2),
		// dur: 0.2,
		dur: b.quantizeWindow().q,
		// amp: [2, 1, 1, 1, 1, 1, 1, 1.5, 2, 1, 1, 1, 2, 1, 2, 1] / 20 + 0.2 => _.q(3) => _.fin(24) ,
		instrument: [\defaultPiano, \twang, ], coef: 0.1, fatness: 0.4
	].pp
});
P(\bass, music: { |p b e|
	[
		freq: [1, 1, 4,  5, 1,  4, 5, 4, 5].df(\d, 3).q,
		dur: b.parse([7, 1, 7, 1, 8, 3, 2, 2, 1]).q
	].pp
});
)
