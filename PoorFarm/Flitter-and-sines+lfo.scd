s.boot

(
o = Server.local.options;
o.devices;
o.numOutputBusChannels = 8;
o.device="USBStreamer ";
s.reboot;
)

// play -- run third (record below)
n.start; b.start;

( //def	-- run first
	SynthDef ("sine+lfo" , { |freq=440 , lfo , bus=0 , lfreq = 0.05 |
		// lfreq = rrand(5,10)*0.009;
		lfo = SinOsc.kr ( lfreq  , 0 , 0.5 , 0.0 );
		Out.ar ( bus , SinOsc.ar(freq , 0 , lfo*0.02+0.02) );
	}).add
)

( // run second

n= Task ({
l= Synth.new ("sine+lfo" , [\bus, 0 ,\freq , 400, \lfreq , rrand(5,10)*0.003 ]);
l= Synth.new ("sine+lfo" , [\bus , 1 ,\freq , 500, \lfreq , rrand(5,10)*0.003 ]);
l= Synth.new ("sine+lfo" , [\bus , 2 , \freq , 440, \lfreq , rrand(5,10)*0.003 ]);
l= Synth.new ("sine+lfo" , [\bus, 4 ,\freq , 300, \lfreq , rrand(5,10)*0.003 ]);
l= Synth.new ("sine+lfo" , [\bus , 5 ,\freq , 350, \lfreq , rrand(5,10)*0.003 ]);
l= Synth.new ("sine+lfo" , [\bus , 6 , \freq , 375, \lfreq , rrand(5,10)*0.003 ]);
l= Synth.new ("sine+lfo" , [\bus , 7 , \freq , 675, \lfreq , rrand(5,10)*0.003 ]);
l= Synth.new ("sine+lfo" , [\bus , 3 , \freq , 340, \lfreq , rrand(5,10)*0.003 ]);

 //offfset 
 
l= Synth.new ("sine+lfo" , [\bus, 0 ,\freq , 400, \lfreq , rrand(5,10)*0.003 ]);
rrand(1,4).wait;
l= Synth.new ("sine+lfo" , [\bus , 1 ,\freq , 500, \lfreq , rrand(5,10)*0.003 ]);
rrand(1,4).wait;
l= Synth.new ("sine+lfo" , [\bus , 2 , \freq , 440, \lfreq , rrand(5,10)*0.003 ]);
rrand(1,4).wait;
l= Synth.new ("sine+lfo" , [\bus, 4 ,\freq , 300, \lfreq , rrand(5,10)*0.003 ]);
rrand(1,4).wait;
l= Synth.new ("sine+lfo" , [\bus , 5 ,\freq , 350, \lfreq , rrand(5,10)*0.003 ]);
rrand(1,4).wait;
l= Synth.new ("sine+lfo" , [\bus , 6 , \freq , 375, \lfreq , rrand(5,10)*0.003 ]);
rrand(1,4).wait;
l= Synth.new ("sine+lfo" , [\bus , 7 , \freq , 675, \lfreq , rrand(5,10)*0.003 ]);
rrand(1,4).wait;
l= Synth.new ("sine+lfo" , [\bus , 3 , \freq , 340, \lfreq , rrand(5,10)*0.003 ]);
});

// flitter (add in SIN+LFO below)


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
}});
)


Task ({ //record
  var path="/tmp/";
  var length=60;
	s.recChannels_(8);
	s.recHeaderFormat_("wav");
	s.recSampleFormat_("int16");
	s.prepareForRecord(path++"flitter.wav");
	s.record(path++"flitter.wav");
b.start;	n.start;
length.wait;
s.stopRecording;	
b.stop;
n.stop;
}).play;
)


	
// Sine + lfo [see function version below]  TODO double notes with arbitrary phase relation



 
n.start;


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
