( ///// setup
	~chairs=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/ambeo/chairs*");
	~davidSteps=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/ambeo/davidSteps*");
	~ice=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/ambeo/ice*");
)
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
			0.4.wait;
			{var sig = PartConv.ar( PlayBuf.ar(1,~buff,rate:0.48)*0.2, 4096, ~speaker); sig=PartConv.ar(sig,4096,~washRoom)*0.04+sig; sig;}.play(s,~speakers[4]);
		}.fork;
		3.wait;

 		~niceParty.(0.2);
		//steps (many?) 

		//chairs-movement

}.fork)

( /// to enable moving around the circle ... what about random?
	ServerTree.remove(~fu_play);
	~speakersz.free;~speakersz=Bus.audio(s,12);
	~fu_monitor.free;~fu_monitor=Monitor.new;
	//scramble ?
	~fu_play={~fu_monitor.playN(~speakers.wrapExtend(12).scramble,1,~speakersz.index+(0..11))};
	//~fu_play={~fu_monitor.playN([~speakers.wrapExtend(12).scramble],1,~speakersz.index+(0..11))};
	ServerTree.add(~fu_play);
)
ServerTree.removeAll;
ServerTree.objects;
( //fu
	~fu={ | bufs reps=200 rateMin=0.1 rateMax=2.5|
		var indices=Array.series(bufs.size);
		indices = Pxrand(indices,inf).asStream;
		{
			reps.do{
				var rate = rrand(rateMin,rateMax);
				var num=indices.next; 
				{PlayBuf.ar(4,bufs[num],rate:rate,doneAction:2)*0.2 }.play(s,~speakersz.index+(8.rand));
				[1.0.rand,1.0.rand,0.2,2].choose.wait;
			}
		}.fork;
	}
)

~fu.(~davidSteps,20,rateMin:0.8,rateMax:1.2);
~fu.(~chairs,50,rateMin:0.8,rateMax:1.2);

(
	s.prepareForRecord("/Users/michael/tank/SchaferHouse/ringer-foo.wav",8);
	s.record(bus:2,numChannels:8,duration:180);
	~fu.(~ice);
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


