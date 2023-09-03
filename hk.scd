(
Song(\HK,[]).current;
TempoClock.tempo_( 2 );
["Verse1","r",[1, 1, 1, 1, 1, 1, 1, 1]/2].addLine;
P(\beat, music:{|p b e|
	[
		[
			dur: [[1].q,[2].q(inf)].q,
			instrument: \sn_808,
			rests: MuteFirst()
		].p,
		[
			dur:"ex xq e eq".asBeats.q(inf),
			instrument: \bd_808
		].p,
		[
			dur: 1!6 ++ (0.33!3) /4 => _.flat => _.q(inf),
			instrument: \hat_808
		].p
	] => Ppar(_) => _.play;
});
P(\chords, music: { |p b e|
	[
		freq: [ [1, 3, 5], [5, 2, -7] ].df(\c).q(inf),
		dur: [ 1.5, 1.5, 2, 2, 1 ].q(6)
	].pp
});
P.synthV(\an, take: \lead,
	pbind: {|p b|
		[
			midinote: [1, 3, 5, 4, 3, 4, 2, 3].dm(\c),
			dur:0.5!8
		].p
	},
	params: {|p b| [
	lyrics: "那 些　胭 脂 色 的　香 檳  　",
	language: \Mandarin,
// 段段艷遇　處處有染　都放在眼前
// 害怕採花　天黑路遠
// 情願對路邊燈飾眷戀",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		/8
		// => p.synthVTracks.at(e.key).()
	}.play
});

)
