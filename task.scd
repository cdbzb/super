//sc3hhowto.blogspot.com

(
	SynthDef.new("rampUp", {arg out = 0, amp = 0.1, dur = 5;
		var sine, env_gen, env, pEnv;
		env_gen = LFGauss.ar(dur,0.25,loop:0);
		pEnv = XLine.ar(40,12000,dur);
		sine = SinOsc.ar(pEnv,0,amp*env_gen);
		Out.ar(out, sine);
	}).load(s);

	SynthDef.new("rampDown", {arg out = 0, amp = 0.1, dur = 5;
		var sine, env_gen, env, pEnv;
		env_gen = LFGauss.ar(dur,0.25,loop:0);
		pEnv = XLine.ar(12000,40,dur);
		sine = SinOsc.ar(pEnv,0,amp*env_gen);
		Out.ar(out, sine);
	}).load(s);

	SynthDef.new("mySine",{
		arg amp=0.1, freq=440, pan=0, amFreq=100, amAmp=0, fmFreq=100, fmAmp=0, busOut=0;
		var sig, aMod, fMod;
		aMod= SinOsc.ar(amFreq, 0, amAmp);
		fMod= SinOsc.ar(fmFreq, 0, fmAmp);
		sig = SinOsc.ar(freq+(fMod*1000) , 0, amp+aMod);
		Out.ar(busOut, sig);
	}).send;
)
//Up!
( 
(
	Task({
		var freq;
		inf.do({
			  Synth(\rampUp    , [\out, 1, \dur, 80]);
			(0.1 + 1.4.rand).wait;
		});
	}).play;
);
//Down!
(
	Task({
		var freq;
		inf.do({
			  Synth(\rampDown    , [\out, 3, \dur, 80]);
			(0.1 + 1.4.rand).wait;
		});
	}).play;
);

Synth(\mySine,[\busOut, 0, \fmFreq, 2000, \fmAmp, 0.1, \amAmp, 0.00, \amFreq, 1100]);
Synth(\mySine,[\busOut, 4, \fmFreq, 2000, \fmAmp, 0.1, \amAmp, 0.00, \amFreq, 1100]);

{ Out.ar(2,PinkNoise.ar(0.2)) }.play
)

//dual stereo (for recording)
( // Noise + Tone
Synth(\mySine,[\busOut, 0, \fmFreq, 2000, \fmAmp, 0.1, \amAmp, 0.00, \amFreq, 1100]);
{ Out.ar(1,PinkNoise.ar(0.2)) }.play
);

( // ramps
	(
		Task({
			var freq;
			inf.do({
				  Synth(\rampUp    , [\out, 0, \dur, 80]);
				(0.1 + 1.4.rand).wait;
			});
		}).play;
	);

	(
		Task({
			var freq;
			inf.do({
				  Synth(\rampDown    , [\out, 1, \dur, 80]);
				(0.1 + 1.4.rand).wait;
			});
		}).play;
	);
);

Synth(\mySine,[\busOut, 0, \fmFreq, 2000, \fmAmp, 0.1, \amAmp, 0.00, \amFreq, 1100]);
Synth(\mySine,[\busOut, 4, \fmFreq, 2000, \fmAmp, 0.1, \amAmp, 0.00, \amFreq, 1100]);

{ Out.ar(2,PinkNoise.ar(0.2)) }.play
)
s.boot
s.meter
s.quit

