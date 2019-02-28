(
"/Users/michael/tank/super/Schafer/FUNCTIONS.scd".load;
~rooms=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/ROOM TONES/*");
~beeps=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/BUZZERS TONES ALARMS/*");
)
( 
SynthDef(\bap,{ |gate=1 bus=0 amp=0.065| //freq frqLag amp
		var vib = Vibrato.ar(\freq.kr(200,\freqLag.kr(1)),rate:5,depth:0.01); 
		var env = EnvGen.kr(Env.linen(0.1,0.8,0.1,amp,0.1),doneAction:2);
		var sig=Formants.ar(vib, Vowel(\i,\tenor).blend(Vowel(\o),Rand(0,1)));
		Out.ar(bus,sig*env*amp);
	}).add;

~beepme={ |beepnumber=1 bus=3| 
	var env = EnvGen.kr(Env.linen(0.05,3,0.05),doneAction: 2);
	var sig = PlayBuf.ar(1,~beeps[rand(4)],startPos: rrand(0,99999))*0.05;
	Out.ar(~speakers[rand(8)],sig);
};
)
( //beeper !!
	Routine({
		rrand(5,10).wait;
		10.do({
			~beepme.play;
			rrand(1,5).wait;
			});
	}).play
)

s.freeAll;

~order=Array.series(10,17); // make delay for arbitrary order
( //Circular echo = round the circle - order must be backwrds
	e=Group.new(addAction:\addToTail);
	~echo=Routine({
		'e.free; to stop echo'.postln;
	{Out.ar(17,DelayN.ar(In.ar(16)*0.6),3,2.6)}.play(e);
	{Out.ar(16,DelayN.ar(In.ar(15)*0.6),3,2.6)}.play(e);
	{Out.ar(15,DelayN.ar(In.ar(14)*0.6),3,2.6)}.play(e);
	{Out.ar(14,DelayN.ar(In.ar(13)*0.6),3,2.6)}.play(e);
	{Out.ar(13,DelayN.ar(In.ar(12)*0.6),3,2.6)}.play(e);
	{Out.ar(12,DelayN.ar(In.ar(11)*0.6),3,2.6)}.play(e);
	{Out.ar(11,DelayN.ar(In.ar(10)*0.6),3,2.6)}.play(e);
	{Out.ar(10,DelayN.ar(InFeedback.ar(17)*0.5),1,0.5)}.play(e);
	}).play;
)

s.freeAll;
e.free;
~echo.play;


(//TODO set range with a bus
	{ 300.do({
		Synth(\bap,[\bus,10+rand(8),\freq,rrand(20,300)]);
		rrand(0.3,2.5).wait})
	}.fork
)
t=TempoClock.default;
t.tempo=1;
( // chord: each tone pans between random pair !!factor!!
Routine.new ({
	var channels=Array.newClear(8);
	2.do({ |outerloop|
		8.do({|i|
			channels[i]={ |gate=1| 
				~outM.(~randomPair.(),
					Pan2.ar(
						Saw.ar(
							Vibrato.ar(rrand(200,400), depth: 0.01),
							0.01* EnvGen.ar( Env.asr(4,1,28),
									gate: gate, 
									doneAction: 2 )),
						LFTri.ar(rrand(0.18,0.22))
					))}.play
		});
		16.wait;
		{channels.do({|i| i.release})}.fork;
		s.sync;//allow release before reassigning (or rename?)
		4.do({ |x|
			channels[x]={|gate=1|
				Out.ar(~speakers[x*2], 
					PlayBuf.ar(2,~rooms[x+3-outerloop].bufnum)*EnvGen.ar(Env.asr(38,0.1,28),
					gate: gate ,doneAction: 2)
				)}.play;
		});
		10.wait;
		{channels.do({|item| item.release})}.fork;
		s.sync;
	});
}).play
)

{Out.ar(11,PlayBuf.ar(~rooms[2]))}.play;

//// echo patterns
// start with little bursts
s.meter;
~echobus;
s=Server.default=Server.local
s=Server.local;
Server.default=s;
s.plotTree;
s.freeAll;
o=s.options;
o.numOutputBusChannels=18;
s.reboot;
s.meter;



(
		~delay=Bus.audio(s,8);
	{
		var bus=~delay.index;
		var in=InFeedback.ar(bus,8);
		8.do({ |x|
			var in=InFeedback.ar(bus+x);
			Out.ar((bus+x+1)%8,DelayN.ar(in,0.5,0.5));
		});
		Out.ar(10,~delay);
	}.play
)
~


