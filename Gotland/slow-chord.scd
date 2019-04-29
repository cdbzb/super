(
	~waves=Buffer.read(s,"/Users/michael/tank/THE FUTURE/SC-bounces/Hayburn.wav");
	~scifi=Buffer.read(s,"/Users/michael/tank/THE FUTURE/SC-bounces/scifi.wav");
	~vo=   Buffer.read(s,"/Users/michael/tank/THE FUTURE/SC-bounces/vo-48.wav");
)


(
	SynthDef(\triangle,{ |freq len=300 vol=0.05|
		var env=EnvGen.kr(Env.triangle(len,vol));
		var sig = SinOsc.ar(freq,0,env);
		Out.ar(0,sig!2);
	}).add
)


~tri={|freq| Synth.new(\triangle,[\freq,freq])};
~tri.(360);

b={SinOsc.ar([400,450,950,850,360],0,0.1)}.play
560
b={SinOsc.ar([400,
2**(1/12);

b.free;


Pbind(\instrument, \triangle,\freq,Pwhite(300,900,inf),\dur,Pwhite(30,630,inf)).play;

a={WhiteNoise.ar(0.01)}.play(s,1);
a.free;

~playmeSlow={|chord| Pbind(\instrument,\triangle,\dur,20,\freq,chord,\len,100,\vol,0.005).play};

~one=Pseq([440,900,400,564,604],inf); 
~thr=Pseq([400,1248,660,1],inf);
~two=Pseq([360,400,450,850,950],inf);
~playmeSlow.(~one);
~playmeSlow.(~two);
~playmeSlow.(~thr);

{WhiteNoise.ar(0.008)!2}.play(s,0);
a={|vol=20| PlayBuf.ar(~waves.numChannels,~waves)*vol}.play;
a.set(\vol,35);
a.free;
b={|rate=1|PlayBuf.ar(~scifi.numChannels,~scifi!2,loop:1, rate:rate)*10}.play(s,0);
b.free;
b.set(\rate,2)

c={PlayBuf.ar(1,~vo!2,startPos: (48000*290),rate:(48/44.1)) }.play(s,0);
c.free;

Synth.new(\cloud,[\fr,[240,288]]);
Synth.new(\cloud,[\fr,288]);
Synth.new(\cloud,[\fr,240]);
Synth.new(\cloud,[\fr,[360,432]]);
Synth.new(\cloud);


c.free;

b.free;

a.free;
~waves.free;

s.meter;





