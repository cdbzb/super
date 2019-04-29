( ////////// SAMPLES
	~waves=Buffer.read(s,"/Users/michael/tank/THE FUTURE/SC-bounces/Hayburn.wav");
	~scifi=Buffer.read(s,"/Users/michael/tank/THE FUTURE/SC-bounces/scifi.wav");
	~vo=   Buffer.read(s,"/Users/michael/tank/THE FUTURE/SC-bounces/vo-48.wav");
	~foley=Buffer.read(s,"/Users/michael/tank/THE FUTURE/REFS/Foley-ROUGH-0420.wav");
	~voSections=[13712000,16609800,18673000,23933000,29269000,31628866,35783000,47264000,52933000,55084000,64365000,68146000,77599000];
	~playVoBit={{|index=0| PlayBuf.ar(1,~vo,startPos:~voSections[index*2])}.play};
	{PlayBuf.ar(1,~vo,startPos:(~voSections[0]*48/44.1),rate:(48/44.1))!2i*0.7}.play;
	~fol={|vol=2|PlayBuf.ar(~foley.numChannels,~foley,rate:(48/44.1),startPos:~voSections[2])*vol }.play;
	~fol.set(\vol,1);
	~playVoBit.(0);

)


(
	SynthDef(\triangle,{ |freq len=300 vol=0.05|
		var env=EnvGen.kr(Env.triangle(len));
		var sig = SinOsc.ar(freq,0,env*vol);
		Out.ar(0,sig!2);
	},[1136,0,160]).add
)


~tri={|freq len=300| Synth.new(\triangle,[\freq,freq,\vol,0.005,\len,len])};
a=~tri.(360,len:10);
a.set(\freq,1360);
a.free;
b=~tri.(460);
c=~tri.(520);
d=~tri.(660);
b.set(\freq,900,\vol,0);
a.set(\vol,0);

(
	~playme={ |chord=#[360,460,520,660] len=300 pause=25 vol=1|
		var notes=Array.newClear(chord.size);
		Routine.new({ 
			~chord.do({|item index| 
				index.postln;b[index].postln;
				notes[index]=~tri.(item,len);
				pause.wait;
			});
		}).play;
		notes;
	}
)

( //////little SCORE #1
	{
~cloudchord.([240,288],0.2);
12.wait;
~cloudchord.([360,432],0.2);
40.wait;

		a=~playme.([300,400,450,444,288],100,20);
		a=~playme.([300,400,450,444,288]);
		
		60.wait;
		w={|vol=15| PlayBuf.ar(~waves.numChannels,~waves,loop:1)*vol*EnvGen.kr(Env.asr(20))}.play;
		20.wait;
		{PlayBuf.ar(1,~vo,startPos:(~voSections[0]*48/44.1),rate:(48/44.1))!2*0.7}.play;
		~fol={|vol=0.5|PlayBuf.ar(~foley.numChannels,~foley,rate:(48/44.1),startPos:~voSections[2])*vol }.play;
		//90.wait;
		120.wait;
		a[2].set(\freq,1000);
		120.wait;
		a[1].set(\fr,0);
		~b={|rate=1 vol=2|PlayBuf.ar(~scifi.numChannels,~scifi!2,loop:1, rate:rate)*vol}.play(s,0);
		a=~playme.([360,400,480,544]);
		//~cloudchord.([100,210,320],0.1);

	}.fork
)
a[3].free;
w.set(\vol,5.2);
}
a;

(
	{4.do({|index| b[index].set(\freq,1200)})}.fork;
)

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

~one=Pseq([440,900,400,564,604]); 
~two=Pseq([360,400,450,850,950]);
~thr=Pseq([400,1248,660,1]);
~playmeSlow.(~one);
~playmeSlow.(~two);
~playmeSlow.(~thr);

n={WhiteNoise.ar(0.002)!2}.play(s,0);
n.free;
w={|vol=20| PlayBuf.ar(~waves.numChannels,~waves,loop:1)*vol*EnvGen.kr(Env.asr(20))}.play;
a.set(\vol,45);
a.set(\vol,15);
a.free;
~b={|rate=1 vol=10|PlayBuf.ar(~scifi.numChannels,~scifi!2,loop:1, rate:rate)*vol}.play(s,0);
~d={|rate=1 vol=10|HPF.ar(PlayBuf.ar(~scifi.numChannels,~scifi!2,loop:1, rate:rate)*vol,200)}.play(s,0);
b.free;
~b.set(\rate,8,\vol,2)
~d.set(\rate,8,\vol,1)
~b.set(\rate,8)
~b.set(\rate,0.5,\vol,9);

~c={PlayBuf.ar(1,~vo!2,startPos: (48000*305),rate:(48/44.1)) }.play(s,0);
~c.free;

~cloudchord={|array amp=0.5| var notes=Array.newClear(array.size); array.do({|item index| notes[index]=Synth.new(\cloud,[\fr,item,\amp,amp])}); notes};
l=~cloudchord.([240,288],0.2);
~cloudchord.([360,432],0.2);
n[1].set(\fr,280);

(instrument:\cloud,fr:[240,288]).play;
		(\instrument: \cloud, \fr: [100,120,130]).play;

Synth.new(\cloud,[\fr,288,\amp,0.5]);
Synth.new(\cloud,[\fr,240],\amp,0.5);
Synth.new(\cloud,[\fr,432,\amp,0.1]);
Synth.new(\cloud,[\fr,360],\amp,0.5);
Synth.new(\cloud,[\fr,160,\amp,0.1]);
Synth.new(\cloud,[\fr,100,\amp,0.5]);

Synth.new(\cloud,[\fr,390]);
g.free;


c.free;

b.free;

a.free;
~waves.free;

s.meter;





