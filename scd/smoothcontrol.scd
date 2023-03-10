
(
a={
	var zeta = \zeta.kr(0.0), f = \f.kr(5), r= \r.kr(2);
	Saw.ar( \freq.kr(300) => SmoothControl.kr(_,f,zeta,r),0.1 )
	=> MoogFF.ar(_, SmoothControl.kr(\ffreq.kr(1000),f,zeta,r))
}.asSynthDef.add;
)
/*
(
~speaker =~speaker ? (0..4).q(inf).asStream;
//f = 100.exprand(1) + 1 => _.postln;
//r = 100.exprand(1) + 1 => _.postln;
f = 6; //f (inverse of frequency ie speed to target)
r = 10; // resonance
z = 0.6; //damping
fork{
	5.do{
		[
			f:f,
			r:r,
			dur:Prand([0.1,0.2,0.4,3,1.5],inf),
			degree:Pwalk((0..12),Pwhite(0,3,inf)),
			ffreq:Pbrown(500,4000,100,inf),
			out:1,
			octave:3.rrand(5),
			zeta:z,
			zeta:[1] ++ Pbrown(0.02,0.6,0.001,inf) => Pseq(_),
			out:~speaker.next,
			tuning: \sept7

		].pm(a.name).play;
		1.0.rand.wait
	}
}
)
*/
