
SynthDef(\suddenGrowth, {
    arg out=0, freq=100, growthTime=1, amp=0.5;
    var sig, env, freqEnv;

    // Frequency envelope: rapid exponential growth
    freqEnv = EnvGen.ar(
        Env(
            [freq, freq * 4],
            [growthTime],
            \exp
        )
    );

    // Amplitude envelope: quick attack, slow decay
    env = EnvGen.ar(
        Env.perc(0.01, growthTime * 1.5, curve: 2),
        doneAction: 2
    );

    // Main oscillator
    sig = SinOsc.ar(freqEnv * LFBrownNoise2.ar(5).range(0.9,1.1)) * env;

    // Add some complexity with FM synthesis
    sig = sig + (SinOsc.ar(freqEnv * 1.5) * env * 0.3);

    // Add some noise for texture
    sig = sig + (PinkNoise.ar() * env * 0.1);

    // Output
    Out.ar(out, sig * amp ! 2);
}).add;




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

