( ///// setup

	~chairs=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/ambeo/chairs*");
	~davidSteps=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/ambeo/footsteps*");
	~ice=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/ambeo/ice*");
	~venice=Buffer.read(s,"/Users/michael/tank/SchaferHouse/SOUND/VENICE RECORDINGS/good drivebys.wav");
	~noiseFu.free;~noiseFu=Buffer.read(s,"/Users/michael/tank/SchaferHouse/fu-noise8-chan2.aif");
)
(
	~moveNumberBuffersToRemote={
		8.do({	|i|
			var buf=~numberBuffers[i];
			buf.loadToFloatArray(action:
				{|array| 
					~numberBuffers[i]=Buffer.sendCollection(s,array)});

				});
			};
		)
		~moveNumberBuffersToRemote.();
//knock open "you have arrived at your destination"
( // first draft
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
		~fu.(~davidSteps,density:0.2,amp:0.2);
		~fu.(~ice,density:8.2);
		~fu.(~chairs);

 		~niceParty.(0.2);
		//steps (many?) 

			~makeNumberBuffers.();
			~moveNumberBuffersToRemote.();
			{var num= 8.rand; num.postln; {  PlayBuf.ar(1,~numberBuffers[num],rate:0.5) }.play(s,~speakers[num])}.value	;
			~speakers[2];

		//chairs-movement

}.fork)

( /// to enable moving around the circle ... what about random?
	ServerTree.remove(~fu_play);
	~speakersz.free;~speakersz=Bus.audio(s,12);
	~fu_monitor.free;~fu_monitor=Monitor.new;
	//scramble ?
	~fu_play={~fu_monitor.playN(~speakers.scramble.wrapExtend(12),1,~speakersz.index+(0..11))};
	//~fu_play={~fu_monitor.playN([~speakers.wrapExtend(12).scramble],1,~speakersz.index+(0..11))};
	ServerTree.add(~fu_play);
)

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

(//  noise-fu
	//{ 
	//	s.prepareForRecord("/Users/michael/tank/SchaferHouse/fu-noise8-chan4.aif",numChannels:8);
	//	s.sync;
	//	s.record(bus:~speakers[0],duration:300);
	//	~fu.(~ice);
	//	310.wait;
	//  
	//}.fork
)
s.stopRecording;

( // a little composition
	{
		s.prepareForRecord("/Users/michael/tank/SchaferHouse/5-6-alt1.aif",numChannels:8);
		s.sync;
		//s.record(bus:~speakers[0]);
		c=SystemClock.seconds;
		{PlayBuf.ar(1,~doors[5])*0.5}.play(s,~speakers[4]);
		2.wait;
		~walkFromTo.(1,~speakers[5],~speakers[4],7,fadeIn:0.3);
		7.wait;
		{PlayBuf.ar(1,~doors[2])*0.7}.play(s,~speakers[4]);
		~hallThroughDoor=NodeProxy.audio(s,1).play(~speakers[4]);
		~hallThroughDoor.source= {PlayBuf.ar(~hallway.numChannels,~hallway,startPos:54*48000)*1.5};
		1.5.wait;
		{
			//~prepPhraseToBuff.("you have arrived at your destination");
			//0.4.wait;
			{var sig = PartConv.ar( PlayBuf.ar(1,~buff,rate:0.48)*0.1, 4096, ~speaker); sig=PartConv.ar(sig,4096,~washRoom)*0.04+sig; sig;}.play(s,~speakers[4]);
		}.fork;
		6.wait;

		//~fu.(~davidSteps,8,amp:0.2,rateMin:0.8, rateMax:1.1);
		//15.wait;
		~fu.(~chairs,36,rateMin:0.8,ampVar:1.3);
		~walkFromTo.(0,~speakers[4],~speakers[0],8);
		2.wait;
		~walkFromTo.(1,~speakers[5],~speakers[2],6);
		{ PlayBuf.ar(1,~doors[1])*0.4 }.play(s,~speakers[4]);
		~hallThroughDoor[1]=\filter->{|in| PartConv.ar(in,4096,~doorCl)};
		0.2.wait;~hallThroughDoor.release(0.5);
		24.wait;
		~fu.(~ice,120,density:2,amp:0.3,ampVar:1.1);
		2.wait; ~walkFromTo.(1,~speakers[2],~speakers[6],8);
		25.wait;
		~niceParty.(0.2,lag:1.5);
		30.wait;
		~fu.(~ice,60,rateMin:1,rateMax:2,amp:0.15,density:0.5);
		42.wait;
		//~crowd.do({|m| m.lag(\vol,0.1)});
		4.wait;
		~crowd.do{|m| m.release(9)};
		~niceParty.set(\sound,1);postln('set');
		8.wait;
		//~partyPauser.pause;~jumpinessTask.pause;~crowd.do({|m| m.set(\vol,0)}); 
	{
			~crowd.do{|m| m.release(0.1)};
			~beeep={ReplaceOut.ar(~speakers[0],{PinkNoise.ar(0.03)}!8)}.play(s,addAction:\addToTail);
			1.6.wait;
			~beeep.free;
	}.fork;
		~window=~doors[8];
		~windowOpen={ Line.kr(dur:2,doneAction:2);PlayBuf.ar(1, ~window) };
		~windowClose={ Line.kr(dur:2,doneAction:2);PlayBuf.ar(1, ~window, startPos:(44000*5.4))*1.5};
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
		~walkFromTo.(0,~speakers[2],~bedroomBus,8,fadeOut:0.8);
		8.wait;
		~windowOpen.play(s,~bedroomBus); // make top and tail
		1.wait;
		a={ PlayBuf.ar(2, ~venice,startPos:(44000*7))*1 }.play(s,~bedroomBus);
		30.wait;
		~windowClose.play(s,~bedroomBus);
		a.release(0.3);
		2.wait;
		~clicks=Group.new(s);
		8.do{|x| {Impulse.ar(rrand(1.5,2.0)/4,rrand(0,1.0),mul:0.3)}.play(~clicks,~speakers[x])};
		//~noizz={ PlayBuf.ar(8,~noiseFu)*0.8 }.play(s,~speakers[0]);
		10.wait;
		~playOneNumber.();
		f={|vol=0.5| PlayBuf.ar(8,~noiseFu)*vol }.play(s,~speakers);

		100.wait;
		~clicks.free;
		00.wait;
		f.release(70);
		{ SinOsc.ar([400,360,300,280,440,450,240,340],0,0.01)*EnvGen.kr(Env.linen(40,40,20)) }.play(s,~speakers[0]);
		50.wait;
		~playOneNumber.();
		50.wait;
	c=SystemClock.seconds-c;
	s.stopRecording;
	c.postln;
	}.fork
)

(
	{
		~crowd.do({|m| m.lag(\vol,0.1)});
		4.wait;
		~partyPauser.pause;~jumpinessTask.pause;~crowd.do({|m| m.set(\vol,0)}); //make this a function
			{var num= 8.rand; num.postln; {  PlayBuf.ar(1,~numberBuffers[num],rate:0.5) }.play(s,~speakers[num])}.value	;
		~crowd.do({|m| m.lag(\vol,14)});
		4.wait;
		~partyPauser.resume;~jumpinessTask.resume;
	}.fork
)

( /// interrupt all 8 chans
	{
		~beeep={ReplaceOut.ar(~speakers[0],{PinkNoise.ar(0.03)}!8)}.play(s,addAction:\addToTail);
		1.6.wait;
		~beeep.free;
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


