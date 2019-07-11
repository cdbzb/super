~noiseFuu= SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/new-*") ;
~bus=Bus.audio(s,8);
~channels=Array.series(12,~bus.index);
m=Monitor.new.playN(~speakers,1,~channels,fadeTime: 3.0.rand,target:s);
~swapper={m.playN(~speakers,1,~channels.scramble,fadeTime: 30.0)}
~test={m.playN(6!8,1,~channels,fadeTime:40)};
~rando={m.playN((rrand(2!7,9)++8).scramble,1,~channels)};
({
	s.prepareForRecord("/Users/michael/tank/SchaferHouse/noise-fu-spinning.aif",numChannels:8);
	s.sync;
	s.record(bus:~speakers[0]);
	m.playN;
	p={ PlayBuf.ar(8,~noiseFuu[0],doneAction:2)*1 }.play(s,~bus);
	10.wait;
	4.do{~swapper.();rrand(15,22).wait;'swap'.postln;
            ~rando.();rrand(15,22).wait;'rando'.postln};
	~test.();'test'.postln; 5.wait; p.release(57) ;
		{ SinOsc.ar([400,360,300,280,440,450,240,340],0,0.01)*EnvGen.kr(Env.linen(40,60,30)) }.play(s,~speakers[0]);
		150.wait;
		s.stopRecording;
}.fork);

s.freeAll;
m.isPlaying;
~swapper.();
m.playN;
m;
rrand(2!8,9);
~rando.();


		f.release(70);
		{ SinOsc.ar([400,360,300,280,440,450,240,340],0,0.01)*EnvGen.kr(Env.linen(40,55,20)) }.play(s,~speakers[0]);
		50.wait;
		~playOneNumber.();
		50.wait;
