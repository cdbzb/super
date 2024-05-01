( // - 0-1
Stills.scale = (256/144);
Stills.scale = 1;
Trek.faders[0] = { Trek.transitionGroup.release };
Trek.transitions[0]= (dur: 4, func: {
	1.wait;
	(instrument: \cymbalsDS, att:0.5, amp: 0.02).play;
	{ Stills.plotTitleCard("Contact", dur: 4); }.defer;
	Trek.faders[1].();
	4
});

Trek.setTransition(0, -2);

Trek.faders[1] = {
	{
		In.ar(0,Monitors.channels)
		* Env.asr(0, 9, 1).kr(2, gate: \gate.kr(1)).dbamp
		=> ReplaceOut.ar(0, _);
	}.play(s, target: Trek.transitionGroup);
};

Trek.setTransition(1, -2, dur: 3, func: {
	2.wait;
	// Trek.transitionGroup.release;
	(instrument:\cymbalsDS,amp:0.03, att:2.5).play(target:Trek.transitionGroup,addAction:\addToTail);
	defer{ Stills.plotTitleCard("The Planet", monitor:0, dur:2, top:0, fade:1) };
	s.freeMyDefaultGroup;
});

Trek.setTransition(2, -2, 
	func: {
		Trek.faders[3];
	}, 
	trimEnd: 1, 
	lag: -1.3,
);

Trek.faders[3] = {
		{
			In.ar(0,2)
			* Env( [ 0, 5, 5, 0 ].dbamp, [ 2, Song.songs.at(Trek.keys[3]).durTillEnd + Song.preroll + s.latency - 2, 0.5 ] ).kr(0)
			=> ReplaceOut.ar(0, _)
		}.play(s, target:Trek.transitionGroup);
};

Trek.setTransition(3, -1, 
	 func: {
		 (instrument:\cymbalsDS, att:2.5, group: Trek.transitionGroup).play;
		 // fork{0.9.wait; Server.default.freeMyDefaultGroup};
		 s.defaultGroup.release(1);
		 Trek.faders[4].();
	 }, trimStart: 1, trimEnd:0, dur: 1
);

Trek.faders[4] = {
	{
		In.ar(0,Monitors.channels)
		* Env.asr(0, 2, 1).kr(2, gate: \gate.kr(1)).dbamp
		=> ReplaceOut.ar(0, _);
	}.play(s, target: Trek.transitionGroup);
};

Trek.setTransition(4, -1,lag:-0.1 );
//5 to 6   this one needs a musical transition fix
Trek.setTransition(5, -10,dur: 1, func:{
		// 1.wait;
		// defer{ Stills.plotTitleCard("in the inner chamber", dur: 3.5); };
		// (instrument:\cymbalsDS, att:2.5).play;
		// 5.wait;
});
Trek.setTransition(6, -2);
Trek.setTransition(7, -2,dur: 4.5, func:{
	2.wait;
	defer{ Stills.plotTitleCard("Decision", dur:3, fade:2)}; 
	fork{1.wait; Server.default.freeMyDefaultGroup};
		(amp:0.03, instrument:\cymbalsDS, att:2.5, group: Trek.transitionGroup).play;
});

Trek.setTransition(8, -2,dur: 4, func: {
	fork{
		(instrument:\cymbalsDS, att:2.5, amp:0.02, group: Trek.transitionGroup).play;
		(instrument: \stringyy,dur:10, amp:0.05, freq: [1, 3, 5, 7].df(\c, \mixolydian), group: Trek.transitionGroup).play;
		3.wait;
		Trek.faders[9].();
		// (instrument: \stringyy, freq: [1, 3, 5, 7].df(\f)).play;
		// 1.wait;
	}
	}	
);

Trek.faders[9] = { 
	{
		In.ar(0, Monitors.channels)
		* 5.dbamp
		=> BLowShelf.ar(_, freq:200.0, rs:1.0, db:-3, mul:1.0, add:0.0)
		=> ReplaceOut.ar(0, _);
		Env.asr(releaseTime:1).kr(2, gate: \gate.kr(1));
	}.play(s, target: Trek.transitionGroup, addAction: \addToHead ) 
};
Trek.setTransition(9, -1, dur: 5, 
	func: {
		4.wait;
		Trek.transitionGroup.release(4);
		defer{ Stills.plotTitleCard("Transfer", dur: 5, fade:2); };
		fork{1.wait; Server.default.freeMyDefaultGroup};
		(instrument:\cymbalsDS, att:2.5, amp:0.03, group: Trek.transitionGroup, addAction:\addToTail).play;
		1.wait;
		Trek.faders[10].();
});

Trek.faders[10] = { 
	{
		In.ar(0, Monitors.channels)
		* -5.dbamp
		=> ReplaceOut.ar(0, _);
		Env.asr(releaseTime:1).kr(2, gate: \gate.kr(1));
	}.play(s, target: Trek.transitionGroup, addAction: \addToHead ) 
};
// 10 and 11 are the same!!
Trek.setTransition(10, -2, dur: 1,
	func: {
		Trek.transitionGroup.release(3);
		Trek.faders[11].();
	}
);
Trek.faders[11] = {
	{
		In.ar(0, Monitors.channels)
		* 2.dbamp
		=> ReplaceOut.ar(0, _);
		Env.asr(releaseTime:1).kr(2, gate: \gate.kr(1));
	}.play(s, target: Trek.transitionGroup, addAction: \addToHead ) 
};
Trek.setTransition(11, -1, dur:1, func:{
	try{ Trek.transitionGroup.release };
}, );
Trek.setTransition(12, -1,dur: 5.5, func:{
	1.5.wait;
	defer{ a=Stills.plotTitleCard("With these bodies", dur: 5.5); };
	nil
});
Trek.setTransition(13, -1, dur: 20 );
Trek.setTransition(13, 0, dur: 20 );
Trek.setTransition(14, -1, dur: 5, func: { 
	// defer{ Stills.plotTitleCard("Sick Bay",fade:0) };
}, trimStart:1);
Trek.setTransition(15, -1, dur: 0);
Trek.setTransition(16, -1, dur: 2);
Trek.setTransition(16, -3, dur: 2);
Trek.setTransition(17, -2, dur: 3.5);
Trek.setTransition(18, -2, dur: 3.5);
Trek.setTransition(19, -4, dur: 2);
Trek.setTransition(20, -1, dur: 2);
// no 20!!!
Trek.setTransition(21, -1, dur: 2);
)
