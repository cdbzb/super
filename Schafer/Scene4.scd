//knock open "you have arrived at your destination"
(
	{
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
			0.3.wait;
			{var sig = PartConv.ar( PlayBuf.ar(1,~buff,rate:0.48)*0.2, 4096, ~speaker); sig=PartConv.ar(sig,4096,~washRoom)*0.04+sig; sig;}.play(s,~speakers[4]);
		}.fork;
		3.wait;




		~niceParty.(0.1);
		//steps (many?) 

		//chairs-movement

~chairs=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/ambeo/chairs*");
~davidSteps=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/ambeo/footsteps*");
~ice=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/ambeo/ice*");
~names.(~chairs);
{var num=19.rand; PlayBuf.ar(~ice[num].numChannels,~ice[num]) }.play(s,~speakers[8.rand]);
{var num=2.rand; PlayBuf.ar(~davidSteps[num].numChannels,~davidSteps[num]) }.play(s,~speakers[8.rand]);

)

( //chair-fu
	var indices = Pxrand([0,1,2,3,4],inf).asStream;
	(~chairs==nil).if{~chairs=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/ambeo/chairs*")};
	// indices = Pseq([0,1,2,3,4],inf).asStream;
	{
		20.do{
			
			//var rate=[0.8,1,1.25].choose;
			var rate = rrand(0.8,1.2);
			{var num=indices.next; PlayBuf.ar(4,~chairs[num],rate:rate)*0.2 }.play(s,~speakers[8.rand]);
			[1.0.rand,1.0.rand,0.2,2].choose.wait;
		}
	}.fork
)
~davidSteps.size;
( //david-fu
	var indices = Pxrand([0,1],inf).asStream;
	(~davidSteps==nil).if{~davidSteps=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/ambeo/davidSteps*")};
	// indices = Pseq([0,1,2,3,4],inf).asStream;
	{
		20.do{
			
			//var rate=[0.8,1,1.25].choose;
			var rate = rrand(0.8,1.2);
			{var num=indices.next; PlayBuf.ar(4,~davidSteps[num],rate:rate)*0.1 }.play(s,~speakers[8.rand]);
			[1.0.rand,1.0.rand,0.2,2].choose.wait;
		}
	}.fork
)

( //ice-fu
	var indices=Array.series(~ice.size);
	indices = Pxrand(indices,inf).asStream;
	(~ice==nil).if{~ice=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/ambeo/ice*")};
	// indices = Pseq([0,1,2,3,4],inf).asStream;
	{
		200.do{
			
			//var rate=[0.8,1,1.25].choose;
			var rate = rrand(0.8,1.2);
			{var num=indices.next; PlayBuf.ar(4,~ice[num],rate:rate)*0.2 }.play(s,~speakers[8.rand]);
			[1.0.rand,1.0.rand,0.2,2].choose.wait;
		}
	}.fork
)


		//numbers (try interrupt using OutReplace or whatever that is!)

		//more voices

		//alexa
		
		//EDM

		//phonecall - verification 

		//window - traffic

		//helicircle
	}.fork
)

//ALT ORDER ??
//door " you have arrived"

//call

//verification

//door " you have arrrived"

//many enter

//furniture mingled with chatter

//number/interrupt

//window traffic

//helicircle

//"spacey"
//
//Market Phrases ?


