
//SynthDef sources
//Quarks.gui
//SCLOrkSynths.gui;




		//improve bass end compression: could roll own compressor using Amplitude as here:
		//https://scsynth.org/t/multiband-compressor/3753/4

		SynthDef(\NC_MasterFX,{arg in=0;
			  	var input, process;
				var good;
	var lowend, therest;

			input= In.ar(0,2);

			//cut below 43 Hz to try to reduce feedback issues and spectral clutter (freq at 60 for this)
			// CheckBadValues anti inf/nan/denormal routine?
			//good = input * BinaryOpUGen('==', CheckBadValues.ar(input, 0, 0), 0);

			good = Sanitize.ar(input);

			//-6.dbamp
			//BLowShelf.ar(good,60,1.0, -40)
			process = Limiter.ar(LeakDC.ar(good)*0.5,0.99,0.01).clip(-1.0,1.0);

			//cascade for valid crossover filter https://scsynth.org/t/multiband-compressor/3753/4
			lowend = LPF.ar(LPF.ar(process,300),300);
			therest = process - lowend;

			//imaging flat for bass end, more compression on bass
			process = Pan2.ar(Limiter.ar(Mix(Compander.ar(lowend,lowend,0.1,1,1/9,mul:5))),0.0)+DelayC.ar(therest,0.01,0.01);

			//Limiter.ar(In.ar(0,numChannels),0.99,0.01)
			ReplaceOut.ar(0,Limiter.ar(process))
		}).add;



SynthDef(\NC_harpsichord2, {
	arg
	//Standard Values
	out = 0, amp = 0.1, freq = 440, pan = 0, rel = 5,
	//Pluck arguments (blend goes from 0 to 1)
	trig = 1, coef = 0.1, blend = 0.6;

	var exciter, root, octave, snd;

        // You can use white noise here, but Pink is more realistic
	exciter = PinkNoise.ar(amp);

	// Fundamental
        root = Pluck.ar(
	        in: exciter,
	        trig: trig,
	        maxdelaytime: 1/freq,
	        delaytime: 1/freq,
	        decaytime: rel,
	        coef: coef,
	        mul: blend
        );

	// Octave Above
	octave = Pluck.ar(
	        in: exciter,
	        trig: trig,
	        maxdelaytime: 1/(2 * freq),
	        delaytime: 1/(2 * freq),
	        decaytime: rel,
	        coef: coef,
	        mul: (1 - blend)
        );

	// Output Stuff
	snd = Mix.ar(root + octave);
	snd = Limiter.ar(snd);

    DetectSilence.ar(in: snd, doneAction: 2);

	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "Zé Craum",
	category: \keyboards,
	tags: [\pitched]
	)
).add;



SynthDef(\NC_OrganReed, {
    arg
	//Standard Values
	out = 0, pan = 0, freq = 440, amp = 0.3, gate = 1, att = 0.3, rel = 0.3,
	//Depth and Rate Controls (pwmDepth and amDepth range from 0 to 1)
	ranDepth = 0.04, pwmRate = 0.06, pwmDepth = 0.1, amDepth = 0.05, amRate = 5,
	//Other Controls
	nyquist = 18000, fHarmonic = 0.82, fFreq = 2442, rq = 0.3, hiFreq = 1200, hirs = 1, hidb = 1;

    var snd, env;

	// The same envelope controls both the resonant freq and the amplitude
    env = Env.asr(
		attackTime: att,
		sustainLevel: amp,
		releaseTime: rel).ar(gate: gate, doneAction: 2);

    // pulse with modulating width
	snd = Pulse.ar(
		freq: TRand.ar(lo: 2.pow(-1 * ranDepth), hi: 2.pow(ranDepth), trig: gate) * freq,
		width: LFNoise1.kr(freq: pwmRate, mul: pwmDepth).range(0, 1),
		mul: 0.0625);  //Incereasing this lessens the impact of the BPF

    // add a little "grit" to the reed
    //original used snd = Disintegrator.ar(snd, 0.5, 0.7);
	snd = Latch.ar(snd, Impulse.ar(nyquist * 2));

    // a little ebb and flow in volume
	snd = snd * LFNoise2.kr(freq: amRate).range((1 - amDepth), 1);

	//Filtering (BHiShelf intensifies the buzzing)
	snd = snd + BPF.ar(in: snd, freq: env.linexp(0, amp, fFreq * fHarmonic, fFreq), rq: rq);
    snd = BHiShelf.ar(in: snd, freq: hiFreq, rs: hirs, db: hidb);

	//Output
	snd = Mix.ar(snd * env);

    Out.ar(out, Pan2.ar(snd, pan));

},
metadata: (
	credit: "Nathan Ho aka Snappizz",
	category: \organ,
	tags: [\pitched, \tom, \sos]
	)
).add;


SynthDef("NC_harpsichord1", { arg out = 0, freq = 440, amp = 0.1, pan = 0;
    var env, snd;
	env = Env.perc(level: amp).kr(doneAction: 2);
	snd = Pulse.ar(freq, 0.25, 0.75);
	snd = snd * env;
	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "unknown",
	category: \keyboards,
	tags: [\pitched, \harpsichord]
)
).add;




(
  SynthDef(\NC_DistortedGuitar, {
    arg
    //Standard Values
    out = 0, pan = 0, amp = 0.1, freq = 220, rel = 4, crv = -3,
    // String and Plucking Hand Controls
    coef = 0.75, openStringFreq = 110, pickPos = 0.5, muteSus = 0.5,
    // Pickup Controls
    pickupPos = 0.17, pickupResfreq = 8000, pickupResrq = 0.5, pickupHPF = 250, pickupHPFrq = 0.8,
    // Distortion Controls
    preDistHPF = 600, postDistLPF = 2000, 
    gain = 0.5, t_trig = 1;

    var mute, snd,gate;

    // The Pick
    gate= \gate.kr(1);
    snd = Hasher.ar(Sweep.ar(1));
    snd = snd - DelayN.ar(
      in: snd,
      maxdelaytime: pickPos.clip(0, 1)/freq,
      delaytime: pickPos.clip(0, 1)/freq);

    // The String
    snd = Pluck.ar(
      in: snd,
      trig: t_trig,
      maxdelaytime: 1/freq,
      delaytime: 1/freq,
      decaytime: rel,
      coef: coef.clip(-1, 1)).poll;
    snd = LeakDC.ar(snd);

    // An Envelope for Muting the String
    mute = Env.new(
      levels: [1, 1, 0, 0],
      times: [muteSus, 0.075, 0.025]).ar(doneAction: 0);
    // Mute the String
    // snd = snd * mute;
    snd = snd * Env.asr(0,1,0).kr(2,gate:gate);
    snd = HPF.ar(
      in: snd,
      freq: LinExp.ar(
        in: mute,
        srclo: 0, srchi: 1,
        dstlo: 100, dsthi: 20));
    snd = LPF.ar(
      in: snd,
      freq: LinExp.ar(
        in: mute,
        srclo: 0, srchi: 1,
        dstlo: 20, dsthi: 10000));

    // The Pickup
    snd = snd - DelayN.ar(
      in: snd,
      maxdelaytime: pickupPos.clip(0, 1)/openStringFreq,
      delaytime: pickupPos.clip(0, 1)/openStringFreq);
    snd = RHPF.ar(
      in: snd,
      freq: pickupHPF,
      rq: pickupHPFrq);
    snd = BLowPass4.ar(
      in: snd,
      freq: pickupResfreq,
      rq: pickupResrq);

    snd = LeakDC.ar(snd);

    // The Distortion
    // snd = HPF.ar(
    //   in: snd,
    //   freq: preDistHPF);
    // snd = snd * gain;
    // snd = snd.tanh;
    // snd = LPF.ar(
    //   in: snd,
    //   freq: postDistLPF);
    snd =CrossoverDistortion.ar(snd,amp:0.5, smooth:0.8 ) /2 
    + AnalogVintageDistortion.ar(snd,drivegain:1) *2;

    // Output Stuff
    snd = snd * amp;
    snd = Limiter.ar(snd);

    DetectSilence.ar(in: snd, doneAction: 2);

    Out.ar(out, Pan2.ar(snd*0.2));
  },
  metadata: (
    credit: "Josh Mitchell",
    category: \guitar,
    tags: [\pitched]
  )
).add.tag(\guitar);
);


SynthDef(\NC_ModalMarimba, {
	arg
	// Standard values
	out = 0, freq = 440, amp = 0.1, att = 0.001, dec = 0.1, rel = 0.5, pan = 0,
	// Other controls, position goes from 0 to 1
	decCoef = 2, position = 0.414, ampSlope = 3;

	var freqarray, amparray, decarray, mallet, snd;

	// Array of frequencies, determined by solutions to the dynamic beam equation
	freqarray = Array.fill(30, { arg i; i + 1.5});
        freqarray[0] = 1.50561873;
	    freqarray[1] = 2.49975267;
	    freqarray = freqarray/1.50561873; // Normalize to freqarray[0] = 1

	// Array of amplitudes
	amparray = Array.fill(30, { arg i;
		if (freqarray[i] > 20000)
		    { 0 }
		    {
		        sin(((i + 1) * pi) * position) *
		        (ampSlope * (freqarray[i]).log2).dbamp
		    }
	});

	// Array of Decay times
	decarray = Array.fill(30, { arg i;
		exp(-1 * i * decCoef)
	}); // The decay times are dropping off exponentially

	// Hit the object
	mallet = Decay2.ar(
		in: Impulse.ar(0),
		attackTime: att,
		decayTime: dec,
		mul: 0.1);

	// Bank of resonators
	snd = Klank.ar(
		specificationsArrayRef: Ref.new([freqarray, amparray, decarray]),
		input: mallet,
		freqscale: freq,
		decayscale: rel);

	// Output stuff
	snd = Mix.ar(snd) * amp;
	snd = Limiter.ar(snd);

	DetectSilence.ar(in: snd, doneAction: 2);

	Out.ar(out, Pan2.ar(snd*0.5, pan));
},
metadata: (
	credit: "by Josh Mitchell",
	category: \percussion,
	tags: [\pitched, \modal]
)).add;



		//see also wrapping example in wrap help
		[
			[\FX1,{|in, spb|

				CombC.ar(in,spb, spb*(Rand(1.4)*0.25)+0.001,Rand(1,10))

			}],
			[\FX2,{|in, spb|

				FreeVerb.ar(in, 1, Rand(0.5, 0.98), Rand(0.2,0.7));
			}],
			[\FX3,{|in, spb|

				DelayC.ar(in, spb, spb*(Rand(1.4)*0.25));
			}],
			[\FX4,{|in, spb|

				//swing
				DelayC.ar(in, spb*0.38, spb*Rand(0.32,0.38));

			}],
			[\FX5,{|in, spb, param|

			var n = 10;

			//chorusing
			LeakDC.ar(Mix.fill(n, {
				DelayC.ar(in, 0.03, LFNoise1.kr(Rand(5.0,10.0),0.01*param,0.02) )
				}));

			}],
			[\FX6,{|in, spb, param|

			//phasing

			AllpassN.ar(in,0.02,SinOsc.kr(param,0,0.01,0.01)); //max delay of 20msec


			}],
			[\FX7,{|in, spb, param|

				//flanging
			var input = LeakDC.ar(in)+LocalIn.ar(1);
			var effect;

			effect = LeakDC.ar(DelayN.ar(input,0.02,SinOsc.kr(param,0,0.005,0.005))); //max delay of 20msec
				LocalOut.ar(0.995*Rand(0.05,0.15)*effect);

			}],


].do{|data|
	var name = \NC_ ++ data[0];

			SynthDef(name, {arg in=16, out=0, spb=0.5, gate=1, amp=0.3,param = 0.1;

				//var env = EnvGen.ar(Env([0,1,1,0],[fadein,dur-fadein-fadeout,fadeout],[envslopein,1,envslopeout]),doneAction:2);
				var env = EnvGen.ar(Env.asr(0.01,1,1),gate, doneAction:2);

				in  = In.ar(in,2);

				Out.ar(out,SynthDef.wrap(data[1],nil,[in,spb,param])*amp);
		}).add;

};


		SynthDef(\NC_PartConv, {arg in=16, out=0, bufnumL=0,bufnumR=0, gate=1, amp=0.3;

			var env = EnvGen.ar(Env.asr(0.01,1,1),gate, doneAction:2);
			var leftconv,rightconv;

			in  = In.ar(in,2);

			leftconv = PartConv.ar(in[0],2048,bufnumL);
			rightconv = PartConv.ar(in[1],2048,bufnumR);

			Out.ar(out,[leftconv,rightconv]*env*amp)

		}).add;








