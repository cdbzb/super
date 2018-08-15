(
// define the Instr
Instr([\analog, \voxlet], { | freq, gate, exciterFunc, detune, formfreq, ffreq, env, formfreqenv, attacktime,
decaytime, vsens, fenvsens, formHarmRatios, formHarmAmps|
var amp, sig;
formfreq = formfreq * ((EnvGen.kr(formfreqenv, gate) * fenvsens) + 1);
Where: Help→Control→ObjectSpec
210
amp = (Latch.kr(gate, gate)-1) * vsens + 1;
sig = exciterFunc.value(freq, detune); // this func is user supplied
sig = Formlet.ar(sig,
formHarmRatios.notNil.if({ formfreq * formHarmRatios }, { formfreq }),
attacktime, decaytime, mul: formHarmAmps ?? { 1 });
// formlet is a bit volatile, so limit its amplitude
(Limiter.ar(LPF.ar(Mix.ar(sig), ffreq), 0.9, 0.06)
* EnvGen.kr(env, gate, doneAction:2)) ! 2
}, [
\freq,
\amp,
// default func is an audio-rate impulse to provide the base frequency
// override this with a func for a different exciter
// your func may have a frequency and detune argument
// it should output 1 channel only
ObjectSpec({ | fr| Impulse.ar(fr) }),
\mydetune,
\freq,
#[20, 20000, \exp, 0, 1200],
EnvSpec(Env.adsr(0.07, 0.2, 0.8, 0.11)),
EnvSpec(Env(#[0, 0], [1])),
#[0.0001, 1, \exp, 0, 0.01],
#[0.0001, 1, \exp, 0, 0.1],
\amp,
\amp,
ObjectSpec(nil), // arrays by default are nil -- ugenfunc fills in the true default here
ObjectSpec(nil)
]);
)
// use the default exciter
p = Patch([\analog, \voxlet], [Patch({ MouseX.kr(20, 20000, 1, 0.1) }), 0.5, nil, nil, Patch({ MouseY.kr(20,
20000, 1, 0.1) }), nil, nil, nil, nil, nil, 1, 0]);
p.play;
// move the mouse to control base freq and formant freq
// watch the volume--amplitude can spike at times in this patch
// when done:
p.free;
