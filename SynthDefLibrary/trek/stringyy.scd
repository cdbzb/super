
	SynthDef(\stringyy,{ |gate=1 ampLag=0| //{{{
		var freq=\freq.kr(400,\freqLag.kr(0.05));
		var width=\width.kr(6);
		//var gate=\gate.kr(0);
		Gendy2.ar(minfreq:freq-width,maxfreq:freq+width)
		=>Mix.ar(_) *0.5
		+Gendy1.ar(minfreq:freq-width,maxfreq:freq+width)
		* 0.1 * \amp.kr(0.5,ampLag)
		=> (PlateReverb.ar(_,10,mix:\mix.kr(1)) ++ (_*0.5)) => Mix.ar(_)
		* Env.asr(\attack.kr(0.5),1,\release.kr(8)).kr(2,gate:gate)
		=>Out.ar(\out.kr(0),_)
	}).add; //}}}

