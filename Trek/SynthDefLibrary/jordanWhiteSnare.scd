(
SynthDef(\JWSnare, {
    var transient, resonance, snare;
    var sig;

    transient = WhiteNoise.ar + Pulse.ar(\transientFreq.kr(239), 0.3); // tweak freq to change pitch of transient
    transient = HPF.ar(transient, 120);
    transient = BPeakEQ.ar(transient, [300, 1000], 1, [1.1, 0.6]);
    transient = transient * Env.perc(0, 0.079).ar * 1.dbamp;
    
    snare = BPeakEQ.ar(WhiteNoise.ar, 2000, 1, 6.3) * Env.perc(0, 0.17).ar * -3.dbamp;
    snare = HPF.ar(snare, 300);

    resonance = transient + LocalIn.ar(1);
    resonance = DelayC.ar(resonance, 0.1, \resonancefreq.kr(86).reciprocal); // tweak delay time to change pitch of the resonance
    resonance = HPF.ar(resonance, 400);
    resonance = LPF.ar(resonance, 3000);
    resonance = BPeakEQ.ar(resonance, 550, 1.3, -4.3);
    resonance = resonance * \resonanceLength.kr(-0.11.dbamp); // tweak this to change length of resonance
    LocalOut.ar(resonance);

    resonance = resonance * -4.5.dbamp;

    
    sig = transient + resonance + snare ! 2; 
    sig = sig + DWGReverbC1C3.ar(sig * -20.dbamp).sum;
    sig = BPeakEQ.ar(sig, 900, 1, 2.5);
    sig = HPF.ar(sig, 150);
    sig = (sig * 1.6).tanh * 0.7;
    sig = sig * Env.perc(0, 0.7).ar(Done.freeSelf);
    sig = sig * -10.dbamp;
    Out.ar(\out.kr(0), sig * \amp.kr(0.1));
}).add;
)
