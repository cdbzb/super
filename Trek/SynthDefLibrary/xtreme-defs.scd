
SynthDef(\plateReplace,{|in gate=1 bus| 
	//var sig=In.ar(Song.bassBuss.index,2);
	var sig=In.ar(bus,2);
	sig=sig* Env.asr(0,1,0.1).kr(2,gate:gate);
	ReplaceOut.ar(bus,PlateReverb.ar(sig,mix:0.9));
}).add;
SynthDef(\xtremeBass,{|amp=1 decimate=0 out=0 dur=1 bus| 
	var sig = In.ar(bus)!2;
	//Env.perc(~xtreme.durTillEnd+1).kr(2,gate:1);
	Env.perc(dur+1).kr(2,gate:1);
	sig= XFade2.ar(sig,Decimator.ar(sig,rate:8000,bits:4)*(-6.dbamp),Lag.kr(decimate,1));
	Out.ar(out,sig*amp)
}).add;
SynthDef (\cymbal, {|amp=1 length=2| 
	var sig=PinkNoise.ar(EnvGen.kr(Env.perc(0,length)))!2;
	sig=TwoTube.ar(RHPF.ar(sig,500,9),d1length:502,d2length:777,loss:0.99)*0.5;
	DetectSilence.ar(sig,doneAction:2);
	Out.ar(0,sig*amp)}
).add; 
SynthDef(\plate_phaser_insert,{
	|inBus=0 gate=1|      
	var env= Env.cutoff(15,curve:\cub).kr(2,gate:gate);
	var sig = In.ar(inBus,2);
	sig=PlateReverb.ar(sig,mix:0.5,decayTime:0.55);
}).add;
