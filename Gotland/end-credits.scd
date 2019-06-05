Pipe.new("open -a 'REAPER64.app' /Users/michael/tank/THE\\ FUTURE/VIDEO-ONLY.RPP","w" );

~waves_3m=Buffer.read(s,"/Users/michael/tank/THE FUTURE/SC-bounces/3m-stereo\ bounce.wav");
~clink=Buffer.read(s,"/Users/michael/tank/THE FUTURE/media/GOT-0824-003_walking along beach big pebbles.WAV");

c={Mix.ar(SinOsc.ar([340,36,400,450,480]*0.8,0,0.03))!2}.play;
~dry={PlayBuf.ar(2,~waves_3m)*EnvGen.kr(Env.asr(10))}.play;
~fadeOut={|time|c.release(time);~dry.release(time)};
~fadeOut(30);

( // TITLES version
	~start = 90*60-20;
	t=TempoClock.default; t.beats=~start;
	~rpr.sendMsg('time',~start*1.001);
	~rpr.sendMsg('/stop');
	~rpr.sendMsg('/play');
	~schedule.(90*60-6, {~fadeOut.(30)}); //is .value needed??? 
	~schedule.(90*60+3, {{PlayBuf.ar(~clink.numChannels,~clink,startPos:400000)*EnvGen.ar(Env.asr(20),levelScale:0.02) }.play});
	t.beats;
)

(
	~clinkBit={ var frame=rrand(400000,~clink.numFrames);
	 	PlayBuf.ar(~clink.numChannels,~clink,startPos:frame,rate:[0.8,1,1.2].choose*0.2 )*0.2*
		EnvGen.kr(Env.perc(rand(3.0)),doneAction:0)	
       };
	)

	{ 30.do{ ~clinkBit.play(s,~bus); rrand(1.5,3).wait; }}.fork
	{ 90.do{ {var sig= ~clinkBit*0.3+MembraneCircle.ar(~clinkBit,tension:rrand(0.02,0.09));DetectSilence.ar(sig,doneAction:2);sig}.play(s,~bus); rrand(0.05,3).wait; }}.fork
	{ 90.do{ {var sig= ~clinkBit*0.3+MembraneHexagon.ar(~clinkBit,tension:rrand(0.02,0.09));DetectSilence.ar(sig,doneAction:2);sig}.play(s,~bus); rrand(0.05,2).wait; }}.fork
	t.beats=~start;
t.beats=(-50);
t.beats;
~bus=Bus.new;
~verb=NodeProxy.audio.play;
~verb.source={TwoTube.ar(~bus.ar,d1length:1000,d2length:2070,loss:0.95,k:-0.8)*1.2};
~verb.source=nil;

Server.supernova;
s.supernova;
DetectSilence
~drumz=NodeProxy.audio.play;
~drumz.source={MembraneCircle.ar(~bus.ar,tension:0.1)};
~drumz.stop;

~end.fork;

( //ending CYCLING BACK VERSION
	//setup - buffers
(~waves==nil).if{~waves=Buffer.read(s,"/Users/michael/tank/THE FUTURE/SC-bounces/Hayburn.wav")};
(~waves_3m==nil).if{~waves_3m=Buffer.read(s,"/Users/michael/tank/THE FUTURE/SC-bounces/3m-stereo\ bounce.wav")};


//chord	
	//~tones=[400,450,420,500,560,600];
	~tones=[400,450,500,560,600];
	~tones=~tones/2;
	~chd={~tones.do({|item index| {Pan2.ar(SinOsc.ar(item,0,0.002*EnvGen.kr(Env.linen(40,20,35,))),index/2-1)}.play})}; // add arguments for ad and vol
//klank
	~klankBus.source=~tones;
//startup sound
	~startup={(\instrument: \fibs, \fr: [4,4.5,5,6,8,9,10]*2*1.2,\amp:0.2).play};
	~dry={PlayBuf.ar(~waves_3m.numChannels,~waves_3m)*EnvGen.kr(Env.asr(10))}.play;
////// Start time
	~gap=11; // space before video starts again in seconds;
	~startFrom.(5304); 
	//~locateSecs.(5401);
{ ////the Sequence: idea - set end and do some scheduling relatively
	s.sync;
	~schedule.(5310,{~chd.value});"chd".postln;
	~schedule.(5401,{~locateSecs.(3600-~gap)}); // go back to top
	~schedule.(5407,~startup);
	~schedule.(5423,{{PlayBuf.ar(2,~waves_3m)*EnvGen.kr(Env.asr(40),levelScale:0.5) }.play});
	~schedule.(5314,{~klank.play(vol:0.2,fadeTime:30)});
	~schedule.(5314,{~dry.release(51)});
	~klankBus.fadeTime=15;
	~schedule.(5340,{~klankBus.source=(~tones).scramble});//is this happening?
	~schedule.(5344,{~klank.play(vol:0,fadeTime:56)});
	} .fork
)

//Cue for Walker 2
(
	a={|vol=0.6|PlayBuf.ar(~waves_3m.numChannels,~waves_3m)*vol}.play;
	~klank.play;
	~startFrom.(3858);
	//~schedule.(3860,{~chordWave.()});
	~schedule.(3860,{~playme.(~chords.choose,len:180,pause:30,pan:0.9)}); //play through NodeProxy 
	~schedule.(3960,{~membrane.play(fadeTime:30)});
)

//setup waves as proxy to feed membrane and klank



