(
s = Server.local;
s.waitForBoot({

SynthDef("shep",{
	arg amp=0.08, freq=440, pan=0;
	var sig;
	sig = SinOsc.ar(freq);
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(0, sig);
}).add;


~playShep = {

	arg	speed=0.015,
		volume=0.5,
		direction=0,
		centerFreqShift=0,
		pan=0;

	var	pat0,pat1,pat2,pat3,pat4,pat5,pat6,pat7,pat8,
			midiArray,ampArray;

	midiArray=(6,6.01..113.99);

	ampArray = Array.newClear(10800);
	(-5400..5399).do{
		arg val, index;
		ampArray[index]=1.000001.pow((val.pow(2).neg));
	};

	if(
		direction > 0,
		{midiArray},
		{midiArray = midiArray.reverse});

	midiArray = midiArray+centerFreqShift;

	pat0 = Pmono(*[\shep,
		dur:speed,
		amp:
			Pseq(ampArray,inf) *
			Pseq([
				Pseg(Pseq([0,1],1),Pseq([1,0],1),\sine),
				Pseq([1],inf)
				],1) *
			volume,
		pan:pan,
		midinote:Pseq(midiArray,inf),]);

	pat1 = Pmono(*[\shep,
		dur:speed,
		amp:
			Pseq(ampArray.rotate(-1200),inf) *
			Pseq([
				Pseg(Pseq([0,1],1),Pseq([1,0],1),\sine),
				Pseq([1],inf)
			],1) *
			volume,
		pan:pan,
		midinote:Pseq(midiArray.rotate(-1200),inf),]);

	pat2 = Pmono(*[\shep,
		dur:speed,
		amp:
			Pseq(ampArray.rotate(-2400),inf) *
			Pseq([
				Pseg(Pseq([0,1],1),Pseq([1,0],1),\sine),
				Pseq([1],inf)
			],1) *
			volume,
		pan:pan,
		midinote:Pseq(midiArray.rotate(-2400),inf),]);

	pat3 = Pmono(*[\shep,
		dur:speed,
		amp:
			Pseq(ampArray.rotate(-3600),inf) *
			Pseq([
				Pseg(Pseq([0,1],1),Pseq([1,0],1),\sine),
				Pseq([1],inf)
				],1) *
			volume,
		pan:pan,
		midinote:Pseq(midiArray.rotate(-3600),inf),]);

	pat4 = Pmono(*[\shep,
		dur:speed,
		amp:
			Pseq(ampArray.rotate(-4800),inf) *
			Pseq([
				Pseg(Pseq([0,1],1),Pseq([1,0],1),\sine),
				Pseq([1],inf)
				],1) *
			volume,
		pan:pan,
		midinote:Pseq(midiArray.rotate(-4800),inf),]);

	pat5 = Pmono(*[\shep,
		dur:speed,
		amp:
			Pseq(ampArray.rotate(-6000),inf) *
			Pseq([
				Pseg(Pseq([0,1],1),Pseq([1,0],1),\sine),
				Pseq([1],inf)
				],1) *
			volume,
		pan:pan,
		midinote:Pseq(midiArray.rotate(-6000),inf),]);

	pat6 = Pmono(*[\shep,
		dur:speed,
		amp:
			Pseq(ampArray.rotate(-7200),inf) *
			Pseq([
				Pseg(Pseq([0,1],1),Pseq([1,0],1),\sine),
				Pseq([1],inf)
				],1) *
			volume,
		pan:pan,
		midinote:Pseq(midiArray.rotate(-7200),inf),]);

	pat7 = Pmono(*[\shep,
		dur:speed,
		amp:
			Pseq(ampArray.rotate(-8400),inf) *
			Pseq([
				Pseg(Pseq([0,1],1),Pseq([1,0],1),\sine),
				Pseq([1],inf)
				],1) *
			volume,
		pan:pan,
		midinote:Pseq(midiArray.rotate(-8400),inf),]);

	pat8 = Pmono(*[\shep,
		dur:speed,
		amp:
			Pseq(ampArray.rotate(-9600),inf) *
			Pseq([
				Pseg(Pseq([0,1],1),Pseq([1,0],1),\sine),
				Pseq([1],inf)
				],1) *
			volume,
		pan:pan,
		midinote:Pseq(midiArray.rotate(-9600),inf),]);

	Pspawner({
		arg sp;
		sp.par(pat0);
		sp.par(pat1);
		sp.par(pat2);
		sp.par(pat3);
		sp.par(pat4);
		sp.par(pat5);
		sp.par(pat6);
		sp.par(pat7);
		sp.par(pat8);
	}).play;
};
})
)

o=Server.local.options
o.numOutputBusChannels.postln
o.numOutputBusChannels=6
s.quit
s.boot
s.meter



(
	SynthDef.new("mySine",{
		arg amp=0.1, freq=440, pan=0, amFreq=100, amAmp=0, fmFreq=100, fmAmp=0, busOut=0;
		var sig, aMod, fMod;
		aMod= SinOsc.ar(amFreq, 0, amAmp);
		fMod= SinOsc.ar(fmFreq, 0, fmAmp);
		//sig = SinOsc.ar(freq+(fMod*1000),0,amp+aMod);
		//sig = SinOsc.ar(freq,0,amp+aMod);
		sig = SinOsc.ar(freq+(fMod*1000) , 0, amp+aMod);
		Out.ar(busOut, sig);
	}).send;
)

s.boot
a=Synth(\mySine,[\fmFreq, 2000, \fmAmp, 0.1, \amAmp, 0.00, \amFreq, 1100]);

~playShep.(0.036, 0.24,  0,  0, -1);
~playShep.(0.034, 0.24,  1,  0, 1);
a-SinOsc.ar(440,0,0.1)
{Out.ar(4,SinOsc.ar(440,0,0.1))}.play;
{Out.ar(5,SinOsc.ar(440,0,0.1))}.play;
{Out.ar(2,( PinkNoise.ar(0.27,0))) }.play
//Synth("x-axis")
//Synth("y-axis")
)
