+ SynthV {
	*newVST { |key name take double version|
		^super.new.initVST(key, name, take, double, version)
	}
	*vst { |voice params version=2|
		var synthV;
		synthV = super.new.initVST(voice, \default, voice, nil, version);
		synthV.vstParams = params;
		synthV.vstParams[\voice] = voice;
		^synthV
	}
	buildVSTParams {
		var params = vstParams;
		this.buildFunc = {
			params.lyrics = params.lyrics.replace($, , "").split(Char.space).reject{|i| i.size==0};
			params.pitch = params.midinote.asInteger;
			this.makeNotes(params.dur.size);
			this.setDatabase(params[\voice]);
			this.set(params);
		};
	}
	build {
		this.buildVSTParams;
		this.renderVST;
		^this
	}
	morphPhonemesVST { |languages randomSeed=12345|
		var morphed = vstParams.lyrics.morphPhonemes(nil, languages.sort, randomSeed);
		vstParams.putAll((
			phonemes: morphed.phonemes,
			languageOverride: morphed.languageOverride,
			phonesetOverride: morphed.phonesetOverride
		));
		^this
	}
	*buildVST { |song section voice take params version|
		//section is just there for the naming filetree - its just a secondary name in this case
		//in the Song version it is a name used to retrieve blah blah
		var synthV;
		synthV = super.new.initVST(song, section, voice, take, version).setDatabase(voice);

		synthV.vstParams = params;
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
		this.writeFxp(path);
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
		^this
	}
	renderVST {
		var path = "/private/tmp/" ++ UniqueID.next.asString.padLeft(13, "0");
		this.buildFunc.value;
		this.writeProjectVST(path ++ ".svp") ; 
		this.writeFxp(path);
		fork{0.1.wait;vst = SV( path ++ ".fxp" )};
	}

	writeFxp { |path| //pass in path without .svp or .fxp
		var oldPath, newPath, templateFile, fxpData, startIndex, sizeDiff, newFxpData;
		//this is the path we will be embedding in the fxp file
		newPath = path ++ ".svp";
		// select template and embedded path based on appVersion
		case
		{ appVersion == 1 } {
			oldPath = "/private/tmp/250617_142307.svp";
			templateFile = "123456_123456.fxp";
		}
		{ appVersion == 2 } {
			oldPath = "/private/tmp/svvst_665F5C6F.svp";
			templateFile = "654321_654321.fxp";
		};
		fxpData = {
			var file, data;
			file = File(("~/tank/super/Trek/SynthV/" ++ templateFile).standardizePath, "rb");
			data = Int8Array.newClear(file.length);
			file.read(data);
			file.close;
			data;
		}.();
		startIndex = (0..(fxpData.size - oldPath.size)).detect { |i|
			oldPath.ascii.every
			{ |byte, j|
				fxpData[i + j] == byte;
			};
		};
		if(startIndex.notNil) {
			sizeDiff = newPath.size - oldPath.size;
			newFxpData = Int8Array.newClear(fxpData.size + sizeDiff);
			// copy before path
			startIndex.do{|i| newFxpData[i] = fxpData[i] };
			// write new path
			newPath.ascii.do{|byte, i| newFxpData[startIndex + i] = byte };
			// copy after old path
			(fxpData.size - startIndex - oldPath.size).do{|i|
				newFxpData[startIndex + newPath.size + i] = fxpData[startIndex + oldPath.size + i]
			};
			// update JSON length byte at offset 0x28
			newFxpData[0x28] = fxpData[0x28] + sizeDiff;
			{
				var file;
                path ++".fxp" => _.debug("FXP");
				file = File( path ++ ".fxp" , "wb");
				file.write(newFxpData);
				file.close;
			}.value;
		}
	}
	playVST { |func tail=1|
		var syn, dur;
		func = func ? I.d;
		dur = vstParams.dur.sum + tail;
		fork{
			syn = { In.ar(vst.bus) => func }.play;
			vst.controller.setTransportPos(0);
			vst.controller.setPlaying(true);
			dur.wait;
			vst.controller.setPlaying(false);
			syn.free;
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

