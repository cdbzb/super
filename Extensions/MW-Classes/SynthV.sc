SynthV{
	// project.tracks[0].database = "AiKO Lite"
	classvar <>directory = "~/tank/super/SynthV";
	classvar <notePrototype, <databasePrototype, <databaseLib;
	classvar <roles,<envelopes=#[ \toneShift, \pitchDelta, \voicing, \tension, \vibratoEnv, \loudness, \breathiness, \gender ];
	classvar <vocalModes;
	classvar <>registry;
	var <name, <project, <file,<location,<buffer, <key, <song, <section;
	var <>firstNoteOffset = 0;
	var <> offset = 0;
	var <>double;
	*new {|key name take double| registry.at(key, name, take).isNil.if {
		 ^super.new.init(key, name, take, double) 
	 }{
		 registry.at(key, name, (take ? \defailt)).refreshBuffer;
		 ^registry.at(key, name, (take ? \default)) } 
	 }
	*initClass {
		registry = MultiLevelIdentityDictionary.new();

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
		);
		vocalModes = (
			kevin: Set[\Clear,\Soft,\Belt,\Solid]
		);
		databaseLib = (
			genbu:( 'backendType': "SVR2Standard", 'version': 100, 'name': "GENBU", 'phoneset': "romaji", 'language': "japanese", 'languageOverride': "", 'phonesetOverride': "" ), 

			aiko: ( 
				'version': 100, 
				'phonesetOverride': "", 
				'name': "AiKO", 
				'phoneset': "xsampa", 
				'language': "mandarin", 
				'languageOverride': "", 
				'backendType': "SVR2Standard"
			),
			xuan: (
				'name': "Xuan Yu",
				'language': "mandarin",
				'phoneset': "xsampa",
				'languageOverride': "",
				'phonesetOverride': "",
				'backendType': "SVR2AI",
				'version': "100"
			),
			kevin: ( 
				'name':             "Kevin",
				'language':         "english",
				'phoneset':         "arpabet",
				'languageOverride': "",
				'phonesetOverride': "",
				'backendType':      "SVR2AI",
				'version':          "107"
			),
			feng: (
				'name': "Feng Yi",
				'language': "mandarin",
				'phoneset': "xsampa",
				'languageOverride': "english",
				'phonesetOverride': "arpabet",
				'backendType': "SVR2AI",
				'version': "104"
			)

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
		^project => JSON.stringify(_) != try{ String.readNew(File( file ,"r") )}
	}
	needsRender {
		^( File.mtime(file) > File.mtime(location +/+ "synthV_MixDown.wav") )
	}
	refresh {
		this.checkDirty.if{
			this.writeProject;
			this.render;
			buffer = Buffer.doRead(Server.default,location+/+"synthV_MixDown.wav");
		}
	}
	render {
		double.post;" ".post;
		double.isNil.if {
			\renderSynthsizerV.postln;
			"~/scripts/renderSynthesizerV.sh".standardizePath + file =>_.unixCmd
		}{
			\newTakeSynthV.postln;
			"~/scripts/newTakeSynthV.sh".standardizePath + file =>_.unixCmd
		}
	}
	*load { |path|
		^String.readNew(path.standardizePath => File(_,"r")) => JSON.parse(_)
	}
	init{ |n k take d|
		name = n; double = d;
		this.class.registry.put(n,k,(take ? \default),this);
		key = k.asString.replace(Char.space,$_);
		song.isNil.if{ song = Song.currentSong };
		section = song.section(key.replace($_,Char.space)); //does this do anything?
		directory = directory.standardizePath;

		location= directory +/+ song.key +/+ key +/+ name; //change storage scheme here
		take.notNil.if{ location = location ++ "-" ++ take };

		file = location +/+ "project.svp";

		project = String.readNew(File( directory +/+ "test.svp"=>_.standardizePath,"r" ))
		=> JSON.parse(_);

		//strip erroneous points data - TODO clean this up in original file!
		project.tracks[0].mainRef.systemPitchDelta.put(\points,[]);

		this.refreshBuffer;
	}
	writeProject {
		this.setRenderConfig;
		this.checkDirty.if
		{
			JSON.stringify( project ).write(
				file, overwrite: true, ask: false
			);
		}
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
		"open -a 'Synthesizer V Studio Pro'" + file => _.unixCmd 
	}
	database { |track=0|
		^project.tracks[track].mainRef.database
	}
	notes { | track=0  |
		^project.tracks[track].mainGroup.notes
	}
	voice{ |track=0|
		^project.tracks[track].mainRef.voice
	}
	*secondsToBlicks{|seconds|
		^seconds * 2 * 7056 * 10e4 => _.round(1)// => _.asString => _.dropLast(2)
	}
	setEnv{ |param env|
		var points = [env.timeLine.collect({|i| this.class.secondsToBlicks(i)}),env.levels].flop.flat;
		project.tracks[0].mainGroup.parameters.at(param).put(\points,points)
	}
	set { |event|
		(event.lyric == "\r").not.if(
		event.dur.size.postln;
		event.dur = [ 0 ] ++ event.dur.integrate + (event.lag ? 0) => _.differentiate => _.drop(1);
		// trim the last duration to account for inital lag!!
		//event.dur.put(event.dur[event.dur.size],event.dur.last - (event.lag[0] ? 0));
		
		event.dur = event.dur + firstNoteOffset * 2 * 70560  => _.asInteger;
		event.onset = [0] ++ event.dur.integrate => _.dropLast() + ( ( event.lag[0] ? 0 ) * 70560 * 2  );
		event.duration = event.dur * ( event.legato ? 1 ) => _.collect{|i| i.asInteger .asString ++ "0000"};
		event.onset= event.onset.collect {|i| i.asInteger.asString ++ "0000"};

		\KKEEYYSS.postln;
		event.keys.do{|i|
			i.postln;
			case 
                        { [\dur,\legato,\lag].includes(i) }{nil}
			{ i == \vocalMode} {this.voice.put(\vocalModePreset, event.vocalMode)}
                        { envelopes.includes(i)} { this.setEnv(i,event.at(i))}
                        { i == \language }      {\LANGUAGE.postln; project.tracks[0].mainRef.database.put(\languageOverride,event.at(i)).postln }
                        { i == \phoneset}      { project.tracks[0].mainRef.database.put(\phonesetOverride,event.at(i)) }
                        { true }                 { this.setNotes(i,event.at(i)) }
		};
		//this should be done with an array flop and pairsDo instad but...
		this.filterRests 
	)
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
	setDatabase { |key|
		project.tracks[0].mainRef.put(\database, databaseLib.at(key) )
	}
	setLanguage { | array |
		var where = project.tracks[0].mainRef.database;
		[\languageOverride, \phonesetOverride].do{|i x| 
			where.put(i, array[0][x])
		}
	}
	makeNotes {|num track=0|
		project.tracks[track].mainGroup.notes = notePrototype ! num
	}
	shiftNotes {| seconds |
		this.notes.do{ |e| 
			e.put(\onset, e.onset.blicksToSeconds + seconds => _.secondsToBlicks)
		}
	}
	findPartBefore{
		^ Song.pts
		.select{|i| i.name.contains(name.asString)}
		.select{|i| i.name.contains(key.asInteger - 1 => _.asString)}
		.unbubble
	}
	prependNotes {|section synthV track=0|
		var last = this.findPartBefore.synthV.notes.last;
		last = last.put(\onset,"0");
		offset = last.duration.blicksToSeconds;
		// offset = Song.secDur[ key.asInteger - 1 ];
		this.shiftNotes( offset );
		// project.tracks[track].mainGroup.put(\notes, this.findPartBefore.synthV.notes ++ this.notes )
		project.tracks[track].mainGroup.put(\notes, last.bubble ++ this.notes )
	}
	filterRests { |track=0|
		project.tracks[track].mainGroup.notes =
			this.notes.reject({|i| i.at(\lyrics)=="r"})
	}
	refreshBuffer{
		File.exists(location+/+"synthV_MixDown.wav").if{
			try{buffer.free};
			buffer = Buffer.doRead(Server.default,location+/+"synthV_MixDown.wav");
		}
	}
}

+ P {
	*double{| key music filter pbind |
		var section = P.calcStart(nil); 
		var original = Song.currentSong.at(section).select({|e| e.name.contains(key.asString) })[0];
		^P.synthV(
			key,
			params:original.params,
			double:true,
			take:\double,
			music:music,
			filter:(filter ? original.filter),
			pbind: (pbind ? original.pbind)
		)
	}
	*synthV{ | key start params syl lag=0 take double music song resources range filter pbind prepend|

		var event;
		var section = P.calcStart(start );
		var synthV = SynthV(key,( start ? section ),take ,double );
		song = song ? Song.currentSong;
		pbind = pbind.notNil.if{  // pass in a pbind or get it from the song
			pbind.value(song,song.durs[section].list)
		} {
			Song.currentSong.pbind[section] 
		};
		event = pbind.patternpairs.collect{|i|
			( i.class==Pseq ).if{i.list}{i}
		}
		++ params.value(
			song,
			song.durs[section].list, //drop range
		) 
		=> Event.newFrom(_)
		=> {|i| 
			filter.notNil.if{
				( filter.class == Function ).if {
					filter.( i )
				}{ //filter is an Event 
					filter.keys.postln.do{|key|
						\KEY_.post;key.postln;
						\i_.post;i.postln;
						i.put(key, filter.at( key ).( i.at( key ) ))
					}

				}
			};
			i
		};
		event.keys.do{|k| 
			( event.at(k).isCollection && event.at(k).isString.not ).if{
				event.put(k, event.at(k)[range[0]..range[1]])
		}};
		event.lyrics=event.lyrics.replace($, , "").split(Char.space).reject{|i| i.size==0};
		event.pitch=event.midinote.asInteger;
		synthV.makeNotes(event.dur.size);

		synthV.setDatabase(key);
		synthV.set(event); 

		prepend.notNil.if{ 
			synthV.prependNotes;
		};
		synthV.writeProject; 'synthV written!'.postln;
		// write project only does so if dirty !!

		// synthV.checkDirty.if{synthV.refresh};
		
		take.notNil.if{key = key ++ "_" ++ take};
		^P(key,start,syl,lag, music,song,
			resources:(
				synthV: synthV,
				playbuf: { PlayBuf.auto(
					1,
					synthV.buffer.(),
					startPos: ( synthV.offset ) * BufSampleRate.kr(synthV.buffer.()),
					doneAction:2
				)},
				take: take,
				params: params,
				filter: filter


			) ,
			); // order of section and key are reversed!!
	}
}

+String{
	timeSinceModified {
		var a = Pipe.new("echo $(($(date +%s) - $(date -r" + this + "+%s)))","r");
		var b = a.getLine;
		a.close;
		^b.asInteger
	}
	blicksToSeconds {
		^this.dropLast(4).asInteger / 2 / 70560
	}
}

+Song {
	refreshSynthV {
		fork{
			var dirty = Song.pts
			.select{ |i| i.synthV != nil }
			.select{ |i| i.synthV.needsRender};
			dirty.do{ |i|
				var wav = i.synthV.location +/+ "synthV_MixDown.wav";
				1.wait;
				i.synthV.render;
				Post <<< 'time: ' <<< wav.timeSinceModified;
				while { wav.timeSinceModified > 10} {0.1.wait;Post << \waiting <<  wav.timeSinceModified << Char.nl}
				// while {12>10} {0.01.wait;\waiting.postln}
			};
			// ^dirty
		}
	}
}

+ SimpleNumber {
	secondsToBlicks {
		^this * 2 * 70560 => _.round() => _.asInteger => _.asString ++ "0000"
	}
}
