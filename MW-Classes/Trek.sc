Trek {
	classvar <>cast, path, <>presets;
	*initClass {
		path = this.filenameSymbol.asString.dirname.dirname +/+ "More-Organized-Trek/Songs";
		cast = try{ Object.readArchive(path +/+ "trek_cast") } ? ();
		presets = try{ Object.readArchive(path +/+ "trek_presets") } ? MultiLevelIdentityDictionary.new();
	}
	*save {
		cast.writeArchive(path +/+ "trek_cast");
		presets.writeArchive(path +/+ "trek_presets")
	}
	*put { |who voice preset|
		^presets.put(who,voice,preset)
	}
	*at {|...args|
		^presets.at(*args)
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
