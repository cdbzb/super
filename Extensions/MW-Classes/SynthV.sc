SynthV{
	// project.tracks[0].database = "AiKO Lite"
	classvar <>directory = "~/tank/super/SynthV";
	classvar <notePrototype, <databasePrototype;
	classvar <roles;
	var <name, <project, <path, <file,<location,<buffer, <key, <song, <section;
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
		section = song.section(key.replace($_,Char.space));
		//reaperProjectPath = Song.reaperFolder +/+ song.key +/+ key;
		name = n;
		//name.notNil.if{
		//	key = key ++ "-" ++ name
		//};
		///////////

		directory = directory.standardizePath;
		path = directory +/+ song.key +/+ key; //change storage scheme here

		location = path +/+ name;

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
		}
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
	*synthV{ | key synthVstart array syl lag=0 music song resources range |
		var start = P.calcStart(synthVstart );
		var pbind = Song.currentSong.pbind[synthVstart ] ;

		var synthV = SynthV(key,synthVstart );

		//range.notNil.if{
		//	var drop, length;
		//	drop = range[0];
		//	pbind=pbind.drop(drop) ;
		//	range[1].notNil.if {
		//		length = range[1] - range[0] + 1;
		//		pbind=pbind.fin(length) ;
		//	};
		//	(drop > 0).if{ syl = drop - 1; \syl.post;syl.postln };
		//};
		pbind = pbind.patternpairs.collect{|i| ( i.class==Pseq ).if{i.list}{i}}
		++ array
		=> Event.newFrom(_);
		\PBIND.post;pbind.postln;
		pbind.keys.do{|k| ( pbind.at(k).isCollection && pbind.at(k).isString.not ).if{
			pbind.put(k, pbind.at(k)[range[0]..range[1]])
		}};
		pbind.lyrics=pbind.lyrics.split(Char.space).reject{|i| i.size==0};
		pbind.pitch=pbind.midinote.asInteger;
		synthV.makeNotes(pbind.dur.size);


		synthV.set(pbind);

		synthV.writeProject; 'synthV written!'.postln;
		//^P(
		//	key: (key++"SYNTHV").asSymbol, 
		//	synthV: synthV,
		//	start:start, 
		//	music:music, 
		//	syl:syl, 
		//	lag:lag 
		//)
		^P(key,start,syl,lag, music,song,resources,synthV:synthV ); // order of section and key are reversed!!
	}
}
