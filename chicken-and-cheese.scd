
(
Song(\chicken,[]).current;
Song.preroll_(1);
["rest","r",[1]].addLine;
["I would like some chicken and cheese",[1, 2, 3, 5, 4, 5, -7, 1].dm(\c)].addLine;
P.tune(\chicken,Pset(\instrument,\sawSynth,_));
//Song.chickenVocal=VocalRPP(\chicken,\chicken5);
P(\vocal,start:\chicken,lag:-1,resources:(rpp:VocalRPP(\chicken,\chicken)),music:{|p b e| 
	e.rpp.buffer.play
});
P(\bass,start:\chicken,syl:3,music:{|p b e| 
	(
		instrument:\stringyy,
		freq: [1,3,5,7].df(\g,3,\mixolydian),
		amp:0.3,
		dur: b.sum
	).play
});
)


