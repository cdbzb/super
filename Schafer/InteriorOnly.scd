o=s.options; o.memSize=2**17; s.reboot;
o.numOutputBusChannels=18; s.reboot;
NodeProxy
Buffer.freeAll;
(//IRs///////////////////////
	var projectPath="/Users/michael/tank/SchaferHouse/";
	~forest=Library.at(\functions,\prep).("/Users/michael/tank/IR/Saane/Forest/Forest_2.wav");
	~speaker=Library.at(\functions,\prep).("/Users/michael/tank/IR/Saane/Speakers_&_Telephones/Very_small_speaker_stereo.wav");
	~washRoom=Library.at(\functions,\prep).("/Users/michael/tank/IR/Saane/Domestic/Bathroom.wav");
	~doorOp=Library.at(\functions,\prep).(projectPath ++ "/Next-Door/01-open-door.wav"); //change these!
	~doorCl=Library.at(\functions,\prep).(projectPath ++ "/Next-Door/02-closed-door.wav");
	~street=Library.at(\functions,\prep).(projectPath ++ "/Next-Door/Street-smooth-intimate.wav");
//ambisonics////////////////////
	~decoder = FoaDecoderMatrix.newPanto(8, k: 'dual');         // psycho optimised 7;;
//samples///////////////////////
	~doors=SoundFile.collectIntoBuffers(projectPath ++ "/SOUND/DOORS OPENING AND CLOSING/*");
	~footsteps=SoundFile.collectIntoBuffers(projectPath ++ "/SOUND/FOOTSTEPS/*");
	~toilet= Buffer.read(s,projectPath ++ "/SOUND/APPLIANCES/Toilet Flush 2.aiff");
	~water= Buffer.read(s,projectPath ++ "/SOUND/APPLIANCES/water running into sink.wav");
	~ambiStreet= Buffer.read(path:projectPath ++ "/Freesound/139023__lossius__agotnes-terminal-b-format.flac");
	~ambiLobby=Buffer.read(path:projectPath ++ "/Freesound/ambi-walla.wav");
	~elevators=SoundFile.collectIntoBuffers(projectPath ++ "/Freesound/Elevator/*");
	~muzak=SoundFile.new(projectPath ++ "/SOUND/Muzak.wav").cue((amp: 0.025));
	~mid=Buffer.readChannel(s,projectPath ++ "/Freesound/empty-medium-room-tone-stereo-ms.wav",channels: [0]);
	~side=Buffer.readChannel(s,projectPath ++ "/Freesound/empty-medium-room-tone-stereo-ms.wav",channels: [1]);
	~carpetsteps=Buffer.read(s,projectPath ++ "/Freesound/footsteps-on-a-carpet.wav");
	~keys=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/KEYS/*");
	~chair=Buffer.read(s,numFrames: 100000, path: "/Users/michael/tank/SchaferHouse/SOUND/FURNITURE/CHAIR,LEATHER.wav");

)
s.plotTree;
Server.default=s;
(//set up nodes 
	~sources=Group.head(s);
	~spaces=Group.after(~sources);
	~traffic=~makeNodes.(8);
	~traffic.wet.play(~speakers[0]);
	~traffic.wet.fadeTime=0.1;
	//footsteps
	~steps=~makeNodes.();
	~steps.dry.source={PlayBuf.ar(2,~footsteps[0],loop:1)*0.3};
	~setIR.(~steps,~street);
	//door
	~doorway=~makeNodes.();
	~bathroom=~makeNodes.();
	~kitchen=~makeNodes.();
	~bathroomBus=Bus.audio(s,1);
	~kitchenBus=Bus.audio(s,1);
	//~bathroom.dry.source={~bathroomBus.ar};
	~setIR.(~bathroom,~doorCl);
	~bathroom.wet.reshaping=\elastic;
	~bathroom.wet.fadeTime=0.5; //time for door open close
	//elevator
	~elevator=NodeProxy.new(s,\audio,2).play([~speakers[2],[3]]);
	~elevator.reshaping=\elastic;
	~hallway=~makeNodes.();
	~washer=~makeNodes.();
	~centerRoom=~makeNodes.();
)
~carpetsteps=~footsteps[2];
(
	~keySit={|walk| Routine.new({  
		~steps.dry.source={PlayBuf.ar(2,~carpetsteps,loop:1)*6};
		~steps.wet.play(~bathroomBus,group:~sources,vol:2);
		1.wait;
		~steps.wet.playN([~speakers[5],~speakers[2]],fadeTime:8,vol:1);
		walk.wait;
		~steps.wet.stop(2.5);
		1.wait;
		~centerRoom.dry.source={PlayBuf.ar(1,~keys[1])};
		~setIR.(~centerRoom,~washRoom); // really??????
		~centerRoom.wet.playN([~speakers[0],~speakers[4]],vol:0.1); ~centerRoom.dry.playN([~speakers[2],~speakers[6]]);
		//sit down
		0.7.wait;
		~bypass.(~centerRoom);
		~centerRoom.dry.source={PlayBuf.ar(1,~chair)*0.4};
	})};
)
~keySit.play(8);

( // prep for routines
	~sources=Group.head(s);
	~spaces=Group.after(~sources);
	~delayline=Bus.audio(s,1);
	//~compensation={DelayN.ar(In.ar(~delayline),0.1,0.045)}.play(s,12,\addToTail);
	~compensation=NodeProxy.audio(s,1);
	~compensation.play(~speakers[4],1,~spaces);
	~compensation.source={DelayN.ar(In.ar(~delayline),1.1,0.009)};
	~bathroom.wet.playN([~speakers[0],~speakers[6]],group: ~spaces, addAction: \addToTail);
	~bathroom.dry.source={Pan2.ar(In.ar(~bathroomBus),0.55)};
	~kitchen.wet.play(~speaker[0]);
	~kitchen.dry.source={Pan2.ar(In.ar(~kitchenBus),-0.5)};
	~bypass.(~steps);
)
s.freeAll;
( //toiletJoy
	Routine.new({
s.prepareForRecord("/Users/michael/tank/SchaferHouse/toiletJoy.wav",8);
s.sync;
s.record(bus: 10,numChannels:8);
/////SETUP - steps->delayline->compensated 4-5-bathroom
		~setIR.(~bathroom,~doorOp); //|
		//~bypass.(~bathroom);	    //|
		~compensation.play(~speakers[4],fadeTime:0);
			~steps.dry.source={PlayBuf.ar(1,~carpetsteps,loop:1)*6}; 
			~steps.wet.play(~delayline,fadeTime:0, group:~sources,  addAction:\addToHead);
	0.1.wait
		~compensation.play(~speakers[5],fadeTime:7);
	3.0.wait;
		~steps.wet.play(~bathroomBus,fadeTime:4, group: ~sources, addAction:\addToHead,vol:3);
	5.wait;
		~steps.wet.stop(1.5);
/////IN BATHROOM
		~bathroom.dry[1]={Pan2.ar(PlayBuf.ar(1,~water)*0.5,0.6)};
	3.wait;
			{Out.ar(~speakers[6],PlayBuf.ar(1,~doors[3])*0.4)}.play;
			~setIR.(~bathroom,~doorCl);
	2.wait;
		~bathroom.dry[2]={Pan2.ar(PlayBuf.ar(1,~toilet),0.5)};
	11.wait;
			{Out.ar(16,PlayBuf.ar(1,~doors[2])*0.4)}.play;
			~setIR.(~bathroom,~doorOp);
	0.5.wait;
		~keySit.(8).play;
	20.wait;
s.stopRecording;
	}).play;
)

( // toiletJoy longer -> add water after toilet
	Routine.new({
s.prepareForRecord("/Users/michael/tank/SchaferHouse/toiletJoy.wav",8);
s.sync;
s.record(bus: 10,numChannels:8);
/////SETUP - steps->delayline->compensated 4-5-bathroom
t=TempoClock(s);
t.tempo=3;
		~setIR.(~bathroom,~doorOp); //|
		//~bypass.(~bathroom);	    //|
		~compensation.play(~speakers[4],fadeTime:0);
			~steps.dry.source={PlayBuf.ar(1,~carpetsteps,loop:1)*6}; 
			~steps.wet.play(~delayline,fadeTime:0, group:~sources,  addAction:\addToHead);
	0.1.wait
		~compensation.play(~speakers[5],fadeTime:7);
	3.0.wait;
		~steps.wet.play(~bathroomBus,fadeTime:4, group: ~sources, addAction:\addToHead,vol:3);
	5.wait;
		~steps.wet.stop(1.5);
/////IN BATHROOM
		~bathroom.dry[1]={Pan2.ar(PlayBuf.ar(1,~water)*0.5,0.6)};
	3.wait;
			{Out.ar(~speakers[6],PlayBuf.ar(1,~doors[3])*0.4)}.play;
			~setIR.(~bathroom,~doorCl);
	2.wait;
		~bathroom.dry[2]={Pan2.ar(PlayBuf.ar(1,~toilet),0.5)};
	11.wait;
			{Out.ar(16,PlayBuf.ar(1,~doors[2])*0.4)}.play;
			~setIR.(~bathroom,~doorOp);
	0.5.wait;
		
//////TO WATER	
t.tempo=1;
		//~steps.dry.source={PlayBuf.ar(2,~carpetsteps,loop:1)*6}; // necessary?
		~steps.wet.play(~bathroomBus,group:~sources,vol:2);
	0.1.wait;
		~steps.wet.play(~kitchenBus,group:~sources,fadeTime:4);
	4.wait;
		~steps.wet.stop;
		~fillCup=Buffer.read(1,"/Users/michael/tank/SchaferHouse/SOUND/WATER/long-fill.wav");
		~klank=Buffer.read(1,"/Users/michael/tank/SchaferHouse/SOUND/WATER/glass down.wav");
		~kitchen.dry[1]={PlayBuf.ar(1,~fillCup)};
	3.wait;
		~kitchen.dry[1]={PlayBuf.ar(1,~klank)};
	1.wait;

		~keySit.(8).play; // modify start point
	20.wait;
s.stopRecording;
	}).play;
)
s.freeAll;

(
	Routine.new({
		////////////////OUTSIDE
		~traffic.wet.play;
		~bypass.(~traffic);
		~traffic.dry.source={FoaDecode.ar(PlayBuf.ar(4,~ambiStreet,loop:1)*1,~decoder)};
		8.wait; ~steps.wet.play(~speakers[5]);
		~steps.dry.source={PlayBuf.ar(2,~footsteps[0],loop:1)*0.2};
		~steps.wet.play(~speakers[4],fadeTime:8); 8.wait;
		~steps.wet.play(~speakers[0],fadeTime:8); 8.wait;
		~steps.wet.end(1);
		~doorway.wet.source=~doorway.dry;
		~doorway.wet.play(~speakers[6]); //dry for now... 
		~doorway.dry.source={PlayBuf.ar(1,[~doors[10],~doors[11]])*0.5};
		4.wait;
		~setIR.(~traffic,~doorCl,1.3);
		s.sync;
		///////////////LOBBY
//change IR when enter lobby
//~steps.wet.source={PartConv.ar(~steps.dry,4096,~forest)};
		//~lobby={FoaDecode.ar(PlayBuf.ar(4,~ambiLobby,loop:1)*1,~decoder)}.play;
		~lobby=~makeNodes.(8); 
		~lobby.wet.play(~speakers);
		~lobby.dry.source={FoaDecode.ar(PlayBuf.ar(4,~ambiLobby,loop:1)*0.1,~decoder)};
		~setIR.(~steps,~forest,0.3);
		~steps.wet.play(~speakers[6]);
	0.5.wait;
		~steps.wet.play(~speakers[3],fadeTime: 10);
	15.wait;
		//~setIR.(~doorway,~forest);//...now in interior verb
		/////////////////ELEVATOR
		~elevator.play(~speakers[2],vol:1.5);
		~elevator.source=~lobbyscene;
	2.wait; //elevator door open;
		~music=~makeNodes.(); ~setIR.(~music,~speaker); ~music.wet.play(~speakers[2],vol:0.2);
		~music.dry.source=~muzak;
		//~elevator.source=~lobbyend;
	12.wait; //door starts closing
	4.wait; //door will thump closed in 1 sec
		~lobby.wet.fadeTime=2;
		~setIR.(~lobby,~doorCl); ~setIR.(~music,~doorCl);
		~traffic.wet.end(1);
	1.wait;
		~lobby.wet.end(1); ~steps.wet.stop; 
	19.5.wait;//Elevator ride length
	~hallway.wet.playN([~speakers[2],~speakers[4]],vol:2.9);
	//~hallway.wet.play(~speakers[3],fadeTime:5);
	~msDecoder={ var mid = PlayBuf.ar(1,~mid)*0.4;
		     var side = PlayBuf.ar(1,~side)*0.4;
		     [[mid+side],[mid-side]];
	};
		~music.wet.end(1);
		~elevator.stop(2);
		~hallway.dry.source=~msDecoder;
		~hallway.dry[1]=
		{Pan2.ar(PlayBuf.ar(1,~carpetsteps,loop:1),
				Line.kr(-0.9,0.9,5))*3};
		16.wait;
		~hallway.wet.stop(0.3);
	}).play
	
)
s.freeAll;
(
	//lobbymusic plays out of 8 through spkr then to surround verb
	~verbBus=Bus.audio(s,2);
	~muzak=~makeNodes.();
	~setIR.(~muzak,~speaker);
	~muzak.wet.play(17);
	~muzak.dry.source=a;
	~muzak.dry.source=nil;
	~muzak.wet.play(~verbBus);
	~muzak.wet.stop
	~muzak.dry.source=Pbind( \degree,Pwhite(-10,10,inf),\dur,0.3);
	~muzak.dry[1].source=Pbind( \degree,Pwhite(0,15,inf),\dur,0.5);
	~muzak.dry.play;
	~muzak.dry.source=nil;
	v={Out.ar(~speakers,PartConv.ar(In.ar(~verbBus),4096,~forest));}.play(s,addAction: \addToTail);
	v.free;
	a.free;
	NodeProxy

	"/Users/michael/Music/iTunes/iTunes Media/"
)

s;
s=Server.local;
Server.default=s;
s.freeAll;
NodeProxy
Server.all;


~bathroom.dry.source={PlayBuf.ar(2,~footsteps[0])};

s.freeAll;
a=Bus.new();
~bathroom.dry[3].source={a.ar;

Server.default=s=Server.local;
	a=NodeProxy.new(s,\audio,2);
	a.bus;
	a.source={PinkNoise.ar(0.2)};
	a.play;
	b=NodeProxy.new(s,\audio);
	b.source={Saw.ar(300,0.2)};
	b.play(4);
	a.bus;
	a[1].source=b;
	a[1];

b={Out.ar(4,Saw(300,0.1))}.play;
//toggle bathroom door
~bathroom.wet.source={PartConv.ar(~dryBath,4096,~doorCl)}; //vagaries of stereo conv
~setIR.(~bathroom,~doorCl);
~setIR.(~bathroom,~doorOp);
~bypass.(~bathroom);
s.freeAll;

