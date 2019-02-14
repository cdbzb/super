//Traffic
(//setup
~names={|collection| collection.collect({|item index| PathName.new(item.path).fileName}) };
)

//Construction

~outdoors=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/OUTDOORS/*");
~names.(~outdoors);
b=~outdoors[0].play;

//Footsteps

~footsteps=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/FOOTSTEPS/*");
~names.(~foosteps);
~footsteps[1].play;
g=Group.new;
a={Pan2.ar(PlayBuf.ar(1,~footsteps[rand(3)]),Line.kr(-1,1,12))}.play(g);
s.meter;

//Lobby door opens

~doors=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/DOORS OPENING AND CLOSING/*");
~names.(~doors);
(
	{
		{ 
		g.free;
		PlayBuf.ar(1,[~doors[10],~doors[11]])}.play;
		4.1.wait;
		b.free;
	}.fork
)

//Room tone 
//New foot steps
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
