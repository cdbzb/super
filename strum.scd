(

    // strummable guitar

    // use mouse to strum strings

{

	var pitch, mousex, out;

	pitch = [ 52, 57, 62, 67, 71, 76 ];		// e a d g b e

	mousex = MouseY.kr;

	out = Mix.fill(pitch.size, { arg i;

		var trigger, pluck, period, string;

		// place trigger points from 0.25 to 0.75

		trigger = HPZ1.kr(mousex > (0.25 + (i * 0.1))).abs;

		pluck = PinkNoise.ar(Decay.kr(trigger, 0.05));

		period = pitch.at(i).midicps.reciprocal;

		string = CombL.ar(pluck, period, period, 4);

		Pan2.ar(string, i * 0.2 - 0.5);

	});

	LPF.ar(out, 12000);

	LeakDC.ar(out);

}.play;

)
