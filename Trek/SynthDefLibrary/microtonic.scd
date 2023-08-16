(
SynthDef (\Tonic,
{   |freq=50,lfofreq=200,lfoamount=0,penvamount=200,
		decaycurve=(-5),patt=0.001,pdec=0.200,shamount=0,shrate=3,
		ampatt=0.001,ampdec=0.7,ampdecaycurve=(-5),oscwaveform=1,amp=0.7,pan=0.2,noiseatt=0.001,noisedec=0.164,noiseamp=0.6,xfade=0,nfiltfreq=1800,noisereso=0.2,noisefiltselect=0,
		drive=2|
		var sin,tri,saw,lfo,modsh,penv,ampenv,sh,signal,noisesig,noiseenv,noisesigbp,noisesighp,noisesiglp;
		noisesig=WhiteNoise.ar*noiseamp;
		noiseenv=EnvGen.ar(Env([0,1,0],[noiseatt,noisedec],[0,-5]));
		noisesig=noisesig*noiseenv;
		noisesigbp=BPF.ar(noisesig,nfiltfreq,rq:noisereso);
		noisesighp=RHPF.ar(noisesig,nfiltfreq,rq:noisereso);
		noisesiglp=RLPF.ar(noisesig,nfiltfreq,rq:noisereso);
		noisesig=SelectX.ar(noisefiltselect,[noisesigbp,noisesighp,noisesiglp]);
		sh=LFNoise0.ar(shrate)*shamount;
		penv=EnvGen.ar(Env([0,1,0],[patt,pdec],[0,decaycurve]),doneAction:0)*penvamount;
		ampenv=EnvGen.ar(Env([0,1,0],[ampatt,ampdec],[0,ampdecaycurve]),doneAction:2);
		lfo=SinOsc.ar(lfofreq)*lfoamount;
		sin=SinOsc.ar(freq+penv+lfo+sh)*ampenv;
		tri=LFTri.ar(freq+ penv +lfo+sh)*ampenv;
		saw=LFSaw.ar(freq+penv+lfo+sh)*ampenv;
		signal=SelectX.ar(oscwaveform,[sin,tri,saw]);
		signal=XFade2.ar(signal,noisesig,pan:xfade);
		signal=((signal)*drive).tanh;
		signal=Pan2.ar(signal,pos:pan)*amp;
		Out.ar(0,signal);
	}).add.tag(\drum)
)

/*
~tonzer=Synth(\Tonic,[
			\oscwaveform,0,////////////0=sine,1=triangle,2=saw
			\freq,50,///////////////Osc frequency
			\lfofreq,100,//////////////Osc pitch lfo frequency
			\lfoamount,0,//////////////Osc pitch lfo amount
			\penvamount,200,///////////Osc pitch envelope amount
			\decaycurve,(-5),//////////Osc decay curve
			\patt,0.001,///////////////Osc pitch envelope attack
			\pdec,0.200,///////////////Osc pitch envelope decay
			\shamount,0,///////////////Osc pitch Sample and hold amount
			\shrate,3,/////////////////Osc pitch Sample and hold rate
			\ampatt,0.001,/////////////Osc amp atack
			\ampdec,0.7,///////////////Osc amp decay
			\ampdecaycurve,(-5),///////Osc amp decay curve
			\noiseamp,0.6,/////////////Noise amp
			\nfiltfreq,1800,///////////Noise filter freq
			\noiseatt,0.001,///////////Noise attack
			\noisedec,0.164,///////////Noise Decay
			\noisefiltselect,0,////////Noise filter select 0=bandpass, 1=res hp, 2=res lp
			\noisereso,0.5,////////////Noise filter Reso
			\xfade,0,//////////////////Crossfade between   Osc and Noise
			\drive,2,//////////////////Drive amount into Tanh shaper
			\pan,0,////////////////////pan output
			\amp,0.7,////////////Signal output volume
])
*/
