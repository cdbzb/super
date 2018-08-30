ModSin : SinOsc {
	*new {|freq=400, rate=5,width=0.05, amp=0.1|
		^SinOsc.ar( SinOsc.kr (rate,0,width*freq,freq),0,amp)
	}
}

VibSin : SinOsc {
	*new {|freq=400, rate=5, width=0.05, delay=0.6, amp=0.1, onset=0.15, trig=1, rateVar=0.04, widthVar=0.1|
		^SinOsc.ar( Vibrato.kr (freq,rate,width,delay, onset, rateVar, widthVar,trig),mul:amp)
	}
}

Verb : UGen {
	*new { |bus=10, mix=1, room=0.8, damp=0.1|
		^FreeVerb.ar (In.ar(bus),mix,room,damp)
	}
}

Send : UGen {
	*new { |in,bus,  dry=0.5, wet=1|
		^Out.ar([0,1,bus],[in*dry, in*dry, in*wet])
	}
}



