(
	b=SynthDef( \four, { | pitch=400 duty=0.5 wet=0.5 filter=1000 gate=1|
		//var sig = Pulse.ar(pitch, duty, 0.1);
		var sig = Pulse.ar(
			Vibrato.kr(pitch, LFNoise2.kr(1)+5, LFNoise2.kr(0.2)*0.02), duty, 0.1);
		sig = LPF.ar(sig,filter);
		sig = FreeVerb.ar(sig,wet,0.7); //replace with Convo!!
		Out.ar([0,1],sig*EnvGen.kr(Env.asr(1,1,9), gate, doneAction:2));
	},[9,9,9,9]).add;
)


( //do 4 times
Routine({
	var aa=Synth.new("four", [\pitch, 600,\duty ,0.5,\wet , 0.5,\filter , 600]);
	var offset=rrand(-300,10);
	12.do({
		[
	{ aa.set(\pitch, 700+offset, \filter, 1000, \duty, 0.1, \wet, 0) } ,
	{ aa.set(\pitch, 680+offset, \filter, 5000, \duty, 0.4, \wet, 1) } ,
	{ aa.set(\pitch, 666+offset, \filter, 800, \duty, 0.2, \wet, 0.2) } ,
	{ aa.set(\pitch, 720+offset, \filter, 14000, \duty, 0.02, \wet, 0.8) }
		].choose.value;
		rrand(3,6).yield; 
		});
		aa.release;
	}).play
)


	VarLag
s.meter;
