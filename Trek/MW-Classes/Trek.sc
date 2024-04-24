Trek {
	classvar <>cast, <path, <>presets, <keys, <>synful1, <>synful2, <>strum1, <>strum2, <>piano;
	classvar <condVar, <>transitions, transitionGroup, <>faders;
	classvar carrierBus, modulatorBus, vocoderRatio ,monitorCarrier, sargonCarrier, auditionVocoder, vocoderFoa, vocodeTune, laMer, vocoderGroup, sargonModulator;

	*initClass {
		path = this.filenameSymbol.asString.dirname.dirname +/+ "/Songs";
		cast = try{ Object.readArchive(path +/+ "trek_cast") } ? ();
		presets = try{ Object.readArchive(path +/+ "trek_presets") } ? MultiLevelIdentityDictionary.new();
		transitions = Order();
		keys = [\visual, \rescue, \transporter, \chamber1, \panel1, \panel2, \smallChamber, \chamber, \briefing, \theyUsed, \song, \song2, 'this formnula', \three, \silverLake, \chapelForgets, \thousand, \sickBay, \medical, \laboratory, \MandT, \MandT2, \ending];
		ServerTree.add({transitionGroup = Group.after(Server.default.defaultGroup).register});
		transitions = keys.collect{ () };
		faders = nil ! keys.size;
		// CmdPeriod.add({transitionGroup = Group.after(Server.default.defaultGroup).register});
		// vocoder 
	}
	*save {
		cast.writeArchive(path +/+ "trek_cast");
		presets.writeArchive(path +/+ "trek_presets")
	}
	*put { |who voice preset|
		^presets.put(who,voice,preset)
	}
	*open{|index|
		
		"vim.cmd('e " + this.allTheSongs[index] + "')" 
		=> SCNvim.luaeval(_)
	}
	*load {|index|
		this.allTheSongs[index].load
	}
	*at {|...args|
		^presets.at(*args)
	}
	*allTheSongs {
		^this.path +/+ "*.scd" 
		=> _.pathMatch 
		=> _.select{|i| "[0-9]+".matchRegexp(i) }
	}
	*song{|i|
		i.isInteger.if{
			^this.allTheSongs[i]
		}{
			^keys.indexOf(i) => this.allTheSongs[_]
		}
	}
	*prepare{
		fork{
			Song(\trashme,[]).current;
			(Trek.piano).isNil.if{this.pf};
			(Trek.strum1).isNil.if{this.strum};
			(Trek.synful1).isNil.if{this.synful};
			Trek.synful2.condition.wait;
			\VSTIS_loaded.postln;
			[strum1, strum2].do{|i| i.syn.run(false)};
			this.loadAll;
			this.loadTransitions
			// this.allTheSongs.do({ |i| defer{ i.load }; 1.wait})
		}
	}
	*loadTransitions{
		path +/+ "transitions.scd" => _.load
	}
	*loadSongs{|array|
		fork{
			array.do{|i x|
				condVar = CondVar();
				defer{ File.readAllString(this.allTheSongs[ i ]) ++ "; Trek.condVar.signalOne" => _.interpret };
				condVar.wait;
				0.25.wait;
				x.debug("loaded!");
			}
		}
	}
	*loadAll{
		fork{
			this.allTheSongs.do{|i x|
				condVar = CondVar();
				defer{ File.readAllString( i ) ++ "; Trek.condVar.signalOne" => _.interpret };
				condVar.wait;
				x.debug("loaded!");
				0.25.wait;
			}
		}
	}

	*playSong{|num cursor=0 scroll=true trimEnd=0| //use cursor -2 to play last two sections
		cursor = cursor ? 0;
		Song.songs.at(keys[num]).current;
		scroll.if{Song.makeScroll};
		(cursor < 0).if{ cursor = Song.sections + cursor };
		Song.cursor_(cursor);
		Song.playRange(cursor, Song.sections - 1 - trimEnd);
		^Server.default.latency + 0.1 + Song.preroll + (cursor .. (Song.sections - 1 - trimEnd)).collect{|i| Song.secDur[i]}.sum ;
		// Song.durTillEnd //return time till end
	}

	*editFile{|num|
		var cmd = "vim.cmd('edit" + this.allTheSongs[num] + "')";
		SCNvim.luaeval(cmd)
	}

	*transitionGroup {
		( transitionGroup.notNil and: try{transitionGroup.isRunning} ).not.if{ transitionGroup = Group.after(Server.default.defaultGroup).register };
		^transitionGroup
	}

	*playTransition { |num cursor func trimStart=0 trimEnd=0 lag=0| // lag is before transition
		func.notNil.if{ transitions[num].put(\func, func) };
		trimStart.notNil.if{ transitions[num + 1].put(\start, trimStart) };
		trimEnd.notNil.if{ transitions[num].put(\trimEnd, trimEnd) };
		lag.notNil.if{ transitions[num + 1].put(\lag, lag) };
		fork{
			this.playSong(num, cursor, trimEnd: trimEnd ) + lag => _.wait;
			transitions[num].func ? 0 => _.wait;
			this.playSong(num + 1, trimStart ? 0); //needToCall "makeScroll" on the song!!
		}
	}

	*setTransition { |num cursor func trimStart=0 trimEnd=0 lag=0 play=false| // lag is before transition
		func.notNil.if{ transitions[num].put(\func, func) };
		trimStart.notNil.if{ transitions[num + 1].put(\start, trimStart) };
		trimEnd.notNil.if{ transitions[num].put(\trimEnd, trimEnd) };
		lag.notNil.if{ transitions[num + 1].put(\lag, lag) };
		^Message(Trek,\playRange,[num, cursor, 2])
		// ^[num, cursor] // => Trek.playRange(*_)
	}

	*play {|array|
		this.playRange(*array)
	}

	*playRange { |num cursor numSections=1| 
		var needLoad;
			needLoad = (num..(num + numSections)).select{|i| Song.songs[Trek.keys[i]].isNil};
			( needLoad.size!=0 ).if{ ^this.loadSongs(needLoad) };
		fork{
			transitionGroup.release;Server.default.sync;
			faders[num].();
			numSections.do{|i| 
				var section = num + i;
				var start = (i == 0).if{ cursor }{ transitions[section].start};
					this.playSong(section, start, trimEnd: transitions[section].trimEnd ? 0) + (transitions[section+1].lag ? 0) => _.wait;
					transitions[section].func.() ? 0 => _.wait
			}
		}
	}
	*playAll {
		var needLoad;
		needLoad = (0..( keys.size - 1 )).select{|i| Song.songs[Trek.keys[i]].isNil};
		( needLoad.size!=0 ).if{ ^this.loadSongs(needLoad) };
		Song.scrollOn = true;
		fork{
			transitionGroup.release;Server.default.sync;
			faders[0].();
			keys.size.do{|key section| 
				var start = transitions[section].start ? 0;
				Trek.editFile(section);
				this.playSong(
					section,
					start,
					trimEnd: transitions[section].trimEnd ? 0
				).wait; 
				(
					transitions[section+1].notNil.if{
					transitions[section + 1].lag ? 0
				}).wait;
				(
					transitions[section].func.() ? 0 
				).wait
			}
		}
	}

	*pf {
		( piano.isNil or: try{ piano.syn.isPlaying.not } ).if {
			piano = PF();
			Song.currentSong.piano = piano;
		}{
			Song.currentSong.piano = piano;
		};
		// Song.resources.condition=Condition();
		// Song.resources.infrastructure = {
		// 	FunctionList.new.array_([
		// 		( currentEnvironment.at(\piano).isNil or: try{ currentEnvironment.at(\piano).syn.isPlaying.not } ).if
		// 		(Trek.piano.isNil or: try{ Trek.piano.syn.isPlaying.not }).if {
		// 			Song.currentSong.piano = Trek.piano = PF();
		// 		},
		// 		{ fork {
		// 			while( {
		// 				Trek.piano.controller.loaded.not;
		// 			},{0.05.wait});
		// 			Song.resources.condition.test_(true).signal
		// 		}}
		// 	]).value
		// }.inEnvir;

	}
	*strum {
		( strum1.isNil or: try{ strum1.syn.isPlaying.not } ).if {
			strum1 = AAS_Strum();
			strum2 = AAS_Strum();
			Song.currentSong.strum1 = strum1;
			Song.currentSong.strum2 = strum2;
		}{
			Song.currentSong.strum1 = strum1;
			Song.currentSong.strum2 = strum2;
		};
		// Song.resources.condition=Condition();
		// Song.resources.infrastructure = {
		// 	FunctionList.new.array_([
		// 		( currentEnvironment.at(\strum1).isNil or: try{ currentEnvironment.at(\strum1).syn.isPlaying.not } ).if
		// 		(Trek.strum1.isNil or: try{ Trek.strum1.syn.isPlaying.not }).if {
		// 			Song.currentSong.strum1 = Trek.strum1 = AAS_Strum();
		// 			Song.currentSong.strum2 = Trek.strum2 = AAS_Strum();
		// 		},
		// 		{ fork {
		// 			while( {
		// 				Trek.strum2.controller.loaded.not;
		// 			},{0.05.wait});
		// 			Song.resources.condition.test_(true).signal
		// 		}}
		// 	]).value
		// }.inEnvir;

	}
	*synful {
		( synful1.isNil or: try{ synful1.syn.isPlaying.not } ).if {
			synful1 = Synful();
			synful2 = Synful();
			Song.currentSong.synful1 = synful1;
			Song.currentSong.synful2 = synful2;
		}{
			Song.currentSong.synful1 = synful1;
			Song.currentSong.synful2 = synful2;
		};
		// Song.resources.condition=Condition();
		// Song.resources.infrastructure = {
		// 	FunctionList.new.array_([
		// 		( currentEnvironment.at(\synful1).isNil or: try{ currentEnvironment.at(\synful1).syn.isPlaying.not } ).if
		// 		(Trek.synful1.isNil or: try{ Trek.synful1.syn.isPlaying.not }).if {
		// 			Song.currentSong.synful1 = Trek.synful1 = Synful();
		// 			Song.currentSong.synful2 = Trek.synful2 = Synful();
		// 		},
		// 		{ fork {
		// 			while( {
		// 				Trek.synful2.controller.loaded.not;
		// 			},{0.05.wait});
		// 			Song.resources.condition.test_(true).signal
		// 		}}
		// 	]).value
		// }.inEnvir;
	}

	*vocoder {
		vocoderGroup = vocoderGroup = Group(addAction:\addToTail);
		carrierBus = Bus.audio(Server.default,5);
		modulatorBus = Bus.audio(Server.default,2);
		vocoderRatio = Bus.control(Server.default,1).set(2);
		monitorCarrier = {
			{
				In.ar(Song.carrierBus,1)!5 => ReplaceOut.ar(0, _)
			}.play(Group.after(Server.default.defaultGroup)).run(false)
		};
		sargonCarrier = { // 5 channels out p.carrierBus
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
		}.play(Server.default, carrierBus.index)
	};
	sargonModulator = {|rpp dur modGain=1 echo=1 playbuf| { 
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
		}.play(Server.default, modulatorBus.index) 
	};
	auditionVocoder = {
		Synth(
			\soundInMorph, [
				modulator: Server.default.options.numOutputBusChannels + 9,
				carrier:  Server.default.options.numOutputBusChannels  + 8,
				amp:0.32,
				dur: 999,
				amp:0.2, // WHEN buses are set to 1 channel otherwise comment out!
			]
		)
	};
	vocoderFoa = vocoderFoa ? Bus.audio(Server.default,5);
	
	vocodeTune = { 
		|p b e rppName amp=0.2 att=3 sus=1 rel=5 dur=10 chord=#[1,2,4,5,6,8] tune out=0 modGain=1 echo=1 mix=0.5 verb=1 width=1.1 carrierGain=1 enlarge sawFreqRatio=2 durRel=0 gain=1|
		var synthVbuffer, playSynth, playAmbiSynth;
		( vocoderGroup.isNil or: { vocoderGroup.isRunning.not }.try ).if{
			vocoderGroup = Group.new(addAction:\addToTail).register 
		};
		e.rpp.notNil.if{rppName = e.rpp};
		( ( (b.sum /*+ 0.5*/) < dur ) and: enlarge.isNil ).if {
			b.sum.asString + dur.asString +"section shorter than default vocoder dur - setting dur to" + ( b.sum + durRel /*+ 0.5 */) => _.warn;
			dur = b.sum + durRel /*+ 0.5*/
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

					target: vocoderGroup,
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
				* 3 * \gain.kr(gain,0.1)
			}.play(
				target: vocoderGroup,
				addAction:\addToTail
			).register
		};
		case
            { Song.vocoderSynth.isNil }         { playSynth.();playAmbiSynth.() }
            { Song.vocoderSynth.isPlaying.not } { playSynth.(); playAmbiSynth.() }
            { true }                            { Song.vocoderSynth.set(\dur,dur,\gate,1)} ;
		// restore line above to 'out' to get rid of ambisonics!!
		Song.carrierSynth = Song.sargonCarrier.(p,b,e,att, sus, rel, chord,tune,mix, verb, width,carrierGain,enlarge,sawFreqRatio);
		Song.modulatorSynth = Song.sargonModulator.(rppName,dur,modGain,echo,synthVbuffer)
	};
	laMer = laMer ?  Buffer.read(Server.default,"~/tank/super/samples/La_Mer_clean.aif".standardizePath);
	[
		\carrierBus,
		\modulatorBus,
		\vocoderRatio ,
		\monitorCarrier,
		\sargonCarrier,
		\auditionVocoder,
		\vocoderFoa,
		\vocodeTune,
		\laMer;
	].do({|i| Song.resources.put(i, Trek.perform(i))})
	}
}

