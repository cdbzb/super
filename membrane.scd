(
SynthDef(\circularMembrane, {
	arg
	// Standard values
	out = 0, freq = 160, amp = 0.5, att = 0.0001, hold = 0, dec = 0.05, rel = 4, pan = 0, crv = 0,
	// Other controls
	decCoef = 0.5, position = 0.8, slope = 0.5, thumpAmp = 0.7, thumpDec = 0.2;

	var exciter, freqArray, ampRowArray, ampArray, decArray, snd;

	// From a Bessel Funtion solver in matlab, normalized to 1 at freqArray[0][1]
	freqArray = [
		[ 0.6276, 1,      1.3403, 1.6651, 1.9804, 2.2892, 2.5931, 2.8933,
		  3.1905, 3.4852, 3.7778, 4.0686, 4.3579, 4.6458, 4.9325, 5.2182 ],
		[ 1.4406, 1.8309, 2.1967, 2.5474, 2.8877, 3.2201, 3.5465, 3.8681,
		  4.1855, 4.4996, 4.8108, 5.1194, 5.4258, 5.7301, 6.0328, 6.3338 ],
		[ 2.2585, 2.6551, 3.0326, 3.3967, 3.7509, 4.0974, 4.4377, 4.7727,
		  5.1033, 5.4302, 5.7538, 6.0745, 6.3927, 6.7085, 7.0223, 7.3342 ],
		[ 3.0774, 3.4772, 3.8615, 4.234, 4.5974, 4.9534, 5.3033, 5.648,
		  5.9882, 6.3246, 6.6575, 6.9873, 7.3144, 7.6391, 7.9615, 8.2818 ],
		[ 3.8967, 4.2985, 4.6872, 5.0655, 5.4354, 5.7984, 6.1555, 6.5075,
          6.8551, 7.1988, 7.539, 7.8761, 8.2104, 8.5422, 8.8716, 9.1988 ],
		[ 4.7162, 5.1194, 5.5111, 5.8936, 6.2685, 6.6368, 6.9995, 7.3573,
		  7.7108, 8.0605, 8.4067, 8.7497, 9.0899, 9.4276, 9.7628, 10.0958 ],
		[ 5.5358, 5.9399, 6.334, 6.7198, 7.0984, 7.471, 7.8382, 8.2007,
		  8.5591, 8.9136, 9.2648, 9.6128, 9.9581, 10.3007, 10.6409, 10.9789 ],
		[ 6.3555, 6.7603, 7.1562, 7.5445, 7.9262, 8.3022, 8.6732, 9.0396,
          9.402, 9.7607, 10.1161, 10.4684, 10.8179, 11.1649, 11.5094, 11.8517 ],
		[ 7.1753, 7.5807, 7.978, 8.3683, 8.7525, 9.1314, 9.5054, 9.8752,
		  10.241, 10.6033, 10.9623, 11.3183, 11.6715, 12.0222, 12.3706, 12.7167 ],
		[ 7.995, 8.4009, 8.7993, 9.1914, 9.5777, 9.959, 10.3357, 10.7082,
          11.077, 11.4424, 11.8046, 12.1638, 12.5203, 12.8744, 13.226, 13.5755 ],
		[ 8.8148, 9.221, 9.6205, 10.0139, 10.4021, 10.7854, 11.1643, 11.5394,
          11.9107, 12.2788, 12.6438, 13.0059, 13.3653, 13.7223, 14.0769, 14.4294 ],
		[ 9.6346, 10.0412, 10.4414, 10.8361, 11.2257, 11.6108, 11.9918, 12.3689,
		  12.7426, 13.113, 13.4805, 13.8451, 14.2072, 14.5668, 14.9241, 15.2793 ],
		[ 10.4545, 10.8612, 11.2622, 11.6579, 12.0489, 12.4356, 12.8183, 13.1973,
		  13.573, 13.9455, 14.3152, 14.6821, 15.0465, 15.4085, 15.7683, 16.1259 ],
		[ 11.2743, 11.6813, 12.0829, 12.4795, 12.8716, 13.2597, 13.6439, 14.0246,
		  14.4021, 14.7766, 15.1482, 15.5172, 15.8837, 16.2479, 16.6099, 16.9697 ],
		[ 12.0941, 12.5013, 12.9034, 13.3009, 13.694, 14.0833, 14.4689, 14.8512,
		  15.2303, 15.6064, 15.9799, 16.3507, 16.7192, 17.0853, 17.4493, 17.8112 ],
		[ 12.914, 13.3214, 13.7239, 14.1221, 14.5162, 14.9065, 15.2933, 15.677,
		  16.0575, 16.4353, 16.8103, 17.1829, 17.5531, 17.921, 18.2869, 18.6507 ],
	];

	// An approximation that I guessed at for each mode's amplitude, depending on
	// where on the drum it was hit, with position = 0 at the center and
	// position = 1 at the edge of the membrane.
	ampRowArray = Array.fill(16, {
		arg i;
		if (i == 0)
			{ thumpAmp }
			{
		        (1 - (2 * (4 * i) * sin(pi/(2 * i))/(3 * pi))) *
		        (
		            (
			        	((4 * i) * sin(pi/(2 * i))/(3 * pi)).pow(2) -
		                ((4 * i) * sin(pi/(2 * i))/(3 * pi))
		            ).pow(-2)
	            ) *
		        (
			        position.pow(3) - position +
			        (
			        	(position - position.pow(2)) *
			            ((3 * ((4 * i) * sin(pi/(2 * i))/(3 * pi)).pow(2)) - 1)/
			            ((2 * ((4 * i) * sin(pi/(2 * i))/(3 * pi))) - 1)
			        )
		        )
		    }
	});
	ampArray = Array.fill2D(16, 16, {
		arg i, j;
		if (freqArray[i][j] > 20000)
	    	{ 0 }
		    {
		        cos(pi * position * ((2 * i) + 1)/2) * ampRowArray[j]
		    }
	});

	// Quick decay time approximation
	decArray = Array.fill2D(16, 16, {
		arg i, j;
		(
			if (j == 0)
		        { thumpDec }
		        { 1 }
		) *
		exp(-1 * (i + j) * decCoef)
	});

	// Exciter
	exciter = Env.linen(
		attackTime: att,
		sustainTime: hold,
		releaseTime: dec,
		level: 0.01,
		curve: crv).ar;

	// Bank of resonators
	snd = Array.fill(16, {
		arg i;
			DynKlank.ar(
		        specificationsArrayRef:
		    	    Ref.new([freqArray[i], ampArray[i], decArray[i]]),
		        input: exciter,
		        freqscale: freq,
		        decayscale: rel
	        )
	});

	// Output stuff
	snd = Mix.ar(snd) * amp;
	snd = Limiter.ar(snd);

	DetectSilence.ar(in: snd, doneAction: 2);

	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (credit: "Josh Mitchell 2020")
).add;
)
// Example Sound:
 Synth(\circularMembrane, [position: rrand(0.55, 0.9)]);
 (
// Example Sound:
)
(
Synth(\circularMembrane, [
position: rrand(0.05, 0.9),
decCoef: 0.02,
slope: 0.1,
thumpAmp: 0.9,
thumpDec: 0.2
]);
)
{PinkNoise.ar(0.1) }.play
s.boot
(
SynthDef(\tapedly, {
	|in=0, out=0,fb=0.6, fc=5000, dlytime=0.125, wet=0.5, pan=0.0|
	var local, sig, delayed, phi, phR, phP, freq;
	var tdbh; // time delay between heads (seconds)
	local = LocalBuf(SampleRate.ir * 3, 1);
	local.clear; // clear the buffer

	tdbh = 0.125;
	phi = (2 * tdbh) / BufDur.ir(local);
	freq = 1.0 / BufDur.ir(local); // frequency to playback the buffer at rate 1
	freq = (freq * tdbh) / VarLag.kr(dlytime, 2, warp:\linear);
	phR = LFSaw.ar( freq, phi, 0.5, 0.5)*BufFrames.kr( local );
	phP = LFSaw.ar( freq, 0.0, 0.5, 0.5)*BufFrames.kr( local );

	sig = Mix.ar(In.ar(in,2));
	delayed = BufRd.ar(1, local, phP, loop:1);
	delayed = delayed.tanh;
	BufWr.ar( LPF.ar( (sig + delayed), fc, mul:fb), local, phR, loop:1);
	pan = LFNoise1.ar(5);
	Out.ar(out, Pan2.ar(delayed*wet, pan));
}).add;
)// instantiate the delay and eventually set some of its parameters
d = Synth(\tapedly, [\in, 0, \dlytime, 0.333, \fb, 0.5, \wet, 1.0]);
d.set(\dlytime, 0.25, \fb, 0.8,\wet, 1.0,\fc, 5000)

// define a test synth
(
SynthDef(\pulse, {
	|freq=440, fb=0.5, amp=1.0, atk=0.0, rel=0.1, out=0, pan=0.0|
	var env = EnvGen.ar(Env.perc(atk, rel), 1, doneAction:2);
	var sig = SinOscFB.ar(freq, fb) * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// and use it via a Pbindef
(
Pbindef(\testPulses,
	\instrument, \pulse,
	\scale, Scale.minor,
	\octave, Prand([4,5,6],inf),
	\degree, Prand([-1,0,2], inf),
	\fb, Pexprand(0.1, 0.7, inf),
	\atk, 0.01,
	\rel, Prand([0.125, 0.25, 0.5], inf),
	\dur, Prand([0.25,0.5],inf),
	\amp, 0.25,
	\out, 0,
	\pan, 0.0,
	\addAction, Pwrand([0,1],[3, 10].normalizeSum,inf)
).quant_(1).play;
)
s.meter
