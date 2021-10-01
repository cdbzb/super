(
SynthDef( \shush,  { 
	[GrayNoise.ar(0.1) , PinkNoise.ar(0.1), BrownNoise.ar(0.1), WhiteNoise.ar(0.1)]
	=> SelectXFocus.ar(LFBrownNoise1.ar(1!4)+3,_,1,wrap:true)
	=> Splay.ar(_)
	* Env.asr(\attack.kr(3),1,10).kr(gate:\gate.kr(1),doneAction: 2)
	=> Out.ar(\out.kr(0),_)
}).add.tag(\sfx)
)
