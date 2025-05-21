
(
Song("250518_143205".asSymbol, []).current;
Song.quarter = 132.reciprocal * 60;
["intro", "r", Song.quarter.dup(16)].addLine;
P(\bassline, music: { |p b e|
	[
		freq: [1.dup(8), -7.dup(3), -4.dup(4), -3, -6.dup(8),  3.dup(3), -7.dup(4), -6].df(\c, 3, \minor).flat.q(4),
		dur: p.quarter/2,
		out: Effect.bus({|i| CrossoverDistortion.ar(i) => Limiter.ar(_, 0.05) /2 + i })  

	].pp
});
P(\traps, music: { |p b e| 
	var len = 2;
	[
		dur: "q e e q q".beats.q(4 * len) * p.quarter,
		instrument: \cp_808,
		rest: [\r, 1, 1, \r, 1].q(4 * len)

	].pp
});
Song.lick=2.collect{ |i|
	{ |instrument|
		[
			lag:0.2,
			amp:0.06,
			freq: [
				[\r, 3, 4, 5, 1, -7, 2, 1, \r].df(\c, \mixolydian),
				[\r, -6, -7, 1, 3, 5, 6, 4, \r].df(\c, \minor)
			][i].q,
			dur: "q e e q q q e eq q".beats.q * Song.quarter,
			// legato: [10,10,10,10,9,10,10,9].q/10,
			instrument: instrument,
			lofreq: 2000, hifreq: 8000
		].ppm
	}
};
Song.chords = 
[
	[
		[-4, -7, 2],
		[ -4, -6, 1]
	].df(\c, \mixolydian),
	[
		[-5, -7, 3],
		[-4, -7, 2]
	].df(\c, \minor),
]
.collect {|chords|
	{ 
		// fork{
		4*Song.quarter.wait;
		{
			chords
			.flop.collect {|i| i.dq.demand("qe e".beats * Song.quarter)}
			=> Pulse.ar(_, 0.2, 0.1)
			=> BPF.ar(_, 900)

			* EnvGen.cutoff(wait: 3*Song.quarter, release:2)
			// => {|i| Convolution.ar(i, Dust.ar(4.df(\c)) => Decay.ar(_,0.02)=> FreeVerb.ar(_,0.5,0.1)) => HPF.ar(_, 1000) + i}
			=> Splay.ar(_, spread:0.3, center:-0.3)
			=> FreeVerb.ar(_,0.5,1)
		}.play
		// }
	}
}

)
(
Song.playSection(\intro); (lag:0.2,amp:0.02, instrument: \cymbalsDS).play;
8.do{|i| {fork{Song.chords[i % 2].()}}.sched(i * 8 + 4 * Song.quarter -0.1)};
4.do{|i| {Song.lick[i % 2].(\sawSynthSustain)}.sched(i * 8 * Song.quarter) };
SystemClock.sched(Song.quarter * 16 + 0.2, {(instrument:\cymbalsDS, amp:0.02).play})
)
