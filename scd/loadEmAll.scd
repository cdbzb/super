Trek.loadSongs( [0, 1, 2, 3, 4] )
(
fork{
	Trek.keys[0] => Song.songs.at(_) => _.current;
	Song.cursor_(Song.sections - 2);
	Song.play;
	Song.durTillEnd.wait;

	//transition material here VVV
	//put the song in the buffer!!!
	2.wait;
	(instrument:\cymbalsDS, att:2.5).play;
	1.wait;

	Trek.keys[1] => Song.songs.at(_) => _.current;
	Song.cursor_(0);
	g = Group.after(s.defaultGroup);
	{
		In.ar(0,2)
		* 4.dbamp
		=> ReplaceOut.ar(0, _)
	}.play(s, target:g).dur(Song.currentSong.durTillEnd);
	Song.play;
	Song.durTillEnd.wait;

	2.wait;
	(instrument:\cymbalsDS, att:2.5).play;
	1.wait;

	Trek.keys[2] => Song.songs.at(_) => _.current;
	Song.cursor_(0);
	Song.play
}
)

( // 1 to 2
var gain;
fork{
	Trek.keys[1] => Song.songs.at(_) => _.current;
	Song.cursor_(Song.sections - 2);
	g = Group.after(s.defaultGroup);
	gain = {
		In.ar(0,2)
		// * 4.dbamp
		* Env( [ 4.dbamp, 4.dbamp, 1 ], [ Song.durTillEnd + Song.preroll + s.latency, 0.5 ] ).kr(0,gate:\gate.kr(1))
		=> ReplaceOut.ar(0, _)
	}.play(s, target:g);
	Song.play;
	Song.durTillEnd + Song.preroll + s.latency => _.wait;
	// gain.release(1);
	2.wait;
	(instrument:\cymbalsDS, att:2.5).play;
	1.wait;

	Trek.keys[2] => Song.songs.at(_) => _.current;
	Song.cursor_(0);
	Song.play
}
)
( // 2 to 3
var gain;
fork{
	Trek.keys[2] => Song.songs.at(_) => _.current;
	Song.cursor_(Song.sections - 2);
	Song.play;
	Song.durTillEnd + Song.preroll + s.latency => _.wait;
	// gain.release(1);
	// 2.wait;
	// (instrument:\cymbalsDS, att:2.5).play;
	// 1.wait;

	Trek.keys[3] => Song.songs.at(_) => _.current;
	Song.cursor_(1);
	g = Group.after(s.defaultGroup);
	gain = {
		In.ar(0,2)
		// * 4.dbamp
		* Env( [ 4.dbamp, 4.dbamp, 1 ], [ Song.durTillEnd + Song.preroll + s.latency, 0.5 ] ).kr(0,gate:\gate.kr(1))
		=> ReplaceOut.ar(0, _)
	}.play(s, target:g);
	Song.play
}
)
