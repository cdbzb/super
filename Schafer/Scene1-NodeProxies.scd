o=s.options; o.memSize=2**17; s.reboot;
o.numOutputBusChannels=18; s.reboot;
s.meter;
o.numOutputBusChannels=18;
s.reboot;

(
	~makeNodes={ |channels=2 |
		var d=();
		var dry = NodeProxy(s,\audio,channels);
		var wet = NodeProxy(s,\audio,channels);
		wet.source=dry;
		d.add(\wet->wet);
		d.add(\dry->dry);
	};
	~setIR={|dict buffer gain=1|
		dict.wet.source = {PartConv.ar(dict.dry,4096,buffer)*gain}
	};
	~bypass={|dict|
		dict.wet.source=dict.dry};
)

(//IRs///////////////////////
	~forest=Library.at(\functions,\prep).("/Users/michael/tank/IR/Saane/Forest/Forest_2.wav");
	~speaker=Library.at(\functions,\prep).("/Users/michael/tank/IR/Saane/Speakers_&_Telephones/Very_small_speaker_stereo.wav");
	~doorOp=Library.at(\functions,\prep).("/Users/michael/tank/SchaferHouse/Next-Door/01-open-door.wav"); //change these!
	~doorCl=Library.at(\functions,\prep).("/Users/michael/tank/SchaferHouse/Next-Door/02-closed-door.wav");
	~street=Library.at(\functions,\prep).("/Users/michael/tank/SchaferHouse/Next-Door/Street-smooth-intimate.wav");
//ambisonics////////////////////
	~decoder = FoaDecoderMatrix.newPanto(8, k: 'dual');         // psycho optimised 7;;
//samples///////////////////////
	~doors=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/DOORS OPENING AND CLOSING/*");
	~footsteps=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/FOOTSTEPS/*");
	~toilet= Buffer.read(s,"/Users/michael/tank/SchaferHouse/SOUND/APPLIANCES/Toilet Flush 2.aiff");
	~water= Buffer.read(s,"/Users/michael/tank/SchaferHouse/SOUND/APPLIANCES/water running into sink.wav");
	~ambiStreet= Buffer.read(path:"/Users/michael/tank/SchaferHouse/Freesound/139023__lossius__agotnes-terminal-b-format.flac");
	~elevators=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/Freesound/Elevator/*");
)
s;

(//set up nodes 
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
	~bathroomBus=Bus.audio(s,1);
	~bathroom.dry.source={~bathroomBus.ar};
	~setIR.(~bathroom,~doorCl);
	~bathroom.wet.reshaping=\elastic;
	~bathroom.wet.fadeTime=0.5; //time for door open close
	//elevator
	~elevator=NodeProxy.new(s,\audio,2).play([~speakers[2],[3]]);
	~elevator.reshaping=\elastic;
)
s.freeAll;


~speakers=Array.series(8,10);

( //setup lobbyscene
	var lobbyscene = "/Users/michael/tank/SchaferHouse/SOUND/VENICE RECORDINGS/Elevator scene.wav";
	var dooropen = 613000;
	var buf = Buffer.read(s,lobbyscene);
	~lobbyscene={PlayBuf.ar(2,buf, startPos: dooropen)*2.5};
)

s.freeAll;
s.meter;
s;
s.plotTree;
(
	Routine.new({
		~traffic.wet.play;
		~bypass.(~traffic);
		~traffic.dry.source={FoaDecode.ar(PlayBuf.ar(4,~ambiStreet,loop:1)*1,~decoder)};
		5.wait; ~steps.wet.play(~speakers[5]);
		~steps.dry.source={PlayBuf.ar(2,~footsteps[0],loop:1)*0.3};
		~steps.wet.play(~speakers[4],fadeTime:8); 8.wait;
		~steps.wet.play(~speakers[0],fadeTime:8); 8.wait;
		~steps.wet.end(1);
		~doorway.wet.play(~speakers[6]); //dry for now... 
		~doorway.wet.source=~doorway.dry;
		~doorway.dry.source={PlayBuf.ar(1,[~doors[10],~doors[11]])*0.5};
		4.wait;
		~setIR.(~traffic,~doorCl,1.3);
		~setIR.(~doorway,~forest);//...now in interior verb
		~elevator.play(~speakers[2]);
		~elevator.source=~lobbyscene;
		~traffic.wet.end(1);
		}).play
)
Server.default=s=Server.local
s.freeAll;
//change IR when enter lobby
//~steps.wet.source={PartConv.ar(~steps.dry,4096,~forest)};

NodeProxy

( //flush then rinse
	~bathroomBus=Bus.audio(s);
	~bathroom.wet.playN([10,16],addAction: \addToTail);
	~bathroom.dry.source={In.ar(~bathroomBus)};
	Routine.new({
		~elevator.stop(0.1);
		~setIR.(~bathroom,~doorOp);
		//
		~steps.dry.source={PlayBuf.ar(2,~footsteps[0],loop:1)*0.3};
		~steps.wet.play(~speakers[2],fadeTime:5,addAction:\addToHead);
		~steps.wet.play(~bathroomBus,fadeTime:5,addAction:\addToHead);
		s.meter;

	~bathroom.dry[0]={In.ar(~bathroomBus)};
		~steps.wet.stop;
		//
		~bathroom.dry[0]={Pan2.ar(PlayBuf.ar(1,~water)*0.5,0.6)};
		3.wait;
		~setIR.(~bathroom,~doorCl);
		2.wait;
		~bathroom.dry[1]={Pan2.ar(PlayBuf.ar(1,~toilet),0.5)};
		16.wait;
	}).play
)

NodeProxy

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

a[0].postcs;
a[1].source={Saw.ar(300,0.1)};
a.play(1);
a[1];
a.add(b);
b=NodeProxy.new(s,\audio,1);
b.source={EnvGen.kr(Env.triangle(15))*Saw.ar(300,0.1)};
a.stop();
s.meter;
a.source={PinkNoise.ar(0.1)}
a=NodeProxy.new(s,\audio,1);
a;
zz



