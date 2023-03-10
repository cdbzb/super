(
	a=Instr(\modsin).asSynthDef.add;
	SynthDef (\verb ,{ |out=0,room,mix=1| var sig; 
		sig=In.ar(out,1); 
	       	ReplaceOut.ar([out,out+1],FreeVerb.ar(sig, mix:mix, room:0.9) )}).add;
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

s.queryAllNodes;

(
	{
		{SinOsc.ar(Vibrato.kr(DC.kr(400.0),5,0.015,delay:0.4,rateVariation:0.05,depthVariation:0.1) )}.play;
		0.005.wait;
		{SinOsc.ar(Vibrato.kr(DC.kr(500.0),5,0.015,delay:0.4,rateVariation:0.05,depthVariation:0.1) )}.play;

		0.005.wait;
		{SinOsc.ar(Vibrato.kr(DC.kr(600.0),5,0.015,delay:0.4,rateVariation:0.05,depthVariation:0.1) )}.play
	}.fork
)

(
{




