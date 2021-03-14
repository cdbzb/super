(
~synthDefLibrary=(
	directory:"~/tank/super/SynthDefLibrary",
	list:{|self|( self.directory ).asPathName.files.collect(_.fileName).do(_.postln)},
	folders:{|self| self.directory.asPathName.folders.collect(_.folderName)},
	load:{|self| ( self.directory +/+ "*" ).loadPaths},
	doesNotUnderstand:{|self| 6.postln},
)
)

/*
~synthDefLibrary.list
~synthDefLibrary.folders
*/
