(
~vocoderPattern = { |pattern item effect out=0 bypass=0 rate=1 amp=0.1 dry=0 inputEffect|
	var environment = ();
	environment.use {
		~modulator=Bus.audio(s,1);
		~verb=Bus.audio(s,2);
		~carrier=Bus.audio(s,1);
		pattern <> (out:~carrier.index) => _.play;
		Item(item).armed.if{ 
			bypass=1 ;
			Item(item).play;
			\recording.postln
		};
		( bypass==0 ).if {
			Item(item);
			{Item(item).playbuf(loop:1,rate:rate) 
			=> ( inputEffect ? {|i|i} )
//			=>CombC.ar(_,1,1,7)*1 
			}.play(s,~modulator.index);
		}{
			{SoundIn.ar()}.play(s,~modulator.index) ;
		};

		( effect.isNil.not ).if{
			~synthOut= ~verb.index 
		}{
			~synthOut= out
		};

		~synth=Synth.new(\busVersion, [
			\carrier,~carrier.index,
			\modulator,~modulator.index,
			//	\modulator,4,
			//	\fftsize,4096,
			\hop,0.25,
			\out,~synthOut,
			//	\out,Effect(FreeVerb.ar(_,0.1,1),inputChannels:1).bus.index,
			//\modBuf, Item(\order).buffer , 
			//default for smooth is *negative* 0.92
			//positive numbers and zero are both interesting
			\smoothCarrier,-0.92 ,
			\pan,[ -1 ].choose,
			\amp,amp,
			\dry,dry
		]);
			NodeWatcher.register(~synth, assumePlaying: true);
			fork{
				while ( {~synth.isPlaying},{1.wait} );
				\freeing_Bus.postln;
				~carrier.free; ~modulator.free;
			};
			(effect.isNil.not).if{
				~effect={ In.ar(~verb.index,2) => effect } =>_.play(s,out,addAction:\addToTail);
			};
		~test = {333.postln};
//		{ In.ar(~verb.index,2)=>Mix.ar(_)=>EarlyRef.ar(_)=>DWGReverbC1C3.ar(_,2000,1,30,mix:0.1,)}.play(s,0,addAction:\addToTail);
	};
	environment;

 })
 (
		~effect = {|i|i[0]=>EarlyRef.ar(_,[SinOsc.kr(0.1),1,1])=>DWGReverbC1C3.ar(_,2000,1,30,mix:0.1,)};
	~lpf = {|i| HPF.ar(i,280)};
		~inputEffect = CombC.ar(_,1,1,7) ;
//~effect = {|i|i!2};
	 ~pattern=[
		 instrument:\sawSynthSustain,
//		 instrument:\stringyy,
		 degree:Pwhite(100,400)/10-8,
		 octave:Pwhite(2,5),
		 rel:5,
		 att:1,
		 legato:Pwhite(1,5),
		 dur:Pwhite(0.2,2),
		 amp:0.1,
	 ].p
	 => 
//	 {|i| i.play;i } =>
	 ~vocoderPattern.(_,\oooh,dry:0.0,bypass:0,effect:~effect,inputEffect:~inputEffect,out:0,rate:rrand(0.9,1.1))
	 //s.meter
//	 ~vocoderPattern.(~pattern,\oooh,bypass:0,effect:~lpf,out:0,rate:rrand(0.9,1.1))
//	 ~vocoderPattern.(~pattern,\oooh,~effect,bypass:0)
//	 => _.test
	 ;
//	 s.plotTreeL
 )
 ~pattern
 Item(\create).arm(bus:0)
 Item(\create).play
 Item

 Item(\create).armed
 Item(\whistling).play
 Item(\oooh).arm(bus:0)
 s.meter
 Item(\oooh).play(s,1)
 a.bus.free;a.verb.free;a.mod.free
 a
