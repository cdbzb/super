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
	// Trek.loadSongs([3]);
	// Trek.loadSongs( [2, 3] );
	Trek.playSong(2, -1).wait;
	Trek.editFile(3);
	a = Trek.playSong(3, 1, true); //needToCall "makeScroll" on the song!!
	g = Group.after(s.defaultGroup);
	gain = {
		In.ar(0,2)
		* Env( [ 4.dbamp, 4.dbamp, 1 ], [ Song.durTillEnd + Song.preroll + s.latency, 0.5 ] ).kr(0)
		=> ReplaceOut.ar(0, _)
	}.play(s, target:g);
	a.wait;
}
)
( //3 to 4
	fork{
		// Trek.loadSongs([4])
		Trek.playSong(3, -1).wait;
		// Trek.editFile(4);
	// 1.wait;
	(instrument:\cymbalsDS, att:2.5).play;
	1.wait;
		Trek.playSong(4, 1); //needToCall "makeScroll" on the song!!
	}
)
(
 //4to5
	fork{
		// Trek.loadSongs([4,5])
		Trek.playSong(4, -1) - 0.1 =>_.wait;
		Trek.playSong(5); //needToCall "makeScroll" on the song!!
	}
)
(
//5 to 6   this one needs a musical transition fix
	fork{
		// Trek.loadSongs([5,6])
		Trek.playSong(5, -1) - 0.0 =>_.wait;
		2.wait;
		// defer{ Stills.plotTitleCard("in the inner chamber", dur: 3.5); };
		// (instrument:\cymbalsDS, att:2.5).play;
		// 5.wait;
		Trek.playSong(6); //needToCall "makeScroll" on the song!!
	}
)
(
//6 to 7
	fork{
		// Trek.loadSongs([6, 7])
		Trek.playSong(6, -2) - 0.0 =>_.wait;
		// 3.wait;
		// defer{ Stills.plotTitleCard("in the inner chamber", dur: 3.5); };
		// (instrument:\cymbalsDS, att:2.5).play;
		// 5.wait;
		Trek.playSong(7); //needToCall "makeScroll" on the song!!
	}
)
(
//7 to 8
	fork{
		// Trek.loadSongs([7, 8])
		Trek.playSong(7, -2) - 0.0 =>_.wait;
		// 3.wait;
		// defer{ Stills.plotTitleCard("in the inner chamber", dur: 3.5); };
		// (instrument:\cymbalsDS, att:2.5).play;
		// 5.wait;
		Trek.playSong(8); //needToCall "makeScroll" on the song!!
	}
)

~transition.(8, -2, {
	fork{
		(instrument:\cymbalsDS, att:2.5, amp:0.03, group: Trek.transitionGroup).play;
		(instrument: \stringyy,dur:10, freq: [1, 3, 5, 7].df(\c, \mixolydian), group: Trek.transitionGroup).play;
		3.wait;
		// (instrument: \stringyy, freq: [1, 3, 5, 7].df(\f)).play;
		// 1.wait;
		{ In.ar(0, Monitors.channels)
			* 4.dbamp
			=> BLowShelf.ar(_, freq:200.0, rs:1.0, db:-3, mul:1.0, add:0.0)
			=> ReplaceOut.ar(0, _);
			Env.asr().kr(2, gate: \gate.kr(1));
		}.play(s, target: Trek.transitionGroup, addAction: \addToHead )
	};
	4
})

(
//9 to 10
Trek.transitionGroup.release;
{ 
	In.ar(0, Monitors.channels)
	* 4.dbamp
	=> BLowShelf.ar(_, freq:200.0, rs:1.0, db:-3, mul:1.0, add:0.0)
	=> ReplaceOut.ar(0, _);
	Env.asr().kr(2, gate: \gate.kr(1));
}.play(s, target: Trek.transitionGroup, addAction: \addToHead );
~transition.(9, -1, {
	Trek.transitionGroup.release;
	s.plotTree
	1.wait;
	defer{ Stills.plotTitleCard("The \nTransfer", dur: 3.5); };
	(instrument:\cymbalsDS, att:2.5, amp:0.03).play;
	4
})
)
(
// 10 and 11 are the same!!
	fork{
		// Trek.loadSongs([11, 12])
		Trek.playSong(11, -1) - 0.0 =>_.wait;
		1.wait;
		Trek.playSong(12); //needToCall "makeScroll" on the song!!
	}
)
(
// 12 to 13
	fork{
		// Trek.loadSongs([13])
		Trek.playSong(12, -1) - 0.0 =>_.wait;
		1.wait;
		Trek.playSong(13); //needToCall "makeScroll" on the song!!
	}
)
(
~transition = {|num sections func skip|
	Trek.transitions.put(num, func);
	fork{
		Trek.playSong(num, sections) - 0.0 => _.wait;
		func.value ? 0 => _.debug("waiting")=>_.wait;
		Trek.playSong(num + 1, skip? 0); //needToCall "makeScroll" on the song!!
	}
}
)
~transition.(12, -1, { 2 })
~transition.(13, -1, { 20 })
~transition.(14, -1, { 
	// defer{ Stills.plotTitleCard("Sick Bay",fade:0) };
	5
}, 1);
Trek.loadSongs( [21] )
~transition.(15, -1, {0})
~transition.(16, -1, {2})
~transition.(16, -3, {2})
~transition.(17, -2, {3.5})
~transition.(18, -2, {3.5})
~transition.(19, -4, {2})
// no 20!!!
~transition.(21, -1, {2})
Song.current
Trek.editFile(21)
//no 22?
Trek.keys[21]
Trek.editFile(20)
Trek.loadSongs([15])
