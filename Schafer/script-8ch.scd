
(//setup
"/Users/michael/tank/super/Schafer/FUNCTIONS.scd".load;
~upstairs=Library.at(\functions,\prepStereo).("/Users/michael/tank/IR/Saane/Domestic/Upstairs_1_floor.wav");
~upstairs2=Library.at(\functions,\prepStereo).("/Users/michael/tank/IR/Saane/Domestic/Upstairs_2_floors.wav");
~nextDoor01Open=Library.at(\functions,\prepStereo).("/Users/michael/tank/SchaferHouse/Next-Door/01-open-door.wav");
~nextDoor02Closed=Library.at(\functions,\prepStereo).("/Users/michael/tank/SchaferHouse/Next-Door/02-closed-door.wav");
~outdoors=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/OUTDOORS/*");
~footsteps=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/FOOTSTEPS/*");
~doors=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/DOORS OPENING AND CLOSING/*");
~construction={|spkr=0 rate=1 gate=1 | Out.ar(spkr+~speakers[0], PlayBuf.ar(2,~outdoors[0], rate:rate))*EnvGen.kr(Env.asr(6,0.1,10),gate: gate )};
)

//Traffic
//Construction
//Footsteps

~footsteps=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/FOOTSTEPS/*");
~names.(~foosteps);
~footsteps[1].play;
a={Pan2.ar(PlayBuf.ar(1,~footsteps[rand(3)]),Line.kr(-1,1,12))}.play; //clean

~walkit={|in ir amp=0.06 length=12| PartConv.ar(Pan2.ar(PlayBuf.ar(1,in),Line.kr(-1,1,length),amp),4096,ir)};
a={PartConv.ar(Pan2.ar(PlayBuf.ar(1,~footsteps[rand(3)]),Line.kr(-1,1,12)),4096,~upstairs)*0.06}.play(g);
a={~walkit.(~footsteps[rand(3)],~upstairs)}.play;
a={~walkit.(~footsteps[rand(3)],~nextDoor02Closed,amp:0.9)}.play;

a={PartConv.ar(Pan2.ar(PlayBuf.ar(1,~footsteps[rand(3)]),Line.kr(-1,1,12)),4096,~upstairs2)*0.06}.play(g);
a={PartConv.ar(Pan2.ar(PlayBuf.ar(1,~footsteps[rand(3)]),Line.kr(-1,1,12)),4096,~nextDoor01Open)*0.09}.play(g);
a={PartConv.ar(Pan2.ar(PlayBuf.ar(1,~footsteps[rand(3)]),Line.kr(-1,1,12)),4096,~nextDoor02Closed)*0.6}.play(g);
~nextDoor02Closed;
s.meter;

//Lobby door opens

~doors=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/DOORS OPENING AND CLOSING/*");
~names.(~doors);


{~construction.(2,0.98)}.play;
s.freeAll;



( // Comp 1 - construction through new step
	var cleanSteps;
	var steps=Group.new; 
	~chord=Array.newClear(10);
	{
	3.do({ //repeats 
		|index|
		var construction={~construction.(rand(3)+10,rrand(0.9,1))}.play; //todo- add random offset and pitch
		3.wait;
		3.do({ 
			{Out.ar(13,PartConv.ar(Pan2.ar(PlayBuf.ar(1,~footsteps[rand(3)]),Line.kr(-1,1,12)),4096,~upstairs)*0.02*EnvGen.kr(Env.cutoff(1.1)))}.play(steps); // Prandx?
			rrand(2,5).wait;
		});
		4.wait;
		{Out.ar(15,PlayBuf.ar(2,[~doors[10],~doors[11]])*0.6)}.play;
		0.25.wait; // till door open
		steps.freeAll;
		4.00.wait; //till door closed
		construction.free;
		~chord[index]={Out.ar(10,SinOsc.ar(Vibrato.kr([300,320,400,420,480,600,301,602],depth: EnvGen.kr(Env([0,0,0.01],[5,15]))),0,0.01))}.play;
		//~chord={Splay.ar(SinOsc.ar([300,320,400,420,480,600],0,0.07))}.play;
//New foot steps
		2.wait;
		cleanSteps={Out.ar(rand(8)+9,Pan2.ar(PlayBuf.ar(1,~footsteps[[0,2].choose])*0.3,Line.kr(-1,1,12),EnvGen.kr(Env.cutoff(4))))}.play;
		1.wait;
		cleanSteps.release(13);
		8.wait;
	});
	5.wait;
	~chord.do{|item index| item.release(12)};
	}.fork
)
//Misc sounds of people in public space

s.freeAll;

//Elevator ding
~doorbells=[5,6,9].collect({|item| ~doors[item]});
~doorbells[2].play;

//Doors open

~elevator=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/ROOM TONES/EL*");
~elevator=~elevator[0];
~elevator.play;



//Doors close
//New room tone and mechanical sounds

~rooms=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/ROOM TONES/*");
~rooms.size;

( // roomtone collage
	a=NodeProxy.new.play(0);
	a.fadeTime=8;
	{
		s.sync;
		~rooms.do({ |item index|
			a.source={PlayBuf.ar(2,item)*0.05};
			item.path.postln;
			8.5.wait;
		});
	a.clear(8);
	b.free;
	}.fork;

)
(
	b={
		15.do({
			a.play([10,11,12,13,14,15,16,17].choose,fadeTime:8);
			3.5.wait;
		})
	}.fork
)
s.freeAll;



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
