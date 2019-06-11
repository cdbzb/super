( //Cue for Walker 2
	a={|vol=0.5|PlayBuf.ar(2,~waves_3m)*vol}.play;
	a.set(\vol,1);
	//~klank.play;
	~startFrom.(3858); //walker 2 enters
	~schedule.(3860,{~chordWave.(vol:0.2)});
	//~startFrom.(4095); //death stinks
	//~schedule.(4102,{~cloudchord.([100,210,320],0.05)});
	//~schedule.(4102,{(\instrument: \fibs, \fr: [4,4.5,5,6,8,9,10]*2*1.2,\amp:0.2).play});
	//~schedule.(4102,{(\instrument:, \fr: [4,4.5,5,6,8,9,10]*2*1.2,\amp:0.2).play});
	~schedule.(4098,{(\instrument: \cloud_staggered, fr: [100,120,150,180]*2*1.2,\amp:0.5).play});
	~schedule.(4105,{~playme.([300,400,450,444,288],90);});
	//~schedule.(4200,)
	//~schedule.(3860,{~playme.(~chords.choose,len:180,pause:30,pan:0.9)}); //play through NodeProxy 
	//~schedule.(3860,{~manualWave.fork}); //play through NodeProxy 
	//~schedule.(3960,{~membrane.play(fadeTime:30)});
)


( //ending CYCLING BACK VERSION
	//setup - buffers
(~waves==nil).if{~waves=Buffer.read(s,"/Users/michael/tank/THE FUTURE/SC-bounces/Hayburn.wav")};
(~waves_3m==nil).if{~waves_3m=Buffer.read(s,"/Users/michael/tank/THE FUTURE/SC-bounces/3m-stereo\ bounce.wav")};
~waves_3m;


//chord	
	//~tones=[400,450,420,500,560,600];
	~tones=[400,450,500,560,600];
	~tones=~tones/2;
	~chd={~tones.do({|item index| {Pan2.ar(SinOsc.ar(item,0,0.002*EnvGen.kr(Env.linen(40,20,35,))),index/2-1)}.play})}; // add arguments for ad and vol
//klank
	~klankBus.source=~tones;
//startup sound
	~startup={(\instrument: \fibs, \fr: [4,4.5,5,6,8,9,10]*2*1.2,\amp:0.2).play};
	//~startup={(\instrument: \cloud_staggered,\fr: [240,288,300,360], amp:0.5).play};
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
