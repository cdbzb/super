s.boot
s.meter
o=ServerOptions;
o.numOutputBusChannels = 8;
o.device="USBStreamer";
s.reboot
o, = Server.local.options;

// flitter


(
a = {	var env, envGen , vol=0.5 , bus ;
	//try a linen instead
	env=Env.perc(0 , 0.02,(rrand(0,4)*0.1)); // dur, lev
	envGen=EnvGen.kr(env,levelScale:vol,doneAction:2);
	bus = rrand(0,7);
 	Out.ar(bus,WhiteNoise.ar(envGen));
};

b= Task ({ var delta;
	loop {
	delta=rrand(0,20)*0.01;
	a.play;
	delta.wait;
};
}).play;
)
	

//TODO task to make flits
//TODO fix flit envelope

// Better
(
[420,440,410,405,402,480,300,320].do ({ arg freq, index ;
	{Out.ar(index,
		SinOsc.ar(freq,0,0.2))}.play;
});
)

(
SynthDef ( "sine" , {
	 |freq=440, amp=0.2 , bus=0 |
		freq=[ 420,440,410,405,402,480,300,320];
		amp =[ 0.2,0.2,0.2,0.1];
		Out.ar(bus,SinOsc.ar(freq,0,amp));
	}).add
)

a= Synth.new("sine",[\freq,400,\bus,0]);
a= Synth.new("sine",[\bus,0]);


// Sine + lfo
(
	SynthDef ("sine+lfo" , { |freq=440 , lfo , bus=0 , lfreq = 0.05 |
		// lfreq = rrand(5,10)*0.009;
		lfo = SinOsc.kr ( lfreq  , 0 , 0.5 , 0.0 );
		Out.ar ( bus , SinOsc.ar(freq , 0 , lfo*0.2+0.2) );
	}).add
)

(
a= Synth.new ("sine+lfo" , [\freq , 400, \lfreq , rrand(5,10)*0.003 ]);
a= Synth.new ("sine+lfo" , [\freq , 500, \lfreq , rrand(5,10)*0.003 ]);
a= Synth.new ("sine+lfo" , [\freq , 440, \lfreq , rrand(5,10)*0.003 ]);
a= Synth.new ("sine+lfo" , [\freq , 340, \lfreq , rrand(5,10)*0.003 ]);
)
a.free

( ~pitches = [420,440,410,405,402,480,300,320]
8.do ({ arg freq,index; Synth.new("sine", [ \freq , ~pitches[index] ])});
)

// trash this prolly
a={SinOsc.ar(420,0,0.2)};
b={SinOsc.ar(440,0,0.2)};
c={SinOsc.ar(410,0,0.2)};
d={SinOsc.ar(405,0,0.2)};
e={SinOsc.ar(402,0,0.2)};
f={SinOsc.ar(480,0,0.2)};
g={SinOsc.ar(300,0,0.2)};
h={SinOsc.ar(320,0,0.2)};
i=[a,b,c,d,e,f,g,h];
{Out.ar(0,i)}.play;


a.free
{Out.ar(0,a)}.play
{Out.ar(1,b)}.play
{Out.ar(2,g[2])}.play


