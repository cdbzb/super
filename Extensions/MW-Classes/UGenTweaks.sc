DetectSilenceDry : DetectSilence {
	
	*ar { arg in = 0.0, amp = 0.0001, time = 0.1, doneAction = 0;
		var both={ 
			DetectSilence.multiNew('audio', in.asAudioRateInput(this), amp, time, doneAction);
		Gain.ar(in.asAudioRateInput(this)) 
	};
	^both
	}
}

EchoCubic {
	*ar { arg in = 0.0, maxdelaytime = 0.2, delaytime = 0.2, decaytime = 1.0, mul = 1.0, add = 0.0, gain = 0;
		var mix = { 
			CombN.multiNew('audio', in.asAudioRateInput(this), maxdelaytime, delaytime, decaytime).madd(mul, add) /	( gain+(delaytime*60/decaytime)).dbamp
			+ in 

		};	
		^mix
	}
}

EchoNone {
	*ar { arg in = 0.0, maxdelaytime = 0.2, delaytime = 0.2, decaytime = 1.0, mul = 1.0, add = 0.0, gain = 0;

		var mix = { 
			CombN.multiNew('audio', in.asAudioRateInput(this), maxdelaytime, delaytime, decaytime).madd(mul, add)
			+ ( in * ( gain+(delaytime*60/decaytime)).dbamp )  

		};	
		^mix
	}
}
