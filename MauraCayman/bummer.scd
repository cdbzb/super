(
Song(\mauraBummer,[]).current;
["Idea","11 7 11 7".dm(\c)].addLine;
Song.setTempoMap(\Idea,"qq qq qq qq qq qq qq qq");
TempoClock.tempo_( 2 )
P(\bend, music: { |p b e|
	[
		freq: [11,7,11,7, 11, 7, 11, 12].df(\c).q,
		legato: [1, 0.6, 1, 0.6,1, 1, 0.6, 1 ].q,
		dur: b.q(8) * 2 ,
		instrument: \sawSynthSustain,amp:0.04,
		lagTime:4, att:1
	].ppma;
});
P(\arp, music: { |p b e|
	[
		freq: [\r,5, 13, 11].dup ++ [\r,5, 13, 12].dup => _.flat => _.df(\c) => _.q(2),
		dur: "e*16".beats.warpTo(e.tempoMap).q(2),
		instrument:\defaultPiano,
		out: Effect.bus({|i| i => PitchShift.ar(_, pitchRatio: SinOsc.ar(3).range(0.99,1.01) ) => FreeVerb.ar(_,0.2,1) },inputChannels:2)
	].pp
});
P(\bassNote, music: { |p b e|
	[
		instrument: \stringyy, 
		freq: [ [3, 1, -5, 4].df(\c,[4,5]).q(2), [-6, 1, -5, -7].df(\c,[4,5]).q, [-6, 1, -5, 4].df(\c,[4,5]).q ].q(2),
		amp:[ 0.3, 0.1 ],
		dur: "qq qq qq qq".asBeats.warpTo( e.tempoMap ).q(4),
		freqLag:2,
		legato: [1, 0.9, ].q(inf),
	].pma.play
});
P(\highnote, music: { |p b e|
	[
		freq: [ [1,3,5, 7 ],[2,3,5,7] ].df(\c,6).q(inf),
		dur: "e*32".beats.warpTo(e.tempoMap).q(6),
		instrument: \harp,coef:0.12,amp:0.01, strum: 0.05,
		out:Effect.bus({|i| i=> Pan2.ar(_, LFBrownNoise1.ar(1)) },)
	].pp
});
)
