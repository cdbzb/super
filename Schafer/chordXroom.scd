(
"/Users/michael/tank/super/Schafer/FUNCTIONS.scd".load;
~rooms=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/ROOM TONES/*");
)
SynthDef(\bap,{ |gate=1 bus=0 amp=0.065| //freq frqLag amp
		var vib = Vibrato.ar(\freq.kr(200,\freqLag.kr(1))); 
		var env = EnvGen.kr(Env.perc(0.9,amp,0.1));
		var sig=Formants.ar(vib, Vowel(\i,\tenor).blend(Vowel(\o),Rand(0,1)));
		Out.ar(bus,sig*env*amp);
	}).add;
)


~order=Array.series(10,17); // make delay for arbitrary order
( //Circular echo = round the circle - order must be backwrds
	{Out.ar(17,DelayN.ar(In.ar(16)*0.5),1,0.6)}.play;
	{Out.ar(16,DelayN.ar(In.ar(15)*0.5),1,0.6)}.play;
	{Out.ar(15,DelayN.ar(In.ar(14)*0.5),1,0.6)}.play;
	{Out.ar(14,DelayN.ar(In.ar(13)*0.5),1,0.6)}.play;
	{Out.ar(13,DelayN.ar(In.ar(12)*0.5),1,0.6)}.play;
	{Out.ar(12,DelayN.ar(In.ar(11)*0.5),1,0.6)}.play;
	{Out.ar(11,DelayN.ar(In.ar(10)*0.5),1,0.6)}.play;
	{Out.ar(10,DelayN.ar(InFeedback.ar(17)*0.5),1,0.5)}.play;
)

(//TODO set range with a bus
	{ 300.do({
		Synth(\bap,[\bus,10+rand(8),\freq,rrand(200,300)]);
		rrand(0.2,1.5).wait})
	}.fork
)

( // chord: each tone pans between random pair !!factor!!
Routine.new ({
	var channels=Array.newClear(8);
	2.do({
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
					PlayBuf.ar(2,~rooms[x+3].bufnum)*EnvGen.ar(Env.asr(38,0.1,28),
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


