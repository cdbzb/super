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
		}{
			\falling_back_to_durs_file.postln;
		Archive.read(dursFile);
		Archive.at((key++\lyricsToDurs).asSymbol).isNil.not.if(
				{lyricsToDurs = Archive.at((key++\lyricsToDurs).asSymbol)},
				{lyricsToDurs= Dictionary.new(128)}
		)
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
		this.getPartsList(args).do(_.p)
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

		TempoClock.sched(when,this)
//		parent.clock.sched(when,this)
		//AppClock.sched(when,this)
//		SystemClock.sched(when,this)
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
        Stills.current.set(key++start=>_.asSymbol, timecode);
        ^P(
            key: ( key ++ start ).asSymbol, 
            resources: (
                still: {| monitor=0 wait fade=2 fadeIn=0 text| defer{ Stills.current.preview( key ++ start => _.asSymbol, monitor:monitor,fade:fade,fadeIn:fadeIn,text:text,wait:wait ) }}
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
            key: (key++"Tune").asSymbol, 
            start: key, 
            music: {  
                var drop, length;
                var pbind = Song.currentSong.pbind[key] ;

                range.notNil.if{
                    drop = range[0];
                    range[1].notNil.if {
                        length = range[1] - range[0] + 1;
                        pbind=pbind.fin(length) ;
                    };
                    pbind=pbind.drop(drop) ;
                    (drop > 0).if{ syl = drop - 1 };
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

VocalRPP {
    var <>key, <>name, <>range=1, <>tail=5, <>song;
    var section;
    var <>reaperProjectPath,<>rpp,<>buffer;

    *new { |...args| ^super.newCopyArgs(*args).init}
init{ 

    song.isNil.if{song=Song.currentSong};
    section =song.section(key);
    reaperProjectPath = Song.reaperFolder +/+ song.key;
    //(reaperProjectPath +/+ "media" +/+ "*PROX" => _.pathMatch => _.first) !? { 
    //    |i|
    //    buffer=Buffer.read(Server.default,i)
    //};
    name.notNil.if{
        key = key ++ "-" ++ name
    };
    buffer = Buffer.read(Server.default,this.proxy)
}

    makeRPPs { 
        |durs=#[1,2,3] |
        var guide=reaperProjectPath +/+ "media" +/+ key.asString ++ ".wav";
        var examplesPath = "/Users/michael/tank/super/RPP/";
        // build subproject
        var subprojectOutPath = "mkdir" + reaperProjectPath +/+ "media" => _.unixCmd;
        var sink = examplesPath ++ "example-sub"
        => File.readAllString(_,"r")
        => _.replace("PTS",durs.makePTs)
        => _.replace("ENDMARKER",durs.sum + 5 => _.asString)
        => _.write(reaperProjectPath +/+ "media" +/+ key ++  "-" ++ "subproject.rpp",overwrite:true); //maybe datestamp
        var sections = [
            "Part1",
            "afterPT-uptoLENGTH",
            "afterLENGTH-uptoFILE",
            "afterFILE-uptosubprojectFILE",
            "tail",
        ].collect({|i| 
            File.readAllString(examplesPath ++ i,"r") 
        });
        var outFile = reaperProjectPath +/+ key++ ".RPP";
        var length = "      LENGTH" +  ( durs.sum + 5 ) ++ "\n";
        var file = "        FILE " ++ guide.quote++"\n";
        //var subproject = "        FILE " ++ "/Users/michael/tank/super/RPP/EXAMPLE/media/02-210914_0752.rpp".quote++"\n";
        var subproject = "        FILE " ++ (reaperProjectPath +/+ "media" +/+ key ++"-" ++ "subproject.rpp").quote++"\n";
        ^(
            sections[0] ++ 
            // durs.makePTs ++
            sections[1] ++
            length ++
            sections[2] ++
            file ++
            sections[3] ++
            subproject ++
            sections[4]
        ).replace("GUIDEOFFSET","SOFFS 0.4") //adjust for server latency 
        .replace("LENGTH 5.00000","LENGTH"+(durs.sum + 5 - 0.4))
        // may not be necessary
        .write(outFile,overwrite:true )
}

build {
    var path;
    var s = Server.default;
    File.exists(reaperProjectPath).not.if(File.mkdir(reaperProjectPath +/+ "media"));
    path=reaperProjectPath +/+ "media" +/+ key.asString ++ ".wav";
    fork{
        s.prepareForRecord(path);
        0.1.wait;
        Song.cursor_(section);
        range.do(
            { |i|
                song.play(song.at(section+i));
            }
        );
        s.record(duration: range.collect{|i| Song.secDur[ i ]}.sum + tail);
        (range.collect{|i| song.secDur[ i ]}.sum + tail + 0.5).wait;
        //put name in variable
        this.makeRPPs(
            song.durs[section].list, //durs
             //path to reaper dir (redundant!!)
        );
        this.storeDurs;
    };

}

storeDurs{
    song.durs[section].list.writeArchive(
        reaperProjectPath +/+ "media" +/+ key.asString ++ "_durs"
    )
}

checkDursChanged{
    ^song.durs[section].list != Object.readArchive(
        reaperProjectPath +/+ "media" +/+ key.asString ++ "_durs"
    )
}

updateDurs{
    var endings;
    var out="";
    var line="";
    var filename = reaperProjectPath +/+ "media" +/+ key ++  "-" ++ "subproject.rpp" ;
    var file=File.open(filename,"r");
    var next = {out = out ++ line ++ "\n"; line = file.getLine};
    next.();
    endings = line.contains($);
    line.postln;
    while ({ line.contains("TEMPOENVEX").not },{next.()});
    while ({ line.contains("PT").not },{next.()});
    while({line.contains("PT")},{line=getLine(file)});
    out = out ++ song.durs[section].list.makePTs;
    while({line.notNil},next);
    endings.if {
        out.write("/tmp/xxx",overwrite:true);
        "/tmp/xxx".fixLineEndings(filename); 
    }{
        out.write(filename)
    }
}

proxy {
    ^reaperProjectPath +/+ "media" +/+ key++"*PROX" => _.pathMatch => _.first;
}

open {
    "open" + reaperProjectPath +/+ key ++ "*RPP" => _.unixCmd
}
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
