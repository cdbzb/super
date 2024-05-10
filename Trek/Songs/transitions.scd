( // - 0-1
Stills.scale = (256/144);
Stills.scale = 1;
~asrFader = {| a=0, s=9, r=1|
	{
		In.ar(0,Monitors.channels)
		* Env.asr(a, s, r).kr(2, gate: \gate.kr(1)).dbamp//.poll
		=> ReplaceOut.ar(0, _);
	}.play(s, target: Trek.transitionGroup);
};
~activateFader = {|num| Trek.faderSynths[num] = Trek.faders[num].()};

Trek.faders[0] = { 
	Trek.transitionGroup.release ;
	{
		In.ar(0,Monitors.channels)
		* Env.asr(1, -3, 5).kr(2, gate: \gate.kr(1)).dbamp//.poll
		=> ReplaceOut.ar(0, _);
	}.play(s, target: RootNode(s), addAction:\addToTail);
};

Trek.setTransition(0, -2, dur: 4, func: {
	1.wait;
	(instrument: \cymbalsDS, att:0.5, amp: 0.02).play;
	{ Stills.plotTitleCard("Contact", dur: 4); }.defer;
	Trek.faderSynths[0].release;
	~activateFader.(1)
});

Trek.faders[1] = {~asrFader.(1,7,2)};

Trek.setTransition(1, -2, dur: 3, func: {
	2.wait;
	Trek.faderSynths[1].release;
	(instrument:\cymbalsDS,amp:0.03, att:2.5,target:Trek.transitionGroup,addAction:\addToTail).play;
	defer{ Stills.plotTitleCard("The Planet", monitor:0, dur:2, top:0, fade:1) };
	nil
});

Trek.faders[2]={~asrFader.(1, 0, 1)};

Trek.setTransition(2, -2, 
	func: {
		Trek.faderSynths[2].release;
		~activateFader.(3);
	}, 
	trimEnd: 1, 
	lag: -1.3,
);

Trek.faders[3]={~asrFader.(5, 3, 0.5)};

Trek.setTransition(3, -1, 
	 func: {
		 (instrument:\cymbalsDS, att:2.5, group: Trek.transitionGroup).play;
		 // fork{0.9.wait; Server.default.freeMyDefaultGroup};
		 s.defaultGroup.release(1);
		 Trek.faderSynths[3].release(1);
		 ~activateFader.(4);
	 }, trimStart: 1, trimEnd:0, dur: 1
);

Trek.faders[4] = {~asrFader.(0,2,6)};

Trek.setTransition(4, -1,lag:-0.1, func: {
	Trek.faderSynths[4].release(0.5);
	~activateFader.(5)
} );
//5 to 6   this one needs a musical transition fix
Trek.faders[5] = {~asrFader.(0,2,5)};
Trek.setTransition(5, -4,dur: 1, func:{
	Trek.faderSynths[5].release(1);
	~activateFader.(6);
		// 1.wait;
		// defer{ Stills.plotTitleCard("in the inner chamber", dur: 3.5); };
		// (instrument:\cymbalsDS, att:2.5).play;
		// 5.wait;
});

Trek.faders[6] = {~asrFader.(1,5,1)};

Trek.setTransition(6, -2, 
	// trimStart:2, trimEnd:2,
	func: {
	~activateFader.(7);
	Trek.faderSynths[6].release;
});

Trek.faders[7] = {~asrFader.(3,8,1)};
Trek.setTransition(7, -3,dur: 4.5, func:{
	2.wait;
	defer{ Stills.plotTitleCard("Decision", dur:3, fade:2)}; 
	fork{1.wait; Server.default.freeMyDefaultGroup};
	Trek.faderSynths[7].release(3);
	~activateFader.(8);
	(amp:0.03, instrument:\cymbalsDS, att:2.5, group: Trek.transitionGroup, out:[2, 0]).play;
});

Trek.faders[8] = {~asrFader.(1,2,1)};

Trek.setTransition(8, -2,dur: 4, func: {
	fork{
		(instrument:\cymbalsDS, att:2.5, amp:0.02, group: Trek.transitionGroup).play;
		(instrument: \stringyy,dur:10, amp:0.05, freq: [1, 3, 5, 7].df(\c, \mixolydian), group: Trek.transitionGroup).play;
		3.wait;
		Trek.faderSynths[8].release;
		~activateFader.(9);
		// (instrument: \stringyy, freq: [1, 3, 5, 7].df(\f)).play;
		// 1.wait;
	}
	}	
);

Trek.faders[9] = { 
	{
		In.ar(0, Monitors.channels)
		* Env.asr(4, 7, 2).kr(2, gate: \gate.kr(1)).dbamp
		=> BLowShelf.ar(_, freq:200.0, rs:1.0, db:-7, mul:1.0, add:0.0)
		=> ReplaceOut.ar(0, _);
	}.play(s, target: Trek.transitionGroup, addAction: \addToHead );
};

Trek.setTransition(9, -1, dur: 5, 
	func: {
		4.wait;
		// Trek.faderSynths[9].release;
		Trek.transitionGroup.release(4);
		defer{ Stills.plotTitleCard("Transfer", dur: 5, fade:2); };
		fork{1.wait; Server.default.freeMyDefaultGroup};
		(instrument:\cymbalsDS, att:2.5, amp:0.03, group: Trek.transitionGroup, addAction:\addToTail).play;
		1.wait;
		(instrument:\cymbalsDS, att:2.5, amp:0.03,out:1, group: Trek.transitionGroup, addAction:\addToTail).play;
		~activateFader.(10);
});

Trek.faders[10] = {~asrFader.(1, 0, 1)};
// 10 and 11 are the same!!
Trek.setTransition(10, -2, dur: 1,
	func: {
		Trek.faderSynths[10].release;
		Trek.transitionGroup.release(3);
		~activateFader.(11);
	}
);

Trek.faders[11] = {~asrFader.(1, 6, 2)};
Trek.setTransition(11, -1, dur:1, func:{
	Trek.faderSynths[11].release;
	try{ Trek.transitionGroup.release };
	~activateFader.(12)
}, );

Trek.faders[12] = {~asrFader.(1, 3, 2)};
Trek.setTransition(12, -3,dur: 5.5, func:{
	1.5.wait;
	defer{ a=Stills.plotTitleCard("With these bodies", dur: 5.5); };
	~activateFader.(13);
	Trek.faderSynths[12].release;
});
Trek.faders[13] = {~asrFader.(1, 3, 8)};
Trek.setTransition(13, -1, dur: 20, func:{
	~activateFader.(14);
	Trek.faderSynths[13].release;
} );
Trek.faders[14] = {~asrFader.(8, 3, 2)};
Trek.setTransition(13, 0, dur: 20 );
Trek.setTransition(14, -1, dur: 5, func: { 
	~activateFader.(15);
	Trek.faderSynths[14].release;
	// defer{ Stills.plotTitleCard("Sick Bay",fade:0) };
}, trimStart:1);
Trek.faders[15] = {~asrFader.(8, 3, 2)};
Trek.setTransition(15, -1, dur: 0, func:{
	~activateFader.(16);
	Trek.faderSynths[15].release;
});
Trek.faders[16] = {~asrFader.(8, 3, 2)};
Trek.setTransition(16, -1, dur: 2, func:{
	~activateFader.(17);
	Trek.faderSynths[16].release;
});
Trek.faders[17] = {~asrFader.(8, 5, 2)};
Trek.setTransition(17, -2, dur: 4.5, func: {
	1.5.wait;
	defer{ Stills.plotTitleCard("Temptation", dur:3) };
	(instrument:\cymbalsDS, att:2.5, amp:0.03,out:1, group: Trek.transitionGroup, addAction:\addToTail).play;
	(instrument:\cymbalsDS,lag:1, out:2, att:2.5, amp:0.03,out:1, group: Trek.transitionGroup, addAction:\addToTail).play;
	~activateFader.(18);
	Trek.faderSynths[17].release;
});
Trek.faders[18] = {~asrFader.(8, 6, 2)};
Trek.setTransition(18, -2, dur: 3.5, func: {
	~activateFader.(19);
	Trek.faderSynths[18].release;
});
Trek.faders[19] = {~asrFader.(4, 4, 2)};
Trek.setTransition(19, -4, dur: 1, func: {
	~activateFader.(20);
	Trek.faderSynths[19].release;
});
Trek.faders[20] = {~asrFader.(4, 4, 2)};
Trek.setTransition(20, -1, dur: 2, func: {
	~activateFader.(21);
	Trek.faderSynths[20].release;
});
Trek.faders[21] = {~asrFader.(4, 4, 2)};
Trek.setTransition(21, -1, dur: 3, func: {
	1.wait;
	defer{ Stills.plotTitleCard("The Bridge", fade:1) };
	~activateFader.(22);
	Trek.faderSynths[21].release;
}).value;

Trek.faders[22] = {~asrFader.(4, 4, 2)};
)
