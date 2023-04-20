
(

SynthDef(\visual_caw ,{
	arg amp=0.01, delay1=100, delay2=50, k=0.0, loss=0.999,len=0.5, pan=0.0; 
	var source; 
	source = WhiteNoise.ar(0.4) * EnvGen.ar(
		Env([amp,amp,0,0],[(delay1+delay2)/SampleRate.ir,0.0,1.0])
	);
	Out.ar(\out.kr(0), Pan2.ar(
		TwoTube.ar(source,k,loss,delay1,delay2)
		* EnvGen.ar(
			Env([0,1,1,0],[0.001]++((len-0.001)*[0.4,0.6])),doneAction:2
		),pan)
	); 
}).add.tag(\pluck,\perc); 

SynthDef(\visual_aaa, { |out| 
	var vib = Vibrato.ar(\freq.kr(400,\flag.kr(0.1)),
	\rate.kr(6,0.1),
	\width.kr(0.005,0.1));
	var sig = Saw.ar(vib,\amp.kr(0.1))
	* Env.asr(\attack.kr(0),1,\release.kr(1)).kr(2,gate:\gate.kr(1));
	Out.ar(out,Pan2.ar(sig,\pan.kr(0),\amp.kr));
}).add.tag(\vox);

SynthDef(\visual_pad, {|freq=300 gate=1|
	var sig = Splay.ar({ Saw.ar(freq+Rand(-8,8),0.1)}!8);  
	var env = EnvGen.kr(Env.asr(0.05,\vel.kr(0.5),1,4),gate,doneAction:2);
	Out.ar(\out.kr(0),sig*env*\amp.kr(0.5))
}).add.tag(\pad);

SynthDef(\visual_twotube,{arg delay1=1000, delay2=500, k=0.0, loss=0.999, dur=0.5, pan=0.0; 
	var source; 
	source= ModSin(1000*LFNoise1.kr(1)+200).distort;
	Out.ar(0,Pan2.ar(TwoTube.ar(source,k,loss,delay1,delay2)*EnvGen.ar(Env([0,1,1,0],[0.001]++((dur-0.001)*[0.4,0.6])),doneAction:2),pan, level: 0.1)); 
}).add.tag(\sfx);

SynthDef(\visual_vowel, {|freq = 420|
	Out.ar([0,1]+\out.kr(0),
	Formants.ar(Vibrato.kr(freq.lag(0.1)), Vowel(\a).addControls(lag: 1)) * 0.1 * \amp.kr(1)
	* Env.asr(\attack.kr(0),1,\release.kr(1)).kr(2,gate:\gate.kr(1));
) }).add.tag(\vox);

)
