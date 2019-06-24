s.reboot;
s.makeWindow;

(
Event.addEventType(\quietSine,{
	SinOsc.ar(~freq,0,0.01,)},
	(freq: 440))
)

(
	~myClass=(
		number:3,
		bounds:{Rect(100,100,100,100)},
		drawme:{|self| 'drawing'++self.number.postln;}
	)
)
~myClass.number_(4);
~myClass.bounds;
~myClass.drawme;

(

// counter Class
var cCounter = {
  var num=0;
  (
    increment: {|self| num = num+1},
    current: { num }
  )
};

var counter1 = cCounter.value;
var counter2 = cCounter.value;

counter2.increment;

counter1.current.postln; // 0 
counter2.current.postln; // 1

)
(type: \quietSine).play;

(
	SynthDef("quietsine",{ arg freq = 440 ;
		Out.ar([0,1],
		SinOsc.ar(freq,0,0.1)
	)
	}).send
)

(
	Event.addEventType(\rando,{
		{SinOsc.ar(~freq+30.rand,0,0.1)}.play
	})
)

a=(\type:\rando,\freq:300).play;
s.boot;
a = ( note: 2).play; 
a=Synth("quietsine");
(
Pbind(
	\instrument, \quietsine,
	\freq, Pseq( [440, 500] ),
	\dur, Pseq( [5,1])
).play
)

(
Pbind(
	\instrument, \quietsine,
	\midinote, Pseq( [60, 50] ),
	\dur, Pseq( [5,1])
).play
)

(
var a, b;
a = Pfunc.new({ [1, 2, 3, 4].choose });
b = a.asStream;            // make a stream from the pattern
5.do({ b.next.postln; });    // print 5 values from the stream
)
(
var a, b, c;
a = Prout.new({
        3.do({ arg i; 3.rand.yield; })
    });
// make two streams from the pattern
b = a.asStream;
c = 10*a.asStream;
4.do({ b.next.postln; });    // print 4 values from first stream
4.do({ c.next.postln; });    // print 4 values from second stream
)
Pbind( \freq, Pseq([440,880]) ).play
t = Pbind( \freq, Pseq([440,880]) ).asStream;
t.next(Event.default);
t.next(Event.default);
t.next(Event.default);
(
var pattern, stream;

pattern = Pbind(
    \abc, Prand([6, 7, 8, 9], inf ),
    \xyz, Pseq([1, 2, 3], 2 ),
    \uuu, 999 // a constant represents an infinite sequence of itself
);

stream = pattern.asStream;

7.do({ stream.next(Event.new).postln; });
)
(
// specifying the pitch in terms of midinote
// see also The pitch model below
Pbind(
    \dur, 0.125,
    \legato, 1.2,
    \midinote, Pseq(#[60, 62, 64, 65, 67, 69, 71, 72], inf)
).play
)
(
var pattern;
pattern = Pbind( \midinote, Pseq(#[60, 62, 64, 65, 67, 69, 71, 72]) );

Pseq([
    Pbindf(pattern, \legato, 0.1, \dur, 0.2),
    Pbindf(pattern, \legato, 1.0, \dur, 0.125),
    Pbindf(pattern, \legato, 2.0, \dur, 0.3)
], inf).play
)

// xxxxxxxxxxxxxxxx

(
	SynthDef("qw",{ arg freq=440, dur=1;
		Out.ar([0,1],
	Saw.ar(freq,  
			(EnvGen.kr
				(Env.linen(0.5,dur,1),doneAction: 2,levelScale: 0.2)
			)
		))}
	).store;
)
(
  
	SynthDef("qs",{ arg freq=440, dur=1;
		Out.ar([0,1],
		SinOsc.ar(freq,0,
			(EnvGen.kr
				(Env.linen(0.5,dur,1),doneAction: 2,levelScale: 0.2)
			)
  		))}
	).store
)

Synth(\qs, freq: 500);
Synth(\qs, [\freq , 300]);

(
a= Pbind(\instrument, Pseq ([\qs,\qw],inf),
	\dur, (1+rand(3)*0.2) ,
	\freq, Prand([300,330,400,440], 5),
)
)



(
Task({
inf.do({
a.play;
rand(7).wait;
})
}).play
)


p = Pmono(\qs, \dur, Pseq([0.4, 2]), \freq, Pseq([400, 500], 1)).play;

rrand(6);
 
Task({
(
x = Synth(\qs, [\dur,5]);

2.wait;
x.set(\freq, 300, \dur, 3);
)
}).play

(
p = Pbind(
    \type, \set,    // This tells it we'll be setting parameters of an existing node...
    \id, x.nodeID,    // ...this tells it whose parameters we'll be setting
    \args, [\freq, \amp],  // and this tells it which parameters to set
    \freq, Pwhite(100, 1000),
    \dur, 0.2,
    \amp, Pseq((1,0.99 .. 0.1), inf)
).play;
)

p.stop
x.free

s.boot;
p=ProxySpace(s).push;
~a.play;
~a = { SinOsc.ar(~pch,0,0.1)};
~a[1] = nil;
		
~pch=[400,700];
~pch.line(100,3);
~pch.fadeTime = 3;
~pch[1]={SinOsc.kr(8,0,30)};


~a.set(\f,1000);
~c = 400;
~c.line(1000,15);

~c.play;
~c.source = 400;

~c = NodeProxy.control(s, 1);
~a.map(\f,~c);

c.source = { SinOsc.kr([10,20] * 0.1, 0, 150, 1300) };
~a.lag(\f,nil);
~a.map(\f, c);
c.source = 400;
c.source = 600;
w = Env.new(Array.rand(3, 400, 1000),Array.rand(2, 0.3, 0.001), -4);
{c.line(1000,3)};

~out = { SinOsc.ar(~a.kr * Rand(1, 2), 0, 0.1) };
~out.play;

~a = 900;
~a.fadeTime = 2;

~a[0] = 300; // now there is a crossfade.
~a[1] = { SinOsc.kr(15, 0, 20) };
~a[2] = { SinOsc.kr(30, 0, 145) };

~a.play;
~pch = 600;

c.env(w);
c.env(w);
w = Env.new(Array.rand(8, 400, 1000),Array.rand(7, 0.03, 0.1));
c.env(w);
c.env(w);



( //creates item then wiggles it... better to build task?

	{ ~freq = 440;
	Out.kr(9,~freq);
	SinOsc.ar((In.kr(9,1)),0,0.2);
}.play;
)

SystemClock.sched(3,
	{~freq={EnvGen.kr(Env.linen(0.2,3,2), levelScale:500 )}.play});
)
~freq;
~freq.line(500,5);
~freq={EnvGen.kr(Env.linen(0.2,3,7), levelScale:500 )}.play
~freq.lineAt(\f, 300, 2)
c.source = 400;
c.gate(1400, 0.1);

c.gate(1000, 0.1);

c.line(1000, 1);


p;
~out = 0;
~out.source;
~out.line;

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxx

s.reboot;

a = NodeProxy.audio(s, 2);
a.play; // play to hardware output, return a group with synths

// setting the source
a.source = { SinOsc.ar([350, 351.3], 0, 0.2) };

// the proxy has two channels now:
a.numChannels.postln;
a.source = { SinOsc.ar([390, 286] * 1.2, 0, 0.2) };

// exceeding channels wrap:
a.source = { SinOsc.ar([390, 286, 400, 420, 300] * 1.2, 0, 0.2) };

// other inputs
a.source = { WhiteNoise.ar([0.01,0.01]) };
a.source = 0;
a.source = \default; // synthDef on server
a.source = SynthDef("w", { arg out=0; Out.ar(out,SinOsc.ar([Rand(430, 600), 600], 0, 0.2)) });
a.source = nil; // removes any object

// feedback
a.source = { SinOsc.ar(a.ar * 7000 * LFNoise1.kr(1, 0.3, 0.6) + 200, 0, 0.1) };
a.source = { SinOsc.ar(a.ar * 6000 * MouseX.kr(0, 2) + [100, 104], 0, 0.1) };

// fadeTime
a.fadeTime = 2.0;
a.source = { SinOsc.ar([390, 286] * ExpRand(1, 3), 0, 0.2) };


// adding nodes
a.add({ SinOsc.ar([50, 390]*1.25, 0, 0.1) });
a.add({ BrownNoise.ar([0.02,0.02]) });

// setting nodes at indices:
a[0] = { SinOsc.ar( 700 * LFNoise1.kr(1, 0.3, 0.6) + 200, 0, 0.1) };
a[1] = { LFPulse.kr(3, 0.3) * SinOsc.ar(500, 0, 0.1) };
a[2] = { LFPulse.kr(3.5, 0.3) * SinOsc.ar(600, 0, 0.1) };
a[3] = { SinOsc.ar([1,1.25] * 840, 0, 0.1) };

// filtering: the first argument is the previous bus content. more args can be used as usual.
a[3] = \filter -> { arg in; in * SinOsc.ar(Rand(100,1000)) };
a[2] = \filter -> { arg in; in * MouseY.kr(0,1) };
a[8] = \filter -> { arg in; in * MouseX.kr(0,1) };
a[4] = \filter -> { arg in; in * SinOsc.ar(ExpRand(1,5)).max(0) };



// setting controls
a.fadeTime = 2.0;
a.source = { arg f=400; SinOsc.ar(f * [1,1.2] * rrand(0.9, 1.1), 0, 0.1) };
a.set(\f, rrand(900, 300));
a.set(\f, rrand(1500, 700));
a.xset(\f, rrand(1500, 700)); // crossfaded setting
a.source = { arg f=400; RLPF.ar(Pulse.ar(f * [1,1.02] * 0.05, 0.5, 0.2), f * 0.58, 0.2) };

// control lags
a.lag(\f, 0.5); // the objects are built again internally and sent to the server.
a.set(\f, rrand(1500, 700));
a.lag(\f, nil);
a.set(\f, rrand(1500, 700));

a.fadeTime = 1.0;

// mapping controls to other node proxies

c = NodeProxy.control(s, 2);
c.source = { SinOsc.kr([10,20] * 0.1, 0, 150, 1300) };
a.map(\f, c);
a[0] = { arg f=400; RHPF.ar(Pulse.ar(f * [1,1.2] * 0.05, 0.5, 0.2), f * 0.58, 0.2) };
c.source = { SinOsc.kr([10,16] * 0.02, 0, 50, 700) };
c.source = { Line.kr(300, 1500, 10) + SinOsc.kr(20 * [1,2], 0, 100) };
a[1] = { arg f; LFPar.ar(f % MouseX.kr(1, 40, 1) * 4 + 360, 0, 0.2) };

// map multiple channels of one proxy to multiple controls of another
// recently changed behaviour!

~a.play;
~a = { arg f=#[400, 400]; LPF.ar(Pulse.ar(f[0] * [0.4,1], 0.2, 0.2), f[1] * 3) };
~a.map(\f, ~c); // multichannel proxy c is mapped to multichannel control of a
~a = { arg f=#[400, 400]; LPF.ar(Pulse.ar(f, 0.2, 0.2), f[1]) };
~a = { arg f=#[400, 400]; Formant.ar(140, f * 1.5, 100, 0.1) };
~c = { SinOsc.kr([Line.kr(1, 30, 10), 1], 0, [100, 700], [300, 700]) };
~c = 400;


c.fadeTime = 5.5;
c.source = { LFNoise0.kr([2.3, 1.0], [100, 700], [300, 1700]) };
c.source = { SinOsc.kr([2.3, 1.0], 0, [100, 700], [300, 1700]) };
c.source = 400;


// behave like a sc2 plug
c.gate(1400, 0.1);
c.gate(1000, 0.1);
c.line(1000, 1);

// direct access
a.lineAt(\f, 300, 2);
a.xlineAt(\f, 600, 0.3);
a.gateAt(\f, 1600, 0.3);


// changing nodeMaps
a.unmap(\f);
n = a.nodeMap.copy;
n.set(\f, 700);
a.fadeToMap(n);
n = a.nodeMap.copy;
n.set(\f, 400);
a.fadeTime = 1.0;
a.fadeToMap(n, [\f]); // linear interpolation to new map: experimental
a.map(\f, c); // restore mapping


// sending envelopes (up to 8 levels)
w = Env.new(Array.rand(3, 400, 1000),Array.rand(2, 0.3, 0.001), -4);
c.env(w);
c.env(w);
w = Env.new(Array.rand(8, 400, 1000),Array.rand(7, 0.03, 0.1));
c.env(w);
c.env(w);

// stop synthesis, then wake up proxies:

a.stop; // stop the monitor
a.play; // start the monitor
a.end;    // release the synths and stop the monitor
c.free;    // free the control proxy c

s.boot;

(  

SynthDef(\event,{ arg freq=440, amp=0.5, pan=0.0;  

	var env; 

	 

	env = EnvGen.ar(  Env([0,1,1,0],[0.01, 0.1, 0.2]),  doneAction:2);  

	

	Out.ar(0,  Pan2.ar(Blip.ar(freq) * env * amp, pan))  

}).add;  

)
(

{

	

	Synth(\event); 

	

	1.0.wait;	//wait for 1 time unit of default tempo, will probably work out to 1 second

	

	Synth(\event); 

	

}.fork; 	//.fork is a computer science term for setting a new process (sequence) in action

(

{

var source; 



source= LFNoise0.ar(10);



[

	source,			//step

	source.lag(0.1)	//step with lag of period; so only gets to target value at end of step

]

}.plot(1.0)

))

(
	var t;
       t 	= TempoClock(1);
	t.schedAbs(0,
		{ arg ... args;
		args.postln;
		
	Synth(\default);
	1.0;
});

t.schedAbs(8, {t.tempo_(2); nil};);
SystemClock.sched(17,{t.clear});
)
(

var u;



u = TempoClock(3.5);



u.schedAbs(0.0, { arg beat, sec; 

		[beat,sec].postln; 

		Synth( \default ,[\note, rrand(60.0,67.0)]);   

		0.5

});



u.schedAbs(8.0, { u.tempo_(2); nil }); // just schedule tempo change



u.schedAbs(12.0, { u.tempo_(7); nil }); // just schedule tempo change



u.schedAbs(17.2, { u.tempo_(1); nil }); // just schedule tempo change



SystemClock.sched(7.0, { u.clear; }); // schedule a stop for 7 seconds from now.

)
