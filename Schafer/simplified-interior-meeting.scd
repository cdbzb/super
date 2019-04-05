~speakers=Array.series(8,2);
(
//IRs///////////////////////
	~projectPath="/Users/michael/tank/SchaferHouse/";
	~washRoom=Library.at(\functions,\prep).("/Users/michael/tank/IR/Saane/Domestic/Bathroom.wav");
	~doorOp=Library.at(\functions,\prep).(~projectPath ++ "/Next-Door/01-open-door.wav"); //change these!
	~doorCl=Library.at(\functions,\prep).(~projectPath ++ "/Next-Door/02-closed-door.wav");
	~kitch=Library.at(\functions,\prep).("/Users/michael/tank/IR/Saane/Domestic/Amsterdam_living_room_1.wav");
//samples///////////////////////
	~edm=Buffer.read(s,"/Users/michael/tank/SchaferHouse/SOUND/AI SOUNDS/[TOP 25] EDM Tracks Of 2012.wav")
	~marketPhrases=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/MARKET PHRASES RECORDINGS/*");
	~helicopter=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/JET HELICOPTER /*");
	~doors=SoundFile.collectIntoBuffers(~projectPath ++ "/SOUND/DOORS OPENING AND CLOSING/*");
	~footsteps=SoundFile.collectIntoBuffers(~projectPath ++ "/SOUND/FOOTSTEPS/*");
	~toilet= Buffer.read(s,~projectPath ++ "/SOUND/APPLIANCES/Toilet Flush 2.aiff");
	~water= Buffer.read(s,~projectPath ++ "/SOUND/APPLIANCES/water running into sink.wav");
	~carpetsteps=Buffer.read(s,~projectPath ++ "/Freesound/footsteps-on-a-carpet.wav");
	~keys=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/KEYS/*");
	~keyDrop=~keys[1];
	~alvarado=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/ALVARADO/*");
	~names.(~alvarado);
	~bagDrop=Buffer.read(s,"/Users/michael/tank/SchaferHouse/SOUND/ALVARADO/ybagdrom.wav");
	~chair=Buffer.read(s,numFrames: 100000, path: "/Users/michael/tank/SchaferHouse/SOUND/FURNITURE/CHAIR,LEATHER.wav");
	~aiSounds=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/AI SOUNDS/*");
	~phone=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/PHONE/*");
	~washer=Buffer.read(s,'/Users/michael/tank/SchaferHouse/SOUND/washer-dryer2.wav');
	~hallway=Buffer.read(s,'/Users/michael/tank/SchaferHouse/Freesound/quietnycpapartmenthallway.wav');
	~bots=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/edited-Clevebot/*");
	~prepAlexa.();
	~marketPhraseEdited=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/MARKET PHRASES RECORDINGS/18-edited/*");
	~vestfrost=Buffer.read(s,'/Users/michael/tank/SchaferHouse/SOUND/REFRIGERATOR/Vestfrost-trimmed.wav');
	~traffic=Buffer.read(s,'/Users/michael/tank/SchaferHouse/SOUND/OUTDOORS/Construction Site,Saw,Drill,Wood and Metal Hits - good depth and reverb.wav');
	~holdMusic=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/HOME RECORDINGS/*")
	~stool=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/STOOL/*");
	~texts=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/TEXT-NOTIFICATIONS/*");
	~sendText=Buffer.read(s,'/Users/michael/tank/SchaferHouse/SOUND/TEXT-NOTIFICATIONS/SEND.wav');
	~dialing=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/PRANK-CALL/*")
	~buzzer=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/BUZZERS TONES ALARMS/*")
)
Buffer.freeAll;
(
	~makeSpace= { |channels=2|
		var space=();
		space.add(\bus->Bus.audio(s,channels));
		space.add(\node->NodeProxy.audio(s,2));
		space.node.source={In.ar(space.bus)};
		space;
	};
	~setBusIR={|dict ir  slot=3|
		dict.node[slot]= \filter->{ |in| PartConv.ar(in,4096,ir)};
	};
	~walkFromTo={|stepNumber=0 from=2 to=7 time=15 fadeIn=0.5 fadeOut=0.2|
		var vol=[2.5,0.2].at(stepNumber);
		var steps= [~carpetsteps,~footsteps[2]].at(stepNumber);
		{
		var line=Line.kr(0,1,dur:time);
		var env=EnvGen.kr(Env.linen(fadeIn,time-(fadeIn+fadeOut),fadeOut));
		//var steps=[~carpetsteps,~footsteps[2]].at(i_stepNumber);
		steps=PlayBuf.ar(1,steps,loop:1)*env*vol;
		Out.ar(from,steps*(1-line));
		Out.ar(to,steps*line);
	}.play};
)

(

~heliPlay={
	~helicopterThroughWall=NodeProxy.audio(s,2);
	~helicopterThroughWall[0]={Pan2.ar(PlayBuf.ar(1,~helicopter[3]),Line.kr(-1,1,40),EnvGen.kr(Env.linen(8,10,15))*0.3)};//alsotry 3 and 4
	~helicopterThroughWall[1]=\filter->{|in|PartConv.ar(in,4096,~doorCl)};
	~helicopterThroughWall.reshaping=\elastic;
	~helicopterThroughWall.playN([~speakers[3],~speakers[5]]);
	~heliRumble=NodeProxy.audio(s,1).play(~speakers[7]);
	~heliRumble.source={Mix.new(~helicopterThroughWall)};
};
)
~walkFromTo.(from:~speakers[6], to:~speakers[5],time:20,fadeOut:0.5);
~walkFromTo.(1,from:~speakers[2], to:~speakers[5],time:20,fadeOut:0.5);

~heliPlay.play;
SynthDef
s.freeAll;
Function

(
	~sources=Group.new(s);
	~spaces=Group.tail(s);
	~bathroom=~makeSpace.(1);
	~kitchen= ~makeSpace.();
	~bathroom.node.playN([~speakers[6],~speakers[6]],group:~spaces);
	~bathroom.node.source={Pan2.ar(~bathroom.bus.ar,0.55)};
	//~bathroom.node.play(~speakers[6],group:~spaces);
	~kitchen.node.play(~speakers[0],group:~spaces);
	~setBusIR.(~kitchen,~kitch);
	~steps=NodeProxy.audio(s,1);
	~startWalking={~steps.source={ PlayBuf.ar(2,~carpetsteps, loop:1)*2.5}};
)
s.freeAll;
( a=Routine.new({
//s.prepareForRecord("/Users/michael/tank/SchaferHouse/toiletJoy.wav",8);
//s.sync;
//s.record(bus: 10,numChannels:8);
	~steps.fadeTime=0.1;
  	~steps[1]=\filter->{|in| DelayN(in,0.1,0.009)}; //delay compensation
	//~steps[2]=\filter->{|in| Pan2.ar(in,-0.9)};
	~startWalking.();
	~steps.play(~speakers[4],1,group: ~sources,fadeTime:0.5);
	0.5.wait;
	~steps.play(~speakers[5],1,group: ~sources, fadeTime: 7);
	6.wait;
		~steps.stop(1.0);
	0.5.wait;
		{Out.ar(~speakers[5],PlayBuf.ar(2,~keyDrop)*0.8)}.play;
	0.5.wait;
		{Out.ar(~speakers[5],PlayBuf.ar(2,~bagDrop)*1.2)}.play; //chair??
	1.0.wait;
		~setBusIR.(~bathroom,~doorOp);
		~steps.play(~speakers[5],fadeTime:0.8,group:~sources);
	0.5.wait;
		~steps.play(~bathroom.bus,fadeTime:7,group:~sources,vol:0.2);
		~steps.fadeTime=7;~steps[1]=nil;
	5.5.wait;
		~steps.stop(1.5);
/////IN BATHROOM
		~bathroom.node[1]={Pan2.ar(BrownNoise.ar(0.004),0.6)};
		//~bathroom.node[1]={Pan2.ar(PlayBuf.ar(1,~water)*0.2,0.6)};
	3.wait;
		{Out.ar(~speakers[6],PlayBuf.ar(1,~doors[3]))}.play; ~bathroom.node.fadeTime=0.5; ~setBusIR.(~bathroom,~doorCl,);
	11.wait;
		~bathroom.node[2]={Pan2.ar(PlayBuf.ar(1,~toilet)*0.5,0.5)};
	5.wait;
		~bathroom.node[1]={Pan2.ar(PlayBuf.ar(1,~water)*0.2,0.6)};
	13.wait;
		{Out.ar(16,PlayBuf.ar(1,~doors[2])*0.4)}.play;
		~setBusIR.(~bathroom,~doorOp);
	0.5.wait;
		~startWalking.(); ~steps.play(~bathroom.bus,group:~sources,fadeTime:0.1);
	0.1.wait;
		~steps.play(~kitchen.bus,group:~sources,fadeTime: 8,vol:0.4);
	5.0.wait; 
		~steps.stop(1);
	1.5.wait;
////fill carafe - put on stove open fridge - take out - microwave
		~kitchen.node[1]={PlayBuf.ar(2,~alvarado[2])*0.15};//fill carafe
	7.wait;
		~startWalking.();~steps.play(~kitchen.bus,group:~sources,fadeTime:0.1);
	       	0.6.wait; ~steps.stop(1);
	1.5.wait;
		~kitchen.node[1]={PlayBuf.ar(2,~alvarado[1])};//put on stove
		~startWalking.();~steps.play(~kitchen.bus,group:~sources);
	       	1.2.wait; ~steps.stop(1);
	4.5.wait;
		~kitchen.node[0]={PlayBuf.ar(2,~alvarado[3])};//grt from fridge -4 is alt- 
	5.wait;
		~kitchen.node[1]={PlayBuf.ar(2,~alvarado[0])*0.4};//microwave
	3.wait;
////start walking and walk to center
		~startWalking.(); ~steps.play(~kitchen.bus,group:~sources,vol:0.8);
	2.wait;
		~steps[1]=\filter->{|in| DelayN(in,0.1,0.009)}; //delay compensation
		~steps.play(~speakers[1],fadeTime:5,vol:1);
	2.wait;
		~steps.play(~speakers[2],fadeTime:6);
	2.wait;
		~steps.play(~speakers[4],fadeTime:7);
	6.wait;
		~steps.stop(0.5);
		{ Out.ar(~speakers[3],PlayBuf.ar(2,~alvarado[6])) }.play; //open patio doo
	25.wait;

s.stopRecording;
}).play
)


(
	~headToWasher={ |walkTime=8| Routine.new({
		~walkFromTo.(0,~speakers[1],~speakers[6],11,fadeIn:0.3);
		walkTime.wait;
		w={|vol=1| PlayBuf.ar(~washer.numChannels,~washer,startPos: (23*44000))*0.6*vol}.play(s,~speakers[6]);
	}).play};

	~editedChatBots={	
		var he = PlayBuf.ar(1,~bots[0],doneAction:2)*0.5;
		var she= PlayBuf.ar(1,~bots[1])*0.5;
		var pos = 0.38;
		var chans=PanAz.ar(7,he,pos+0.2) +
			  PanAz.ar(7,she,pos);
		Out.ar(~speakers[0],chans*0.6) 
	};
)


Server
s.recSampleFormat;
(
	~scene2={
	s.recSampleFormat="int24";
	s.recHeaderFormat="wav";
	s.prepareForRecord("/Users/michael/tank/SchaferHouse/Scene2.wav",8);
	s.sync;
	s.record(bus: 2,numChannels:8);
	//knock
		
		~knock = NodeProxy.audio(s,1).play(~speakers[4]);
		{
			4.wait;
			~fridge=NodeProxy.audio(s,2).play(~speakers[0]);
			~fridge[0]={PlayBuf.ar(~vestfrost.numChannels,~vestfrost)*0.4};
			~fridge[1]=\filter->{|in|PartConv.ar(in,4096,~doorOp)};
		}.fork;
		
		~knock[1]=\filter->{ |in| PartConv.ar(in,4096,~doorCl)};
		~knock[0]={ PlayBuf.ar(1,~doors[4])};
		3.3.wait;
		~knock[0]={ PlayBuf.ar(1,~doors[4],startPos:18000)};
	//walk
		1.wait;
		{PlayBuf.ar(~chair.numChannels,~chair)*0.1}.play(s,~speakers[5]); 
		0.5.wait;
		~startWalking.();~steps.play(~speakers[5],fadeTime:0.2);
		0.5.wait;
		~steps.play(~speakers[4],fadeTime:4);
		6.wait;
	//open
		{PlayBuf.ar(1,~doors[2])*0.7}.play(s,~speakers[4]);
		~hallThroughDoor=NodeProxy.audio(s,1).play(~speakers[4]);
		~hallThroughDoor.source= {PlayBuf.ar(~hallway.numChannels,~hallway,startPos:54*48000)*1.5};
		0.5.wait;
		~startWalking.();~steps.play(~speakers[4],fadeTime: 0.5);
		{~walkerTwo=NodeProxy.audio(s,1).play(~speakers[4],fadeTime:1);
			~walkerTwo.source={PlayBuf.ar(~footsteps[2].numChannels,~footsteps[2],loop:1)*0.1};
			2.wait; ~walkerTwo.stop;}.fork;
		0.51.wait;
		~steps.stop(0.6);
		3.wait;
		{PlayBuf.ar(1,~doors[3])*0.7}.play(s,~speakers[4]);
		0.1.wait;
		~hallThroughDoor[1]= \filter -> { |in| PartConv.ar(in,4096,~doorCl)};
		~hallThroughDoor.stop(30);
		2.5.wait;
	//phone rings
		r={PlayBuf.ar(~phone[4].bufnum.numChannels,~phone[4].bufnum)*0.7}.play(s,~speakers[1]);
		4.wait;
		~startWalking.();~steps.play(~speakers[4],fadeTime:0.5);
		1.1.wait;
		~steps.play(~speakers[0],fadeTime:7);
		9.2.wait;
		~steps.stop(0.5);
		2.wait;
		r.release(0.05);
		{PlayBuf.ar(1,~phone[1].bufnum)}.play(s,~speakers[0]); //BEEP
		0.5.wait;
	//SpamCall
		~spam={PlayBuf.ar(~aiSounds[8].numChannels,~aiSounds[7])*0.21!7}.play(s,~speakers);
		10.wait;
	//ringer2

		~ring2=NodeProxy.audio(s,1).play(~speakers[4]);
		{~ring2.source={|trig=(-1)| PlayBuf.ar(~phone[2].numChannels,~phone[2],trigger:trig,startPos:20000)}; 8.wait;~ring2.set(\trig,1)}.fork;
		1.5.wait;
		~walkFromTo.(1,~speakers[4],~speakers[2],6);
		~ring2.play(~speakers[2],fadeTime:6);
		1.wait;
		~spam.release(0.2);
		5.wait; ~walkerTwo.stop(1);
		1.wait;
		{PlayBuf.ar(1,~phone[1].bufnum,rate:0.95)}.play(s,~speakers[2]);// BEEP
		~ring2.release;
		1.5.wait;
		~editedChatBots.play;
		24.wait;
		{PlayBuf.ar(~alexa.numChannels,~alexa,rate:0.45)*0.25}.play(s,~speakers[5]);
		13.wait;
		~headToWasher.(8); ///// washer is in 'w' variable

		18.wait;
	//doorbell
		{ PlayBuf.ar(1,~doors[6] ,startPos:40000)}.play(s,~speakers[4]);
		4.0.wait;
		~walkFromTo.(1,~speakers[2],~speakers[4],time: 6);
		6.wait;
		{PlayBuf.ar(1,~doors[2])*0.7}.play(s,~speakers[4]); //open
		~hallThroughDoor=NodeProxy.audio(s,1).play(~speakers[4]);
		~hallThroughDoor.source= {PlayBuf.ar(~hallway.numChannels,~hallway,startPos:54*48000)*1.5};
		7.wait;
		{a={Out.ar(~speakers,Impulse.ar(1,mul:0.7))}.play;0.1.wait;a.free}.fork; //TICK
		~hallThroughDoor.stop;
		w.set(\vol,0);
		~fridge.stop;
//~helicopterThroughWall.stop;
//~heliRumble.stop;
		4.5.wait;
		~playNumbers.();
		11.wait;
		{a={Out.ar(~speakers,Impulse.ar(1),mul:0.7)}.play;0.1.wait;a.free}.fork;
		{PlayBuf.ar(~washer.numChannels,~washer,startPos:5000000)}.play(s,~speakers[6],fadeTime:10);
		~fridge.play;
			~fridge[0]={PlayBuf.ar(~vestfrost.numChannels,~vestfrost)*0.4};
			~fridge[1]=\filter->{|in|PartConv.ar(in,4096,~doorOp)};
		~hallThroughDoor.play;~hallThroughDoor.stop(120);
		~hallThroughDoor.source= {PlayBuf.ar(~hallway.numChannels,~hallway,startPos:54*48000)*1.5};
//~helicopterThroughWall.play;
//~heliRumble.play;
		w.set(\vol,1);
		5.wait;
		m={PlayBuf.ar(1,~marketPhrases[0],startPos:480000)*0.9 }.play(s,~speakers[4]);
		10.wait;
{3.do({~heliPlay.play; 27.wait })}.fork;
		115.wait;
		m.release(0.2);
		{PartConv.ar(PlayBuf.ar(~doors[5].numChannels,~doors[1]),4096,~doorOp)}.play(s,5);
		
}.fork;
)


(
	~walkToPatio={
	~walkFromTo.(0,~speakers[6],~speakers[4],10);
	~trafficThroughDoor=NodeProxy.audio(s,2).play(~speakers[3],fadeTime:10);

	~trafficThroughDoor.source={PlayBuf.ar(2,~traffic)*1.5};
	trafficThroughDoor[1]=\filter->{|in|PartConv.ar(in,4096,~doorCl,mul:0.4)};
	~trafficThroughDoor.fadeTime=3;
	10.wait;
	w={PlayBuf.ar(~washer.numChannels,~washer,startPos:2800000)}.play(s,~speakers[6],fadeTime:30);
	{ Out.ar(~speakers[3],PlayBuf.ar(2,~alvarado[6])) }.play; //open patio door
	1.wait;
	~trafficThroughDoor[1]=\filter->{|in|PartConv.ar(in,4096,~doorOp)};

	25.wait;

	~neighbor=NodeProxy.audio(s,1).play(~speakers[3]);
	~neighbor[0]={ PlayBuf.ar(~edm.numChannels,~edm)*0.1 };
	~neighbor[1]=\filter->{|in| PartConv.ar(in,4096,~doorOp,mul:0.9)};
	~neighbor.fadeTime=2;

	4.wait;

	{PlayBuf.ar(~alvarado[6].numChannels,~alvarado[6])}.play(s,~speakers[3]);//close

	4.wait;

	~trafficThroughDoor[1]=\filter->{|in|PartConv.ar(in,4096,~doorCl,mul:0.4)};
	~neighbor[1]          =\filter->{|in|PartConv.ar(in,4096,~doorCl,mul:0.1)};
	
			~walkFromTo.(1,~speakers[4],~speakers[2],8);
			7.wait;
			{PlayBuf.ar(~stool[0].numChannels,~stool[1])}.play(s,~speakers[2]);	
			3.5.wait;
			{PlayBuf.ar(~stool[0].numChannels,~stool[2])*0.15}.play(s,~speakers[2]);	
			5.wait;
			{PlayBuf.ar(1,~sendText)*1}.play(s,~speakers[2]);
			6.wait;
			
			{10.do({
				{PlayBuf.ar(~texts.choose.numChannels,~texts.choose) *0.5}.play(s,~speakers.choose);
				rrand(0.5,2).wait;
			})}.fork;
//~heliPlay.play;
			10.wait;
			w.release();
			{PlayBuf.ar(~buzzer[0].numChannels,~buzzer[1])*0.4 }.play(s,~speakers[6]);

			5.wait;
			~walkFromTo.(0,~speakers[3],~speakers[5],8);
			9.wait;
			{PlayBuf.ar(~dialing[0].numChannels,~dialing[0]) }.play(s,~speakers[5]);
			6.wait;
			{PlayBuf.ar(~dialing[0].numChannels,~dialing[2]) }.play(s,~speakers[5]);
			7.wait;
			{PlayBuf.ar(~holdMusic[2].numChannels,~holdMusic[2])*0.3 }.play(s,~speakers[5]);

			s.stopRecording;
		}.fork;
)




	



~walkFromTo.(from:~speakers[2], to:~speakers[5],time:20,fadeOut:0.5);
