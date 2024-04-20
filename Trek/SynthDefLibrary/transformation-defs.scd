	SynthDef(\trans, { |freq=333 amp=0.1 gate=1 out=0|
		var notes= Demand.kr(Dust.kr(0.3)+Impulse.kr(0.01,0.999),0,Dseq([freq,freq*2],inf));
		var sig=SinOsc.ar(Lag.kr(notes,0.6),0,0.1).distort*amp*Env.asr(0,1,5).kr(2, gate:gate);
		Out.ar(out,sig!4);
	}).add.tag(\fx) ;
	SynthDef(\transLinen, { |freq=333 amp=0.1 gate=1 out=0 attack=0 sustain=1 release=8|
		var notes= Demand.kr(Dust.kr(0.3)+Impulse.kr(0.01,0.999),0,Dseq([freq,freq*2],inf));
		var sig=SinOsc.ar(Lag.kr(notes,0.6),0,0.1).distort*amp*Env.linen(0,5,5).kr(doneAction:2);
		Out.ar(out,sig!4);
	}).add.tag(\fx) ;
