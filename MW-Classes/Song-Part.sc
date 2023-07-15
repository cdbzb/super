Song {
	classvar lastSectionPlayed=0;
	classvar <reaperFolder, <>dursFile, <>dursFolder;
	classvar <songs;
	classvar <>current;
	classvar <>loading;
	classvar <>songList;
	classvar <>muteList,<muted;
	var <lyricWindow,lyricWindowText;
	var <song, <key, <cursor=0, sections, <lyrics, <tune; 
	var <durs,  <>resources, <>lyricsToDurs;
	var <>next;
	var <>quarters, <>tempoMap;
	var <>clock;
	var playInitiatedAt,<>preroll=0;
	var <secLoc, <secDur, <pbind;
	var <>loadedFrom;
	var scrollOn = false;
	classvar <>lastPlayOnly;
	classvar <>muteTunes;

	*initClass {
		reaperFolder = this.filenameSymbol.asString.dirname.dirname +/+ "RPP";
		dursFile=this.filenameSymbol.asString.dirname.dirname +/+ "theExtreme3";
		dursFolder=this.filenameSymbol.asString.dirname.dirname +/+ "Dur";
		// Archive.archiveDir = this.filenameSymbol.asString.dirname.dirname;
		Class.initClassTree(Recorder);
		songs= Dictionary.new;
		loading = CondVar();
		muteList = List[];
		muted = List[];
	}
	*new { 
		|key array dursInFile resources|
		^super.new.init(key, array,dursInFile, resources);
	}
	*mute { |symbol|
		symbol.notNil.if{ muted.add(symbol); }{muted = List[]};
		^muted
	}
	*unmute { |symbol|
		symbol.notNil.if{ muted.remove(symbol) }{muted = List[]}
	}
	*rhythm { |section=0 length=1 cueSections=1 | //this method uses arg section - use rhythmRecorder to use cursor (should rename!)
		this.currentSong.cursor = this.currentSong.section(section);
		this.rhythmRecorder(length, cueSections);
	}
	*rhythmRecorder { // 
		|  length=1 cueSecs=1 |
		var rnge=[Song.cursor, Song.cursor + length -1];
		var stepper;
		var song = Song.currentSong;
		var synth,recorder,a;
		var range = Array.with(rnge).flatten;
		var seq = (range[0]..range.clipAt(1))
		.collect({|i|song.tune[i].list}).flatten;
		seq.postln;
		stepper={ |seq|
			var rests = seq.collect{|i| ( i == \r ).if{0}{1} };

			seq = seq.collect{|i| ( i == \r ).if{400}{i} };

			SynthDef(\stepper, { |t_trigger=0|
				var note = Demand.kr(t_trigger + KeyState.kr(38)-0.1,0, Dseq.new(seq.midicps));
				var amp = Demand.kr(t_trigger + KeyState.kr(38)-0.1,0, Dseq.new(rests.midicps));
				var sig=SinOsc.ar(note,0,EnvGen.kr(
					Env.perc(0.01,1,0.1)
					,gate:t_trigger + KeyState.kr(38)-0.1
				));
				Out.ar(1,sig * amp * 0.1);
			});
		};
		stepper.(seq).add;
		recorder=( // function returns this pseudo-object and calls makeWindow on it
			range:range,
			time:Main.elapsedTime,
			item:List.new,
			cue:{
				|self|
				var range=(self.range[0]-(cueSecs-1)-1..self.range[0]-1);
				("range"++range).postln;
				(self.range[0]>0).if(
					{var seq = range.collect({|i|song.pbind[i]});
					Pseq(seq);},
					//{song.pbind[nextTune-1]},
					(type:\rest)
				)
			},
			captureLoop:{
				|self char|
				Routine ({
					loop {
						self.item = self.item.add(Main.elapsedTime-self.time); 
						synth.set(\t_trigger,1);
						self.time=Main.elapsedTime; 
						char = 0.yield; 
					}
				})
			},
			window:nil,
			makeWindow: {
				|self| var w=Window.new.alwaysOnTop_(true).front.alwaysOnTop_(true);
				var b=Button.new(w.view,Rect(60,10,100,100))
				.states_(["1",Color.black,Color.white])
				.action = {self.doOver;"do over".postln};
				var c=Button.new(w.view,Rect(160,10,100,100))
				.states_(["1",Color.black,Color.white])
				.action = { var a = self.ret;a.postln};
				var d=Button.new(w.view,Rect(260,10,100,100))
				.states_(["1",Color.black,Color.white])
				.action = {self.nextt;"next".postln};
				var e=Button.new(w.view,Rect(260,300,100,100))
				.states_(["1",Color.black,Color.white])
				.action = {song.save};
				var v=w.view;
				////////// MIDI FUNCTION //////////
				//							XTouch.addKey({
				//								Pipe("osascript -e 'tell application \"System Events\" to keystroke \"j\"'","w")
				//							},\f8);
				self.window=w;
				StaticText(b,Rect(0,0,100,100)).string_("Do over").align_(\center);
				StaticText(c,Rect(0,0,100,100)).string_("Return").align_(\center);
				StaticText(d,Rect(0,0,100,100)).string_("next").align_(\center);
				StaticText(e,Rect(0,0,100,100)).string_("save").align_(\center);
				EZText.new(v,Rect(0,110,300,50	),label:"range",initVal:self.range,);
				v.keyDownAction={ |view char|
					self.captureLoop.(b); 
					switch(char,
						$d , {self.doOver},
						$n , {self.nextt},
						$r , {self.ret},
						$s , {song.save},
						$w , {self.window.close;},
						$q , {self.window.close;}
					)
				};
				self.item=[];
				fork{Server.default.sync; synth=Synth(\stepper); a=synth };
				w.onClose_({synth.free});
				self.cue.play ;
				self.range.do({|i|song.lyrics[i].postln});
				self
			},
			doOver:{|self| self.item=[];self.cue.play;synth.free;synth=Synth(\stepper)},
			nextt:{|self| 
				self.range=(self.range+(self.range.clipAt(1)-self.range[0]+1));
				self.range.do({|i x| (i>(song.sections-1)).if {self.range[x]=(song.sections-1).asInt}}); // check if range too high
				(self.range++" "++song.sections).postln;
				self.window.close;
				{
					var newSeq=self.range.collect({|i|song.tune[i].list}).flatten;
					stepper.(newSeq).add;
					Server.default.sync;
					self.makeWindow
				}.fork(AppClock)
			},
			ret: {|self|
				var recorded =self.item.round(0.001)[1..(self.item.size)];
				recorded.postln;
				( self.range[0]..self.range.clipAt(1) ).do({|i|
					var returnChunk=List.new;
					var elements=song.tune[i].list.size;
					elements.do(
						{|i|
							if(recorded.size>0)
							{returnChunk.add(recorded.removeAt(0)) }
						}
					);
					(returnChunk[0].isNil.not).if{song.durs[i]=Pseq(returnChunk)} ;
				});
				//~xtreme.durs[nextTune]= Pseq(recorded);
			};
		).makeWindow;
		fork{
			Server.default.sync;
			'registering midifunc'.postln;
			MIDIFunc.noteOn({
				recorder.captureLoop.();
				synth.set(\t_trigger,1);
				synth.postln}
			)}
	}
	*playArray { |array|
			fork{
				array.do({|i|
					{ songs.at(i).valueInfrastructure }.try;
					{ songs.at(i).condition.wait }.try;
				});
				array.do({|i|
					{ songs.at(i).current }.try;
					{ songs.at(i).playParts }.try;
					{ songs.at(i).durTillEnd.wait }.try;
				})
			}
	}
	*currentSong {
		^songs.at(current)
	}
	*play { |...args|
		( args.size == 0 ).if{ 
			songList.isNil.if{
				songs.at(current).play 
			}{
				this.playArray(songList)
			}		
		}{
			fork{
				args.do({|i|
					songs.at(i).valueInfrastructure;
					{ songs.at(i).condition.wait }.try;
				});
				args.do({|i|
					songs.at(i).playParts;
					songs.at(i).durTillEnd.wait;
				})
			}
		}
	}
	makeScroll {
		Song.sections.do{ |x|
			P(\scroll,start:x,music:{ |p b e|
				Song.scroll(x)
			})
		}
	}
	showLyricWindow {
		lyricWindow = Window.new(bounds:Rect(0,00,1040,200))
			.background_(Color.clear)
		;
		lyricWindowText = StaticText.new(lyricWindow,  bounds: Rect(0,0,1040,300))
			.align_(\center)
			.font_(Font(\helvetica,40,bold:true))
		;
		Song.currentSong.sections.do{ |i| 
			P(\lyric, start:i, music:{ |p b e|
				lyricWindow.front;
				{
					lyricWindowText.string_(Song.lyrics[i])
					.stringColor_(Color.rand)
				}.defer
			})
		}
	}
	closeLyricWindow{
		lyricWindow.close
	}
	*doesNotUnderstand { |selector   ...args|
		songs.at(current).respondsTo(selector).if{
			^Message(songs.at(current),selector).value(*args)
		} {
			var key = selector.asString;
			key.endsWith("_").if{
				key=key.replace("_","").asSymbol;
				^this.currentSong.resources.put(key, *args);
			} {
				^Song.currentSong.resources.at(key.asSymbol)
			}
			//^songs.at(selector)
		}
	}
	init {|symbol array dursInFile r|
		loadedFrom = thisProcess.nowExecutingPath;
		resources = r;
		key=symbol;
		songs.at(symbol.asSymbol).notNil.if {cursor=lastSectionPlayed};
		songs.put(symbol.asSymbol,this);
		song=array;
		resources=();
		//sections=(song.size/2).asInteger;
		lyrics=song.copySeries(0,2,song.size);
		tune=song[1,3..song.size].collect({|i|
			case {i.class==String} { Panola.new(i).midinotePattern }
			{i.class==Array } {i.q}
		});
		this.setupLyricsToDurs;
		durs=Durs(this);
		clock=TempoClock.new(queueSize:512);
		quarters=SongArray(key:key);
		tempoMap=SongArray(key:key);
		secLoc = SectionAccessor({ |i| 
			Song.currentSong.secDur[..(i-1)].sum
		});
		secDur = SectionAccessor({ |i|
			Song.currentSong.durs[ i ].list.sum
		});
		pbind = SectionAccessor({ |i|
			Pbind(\dur,Song.currentSong.durs[i],\midinote,Song.currentSong.tune[i])
		})

	}
	reload {
		loadedFrom.load // loads last saved version
	}
		cursor_ {|i| cursor = i; lastSectionPlayed = i; ^i}
	scroll { |section|
		var lyric = this.lyrics[this.section(section)];
		// Need to excape [ and ]  !!!
		var luacode = "vim.fn.search(\"%\")"
		// "print(match_pos)"
		// "vim.api.nvim_win_set_cursor(0,{match_pos, 0 })"
		.format(lyric);
		Post << "lua code" <<luacode;
		SCNvim.luaeval(luacode)
	}
	hasDursButNotLyricsToDurs {
		// Is there a file in the Dur folder?
		File.exists(dursFolder +/+ key).if{
			^false
		} { 
			// otherwise check the old Archive file (ie theExtreme)
			Archive.at(key).isNil.not.if({
				Archive.at((key++"lyricsToDurs").asSymbol).isNil.if(
					{ 
						^true 
					},{ 
						^false 
					})
				},{
					^false
				}
			)
		}
	}
	writeDurs {|section|
		File("/tmp/durs","w").write(Song.durs[section].list.asString.replace("List","")++".addDurs;").close
	}
	sections { ^( song.size / 2 ).asInteger }
	addLine { |line| //array
		line[1].isNil.if{line=line++["r"]};


		//TODO merge lyricsToDurs with Archive when saving!!
		this.hasDursButNotLyricsToDurs.if{
			lyricsToDurs.add(line[0] -> Archive.at(key)[sections]);
		};
		song=song++line[0..1]; 
		lyrics = lyrics.add(line[0]);
		tune = tune.add(
			case 
			{line[1]=="r"} {[\r].q}
			{line[1].class==Array } {line[1].q}
			{line[1].class==String} { Panola.new(line[1]).midinotePattern}
		).postln;
		
		line[2].notNil.if{
			durs.put(line[0].asSymbol,(line[2]).q);
		};
		^Song.sections-1;
	}
	addDurs {|array|
		durs[sections-1]=array.q
	}
	writeLyricDurationFile {
		File.exists(dursFolder +/+ key).if{
			File.exists(dursFolder +/+ 'Old').not.if{"mkdir "++dursFolder+/+'Old'=>_.unixCmd};
			//move to old
			File.copy(dursFolder +/+ key , dursFolder +/+'Old' +/+ key ++ Date.getDate.stamp)
		};
		lyricsToDurs.writeArchive(dursFolder +/+ key);
	}
	setupLyricsToDurs {
		// Load from file, otherwise fall back to archive
		File.exists(dursFolder +/+ key).if{
			lyricsToDurs = Object.readArchive(dursFolder +/+ key)
		} {
            "checking durs file".postln;
            Archive.read(dursFile);
            Archive.at((key++\lyricsToDurs).asSymbol).isNil.not.if {
                "loading from archive".postln;
                lyricsToDurs = Archive.at((key++\lyricsToDurs).asSymbol)
            } {
                lyricsToDurs= Dictionary.new(128);
                this.writeLyricDurationFile;
                }
		}
	}
	setupDurs {
		Archive.read(dursFile);
		Archive.at(key).isNil.not.if(
			{
				var a=Archive.at(key);
				//durs=a++(Pseq([1])!(sections-a.size)); //copy or pad
				lyricsToDurs = Archive.at((key++\lyricsToDurs).asSymbol);
			},{
				durs=Pseq([1])!sections
			}
		);
			
	}
	rebuildLyricstoDurs {
		lyricsToDurs = Dictionary.new(sections);
		lyrics.do{|i x| lyricsToDurs.add( i -> durs[x] ) };
	}
	save { 
        File.exists(dursFolder +/+ key).if{
			this.writeLyricDurationFile;
			'file written'.postln;
		} {
			var location = (key++\lyricsToDurs).asSymbol;
			var merge=Archive.global.at(location) ? Dictionary.new(128);
			lyrics.do{|i| merge.add(i -> lyricsToDurs.at(i))};
			Archive.global.put(location, merge);
			'loc '.post;location.post;' merge '.post;merge.postln;
			Archive.write(dursFile);'archive written'.postln 
		}

	}
	backup {
		var backup = dursFile++Date.getDate.stamp;
		Archive.write(backup); 'archive backed up to '.post;backup.postln}
	durTill {|sec till|
		var list= durs[sec].list;
		^list[0..till].sum
	}
	postLyrics {
		lyrics.do{|i x| (x.asString++' '++i).postln}
	}
	pbindFrom {|from=3| 
		var list = this.pbind[from.asInteger..(sections-1)].postln;
		^Pseq(list)
	}
	pts {^all {:x,x<-resources,x.class==Part}}
	part {|name, section| 
		var key;
		//section = section ? "";
		section = section.notNil.if {this.section(section).asString}{""};
		key = name++section => _.postln;
		^this.pts.select({|i| i.name contains: key })[0].unbubble
	}
	partsWith {|key| ^all{:x,x<-this.pts,x.name.asString.contains(key.asString)}}
	playOnly {|...args|
		var strings;
		(args.size == 0).if{ strings  = lastPlayOnly }{strings = args};
		lastPlayOnly = strings;
		strings.collect{|i| this.partsWith(i)}.reject{|i| i.isNil}.flat.do(_.p)
	}
	track { 
		|trackName| 
		trackName=trackName.asString;
		^this.pts.collect(_.name)
			.select(_.contains(trackName))
			.sort
	}
	valueInfrastructure {
			  resources.condition !? (_.test_(false));
			this.resources.at(\infrastructure) !? (_.value);
	}
	playParts { |...args|
		this.getPartsList(args).sort({|i j| try{ i.start<j.start }}).do(_.p)
	}
	chain {
		songList=[key,next];
		songList.postln;
	}
	play { |...args|
		var list = this.getPartsList(args);
		var first = try{ list.select{|part| { part.start } == cursor} };
		var wait = try{ first.select{|part| part.lag < 0}.collect({ |part| part.lag }).sort[0] };
		wait.notNil.if {Song.preroll_(wait.abs + Server.default.latency + 0.1)};
		playInitiatedAt = SystemClock.seconds;
		fork{
			//resources.condition ? resources.condition.test_(false);
			resources.condition !? (_.test_(false));
			this.resources.at(\infrastructure) !? (_.value);
			resources.condition !? _.wait;
			'Condition Met'.postln;
//			1.wait;
			Server.default.sync;
			fork{ list.do(_.p) }
			//list.do(_.pAbs)
		}
	}		
	playAfterLoad {
		fork{
			loading.wait;
			this.play
		}
	}
	current {
		current = key;
		songList = nil;
		key.postln;
	}
	getPartsList { |args|
		var a =
		case
		{(args==[])}{this.pts}	
		{true}{args.flatten};
		^this.getParts(a)
	}
	getParts { |list|
		list.postln;
		( muteTunes == true ).if{ list=list.select{|i| i.name.contains( "TUNE" )} };
		list = list.reject{ |i|
			muted.collect{ |m|
				var res = i.resources.at(m).notNil or:  i.name.asString.contains(m.asString);
				res.postln
			}
			.inject(false, _ or: _ )
		};
		^list.collect{|x|(x.class==Symbol).if({resources.at(x)},{x})}
	}
	///these are for backwards compat
	parts {|selector event| 
		^this
	}
	asPart { |event|
		var part=Part();
		part.music=event.at(\music);
		part.lag=event.lag;
		part.syl=event.syl;
		part.start=event.start;
		part.parent=this;
		^part;
	}
	at {|...args|
		var array;
		array = all {:x,x<-this.pts,args.flatten.includes(x.start)};
		array.do({|i|i.name.postln})
		^array
	}
	playSection {|sec| //uses play method which prepares infrastructure
		sec=this.section(sec);
		cursor=sec;
		this.play(this.at(sec))
	}
	playRange { |start end |
		var from,to;
		# from, to = [start, end].collect{
			|sec| ( sec.class==Integer ).not.if{ sec = this.section(sec) }{sec};
		};
		this.cursor_( from );
		(from..to).do{
			|sec| this.play(this.at(sec))
		}
	}
	screengrab { |start end path tail=2|
		//var player = P(start:) -- this would make it start with the music
		var length = (start..( end ? start )).collect(this.secDur[_]).sum;
		length.postln;
		path.postln;
		//-G to add an audio source
		fork{
			"screencapture -V" + length + path => _.unixCmd
		}

	}
	playSectionParts {|start end| // uses .p method which doesn't prepare infrastructure
		start = this.section(start);
		end.notNil.if{ this.section(end) }{start};
		cursor=start;
		(start..end).do {|i| this.at(i).do(_.p) }
	}
	recordSection { |start end bus path channels=2 tail=3|
		var s = Server.default;
		fork{
			s.recSampleFormat = \int16;
			s.prepareForRecord(path);
			s.sync;
			this.playSectionParts (start, end); // latency is added here due to use of p
			Server.default.latency * 2 => _.wait; // double latency
			s.record(
				bus:bus,
				duration:(start..end).collect(this.secDur[_]).sum + tail
			);
			}
	}
	makeVid { |start end dir tail=2| // check Sync
		var now = Date.getDate.stamp;
		var path = dir +/+ now;
		//preroll = 0.5;
		start = Song.section(start);
		end = Song.section(end);
		fork{
			P(\video, start:start,lag: 0,music: { |p b e|
					p.screengrab(start,end,path ++ ".mov",tail);
			});
			this.cursor_(start);
			Song.recordSection(start,end,0, path ++ ".aif",2, 0);
			while ( {File.exists(path++".mov") == false},{0.1.wait} );
			tail.wait;
			try{ Server.default.stopRecording };
			0.1.wait;
			"ffmpeg -i" + path ++ ".mov" + "-i" + path ++ ".aif" + "-c copy -map 0:v:0 -map 1:a:0" + path ++ "screenCapture.mov" => _.unixCmd;
			5.wait;
			"ffmpeg -i" + path++"screenCapture.mov" + "-filter:v fps=30" + path++"30fps.mov" => _.unixCmd

			//"ffmpeg -i" + path ++ ".aif" + "-itsoffset 1 -i" + path ++ ".mov" + "-c copy -map 0:v:0 -map 1:a:0" + path ++ "together.mov" => _.unixCmd
		}
	}
	recordOBS { |start end dir="/tmp" tail=2|
		var now = Date.getDate.stamp;
		var path = dir +/+ now;
		//preroll = 0.5;
		(Server.default.options.outDevice == "BlackHole 2ch").if
		{
			Song.makeScroll;
			start = Song.section(start);
			end = Song.section(end);
			Song.playRange(start,end);
			fork{
				Server.default.latency.wait;
				"obs-cli --password Where4obs recording start".unixCmd;
				(start..end).collect(Song.secDur[_]).sum.wait;
				tail.wait;
				2.wait;
				"obs-cli --password Where4obs recording stop".unixCmd;
			}
		}{
			Monitors.blackHole;
			Server.default.waitForBoot{
				this.load;
				{
					3.wait;
					this.recordOBS(start, end, dir, tail)
				}
			}
		}

	}
    // TRASHME
    reaperSection {|sec range=1 tail=5| 
        var path;
        var reaperProjectPath = reaperFolder +/+ key;
        var section = this.section(sec);
        var s = Server.default;
        File.exists(reaperProjectPath).not.if(File.mkdir(reaperProjectPath +/+ "media"));
        path=reaperProjectPath +/+ "media" +/+ sec.asString ++ ".wav";
        fork{
            s.prepareForRecord(path);
            0.1.wait;
            Song.cursor_(section);
            range.do(
                { |i|
                    Song.currentSong.play(Song.at(section+i));
                }
            );
            s.record(duration: range.collect{|i| Song.secDur[ i ]}.sum + tail);
            (range.collect{|i| Song.secDur[ i ]}.sum + tail + 0.5).wait;
            Reaper.buildVocalRPP(path,durs[sec].list,reaperProjectPath)
        };

    }
	section {|section| 
		//returns section number which contains lyric
		section.isInteger.if{^section}
		{
			var array = (..lyrics.size-1).select{|i |lyrics[i].asString.contains(section.asString)};
			(array.size>1).if{'!!! more than one section with: '.post;section.postln; array.postln};
			( array.size==0 ).if{'no section with: '.post; section.postln; ^-1}

			{ ^array[0] }
		}
	}
	contains {
		|string|
		var array = all{ :x, x<-resources.keys,
			var y=resources.at(x.asSymbol),
			y.class==Part,
			(x.asString).contains(string) 
	};
	array.postln;
	^array.collect{|i| resources.at(i)};
	}
	addPart {|key part| 
		resources.put(key,part);
		part.name=key;
		part.parent=this;^resources}
	durTillEnd {
		^this.secDur[cursor..(sections-1)].sum
	}
	durFromTo { | from to|
		from = Song.section(from);
		to = Song.section(to);
		^(
			(from .. to)
			.inject(0,{|x y| x + Song.secDur[y]})
			- Song.secDur[to]
		)
	}
	rppOffset { | e |
		^( this.durFromTo(e.rpp.section,e.start).abs + 1 * e.rpp.buffer.().sampleRate )
	}
	getSection {|a| 
		a.isNil.if{a=sections};
		(a.class==String).if{a=a.asSymbol};
		(a.class==Symbol).if({
			^this.section(a)
		},{
			^a
		})
	}

	getStartString { |x|
		var a=this.lyrics.collect( { |i| i.asString.split($ ).collect(_.asSymbol)} );
		var q={|array index| array.keep(index)++array.copyToEnd(index + 1)};
		var start = a[x].difference(q.(a,x).flat);

		var luacode = "local pos = vim.api.nvim_win_get_cursor(0)[2] ;"
		" local line = vim.api.nvim_get_current_line() ;"
		" local nline = line:sub(0, pos) .. \"%\"  .. line:sub(pos + 1) ;"
		" vim.api.nvim_set_current_line(nline) ;"
		.format(start[0]);
		SCNvim.luaeval(luacode)

	}
	returnStartString {|x|
		var a=this.lyrics.collect( { |i| i.asString.split($ ).collect(_.asSymbol)} );
		var q={|array index| array.keep(index)++array.copyToEnd(index + 1)};
		var start = a[x].difference(q.(a,x).flat);
		^start[0]
	}
	parse {|phrase array start=0| 
		var counter = 0;
		var beatNum; 
		phrase=this.getSection(phrase);
		//expand numbers greater than one
		//doesn't currently support numbers greater than one in sub-arrays
		//or decimal numbers greater than one
		array=array.deepCollect(2,{|i| 
			//( i.class==Integer ).if{
			(i>1).if{ 1.dup(i) }{ i }
			//}{
			//		i
			//	}
		});
		array=array.collect{|i| i.isArray.if({i.flatten},{i})};
		beatNum = array.flatten.collect{|m i| array.flatten.[0..i].sum};
		array.postln;
		beatNum = beatNum.collect{|i|(i-0.001).floor};
		^array.collect{ |item|
			item.isArray.not.if(
				{
					var b = beatNum[counter];
					counter =counter+1;
					item*durs[phrase].list.clipAt( b+start )
				},{
					var subArray = item.collect{
						|i x| 
						var b = beatNum[counter+x];
						i*durs[phrase].list.clipAt( b+start )
					}; 
					counter=counter+item.size; 
					subArray.sum;
				}
			);
		}
	} 
	parseBeats { |phrase array start=0|
		var beatCounter, result, desiredLength, denominators;
		array = array.drop(start);
		beatCounter = List.new; denominators = List.new;
		result = List.new;
		desiredLength = array.sum;
		phrase=this.getSection(phrase);
		array=array++1;
		array.do{
			|i|
			var denominator = i;
			\looptop.postln;
			case 
			{i < (1 - beatCounter.sum)}{
				\less.postln;
				denominators.add(denominator);
				beatCounter.add(i);
				i.postln;\less.post;beatCounter.postln;
			}{i == (1-beatCounter.sum)}{
				\equals.postln;
				denominators.add(denominator);
				beatCounter.add(i);
				( beatCounter.size==1 ).if({result.add(1)},{result.add(beatCounter/denominators)});
				beatCounter=List.new;denominators=List.new;
			}{i > (1 - beatCounter.sum)}{
				while ( {i > (1 - beatCounter.sum)},{
					i = i-(1-beatCounter.sum);
					((1-beatCounter.sum)>0).if {
						beatCounter.add(1-beatCounter.sum);
						denominators.add(denominator);
					};
					( beatCounter.size==1 ).if(
						{result.add(1/denominators[0])},
						{result.add(beatCounter/denominators)});
						beatCounter=List.new;denominators=List.new;
					} );
					denominators.add(denominator);
					beatCounter.add(i);
				}
			};
			//sanity check - if result is 1 too long
			(result.size>desiredLength).if{result=result[0..(result.size-2)]};
			^this.parse(phrase,result,start)
}
	addGuides {|string|
		string.isNil.if{string="x"};
		string=string.reject(_==$|);
		string.clipExtend(this.sections)
		.do({|i n|
			(i==$x).if{
				var label=("guide"++n).asSymbol;
				this.addPart(label,Part(start:n,music:this.pbind[n]))
			}
		}
	)
}
	doesNotUnderstand { |selector   args|
		var key = selector.asString;
		key.contains($_).if
		(
			{
				key=key[..key.size-2];
				(args.class==Event).if{Part.current=this.asPart(args);args=this.asPart(args)};
				resources.put(key.asSymbol,args);
				args.postln;
				(args.class==Part).if{
					args.name=key;
					args.parent=this;
					Part.current=args;
					(args.music.class==Event).if{
						args.music.b=this.durs[args.start].list.drop(args.syl?0);
						args.music.p=this;
						args.music.e=args;
					};
				};
			},{
				^resources.at(key.asSymbol);
			}
		)
	}
    setQuarters { |section array|
	    ( array.class == String ).if{ array = array.asBeats } ;
        quarters[section] = this.parseBeats(section,array).q
    }
    setTempoMap {| section array|
	    ( array.class == String ).if{ array = array.asBeats.collect({|i| (i==0).if{0.000001}{i}}) } ;
	    ( Song.section(section)!=(-1) ).if
	    {
		    tempoMap[section] = TempoMap(array, durs[section].list)
	    }
    }
    asBeatsPickup {|section string |
	    string.contains( "|" ).if{
		    var pickup,beats;
		    # pickup,beats = string.split($|);
		    pickup = pickup.split(Char.space).reject{|i| i==""}.size; // how many notes
		    'pickup '.post;pickup.post;'beats '.post;beats.post;
		    string = string.reject{|i| i== $|}.reject{|i| i==""};
		    //^this.setQuartersPickup(section,string,pickup)
	    ^quarters[section] = this.durs[section].list[0].bubble ++ this.parseBeats(section,string, start: pickup)
	    }
    }
    setQuartersPickup { |section array pickup| // one pickup note only
	    ( array.class == String ).if{ array = array.asBeats } ;
	    //^ array[0].bubble ++ this.parseBeats(section, array, start: 1)
	    quarters[section] = this.durs[section].list[0].bubble ++ this.parseBeats(section, array, start: pickup)
    }
    playIncremental {
	    var parts = Song.currentSong.pts;
	    var order = parts.collect(_.start);
	    var a = fork{
		    ///;/NOPE need to play all the parts in each section!
		    this.sections.do{|i|
			    this.cursor_(i);
			    this.[i].do(_.p);
			    nil.yield 
		    };
		    parts.do{
			    |i|
			    i.play.yield;
			    i.start.postln;
		    }
	    };
	    var w = Window.new().front;
	    var v = w.view;
	    v.keyDownAction={ |view char|
		    a.resume;a.postln

		    //	$d , {self.doOver},
		    //	$n , {self.nextt},
		    //	$r , {self.ret},
		    //	$s , {song.save},
		    //	$w , {self.window.close;t.free},
		    //	$q , {self.window.close;t.free}
	    };
	    ^a
	    // play in loop waiting for trigger before advancing
	}
	length {
		^sections.collect(this.secDur[_]).sum
	}
	allNotesOff {
		resources.vstis.postln;
		resources.vstis !? _.do{|i| 
			(type:\vst_midi, vst:i.controller, midicmd:\allNotesOff).play
		}
	}
	span { | e |

		//stripping out section number should be fixed!!
		this.at(e.start+1).select({|i| i.name.contains(e.name.dropLast.dropLast.asString)}).postln.unbubble.span_(true);
	}

	enlarge { | numNotes start|  //number of notes to add from next pattern
		// var b = Song.durs[key].list; p=Song;
		var key= start ? P.calcStart();
		numNotes = numNotes - 1;

		Post << "numnotes " << numNotes << "\n";
		^{|p b| 
			[
				dur: b ++ p.durs[p.section(key)+1].list[0..numNotes]
				=> _.q => _.postln,
				midinote:p.tune[p.section(key)].list 
				++p.tune[p.section(key)+1].list[0..numNotes] => _.q 
			].p
		}
	}

	enlarge2 { | numNotes start|  //number of notes to add from next pattern
		// var b = Song.durs[key].list; p=Song;song-p
		var key= start ? P.calcStart();
		numNotes = numNotes - 1;

		Post << "numnotes " << numNotes << "\n";
		^{|p b| 
			[
				dur: b 
				++ p.durs[p.section(key)+1].list 
				++ p.durs[p.section(key)+2].list[0..numNotes]
				=> _.flat => _.q, 
				midinote:p.tune[p.section(key)].list 
				++p.tune[p.section(key)+1].list
				++p.tune[p.section(key)+2].list[0..numNotes] => _.flat => _.q 
			].p
		}
	}
}

Part { 
	classvar <>current;
	var <>start,<>syl,<>lag,<>music,<>resources,<>parent,<>name;

	*play{fork{Server.default.sync;current.play};^current}
	*new {|start=0,syl,lag=0,music,resources|
		^super.new.init(start,syl,lag,music,resources)
	}
	key {^name.split($_)[0].asSymbol}
	init { |s,y,l,m, r|
		start=s;syl=y;music=m;lag=l;resources = r.isNil.if{()}{r};
	}
	//play immediately
	printOn {|stream| ^this.name.printOn(stream) }
	play {
		//Song.allNotesOff;
		// var synthV = resources.at(\synthV);
		// synthV.notNil.if{
		// 	synthV.needsRender.if{
		// 		^synthV.render
		// 	} 
		// };
		switch (music.class,
			Function,{Server.default.bind{
				music.value(
					parent,
					//durs from event start
					parent.durs[start].list.drop(syl ? 0), //this is why you gotta use .drop(1) aaarg
					this
				)
			}},
			// Event,{ music.play},
			Message,{Server.default.bind{music.value}},
			Routine,{
				music.value(
					parent,
					//durs from event start
					parent.durs[start].list.drop(syl?0),
					this
				)
			},
			VocoderPattern,{music.play;\vocoderPatternPlaying.postln},
			{music.play}
		)  
	}
	test{^start}
	awake { this.play }
	sched { |when=1|
		////////////////trying to make setup be part of Part
		//////////delete this line if not work
		//(music.class=Routine).if(music.play);

		TempoClock.sched(when,this)
		//		parent.clock.sched(when,this)
		//AppClock.sched(when,this)
		//SystemClock.sched(when,this)
	}
	calcTime {
		var when;
		lag.isNil.if{lag=0};
		when = parent.secLoc[start]-parent.secLoc[parent.cursor];
		when = when + lag + parent.preroll; // per song setting to allow for negative lags
		syl !? {when = when + parent.durTill(start,syl)};
		^when
	}
	// adds .playInitiatedAt to the start time - not used ATM
	pAbs {
		(start>=parent.cursor).if{
			var when = this.calcTime + parent.playInitiatedAt;
			this.schedAbs( when + Server.default.latency);
			{this.name.postln}.schedAbs(when);
		}
	}
	p {
		parent.cursor = parent.cursor ? 0;
		(start>=parent.cursor).if{
			var when=this.calcTime;
			this.sched(when+Server.default.latency);
			{this.name.postln}.sched(when);
			//			when.postln
		}
	}
	ppost {
		this.p;
		{this.name.postln}.sched(this.calcTime);
	}
	hasStill {
		resources.still.notNil || music.cs.contains("still") 
	}
	isTune {
		name.asString.contains("TUNE")
	}
	quarters {
		^parent.quarters[start]
	}
	tempoMap {
		^parent.tempoMap[start]
	}
	next {
		^start + 1
	}
	bNext { |offset=1|
		^parent.durs[start+offset].list
	}
	bAll {
		var length = parent.sections - start;
		^length.collect{|x| parent.durs[start + x].list}.flat
	}

	//add random stuff to resources
	doesNotUnderstand { |selector   args|
		var key = selector.asString;
		key.contains($_).if
		(
			{
				key=key[..key.size-2];
				resources.put(key.asSymbol,args)
			},{
				key.postln;
				^resources.at(key.asSymbol);
			}
		)
	}
}
// Constructor for Parts
P { 
    *new {
        |key start syl lag=0 music song resources rpp synthV|
        var part,error;
	{
		start = this.calcStart(start); //finds it if not provided!
		( start.class==Function ).if{music = start; start = nil}; //syntactic sugar
		start.postln;
		key = (key ++ "_" ++ start).asSymbol;
		resources = ( resources ++ (rpp: rpp) ? resources );
		//resources = ( resources ++ (synthV: synthV) ? resources );
		part = Part(start,syl,lag,music,resources);
		Message(Song.currentSong, ( key ++ $_ => _.asSymbol )).value(part); //set Song.resources.key to part
		key.postln;
	}.try{|e| error = e}
        ^( error ? part )
    }
    *calcStart { |start|
	    ^start.isNil.if{
		    Song.partCursor.notNil.if{
			    Song.partCursor
		    } {
			    ((Song.song.size-2)/2).asInteger
		    };
	    }{
		    (start.class==Symbol).if{
			    Song.section(start);
		    }{start}
	    };

    }
    *still {   // renders the still when compiled
              // and stores a function to preview it in resources.still (e.still)
        |key st syl lag=0 timecode=60 music|
		var start = P.calcStart(st);
		var aStill;
		key = key ++ start;
		aStill = timecode.isNumber.if{
			Still(key ++ ( Song.calcStart( start ) )=> _.asSymbol, timecode:timecode);
		}{
			timecode.collect{|i x|
				Still(key ++ ( Song.calcStart( start ) ) ++ x => _.asSymbol, timecode: i);
			}
		};
        // nope - make a Still instead
        // like define Still here and in the music:{
        // e.still.wait_(4).fadeIn_(2).text_   etc etc
        //}
        ^P(
            key: ( key ++ start ).asSymbol, 
            resources: (
				still: aStill
            ),
            start: start,
            syl: syl,
            lag: lag,
            music: music
        )


    }
    *tune {
        |key function range lag=0 syl lyrics music| 
        // range is [start,end] or just [start]
        // range sets syllable automatically
	var start;
	( key.class==Function ).if{function=key; key=nil};
	start = key ? this.calcStart(key);
	^P( 
		key: (key++"TUNE").asSymbol, 
		start:start, 
		music: {  
			var drop, length;
			var pbind = Song.currentSong.pbind[start] ;

			range.notNil.if{
				drop = range[0];
				pbind=pbind.drop(drop) ;
				range[1].notNil.if {
					length = range[1] - range[0] + 1;
					pbind=pbind.fin(length) ;
				};
				(drop > 0).if{ syl = drop - 1; \syl.post;syl.postln };
			};

			function.isNil.if{function={|i|i}};
			function.value(pbind).play;
		}, 
		syl:syl, 
		lag:lag 
	)//.value
	
    }
    *click { | key |
	    P(
		    key: (key++"CLICK").asSymbol, 
		    start: key,
		    music: { |p b e| 
			    [
				    instrument:\hat_808,
				    dur: p.quarters[e.start]
			    ].pp 
		    }
	    )
    }
}

SongList {
	classvar <> current;
	var < arrayOfSongs;

	*new {| ...args |
		^super.new.init(args)
	}

	init { | args |
		arrayOfSongs= args;
	}

	*play {
		current.play;
	}

	play {
		var durations = arrayOfSongs.collect(_.durTillEnd);
		//save and restore the cursors for sections after the first 
		var cursors = arrayOfSongs.collect(_.cursor);
		arrayOfSongs.do{ |i x|
			var offset =0; 
			var playFrom=cursors[0];
			(x>0).if{
				offset=durations[0..x-1];
				playFrom=0;
			};
			i.postln;offset.postln;
			{ i.cursor_(playFrom).play }.sched(offset);
			{ i.cursor_(cursors[x])}.sched(offset+1) 
		};
	}
//		~playMultipleSongs.([~tu,~im2]);
}


Dur[slot] : List { 
	var array;
	*current {
		^Song.currentSong.durs[Song.currentSong.sections-1]
	}
	*printOn {333.postln}
	*new {
		^super.new.setCollection(Array.new(8))
	}
	setCollection { arg aColl;
		aColl.isNil.if(
			{
				array=[3,4,5];
			},{
				array = aColl.asArray;
	})
	}

	
}

Track {
	var <>name,song;
	var <names, <parts;
	*new {|...args| ^super.newCopyArgs(*args).init }
	init {
		song = (song ? Song.currentSong);
		name = name.asString;
		names=song.track(name,song);
		parts =  names.collect({|i| song.resources.at(i.asSymbol)}) 
	}
	number {|string| ^string.replace(name,"").asInteger}
	blocks { ^names.separate({|x y|( (this.number(y)-this.number(x))==1 ).not }) }
	play { song.play(names.collect(_.asSymbol));^names }
	dry_ {|amount| parts.do({ |i| i.music.dry_(amount) })}
	arm {|bus| parts.do({ |i| i.music.arm(bus:bus) })}
}

SectionAccessor {
	var function;
	*new {|function| ^super.new.init(function) }
	init {|f| function = f} 
	at {|section| ^(section.isNumber).if{section}{Song.section(section)}  => function }
	copySeries {|i j k| ^(0..Song.sections).copySeries(i,j,k).collect( { |i| this.at(i)} )}
}

+ Symbol {
	cursor {
		^Song.songs.at(this).cursor
	}
	cursor_ {|i|
		Song.songs.at(this).cursor_(i)
	}
	current {
		^Song.songs.at(this).current
	}
}

+ Nil {
	p {
		nil
	}
}
