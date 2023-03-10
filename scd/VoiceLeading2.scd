
(
a=VoiceLeading([
	[1, 3 ,5  ,\r],
	[6, \_,6.5,\r],
	[8, \r,\r,11],
],
[1,1.2,1.5,2]
		);	
//		a.dm('d');
		{a.pm(\default).set(\amp,3.collect(0.2.rand),\detune,Ptuple([Pwhite(1,3!3)]),\mtranspose,7.rand,\legato,[Pwhite(0.1,2.rand),1,0.4],\out,4.collect((0..3).scramble.q),\pan,-1,\wet,0,\instrument,[\default,\stringyy,\sparkTriangle].choose!3).play;2.5.rand}
		=> TempoClock.sched(0,_);
		//TempoClock.tempo_(8)
		~stills
)
