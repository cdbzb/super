
s.reboot;
( // 1 Defs
	SynthDef(\sinsaw,{ |freq=400,blend=0.5,amp=0.1, wet, gate=1, release | var sig, env; 
	freq = Lag.kr(freq,0.2);
	blend= Lag.kr(blend, 1);
	amp = amp * EnvGen.kr(Env.adsr(0.05,0.01,1,release),gate, doneAction: 2);
	sig = SinOsc.ar(freq, 0, amp);
	sig = sig + Saw.ar(freq, blend*amp);
	sig = FreeVerb.ar(sig, wet, room: 0.7, damp: 0.5);
	Out.ar([0,1],sig);
}).add
)

( // 2 Data 
	var lick;
	c=TempoClock(1,0);
	~part1 = Pbind(
		\instrument, \default,
		\dur , Pseq ([ 1, 0.5, 0.5 ], 3),
		\freq, Pseq ([ 100, 400, 400],3 ) );

	~part2 = {
		SinOsc.ar([333,444,555,999],0,0.05) * 
		EnvGen.kr( Env.triangle ( 4,5 ) ) 
	};
	lick = [4,3,0,1,-4];
	lick = 2 ** ( 1/12) ** lick;
	lick = lick*444; // root
	~part3 =  Pmono( \sinsaw,
		\dur, 0.5, 
		\release, 5,
		\wet, 0.5,
		\blend, Pseq( [ 0.4,0.3 ,0.4, 0.1, 0.0],2),
		\freq, Pseq( lick ));
	~loop = { //riff and sinchord
		~part1.play(c);

		c.sched(2,{~part2.play});
	};
	~chrd = { 
		var sig,  cutoff=2000;
		cutoff=cutoff*Line.kr(1,0,5,doneAction: 2);
		sig = Pulse.ar([250,500,600,650], mul: 0.1 *
			EnvGen.kr(Env.triangle(9,1)));
		sig = LPF.ar(sig,cutoff);
		sig = Mix.ar(sig);
		sig = Pan2.ar(sig, 0.5);
		Out.ar([0,1],sig);
	};

)

~chrd.play;

( // 3 Sequence	 
	{ 
		2.do ({ arg index; 
			c.tempo_(1.5);
			c.sched(0,	{~loop.value});
			c.sched(4.5, 	{c.tempo_(1.6)});
			c.sched(4.5,	{Pset(\amp,0.1, ~part3).play(c)}); 	//lick
			c.sched(5.65,	{Pset(\amp,0.03,~part3).play(c)}); 	//lick echo
			c.sched(6,	{~loop.value}); 
			c.sched(6.31,	{ if ( index==0, {~chrd.play; })});
			c.sched(8,	{~loop.value}); 
			c.sched(10,	{ if ( index==0, {~loop.value})}); 
			16.wait;
		})
	}.fork(c);
)
