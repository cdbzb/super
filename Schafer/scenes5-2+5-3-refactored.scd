ServerTree.removeAll;

( 
	{
		~speakers=Array.series(8,2);
		~remoteInit={
			s=Server.remote(\hack,NetAddr.new("192.168.1.136",57110));
			Server.default=s;
		}.value;
		Server.local.boot;
	}.fork;
)
~prepAlexa;
(	/////// variables
{
		~prepAlexa.();
		{
			~makeNumberBuffers.(); 
			4.wait; 
			~moveNumberBuffersToRemote.(); 
		}.fork;
	};

	//~speakers=1!8;
 //IRs///////////////////////
	~loadBuffers={
		~projectPath="/Users/michael/tank/SchaferHouse/";
		~sendMail=Buffer.read(s,'/Users/michael/tank/SchaferHouse/SOUND/TYPING/compose-mail.wav');
		~washRoom=Library.at(\functions,\prep).("/Users/michael/tank/IR/Saane/Domestic/Bathroom.wav");
		~speaker=Library.at(\functions,\prep).("/Users/michael/tank/IR/Saane/Speakers_&_Telephones/Very_small_speaker_mono.wav");
		~doorOp=Library.at(\functions,\prep).(~projectPath ++ "/Next-Door/01-open-door.wav"); //change these!
		~doorCl=Library.at(\functions,\prep).(~projectPath ++ "/Next-Door/02-closed-door.wav");
		~kitch=Library.at(\functions,\prep).("/Users/michael/tank/IR/Saane/Domestic/Amsterdam_living_room_1.wav");
		//samples///////////////////////
		~edm=Buffer.read(s,"/Users/michael/tank/SchaferHouse/SOUND/AI SOUNDS/[TOP 25] EDM Tracks Of 2012.wav");
		//~marketPhrases=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/MARKET PHRASES RECORDINGS/*");
		~marketPhrases=SoundFile.collectIntoBuffers("~/tank/SchaferHouse/SOUND/MARKET PHRASES RECORDINGS/3-voice-comp/*.wav");
		~helicopter=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/JET HELICOPTER /*");
		~doors=SoundFile.collectIntoBuffers(~projectPath ++ "/SOUND/DOORS OPENING AND CLOSING/*");
		~footsteps=SoundFile.collectIntoBuffers(~projectPath ++ "/SOUND/FOOTSTEPS/*");
		~toilet= Buffer.read(s,~projectPath ++ "/SOUND/APPLIANCES/Toilet Flush 2.aiff");
		~water= Buffer.read(s,~projectPath ++ "/SOUND/APPLIANCES/water running into sink.wav");
		~carpetsteps=Buffer.read(s,~projectPath ++ "/Freesound/footsteps-on-a-carpet.wav");
		~keys=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/KEYS/*");
		~keyDrop=~keys[1];
		~alvarado=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/ALVARADO/*");
		~bagDrop=Buffer.read(s,"/Users/michael/tank/SchaferHouse/SOUND/ALVARADO/ybagdrom.wav");
		~chairLong=Buffer.read(s,numFrames: 140000, path: "/Users/michael/tank/SchaferHouse/SOUND/FURNITURE/CHAIR,LEATHER.wav");
		~chair=Buffer.read(s,numFrames: 100000, path: "/Users/michael/tank/SchaferHouse/SOUND/FURNITURE/CHAIR,LEATHER.wav");
		~aiSounds=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/AI SOUNDS/*");
		~phone=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/PHONE/*");
		~washer=Buffer.read(s,'/Users/michael/tank/SchaferHouse/SOUND/washer-dryer2.wav');
		~hallway=Buffer.read(s,'/Users/michael/tank/SchaferHouse/Freesound/quietnycpapartmenthallway.wav');
		~bots=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/edited-Clevebot/*");
		~marketPhraseEdited=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/MARKET PHRASES RECORDINGS/18-edited/*");
		~vestfrost=Buffer.read(s,'/Users/michael/tank/SchaferHouse/SOUND/REFRIGERATOR/Vestfrost-trimmed.wav');
		~traffic=Buffer.read(s,'/Users/michael/tank/SchaferHouse/SOUND/OUTDOORS/Construction Site,Saw,Drill,Wood and Metal Hits - good depth and reverb.wav');
		~holdMusic=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/HOME RECORDINGS/*");
		~stool=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/STOOL/*");
		~texts=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/TEXT-NOTIFICATIONS/*");
		~sendText=Buffer.read(s,'/Users/michael/tank/SchaferHouse/SOUND/TEXT-NOTIFICATIONS/SEND.wav');
		~dialing=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/PRANK-CALL/*");
		~buzzer=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/BUZZERS TONES ALARMS/*");
		~bathroomFan=Buffer.read(s,'/Users/michael/tank/SchaferHouse/SOUND/BATHROOM-FANS/bathroom-fan1.wav');	//m-s
		~mag=Buffer.read(s,"/Users/michael/tank/SchaferHouse/SOUND/magazine.wav");	
	};

		~chairs=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/ambeo/chairs*");
		~davidSteps=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/ambeo/footsteps*");
		~ice=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/ambeo/ice*");

///// ServerTree add groups
	~makeGroups={
		~sources.free;~spaces.free;
		~sources=Group.new(s);
		~spaces=Group.tail(s);
	};
)

( ////// functions for scene 1
	{
		s.sync;
		Buffer.freeAll(s);
	~makeGroups.();
	ServerTree.add(~makeGroups);
	CmdPeriod.add({s.freeAll});
		s.sync;
		~loadBuffers.();
		s.sync;
		~bathroom=~makeSpace.(1);
		~kitchen= ~makeSpace.();
		~bathroom.node.playN([~speakers[6],~speakers[6]],group:~spaces);
		~bathroom.node.source={Pan2.ar(~bathroom.bus.ar,0.55)};
		//~bathroom.node.play(~speakers[6],group:~spaces);
		~kitchen.node.play(~speakers[0],group:~spaces);
		~setBusIR.(~kitchen,~kitch);
		~steps=NodeProxy.audio(s,1);
		~startWalking={~steps.source={ PlayBuf.ar(2,~carpetsteps, loop:1)*2.5}};
		s.sync;

 ////// functions for scene 2 
		~headToWasher={ |walkTime=8| Routine.new({
			~walkFromTo.(0,~speakers[1],~speakers[6],11,fadeIn:0.3);
			walkTime.wait;
			~washerRunning={|vol=1| PlayBuf.ar(~washer.numChannels,~washer,startPos: (23*44000))*0.6*vol}.play(s,~speakers[6]);
	}).play};

		~editedChatBots={	
			var he = PlayBuf.ar(1,~bots[0],doneAction:2)*0.5;
			var she= PlayBuf.ar(1,~bots[1])*0.5;
			var pos = 0.38;
			var chans=PanAz.ar(7,he,pos+0.2) +
				  PanAz.ar(7,she,pos);
			Out.ar(~speakers[0],chans*0.6) 
	};

		~heliPlay={
			~helicopterThroughWall=NodeProxy.audio(s,2);
			~helicopterThroughWall[0]={Pan2.ar(PlayBuf.ar(1,~helicopter[3]),Line.kr(-1,1,40),EnvGen.kr(Env.linen(8,10,15))*0.4)};//alsotry 3 and 4
			~helicopterThroughWall[1]=\filter->{|in|PartConv.ar(in,4096,~doorCl)};
			~helicopterThroughWall.reshaping=\elastic;
			~helicopterThroughWall.playN([~speakers[3],~speakers[5]]);
			~heliRumble=NodeProxy.audio(s,1).play(~speakers[7]);
			~heliRumble.source={Mix.new(~helicopterThroughWall)};
		};

	}.fork
)
	({
  //nice party
	~niceParty={|masterVol sound=0 lag=1 playing=true|
		var bots= ~aiSounds[sound];
		~jumpinessBus=NodeProxy.control;
		~jumpinessBus.source=10000009;  //clean
		~guest={ |vol jumpiness=10000009 |
			BufRd.ar(1, bots, Phasor.ar(
				0, 
				BufRateScale.kr(bots)*Rand(0.9,1.1), 
				0,
				BufFrames.kr(bots)
			)+LFBrownNoise0.kr(
				(LFBrownNoise2.kr(1,mul:0.9,add:0.5)),0.5,mul:~jumpinessBus)
			)*Rand(0.5,1)*vol };

			~crowd=Array.fill(7,{NodeProxy.audio(s,1)});
			~crowd.do({|m| m.source=~guest});
			playing.if{{(0..7).scramble.do{ |x| ~crowd[x].play(~speakers[x],vol:masterVol); lag+(x**1.5)/3.wait}; }.fork};
			~crowd.do({|m| m.fadeTime=4});
			~crowd.do({|m| m.lag(\vol,4)});
			~partyPauser=Task.new({100.do({ ~crowd.do({|m| m.set(\vol,[0,0.5,0.35].choose)});5.wait; })}).play;
			//little tingle
			~jumpinessTask=Task({ //take these to a seperate place ??
				30.wait;~jumpinessBus.source=100000009;
				30.wait;
				~jumpinessBus.source=10000009;
				//30.wait;~jumpinessBus.source=100000009;
				60.wait;~jumpinessBus.source={Line.kr(1000009,109,100)};
				60.wait;~jumpinessBus.source={Line.kr(109,10000000009,100000)};
				60.wait; ~jumpinessBus.source={Line.kr(109,10000000009,15)};
				15.wait;
				//~crowd.do({|m| m.stop(20)});
			}).play
		};
	"LOADED!".postln;
	}.fork;
)

(///spinning party behind wall
	~partyBehindWall={
		var hall=NodeProxy.audio(s,2);
		~niceParty.(playing:false);
		0.1.wait;
		~crowd.do{|m| m.stop};0.5.wait;
		hall.source={ Splay.ar(~crowd) };
		hall[1]=\filter->{|in| PartConv.ar(in,4096,~doorCl)};

		7.do{|i| hall.play(~speakers[i],fadeTime:4);5.wait};
		10.wait;
		hall.stop;4.wait;hall.end;
	}.fork;
	~partyBehindWall.();
)
	{ SinOsc.ar([400,240,288,320,360,424,480],0,0.02)*EnvGen.kr(Env.linen(10,1,5)) }.play(s,~speakers[0]);
	~singleNote={|len=10 vol=0.03| {SinOsc.ar([400,240,288,320,360,424,480].choose,0,vol) *EnvGen.kr(Env.triangle(len)) }.play(s,~speakers[7.rand])};
	~singleNote.(10+2.0.rand);
	~smallChord={|num=4| num.do({~singleNote.(10+2.0.rand)})};
	~smallChord.();

(
	{
		8.do({
			{SinOsc.ar([400,240,288,320,360,424,480].choose,0,0.03) *EnvGen.kr(Env.triangle(10)) }.play(s,~speakers[7.rand]);
			5.wait;
		})
	}.fork
)

}.fork
)

( { // scene1 toiletjoy 5-2
//s.prepareForRecord("/Users/michael/tank/SchaferHouse/toiletJoy2.wav",8);
//s.sync;
//s.record(bus:~speakers[0] , numChannels:8);

	c=thisThread.clock.beats;
	~steps.fadeTime=0.1;
  	~steps[1]=\filter->{|in| DelayN(in,0.1,0.009)}; //delay compensation
	//~steps[2]=\filter->{|in| Pan2.ar(in,-0.9)};
	~startWalking.();
	~steps.play(~speakers[4],1,group: ~sources,fadeTime:0.5);
	0.5.wait;
	~steps.play(~speakers[5],1,group: ~sources, fadeTime: 7);
	6.wait;
		~steps.stop(0.6);
	0.5.wait;
		{Out.ar(~speakers[5],PlayBuf.ar(2,~keyDrop)*0.6)}.play;
		//~steps.play(~speakers[5],fadeTime:2,group:~sources,vol:0.2);
	0.7.wait;
		{Out.ar(~speakers[5],PlayBuf.ar(1,~bagDrop)*1.2)}.play; //chair??
	1.0.wait;
		~steps.play(~speakers[5],fadeTime:0.8,group:~sources);
	0.5.wait;
		~steps.play(~bathroom.bus,fadeTime:7,group:~sources,vol:0.2);
		~steps.fadeTime=7;~steps[1]=nil;
	5.5.wait;
		~steps.stop(1.5);
///IN BATHROOM
		//~bathroom.node[1]={Pan2.ar(BrownNoise.ar(0.004),0.6)};
	~setBusIR.(~bathroom,~doorOp);
		//~bathroom.node[1]={Pan2.ar(PlayBuf.ar(1,~water)*0.2,0.6)};
		~bathroom.node[1]={PlayBuf.ar(1,~bathroomFan)*0.4};
		3.wait;
	3.wait;
		{Out.ar(~speakers[6],PlayBuf.ar(1,~doors[3]))}.play; ~bathroom.node.fadeTime=0.5; ~setBusIR.(~bathroom,~doorCl,);
		2.wait;
		~startWalking.();~steps.play(~bathroom.bus,group:~sources,fadeTime:2);
		3.wait;
		~steps.stop(0.3);
	15.wait;
		~bathroom.node[2]={Pan2.ar(PlayBuf.ar(1,~toilet)*0.5,0.5)};
	2.wait;
		~bathroom.node[1]={Pan2.ar(PlayBuf.ar(1,~water)*0.2,0.6)};
	11.wait;
		{Out.ar(~speakers[6],PlayBuf.ar(1,~doors[2])*0.4)}.play;
		~setBusIR.(~bathroom,~doorOp);
	0.5.wait;
		~startWalking.(); ~steps.play(~bathroom.bus,group:~sources,fadeTime:0.1);
	0.1.wait;
		~steps.play(~kitchen.bus,group:~sources,fadeTime: 8,vol:0.4);
	5.0.wait; 
		~steps.stop(2);
	2.5.wait;
////fill carafe - put on stove open fridge - take out - microwave
		~kitchen.node[1]={PlayBuf.ar(2,~alvarado[2])*0.15};//fill carafe
		~names.(~alvarado);
	7.wait;
		~startWalking.();~steps.play(~kitchen.bus,group:~sources,fadeTime:0.1);
	       	0.6.wait; ~steps.stop(1);
	1.5.wait;
		~kitchen.node[1]={PlayBuf.ar(2,~alvarado[1])};//put on stove
		~startWalking.();~steps.play(~kitchen.bus,group:~sources);
	       	1.2.wait; ~steps.stop(1);
	7.5.wait;
		~kitchen.node[0]={PlayBuf.ar(2,~alvarado[3])};//grt from fridge -4 is alt- 
	9.wait;
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
		~steps.play(~speakers[5],fadeTime:7);
	6.wait;
		~steps.stop(0.5);
		{PlayBuf.ar(1,~chairLong)*0.2}.play(s,~speakers[5]); 
	2.wait;
		{PlayBuf.ar(1,~mag) }.play(s,~speakers[5]);
		//{ Out.ar(~speakers[3],PlayBuf.ar(2,~alvarado[6])) }.play; //open patio doo
	25.wait;
		c=(thisThread.clock.beats-c);c.postln;

s.stopRecording;
}.fork;
)

(  ///////scenes 3-4
	{ //////   scene2

	s.recSampleFormat="int24";
	s.recHeaderFormat="wav";
	//s.prepareForRecord("/Users/michael/tank/SchaferHouse/Scene3-4.wav",8);
	s.sync;
	//s.record(bus: ~speakers,numChannels:8);

		c=thisThread.clock.beats;
	//setup
		~steps=NodeProxy.audio(s,1);
		~startWalking={~steps.source={ PlayBuf.ar(2,~carpetsteps, loop:1)*2.5}};
	// random texts
		~text={|vol| {PlayBuf.ar(~texts.choose.numChannels,~texts.choose)*vol}.play(s,~speakers[7.rand])};
		{ 5.wait; 10.do{ rrand(10,20).wait;~text.(1.0.rand)} }.fork;
	//fridge
		{
			4.wait;
			~fridge=NodeProxy.audio(s,2).play(~speakers[0]);
			~fridge[0]={PlayBuf.ar(~vestfrost.numChannels,~vestfrost)*0.4};
			~fridge[1]=\filter->{|in|PartConv.ar(in,4096,~doorOp)};
		}.fork;
	//knock	
		~knock = NodeProxy.audio(s,1).play(~speakers[4]);
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
		//~spam={PlayBuf.ar(~aiSounds[8].numChannels,~aiSounds[7])*0.21!7}.play(s,~speakers);
		~spam={PartConv.ar(PlayBuf.ar(~aiSounds[8].numChannels,~aiSounds[7])*0.021!7,4096,~speaker)}.play(s,~speakers);
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
		~washerRunning.set(\vol,0);
		~fridge.stop;
		4.5.wait;
		~playNumbers.();
		11.wait;
	//~washerRunning={|vol=1| PlayBuf.ar(~washer.numChannels,~washer,startPos: (23*2044000))*0.6*vol}.play(s,~speakers[6]); /// TODO check if washer is running !!!!!!!
		{a={Out.ar(~speakers,Impulse.ar(1)*0.7)}.play;0.1.wait;a.free}.fork;
		{PlayBuf.ar(~washer.numChannels,~washer,startPos:5000000)}.play(s,~speakers[6],fadeTime:10);
		~fridge.play;
			~fridge[0]={PlayBuf.ar(~vestfrost.numChannels,~vestfrost)*0.4};
			~fridge[1]=\filter->{|in|PartConv.ar(in,4096,~doorOp)};
		~hallThroughDoor.play;~hallThroughDoor.stop(120);
		~hallThroughDoor.source= {PlayBuf.ar(~hallway.numChannels,~hallway,startPos:54*48000,loop:1)*1.5};
		~washerRunning.set(\vol,1);
		4.wait;
		//m={PlayBuf.ar(1,~marketPhrases[3],startPos:480000)*0.9 }.play(s,~speakers[4]);//1.6s shorter
		~mk={ SplayAz.ar(  8, [ Mix.ar(PlayBuf.ar(2,~marketPhrases[1])),
					Mix.ar(PlayBuf.ar(2,~marketPhrases[2])),
					Mix.ar(PlayBuf.ar(2,~marketPhrases[0]))
				], spread:0.05,center:0.875,level:0.6) }.play(s,~speakers);
		10.wait;
		{3.do({~heliPlay.play; 27.wait })}.fork;
		103.5.wait;
		~mk.release(0.2);
	/// SLAM!!! 4 

})

(  // functions for 5-4
/// set up circular panning

	~levels=Array.series(9,0,0.285714);
	~levels.put(8,0);
	~arclengths=[0, 15, 60,100,180,250, 300,360,360]; //in degrees
	~times=~arclengths*2/360;
	~ttimes= Array.newClear(~times.size);
       	(~arclengths.size-1).do({|index| 
		~ttimes.put(index, ~times[index+1]-~times[index])});
	~ttimes.put(~ttimes.size-1,0);
	~panEnv=Env.new(~levels,~ttimes,loopNode:0 );

//circle function
	~circleMe={ |buffer vol=0.1 phase=0 orient=2 group | { 
		//do with a gate instead
		var cycleLength = 60;
		var in = PlayBuf.ar(1,buffer,loop:1)*vol;
		var gate=Impulse.kr(1/cycleLength,phase:phase);
		var env=EnvGen.kr(~panEnv, timeScale:(cycleLength/2),gate:gate);
		//pan=~panEnv.at(pan);
		(PanAz.ar(7,in,env,orientation:orient,width:2));
	}.play(group,~speakers[0]);
};

	~toness={|num=18 vol=0.015| {
		num.do({
			{SinOsc.ar([400,440,288,320,360,424,480].choose,0,0.02) *EnvGen.kr(Env.linen(4,2,4)) }.play(s,~speakers[7.rand]);
			rrand(5,8).wait;
		})
	}.fork};;

	~partyBehindWall={|vol|{
		var hall=NodeProxy.audio(s,2);
		~niceParty.(vol,playing:false);
		0.1.wait;
		~crowd.do{|m| m.stop};0.5.wait;
		hall.source={ Splay.ar(~crowd*vol) };
		hall[1]=\filter->{|in| PartConv.ar(in,4096,~doorCl)*rrand(0.4,1.05)};
		7.do{|i| hall.play(~speakers[i],fadeTime:4);5.wait};
		15.wait;
		hall.stop;4.wait;hall.end;
	}.fork; }

		var group=Group.new(s);
)

( //// 5-4
	{
		var group=Group.new(s);
		c=SystemClock.seconds;
		{PartConv.ar(PlayBuf.ar(~doors[5].numChannels,~doors[1]),4096,~kitch,mul:1)}.play(s,5);
		~walkFromTo.(0,~speakers[6],~speakers[4],10);
	
		~trafficThroughDoor=NodeProxy.audio(s,2).play(~speakers[3],fadeTime:10);
		~trafficThroughDoor.source={PlayBuf.ar(2,~traffic)*1.5};
		~trafficThroughDoor[1]=\filter->{|in|PartConv.ar(in,4096,~doorCl,mul:0.4)};
		~trafficThroughDoor.fadeTime=3;
		10.wait;
		//~washerRunning={PlayBuf.ar(~washer.numChannels,~washer,startPos:2800000)}.play(s,~speakers[6],fadeTime:30);
		{ Out.ar(~speakers[3],PlayBuf.ar(2,~alvarado[7])*EnvGen.kr(Env.linen(0,5,1))) }.play; //open patio door
		2.wait;
		~trafficThroughDoor[1]=\filter->{|in|PartConv.ar(in,4096,~doorOp)};

		25.wait;
//NEIGHBOR
		~neighbor=NodeProxy.audio(s,1).play(~speakers[3]);
		~neighbor[0]={ PlayBuf.ar(~edm.numChannels,~edm)*0.1 };
		~neighbor[1]=\filter->{|in| PartConv.ar(in,4096,~doorOp,mul:0.9)};
		~neighbor.fadeTime=2;

		6.wait;
//CLOSE PATIO DOOR
		{PlayBuf.ar(~alvarado[5].numChannels,~alvarado[5],startPos:100000)*2}.play(s,~speakers[3]);//close
		//3.wait;
		~trafficThroughDoor[1]=\filter->{|in|PartConv.ar(in,4096,~doorCl,mul:0.4)};
		~trafficThroughDoor.fadeTime=4; ~neighbor.fadeTime=4;
		~neighbor[1]          =\filter->{|in|PartConv.ar(in,4096,~doorCl,mul:0.1)};
	
		~walkFromTo.(1,~speakers[4],~speakers[2],8);
		7.wait;
		{PlayBuf.ar(~stool[0].numChannels,~stool[1])}.play(s,~speakers[2]);	
		3.5.wait;
		{PlayBuf.ar(~stool[0].numChannels,~stool[2])*0.15}.play(s,~speakers[2]);	
		5.wait;
		{PlayBuf.ar(1,~sendText)*1}.play(s,~speakers[2]);
		6.wait;
//text cloud
		~tcloud=Routine({       var line=Line.kr(3,0.2,10);
			~textgroup=Group.new(s);
			400.do({|i|
			var rate=if(i<13,{[1,1.1,2].choose},{[0.2,2,10.11,1,1.1].choose}) ;
			{PlayBuf.ar(~texts.choose.numChannels,~texts.choose,rate:rate*(rrand(0.99,1.01)) ,doneAction:2) *[0.5,0.5,0.1,0.4].choose}.play(~textgroup,~speakers.choose);
			//linrrand(0.3,3).wait; //use a line for the lower bound
			if(i<20,{linrand(450-(i*10)/200+0.9,4).wait},{linrand(0.4,3).wait});
		})}).play;
		16.wait;~walkFromTo.(1,~speakers[2],~speakers[5],7);
		24.wait;
		~tcloud.stop;
		~textgroup.release(0.1);
		~washerRunning.release();
		p={PlayBuf.ar(~buzzer[0].numChannels,~buzzer[1],startPos:20000)*0.4 }.play(s,~speakers[6]);
		5.wait;
		~walkFromTo.(0,~speakers[3],~speakers[5],8);
		5.wait;~playOneNumber.();4.wait;
		7.wait;p.free;


	}.fork)
	({ ///topp
////////////////////

		var group=Group.new(s);
		{PlayBuf.ar(1,~dialing[0],startPos:58000)*4 }.play(s,~speakers[5]);
		5.wait;
		{PlayBuf.ar(1,~dialing[2])*2.5 }.play(s,~speakers[5]);//ring
		7.wait;
		~circleMe.(~holdMusic[2], 0.32 , phase:0.11 , orient:5,group:group );
		//25.wait;
		//8.wait;
		13.wait;
		{PlayBuf.ar(1,~dialing[0],startPos:58000)*4 }.play(s,~speakers[2]);
		5.wait;	
		{PlayBuf.ar(1,~dialing[2])*2.5 }.play(s,~speakers[2]);//ring
		7.wait;
		~circleMe.(~holdMusic[4], 0.085 , phase:0.61 , orient:2, group:group );
		//20.wait;
		5.wait;
			~fridge=NodeProxy.audio(s,2).play(~speakers[0]);
			~fridge[0]={PlayBuf.ar(~vestfrost.numChannels,~vestfrost,startPos:100000)*0.4};
			~fridge[1]=\filter->{|in|PartConv.ar(in,4096,~doorOp)};
		~circleMe.(~footsteps[1],0.1, group:group);
		7.wait;
		~toness.(10,0.012); //start turning here
		15.wait;
		group.release(35);
		15.wait;
		~partyBehindWall.(0.45);
		15.wait;
		~crowd.do({|m| m.release(4)});
		10.wait;
		~partyBehindWall.(0.3);
		10.wait;
		~crowd.do({|m| m.release(4)});
		(SystemClock.seconds-c).postln;
		///////Scene 4
		{PlayBuf.ar(1,~doors[5])*0.5}.play(s,~speakers[4]);
		2.wait;
		~walkFromTo.(1,~speakers[5],~speakers[4],7,fadeIn:0.3);
		7.wait;
		{PlayBuf.ar(1,~doors[2])*0.7}.play(s,~speakers[4]);
		~hallThroughDoor=NodeProxy.audio(s,1).play(~speakers[4]);
		~hallThroughDoor.source= {PlayBuf.ar(~hallway.numChannels,~hallway,startPos:54*48000)*1.5};
		1.5.wait;
		{
			~prepPhraseToBuff.("you have arrived at your destination");
			0.4.wait;
			{var sig = PartConv.ar( PlayBuf.ar(1,~buff,rate:0.48)*0.1, 4096, ~speaker); sig=PartConv.ar(sig,4096,~washRoom)*0.04+sig; sig;}.play(s,~speakers[4]);
		}.fork;
		6.wait;

		//~fu.(~davidSteps,8,amp:0.2,rateMin:0.8, rateMax:1.1);
		//15.wait;
		~fu.(~chairs,36,rateMin:0.8,ampVar:1.3);
	}.fork;
)

		1.wait;
		//a={PlayBuf.ar(1,~edm)*0.5 }.play(s,~speakers[3]);
		//5.wait;
		//{PlayBuf.ar(1,~doors[3])*2}.play(s,~speakers[3]); 
		//0.2.wait;
		//a.free;
	};
//	9.do({ 
//			~goThere.(0,rand(7));
//			rrand(5,7).wait;
//			~goThere.(1,rand(7));
//			rrand(5,7).wait;
//		});
		
		//{
		//	~goThere.(0,3);7.wait;
		//	~where.postln;
		//	~goThere.(0,4);7.wait;
		//	~where.postln;
		//	~goThere.(0,5);7.wait;
		//	~where.postln;
		//	~goThere.(0,6);7.wait;
		//	~where.postln;
		//	~goThere.(0,0);7.wait;
		//	5.wait;
		//	~where.postln;
		//}.fork;
		//{
		//	~goThere.(1,5);6.wait;
		//	~goThere.(1,6);6.wait;
		//	~goThere.(1,0);6.wait;
		//	~goThere.(1,1);6.wait;
		//	~goThere.(1,2);6.wait;
		//}.fork;
		40.wait;
		~phoneWalker[0].stop(1);
		~phoneWalker[1].stop(1);


		h.release(0.4);
		5.wait;
		s.stopRecording;
		c=(thisThread.clock.beats-c);c.postln;
	}.fork;
)
