+ SynthV {
	*newVST { |key name take double| 
		^super.new.initVST(key, name, take, double) 
	}
	*buildVST { |song section voice take params|
		//section is just there for the naming filetree - its just a secondary name in this case
		//in the Song version it is a name used to retrieve blah blah
		var synthV;
		synthV = 
		// SynthV(name, voice, take).setDatabase(voice);
		super.new.initVST(song, section, voice, take).setDatabase(voice);
		synthV.buildFunc = { 
			params.lyrics=params.lyrics.replace($, , "").split(Char.space).reject{|i| i.size==0};
			params.pitch=params.midinote.asInteger;
			synthV.makeNotes(params.dur.size);

			synthV.set(params); 
		};
			// take.notNil.if{voice = voice ++ "_" ++ take};
			// SynthV.current_(synthV);
			// synthV.refreshBuffer(song, section, voice, (take ? \default));
			^synthV
	}
	initVST { |son sec v t |
		var voice = v;
		section = sec;
		song = son; take = t;

		// directory = "/tmp";

		// location = directory +/+ ( song.key.asString.replace(Char.space,$-) ) +/+ Song.lyrics[Song.section(key)].hash.abs +/+ name; //change storage scheme here
		location = directory;

		file = location +/+ "project.svp";

		project = Object.readArchive(directory +/+ "test.svp.event-archive");

		//strip erroneous points data - TODO clean this up in original file!
		project.tracks[0].mainRef.systemPitchDelta.put(\points,[]);

		// this.refreshBuffer(song, name, voice, (take ? \default));
	}
	renderVST {
		var path = "/tmp/" ++ [song,section,take].hash ++ ".svp";
		this.buildFunc.value;
		this.writeProjectVST(path) ; 
		vst = SV( path );
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
