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
~stills.isNil.if{~stills=Stills("/Users/michael/trek/BySection/media/return to tomorrow.mov").current};
//	Song.resources.condition=Condition();
( //Vocoder resources
	Song.carrierBus = Bus.audio(s,5);
	Song.modulatorBus = Bus.audio(s,2);
	Song.sargonCarrier = {
		|p b e att=3 sus=5 rel=6 chord=#[1,2,4,5,6,8] aTune mix=0.5| 
		{  
			var tune = aTune ? p.tune[e.start].list;

			//no preroll adjustment if synthV present
			//var dursWithPreroll = e.synthV.isNil.if{
			//	b[0] + Song.preroll => _.bubble ++ b.drop(1) 
			//}{
			//	b 
			//}; 
			var dursWithPreroll = b[0] + (-1 * e.lag) => _.bubble ++ b.drop(1);
			var freqs = Demand.ar(
				TDuty.ar(dursWithPreroll.dq,1,1),
				1,
				tune.asArray.midicps /.t chord => _.dq
			);
			var car = Gendy1.arWidth( freq: freqs , width:1.10) => Mix.ar(_)
			* Env.linen(att,sus,rel).kr(2,gate:1);
			var saw = Saw.ar(freqs) * 0.1
			=> SplayAz.ar(5,_)
			=> RLPF.ar(_,100,2)
			;//* Env.linen(3,5,6).kr(2,gate:1);
			(1-mix * car min: 0.001  )=> FreeVerb.ar(_,1,0.8)
			+ (mix * saw )
			/10
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
			=> DCompressor.ar( _,  sidechainIn: 0,  sidechain: 0,  ratio: 4,  threshold: -47,  attack: 0.1,  release: 100.1,  makeup: 0.5,  automakeup: 1) /4.9
			 
			
			//+ ( In.ar(carrierBus.index,1) )
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
	Song.vocodeTune = { 
		|p b e rppName amp=0.2 att=3 sus=1 rel=5 dur=10 chord=#[1,2,4,5,6,8] tune out=0 modGain=1 echo=1 mix=0.5|
		var foa = Bus.audio(s,1);
		var synthVbuffer, playSynth;
		( v.isNil or: { v.isRunning.not }.try )
		.if{
			v = Group.new(addAction:\addToTail).register 
		};
		e.rpp.notNil.if{rppName = e.rpp};
		e.synthV.notNil.if{synthVbuffer=e.playbuf};
		playSynth = { 
				Song.vocoderSynth = 
				Synth(\soundInMorph,[
					modulator: Song.modulatorBus.index,
					carrier: Song.carrierBus.index,
					amp:0.32,
					amp:0.2, // WHEN buses are set to 1 channel otherwise comment out!
					amp:amp, 
					dur:dur,
					out:foa.index, // out

					target:v
					//out:out
				]).register;
		};
		case
		{Song.vocoderSynth.isNil}{ playSynth.() }
		{Song.vocoderSynth.isPlaying.not}{ playSynth.() }
		{ true }{ Song.vocoderSynth.set(\dur,dur,\gate,1)}
		 ;
		// restore line above to 'out' to get rid of ambisonics!!
		{
			In.ar(foa.index) 
			=> FoaEncode.ar(_,Song.encoders.omni)
			=> FoaTransform.ar(_, 'press', LFBrownNoise2.ar(1)*pi/1,LFBrownNoise2.ar(1)*pi)
			=> FoaTransform.ar(_,'pressZ',SinOsc.ar(1))
			=> FoaDecode.ar(_,Monitors.decoder)
			*3
		}.play(
			target:v,
			addAction:\addToTail);
		Song.sargonCarrier.(p,b,e,att, sus, rel, chord,tune,mix);
		Song.sargonModulator.(rppName,dur,modGain,echo,synthVbuffer)
	};
	Song.laMer = Song.laMer ?  Buffer.read(s,"~/tank/super/samples/La_Mer_clean.aif".standardizePath);
);
)
