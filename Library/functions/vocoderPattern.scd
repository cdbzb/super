//TODO take out the effect at the end of the function!!
(
~vocoderPattern = { |pattern item|
	~mod? ~mod=Bus.audio(s,1);
	~verb=Bus.audio(s,2);
	~bus.isNil.if (~bus=Bus.audio(s,1));
	pattern <> (out:~bus.index) => _.play;
	{Item(item).playbuf(loop:1) =>CombC.ar(_,1,1,7)*3 }.play(s,~mod.index);
	//~mod.scope;
	x = Synth.new('cepstral-vocoder-bus', [
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

}
)
/*

(
~pattern=[
	//instrument:\sawSynthSustain,
	instrument:\stringyy,
	freq:Pwhite(200,900),
	legato:Pwhite(1,5),
	dur:Pwhite(0.2,2),
	amp:0.1,
].p;
~vocoderPattern.(~pattern,\order)
	)
*/
