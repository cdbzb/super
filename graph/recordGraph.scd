//sc3hhowto.blogspot.com

( //defs
	SynthDef.new("rampUp", {arg out = 0, amp = 0.05, dur = 5;
		var sine, env_gen, env, pEnv;
		env_gen = LFGauss.ar(dur,0.25,loop:0);
		pEnv = XLine.ar(40,12000,dur,1,0,2);
		sine = SinOsc.ar(pEnv,0,amp*env_gen);
		Out.ar(out, sine);
	}).load(s);

	SynthDef.new("rampDown", {arg out = 0, amp = 0.05, dur = 5;
		var sine, env_gen, env, pEnv;
		env_gen = LFGauss.ar(dur,0.25,loop:0);
		pEnv = XLine.ar(12000,40,dur,1,0,2);
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
	}).load(s);
)


	s.reboot; // run this first
	r.next // run this third (to record the sinewave)
( // settings - run this second
  var path="/Volumes/tank/SuperCollider/graph/";
  var density=1.8, rampDur=2000;
  var sinDur=2400;
       	(
	s.recChannels_(2);
	s.recHeaderFormat_("wav");
	s.recSampleFormat_("int16");
	);


r=Task({
( // ramps
	Server.default=s=Server.local;
	s.prepareForRecord(path++"ramps"++density++".wav");
	//`1.wait;
	//s.sync;
	s.record(path++"ramps"++density++"wav");
	(
		Task({
			rampDur.do({
				Synth(\rampUp    , [\out, 0, \dur, 80]);
				(0.1 + density.rand).wait;
			});
		}).play;
		//recording is stopped after second task
	);

	(
		Task({
			rampDur.do({
				Synth(\rampDown    , [\out, 1, \dur, 80]);
				(0.1 + density.rand).wait;
			});
			80.wait; //tail
			s.stopRecording;
		}).play;
	);
).yield; 

( // noise + tone
	s.prepareForRecord(path++"sine-noise.wav");
	s.record(path++"sine-noise.wav");
	Task({
		a=Synth(\mySine,[\busOut, 0, \fmFreq, 2000, \fmAmp, 0.06, \amAmp, 0.00, \amFreq, 1100]);
		b={ Out.ar(1,PinkNoise.ar(0.2)) }.play;
		sinDur.wait;
		s.stopRecording;
		a.free;
		b.free;
	}).play;
);
}).play;
//r.play;
//r.next;
)

