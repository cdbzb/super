
SynthDef(\sparkTriangle,{
	var vibrato=Vibrato.kr(\freq.kr(400,0.2),5);
	DPW3Tri.ar(vibrato)
	* Env.asr(1,\amp.kr(0.2),3).kr(2,gate:\gate.kr(1))
	=> Out.ar(\out.kr(0),_)
}).add;

