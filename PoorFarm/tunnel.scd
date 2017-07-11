// IDEAS!
// very tiny window on shepards tone
// slow random movements like a cart wheel
//steel tube Altiverb


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

(
	a = { var env,envGen;
	~root = 160;	
	env=Env.triangle(dur: 10); // dur, lev	
	envGen=EnvGen.kr(env,doneAction:2);
	Out.ar(0,
		Pan2.ar
			(SinOsc.ar(~root+(rrand(0,10)*(~root/12))+Crackle.kr(1.95),Crackle.kr(1.96),0.05*envGen),
			Line.kr(-0,1,10,1,0,2))
		)};


	b= Task ({

		loop {
			a.play;
			rrand(1,4).wait;
		};
	});
	b.start;
)

(
	Task ({
		loop({
,			5.wait;
			~root = 150;
			rrand(10,20).wait;
			~root = 100;
			rrand(2,6).wait;	
			~root = 160;
		})
	})
)
s.meter;



