
	SynthDef(\two_tube,{|out=0 gate=1 |
		var in =In.ar(out,2);
		var sig=TwoTube.ar(in,d1length:507,d2length:819,loss:0.99);
		ReplaceOut.ar(out,sig*EnvGen.ar(Env.perc(0,7)));
	}).add;
