o=Server.local.options;
o.sampleRate=48000;
o.sampleRate;
o.memSize=2**17;
s.sampleRate;
s.reboot;
(//synthdef and setup vo
	SynthDef(\cloud, { arg fr=100, amp=1; var out;  
		fr = Lag.kr(fr,60);
		Out.ar(0,{
			Mix.arFill(20, //number of harmonics
			    { arg x  ; var sig, frq;
				frq=fr;
				//sig = FSinOsc.ar( frq*x ,0,0.01/(x+1) * LFNoise1.kr(18*LFNoise1.kr));//.distort;
				sig = FSinOsc.ar( frq*x ,0,0.01 * LFNoise1.kr(18*LFNoise1.kr)).distort;
				sig = sig+SinOsc.ar( frq ,0,0.01 * LFNoise1.kr(18*LFNoise1.kr)).distort;
				sig = Pan2.ar(sig, LFNoise1.kr(1));
				sig= sig * EnvGen.kr(Env.linen(6,2,99),doneAction: 2);
				//sig=BHiShelf.ar(sig,1200,db: -10);
				sig*amp;
			})
		})}).load;

	~voPauseAmp = { arg pause=1, amp=0.3;
	~buffers = SoundFile.collectIntoBuffers("~/tank/THE FUTURE/VO/*");
		Routine.new({ //arg pause;
			~buffers.do({|item index|
				//item.postln;
				{Out.ar([0,1],PlayBuf.ar(1,item)*amp)}.play;
				pause.wait;
			})
		}).play
	}
)
(//play movie
	{
		Pipe.new("open -a 'QuickTime Player.app' /Users/michael/tank/THE\\ FUTURE/TheFuture_Vimeo_20181025-fast1080.mp4","w" );
		0.3.wait;
		Pipe.new( "osascript ~/scripts/play-front-qt-movie.scpt","w");
		4.wait;
	}.fork;
)

( //sparkle
	{
		(\instrument: \cloud, \fr: 90).play;
		6.wait;
		// a.set(\fr, 110); //PORTAMENTO
		(\instrument: \cloud, \fr: [100,120,130]).play;
		//(\instrument: \cloud, \fr: [240]).play;
		9.wait;
		(\instrument: \cloud, \fr: [300,360], \amp: 0.1).play;
		6.wait;
		(\instrument: \cloud, \fr: [240,240*1.2], \amp: 0.17).play;
		(\instrument: \cloud, \fr: [360,360*1.2], \amp: 0.17).play;
		(\instrument: \cloud, \fr: [270,270*1.2], \amp: 0.07).play;
		(\instrument: \cloud, \fr: [180,180*1.2], \amp: 0.07).play;
		s.meter;
	}.fork
)

(//pattern
{
	var vol = 0.03;
	s.prepareForRecord("/Users/michael/tank/THE FUTURE/SC-Bounces/cloud-chord-2.wav",2);
	s.sync;
	s.stopRecording;
	s.prepareForRecord("/Users/michael/tank/THE FUTURE/SC-Bounces/cloud-chord-1-d.wav",2);
	s.record(duration:200); (\instrument: \cloud, \fr: [240,240*1.2], \amp: 0.17).play;
	s.prepareForRecord("/Users/michael/tank/THE FUTURE/SC-Bounces/cloud-chord-2-d.wav",2);
	s.record(duration:180);(\instrument: \cloud, \fr: [360,360*1.2], \amp: 0.17).play;
	s.prepareForRecord("/Users/michael/tank/THE FUTURE/SC-Bounces/cloud-chord-3-d.wav",2);
	s.record(duration:180);(\instrument: \cloud, \fr: [270,270*1.2], \amp: 0.17).play;
	y=Synth.new(\cloud,[\fr,[240,288],\amp,0.03]);
	
	~pattern=Pbind(	\instrument, \cloud,
		\fr, Pseq([[240,288],[360,432],90,[200,240],[100,120,130]],inf),
		//\amp,Pseries( 0.5,-0.09, 5),
		\amp,Pseries( vol,-0.09*vol/5, 5),
		\dur,Pwhite(12,77,5)
	).play
}.fork
)
~pattern.stop;
s.meter;

(//ocean
	{
		var buf=Buffer.read(s,"/Users/michael/tank/THE FUTURE/Ocean/243591__sonic-ranger__ocean-waves-sea-tide-hayburn-wyke-22-july-14.wav");
		s.prepareForRecord("/Users/michael/tank/THE FUTURE/SC-Bounces/Hayburn.wav");
		s.sync;
		s.record(duration: 600);
		~oceanHayburn={PlayBuf.ar(buf.numChannels,buf)*0.003*
				EnvGen.ar(Env.asr(48,1,20),1,doneAction: 2);
				}.play;
	}.fork
)

(//vo
)

~vo=~voPauseAmp.(28,0.1);
~vo.stop;
~vo.play;
(  //scifi
	{
		var buf=Buffer.read(s,"/Users/michael/tank/THE FUTURE/BOUNCES.scifi-nodelay.wav");
		s.prepareForRecord("/Users/michael/tank/THE FUTURE/SC-Bounces/scifi.wav",2);
		s.sync;
		s.record(duration:200);
		~scifiNoDelay={PlayBuf.ar(buf.numChannels,buf, rate:0.4 )*0.03*
				EnvGen.ar(Env.asr(8,1,20),1,doneAction: 2);
				}.play;

	}.fork
)
~oceanHayburn.free;
Buffer.freeAll;
s.meter;


