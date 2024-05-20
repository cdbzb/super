(
fork{
	b = Bus.control;
	{ Pulse.kr(0.1).range(0,1).lag(2) }.play(s, b);
	150.do{
		var pitches = [1, 5, 4, 3, 2, -5, -1].df([\a, \g, \d, \e].choose);
		var modFunc = {|freq| freq.floor % [ 29, 31 ].choose % 11 / 3 };
		{
			var scale = 1.rrand(1.7);
			var pitch = pitches.dq.demand("q q ex ex q q q".beats / scale);
			Saw.ar(
				pitch.lag([0,0,0,0.3].choose)
				*[1,2,4].choose
				// * In.kr(b).midiratio
				, SinOsc.ar(modFunc.(pitch))//.range(0.98,1,02)
			)
			+
			Saw.ar(
				pitch,
				* SinOsc.ar(modFunc.(pitch)).range(0.98,1,02)
			)
			/10
			=> LPF.ar(_, 400.rrand(4000))
			* 0.1.rrand(1)
			=> Pan2.ar(_, 1.rrand(-1))
			* Env.linen(0, 6.5/scale, 2.0.rand ).kr(2,gate:1)
		}.play;
		[0.1,0.2, 1.0, 4 ].choose.rand.wait

	}
}
)
