( ///here first
	SynthDef(\distort, { arg out=0, pregain=40, amp=0.2, gate=1;
		    var env;
		    env = Linen.kr(gate, 0.05, 1, 0.1, 2);
		    ReplaceOut.ar(out, (In.ar(out, 2) * pregain).distort * amp);
	}, [\ir, 0.1, 0.1, 0]).add;

	a=Instr(\modsin).asSynthDef.add;
	
	SynthDef (\verb ,{ |out=0,room,mix=1| var sig; 
		sig=In.ar(out,1); 
	       	Out.ar([out,out+1],FreeVerb.ar(sig, mix:mix, room:0.9) )}).add;
)
(
	b=Pmono(a.name,
		\freq, Pseq( [300,200,450,400,425,30,375,385,360,400],inf ),
		\dur, 0.5,
		\tempo, Pseg( Pseq( [ 1,5.5,0.1 ] ), durs: 3,  repeats: inf),
		\width, Pseq( [0.05,0.05,0.05,0.10, 0.05 , 0.02],inf),
	);

	d=Pfx(b, \distort);
	c=Pfx(d, \verb, \mix, 0.4).play;
	
)
( //2nd (one more!)
SynthDef(\twotube,{arg delay1=100, delay2=50, k=0.0, loss=0.999, dur=0.5, pan=0.0; 
var source; 

//k from -1 to 1

source= WhiteNoise.ar(0.5)*EnvGen.ar(Env([1,1,0,0],[(delay1+delay2)/SampleRate.ir,0.0,1.0]));

Out.ar(0,Pan2.ar(TwoTube.ar(source,k,loss,delay1,delay2)*EnvGen.ar(Env([0,1,1,0],[0.001]++((dur-0.001)*[0.4,0.6])),doneAction:2),pan)); 
}).send(s); 
)
( //3rd
t.stop;
k=TempoClock.new;
k.tempo=0.4;
t={

inf.do{

Synth(\twotube,[\delay1, rrand(1000,3000),\delay2, rrand(1000,3000),\loss, rrand(0.99,0.9999),\dur, rrand(3.1,8.0), \pan, rrand(-1,1.0), \k, rrand(0,1.0)]);

0.6.wait;
};

}.fork(k);
)

z=Group.new;
s.meter;
(
	{
		{SinOsc.ar(Vibrato.kr(DC.kr(400.0),5,0.015,delay:0.4,rateVariation:0.05,depthVariation:0.1) )}.play;
		0.005.wait;
		{SinOsc.ar(Vibrato.kr(DC.kr(500.0),5,0.015,delay:0.4,rateVariation:0.05,depthVariation:0.1) )}.play;

		0.005.wait;
		{SinOsc.ar(Vibrato.kr(DC.kr(600.0),5,0.015,delay:0.4,rateVariation:0.05,depthVariation:0.1) )}.play
	}.fork
)

