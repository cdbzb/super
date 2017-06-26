s.boot
s.meter
(
o = Server.local.options;
o.devices;
o.numOutputBusChannels = 8;
o.device="USBStreamer ";
s.reboot;
)
,<<<<<<< HEAD
o = Server.local.options;

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
		~pythag = {arg one,two; var result; result = (((one[0]-two[0])**2) + ((one[1]-two[1])**2)**0.5);} 
		~pythag.value([2,3],[4,5]); //for testing


// crackle and dust

(
b= {Out.ar(1,Crackle.ar(SinOsc.kr(0.034,0.1,0.5,1.5),0.3))}.play;
c= {Out.ar(0,Crackle.ar(SinOsc.kr(0.03,0,0.5,1.5),0.3))}.play;
)
a={Crackle.ar(SinOsc.kr(0.03,0,0.5,1.5),0.3)}.play;
=======
a={Out.ar(5,Crackle.ar(SinOsc.kr(0.11,0,0.1,1.5),0.01))}.play;
a={Out.ar(6,Crackle.ar(SinOsc.kr(0.11,0,0.1,1.5),0.011))}.play;
>>>>>>> fac33d59b604c8b10b7abfc2d103d9cfb6e55de0
a.free;
{Pan2.ar(Dust.ar(SinOsc.kr(0.07)*10),0)}.play;

 
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

	a = {
	rrand(1,9)*0.1;
};

	b= {
		arg dur = 0.1;
	var rands = [ a.value*dur,a.value*dur, a.value*dur, a.value*dur, a.value*dur, a.value*dur, ];
	var env, envgen;

	env = Env(rands.value,rands.value,-4);
	envgen = EnvGen.ar(env , doneAction:2);
	c = dur;

	SinOsc.ar(400,0,envgen);
}.play;
)


b(dur: 0.1);
b.set(\dur , 5.1);
b.play;
// flitter (add in SIN+LFO below)


(
a = {	var env, envGen , vol=0.1 , bus ;
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
	
// Sine + lfo [see function version below]  TODO doble notes with arbitrary phase relation
(
	SynthDef ("sine+lfo" , { |freq=440 , lfo , bus=0 , lfreq = 0.05 |
		// lfreq = rrand(5,10)*0.009;
		lfo = SinOsc.kr ( lfreq  , 0 , 0.5 , 0.0 );
		Out.ar ( bus , SinOsc.ar(freq , 0 , lfo*0.02+0.02) );
	}).add
)

(
l= Synth.new ("sine+lfo" , [\bus, 0 ,\freq , 400, \lfreq , rrand(5,10)*0.006 ]);
l= Synth.new ("sine+lfo" , [\bus , 1 ,\freq , 500, \lfreq , rrand(5,10)*0.006 ]);
l= Synth.new ("sine+lfo" , [\bus , 2 , \freq , 440, \lfreq , rrand(5,10)*0.006 ]);
l= Synth.new ("sine+lfo" , [\bus, 4 ,\freq , 300, \lfreq , rrand(5,10)*0.006 ]);
l= Synth.new ("sine+lfo" , [\bus , 5 ,\freq , 350, \lfreq , rrand(5,10)*0.006 ]);
l= Synth.new ("sine+lfo" , [\bus , 6 , \freq , 375, \lfreq , rrand(5,10)*0.006 ]);
l= Synth.new ("sine+lfo" , [\bus , 7 , \freq , 675, \lfreq , rrand(5,10)*0.006 ]);
l= Synth.new ("sine+lfo" , [\bus , 3 , \freq , 340, \lfreq , rrand(5,10)*0.006 ]);
)
a.free

//TODO task to make flits
//TODO fix flit envelope

8.do({arg num,index; {Out.ar(index,Dust.ar(0.0+(Rand(1,10)*0.1),0.03),)}.play});


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

a.free
{Out.ar(0,a)}.play
{Out.ar(1,b)}.play
{Out.ar(2,g[2])}.play
