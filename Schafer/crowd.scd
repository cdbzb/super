//a=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/AI SOUNDS/*");
~aiSounds=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/AI SOUNDS/*");
~bots=~aiSounds[0];

( //nice party
	~niceParty={|masterVol|
		~jumpinessBus=NodeProxy.control;
		~jumpinessBus.source=10000009;  //clean
		~guest={ |vol jumpiness=10000009 |
			BufRd.ar(1, ~bots, Phasor.ar(
				0, 
				BufRateScale.kr(~bots)*Rand(0.9,1.1), 
				0,
				BufFrames.kr(~bots)
			)+LFBrownNoise0.kr(
				(LFBrownNoise2.kr(1,mul:0.9,add:0.5)),0.5,mul:~jumpinessBus)
			)*Rand(0.5,1)*vol };

			~crowd=Array.fill(7,{NodeProxy.audio(s,1)});
			~crowd.do({|m| m.source=~guest});
			~crowd.do({|m x| m.play(~speakers[x],vol:masterVol)});
			~crowd.do({|m| m.fadeTime=4});
			~crowd.do({|m| m.lag(\vol,4)});
			{100.do({ ~crowd.do({|m| m.set(\vol,[0,0.5,0.35].choose)});5.wait; })}.fork;
			//little tingle
			{ //take these to a seperate place ??
				30.wait;~jumpinessBus.source=100000009;
				30.wait;
				~jumpinessBus.source=10000009;
				//30.wait;~jumpinessBus.source=100000009;
				60.wait;~jumpinessBus.source={Line.kr(1000009,109,100)};
				60.wait;~jumpinessBus.source={Line.kr(109,10000000009,100000)};
				60.wait; ~jumpinessBus.source={Line.kr(109,10000000009,15)};
				15.wait;
				~crowd.do({|m| m.stop(20)});
			}.fork
		}
)


(
	{
		{ PlayBuf.ar(1,~doors[6] ,startPos:40000)}.play(s,~speakers[4]);
		4.wait;
		~walkFromTo.(0,~speakers[1],~speakers[4],11,fadeIn:0.3);
		11.wait;
		{PlayBuf.ar(1,~doors[7])}.play(s,~speakers[4]);
		2.wait;
		n=~niceParty.(0.2).play;
	}.fork
)
		~crowd.do({|m x| m.play(~speakers[x],vol:0.5)});

(
	{       var line=Line.kr(3,0.2,10);
	800.do({
		{PlayBuf.ar(~texts.choose.numChannels,~texts.choose,rate:([0.9,1,1.11].choose*(rrand(0.99,1.01))) ,doneAction:2) *[0.5,0.5,0.1].choose}.play(s,~speakers.choose);

		linrand(0.3,3).wait; //use a line for the lower bound
	})}.fork;
)

~circlingCopter.play;

(
	~circlingCopter={
		{
			//do with a gate instead
			var cycleLength = 10;
			//var in = PinkNoise.ar(0.05);
			var in = {PlayBuf.ar(1,~helicopter[3],rate:0.9)  };
			var gate=Impulse.ar(1/cycleLength);
			var env=EnvGen.kr(~panEnv, timeScale:(cycleLength/2),gate:gate);
			//pan=~panEnv.at(pan);
			(PanAz.ar(7,in,env,orientation:0,width:2));
		}.play(s,~speakers[0]);
	}
)
//idea: numbers interrupt

	b=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/AI SOUNDS/*");
	
	//tape-speed changes (sounds cool in #7)
	{ BufRd.ar(2, ~bots,LFBrownNoise2.ar(1,0.01) * BufFrames.ir(~bots))*0.5 }.play(s,~speakers[7]);
	//un-noticeable glitcher
(       
	~bots=~aiSounds[0];
	~guest={ |vol jumpiness=10000009 out=2|
		Out.ar(out, vol* 
		BufRd.ar(1, ~bots, Phasor.ar(
			0, 
			BufRateScale.kr(~bots)*Rand(0.9,1.1), 
			0,
			BufFrames.kr(~bots)
		)+LFBrownNoise0.kr((LFBrownNoise2.kr(1,mul:0.9,add:0.5)),0.5,mul:~jumpinessBus))*Rand(0.5,1)) };
)


	~crowd.do({|m| m.set(\vol,rrand(0,0.5))});
	~crowd.do({|m| m.set(\vol,[0,0.5].choose)});
	~crowd.do({|m| m.stop(5)});
{	PlayBuf.ar(~bots.numChannels,~bots)}.play(1);
	



	(
		~jumpinessBus=NodeProxy.control;
		~jumpinessBus.source=10000009;  //clean
		7.do({|index| {~guest.(vol:0.3,out:index)}.play});
	)

~jumpinessBus.source=10000009;  //clean
~jumpinessBus.source=100000009;  //little tingle
~jumpinessBus.source=1000000009;  //ring mod-ish
~jumpinessBus.source=10000000009;  //dirtier yet
~jumpinessBus.source={Line.kr(1000009,109,100)}; //bend till they get together
~jumpinessBus.source={Line.kr(109,10000000009,100000)}; //and head back out
~jumpinessBus.source={Line.kr(10000500008,1000000009,10)}; 
~jumpinessBus.source={Line.kr(109,10000000009,XLine.kr(100000,10,20))};  // nice
~jumpinessBus.fadeTime=10000;
~jumpinessBus.fadeTime=0;
~jumpinessBus.fadeTime;
~jumpinessBus.source=109;
~jumpinessBus.clear;

~hold = { PlayBuf.ar(~holdMusic[0].numChannels,~holdMusic[2]) }.play(s,~speakers[7]);


a.stop;
a.clear;
a.play(~speakers[4]);
a.play(~speakers[0],fadeTime: 8);
b=NodeProxy.audio(s,8);
b.play(~speakers);
~guest.play(s,~speakers[0]);
a.source={SinOsc.ar(400,0,0.05)};
a=~guest.play(s,~speakers[1]);

a.set(\jumpiness, 100000009);
a.fadeTime=20;
a.lag(\jumpiness, nil);
~guest.play;
~guest( 100000009).play(s,~speakers[4]);
~speakers;
