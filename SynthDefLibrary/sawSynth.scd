	SynthDef("sawSynthSustain", { arg out=0, freq = 440, amp = 0.1, att = 0.1, rel = 2, lofreq = 1000, hifreq = 3000, lagTime = 0.3, spread=1, center=0;
		var env, snd;
		freq=Lag.kr(freq,lagTime);
		env = Env.asr(
			attackTime: att,
			sustainLevel: amp,
			releaseTime: rel,
		).kr(gate:\gate.kr(1),doneAction: 2);
		snd = Saw.ar(freq: freq * [0.99, 1, 1.001, 1.008]) * env;
		snd = LPF.ar(
			in: snd,
			freq: LFNoise2.kr(1).range(lofreq, hifreq)
		);
		snd = Splay.ar(snd,spread:spread,center:center);
		Out.ar(out, snd);
	}).add;
//
	SynthDef("sawSynth", { arg out=0, freq = 440, amp = 0.1, att = 0.1, rel = 2, lofreq = 1000, hifreq = 3000, lagTime = 0.3, spread = 1, center = 0;
		var env, snd;
		freq=Lag.kr(freq,lagTime);
		env = Env.perc(
			attackTime: att,
			releaseTime: rel,
			level: amp
		).kr(doneAction: 2);
		snd = Saw.ar(freq: freq * [0.99, 1, 1.001, 1.008], mul: env);
		snd = LPF.ar(
			in: snd,
			freq: LFNoise2.kr(1).range(lofreq, hifreq)
		);
		snd = Splay.ar(snd,spread:spread,center:center);
		Out.ar(out, snd);
	}).add;

	SynthDef("sawSynthEnv", { arg out=0, freq = 440, amp = 0.1, att = 0.1, rel = 2, lofreq = 1000, hifreq = 3000, lagTime = 0.3, spread=1, center=0;
		var env, snd;
		freq=Lag.kr(freq,lagTime);
		env = Env.asr(
			attackTime: att,
			sustainLevel: amp,
			releaseTime: rel,
		).kr(gate:\gate.kr(1),doneAction: 2);
		snd = Saw.ar(freq: freq * [0.99, 1, 1.001, 1.008]) * env;
		snd = LPF.ar(
			in: snd,
			freq: LFNoise2.kr(1).range(lofreq, hifreq)
			* Env.asr(0.6,1,0.8).kr(0,gate:1)
			+ ( freq * 0.15 )
		);
		snd = Splay.ar(snd,spread:spread,center:center);
		Out.ar(out, snd);
	}).add;
