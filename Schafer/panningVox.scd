(
	SynthDef(\vocalPanner,{ |speakerNumber=0 panlag=0.3| //freq freqlag amp
	var panOrder = [1,6,2,5,3,0,4,8];
	var sig = Saw.ar(\freq.kr(400,\freqLag.kr-0.2),\amp.kr(0.1));
	var pan = Lag.kr(speakerNumber,panlag)/7	;
	sig = PanX.ar(8,sig, pan, width: 2);
	sig.do({|i x| Out.ar(panOrder[x]+10,i)});
	}).add
)

(
	Pmono(	\vocalPanner,
		\speakerNumber,Pseq([1,2,3,4,3,2,1,4,1],1),
		\panlag,2
		
	).play
)
	 s.meter;
	 Synth(\vocalPanner,[\speakerNumber,1]);
