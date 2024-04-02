// See http://www.tcelectronic.com/media/1014018/skovenborg_nielsen_2007_loudness-meter_dafx.pdf for background.

(
// This is entirely interchangeable with a loudness algorithm of your
// choice. Just make sure that the values returned are in [0..1].
SynthDef(\loudness, {
	|in = 0, shortRate = 6, longRate = 6|
	var sig, chain, loudness;
	sig = In.ar(in, 1);
	chain = FFT(LocalBuf(1024), sig);
	loudness = Loudness.kr(chain) / 64.0;
	// The original paper uses an algorithm called "TC LARM" that has an
	// adjustable window size, using 0.5s for the short-term and 2.0s for
	// the long-term. Here we cheat and use the same loudness measurement
	// twice, with a lowpass on the long-term. With other algorithms you
	// may want to use their method. Keep in mind that having a nice
	// smooth long-term loudness is good for aesthetics.
	SendTrig.kr(Impulse.kr(shortRate), 0, loudness);
	SendTrig.kr(Impulse.kr(longRate), 1, LPF.kr(loudness, 0.3));
}).add;
)

~loudbus = Bus.audio(s, 1);

(
var size = 400;
var canv, synth, short, recv;
var longSize, long, longPos;
w = Window("Ring", Rect(100, 100, size, size));
w.front;

// Short-term loudness meter level
short = 0.0;
// Size of the long-term loudness history. Increase for a smoother display.
longSize = 256;
// Long-term loudness history
long = Signal.newClear(longSize);
// Make the position match the second hand on the clock, just for fun
longPos = ((Date.getDate.second + 45) * longSize / 60).asInteger % longSize;

synth = Synth.tail(s, \loudness, [
	\in, ~loudbus,
	\in, 1,
	\shortRate, 15,
	\longRate, longSize / 60
]);

canv = UserView(w, Rect(0, 0, size, size));
canv.background_(Color.black);
canv.drawFunc_ {
	var center, wedge;
	center = size@size * 0.5;

	wedge = { |l1, l2, color|
		Pen.color = color;
		Pen.addAnnularWedge(size@size * 0.5, size*0.4, size*0.45, (pi/2) + (1.5pi*l1), 1.5pi*(l2 - l1));
		Pen.fill;
	};

	// These levels and choices of color are for the sake of example.
	// They are in no way the best options, and you will want to tune them.
	case
	{ short < 0.3 } {
		wedge.(0, short, Color.green);
	}

	{ short < 0.6 } {
		wedge.(0.0, 0.3, Color.green);
		wedge.(0.3, short, Color.yellow);
	}

	{ short >= 0.6 } {
		wedge.(0.0, 0.3, Color.green);
		wedge.(0.3, 0.6, Color.yellow);
		wedge.(0.6, short, Color.red);
	};

	longSize.do { |i|
		var wedge;
		var rhoInner, theta1, theta2;
		theta1 = 2pi*i/longSize;
		theta2 = 2pi*(i+1)/longSize;
		rhoInner = size*0.1;

		wedge = { |base, l1, l2, color|
			var rhoB = rhoInner + (base*size*0.35);
			var rho1 = rhoInner + (l1*size*0.35);
			var rho2 = rhoInner + (l2*size*0.35);
			Pen.color = color.blend(Color.black, 1 - ((i - longPos + 1) % longSize / longSize));
			Pen.moveTo(center + Polar(rhoB, theta2).asPoint);
			Pen.lineTo(center + Polar(rho2, theta2).asPoint);
			Pen.lineTo(center + Polar(rho1, theta1).asPoint);
			Pen.lineTo(center + Polar(rhoB, theta1).asPoint);
			Pen.fill;
		};

		// These levels and choices of color are for the sake of example.
		// They are in no way the best options, and you will want to tune them.

		// BUG: Sometimes the quads look a little weird when two consecutive
		// samples bridge one of the color thresholds.

		case
		{ long[i] < 0.3 } {
			wedge.(0, long[i], long[(i+1)%longSize], Color.green);
		}

		{ long[i] < 0.6 } {
			wedge.(0.0, 0.3, 0.3, Color.green);
			wedge.(0.3, long[i], long[(i+1)%longSize], Color.yellow);
		}

		{ long[i] >= 0.6 } {
			wedge.(0.0, 0.3, 0.3, Color.green);
			wedge.(0.3, 0.6, 0.6, Color.yellow);
			wedge.(0.6, long[i], long[(i+1)%longSize], Color.red);
		};
	};
};

recv = OSCFunc({ arg msg;
	if (msg[1] == synth.nodeID) {
		if (msg[2] == 0) {
			short = msg[3].clip(0, 1);
			{ canv.refresh }.defer;
		};
		if (msg[2] == 1) {
			long[longPos] = msg[3].clip(0, 1);
			longPos = (longPos + 1) % longSize;
			{ canv.refresh }.defer;
		};
	};
}, '/tr', s.addr);

w.onClose_ {
	synth.free;
	recv.free;
};
)

// Listen in from a microphone
x = { SoundIn.ar(2) }.play(s, outbus: ~loudbus);
x.free;
