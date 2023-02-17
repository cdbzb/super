Trek {
	classvar <>cast, path;
	*initClass {
		path = "/Users/michael/tank/super/More-Organized-Trek/Songs";
		cast = try{ Object.readArchive(path +/+ "trek_cast") } ? ();
	}
	*save {
		cast.writeArchive(path +/+ "trek_cast")
	}
}
