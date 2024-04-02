
SynthDef(\sparkTriangle,{
	var vibrato=Vibrato.kr(\freq.kr(400,\freqLag.kr(0.2)),5,\depth.kr(0.02));
	DPW3Tri.ar(vibrato)
	* Env.asr(\att.kr(1),\amp.kr(0.2),\rel.kr(3)).kr(2,gate:\gate.kr(1))
	=> Out.ar(\out.kr(0),_)
}).add.tag(\keys);
SynthDef(\sparkTrianglePan,{
	var vibrato=Vibrato.kr(\freq.kr(400,\freqLag.kr(0.2)),5,\depth.kr(0.02));
	DPW3Tri.ar(vibrato)
	* Env.asr(\att.kr(1),\amp.kr(0.2),\rel.kr(3)).kr(2,gate:\gate.kr(1))
	=> Pan2.ar(_, \pan.kr(0))
	=> Out.ar(\out.kr(0),_)
}).add.tag(\keys);

