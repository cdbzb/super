// Drum EventTypes
Event.addEventType(\yoeDrum0, {
	~amp = ~amp ? 1;
	~out = { Effect.bus({ |i| FreeVerb.ar(i, 1,1) * 8 }) };
	currentEnvironment.copy.put(\type,\note).play;
});

Event.addEventType(\yoeDrum1, {
	{ MembraneCircle.ar(excitation: Impulse.ar(0) => {|i| i  => Decay.ar(_, 0.3) * PinkNoise.ar(1) }, tension:SinOsc.ar(LFNoise0.ar().range(4,[ 5, 6 ])) /100 + 0.001, loss:0.9999) * XLine.kr (0.3,00001,9) => LeakDC.ar(_)}.play;
});

Event.addEventType(\yoeDrum2, { 
	(
		instrument:\cymbalsDS, amp: ( ~amp ? 0.1 ) * 10 * [ 0.02, 0.021 ] , out:Effect.bus({|i| FreeVerb.ar(i, 1, 1) * [3,2]})
	).play
});

Event.addEventType(\yoeDrum3, { 
	(instrument:[ \stringyy, \harpGendy ],freq:~freq, amp: 0.3 * 10 * ( ~amp ? 0.1 ), out: Effect.bus({|i| FreeVerb.ar(i, 1, 1) },)).play ;
});
