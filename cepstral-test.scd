~carrier=Buffer.alloc(s,4096);
(
~bus.isNil.if (~bus=Bus.audio(s,1));
[
	out:~bus.index,
	//instrument:\sawSynthSustain,
	instrument:\stringyy,
	freq:Pwhite(200,900),
	legato:Pwhite(1,5),
	dur:Pwhite(0.2,2),
].pp;
	{RecordBuf.ar(In.ar(~bus.index,1),~carrier.bufnum);0}.play;
~modulator=Item(\order).buffer;

//Synth(\localBufferMorph,[0,modBuf:~modulator,carBuf:~carrier]
x = Synth.new(\localBufferMorph, [
		\out,~verb.index,
		\modBuf, Item(\order).buffer , 
		\carBuf, ~carrier,
		//default for smooth is *negative* 0.92
		//positive numbers and zero are both interesting
		\smoothCarrier,-0.92 ,
		\pan,[ 0,1 ].choose,
		\amp,2,
	]);
);
)
{ In.ar(~verb.index,1)=>FreeVerb.ar(_,0.2,1)}.play(s,1);
s.plotTree

(
~mod? ~mod=Bus.audio(s,1);
~verb=Bus.audio(s,2);
 ~bus.isNil.if (~bus=Bus.audio(s,1));
[
	out:~bus.index,
	//instrument:\sawSynthSustain,
	instrument:\stringyy,
	freq:Pwhite(200,900),
	legato:Pwhite(1,5),
	dur:Pwhite(0.2,2),
	amp:0.1,
].pp;
//{ In.ar(~verb.index,1)=>FreeVerb.ar(_,0.2,1)}.play(s,1);

//modulator is SoundIn
//~mod=Bus.audio(s,1);
//Item(\order).play(s,~mod);
{Item(\order).playbuf(loop:1) =>CombC.ar(_,1,1,7)*3 }.play(s,~mod.index);
//~mod.scope;
x = Synth.new(\busVersion, [
	\carrier,~bus.index,
	\modulator,~mod.index,
//	\modulator,4,
//	\fftsize,4096,
	\hop,0.25,
	\out,~verb.index,
//	\out,0,
//	\out,Effect(FreeVerb.ar(_,0.1,1),inputChannels:1).bus.index,
	//\modBuf, Item(\order).buffer , 
	//default for smooth is *negative* 0.92
	//positive numbers and zero are both interesting
	\smoothCarrier,-0.92 ,
	\pan,[ -1 ].choose,
	\amp,0.2,
]);
{ In.ar(~verb.index,2)=>Mix.ar(_)=>EarlyRef.ar(_)=>DWGReverbC1C3.ar(_,2000,1,30,mix:0.1,)}.play(s,0,addAction:\addToTail);
 );
~verb.scope
Bus.audio
s.plotTree
x.free
s.plotTree
~bus.scope
Item(\order).buffer.plot
~modulator.play
~carrier.plot
~carrier=Buffer.fill()
~carrier.play
s.options.memSize_(2**18)
s.reboot
2**16
(
Pproto({
	~item=Item(\order);
	~modulatorBus=(type:\audiobus,);
	~carrierBus=(type:\audiobus,);
	~vocoder = (type:\on,instrument:\busVersion,carrier:~carrierBus,modulator:~modulatorBus).yield;
},
[
	rate:[1,0.8].q(inf),
	out:Pwhite(0,3),
	it:Pfunc({|e|e.item.play(rate:e.rate,out:e.out,)}),
	dur:3,
].p

	).play
)
(
[
	vocoder:Synth(\busVersion,[]),
].pp
)
(
a=LambdaEnvir((
	carrier:Bus.audio,
	modulator:Bus.audio,
	vocoder:{ Synth(\busVersion,[0,~carrier.index,~modulator.index]) },
	out:0,
	pattern:{ [
		degree:Pwhite(0,10),
		octave:Pwhite(2,4),
		legato:4,
		out:~carrier.index,
		amp:0.2,
		instrument:\stringyy,
	].p },
//	item:{Item(\order).play(s,~modulator.index,loop:1)},
	item:{
//		Item(\order).play(out:0.index,loop:1)
//		Item(\order).play(out:~modulator.index,loop:1);
//		Item(\order).play(out:0,loop:1);
		{Item(\order).playbuf(loop:1) =>CombC.ar(_,1,1,7)*3 }.play(s,~modulator.index);
	},
	play:{
		~item;
		~carrier.index.postln;
		~pattern.play;
		~vocoder;
		//~carrier.scope;
		~modulator.scope

	},
))
//s.plotTree;
)
~modulator=Bus.audio
a.vocoder
a.pattern.play
a.item
(
	~pattern=[
		//instrument:\sawSynthSustain,
		instrument:\stringyy,
		freq:Pwhite(200,900),
		legato:Pwhite(1,5),
		dur:Pwhite(0.2,2),
		amp:0.1,
	].p;
~vocoderPattern = { |pattern item|
	~mod? ~mod=Bus.audio(s,1);
	~verb=Bus.audio(s,2);
	~bus.isNil.if (~bus=Bus.audio(s,1));
	pattern <> (out:~bus.index) => _.play;
	{Item(item).playbuf(loop:1) =>CombC.ar(_,1,1,7)*3 }.play(s,~mod.index);
	//~mod.scope;
	x = Synth.new(\busVersion, [
		\carrier,~bus.index,
		\modulator,~mod.index,
		//	\modulator,4,
		//	\fftsize,4096,
		\hop,0.25,
		\out,~verb.index,
		//	\out,0,
		//	\out,Effect(FreeVerb.ar(_,0.1,1),inputChannels:1).bus.index,
		//\modBuf, Item(\order).buffer , 
		//default for smooth is *negative* 0.92
		//positive numbers and zero are both interesting
		\smoothCarrier,-0.92 ,
		\pan,[ -1 ].choose,
		\amp,0.2,
	]);
	{ In.ar(~verb.index,2)=>Mix.ar(_)=>EarlyRef.ar(_)=>DWGReverbC1C3.ar(_,2000,1,30,mix:0.1,)}.play(s,0,addAction:\addToTail);

 })
 ~vocoderPattern.(~pattern,\order)
