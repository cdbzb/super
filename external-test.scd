
(
		{ d=Synth(\sine,[\freq,950,\pan,0]);
			4.wait;
			d.set(\freq, 150);
			3.wait;
			d.release;
		}.fork;
)
