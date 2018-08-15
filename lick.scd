s.reboot;
s=Server.local;
(
v=Bus.audio(s,2); //set verb bus
)
(
	SynthDef(\verb,{
		Out.ar([0,1],
		FreeVerb.ar(In.ar(v),mix:1, room:0.7))
	}).add;

	SynthDef (\saws, { arg gate=1,freq=400, amp=0.6, cutoff=1000, bw=0.3, porta=0.08, lfrate=5,  lfrange=4; var sig, lfo;
		freq=Lag.kr(freq, porta); 	//lag the freq
		lfo=SinOsc.kr(lfrate);    	//lfo
		freq=freq+(lfo*lfrange);	//freq mod amnt
		sig = Saw.ar(freq)*amp;		// Oscillator
		cutoff = freq*3.5; 		// key follow
		sig = Resonz.ar(sig, cutoff, bw)*2; 	// filter
		sig = sig*EnvGen.ar(Env.adsr(0.08,0,1,1, 1, 22 ),gate, doneAction: 2);
		Out.ar([0,1,v],sig);
	},[0,0,2.5,0.5]).add;

	t=TempoClock(1);

	a = {arg gain=0, trans=0, tempo=1; 	// the lick 
		PmonoArtic( \saws,
			\scale, Scale.major,
			\degree, Pseq([8,7,6.1,6,5.1,5]-1-8+trans, 1),
			\dur, Pseq([1.5,Pseq([0.125],4)],1),
			\legato, Pseq([1.0, 1, 1, 1, 1, 1]),
			\lfrange, Pseq([0.5,0,0,0,0,1]),
			\amp, 	Pseg( Pseq([0.1,0.2],2), Pseq([2.0],inf))*gain, 
			\tempo, tempo
	)};
)
(
Synth(\verb); // make the verb
)

( 						// loop and accel
	t.tempo_(1);
		6.do({ arg i;
			t.sched(i*2,
				{t.tempo=(t.tempo*1.1);nil;
				b=a.value(1/(3**i),7*i,t.tempo); //pass tempo
				b.play;
				nil;
			});
		});
		
)
s.freeAll;

