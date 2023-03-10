(
	~lfo={ 
		SynthDef.wrap( {|freq=400, rate=2| SinOsc.kr(rate,mul:20,add:freq)}) 
	};
)

(
	d=SynthDef(\aaa, { 
		Out.ar(0,
		SinOsc.ar( ~lfo.value, 0, 0.1 );
	)
	}).add;
)
~lfo.(440);

~lfo2 = {|name="ff"| var freq=NamedControl(name,440,1); SinOsc.ar(freq);}

d=SynthDef(\bbb, { Out.ar(0,~lfo2.())})

d.allControlNames;
Synth(\aaa,[\freq,350,\rate,5]);
s.meter;

f=\freq;
f;
Control

(
	SynthDef(\aaa,{
		var sig = ModSin(\freq.kr(400,\freqLag.kr), rate:\rate.kr(3,0.2));
		Out.ar(0,sig);
	}).add
)
(
{
a=Synth(\aaa,[\freq,300,\freqLag,1]);
1.wait;
a.set(\freq,1000,\rate,5);
}.fork
)

(
q = ();
q.makeEnv = { |q, env, doneAction = 0| EnvGen.kr(env, NamedControl.kr(\gate, 1), doneAction: doneAction) };
q.chooseNoise = { [ {PinkNoise.ar}, {WhiteNoise.ar*0.3}, {LFNoise2.ar(Rand(100, 1000))}].choose.value};
q.filterInput = { |q, in| [
    { BPF.ar(in * 15, NamedControl.kr(\freq, 800), 0.2) },
    { RHPF.ar(in, NamedControl.kr(\freq, 800, 0.2), 0.2) }
    ].choose.value
};
)

//Dictionary
////////WAVEZ
(
a = {
    var channels = Array.fill(3, {
        q.filterInput(q.chooseNoise) * q.makeEnv(Env.asr(rrand(3,5)), 2)
    });
    Splay.ar(channels);

};
)

(
Routine({
	inf.do({
		b=a.play;
		0.05.wait;
		b.set(\freq, rrand(700,850));
		rrand(2,5).wait;
		b.set(\gate, rrand(-4,-8));
	});
}).play
)

~dict=();
~dict.dbl={|q, x| x+x};
~dict.dbl(3).value;
