~duration = {|from to| to.asFloat.asSeconds - from.asFloat.asSeconds};

~circle = {
};
~dotted = 	{ | dur |
	{ 
		Dust.ar(50) 
		=>Decay.ar(_,0.0001)
		=>TwoTube.ar(_,loss:0.8,d1length:rrand(20,30))
		=>MoogFF.ar(_,LFBrownNoise1.kr(2).range(4700,6000))
		=>Pan2.ar(_,0.5,0.7)
	}.play(s,0) .dur(dur)
};
~drawLine = {| start end | Reaper.sched(start, {~dotted.value(~duration.(start, end) )})};
~record = { | name, length |
	g = Group.after(1);
	b = Buffer.alloc(s, 65536, 2);
	b.write("~/tank/Leverage/SC".standardizePath +/+ name.asString ++ ".wav", "wav", "int24", 0, 0, true);
	// create the diskout node; making sure it comes after the source
	d = Synth.tail(g, "diskout2", [\bufnum, b]);
	fork{ 
		length.wait ;
		d.free; 
	b.close;
	b.free;
	}
	
};

~myFree = {
	|vsti|
	s.freeMyDefaultGroup;
	fork{
		//s.latency.wait;
		TempoClock.all.do(_.clear);
		SystemClock.do(_.clear);
	};
	// Alga.parGroups[s] = AlgaParGroup(s.defaultGroup);
	~vstRegistry.do{|i| 16.do{|x| i.midi.allNotesOff(x)}};
	Reaper.stop;
	try{ Song.resources.select{|i| i.isKindOf(Node)}.do(_.release)};
	Trek.transitionGroup.release;
	// g=Group.new
};

SynthDef(\suddenGrowth, {
    arg out=0, startFreq=100, endFreq=400, len=0.5, amp=0.5;
    var sig, env, freqEnv;

    freqEnv = Env( [startFreq, endFreq], len, \exp).kr(0)
	+ LFBrownNoise1.ar(50, mul:5)
	;
    // Main oscillator
    SinOsc.ar(freqEnv 
		// + 
		// ( LFBrownNoise2.ar(5) *80 )
	)
    // Add some complexity with FM synthesis
    + SinOsc.ar(freqEnv * 1.5, 0, 0.3)
    + PinkNoise.ar(0.1)
    * Env.perc(0.01,  len * 1.5, curve: 2).kr(2)
	* amp
    => Out.ar(out, _)
}).add;




SynthDef(\growingBalloonRub, {
    arg out=0, freq=500, growthTime=2, pressure=0.7, amp=0.5;
    var sig, env, freqEnv, noiseEnv, friction;

    // Frequency envelope: gradual exponential growth
    freqEnv = EnvGen.ar(
        Env( [freq, freq * 2.5], [growthTime], \exp)
    );

    // Amplitude envelope: slow attack, slow decay
    env = EnvGen.ar(
        Env.perc(growthTime * 0.3, growthTime * 0.7, curve: 2),
        doneAction: 2
    );

    // Noise envelope: fluctuating pressure
    noiseEnv = LFNoise1.kr(10).range(0.5, 1) * pressure;

    // Friction sound
    friction = (BPF.ar(
        WhiteNoise.ar(),
        freqEnv * (LFNoise1.kr(5).range(0.95, 1.05)),
        0.1
    ) * noiseEnv).tanh;

    // Resonant body sound
    sig = SinOsc.ar(freqEnv) * env * 0.3;

    // Combine friction and resonance
    sig = (friction + sig) * env;

    // Add some squeaking
    sig = sig + (SinOsc.ar(freqEnv * 2) * env * noiseEnv * 0.2);

    // Output
    Out.ar(out, Pan2.ar(sig * amp, LFNoise1.kr(2).range(-0.3, 0.3)));
}).add;

~dotted2 = 	{ | dur env pan |
	{ 
		Dust.ar(50) 
		=>Decay.ar(_,0.0001)
		=>TwoTube.ar(_,loss:0.8,d1length:rrand(20,30))
		=>MoogFF.ar(_,
			// LFBrownNoise1.kr(2).range(4700,6000) +
			// ~interestEnv.kr* 4000,
			env.kr(0).poll,
			gain: 3
		)
		=>Pan2.ar(_,pan,0.7)
	}.play(s,0) .dur(dur)
};
~drawLineEnv = {| start end env pan | Reaper.sched(start, {~dotted2.value(~duration.(start, end), env, pan )})};
