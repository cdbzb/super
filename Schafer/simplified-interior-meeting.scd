(
//IRs///////////////////////
	~projectPath="/Users/michael/tank/SchaferHouse/";
	~washRoom=Library.at(\functions,\prep).("/Users/michael/tank/IR/Saane/Domestic/Bathroom.wav");
	~doorOp=Library.at(\functions,\prep).(~projectPath ++ "/Next-Door/01-open-door.wav"); //change these!
	~doorCl=Library.at(\functions,\prep).(~projectPath ++ "/Next-Door/02-closed-door.wav");
//samples///////////////////////

	~doors=SoundFile.collectIntoBuffers(~projectPath ++ "/SOUND/DOORS OPENING AND CLOSING/*");
	~footsteps=SoundFile.collectIntoBuffers(~projectPath ++ "/SOUND/FOOTSTEPS/*");
	~toilet= Buffer.read(s,~projectPath ++ "/SOUND/APPLIANCES/Toilet Flush 2.aiff");
	~water= Buffer.read(s,~projectPath ++ "/SOUND/APPLIANCES/water running into sink.wav");
	~carpetsteps=Buffer.read(s,~projectPath ++ "/Freesound/footsteps-on-a-carpet.wav");
	~keys=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/KEYS/*");
	~keyDrop=~keys[1];
	~alvarado=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/ALVARADO/*");
	~names.(~alvarado);
	~kitch=Library.at(\functions,\prep).("/Users/michael/tank/IR/Saane/Domestic/Amsterdam_living_room_1.wav");
	~bagDrop=Buffer.read(s,"/Users/michael/tank/SchaferHouse/SOUND/ALVARADO/ybagdrom.wav");
	~chair=Buffer.read(s,numFrames: 100000, path: "/Users/michael/tank/SchaferHouse/SOUND/FURNITURE/CHAIR,LEATHER.wav");
)

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
)
s.freeAll;
(
	(~sources==nil).if({1},{2});
	~sources=Group.new(s);
	~spaces=Group.tail(s);
	~bathroom=~makeSpace.(1);
	~kitchen= ~makeSpace.();
	~bathroom.node.playN([[~speakers[6],~speakers[6]]],group:~spaces);
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
s.freeAll;

~scene2={
//s.prepareForRecord("/Users/michael/tank/SchaferHouse/Scene2.wav",8);
//s.sync;
//s.record(bus: 10,numChannels:8);

//knock
~knock = NodeProxy.audio(s,1).play(~speakers[5]);
~knock[1]=\filter->{ |in| PartConv.ar(in,4096,~doorCl)};
~knock[0]={PlayBuf.ar(1,~doors[4])};
PlayBuf.ar(1,~doors[4])};
(
	{
	~knock[0]={ PlayBuf.ar(1,~doors[4])};
	3.3.wait;
	~knock[0]={ PlayBuf.ar(1,~doors[4],startPos:18000)};
}.fork
)

//walk

{PlayBuf.ar(~chair.numChannels,~chair)}.play(s,~speakers[4]); //sit down - should be up
0.5.wait;
~startWalking.();~steps.play(~speakers[6],fadeTime:0);
~steps.play(~speakers[4],fadeTime:4);
4.wait;
~steps.stop;

//open

//ringtone

//spamcall



//s.stopRecording;
}.fork

