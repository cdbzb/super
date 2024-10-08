(
Song(\mauraFruit,[]).current;
~make = {|i| [[7, 4, 2, 2, 1], i].flop.collect({|i| i[1].dup(i[0])})};
["one", "5 5 5 5 5 5 5 6 6 6 6 7 7 6 6 5  5 5 5 5 5 5 5 6 6 6 6 7 7 6 6 5".dm(\d, \mixolydian) ].addLine;
// P.tune(\one);
~chordInstrument = [\default, \stab, \harp];
~amps = [0.1, 0.6, 0.03];
P(\chords, music: { |p b e|
	[
		freq: [[1, 3, 5], [1, 4, 6], [2, 4, 7], [1, 4, 6], [1, 3, 5],].df(\d, \mixolydian) => ~make.(_) => _.flatten
		++ ([[1, 3, 5], [1, 4, 6], [2, 4, 7], [1, 4, 6], [1, 2.5, 5],].df(\d, \mixolydian) => ~make.(_) => _.flatten)		=> _.q,
		dur: b.quantizeWindow().q,
		// amp: [2, 1, 1, 1, 1, 1, 1, 1.5, 2, 1, 1, 1, 2, 1, 2, 1] / 20 + 0.2 => _.q(2) ,
		instrument: ~chordInstrument, coef: 0.2, fatness: 0.4,
		amp: ~amps
	].pp
});
["two", "5 5 5 5 5 5 5 6 6 6 6 7 7 6 6 5  5 5 5 5 5 5 5 6 6 6 6 7 7 6 6 5".dm('c#', \mixolydian) ].addLine;
// P.tune(\two);
P(\chords, music: { |p b e|
	[
		freq: [[1, 3, 5], [1, 4, 6], [2, 4, 7], [1, 4, 6], [1, 4, 5],] => ~make.(_) => _.flatten
		++ ([[1, 3, 5], [1, 4, 6], [2, 4, 7], [1, 4, 6], [2, 4, 7],] => ~make.(_) => _.flatten)	
		=> _.df('c#') => {|i| i.size.debug("size"); i} => _.q,
		dur: b.quantizeWindow().q,
		// amp: [2, 1, 1, 1, 1, 1, 1, 1.5, 2, 1, 1, 1, 2, 1, 2, 1] / 20 + 0.2 => _.q(2) ,
		instrument: ~chordInstrument, coef: 0.2, fatness: 0.4,
		amp: ~amps
	].pp
});
["three", "5 5 5 5 5 5 5 6 6 6 6 7 7 6 6 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7  ".dm('c', \mixolydian) ].addLine;
// P.tune(\three);
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
		instrument: ~chordInstrument, coef: 0.2, fatness: 0.4,
		amp: ~amps
	].pp
});
P(\line,syl: 15, music: { |p b e|
	[
		freq: [ 1, 1.5, 1, 1.5, 2, 2.5, 2,2.5, 3, 4.5].df(\c, [4, 5]).q,
		wet: 0.1,
		instrument: \stringyy,
		amp: [0.1,0.2],
		dur: b.parse([ 3, 2, 2, 1, 3, 2, 2,1, 8]) ++ 2 => _.q,
		freqLag: 0.05 ! 9 ++ 2 => _.q
	].ppm
});
P(\lineTwo, music: { |p b e|
	[
		freq: [ [-3, -5, 1], [-4, 1], 7, 6, 7, 5 ].df(\c, \mixolydian).q,
		legato: [ 1, [4, 1], [4,  1], 1, 1, 1, 1 ].q,
		dur: b.parse([7, 4, 2, 2, 1, 3, 2, 2, 1]).q
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
		instrument: ~chordInstrument, coef: 0.2, fatness: 0.4,
		amp: ~amps
	].pp
});
P(\bass, music: { |p b e|
	[
		freq: [1,             1, 4, 5, 1, 4, 5, 4, 5, 2.5, 5.5].df(\d,     3).q,
		dur: e.bAll.parse([7, 1, 7, 1, 8, 3, 2, 2, 1, 8,   1]).q,
		amp: [1,              1, 1, 1, 1, 1, 1, 1, 1, 1,   1.5]/10 => _.q,
		legatp: 0.9 ! 9 ++ 0.5 => _.q
	].pp
});
["five", 1!16 => _.dm(\f) ++ [7,7,7,7,7,7,7,7,7,7,7,11,11,7,7,6.5].dm('c#')].addLine;
P(\chords, music: { |p b e|
	[
		freq: [ [3, 5, 11], [4, 6, 11], [5, 6, 11], [4, 6, 11],[3, 6, 11] ] => ~make.(_) => _.flatten => _.df(\f)
		++( [[5, 11, 13]!8] ++ [[6, 11, 13]!3, [6, 11, 14]!2, [ 6, 11, 13]!2, [6, 11, 12.5].bubble] => _.flatten => _.df('a-', [4,5]))
		=> _.q,
		// dur: 0.2,
		dur: b.quantizeWindow().q,
		// amp: [2, 1, 1, 1, 1, 1, 1, 1.5, 2, 1, 1, 1, 2, 1, 2, 1] / 20 + 0.2 => _.q(3) => _.fin(24) ,
		instrument: ~chordInstrument, coef: 0.2, fatness: 0.4,
		amp: ~amps
	].pp
} );
P(\connector, music: { |p b e|
	[
		freq: [\r, [1, 3],[2, 3],1, -7, [-6.5, 2]].df('b-',4).q,
		dur: b.parse([7, 4, 2, 2, 1, 8]).q,
		legato: [1, 1, [1, 2], 1, 1, 1].q
	].pp
});
P(\bassnote,syl:23,  music: { |p b e|
	(
		freq: 1.df('c#', [3, 4]),
		out: Effect.bus({|i| FreeVerb.ar(i, 0.3,1) },inputChannels:2),
	).play;
	( 
		freq: [1, 3, 5, 7].df('c#'),
		instrument: \stringyy
	).play
});
["six", 3!16 => _.dm(\g)].addLine;
P(\chords, music: { |p b e|
	[
		freq: [5, 11, 13].df(\g, [ 4,5]).flatten,
		dur: b.quantizeWindow().q,
		// amp: [2, 1, 1, 1, 1, 1, 1, 1.5, 2, 1, 1, 1, 2, 1, 2, 1] / 20 + 0.2 => _.q(3) => _.fin(24) ,
		instrument: ~chordInstrument, coef: 0.2, fatness: 0.4,
		amp: ~amps
	].pp
} );
["ending", "5 5 5 5 5 5 5 6 6 6 6 7 7 6 6 5  5 5 5 5 5 5 5 6 6 6 6 7 7 6 6 5".dm(\d, \mixolydian) ].addLine;
P(\chords, music: { |p b e|
	[
		freq: [[11, 3, 5], [11, 4, 6], [12, 4, 7], [11, 4, 6], [11, 3, 5],].df(\c,[5], \mixolydian) => ~make.(_) => _.flatten
		++ ([[11, 3, 5], [11, 4, 6], [12, 4, 7], [11, 4, 6], [11, 3, 5],].df(\c,[5], \mixolydian) => ~make.(_) => _.flatten)		=> _.q,
		dur: b.quantizeWindow().q,
		// amp: [2, 1, 1, 1, 1, 1, 1, 1.5, 2, 1, 1, 1, 2, 1, 2, 1] / 20 + 0.2 => _.q(2) ,
		instrument: ~chordInstrument, coef: 0.2, fatness: 0.4,
		amp: ~amps
	].pp
});
P(\bass, music: { |p b e|
	[
		freq: [1,             1, 4, 5, 1, 4, 5, 4, 5, ].df(\c,     3).q,
		dur: e.bAll.parse([7, 1, 7, 1, 8, 3, 2, 2, 1, ]).q,
		amp: [1,              1, 1, 1, 1, 1, 1, 1, 1, ]/10 => _.q,
		legatp: 0.9 ! 9 ++ 0.5 => _.q
	].pp
});
)

