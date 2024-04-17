
SynthDef(\pulse,{|gate=1 freq=400 amp=1 ffreq=4500 rel=2 out=0 t_trig wiggle=500| 
	var sig=Pulse.ar(freq,SinOsc.kr(8.55,0,0.6,0.4));
	var env= Env.perc(0,rel).kr(2,gate:t_trig)*amp;
	//var env=0.1;
	sig= MoogFF.ar(sig,SinOsc.kr(0.3,0,wiggle,1150));
	sig=HPF.ar(sig,500);
	Out.ar(0,sig*env!2)}
).add.tag(\keys);


SynthDef(\bl,{|gate=1 out=0 freq=400 t_trig=0  | //{{{
	var sig= SawDPW.ar(freq*[1,2],0,0.04 );  // add these octaves better
	//var env=Decay.kr(t_trig,0.4) ;
	var env= Env.perc(0.00,\rel.kr(0.3),curve:\sin).kr(0,gate:t_trig) ;
	var cleanup = Env.perc(0.00,1,curve:\sin).kr(2,gate:t_trig) ;

	sig= sig+CombN.ar(sig, 1, 0.35,  decaytime: 3,  mul: 0.5,  add: 0);
	sig = sig * \amp.kr(1);
	sig=DFM1.ar(sig,1800,0,5.9);//.distort;
	Out.ar(out,sig*env!2);
}).add.tag(\monoSynth,\bass);
