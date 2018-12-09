


// horizontal line
//	decorrelated pink noise?
//	true stereo noise?


(
~stereo_noise={Out.ar([0,1],PinkNoise.ar(0.1))};

~horizon={ |dur, vol|
	Routine.new({
		var sig={
		       var env=EnvGen.kr(Env.asr(2,1,2));
	       	       Out.ar([0,1],PinkNoise.ar(vol)*env)
	       }.play;
		dur.wait;
		sig.free;
		}
	)
}
)

~sea={ |angle sample|
	b=Buffer.read(s,sample);
	//ATK play sample at angle
	PlayBuf.ar (4, bufnum: b, rate: 1, trigger: 1, startPos: 0, loop: 0, doneAction: 0)
}

~horizon.(8,0.05).play;

//////////////////
score= {
	~intro;
	~center;
	~outtro;
}

