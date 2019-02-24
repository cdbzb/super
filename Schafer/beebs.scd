~beeps=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/BUZZERS TONES ALARMS/*");
~beeps.size;
~names.(~beeps);

~beeps[0].play;

(
	~playem = { |num amp bus| 
		4.do({
			{Out.ar(bus,PlayBuf.ar(1,~beeps[num].bufnum,rrand(0.9,1.1)+LFNoise2.kr(0.02,mul:0.1),loop:1)*LFNoise1.kr(rrand(0.1,0.15))*amp)}.play;
		})
	}
)


~playem.(1,0.2, 1);
~playem.(1,0.2, 0);
~playem.(0,0.2, 1);
~playem.(4,0.2,[0,1]);

s.meter;

(
	4.do({
		{PlayBuf.ar(1,~beeps[0].bufnum,rrand(0.9,1.1),loop:1)*LFNoise1.kr(rrand(0.1,0.15))**2}.play;
	})
)

(
	4.do({
		{PlayBuf.ar(1,~beeps[1].bufnum,rrand(0.9,1.1),loop:1)*LFNoise1.kr(rrand(0.1,0.15))**2*0.4}.play(s,[\out,1]);
	})
)

(
	4.do({
		{PlayBuf.ar(1,~beeps[2].bufnum,rrand(0.9,1.1),loop:1)*LFNoise1.kr(rrand(0.1,0.15))**2*0.4}.play(s,[\out,1]);
	})
)


(
	4.do({
		{PlayBuf.ar(1,~beeps[3].bufnum,rrand(0.9,1.1),loop:1)*LFNoise1.kr(rrand(0.1,0.15))**2*0.4}.play;
	})
)


(
	4.do({
		{PlayBuf.ar(1,~beeps[4].bufnum,rrand(0.9,1.1),loop:1)*LFNoise1.kr(rrand(0.1,0.15))**2*0.4}.play;
	})
)
