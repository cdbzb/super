(
	SynthDef(\tone, { |freq=400 amp=1  |
		var env=EnvGen.ar(Env.sine(0.10),doneAction: 2);
		var sig=SinOsc.ar(freq,0,0.15*env*amp*0.7);
		Out.ar(0,[sig,sig*0.50]);
	}).add;
	
)

(
	var quartet,set;
	~tinTone=8000;
	~tones=Array.geom(4,6000,1.8**(1/3));
	~vols=[0.3,1.5,0.7,1.0];
	~indices=Array.series(4,0);

)
s.meter;
~tones;
~tones.permute;
(
	Routine.new({
		inf.do({
			3.do({
				~indices.do({ |i| 
					i=~indices[i];
					Synth(\tone,[\freq,~tones[i],\amp,~vols[i]]);
					(1.5/4).wait;
				});
				~indices=~indices.scramble;
			});
			
			3.wait;
		});
	}).play
)
x = Synth(\tone);

s.meter;
~tones;
a={SinOsc.ar(9400,0,0.5)}.play(s,1);
Server.default=s=Server.local;
s;
.free;
s.meter;


//at 2 squares volume on the macbook


(
	SynthDef(\fourTonesBalance,{|freq,amp,chan db|
		var env=EnvGen.kr(Env.step([0,1,0,1,0,1,0,1],0.2!8),doneAction:2);
		var sig = SinOsc.ar(freq,0,amp*env);
		Out.ar(0,[sig,sig*db.ampdb]);
	}).add;
	0.ampdb;

	SynthDef(\fourTones,{|freq,amp,chan|
		var env=EnvGen.kr(Env.step([0,1,0,1,0,1,0,1],0.2!8),doneAction:2);
		var sig = SinOsc.ar(freq,0,amp*env);
		Out.ar(chan,sig);
	}).add
)

Synth(\fourTones,[\freq,6000,\amp,0.529,\chan,1]);
(
	Synth(\fourTones,[\freq,6000,\amp,0.015,\chan,0]);
	Synth(\fourTones,[\freq,6000,\amp,0.010,\chan,1]);
	(3/2).ampdb;
	Synth(\fourTones,[\freq,7000,\amp,0.050,\chan,0]);
	Synth(\fourTones,[\freq,7000,\amp,0.008,\chan,1]);
	(0.06/0.015).ampdb;
	Synth(\fourTones,[\freq,8000,\amp,0.390,\chan,0]);
	Synth(\fourTones,[\freq,8000,\amp,0.025,\chan,1]);
	(0.39/0.025).ampdb;
	Synth(\fourTones,[\freq,8500,\amp,0.100,\chan,0]);
	Synth(\fourTones,[\freq,8500,\amp,0.004,\chan,1]);
	(0.1/0.004).ampdb;
	Synth(\fourTones,[\freq,9000,\amp,0.015,\chan,0]);
	Synth(\fourTones,[\freq,9000,\amp,0.003,\chan,1]);
	(20/4).ampdb;
	Synth(\fourTones,[\freq,10000,\amp,0.035,\chan,1]);
	Synth(\fourTones,[\freq,10000,\amp,0.006,\chan,0]);
	(0.035/0.006).ampdb;


	s.meter;
)

{ SinOsc.ar(6000,0,0.1!2) }.play;

Synth(\fourTonesBalance,[\freq, 700, \amp, 0.01, \db, 0000]);

s.meter;
