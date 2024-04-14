Trek {
	classvar <>cast, <path, <>presets, <keys, <>synful1, <>synful2;
	classvar <condVar, <>transitions, transitionGroup;
	*initClass {
		path = this.filenameSymbol.asString.dirname.dirname +/+ "/Songs";
		cast = try{ Object.readArchive(path +/+ "trek_cast") } ? ();
		presets = try{ Object.readArchive(path +/+ "trek_presets") } ? MultiLevelIdentityDictionary.new();
		transitions = Order();
		keys = [
			\visual,
			\rescue,
			\transporter,
			\chamber1,
			\panel1,
			\panel2,
			\smallChamber,
			\chamber,
			\briefing,
			\theyUsed,
			\song,
			\song,
			'this formnula',
			\three,
			\silverLake,
			\chapelForgets,
			\thousand,
			\sickBay,
			\medical,
			\laboratory,
			\MandT,
			\MandT,
			\ending
		];
		ServerTree.add({transitionGroup = Group.after(Server.default.defaultGroup).register});
		transitions = keys.collect{ () };
		// CmdPeriod.add({transitionGroup = Group.after(Server.default.defaultGroup).register});
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
		=>_.select{|i| "[0-9]+".matchRegexp(i) }
	}
	*song{|i|
		i.isInteger.if{
			^this.allTheSongs[i]
		}{
			^keys.indexOf(i) => this.allTheSongs[_]
		}
	}
	*loadSongs{|array|
		fork{
			array.do{|i x|
				condVar = CondVar();
				defer{ File.readAllString(this.allTheSongs[ i ]) ++ "; Trek.condVar.signalOne" => _.interpret };
				condVar.wait;
				x.debug("loaded!");
			}
		}
	}

	*playSong{|num cursor=0 scroll=false trimEnd=0| //use cursor -2 to play last two sections
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

	*playRange { |num cursor numSections| 
		fork{
			numSections.do{|i| 
				var section = num + i;
				var start = (i == 0).if{ cursor }{ transitions[section].start};
				this.playSong(section, start, trimEnd: transitions[section].trimEnd ? 0) + (transitions[section+1].lag ? 0) => _.wait;
				transitions[section].func.() ? 0 => _.wait
			}
		}
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
		Song.resources.condition=Condition();
		Song.resources.infrastructure = {
			FunctionList.new.array_([
				( currentEnvironment.at(\synful1).isNil or: try{ currentEnvironment.at(\synful1).syn.isPlaying.not } ).if
				(Trek.synful1.isNil or: try{ Trek.synful1.syn.isPlaying.not }).if {
					Song.currentSong.synful1 = Trek.synful1 = Synful();
					Song.currentSong.synful2 = Trek.synful2 = Synful();
				},
				{ fork {
					while( {
						Trek.synful2.controller.loaded.not;
					},{0.05.wait});
					Song.resources.condition.test_(true).signal
				}}
			]).value
		}.inEnvir;
	}


}

