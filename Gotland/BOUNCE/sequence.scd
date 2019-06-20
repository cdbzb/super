( //ending CYCLING BACK VERSION
	//setup - buffers
(~waves==nil).if{~waves=Buffer.read(s,"/Users/michael/tank/THE FUTURE/SC-bounces/Hayburn.wav")};
(~waves_3m==nil).if{~waves_3m=Buffer.read(s,"/Users/michael/tank/THE FUTURE/SC-bounces/3m-stereo\ bounce.wav")};
~waves_3m;


~membrane.stop(5);
//chord	
	//~tones=[400,450,420,500,560,600];
	~tones=[400,450,500,560,600];
	~tones=~tones/2;
	~chd={| len=20 | ~tones.do({|item index bus=0| {Pan2.ar(SinOsc.ar(item,0,0.002*EnvGen.kr(Env.linen(40,len,35,))),index/2-1)}.play(outbus:~out.index+8)})}; // add arguments for ad and vol
	~chd_long={| len=28 | ~tones.do({|item index bus=0| {Pan2.ar(SinOsc.ar(item,0,0.002*EnvGen.kr(Env.linen(40,len,35,))),index/2-1)}.play(outbus:~out.index+8)})}; // add arguments for ad and vol
//klank
//startup sound
	~startup={(\instrument: \fibs, \fr: [4,4.5,5,6,8,9,10]*2*1.2,\amp:0.2).play};
	//~startup={(\instrument: \cloud_staggered,\fr: [240,288,300,360], amp:0.5).play};
	~dry={PlayBuf.ar(~waves_3m.numChannels,~waves_3m)*EnvGen.kr(Env.asr(10))}.play;
////// Start time
	~gap=11; // space before video starts again in seconds;
	//~locateSecs.(5401);
)
		~klank.initMonitor;
		~klank.monitor.outs_([[0,~out.index+2],[1,~out.index+3]]);
		~klank.playN; //??
		s.meter;
(
	~recpath="/Users/michael/tank/THE FUTURE/SC-bounces/";
{ ////the Sequence: idea - set end and do some scheduling relatively
	s.prepareForRecord(~recpath++"ending-10-chans.aif",numChannels:10);
	s.sync;
	//s.record(bus:~out,duration:150);
	~startFrom.(5304); 
	~schedule.(5310,{~chd.value});"chd".postln;
	~schedule.(5340,{~klankBus.source=~tones});
	~schedule.(5314,{~klank.play(vol:0.2,fadeTime:30)});
	~schedule.(5314,{~dry.release(51)});
	~klankBus.fadeTime=15;
	~schedule.(5340,{~klankBus.source=(~tones).scramble});//is this happening?
	~schedule.(5344,{~klank.play(vol:0,fadeTime:56)});
	~schedule.(5401,{~locateSecs.(3600-~gap)}); // go back to top
	//~schedule.(5407,~startup);
	//~schedule.(5423,{{PlayBuf.ar(2,~waves_3m)*EnvGen.kr(Env.asr(40),levelScale:0.5) }.play});

	} .fork
)
( //longer sketch

	~recpath="/Users/michael/tank/THE FUTURE/SC-bounces/";
{ 
	s.prepareForRecord(~recpath++"ending-10-chans-longer.aif",numChannels:10);
	s.sync;
	//s.record(bus:~out,duration:150);
	m.play(~out.index+8,2,0,2, multi:true);
	~tones=[400,450,500,560,600]; ~tones=~tones/2;
	~startFrom.(5304); 
	//~schedule.(5310,{~chd.value(len:20+~gap)});"chd".postln;
	~schedule.(5310,{~chd_long.value(len:20+~gap)});"chd".postln;
	~schedule.(5340,{~klankBus.source=~tones});
	~schedule.(5314,{~klank.play(vol:0.2,fadeTime:30)});
	~schedule.(5314,{~dry.release(51)});
	~klankBus.fadeTime=15;
	~schedule.(5340,{~klankBus.source=(~tones).scramble});//is this happening?
	~schedule.(5344,{~klank.play(vol:0,fadeTime:56)});
	~schedule.(5401,{~locateSecs.(3600-~gap)}); // go back to top
	//~schedule.(5407,~startup);
	~schedule.(5404-10, { ~tones=~tones.collect({|i| i*1.125;}).scramble; ~chd.value; });
	~schedule.(5423,{{PlayBuf.ar(2,~waves_3m)*EnvGen.kr(Env.asr(40),levelScale:0.5) }.play});

	} .fork
)

{ ~tones=~tones.collect({|i| i*1.2;}); ~chd.value; }
