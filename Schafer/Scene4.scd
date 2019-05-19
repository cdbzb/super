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
		~niceParty.(0.4);
		//steps (many?) 

		//chairs-movement

		//numbers (try interrupt using OutReplace or whatever that is!)

		//chatter starts

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


