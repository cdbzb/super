+ SynthV {
	*newVST { |key name take double| 
		^super.new.initVST(key, name, take, double) 
	}
	*buildVST { |song section voice take params version|
		//section is just there for the naming filetree - its just a secondary name in this case
		//in the Song version it is a name used to retrieve blah blah
		var synthV;
		synthV = super.new.initVST(song, section, voice, take, version).setDatabase(voice);

		synthV.buildFunc = { 
			params.lyrics=params.lyrics.replace($, , "").split(Char.space).reject{|i| i.size==0};
			params.pitch=params.midinote.asInteger;
			synthV.makeNotes(params.dur.size);

			synthV.set(params); 
		};
			// take.notNil.if{voice = voice ++ "_" ++ take};
			// SynthV.current_(synthV);
			// synthV.refreshBuffer(song, section, voice, (take ? \default));
			synthV.renderVST;
			^synthV
	}
	buildVST { |song section voice take params|
		var path = "/private/tmp/" ++ Date.new.stamp;
		this.setDatabase(voice);
		this.buildFunc = { 
			params.lyrics=params.lyrics.replace($, , "").split(Char.space).reject{|i| i.size==0};
			params.pitch=params.midinote.asInteger;
			this.makeNotes(params.dur.size);

			this.set(params); 
		};
		this.buildFunc.value;
		this.writeProjectVST(path ++ ".svp") ; 
		this.writeFxp(path ++ ".fxp");
		fork{0.1.wait;vst.controller.readProgram(path ++ ".fxp")};
	}
	initVST { |son sec v t version |
		var voice = v;
		section = sec;
		song = son; take = t;
        appVersion = version ? 1;
		// directory = "/tmp";

		// location = directory +/+ ( song.key.asString.replace(Char.space,$-) ) +/+ Song.lyrics[Song.section(key)].hash.abs +/+ name; //change storage scheme here
		location = directory;

		file = location +/+ "project.svp";

		project = case
		{ appVersion == 1 } { Object.readArchive(directory +/+ "test.svp.event-archive") }
		{ appVersion == 2 } { Object.readArchive(directory +/+ "test.svp.event-archive-V2") };

        this.setProjectVersion;
		//strip erroneous points data - TODO clean this up in original file!
		(appVersion == 1).if { project.tracks[0].mainRef.systemPitchDelta.put(\points,[]) };

		// this.refreshBuffer(song, name, voice, (take ? \default));
	}
	renderVST {
		var path = "/private/tmp/" ++ Date.new.stamp;
		this.buildFunc.value;
		this.writeProjectVST(path ++ ".svp") ; 
		this.writeFxp(path);
		fork{0.1.wait;vst = SV( path ++ ".fxp" )};
	}

	writeFxp { |path| //pass in path without .svp or .fxp
        //this path is embedded in the example fxp file below
		// var oldPath = "/private/tmp/250617_142307.svp";

		// for V2 
		var oldPath = "/private/tmp/250717_080003.svp";
		// var newPath = "/private/tmp/" ++ Date.new.stamp ++ ".svp";
        //this is the path we will be embedding in the fxp file
		var newPath = path ++ ".svp";
		var fxpData = {
			var file, data;
			// this example fxp file has an embedded path
			file = File("~/tank/super/Trek/SynthV/123456_123456.fxp".standardizePath, "rb"); // "rb" for read binary
			// this is a V2 example
			file = File("~/tank/super/Trek/SynthV/654321_654321.fxp".standardizePath, "rb"); // "rb" for read binary
			data = Int8Array.newClear(file.length);
			file.read(data);
			file.close;
			data;
		}.();
		var startIndex = (0..(fxpData.size - oldPath.size)).detect { |i|
			oldPath.ascii.every
			{ |byte, j|
				fxpData[i + j] == byte;
			};
		};
		if(startIndex.notNil) {
			newPath.ascii.do { |byte, i|
				fxpData[startIndex + i] = byte;
			};
			// here we write it back

			{
				var file;
				// "WRITING".postln;
                path ++".fxp" => _.debug("FXP");
				file = File( path ++ ".fxp" , "wb"); // "wb" for write binary
				file.write(fxpData);
				file.close;
			}.value;
		}
	}
	writeProjectVST { |path|
		this.setRenderConfig;
		// File.exists(location).not.if{File.mkdir(location)};
		// this.checkDirty.if
		// {
			// project.writeArchive( location +/+ "raw" );
			JSON.stringify( project ).write(
				path , overwrite: true, ask: false
			);
			'synthV written!'.postln;
			// fork{0.05.wait;this.render}
		// }
	}

}

