SynthDef(\defaultPorto,{|fixOut=(-1)|
	var freq=\freq.kr(400,0.5)-5;
	var gate=\gate.kr(1);
	var width=\width.kr(19);
	var release=\release.kr(3);
	var sig;
	Gendy4.ar(4,1,1,1,freq-width,freq+width,\ampScale.kr(0.1),\durScale.kr(0.1),Rand(11)+1)
	+ Saw.ar(freq,0.05)
	* Env.asr(\attack.kr(2),1,release).kr(0,gate:gate)
	* 0.1
	=> BMoog.ar(_,1800,0.2,2.1)
	=> FreeVerb.ar(_,0.4,1)
	=> LeakDC.ar(_)
	* \amp.kr(0.1) * 10
	=> .first
	DetectSilence.ar(_,doneAction:2)
	//=> DetectSilenceDry.ar(_,doneAction:2)
	=> Out.ar((fixOut==(-1)).if {Rand(4)}{fixOut},_);
//	Env.cutoff(release+3).kr(2,gate:gate)
},variants:(
	noisy1: [\ampScale,1.0,\durScale,1.5],
	clean: [\ampScale,0.5,\durScale,5.5]
 )).add.tag(\gendy);

SynthDef(\defaultPortoCP,{
	var freq=\freq.kr(400,0.5)-5;
	var gate=\gate.kr(1);
	var width=\width.kr(19);
	var release=\release.kr(3);
	var sig;
	Gendy4.ar(4,1,1,1,freq-width,freq+width,\ampScale.kr(0.1),\durScale.kr(0.1),\initCP.kr(3))
	+ Saw.ar(freq,0.05)
	* Env.asr(\attack.kr(2),1,release).kr(0,gate:gate)
	* 0.1
	=> BMoog.ar(_,1800,0.2,2.1)
	=> FreeVerb.ar(_,0.4,1)
	=> LeakDC.ar(_)
	* \amp.kr(0.1) * 10
	=> .first
	DetectSilence.ar(_,doneAction:2)
	//=> DetectSilenceDry.ar(_,doneAction:2)
	=> Out.ar(Rand(4),_);
//	Env.cutoff(release+3).kr(2,gate:gate)
},variants:(
	noisy1: [\ampScale,1.0,\durScale,1.5],
	clean: [\ampScale,0.5,\durScale,5.5]
 )).add.tag(\gendy);

SynthDef(\defaultPortoGendy1,{
	var freq=\freq.kr(400,0.5)-5;
	var gate=\gate.kr(1);
	var width=\width.kr(19);
	var release=\release.kr(3);
	var sig;
	Gendy1.ar(4,1,1,1,freq-width,freq+width,\ampScale.kr(0.1),\durScale.kr(0.1),\initCP.kr(3))
	+ Saw.ar(freq,0.05)
	* Env.asr(\attack.kr(2),1,release).kr(0,gate:gate)
	* 0.1
	=> BMoog.ar(_,1800,0.2,2.1)
	=> FreeVerb.ar(_,0.4,1)
	=> LeakDC.ar(_)
	* \amp.kr(0.1) * 10
	=> .first
	DetectSilence.ar(_,doneAction:2)
	//=> DetectSilenceDry.ar(_,doneAction:2)
	=> Out.ar(Rand(4),_);
//	Env.cutoff(release+3).kr(2,gate:gate)
},variants:(
	noisy1: [\ampScale,1.0,\durScale,1.5],
	clean: [\ampScale,0.5,\durScale,5.5]
 )).add.tag(\gendy);
