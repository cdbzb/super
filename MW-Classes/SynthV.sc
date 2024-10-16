SynthV {
	// project.tracks[0].database = "AiKO Lite"
	classvar <>directory;
	classvar <notePrototype, <databasePrototype, <databaseLib;
	classvar <roles,<envelopes=#[ \toneShift, \pitchDelta, \voicing, \tension, \vibratoEnv, \loudness, \breathiness, \gender ];
	classvar <vocalModes;
	classvar <>buffers;
	classvar <>synthVsToRender;
	var <name, <project, <file,<location,<buffer, <key, <song, <section;
	var <>firstNoteOffset = 0;
	var <> offset = 0;
	var <>double, <>take;
	*new {|key name take double| 
			^super.new.init(key, name, take, double) 
		}
	*renderMultiple { |wait = 8.5 |
		fork{
			synthVsToRender.do{ |i| i.synthV.render; wait.wait };
			synthVsToRender = nil;
		}
	}
	*renderSection { |wait = 8.5|
		var section = Song.cursor;
		synthVsToRender = Song.at(section).select{|i| i.synthV.notNil };
		SynthV.renderMultiple(wait);
	}
	*initClass {

	directory = this.filenameSymbol.asString.dirname.dirname ++ "/SynthV";
		buffers = MultiLevelIdentityDictionary.new();

		roles = ();

		notePrototype = (
			'onset': 88200000,
			'duration': 1146600000,
			'pitch': 66,
			'detune': 0,
			'systemAttributes': (  ),
			'pitchTakes': (
				'activeTakeId': 0,
				'takes': 4.collect{|i| (liked: false, id: i, expr: 1.0) },
			),
			'lyrics': "la",
			'timbreTakes': (
				'activeTakeId': 0,
				'takes': 4.collect{|i| (liked: false, id: i, expr: 1.0) },
			),
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
				'languageOverride': "english",
				'phonesetOverride': "arpabet",
				'backendType': "SVR2AI",
				'version': "101"
			),
			kevin: ( 
				'name':             "Kevin",
				'language':         "english",
				'phoneset':         "arpabet",
				'languageOverride': "",
				'phonesetOverride': "",
				'backendType':      "SVR2AI",
				'version':          "108"
			),
			feng: (
				'name': "Feng Yi",
				'language': "mandarin",
				'phoneset': "xsampa",
				'languageOverride': "english",
				'phonesetOverride': "arpabet",
				'backendType': "SVR2AI",
				'version': "104"
			),
			an: (
				'name': "An Xiao",
				'language': "mandarin",
				'phoneset': "xsampa",
				'languageOverride': "english",
				'phonesetOverride': "arpabet",
				'backendType': "SVR2AI",
				'version': "105"
			),
			mo: (
				'name': "Mo Chen",
				'language': "mandarin",
				'phoneset': "xsampa",
				'languageOverride': "english",
				'phonesetOverride': "arpabet",
				'backendType': "SVR2AI",
				'version': "105"
			),
			teto: (
				'name': "Kasane Teto",
				'language': "japanese",
				'phoneset': "romaji",
				'languageOverride': "english",
				'phonesetOverride': "arpabet",
				'backendType': "SVR2AI",
				'version': "100"
			),
			asterian: (
				'name': "ASTERIAN",
				'language': "english",
				'phoneset': "arpabet",
				'languageOverride': "",
				'phonesetOverride': "",
				'backendType': "SVR2AI",
				'version': "101"
			),
			cheng: (

				'name': "Cheng Xiao",
				'language': "mandarin",
				'phoneset': "xsampa",
				'languageOverride': "english",
				'phonesetOverride': "arpabet",
				'backendType': "SVR2AI",
				'version': "100"
			),
			ninezero: (
				'name': "Ninezero",
				'language': "english",
				'phoneset': "arpabet",
				'languageoverride': "",
				'phonesetoverride': "",
				'backendtype': "SVR2AI",
				'version': "100"
			),
			jun: (
				'name':             "JUN",
				'language':         "english",
				'phoneset':         "arpabet",
				'languageOverride': "",
				'phonesetOverride': "",
				'backendType':      "SVR2AI",
				'version':          "100"
			)

		);
		synthVsToRender = List.new;
	}
	checkDirty {
		// ^project => JSON.stringify(_) != try{ String.readNew(File( file ,"r") )}
		File.exists(file).not.if{ 
			"no projectFile".postln;
			^true; };
		File.exists( location +/+ "raw" ).not.if{
			"no raw file".postln
			^true; 		
		} {
			"project != raw ".post;
			^project != Object.readArchive( location +/+ "raw" ) => _.postln;
		}
	}
	writeRawProject {
		project.writeArchive( location +/+ "raw" )
	}
	refresh {
		this.checkDirty.if{
			this.writeProject;
			this.render;
			try{ buffer.free };
			buffer = Buffer.doRead(Server.default,location+/+"synthV_MixDown.wav");
		}
	}
	render {
		take.notNil.if {
			directory +/+ "SCRIPTS/renderSynthV-recompute.sh".standardizePath + file =>_.unixCmd
		}{
			directory +/+ "SCRIPTS/renderSynthesizerV.sh".standardizePath + file =>_.unixCmd
		};
		this.writeRawProject
	}

	*load { |path|
		^String.readNew(path.standardizePath => File(_,"r")) => JSON.parse(_)
	}
	init{ |n k t d|
		name = n; double = d; take = t;
		// this.class.registry.put(n,k,(take ? \default),this);
		// key = k.asString.replace(Char.space,$_);
		key = k;
		\KEY.post;key.postln;
		song.isNil.if{ song = Song.currentSong };
		// section = song.section(key.replace($_,Char.space)); //does this do anything?
		section = key;
		directory = directory.standardizePath;

		location= directory +/+ ( song.key.asString.replace(Char.space,$-) ) +/+ Song.lyrics[Song.section(key)].hash.abs +/+ name; //change storage scheme here
		take.notNil.if{ location = location ++ "-" ++ take };

		file = location +/+ "project.svp";

		project = String.readNew(File( directory +/+ "test.svp"=>_.standardizePath,"r" ))
		=> JSON.parse(_);

		//strip erroneous points data - TODO clean this up in original file!
		project.tracks[0].mainRef.systemPitchDelta.put(\points,[]);

		this.refreshBuffer(n,k,(take ? \default));
	}
	writeProject {
		this.setRenderConfig;
		File.exists(location).not.if{File.mkdir(location)};
		this.checkDirty.if
		{
			// project.writeArchive( location +/+ "raw" );
			JSON.stringify( project ).write(
				file, overwrite: true, ask: false
			);
			// fork{0.05.wait;this.render}
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
			{ i == \vocalMode} {
				this.voice.put(\vocalModePreset, event.vocalMode);
				this.voice.put(\vocalModeParams, (( event.vocalMode ): 100))
			}
                        { i.asString.contains("param") } { this.voice.put(i, event.at(i))}
                        { i == \defaultVibratoDepth}     { this.voice.put(\dF0Vbr,event.at(i))}
                        { envelopes.includes(i)}         { this.setEnv(i,event.at(i))}
                        { i == \language }               { \LANGUAGE.postln; project.tracks[0].mainRef.database.put(\languageOverride,event.at(i)).postln }
                        { i == \phoneset}                { project.tracks[0].mainRef.database.put(\phonesetOverride,event.at(i)) }
			{ i == \pitchTake}               { this.setPitchTakeId(event.at(i)) }
			{ i == \pitchExpression }        { this.setPitchExpression(event.at(i)) }
                        { true }                         { this.setNotes(i,event.at(i)) }
		};
		//this should be done with an array flop and pairsDo instad but...
		this.filterRests 
	)
	}
	setNote {| index key value|
		
		key.post;" ".post;value.postln;
		this.notes[index].put(key,value);
	}
	setNotes { |key array| //can use an integer or shorter array
		// array.do{|i x|
		// 	this.setNote(x, key, i)
		// }
		( array.rank==0 ).if{array = array.bubble};
		this.notes.do{|i x| this.setNote(x, key, array.clipAt(x))}
	}
	setPitchTakeId {|id|
		this.notes.do{|i x| this.notes[x].pitchTakes.put(\activeTakeId,id)}
	}
	setPitchExpression { |array|   // puts the values in all the takes
		( array.rank==0 ).if{array = array.bubble};
		this.notes.do{ |i x|
			this.notes[x].pitchTakes.takes.do{ |take takeNumber|
				take.put( \expr, array.clipAt(x) )
			}
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
		Post  << "findPartBefore " << name << "\n";

		^ Song.pts
		.select{|i| i.name.contains(name.asString)}
		.select{|i| take == i.synthV.take}
		// .select{|i| i.name.contains(key.asInteger - 1 => _.asString and: not( i.name.contains(  ) ) )}
		.select{|i| "(?<![0-9])"++( key.asInteger - 1 ) =>_.matchRegexp(i.name.asString)} //match 5 but not 15
		.unbubble
	}
	
	prependNotes {|section synthV track=0|
		var last = { this.findPartBefore.synthV.notes.last }.try({ "couldnt find part before!!".postln; this.dump.postln}) ;
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
	refreshBuffer{ |n k t|
		var old = buffers.at(n,k,t).();
		File.exists(location+/+"synthV_MixDown.wav").if{
			try{old.().free};
			buffer = Buffer.doRead(Server.default,location+/+"synthV_MixDown.wav");
		try{ buffers.put(n,k,(take ? \default),buffer) };
		}{\NEEDS_RENDER.postln};
	}
}

+ P {
	*double{| key start take params music filter pbind role wait|
		var section = P.calcStart(start); 
		var original = Song.currentSong.at(section)
		.select({|e|
			e.name.contains (key.notNil.if{key.asString}{Trek.cast.at(role).asString} ) 
		})
		.select({|e|
			take.isNil.if{true}{e.name.contains(take.asString)}
		})
		.reject{|e|
			e.name.contains("dbl")
		}[0];
			Post << "section " << section << "name " << name << " original " << original << "\n";

			^P.synthV(
				key, 
				start: section,
				// wait:1,
				role: role,
				params:original.params,
				// double:true,
				take:original.take ++ "-dbl" => _.asSymbol,
				music:music,
				filter:(filter ? original.filter),
				pbind: (pbind ? original.pbind)
			)
	}
	*synthVs { | key start params syl lag=0 take double music song resources range filter pbind prepend role wait |
		var section = P.calcStart(start );
		song = song ? Song.currentSong;
		SynthV.synthVsToRender = List.new;
		[  key, start, params.(
			song,
			song.durs[section].list, //drop range
			key
		).flop.collect{|i| {i}}, syl, lag=0, take, double, music, song, resources, range, filter, pbind
		// .(
		// 	song,
		// 	song.durs[section].list, //drop range
		// )
		, prepend, role, wait, ].flop.do{|i x|
/* 			[ i[0]++x ] ++ i.drop(1) //makes keys \sargon0, \sargon1 */
			i.postln
			=> P.synthV(*_)
			=> {|i| SynthV.synthVsToRender.add(i) }
		};
	}
	*synthV{ | key start params syl lag=0 take double music song resources range filter pbind prepend role wait|
		var event;
		var section = P.calcStart(start );
		var synthV;
		song = song ? Song.currentSong;
		role.notNil.if{
			key = Trek.cast.at(role);
		};
		synthV = SynthV(key,( start ? section ),take ,double );
		pbind = pbind.notNil.if{  // pass in a pbind or get it from the song
			{ pbind.value(song,song.durs[section].list) }.try{ Song.currentSong.pbind[section] }
		} {
			Song.currentSong.pbind[section] 
		};
		event = pbind.patternpairs.collect{|i|
			( i.class==Pseq ).if{i.list}{i}
		}
		++ Trek.at(role, key)
		++ try{ Trek.at(role, key, take) }
		++ params.value(
			song,
			song.durs[section].list, //drop range
			key
		) 
		++ ( take.asString.contains("dbl")).if{ [pitchTake: 3] } // last of 4
		=> Event.newFrom(_);

		filter = filter ? event.removeAt(\filter);
		event => {|i| 
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
			}
		};
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
				playbuf: {
					var buf = synthV.buffer.();
					PlayBuf.auto(
					1,
					buf,
					startPos: ( synthV.offset ) * BufSampleRate.kr( buf ),
					doneAction:0
				)},
				take: take,
				params: params,
				filter: filter,
				pbind: pbind
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
	renderSynthV{ |pause = 12|
		var synthVs = Song.pts.select{|i| i.synthV.notNil }.collect(_.synthV);
		fork {
		synthVs.do{|i x|
				i.render;
				Post << x << " of " << synthVs.size << "\n";
				pause.wait;
			}
		}
	}
	dirtySynthVs{
		^ this.pts.select{|i| i.synthV.notNil }
		.collect{|i| i.synthV}
		.select{|i| i.checkDirty}
	}
	renderDirty { |wait = 12|
		fork{ 
			this.dirtySynthVs.do{ 
				|i|
				i.render;
				wait.wait
			};
			// thisProcess.nowExecutingPath.load
			// Song.currentSong.loadedFrom.load
		}
	}
	renderAllSynthVs { |wait = 10|
		fork{
			this.pts.select{|i| i.synthV.notNil}.do{
				|i|
				i.synthV.render;
				wait.wait
			}
		}
	}
}
+ SimpleNumber {
	secondsToBlicks {
		^this * 2 * 70560 => _.round() => _.asInteger => _.asString ++ "0000"
	}
}
