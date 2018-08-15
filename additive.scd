s.boot;
s = Server.local;
s.boot;
(
	SynthDef(\cloud, { arg fr=100, amp=1; var out;  
		fr = Lag.kr(fr,60);
		Out.ar(0,{
			Mix.arFill(20,
			    { arg x  ; var sig, frq;
				frq=fr;
				sig = SinOsc.ar( x+1*frq ,0,0.01 * LFNoise1.kr(18*LFNoise1.kr));
				sig = Pan2.ar(sig, LFNoise1.kr(1));
				sig= sig * EnvGen.kr(Env.linen(5,60,10),doneAction: 2);
				sig*amp;
			})
		})}).add;


{
	//Pbind(\instrument, \cloud, \dur, 500,  \fr, [90,100,110,120,130]).play
	a = Synth(\cloud,[\fr, 90]);
	1.wait;
	b = Synth(\cloud,[\fr, 100]);
	1.wait;
	c = Synth(\cloud,[\fr, 110]);
	1.wait;
	d = Synth(\cloud,[\fr, 130]);
}.fork

)

Pbind (\instrument, \cloud, \fr, Pseq([90,100,110,130]),\dur, 3).play;

(
{
a=(\instrument: \cloud, \fr: 90).play;
6.wait;
a.set(\fr, 110);
(\instrument: \cloud, \fr: [100,120,130]).play;
9.wait;
(\instrument: \cloud, \fr: [300,360], \amp: 0.1).play;
6.wait;
(\instrument: \cloud, \fr: [200,240], \amp: 0.01).play;
}.fork
)
