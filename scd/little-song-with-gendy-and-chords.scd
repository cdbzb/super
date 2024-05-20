(
Song(\trashme, []).current;
["One", "r", [20]].addLine;
P(\busTest,music: { |p b e|
	a = Routine{
		100.do{
			{ 
				Gendy5.ar(minfreq: 300.rrand(600))
				/10
				* Env.perc(0.01, 10.xrand).kr(2,gate:1)
				=> Monitors.az(_, 2.0.rand )
			}.play;
			3.xrand.wait
		};
	};
		a.play;
		fork{
			e.bAll.sum.wait; a.stop
		}
	});
P(\buzzz,lag: 5, music: { |p b e|
	e.synth = {
		Saw.ar(
			[
				1, 3, 5, 7, 12, 14, 16
			].df(\e, tuning: \pythagorean)
			+ Gendy5.ar(minfreq: 0.1, maxfreq:{1.0.rand}!7).range(-10, 10)
			/( 4.rand + 1 )
		)
		/30
		* Env([0, 1, 1, 0],[7, 10, 7]).kr(2,gate:1)
	}.play
});
P(\buzzz,lag: 5, music: { |p b e|
	e.synth = {
		Saw.ar(
			[
				1, 3, 5, 7, 12, 14, 16
			].df(\e, tuning: \pythagorean)
			+ Gendy5.ar(minfreq: 0.1, maxfreq:{1.0.rand}!7).range(-10, 10)
			/( 4.rand + 1 )
		)
		/30
		* Env([0, 1, 1, 0],[7, 10, 7]).kr(2,gate:1)
	}.play
});
["Two", "r", [20, 5]].addLine;
P(\noise, music: { |p b e|
	{
		BrownNoise.ar(0.1)
		* Env.linen(2, b[0], b[1]).kr(2,gate:1)
		=> BPF.ar(_, freq:LFBrownNoise1.ar(
			LFBrownNoise1.ar(0.1).range(0.1,3)
		).exprange(20, 1000), rq:1.0, mul:1.0, add:0.0) 
		=> Monitors.az(_, LFBrownNoise1.ar(1))
	}.play
});
P(\buzzz,lag: 8, music: { |p b e|
	e.synth = {
		Saw.ar(
			[
				1, 3, 5, 7, 12, 14, 16
			].df(\e, tuning: \pythagorean)
			+ Gendy5.ar(minfreq: 0.1, maxfreq:{1.0.rand}!7).range(-10, 10)
			/( 4.rand + 1 )
		)
		/30
		* Env([0, 1, 1, 0],[7, 10, 7]).kr(2,gate:1)
	}.play
});
)

Song.buzzz_0.play
Song.buzzz_0.synth.release
// Song.busTest_0.bus.scope
{Impulse.ar(555) => Monitors.az(_, Phasor.ar(trig:1, rate:0.000001, start:0.0, end:10.0, resetPos:0.0)) / 20}.play
