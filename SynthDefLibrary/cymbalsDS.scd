
	SynthDef (\cymbalsDS,{ //Dan Stowall Cymbals
		var lodriver, locutoffenv, hidriver, hicutoffenv, freqs, res, thwack;
		locutoffenv = EnvGen.ar(Env.perc(0.5, 5)) * 20000 + 10;
		lodriver = LPF.ar(WhiteNoise.ar(0.1), locutoffenv);
		hicutoffenv = (EnvGen.ar(Env.perc(1, 3))).range(10000,1);
		hidriver = HPF.ar(WhiteNoise.ar(0.1), hicutoffenv)
		* EnvGen.ar(Env.perc(1, 1, 0.25));
		thwack = EnvGen.ar(Env.perc(\att.kr(0.001),0.0001,1));
		freqs  = {ExpRand(300, 20000)}.dup(30);
		res	= Ringz.ar(lodriver + hidriver + thwack, freqs).mean;
		((res * 1) + (lodriver * 2) + thwack).dup * \amp.kr(0.1)
		=> ( Out.ar(\out.ir,_) <! DetectSilence.ar(_,doneAction:2))
	}).add.tag(\cymbal);
