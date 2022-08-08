SynthDef (\kick_gentle,
{
		arg pitch=42,patt=0.001,pdec=0.8,pcurve=(-50),pamt=100,att=0.001,dec=0.700,noisefreq=100,shamt=2,vol=0.3;
		var kick,penv,ampenv,noiseosc;
		penv=EnvGen.ar(Env([0,1,0],[patt,pdec],[0,pcurve]),doneAction:2);
		kick=SinOsc.ar(pitch+(penv*pamt))*0.9;
		noiseosc=LPF.ar(WhiteNoise.ar(0.1),noisefreq);
		kick=(noiseosc+kick)*EnvGen.ar(Env([0,1,0],[att,dec],[0,-5]))!2;
		kick=SineShaper.ar(kick*shamt)*vol;
		kick=HPF.ar(kick,80);
		Out.ar(0,kick);
}).add
.tag(\kick);


SynthDef (\pulse_gentle,
{
|att=0.001,dec=0.200,envAmount=150,pitch=0,filterfreq=400,reso=0.5,amp=0.1,pan=0,pw=0.5,pww=0.8|
var sig,env;

		env=EnvGen.ar(Env([0,1,0],[att,dec],[0,-5]),doneAction:2);
		sig=Pulse.ar(pitch,mul:0.5,width:pw)+Pulse.ar((pitch*0.2.midiratio),mul:0.5,width:pww);///////I an
		sig=RLPF.ar(sig,filterfreq+(env*envAmount).clip(40,20000),rq:reso);
		sig=sig*env;
		sig=Pan2.ar(sig,pos:pan);
		Out.ar(0,sig*amp)
}).add.tag(\keys)
