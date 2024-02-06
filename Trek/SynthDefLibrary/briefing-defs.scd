SynthDef(\mda,{ //{{{
	var sig=MdaPiano.ar(\freq.kr(400),\gate.kr(1)) * \amp.kr(0.1);
	Out.ar(\out.kr(0),sig);
	DetectSilence.ar(sig,0.01)
}).add; //}}}

SynthDef(\portBass,{ //{{{
	Formants.ar(\freq.kr(300,\port.kr(0.2)),Vowel().blend(Vowel(\u,\tenor),\blend.kr(0)))
	=>FreeVerb.ar(_,0.3,1)
	*\amp.kr(0.1)
	//				* Env.cutoff(1).kr(2,gate:\gate.kr(1))
	* Env.asr(\attack.kr(0),1,\release.kr(1)).kr(2,gate:\gate.kr(1))
	=>Out.ar(\out.kr(1),_)
}).add; //}}}

SynthDef(\tri,{ //{{{
	DPW3Tri.ar(\freq.kr(300,\port.kr(0))) * \amp.kr(0.1).distort
	* Env.asr(\attack.kr( 0.05 ),1,2).kr(2,gate:\gate.kr(1))
	=> FreeVerb.ar(_,\mix.kr(0.7),1)
	=>Out.ar (\out.kr(1),_)
}).add; //}}}

SynthDef(\pulseBBass2,{  //{{{
	var freq=\freq.kr(100,0);
	var fenv = Env.perc(0,0.5).range(300,freq*8).kr(0,gate:1);
	var env = Env.linen(0,0.2,0.5).kr(2,gate:1);
	var a = Saw.ar(freq*[0.5,1],\amp.kr(0.15)*[1,0.5]);
	//a[0] // mono
	a
	=>MoogFF.ar(_,fenv,\res.kr(2)) * env 
	=>Out.ar(\out.kr(0),_)
}).add; //}}}

