
	a=0.iterate{|x| x+ rrand(0.9,1.1)};
(//music Box -- careful crashes!!

	{Synth(\default,[\out,5.rand,\pan,-1]).dur(1)}.sched(a.take(16));
	{Synth(\default,[\freq,2**(14.rand/12)*300,\pan,-1,\out,5.rand]) .dur(1) } .sched(a.take(32).asArray/2)
	{Synth(\default,[\freq,2**(14.rand/12)*660,\pan,-1,\out,5.rand]) .dur(1) } .sched(a.take(64).asArray/4)
)
