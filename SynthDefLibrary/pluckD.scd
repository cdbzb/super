	SynthDef(\pluckD,{|freq=400 amp=1|
		var sig= Pluck.ar(WhiteNoise.ar(0.1),  trig: \trig.tr(1),  maxdelaytime: 0.2,  delaytime: freq.reciprocal,  decaytime: \del.kr(5),  coef: \coef.kr(0.6),  mul: 1,  add: 0) ;
		sig=CrossoverDistortion.ar(sig,\drive.kr(0.9),\smooth.kr(0.1));
		sig=Phaser2.ar(sig,0.5,0.15,rq:1);
		Out.ar(\out.ir,  sig*amp);
	}).add.tag(\pluck);

	SynthDef(\pluckDEnv,{|freq=400 amp=1 release=3|
		var envelope= Env.cutoff(release).kr(2,gate:\gate.kr(1));
		var sig= Pluck.ar(WhiteNoise.ar(0.1),  trig: \trig.tr(1),  maxdelaytime: 0.2,  delaytime: freq.reciprocal,  decaytime: \del.kr(5),  coef: \coef.kr(0.6),  mul: 1,  add: 0) ;
		sig=CrossoverDistortion.ar(sig,\drive.kr(0.9),\smooth.kr(0.1));
		sig=Phaser2.ar(sig,0.5,0.15,rq:1);
		Out.ar(\out.kr,  sig*amp*envelope);
	}).add.tag(\pluck);

	SynthDef(\pluckDEnvPan,{|freq=400 amp=1 release=3 pan=0|
		var envelope= Env.cutoff(release).kr(2,gate:\gate.kr(1));
		var sig= Pluck.ar(WhiteNoise.ar(0.1),  trig: \trig.tr(1),  maxdelaytime: 0.2,  delaytime: freq.reciprocal,  decaytime: \del.kr(5),  coef: \coef.kr(0.6),  mul: 1,  add: 0) ;
		sig=CrossoverDistortion.ar(sig,\drive.kr(0.9),\smooth.kr(0.1));
		sig=Phaser2.ar(sig,0.5,0.15,rq:1);
		sig = Pan2.ar(sig,pan);
		Out.ar(\out.kr,  sig*amp*envelope);
	}).add.tag(\pluck);

SynthDef(\pluckDVerb,{|freq=400 amp=1| 
	var sig= Pluck.ar(
		WhiteNoise.ar(0.1),
		trig: \trig.tr(1),
		maxdelaytime: 0.2,
		delaytime: freq.reciprocal,
		decaytime: \del.kr(5),
		coef: \coef.kr(0.6)
	) ;
	sig=CrossoverDistortion.ar(sig,\drive.kr(0.9),\smooth.kr(0.1));
	sig=Phaser2.ar(sig,0.5,0.15,rq:1);
	sig=[sig,sig* Env.asr(0,1,2).kr(0,gate:\gate.kr(1)) => FreeVerb.ar(_,0.6,0.9)];
	sig=XFade2.ar(sig[0],sig[1],\blend.kr(0));  
	sig=DelayN.ar(sig,0.01,Rand(0.01));
	Out.ar(\out.ir, sig*amp);
	DetectSilence.ar(sig,doneAction:2)
}).add;
