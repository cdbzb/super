
SynthDef(\suddenGrowth, {
    arg out=0, startFreq=100, endFreq=400, len=0.5, amp=0.5;
    var sig, env, freqEnv;

    freqEnv = Env( [startFreq, endFreq], len, \exp).kr(0)
	+ LFBrownNoise1.ar(50, mul:5)
	;
    // Main oscillator
    SinOsc.ar(freqEnv 
		// + 
		// ( LFBrownNoise2.ar(5) *80 )
	)
    // Add some complexity with FM synthesis
    + SinOsc.ar(freqEnv * 1.5, 0, 0.3)
    + PinkNoise.ar(0.1)
    * Env.perc(0.01,  len * 1.5, curve: 2).kr(2)
    => Out.ar(out, _)
}).play;




SynthDef(\growingBalloonRub, {
    arg out=0, freq=500, growthTime=2, pressure=0.7, amp=0.5;
    var sig, env, freqEnv, noiseEnv, friction;

    // Frequency envelope: gradual exponential growth
    freqEnv = EnvGen.ar(
        Env(
            [freq, freq * 2.5],
            [growthTime],
            \exp
        )
    );

    // Amplitude envelope: slow attack, slow decay
    env = EnvGen.ar(
        Env.perc(growthTime * 0.3, growthTime * 0.7, curve: 2),
        doneAction: 2
    );

    // Noise envelope: fluctuating pressure
    noiseEnv = LFNoise1.kr(10).range(0.5, 1) * pressure;

    // Friction sound
    friction = (BPF.ar(
        WhiteNoise.ar(),
        freqEnv * (LFNoise1.kr(5).range(0.95, 1.05)),
        0.1
    ) * noiseEnv).tanh;

    // Resonant body sound
    sig = SinOsc.ar(freqEnv) * env * 0.3;

    // Combine friction and resonance
    sig = (friction + sig) * env;

    // Add some squeaking
    sig = sig + (SinOsc.ar(freqEnv * 2) * env * noiseEnv * 0.2);

    // Output
    Out.ar(out, Pan2.ar(sig * amp, LFNoise1.kr(2).range(-0.3, 0.3)));
}).add;

