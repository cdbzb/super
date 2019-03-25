a=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/AI SOUNDS/*");
~names.(a);
(
	~glitchBus=Bus.control(s,8);

	~glitchme={ |buffer=101 density-0.1|
		//var glitch = EnvGen.ar(Env.step([05,0],[0.5,1]),gate:Dust.ar(density));
		var glitch=0;
		var sig = BufRd.ar(2,buffer, Phasor.ar(0, BufRateScale.ir(buffer))+glitch);
		Out.ar(1,sig);
	}.play;
	)
~glitchme.(a[0]);
a[0];

~glitchme([\buffer,a[0]);
s.meter;
	Server.default=s=Server.local;
//idea: numbers interrupt
	b=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/AI SOUNDS/*");
	
	{ BufRd.ar(2, b[0],LFBrownNoise2.ar(1,0.01) * BufFrames.ir(b[0])) }.play;
	{ BufRd.ar(1, b[0], Phasor.ar(0, BufRateScale.kr(b[0])*[Rand(0.9,1.1),Rand(0.9,1.1)], 0, BufFrames.kr(b[0]))+LFBrownNoise0.kr((LFBrownNoise2.kr(1,mul:0.9,add:0.5)!2),0.5,mul:10000009)) }.play;
