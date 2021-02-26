	SynthDef(\pluckD,{|freq=400 amp=1|
		var sig= Pluck.ar(WhiteNoise.ar(0.1),  trig: \trig.tr(1),  maxdelaytime: 0.2,  delaytime: freq.reciprocal,  decaytime: \del.kr(5),  coef: \coef.kr(0.6),  mul: 1,  add: 0) ;
		sig=CrossoverDistortion.ar(sig,\drive.kr(0.9),\smooth.kr(0.1));
		sig=Phaser2.ar(sig,0.5,0.15,rq:1);
		Out.ar(\out.ir,  sig*amp);
	}).add;

	SynthDef(\pluckDEnv,{|freq=400 amp=1 release=3|
		var envelope= Env.cutoff(release).kr(2,gate:\gate.kr(1));
		var sig= Pluck.ar(WhiteNoise.ar(0.1),  trig: \trig.tr(1),  maxdelaytime: 0.2,  delaytime: freq.reciprocal,  decaytime: \del.kr(5),  coef: \coef.kr(0.6),  mul: 1,  add: 0) ;
		sig=CrossoverDistortion.ar(sig,\drive.kr(0.9),\smooth.kr(0.1));
		sig=Phaser2.ar(sig,0.5,0.15,rq:1);
		Out.ar(\out.kr,  sig*amp*envelope);
	}).add;

