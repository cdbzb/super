s.boot
s.meter
o=ServerOptions;
o.numOutputBusChannels = 8;
o.device="USBStreamer";
s.reboot
o, = Server.local.options;

//wind
	//array of speaker locations
		~speakers = [[1,2],[2,3],[5,6]]; 
	// wind location
		~location = [1.5,2.5]
	//this code calculates all the distances and puts in an array
	(
		~distances = Array.new;
		~speakers.do({arg item , index;  
		var dist = ~pythag.value(~location,item);
		~distances=~distances.add(dist);
		})
	)
		~distances.value;
	// correct this - should be pyth distance
		~pythag = {arg one,two; var result; result = (((one[0]-two[0])^2) + (one[1]-two[1])^2)^0.5);} 
		~pythag.value([2,3],[4,5]); //for testing


// crackle and dust
a={Crackle.ar(SinOsc.kr(0.11,0,0.5,1.5),0.3)}.play;
a.free;
{Dust.ar(SinOsc.kr(0.1)*10)}.play;

 
( // array of rands
~rands = { |elements=8,resolution=10,scale=1| 
	a = Array.new(elements);
	b = {
		rrand(0,resolution-1)*(scale/resolution);
	};
	elements.do({a.add(b.value)});
	a.value;
};
)

~rands.value(20);

// crunchy envelope
(
	{
	var rands = [ a.value,a.value, a.value, a.value, a.value, a.value, ];
	var env, envgen;

	a = {
	rrand(1,9)*0.1;
};

env = Env(rands.value,rands.value,-4);
envgen = EnvGen.ar(env , doneAction:2);

Out.ar(1,SinOsc.ar(400,0,envgen));
}.play
)

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
// function version

(
	a={ |freq=440 , lfo , bus=0 , lfreq = 0.05 , env , gate = 1 , release = 10|
		env=EnvGen.kr(Env.asr(0.1,1,release),gate,doneAction:2);
		// lfreq = rrand(5,10)*0.009;
		lfo = SinOsc.kr ( lfreq  , 0 , 0.5 , 0.0 );
		Out.ar ( bus , SinOsc.ar(freq , 0 , lfo*0.2+0.2*env) );
	};
)
b=a.play;
b.set(\freq , 500); // oooh "set"
b.set(\gate , 0);


////////////////////////////////////////////////////////////

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


