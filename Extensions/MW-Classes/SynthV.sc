SynthV{
	// project.tracks[0].database = "AiKO Lite"
	classvar <>directory = "~/tank/super/SynthV";
	classvar <notePrototype, <databasePrototype, <databaseLib;
	classvar <roles,<envelopes=#[ \toneShift, \pitchDelta, \voicing, \tension, \vibratoEnv, \loudness, \breathiness, \gender ];
	classvar <vocalModes;
	var <name, <project, <file,<location,<buffer, <key, <song, <section;
	*new {|key name take| ^super.new.init(key, name, take) }
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
		);
		vocalModes = (
			kevin: Set[\Clear,\Soft,\Belt,\Solid]
		);
		databaseLib = (
			genbu:( 'backendType': "SVR2Standard", 'version': 100, 'name': "GENBU", 'phoneset': "romaji", 'language': "japanese", 'languageOverride': "", 'phonesetOverride': "" ), 

			aiko: ( 
				'version': 100, 
				'phonesetOverride': "", 
				'name': "AiKO (Lite)", 
				'phoneset': "xsampa", 
				'language': "mandarin", 
				'languageOverride': "", 
				'backendType': "SVR2Standard"
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
		"~/scripts/renderSynthesizerV.sh".standardizePath + file =>_.unixCmd
	}
	*load { |path|
		^String.readNew(path.standardizePath => File(_,"r")) => JSON.parse(_)
	}
	init{ |n k take|
		key = k.asString.replace(Char.space,$_);
		song.isNil.if{ song = Song.currentSong };
		section = song.section(key.replace($_,Char.space)); //does this do anything?
		name = n;
		directory = directory.standardizePath;

		location= directory +/+ song.key +/+ key +/+ name; //change storage scheme here
		take.notNil.if{ location = location ++ "-" ++ take };

		file = location +/+ "project.svp";

		project = String.readNew(File( directory +/+ "test.svp"=>_.standardizePath,"r" ))
		=> JSON.parse(_);

		//strip erroneous points data - TODO clean this up
		project.tracks[0].mainRef.systemPitchDelta.put(\points,[]);

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
		event.dur.size.postln;// => this.makeNotes(_+1);
		//event.dur = event.dur.collect{|i| this.class.secondsToBlicks(i)};
		event.dur = [0] ++ event.dur.integrate + (event.lag ? 0) => _.differentiate => _.drop(1);
		// trim the last duration to account for inital lag!!
		//event.dur.put(event.dur[event.dur.size],event.dur.last - (event.lag[0] ? 0));
		
		event.dur = event.dur * 2 * 70560 => _.asInteger;

		event.vocalMode.notNil.if{ this.voice.put(\vocalModePreset, event.vocalMode) };
		
		event.onset = [0] ++ event.dur.integrate => _.dropLast() + ( ( event.lag[0] ? 0 ) * 70560 * 2  );
		event.duration = event.dur * ( event.legato ? 1 ) => _.collect{|i| i.asInteger .asString ++ "0000"};
		event.onset= event.onset.collect {|i| i.asInteger.asString ++ "0000"};
		event.keys.reject({|i| [\dur,\legato,\vocalMode].includes(i) }).do{|key|
			envelopes.includes(key).if{|i|
				this.setEnv(key,event.at(key))
			} { this.setNotes(key,event.at(key)) }
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
	makeNotes {|num track=0|
		project.tracks[track].mainGroup.notes = notePrototype ! num
	}
	filterRests { |track=0|
		project.tracks[track].mainGroup.notes =
			this.notes.reject({|i| i.at(\lyrics)=="r"})
	}
	refreshBuffer{
		File.exists(location+/+"synthV_MixDown.wav").if{
		buffer = Buffer.doRead(Server.default,location+/+"synthV_MixDown.wav");
		}
	}
}

+ P {
	*synthV{ | key start params syl lag=0 take music song resources range filter pbind |

		var event;
		var section = P.calcStart(start );
		var synthV = SynthV(key,section,take );
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

		synthV.set(event); //set should filter for \r
		synthV.setDatabase(key);

		synthV.writeProject; 'synthV written!'.postln;
		take.notNil.if{key = key ++ "_" ++ take};
		^P(key,start,syl,lag, music,song,
			resources:(
				synthV: synthV,
				playbuf: { PlayBuf.auto(1,synthV.buffer.()) },
				take: take

			) ,
			); // order of section and key are reversed!!
	}
}
