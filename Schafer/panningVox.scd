(
	SynthDef(\vocalPanner,{ |speakerNumber=0 panlag=0.3| //freq freqlag amp
	var panOrder = [1,6,2,5,3,0,4,7];
	var sig = Saw.ar(\freq.kr(400,\freqLag.kr(0.2)),\amp.kr(0.05));
	var pan = Lag.kr(speakerNumber,panlag)/7	;
	sig = PanX.ar(8,sig, pan, width: 2);
	sig.do({|i x| Out.ar(panOrder[x]+10,i)});
	}).add;
)
// version that accepts array input
SynthDef(\vocalPanner2,{ |order=[1,6,2,5,3,] spkr, panlag| 
	
})

(
	Pmono(	\vocalPanner,
		\speakerNumber,Pseq([1,2,3,4,3,2,1,4,1,0,1,0,7,6],inf),
		//\speakerNumber,Pseq([7,6,7,6],inf),
		\panlag,1,
		\freqLag,1,
		\tempo,1.5,
		\freq,Pwhite(260,330)
	).play
)
	 s.meter;

	 {Out.ar(17,Saw.ar(100,0.04))}.play;
a= Synth(\vocalPanner,[\speakerNumber,7,\freq,190]);
a.set([\panlag,3,\speakerNumber,8])
a.free;
s.plotTree;
s.freeAll;
b = [1,8,6,8,2,8,5,8,3,8,0,8,4,8]; //passing throuigh top on the way

s;

