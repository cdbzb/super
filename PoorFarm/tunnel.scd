s.boot




// tunnel


SynthDef.new("RiseUp", { arg out=0,bufnum=0;
	var rate;
	rate = XLine.kr(0.1, 50, 90);
	Out.ar(out, 
		PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*rate, 1.0, 0.0, 0.0, 2)
	)
}).send;


a={Saw.ar(300,0,0.1)}.play
a.free

(
	a = { var env,envGen;
	env=Env.triangle(dur: 10); // dur, lev
	envGen=EnvGen.kr(env,doneAction:2);
	Out.ar(0,Pan2.ar(Saw.ar(300+rrand(0,100),0.2*envGen),Line.kr(-0,1,10,1,0,2)))};


	b= Task ({

		loop {
			a.play;
			1.wait;
		};
	});
	b.start;
)

s.meter;

