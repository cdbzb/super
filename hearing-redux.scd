
(
	b={ |rate=0.2|
		a={|freq=400| SinOsc.ar(freq,0,0.05)}.play(s,1);
		//a={|freq=400|Blip.ar(freq/10,10,0.05)}.play(s,1);
		s.sync;
		inf.do({
			a.set(\freq,7100);
			0.2.wait;
			a.set(\freq,8800);
			0.2.wait;
			a.set(\freq,5);
			0.2.wait;
		});
	}.fork
)
s.meter;
