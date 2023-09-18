SynthDef(\ooh, {| out=0 gate=1| 
	Formants.ar(
		Vibrato.kr(\freq.kr(400,13),\rate.kr(rrand(6,7.0!5)),\depth.kr(0.02)),
		Vowel(\u,\soprano).blend(Vowel(\a,\soprano),VarLag.kr(\blend.kr(0),\lag.kr(0.5)))
	)
	=>Splay.ar(_)
	// * Env.cutoff(3).kr(2,gate:gate)
	* \amp.kr(0.1)
	* Env.asr(\att.kr(0),1,3).kr(2,gate:gate)
	// => PanAz.ar(4,_,\pan.kr(0))
	=>Out.ar(out,_)
} ).add.tag(\vox); 
