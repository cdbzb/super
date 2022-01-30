Song {
	classvar lastSectionPlayed=0;
    classvar <>reaperFolder = "/Users/michael/tank/super/RPP";
	classvar <> dursFile="/Users/michael/tank/super/theExtreme3";
	classvar <> dursFolder="/Users/michael/tank/super/Dur";
	classvar < songs;
	classvar <> current;
	classvar lyricWindow;
	classvar <>songList;
	var <song, <key, <cursor=0, <sections, <lyrics, <tune; 
	var <durs,  <>resources, <>lyricsToDurs;
    var <>next;
	var <>quarters;
	var <>clock;

	*initClass {
		songs=Dictionary.new;
	}
	
	*new { 
		|key array dursInFile|
		^super.new.init(key, array,dursInFile);
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

	*showLyricWindow {
		lyricWindow=Window(bounds:Rect(-500,000,600,600)).alwaysOnTop_(true).front;
		//a=StaticText.new(w,Rect(120,10,600,300)).string_(~im2.lyrics).font_(Font("Helvetica",20)).align_(\left);
		songs.at(current).lyrics.size.do{|i|
			StaticText.new(lyricWindow,Rect(120,25*i,600,300))
			.string_(songs.at(current).lyrics[i])
			.font_(Font("Helvetica",20));

			StaticText.new(lyricWindow,Rect(100,25*i,600,300))
			.string_(i.asString)
		};
		//{w.close}.defer(5)
	}

	*closeLyricWindow{
		lyricWindow.close
	}

	*doesNotUnderstand { |selector   ...args|
		songs.at(current).respondsTo(selector).if{
			\responds.postln;
			'selector '.post;selector.postln;
			'args '.post;args.postln;
			^Message(songs.at(current),selector).value(*args)
		} {
			var key = selector.asString;
			key.endsWith("_").if{
                key=key.replace("_","").asSymbol;
                ^this.currentSong.resources.put(key, *args);
            }{
                ^Song.currentSong.resources.at(key.asSymbol)
            }
			//^songs.at(selector)
		}
	}

	init {|symbol array dursInFile|
		key=symbol;
		songs.at(symbol.asSymbol).notNil.if {cursor=lastSectionPlayed};
		songs.put(symbol.asSymbol,this);
		song=array;
		resources=();
		sections=(song.size/2).asInteger;
		lyrics=song.copySeries(0,2,song.size);
		tune=song[1,3..song.size].collect({|i|
			case {i.class==String} { Panola.new(i).midinotePattern }
			{i.class==Array } {i.q}
		});
		this.setupLyricsToDurs;
		durs=Durs(this);
		clock=TempoClock.new(queueSize:512);
		quarters=SongArray(key:key);
	}
	cursor_ {|i| cursor = i; lastSectionPlayed = i;}

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

	refreshArray {
		sections=(song.size/2).asInteger;
		lyrics=song.copySeries(0,2,song.size);
		tune=song[1,3..song.size].collect({|i|
			case {i.class==String} { Panola.new(i).midinotePattern }
			{i.class==Array } {i.q}
		});
		//durs=lyrics.collect{|i| lyricsToDurs.at(i) };
		//durs=durs.collect{|i| i.isNil.if( {[1].q} , {i} )}
	}

	addLine { |line| //array
		line[1].isNil.if{line=line++["r"]};


		//TODO merge lyricsToDurs with Archive when saving!!
		this.hasDursButNotLyricsToDurs.if{
			lyricsToDurs.add(line[0] -> Archive.at(key)[sections]);
		};

		//FIXME
		song=song++line[0..1]; this.refreshArray;
		line[2].isNil.if({ 
			//line=line++[[1]]
			//durs.put(line[0].asSymbol,[1].q)

		},{
			durs.put(line[0].asSymbol,(line[2]).q);
		});
		^Song.sections-1;
	}

	addDurs {|array|
		durs[sections-1]=array.q
	}

	secLoc {
		var secDurs = this.secDur;
		^SongArray(
			[0]++(sections-1).collect{|i| secDurs[..i].sum}
			,key
		)
	}

	secDur{
		var dursNow=this.durs;
		^SongArray(
			//this,
			(..sections-1).collect{|i|dursNow[i].list.sum}
			,key
		)
	}

	pbind {
		var dursNow=this.durs;
		^SongArray.new(
			(..sections-1).collect{|i|Pbind(\dur,dursNow[i],\midinote,tune[i])}
			,key
		)
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
		this.getPartsList(args).sort({|i j| i.start<j.start}).do(_.p)
	}

	chain {
		songList=[key,next];
		songList.postln;
	}

	play { |...args|
		var list = this.getPartsList(args);
		fork{
			//resources.condition ? resources.condition.test_(false);
			resources.condition !? (_.test_(false));
			this.resources.at(\infrastructure) !? (_.value);
			resources.condition !? _.wait;
			'Condition Met'.postln;
//			1.wait;
			Server.default.sync;
			list.do(_.p)
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

	playSection {|sec|
		( sec.class==Integer ).not.if{sec=this.section(sec)};
		cursor=sec;
		this.play(this.at(sec))
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
	section {|string| 
		//returns section number which contains lyric
		var array = (..lyrics.size-1).select{|i |lyrics[i].asString.contains(string.asString)};
		(array.size>1).if{'!!! more than one section with: '.post;string.postln; array.postln};
		^array[0]
	}

	contains { |string|
		var array =	all {
                  :x,
                  x<-resources.keys,
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

	getSection {|a| 
		a.isNil.if{a=sections};
		(a.class==String).if{a=a.asSymbol};
		(a.class==Symbol).if({
			^this.section(a)
		},{
			^a
		})
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
		var beatCounter = List.new, denominators = List.new;
		var result = List.new;
		var desiredLength = array.sum;
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
				\grader.postln;
				i.postln;
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
    setQuarters { | section array|
        quarters[section] = this.parseBeats(section,array).q
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
}

Part { 
	classvar <>current;
	var <>start,<>syl,<>lag,<>music,<>resources,<>parent,<>name;

	*play{fork{Server.default.sync;current.play};^current}

	*new {|start=0,syl,lag=0,music,resources|
		^super.new.init(start,syl,lag,music,resources)
	}
	init { |s,y,l,m, r|
		start=s;syl=y;music=m;lag=l;resources = r.isNil.if{()}{r};
	}

	//play immediately
	play {switch (music.class,
		Function,{Server.default.bind{
			music.value(
				parent,
				//durs from event start
				parent.durs[start].list.drop(syl?0),
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


//TempoClock.sched(2,{2.postln;Routine{1.postln}}.value)

	sched { |when=1|
		////////////////trying to make setup be part of Part
		//////////delete this line if not work
		//(music.class=Routine).if(music.play);

		//TempoClock.sched(when,this)
//		parent.clock.sched(when,this)
		//AppClock.sched(when,this)
		SystemClock.sched(when,this)
	}

	calcTime {
		var when;
		lag.isNil.if{lag=0};
		when = parent.secLoc[start]-parent.secLoc[parent.cursor];
		when = when + lag;
		syl !? {when = when + parent.durTill(start,syl)};
		^when
	}

	//play in context of parent song
	p {
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
// makes a part which registers itself with its parent song
P { 
    *new {
        |key start syl lag=0 music song resources|
        var part;
        start.isNil.if{
            start=((Song.song.size-2)/2).asInteger;
        }{
            (start.class==Symbol).if{
                start = Song.section(start);
            };
        };
        start.postln;
        key = (key ++ start ++ \_).asSymbol;
        part = Part(start,syl,lag,music,resources);
        Message(Song.songs.at(Song.current), key).value(part);
        key.postln;
        ^part
    }
    *still{   // renders the still when compiled
              // and stores a function to preview it in resources.still (e.still)
        |key start syl lag=0 timecode=60 music|
		var aStill = Still(key ++ start => _.asSymbol, timecode:timecode);
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
        |key function range lag syl| 
        // range is [start,end] or just [start]
        // range sets syllable automatically
        P( 
            key: (key++"TUNE").asSymbol, 
            start: key, 
            music: {  
                var drop, length;
                var pbind = Song.currentSong.pbind[key] ;

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
        ).value
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
