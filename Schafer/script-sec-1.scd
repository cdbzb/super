(//setup
~names={|collection| collection.collect({|item index| PathName.new(item.path).fileName}) };
~upstairs=Library.at(\functions,\prepStereo).("/Users/michael/tank/IR/Saane/Domestic/Upstairs_1_floor.wav");
~upstairs2=Library.at(\functions,\prepStereo).("/Users/michael/tank/IR/Saane/Domestic/Upstairs_2_floors.wav");
)

//Traffic
//Construction

~outdoors=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/OUTDOORS/*");
~names.(~outdoors);
b=~outdoors[0].play;
~construction={|rate=1 gate=1 | Out.ar(0, PlayBuf.ar(2,~outdoors[0], rate:rate))*EnvGen.kr(Env.asr(5,1,10),gate: gate ))};

b.release(10);
b.set(\gate, 0);
b.free;

b.play;

//Footsteps

~footsteps=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/FOOTSTEPS/*");
~names.(~foosteps);
~footsteps[1].play;
g=Group.new;
a={Pan2.ar(PlayBuf.ar(1,~footsteps[rand(3)]),Line.kr(-1,1,12))}.play(g);
a={PartConv.ar(Pan2.ar(PlayBuf.ar(1,~footsteps[rand(3)]),Line.kr(-1,1,12)),4096,~upstairs)*0.06}.play(g);
a={PartConv.ar(Pan2.ar(PlayBuf.ar(1,~footsteps[rand(3)]),Line.kr(-1,1,12)),4096,~upstairs2)*0.06}.play(g);
s.meter;

//Lobby door opens

~doors=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/DOORS OPENING AND CLOSING/*");
~names.(~doors);
(
	{
	4.do({ //repeats
		var aa=~construction.play; //todo- add random offset and pitch
		6.wait;
		g=Group.new; //todo clear group members how?
		4.do({ 
			{PartConv.ar(Pan2.ar(PlayBuf.ar(1,~footsteps[rand(3)]),Line.kr(-1,1,12)),4096,~upstairs)*0.06}.play(g);
			rrand(2,5).wait;
		});
		4.wait;
		g.freeAll;
		{PlayBuf.ar(1,[~doors[10],~doors[11]])*2}.play;
		4.5.wait;
		aa.free;
//Room tone 
		~chord={Splay.ar(SinOsc.ar([300,320,400,420,480,600],0,0.07))}.play;
//New foot steps
		2.wait;
		a={Pan2.ar(PlayBuf.ar(1,~footsteps[rand(3)]),Line.kr(-1,1,12))}.play;
		9.wait;
	})
	}.fork
)
//Misc sounds of people in public space
//Elevator ding
//Doors open
//Doors close
//New room tone and mechanical sounds
//Elevator sound
//Doors open
//Exit into new room tone
//New footsteps
//Keys
//Door lock open
//New room tone
//Door close
//Foot steps
//Alarm keypad beeps
//Keys down
//Bag down
//Foot steps
//Shuffling around
//Sink and hand washing
//Refrigerator door opens
//Closes
//Pouring
//Getting ice
//Footsteps
//Door
//Room tone changes/ambience
//Toilet flushing
//Sink and hand washing
//Foot steps
//Kitchen
//Micro wave sounds
//Plates
//Phone rings
