(
Song.new(\Oct10_23,[]).current;
["line", [11, 7, 6, 5, 4, 3, 2, 4, 3].dm(\c)].addLine;
Song.setTempoMap(\line,"qe q e q e q e q e");
P.tune( _ <> [instrument: \stringyy].pm );
P(\bassline, music: { |p b e|
	[
		freq: [-1, -5, 1, 3, 5, 4, 3, 1, -6, -5, 1, -4, -2, 1, 5].df(\c).q,
		dur: 0.5 ! 16 warpTo: e.tempoMap |> _.q,
		legato: 2,
		out: Effect.bus({|i| 
		i |> FreeVerb.ar(_,0.8,1)
		|> _.tanh |> _.tanh
		|> Phaser2.ar(_,rate:0.14)
		},)
	].pp
});

["answer", [11, 7, 6, 5, 4, 3, 2, 4, 3].dm(\c)].addLine;
Song.cloneDursAndTempoMap(\line);
// P.tune()
P(\bassline, music: 
	Song.getMusicFunction(\line,\bassline).interpret 
);
Song.playRanges(0,1,0,1, 0,1)
)

