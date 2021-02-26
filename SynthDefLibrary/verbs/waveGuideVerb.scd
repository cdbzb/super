(
SynthDef(\waveGuideVerb,{ |in len=2000 c1=1 c3=10|
	var early,late;
	in = In.ar(in,1);
	//in=Impulse.ar(8);
	early = EarlyRef.ar(in,
		\source.kr([1,1,1],\lag.kr(3)),
		[2,2,2],
		[13,14,15],
		b:\reflectivity.kr(0.97),
		p: \darkness.kr(0),
		n: \reflections.kr(0)
	);
	late = DWGReverbC1C3.ar(
		early=>Mix.ar(_),
		len:len,
		c1:c1,
		c3:c3
	);
	late*\late.kr(0.5)+(early*\early.kr(0.5))+(in*\dry.kr(0))
	=> Out.ar(\out.kr(0),_)
}).add
);

/*

(
	a=Bus.audio(s,1);
	[
		note:Pwhite(0,5),
		out:a.index,
		dur:rrand(0.8,1.1),
		legato:Pwhite(1,2,inf),
		addAction:\addToHead
	].pp;
	b=Synth(\waveGuideVerb,[\in,a]);
	c=Bus.control(s,3);
	{SinOsc.kr([3,2,1].reciprocal).range(0.5,2.8)}.play(s,c);
	b.map(\source,c);
	b.set(\early,0.0); b.set(\dry,0.5);
	b.set(\early,0.5); b.set(\dry,0.1);
	b.set(\late,0.1);
	b.setn(\c1,1,\c3,100,\reflectivity,0.90,\darkness,0.5,\reflections,3);
	b.set(\source,[1.5,3.5,3.5])

)
*/

NamedControl
Control
