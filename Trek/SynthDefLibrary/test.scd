
	SynthDef(\test,{|freq amp=1|
		Out.ar( 1,
			amp*RLPF.ar(Saw.ar(freq.lag(\lag.kr(2)),0.1*EnvGen.kr(Env.linen(0.05,0.5,2),doneAction:2)),freq*2+1500+SinOsc.ar(5.2,0,350),2))}).add;
	SynthDef(\testSustain,{|freq amp=1|
		Out.ar( 1,
			amp*RLPF.ar(Saw.ar(freq.lag(\lag.kr(2)),0.1*EnvGen.kr(Env.asr(\att.kr(0.05),1,\rel.kr(2)),doneAction:2)),freq*2+1500+SinOsc.ar(5.2,0,350),2))}).add;
