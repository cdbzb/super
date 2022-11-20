SynthV{
	// project.tracks[0].database = "AiKO Lite"
	classvar <>directory = "~/tank/super/SynthV";
	classvar <notePrototype, <databasePrototype;
	classvar <roles;
	var <name, <project, <file,<location,<buffer, <key, <song, <section;
	*new {|key name| ^super.new.init(key,name) }
	*setRole {|name database|
		roles.put(name,database)
	}
	*initClass {
		roles = ();

		notePrototype = (
			'onset': 88200000,
			'duration': 1146600000,
			'pitch': 66,
			'detune': 0,
			'systemAttributes': (  ),
			'pitchTakes': ( 'activeTakeId': 0, 'takes': [ ( 'liked': false, 'id': 0, 'expr': 1.0 ) ] ),
			'lyrics': "la",
			'timbreTakes': ( 'activeTakeId': 0, 'takes': [ ( 'liked': false, 'id': 0, 'expr': 1.0 ) ] ),
			'phonemes': "" , 
			'attributes': (  )
		);
		databasePrototype = ( 
			'version': 100, 
			'phonesetOverride': "", 
			'name': "AiKO (Lite)", 
			'phoneset': "xsampa", 
			'language': "mandarin", 
			'languageOverride': "", 
			'backendType': "SVR2Standard"
		)
		/*
		(
			'backendType': "SVR2AI",
			'version': 101,
			'name': "Tsurumaki Maki AI (ENG Lite)",
			'phoneset': "arpabet", 
			'language': "english",
			'languageOverride': "",
			'phonesetOverride': ""
		)
		*/
	}
	checkDirty {

		^project => JSON.stringify(_) != String.readNew(File( file ,"r"))
	}
	refresh {
		this.checkDirty.if{
			this.writeProject;
			this.render;
			buffer = Buffer.doRead(Server.default,location+/+"synthV_MixDown.wav");
		}
	}
	render {
		"~/scripts/renderSynthesizerV.sh".standardizePath.unixCmd
	}
	*load { |path|
		^String.readNew(path.standardizePath => File(_,"r")) => JSON.parse(_)
	}
	init{ |n k|
		key = k.asString.replace(Char.space,$_);
		song.isNil.if{ song = Song.currentSong };
		section = song.section(key.replace($_,Char.space)); //does this do anything?
		name = n;
		directory = directory.standardizePath;
		location= directory +/+ song.key +/+ key +/+ name; //change storage scheme here

		file = location +/+ "project.svp";

		project = String.readNew(File( directory +/+ "test.svp"=>_.standardizePath,"r" ))
		=> JSON.parse(_);

		this.refreshBuffer;
	}
	writeProject {
		this.setRenderConfig;
		JSON.stringify( project ).write(
			file, overwrite: true, ask: false
		);
	}

	setRenderConfig { 
		(
			sampleRate: 48000,
			filename: "synthV.wav",
			aspirationFormat: "NoAspiration",
			exportMixDown: true,
			destination:location,
			bitDepth: 24,
			numChannels:1,
		).asPairs.pairsDo({|i j| project.renderConfig.put(i,j)})
	}

	open {
		"open -a 'Synthesizer V Studio Basic'" + file => _.unixCmd 
	}
	notes { | track=0  |
		^project.tracks[track].mainGroup.notes
	}
	set { |event|
		event.dur.size.postln;// => this.makeNotes(_+1);
		event.dur = event.dur * 2 * 70560 => _.asInteger;
		
		event.legato = event.legato ? 1;
		event.onset = [0] ++ event.dur.integrate => _.dropLast();
		event.duration = event.dur * event.legato => _.collect{|i| i.asInteger .asString ++ "0000"};
		event.onset= event.onset.collect {|i| i.asInteger.asString ++ "0000"};
		event.keys.do{|key|
			key.postln;
			this.setNotes(key,event.at(key))
		};
		//this should be done with an array flop and pairsDo instad but...
		//this.filterRests 
	}
	setPbind { |pbind|
		var event = Event.newFrom(pbind.patternpairs);
		event.postln
	}
	setNote {| index key value|
		
		key.post;" ".post;value.postln;
		this.notes[index].put(key,value);
	}
	setNotes { |key array|
		array.do{|i x|
			this.setNote(x, key, i)
		}
	}
	makeNotes {|num track=0|
		project.tracks[track].mainGroup.notes = notePrototype ! num
	}
	filterRests { |track=0|
		project.tracks[track].maingroup.put(
			\notes,
			this.notes.reject({|i| i.at("lyrics")=="r"})
		)
	}
	refreshBuffer{
		File.exists(location+/+"synthV_MixDown.wav").if{
		buffer = Buffer.doRead(Server.default,location+/+"synthV_MixDown.wav");
		}
	}
}

+ P {
	*synthV{ | key start array syl lag=0 music song resources range |

		var section = P.calcStart(start );

		var pbind = Song.currentSong.pbind[start ] ;

		var synthV = SynthV(key,start );

		pbind = pbind.patternpairs.collect{|i|
			( i.class==Pseq ).if{i.list}{i}
		}
		++ array
		=> Event.newFrom(_);

		pbind.keys.do{|k| 
			( pbind.at(k).isCollection && pbind.at(k).isString.not ).if{
				pbind.put(k, pbind.at(k)[range[0]..range[1]])
		}};
		pbind.lyrics=pbind.lyrics.split(Char.space).reject{|i| i.size==0};
		pbind.pitch=pbind.midinote.asInteger;
		synthV.makeNotes(pbind.dur.size);

		synthV.set(pbind); //set should filter for \r

		synthV.writeProject; 'synthV written!'.postln;
		
		^P(key,section,syl,lag, music,song,
			resources:(
				synthV: synthV,
				playbuf: { PlayBuf.auto(1,synthV.buffer.()) }

			) ,
			); // order of section and key are reversed!!
	}
}
