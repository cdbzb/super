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
	~fu_play={|vol| ~fu_monitor.playN(~speakers.wrapExtend(12).scramble,1,~speakersz.index+(0..11),vol:vol)};
	//~fu_play={~fu_monitor.playN([~speakers.wrapExtend(12).scramble],1,~speakersz.index+(0..11))};
	ServerTree.add(~fu_play);
	Monitor
)

ServerTree.removeAll;
ServerTree.objects;

( //fu
	~fu={ | bufs reps=200 rateMin=0.1 rateMax=2.5 amp=0.2 ampVar=1 density=1|
		var indices=Array.series(bufs.size);
		indices = Pxrand(indices,inf).asStream;
		{
			reps.do{
				var rate = rrand(rateMin,rateMax);
				var num=indices.next; 
				{PlayBuf.ar(4,bufs[num],rate:rate,doneAction:2)*(rrand( amp*ampVar , amp/ampVar)) }
					.play(s,~speakersz.index+(8.rand));
				([1.0.rand,1.0.rand,0.2,2].choose*1/density).wait;
			}
		}.fork;
	}
)

~niceParty.(0.4);
~partyPauser.pause;~jumpinessTask.pause;~crowd.do({|m| m.set(\vol,0)}); //make this a function
~partyPauser.resume;~jumpinessTask.resume;
( /// interrupt all 8 chans
	{
		~beeep={ReplaceOut.ar(~speakers[0],{PinkNoise.ar(0.03)}!8)}.play(s,addAction:\addToTail);
		1.6.wait;
		~beeep.free;
	}.fork
)

~window=~doors[8];

(
	{
		//walk to bedroom door
		~walkFromTo.(0,~speakers[4],~speakers[2],5);
		5.wait;
		//bedroomsetup
		~bedroomBus=Bus.audio(s,2);
		~bedroom=NodeProxy.audio(s,2) .source={In.ar(~bedroomBus)};
		~bedroom[1]=\filter -> {|in| PartConv.ar(in,4096,~washRoom)*0.2+(in)*0.2}; //should be stereo 
		~bedroom.playN([~speakers[2],~speakers[3]],1!2,[0,1]);
		//open bedroom door
		{ PlayBuf.ar(1, ~doors[2])*0.4 }.play(s,~speakers[2]);
		1.wait;
		~walkFromTo.(0,~speakers[2],~bedroomBus,8);
		8.wait;
		{ PlayBuf.ar(2,~window,doneAction:2) }.play(s,~bedroomBus); // make top and tail
		1.wait;
		~venice=Buffer.read(s,"/Users/michael/tank/SchaferHouse/SOUND/VENICE RECORDINGS/good drivebys.wav");

		a={ PlayBuf.ar(2, ~venice)*1 }.play(s,~bedroomBus);


		//~makeSpace.()	//BR
		//walk to window (in br)
		//open window - traffic
	}.fork
)

~niceParty.set(\sound,1);
~fu.(~davidSteps,20,rateMin:0.8,rateMax:1.2,ampVar:1.1);
~fu.(~aiSounds3],20,rateMin:0.8,rateMax:1.2,ampVar:1.1);
~fu.(~chairs,50,rateMin:0.8,rateMax:1.2,amp:0.3,ampVar:1.1);
~fu.(~ice,50,rateMin:0.1,rateMax:2.2,amp:1,ampVar:1.1);
~fu.(~ice,19,rateMin:1.8,rateMax:2.2,amp:1,ampVar:1.1,density:9);
~fu.(~chairs,10,rateMin:0.8,rateMax:1.2,amp:0.3,ampVar:1.1,density:2);
{ PinkNoise.ar(0.05) }.play(s,~speakers[2]);

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


