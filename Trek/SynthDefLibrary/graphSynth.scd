SynthDef(\graphSynth, {
       SinOsc.ar(\freq.kr(800)) * \amp.kr(0.1)
    => {|i| CombC.ar(i, 1, \delay.kr(0.1), \decayTime.kr(3)) / 2 + i}
    * Env.asr(\att.kr(0.5), 1, 4).kr(2, gate: \gate.kr(1))
    => Pan2.ar(_, \pan.kr(-1))
    => Out.ar(\out.kr(0), _)
}).add;
