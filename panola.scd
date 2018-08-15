s.reboot;
s=Server.local;
(
	v=Bus.audio(s,2); //set verb bus

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
)

	t=TempoClock(1);



	(
		~phrase = Panola("c4_8\\vol{0.1} d e c g#_1\\vol{0.5}");
		~pattern = ~phrase.asPbind(\saws);
		~pattern.play;
	)


	(
		~phrase = Panola("c4_8\\vol{0.1} d e c g#_2\\vol{0.5}");
~pattern = Pmono(
    \saws,
	\cutoff, ~phrase.customPropertyPattern("cutoff"),
    \midinote, ~phrase.midinotePattern+5,
    \amp, Pseg(Pseq([0.1,0.5]),Pseq([2]), -3),
    \dur, ~phrase.durationPattern,
    \legato, ~phrase.pdurPattern,
    \lag, ~phrase.lagPattern,
    \tempo, ~phrase.tempoPattern
	); // instrument as parameter
~player = ~pattern.play;
)
