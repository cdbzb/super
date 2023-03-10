(
	{ 	Vocoder.ar(
		car:
		Pulse.ar([1,3,5,7].df('e-',4)
		+ LFBrownNoise0.kr(2,mul:80)
		,0.1),
		mod:
		SoundIn.ar(),
		num:
		10
	)
	=> CombC.ar(_,1,0.3,2)
}.play
)
(
	{ LPCAnalyzer.ar(SoundIn.ar(),Pulse.ar([1,3,5,7].df(octave:[3,4,5,6]),0.03))*0.1 }.play
)
(
	SynthDef(\vocoder,{
		Vocoder.ar(
			Pulse.ar(\freq.kr(400) + \modulation.kr(0),0.1),
//			SoundIn.ar(),
			In.ar(\in.kr(4)),
			12
		)
		=> Out.ar(\out.kr(0),_)
	}).add;
)
(
	a=Item(\word);
//	a.record
	~modulator=Bus.audio;
	a.play(bus:~modulator.index,loop:1,rate:1);
	b=Synths(\vocoder,\addAction,\addToTail,\freq,[1,3,5,7,12,14].df(octave:4),\in,~modulator.index,\out,[0,1,2,3,0,1]);
	~brown=Bus.control();.play
	{LFBrownNoise0.kr(4,mul:80)=>Out.kr(~brown.index,_)}.play(addAction:\addToHead);
	b.map(\modulation,~brown);
	{In.ar(2)=>CombN.ar(_,1,0.3,1.5,mul:0.5)++Gain.ar(_)=>Out.ar(1,_)}.play(addAction:\addToTail);
	{In.ar(3)=>CombN.ar(_,1,0.3,1.5,mul:0.5)++Gain.ar(_)=>Out.ar(0,_)}.play(addAction:\addToTail);

)
// this may be better to split up and use busses for
//	a.record
(
	a.play
)
a.arm()
(
    a = FloatArray.fill(44100 * 5.0, {1.0.rand2}); // 5 seconds of noise
    b = Buffer.loadCollection(s, a);
)
(
	a=Item(\word).buffer;
	f=Buffer.alloc(s,s.sampleRate/64,b.numChannels);
	f=Buffer.alloc(s,a.numFrames/64,21);
	{
		PlayBuf.ar(a.numChannels,a.bufnum)
		=> Vocoder.control(_,20)
		=> RecordBuf.kr(_,f.bufnum)
	}.play;
//	b.scope;.play
//	~modulator.scope
)
(
//	b=Bus.control(s,20);
//	{WhiteNoise.kr(0.1!b.numChannels)}.play(s,b);
//	{ RecordBuf.kr(Vocoder.control(In.ar(~modulator.index),20),f,recLevel:1000) }.play.dur(1)

)
f.plot
s.plotTree
// this makes a control track with 20 band
g=Item(\word).prepVocoder(20);
SynthDef(\variable,{ 
	var buffer=Buffer(bufnum:bufnum);
	Vocoder.sidechain(
		Saw.ar(\freq.kr(200),0.1),
		g,rate:\rate.kr(2)
	)
	=>Out.ar(\out.kr(),_)}
).add;
(
	~test={|buffer bus|
		{
			Vocoder.sidechain(
//				Saw.ar(\freq.kr(200),0.1),
				In.ar(bus,1),
				buffer,rate:\rate.kr(2)
			)
		}.play
	}
)
SynthDef(\sidechainVocoder,{ |buffer carrier| // buffer bus
	Vocoder.sidechain(
		In.ar(8),
//		In.ar(carrier.index),
		buffer,rate:\rate.kr(2)
	)
	=>Out.ar(\out.kr(),_)}
).add;
(
	[ instrument:\variable,
		buffer:g,
		out:1,
		freq: 333,
		dur:1.5,
		rate:2 ].pp;
	[ freq:611,
		buffer:g,
		instrument:\variable,rate:1 ,dur:2].pp;
	[
		dur:1.5/4,
		lag:[0,0,0,0,0.5,0.5,0.5,0.5].q(inf)/4,
		legato:0.1,
		amp:0.01,

	].pp
)
{ StkShakers.ar(energy:PlayBuf.kr(20,g.bufnum)**4,decay:2)*0.05 }.play
	g=Item(\word).prepVocoder(20);
(
	~carrier=~carrier??Bus.audio(s,4);
	{ StkShakers.ar(energy:PlayBuf.kr(20,g.bufnum)**4,decay:2)*0.05 }.play.dur(12.5);
	a=~test.(g,~carrier);
	{ a.set(\rate,0.6) }.sched(0.1);
	{Impulse.ar([100,365,201,700],0,0.5)
	+ Saw.ar([800,465,301,900],0.1)
	=> Mix.ar(_) 
	=> Out.ar(~carrier,_)}.play;
//	{Saw.ar([200,105,300,333],0.1)=> Mix.ar(_) => Out.ar(~carrier,_)}.play;
)
