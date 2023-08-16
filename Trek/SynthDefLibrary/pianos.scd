
SynthDef(\help_oteypiano, { |out=0, freq=440,gate=1, amp=0.5,rho=1|
	var son = OteyPiano.ar(freq, amp, rho:rho)*EnvGen.ar(Env.asr(0,1,0.1),gate,doneAction:2);
	Out.ar(out, Pan2.ar(son * 0.1, LinLin.kr(freq,36.midicps,90.midicps,-0.75,0.75)));
}).add.tag(\piano);
