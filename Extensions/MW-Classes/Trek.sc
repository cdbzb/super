Trek {
	classvar <>cast, path, <>presets;
	*initClass {
		path = "/Users/michael/tank/super/More-Organized-Trek/Songs";
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

}
