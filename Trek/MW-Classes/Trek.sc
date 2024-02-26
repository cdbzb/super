Trek {
	classvar <>cast, <path, <>presets, <keys;
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
		( currentEnvironment.at(\synful1).isNil or: try{ currentEnvironment.at(\synful1).syn.isPlaying.not } ).if
		{
			Song.currentSong.synful1 = currentEnvironment.put(\synful1, Synful());
			Song.currentSong.synful2 = currentEnvironment.put(\synful2, Synful());
		}{
			Song.currentSong.synful1 = currentEnvironment.at(\synful1);
			Song.currentSong.synful2 = currentEnvironment.at(\synful2);
		};
		Song.resources.condition=Condition();
		Song.resources.infrastructure=
		{
			FunctionList.new.array_([
				( currentEnvironment.at(\synful1).isNil or: try{ currentEnvironment.at(\synful1).syn.isPlaying.not } ).if
				{
					Song.currentSong.synful1 = currentEnvironment.put(\synful1,Synful()).synful1;
					Song.currentSong.synful2 = currentEnvironment.put(\synful2,Synful()).synful2;
				},
				{ fork {
					while( {
						currentEnvironment.at(\synful2).controller.loaded.not;
					},{0.05.wait});
					Song.resources.condition.test_(true).signal
				}}
			]).value
		}.inEnvir;
	}


}
