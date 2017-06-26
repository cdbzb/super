( // set device
o = Server.local.options;
o.numOutputBusChannels = 8;
o.device="USBStreamer ";
s.reboot;
)
s.boot;
s.reboot;
( // triangle synth 43s
SynthDef("mysine",{arg freq = 200, bus = 0, dur = 43; var env, envGen;
	env=Env.triangle(dur: 43); // dur, lev
	envGen=EnvGen.kr(env,doneAction:2,levelScale:0.2);
       	Out.ar(bus,SinOsc.ar(freq,-1,envGen))}).add
)

( // function returns a task (so as you can set the bus!)
f ={ arg bus;
	Task ({ 
		inf.do({
		x=Synth("mysine",[freq: (rrand(300,570)), bus: bus, dur: rrand(1,20)+20]);
		g=rrand(28,49);
		g.wait
		});
	});
});


( // sets a trio  of these in motion - run twice for muchness
t=f.value(bus: 0);
t.play;
u=f.value(bus: 1);
u.play;
v=f.value(bus: [0,1]);
v.play;
)
f.stop

// alternate 2 notes

(
f = { arg bus, offset=0; var one , two, funca, funcb; Task({
	one = 200+offset;
	two = 240+offset;
	funca={arg freq=200+offset; Out.ar(bus, SinOsc.ar(freq,0,0.05))};
	funcb=funca.play;
	inf.do({
		1.wait;
		funcb.set(\freq , two);
		rrand(13,87).wait;
		funcb.set(\freq , one);
		rrand(13,87).wait;
	});
    };)
};

8.do({
t=f.value(bus: (rrand(0,1)), offset: rrand(0,8)*10);
t.start;
}
);
)

//intermodultaion

(
d =   {	arg freq1=300, freq2=400;
	Out.ar(0,SinOsc.ar(freq1,SinOsc.ar(freq2,0,0.3),0.3));
	Out.ar(1,SinOsc.ar(freq2,SinOsc.ar(freq1,0,0.3),0.3));
}
)

d.value(freq1: 300, freq2: 400);

// chord slowly falls

(
	~pitches = [300,400,440,442,475,500];
	~offsets = [0,0,0,0,0,0];
	g={arg offset=0; Out.kr(1,Lag.kr(offset,1000))}.play;
	h=Array.new(6);
	6.do({arg index; h.add({arg offset=0; Out.kr(10+index,Lag.kr(offset,50))}.play)});
	~pitches.do ({arg item , index;
		{SinOsc.ar((item+In.kr(1)+In.kr(index+10)),0,0.1)}.play;
	});
	
)

/// note to self : leaving one still whilst sliding the other is nice
/// also nice with the f stuff above
~deltas=[100,40,2,73,25,-200];
6.do({arg index; h[index].set(\offset , ~deltas[index]);});// goes to same chord
6.do({arg index; h[index].set(\offset , 0)});// goes back
/////// Global offset
g.set(\offset , -21);
g.set(\offset , 21);
(
	~deltas=[100,40,2,73,25,-200];
	z=Task({ inf.do({
		g.set(\offset , -20);
		50.wait;
		g.set(\offset , 21);
		100.wait;
	})});
	z.start;
	y=Task({ inf.do ({
		6.do({arg index; h[index].set(\offset , ~deltas[index]);});// goes to same chord
		500.wait;
		6.do({arg index; h[index].set(\offset , 0)});// goes back
		500.wait;
	})});
	y.start;
)

x=Task({ inf.do ({  //trying to vary the cricket-y thing 
	h[3].set(\offset , 1);
	30.wait;
})});
x.start;

g.set(\offset , 50);
~h3.set(\offset , 20);
~pitches.scramble;


b={rrand(400,500)};
b.value;
x.set(\freq, [200,201,202]);
x.stop
a.value;
{a.value(dur: 200)}.play;
a.play;
s.reboot;
s.meter;


