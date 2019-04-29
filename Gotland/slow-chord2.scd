( ////////// SAMPLES
	~waves=Buffer.read(s,"/Users/michael/tank/THE FUTURE/SC-bounces/Hayburn.wav");
	~scifi=Buffer.read(s,"/Users/michael/tank/THE FUTURE/SC-bounces/scifi.wav");
	~vo=   Buffer.read(s,"/Users/michael/tank/THE FUTURE/SC-bounces/vo-48.wav");
	~foley=Buffer.read(s,"/Users/michael/tank/THE FUTURE/REFS/Foley-ROUGH-0420.wav");
	~voSections=[13712000,16609800,18673000,23933000,29269000,31628866,35783000,47264000,52933000,55084000,64365000,68146000,77599000];
	~playVoBit={{|index=0| PlayBuf.ar(1,~vo,startPos:~voSections[index*2])}.play};
	{PlayBuf.ar(1,~vo,startPos:(~voSections[0]*48/44.1),rate:(48/44.1))!2}.play;
	~fol={|vol=2|PlayBuf.ar(~foley.numChannels,~foley,rate:(48/44.1),startPos:~voSections[2])*vol }.play;
	~fol.set(\vol,1);
	~fol.free;
	~playVoBit.(1);
	DiskIn.ar
	Buffer.cueSoundFile()
	

)


(
	SynthDef(\triangle,{ |freq len=300 vol=0.05|
		var env=EnvGen.kr(Env.triangle(len));
		var sig = SinOsc.ar(freq,0,env*vol);
		Out.ar(0,sig!2);
	},[1136,0,160]).add
)


~tri={|freq| Synth.new(\triangle,[\freq,freq,\vol,0.005])};
a=~tri.(360);
a.set(\freq,1360);
a.free;
b=~tri.(460);
c=~tri.(520);
d=~tri.(660);
b.set(\freq,900,\vol,0);
a.set(\vol,0);

(
	~chord=[360,460,520,660];
	c=Array.newClear(4);
	~playme=Routine.new({
		~chord.do({|item index| 
			index.postln;b[index].postln;
			25.wait;
			b[index]=~tri.(item);
		});
	}).play
)
(
	{4.do({|index| b[index].set(\freq,1200)})}.fork;
)

b[2].set(\freq,1000,\vol,0);b[2].release(5);
b[3].set(\freq,1000,\vol,0);b[3].release(5);
b[2]=~tri.(400);
b[3]=~tri.(600);
b[2]=~tri.(300);
{b[2].set(\freq,1000);3.wait;b[2].set(\vol,0);16.wait;b[2].free;b[2]=~tri.(~chord[2])}.fork;
{b[3].set(\freq,10);3.wait;b[3].set(\vol,0);16.wait;b[3].free;b[3]=~tri.(~chord[3])}.fork;
{b[1].set(\freq,1000);3.wait;b[1].set(\vol,0);16.wait;b[1].free;b[1]=~tri.(~chord[1])}.fork;
{b[0].set(\freq,1000);3.wait;b[0].set(\vol,0);16.wait;b[0].free;b[0]=~tri.(~chord[0])}.fork;
b[2].set(\freq,300,\vol,0.05);

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
a={|vol=20| PlayBuf.ar(~waves.numChannels,~waves)*vol,loop:1}.play;
a.set(\vol,35);
a.set(\vol,15);
a.free;
~b={|rate=1 vol=10|PlayBuf.ar(~scifi.numChannels,~scifi!2,loop:1, rate:rate)*vol}.play(s,0);
~d={|rate=1 vol=10|HPF.ar(PlayBuf.ar(~scifi.numChannels,~scifi!2,loop:1, rate:rate)*vol,200)}.play(s,0);
b.free;
~b.set(\rate,8,\vol,2)
~b.set(\rate,8)

~c={PlayBuf.ar(1,~vo!2,startPos: (48000*305),rate:(48/44.1)) }.play(s,0);
~c.free;

Synth.new(\cloud,[\fr,[240,288]]);
Synth.new(\cloud,[\fr,288]);
Synth.new(\cloud,[\fr,240]);
Synth.new(\cloud,[\fr,432]);
Synth.new(\cloud,[\fr,360]);
Synth.new(\cloud,[\fr,[360,432]]);
g=Synth.new(\cloud);

Synth.new(\cloud,[\fr,390]);
g.free;


c.free;

b.free;

a.free;
~waves.free;

s.meter;





