(

SynthDef (\cymbal, {|amp=1 length=2| //{{{
	var sig=PinkNoise.ar(EnvGen.kr(Env.perc(0,length)))!2;
	sig=TwoTube.ar(RHPF.ar(sig,500,9),d1length:502,d2length:777,loss:0.99)*0.5;
	DetectSilence.ar(sig,doneAction:2);
	Out.ar(0,sig*amp)}
).add; //}}}
SynthDef(\fb,
	{|out=1 |
		XOut.ar(out,0.3,
			FreeVerb.ar(In.ar(out,2),1.0,0.9)*1.2
		)
	}
).add;
SynthDef(\plate,
	{|out wet=1 |
		var in=In.ar(out);
		var sig = PlateReverb.ar(in);
		XOut.ar(out, wet, sig)
	}
).add;
SynthDef(\phaserr2,
	{| in out=0 rate=0.1 fb=0.3|
		var sig = Phaser2.ar(In.ar(in,2),rate:rate,fb:fb);
		XOut.ar(out, 1, sig)
	}
).add;
SynthDef(\phaserr,
	{|out rate=0.1 fb=0.3|
		var sig = Phaser2.ar(In.ar(out,2),rate:rate,fb:fb);
		XOut.ar(out, 1, sig)
	}
).add;
SynthDef(\dst,
	{|out gain=1.5|
		var in=In.ar(out);
		var sig = ( in*gain ).distort;
		XOut.ar(out, 1, sig!2)
	}
).add;
)
