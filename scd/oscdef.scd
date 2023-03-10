s.reboot
Server.default=s=Server.internal;
s.queryAllNodes;
r=RootNode.new;
Group.basicNew(s, 1);
f {arg a; ^a*a}

Platform.userExtensionDir; 

s=Server.default;



SynthDef("reverb",{Out.ar(0,CombN.ar(In.ar(0,2),0.1,0.1,4))}).add;

SynthDef("impulses",{Out.ar(0,Impulse.ar([0.9,1.19],0,0.3))}).add;

)

(

g=Group.basicNew(s,1);

Synth.tail(g, "reverb");

Synth.head(g,"impulses");

) 

//where is the reverb? 

(

Synth("impulses");

Synth("reverb");

)
//difference
(SynthDef( "monoSin", { arg freq=440; 
	Out.ar([0,1],SinOsc.ar(freq,0,0.1))}).add
)

a=Synth("monoSin");
a.set([\freq,80]);
b=Synth("monoSin",[\freq,441]);


	{Out.ar([0,1],SinOsc.ar(330,0,0.1)+SinOsc.ar(220,0,0.1))}.play

~ar = EnvGen.kr(Env.linen(0,38,2,1));

(
	SynthDef("sweep", {  arg freq = 440; var line, env;
		line = Env.linen(40,0,0,2);
		env = EnvGen.kr(line, doneAction:2) ;
		Out.ar([0,1],SinOsc.ar((freq*(env/4+1)), 0,0.1));
	}).add
)

a=Synth("sweep");
a=Synth("sweep",[\freq, 300]);

(
	SynthDef("sweep-n-tone",{  arg freq=440; var line, env;
		line = Env.linen(40,0,0,2);
		env = EnvGen.kr(line, doneAction:2) ;
		Out.ar([0,1],SinOsc.ar((freq*(env/4+1)), 0,0.1)+SinOsc.ar(freq,0,0.1));
	}).add
)

a=Synth("sweep-n-tone",[\freq,800]);
a=Synth("sweep-n-tone");

( // cursor tracking 
{Out.ar([0,1], SinOsc.ar(MouseY.kr(50,5000,1),0,0.1))}.play;
{Out.ar([0,1], SinOsc.ar((MouseY.kr(50,5000,1)+(140*MouseX.kr)),  0 ,0.1))}.play;
)
