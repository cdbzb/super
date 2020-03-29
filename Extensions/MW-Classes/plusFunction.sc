+ Function {
	sched { |when clock|
		var fun;
		clock ?? {clock = TempoClock.default};
		fun={when.asArray.do(clock.sched(_,this))};
		fun.value;
		^fun
	}
}

+ Synth {
	sched { |when clock|
		var fun;
		clock ? clock = TempoClock.default;
		fun={when.asArray.do(clock.sched(_,{this.run}))};
		fun.value;
		^fun
	}
}

//(
//	
//		{Synth(\default,[\freq,rrand(200.rand,1249.rand)]).dur(rand(7)+0.5)}.sched(
//			11.collect({ rrand(0,4.0)})
//			.do(_.gaussCurve)
//		)
//	.sched([0,10])
//)
//(
//	{Synth(\default).dur(2)}.sched([2,0.5]).sched([1])
//)
