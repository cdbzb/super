~ir=Library.at(\functions,\prep).("/Users/michael/tank/IR/Saane/Small_Factory_Hall/Transformatorhuis_wide.wav" );

(
var verb=Bus.audio(s,2);

SynthDef(\convo_dual_mono,{ |ir bus|
	Out.ar(0,(PartConv.ar(In.ar(verb,2),4096,ir)))
}).add;

SynthDef(\wobbly_stack,{ |fundamental=100 partials=10 outbus=0 ir harms=1 |
	var privateverb=Bus.audio(s,2);
	10.do({ |index|  
		Out.ar(
			privateverb,Pan2.ar( 
				EnvGen.kr(Env.linen(rrand(1,5.0),rrand(20,30),5))*
				Blip.ar(
					LFNoise2.kr(10.2,11+(index*2),fundamental*index+fundamental)
					,harms,0.02)
					,rrand(-1.0,1)))});
	Out.ar(0,(PartConv.ar(In.ar(privateverb,2),4096,ir, mul:0.2)));
	EnvGen.kr(Env.linen(5,30,15),doneAction:2) /// this releases the synth after max possible env
}).add;
)
o=Server.local.options;
o.memSize=8192*16;
s.reboot;
s.meter;
s.makeWindow;
(
~ir=Library.at(\functions,\prep).("/Users/michael/tank/IR/Saane/Small_Factory_Hall/Transformatorhuis_wide.wav" );
	Pbind(	\instrument, \wobbly_stack,
		\dur,Pseq([13,Prand([13,13,13,13,30],inf)]),
		\ir, ~ir,
		//\outbus,~verb,
		\harms,Pseq([1,Pxrand([1,1,1,1,5],inf)]),
		\fundamental, Pseq([100, Prand([160,150]) ,110,Prand([120,140,90])],inf)).play
		)

Routine({
	s.sync;
	Synth.tail(s,\convo_dual_mono,[\ir,~ir,\bus, ~verb]);
	Synth.head(s,\wobbly_stack,[\fundamental,100,\partials,10,\outbus,~verb]);

	10.wait;

	{10.do({ |index | //then blip 
		Out.ar(
			verb,Pan2.ar( 
					EnvGen.kr(Env.linen(rrand(2,6.0),rrand(20,30),5))*
					Blip.ar(
						LFNoise2.kr(10.2,11+(index*2),100*index+100)
						,10,0.2)
						,rrand(-1.0,1)))})
	}.play;
}).play
)
