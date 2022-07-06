(
Song(\chicken3,[]).current.preroll_(1);
["I would like some chicken and cheese",[1, 2, 3, 4, 3, 4, 2, 5].dm(\d)].addLine;
P.tune(\chicken, Pset(\instrument,\sawSynth,_));
P(\swelly,start:\chicken,music:{|p b e| 
	{
		WhiteNoise.ar()
		* Env([0,0,1,0],b.parse([2,3,1])).kr(2,gate:1)
		* 0.1
	}.play;
	fork{
		b.parse([7]).unbubble.wait;
		(instrument: \cymbalsDS, amp:0.05).play
	}
});
P(\vocal,start:\chicken,rpp:VocalRPP(\chicken,\test8),lag: -1,music:{|p b e| 
	e.rpp.buffer.play
});

)
