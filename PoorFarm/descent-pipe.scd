//sc3hhowto.blogspot.com
(
	SynthDef.new("rampUp", {arg out = 0, amp = 0.05, dur = 5;
		var sine, env_gen, env, pEnv;
		env_gen = LFGauss.ar(dur,0.25,loop:0);
		pEnv = XLine.ar(40,12000,dur);
		sine = SinOsc.ar(pEnv,0,amp*env_gen);
		Out.ar(out, sine);
	}).load(s);

	SynthDef.new("rampDown", {arg out = 0, amp = 0.05, dur = 5;
		var sine, env_gen, env, pEnv;
		env_gen = LFGauss.ar(dur,0.25,loop:0);
		pEnv = XLine.ar(2000,10,dur,1,0,2);
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
//Down!
(
	Task({
		var freq;
		inf.do({
			  Synth(\rampDown    , [\out, 0, \dur, 120]); //dur was 80
			(0.1 + 2.4.rand).wait; //density is here 1.4 is default
		});
	}).play;
);
{SinOsc.ar(90,0,0.2)}.play

)

//dual stereo (for recording)
( // Noise + Tone
Synth(\mySine,[\busOut, 0, \fmFreq, 2000, \fmAmp, 0.1, \amAmp, 0.00, \amFreq, 1100]);
j={ Out.ar(1,PinkNoise.ar(0.2)) }.play
);

g={Out.ar(1,Crackle.ar(1.95))}.play;

(
	s.boot;
	s.recChannels_(2);
	s.recHeaderFormat_("wav");
	s.recSampleFormat_("float");
	s.meter
)

s.stopRecording

( // Record ramps
//	(
//		s.boot;
//		s.recChannels_(2);
//		s.recHeaderFormat_("wav");
//		s.recSampleFormat_("float");
//		s.meter;
//	)
	var density=2.4, dur=60;
	Server.default=s=Server.local;
	s.prepareForRecord("/tmp/Density"++density++".wav");
	s.record("/tmp/Density"++density++"wav");
	(
		Task({
			var freq;
			dur.do({
				Synth(\rampUp    , [\out, 0, \dur, 80]);
				(0.1 + density.rand).wait;
			});
		}).play;
		//recording is stopped after second task
	);

	(
		Task({
			var freq;
			dur.do({
				Synth(\rampDown    , [\out, 1, \dur, 80]);
				(0.1 + density.rand).wait;
			});
			80.wait; //tail
			s.stopRecording;
		}).play;
	);
) 

Synth(\mySine,[\busOut, 0, \fmFreq, 2000, \fmAmp, 0.1, \amAmp, 0.00, \amFreq, 1100]);
Synth(\mySine,[\busOut, 4, \fmFreq, 2000, \fmAmp, 0.1, \amAmp, 0.00, \amFreq, 1100]);

{ Out.ar(2,PinkNoise.ar(0.2)) }.play
)
s.boot
s.meter
s.quit

