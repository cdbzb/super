(
SynthDef(\Pdefhelp, { arg out, freq, sustain=1, amp=1, pan;
    var env = EnvGen.kr(Env.perc(0.01, sustain), 1, doneAction:2);
    Out.ar(out, Pan2.ar(SinOsc.ar(freq, 0.5pi, amp * env), pan));
}).add;
)
// event pattern as an argument
Pdef(\x, Pbind(\instrument, \Pdefhelp, \note, Pbrown(0, 6, 0.1, inf), \dur, 0.2));
Pdef(\x); // omitting the second argument, we can access the proxy
Pdef(\x).play; // ... play one event stream
Pdef(\x).source.postcs; // ... and inspect the event pattern itself.


// function as an argument, create a new pattern each time it is called
Pdef(\x, { Pbind(\note, Pseries(10.rand, 5.rand, 8.rand + 1), \dur, 1 / (8.rand + 1)) });
Pn(Pdef(\x)).play;

// the function is called in the incoming event as current environment, so parameters can be passed:
Pdef(\stut, { Pstutter(~stutter ? 1, ~pattern) });
Pdef(\x, Pbind(\instrument, \Pdefhelp, \note, Pseq([0, 4, 7, 3, 0, 1, 0], inf)));
Pdef(\y, Pdef(\stut) <> (pattern: Pdef(\x), stutter: Pseq([2, 2, 4, 3], inf)) <> (dur: 0.02, legato: 0.1)).play;



Pdef(\x, Pbind(\note, Pbrown(0, 6, 0.1, inf)));
Pdef(\x).quant = 0; // no waiting.
Pbindf(Pdef(\x), \dur, 0.03).play;
Pbindf(Pdef(\x), \dur, 0.1, \ctranspose, 15).play;
Pbindf(Pdef(\x), \dur, 0.3, \ctranspose, 2).play;
// now change the definition
Pdef(\x, Pbind(\note, Pseq([0, 3, 5, 7, 9, 11], inf)));
Pdef(\x, Pbind(\freq, Pseq([1000, 1923, 245.2, 1718] / 1.2 + 0.1, inf)));s.boot;
