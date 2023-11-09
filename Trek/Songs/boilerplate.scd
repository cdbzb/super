(
(s.options.device != "Digiface USB (23953833)") .if{
	g = g ? Group.new(target:RootNode(s));
	m = m ? Monitor.new;
	m.play(2,3,0,2,g);
	ServerTree.add({
		g = Group.new(target:RootNode(s));
		m = m ? Monitor.new;
		m.isPlaying.not.if({m.play(2,3,0,2,g)});
		})
};
v = Group(addAction:\addToTail);
Song.currentSong.preroll_(1);
~encoders = ~encoders ?? { (
	omni:FoaEncoderMatrix.newOmni,
	spread:FoaEncoderKernel.newDiffuse
) };
Song.encoders=~encoders;
~stills.isNil.if{~stills=Stills().current};
//	Song.resources.condition=Condition();
( //Vocoder resources
	Song.carrierBus = Bus.audio(s,5);
	Song.modulatorBus = Bus.audio(s,2);
	Song.vocoderRatio = Bus.control(s,1).set(2);
	Song.monitorCarrier = {
		{
			In.ar(Song.carrierBus,1)!5 => ReplaceOut.ar(0, _)
		}.play(Group.after(s.defaultGroup))
	};
	Song.sargonCarrier = { // 5 channels out p.carrierBus
		|p b e att sus rel chord=#[1,2,4,5,6,8] aTune mix=0.5 verb=1 width=1.1 carrierGain=1 enlarge sawFreqRatio| 
		{  
			var tune = aTune ? p.tune[e.start].list;

			//no preroll adjustment if synthV present
			//var dursWithPreroll = e.synthV.isNil.if{
			//	b[0] + Song.preroll => _.bubble ++ b.drop(1) 
			//}{
			//	b 
			//}; 
			var dursWithPreroll = enlarge.isNil.if{
				b[0] + (-1 * e.lag) => _.bubble ++ b.drop(1)
			}{

				b[0] + (-1 * e.lag) => _.bubble ++ b.drop(1)
				++ e.bNext[0..enlarge]
			};

			var freqs = Demand.ar(
				TDuty.ar(dursWithPreroll.dq,1,1),
				1,
				tune.asArray.midicps /.t chord => _.dq
			);
			var car = Gendy1.arWidth( freq: freqs , width:width) => Mix.ar(_)
			* Env.linen(att,sus,rel).kr(2,gate:1);
			var saw = Saw.ar(freqs*sawFreqRatio) * 0.1
			=> SplayAz.ar(5,_)
			// => Splay.ar(_)
			=> RLPF.ar(_,100,2)
			// => RHPF.ar(_ ,100,2)
			// => HPF.ar(_ ,100,2)
			;//* Env.linen(3,5,6).kr(2,gate:1);
			(1-mix * car /* min: 0.001  */ ) => FreeVerb.ar(_,verb,0.8)
			// (1-mix * car => _.abs     ).poll => FreeVerb.ar(_,verb,0.8)
			+ (mix * saw )
			/10
			* carrierGain
			=> _[0..4] //trying to prevent spillover!!
		}.play(s,Song.carrierBus.index)
	};
	Song.sargonModulator = {|rpp dur modGain=1 echo=1 playbuf| { 
			Line.kr(dur:dur,doneAction:2);
			rpp = (rpp.class == VocalRPP).if{
				rpp
			} {
				rpp=Song.resources.at(rpp)
			};
			playbuf.notNil.if{playbuf}{
				PlayBuf.ar( 1,rpp.buffer.()) 
			}
			=> {|i| echo* EchoNone.ar(i,1,0.4,2) +(i * (1-echo)) } * 2
			//=> MoogFF.ar(_,8000,1)
			=> LPF.ar(_,6000)
			* modGain
			//*5	 => SafetyLimiter.ar(_) /5
			=> DCompressor.ar( _,  sidechainIn: 0,  sidechain: 0,  ratio: In.kr(Song.vocoderRatio),  threshold: -47,  attack: 0.1,  release: 100.1,  makeup: 0.5,  automakeup: 1) /4.9
			 
			
			//+ ( In.ar(carrierBus.index,1) )
			// => _[0,1]
	}.play(s,Song.modulatorBus.index) };
	Song.auditionVocoder = {
		Synth(
			\soundInMorph, [
				modulator: s.options.numOutputBusChannels + 9,
				carrier:  s.options.numOutputBusChannels  + 8,
				amp:0.32,
				dur: 999,
				amp:0.2, // WHEN buses are set to 1 channel otherwise comment out!
			]
		)
	};
	Song.vocoderFoa = Bus.audio(s,5);
	
	Song.vocodeTune = { 
		|p b e rppName amp=0.2 att=3 sus=1 rel=5 dur=10 chord=#[1,2,4,5,6,8] tune out=0 modGain=1 echo=1 mix=0.5 verb=1 width=1.1 carrierGain=1 enlarge sawFreqRatio=2|
		var synthVbuffer, playSynth, playAmbiSynth;
		( v.isNil or: { v.isRunning.not }.try ).if{
			v = Group.new(addAction:\addToTail).register 
		};
		e.rpp.notNil.if{rppName = e.rpp};
		( ( (b.sum /*+ 0.5*/) < dur ) and: enlarge.isNil ).if {
			b.sum.asString + dur.asString +"section shorter than default vocoder dur - setting dur to" + ( b.sum /*+ 0.5 */) => _.warn;
			dur = b.sum /*+ 0.5*/
		} ;
		e.synthV.notNil.if{synthVbuffer=e.playbuf};
		playSynth = {  // mono => mono
				Song.vocoderSynth = 
				Synth(\soundInMorph,[
					modulator: Song.modulatorBus.index,
					carrier: Song.carrierBus.index,
					amp:0.32,
					amp:0.2, // WHEN buses are set to 1 channel otherwise comment out!
					amp:amp, 
					dur:dur,
					out:Song.vocoderFoa.index, // out
					// smoothCarrier: t,

					target:v
					//out:out
				]).register.onFree(try{Song.ambiSynth.free});
		};
		playAmbiSynth = { // mono => ambi
			Song.ambiSynth = {
				In.ar(Song.vocoderFoa.index,2) 
				=> Mix.ar(_)
				// => FoaEncode.ar(_,Song.encoders.spread)
				=> FoaEncode.ar(_,Song.encoders.omni)
				=> FoaTransform.ar(_, 'press', LFBrownNoise2.ar(1)*pi/1,LFBrownNoise2.ar(1)*pi)
				=> FoaTransform.ar(_,'pressZ',SinOsc.ar(1))
				=> FoaDecode.ar(_,Monitors.decoder)
				* 3 * \gain.kr(0,0.1).dbamp
			}.play(
				target:v,
				addAction:\addToTail
			).register
		};
		case
            { Song.vocoderSynth.isNil }         { playSynth.();playAmbiSynth.() }
            { Song.vocoderSynth.isPlaying.not } { playSynth.(); playAmbiSynth.() }
            { true }                            { Song.vocoderSynth.set(\dur,dur,\gate,1)} ;
		// restore line above to 'out' to get rid of ambisonics!!
		Song.sargonCarrier.(p,b,e,att, sus, rel, chord,tune,mix, verb, width,carrierGain,enlarge,sawFreqRatio);
		Song.sargonModulator.(rppName,dur,modGain,echo,synthVbuffer)
	};
	Song.laMer = Song.laMer ?  Buffer.read(s,"~/tank/super/samples/La_Mer_clean.aif".standardizePath);
);
)
