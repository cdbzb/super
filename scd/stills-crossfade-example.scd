(
defer{
	Stills.plotTitleCard("The Planet",2, 4, fade: 8 ) ;
	b = [500, 400, 360, 222].scramble * [1, 2, 1.33, 0.66].scramble;
	(instrument: \cymbalsDSStereo, amp: 0.001, att:[3, 2, 1]).play;
	a = Synths(\stringyy, \freqLag, 8,\rel, 10,\width, 13, \freq, b, \amp, 0.1, \out, [0, 1, 2, 3]);
	Stills.plotTitleCard("The Planet",2, 2, fade: 4 ) ;
	fork{
		2.wait;
		a.set(\freq, [400, 360, 300, 240]);
		4.wait;
		a.release(8);
		2.wait;
		a.set(\freqLag, 8);
		a.set(\freq, [400, 360, 300, 240] - 12);
	}

}

)
