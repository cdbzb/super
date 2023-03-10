// Construct a circulant feedback matrix using the given eigenvalues
(
// 1 - The eigenvalues of the feedback coefficient matrix
d = [
	-1,
        Polar(1, -3pi / 4),
        Polar(1, -pi / 2),
        Polar(1, -pi / 6),
        1,
        Polar(1, pi / 6),
        Polar(1, pi / 2),
        Polar(1, 3pi / 4)
];

// 2 - Compute the feedback matrix from the given eigenvalues
n = d.size;
a = (Matrix.newIDFT(n) * Matrix.withFlatArray(n, 1, d)).real.flat / sqrt(n);
)

(
s.waitForBoot({
        var primePowerDelays = { arg delays;
                (delays collect: { |delay, i|
                        var prime = i.nthPrime;

		        prime ** ((log(delay) / log(prime)) + 0.5).floor;
	        }).asInteger / s.sampleRate;
        };

        var delayLengths = { arg n, dmin, dmax;
	        var nm1 = n - 1;
	        var d = dmin * ((dmax / dmin) ** ((0..nm1) / nm1));
		
	        (d * s.sampleRate).round(1.0).asInteger;
        };

	SynthDef(\sine, { arg out, freq = 440, amp = 0.5, trigFreq = 1;
		Out.ar(out, Decay.ar(Impulse.ar(trigFreq), 0.2, SinOsc.ar(freq, 0, amp)))
	}).add;

	SynthDef(\fdn, { arg in, out, scale = 1.0, coef = 0.5;
		var a, x, w, fb, delT;

		fb = LocalIn.ar(n);

		a = \a.kr(0 ! n);
		delT = \delT.kr(primePowerDelays.(delayLengths.(n, 0.03, 0.06)));
		x = In.ar(in);
		w = a.size collect: { arg i;
			DelayN.ar(a.rotate(i).inject(x, { |input, coef|
				coef * fb[i] + input
			}), 1, (delT[i] * scale - ControlDur.ir).fold(0.0, 1.0))
		};

		LocalOut.ar(LeakDC.ar(OnePole.ar(w, coef)));

		Out.ar(out, w.sum.tanh ! 2)
	}).add;

	{ s.scope(2) }.defer
});
)

(
s.makeBundle(nil, {
        x = Synth(\sine, [\out, 10, \trigFreq, 0.25, \amp, 0.1], 1, \addToHead);
        y = Synth(\fdn, [\in, 10, \out, 0, \a, a, \scale, 1, \coef, 0.5], 1, \addToTail);
});
)
