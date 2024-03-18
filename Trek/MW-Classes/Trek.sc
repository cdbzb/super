Trek {
	classvar <>cast, <path, <>presets, <keys, <>synful1, <>synful2;
	*initClass {
		path = this.filenameSymbol.asString.dirname.dirname +/+ "/Songs";
		cast = try{ Object.readArchive(path +/+ "trek_cast") } ? ();
		presets = try{ Object.readArchive(path +/+ "trek_presets") } ? MultiLevelIdentityDictionary.new();
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
		]
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
	*synful {
		( Song.synful1.isNil or: try{ Song.synful1.syn.isPlaying.not } ).if {
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
