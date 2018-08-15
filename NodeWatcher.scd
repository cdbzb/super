s.boot;

(
	SynthDef(\one,{var sig,env;
		sig = SinOsc.ar(440);
		env = Env.triangle(2,2);
		env = EnvGen.kr(env, doneAction:2);
		Out.ar(0,sig*env);
	}).add;
)
		
( 
	b=Routine({
	a=Synth(\one);
	NodeWatcher.register(a);
	a.onFree({b.next});
	'yielded'.yield;
	a=Synth(\one);
});
)


( 
	b=Routine({
	a=Synth(\one).waitForFree;
	a=Synth(\one);
}).play;
)


(
a=Pbind(\instrument, \default, \dur, Pseq([1,2,3,0],1) , \event, Pfunc({|evt| evt[\dur].postln}));
a.play;
)
/////////// In your Pbind, you can get access to the current event:

(
 Pbind(
  \freq, Pseq([550], 1),
  \event, Pfunc({ |evt|
     evt[\freq].postln;
    })
 ).play
)
a= Pseq([1,2,3,]).asStream;
a.next;

	

		
////////////////////////////
(
b = s.makeBundle(false, {
    a = Group.new(s);    //create a node object
    NodeWatcher.register(a); // register before creating on the server
});
)
a.isPlaying;
s.listSendBundle(nil, b);    //start the node on the server
a.isPlaying;
a.isRunning;
a.run(false);
a.isRunning;
s.freeAll;    //free all nodes
a.isPlaying;
a.isRunning;


c = Condition(false); 
(
fork { 0.5.wait; 
	"started ...".postln; 
	{
		a=Pbind(\instrument, \default, \dur, Pseq([1,2,3],1));
	c.wait;  
	"... and finished.".postln };
)
c.test = true;
c.signal;



// sound example
(
SynthDef(\help_sinegrain,
    { arg out=0, freq=440, sustain=0.05;
        var env;
        env = EnvGen.kr(Env.perc(0.01, sustain, 0.1), doneAction:2);
        Out.ar(out, SinOsc.ar(freq, 0, env))
    }).add;
)


(
var a;
a = Prout({ loop { 1.yield; 2.yield; 7.yield; 10.do { 1.0.rand.yield } }}).asStream;
{
    a.do { |val|
        Synth(\help_sinegrain, [\freq, val * 100 + 300]);
        0.02.wait;
    }
}.fork;
)
