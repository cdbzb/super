Song {
	classvar <> dursFile="/Users/michael/tank/super/theExtreme3";
	classvar < songs;
	classvar <> current;
	classvar lyricWindow;
	var <song, <key, <>cursor=0, <sections, <lyrics, <tune; 
	var <>durs,  <>resources;
	var <>next; 
	classvar <>songList;

	*initClass {
		songs=Dictionary.new;
	}

	*new { |key array|
		^super.new.init(key, array);
	}

	*playArray { |array|
			fork{
				array.do({|i|
					{ songs.at(i).valueInfrastructure }.try;
					{ songs.at(i).condition.wait }.try;
				});
				array.do({|i|
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

	*doesNotUnderstand { |selector   args|
		this.currentSong.respondsTo(selector).if{
			^Message(this.currentSong,selector).value(args)
	} {
			var key = selector.asString;
			//key.contains($_).if{
			//}
			^songs.at(selector)
		}
	}

	//there should be a way to make it so you can insert lines
	// or add lines individually
	// 

	//c=[1,2,3,4].asAssociations(List)
	//c.insert(1,("aaa"->"c3"))
	//c.asPairs
	
	init {|symbol array|
		key=symbol;
		songs.put(symbol.asSymbol,this);
		song=array;
		resources=();
		sections=(song.size/2).asInt;
		lyrics=song.copySeries(0,2,song.size);
		tune=song[1,3..song.size].collect({|i|
			case {i.class==String} { Panola.new(i).midinotePattern }
			{i.class==Array } {i.q}
		});
		this.setupDurs;
	}

	refreshArray {
		sections=(song.size/2).asInt;
		lyrics=song.copySeries(0,2,song.size);
		tune=song[1,3..song.size].collect({|i|
			case {i.class==String} { Panola.new(i).midinotePattern }
			{i.class==Array } {i.q}
		});
	}

	addLine { |line dur=1| //array
		line[1].isNil.if{line=line++["r"]};
		song=song++line;
		this.refreshArray;
		durs=durs++[dur].q;
		^this;
	}

	secLoc {^[0]++(sections-1).collect{|i| this.secDur[..i].sum}}

	secDur {^(..sections-1).collect{|i|durs[i].list.sum}}

	pbind {^(..sections-1).collect{|i|Pbind(\dur,durs[i],\midinote,tune[i])};}

	setupDurs {
		Archive.read(dursFile);
		Archive.at(key).isNil.not.if(
			{
				var a=Archive.at(key);
				durs=a++(Pseq([1])!(sections-a.size)); //copy or pad
			},{
				durs=Pseq([1])!sections
			}
		)
	}

	save { Archive.global.put(key,durs);Archive.write(dursFile);'archive written'.postln }

	durTill {|sec till|
		var list= durs[sec].list;
		^list[0..till].sum
	}

	postLyrics {
		lyrics.do{|i x| (x.asString++' '++i).postln}
	}

	pbindFrom {|from=3| 
		var list = this.pbind[from.asInt..(sections-1)].postln;
		^Pseq(list)
	}

	pts {^all {:x,x<-resources,x.class==Part}}

	valueInfrastructure {
			  resources.condition !? (_.test_(false));
			this.resources.at(\infrastructure) !? (_.value);
	}

	playParts { |...args|
		this.getPartsList(args).do(_.p)
	}

	chain {
		songList=[key,next]
	}

	play { |...args|
		var list = this.getPartsList(args);
		fork{
			//resources.condition ? resources.condition.test_(false);
			  resources.condition !? (_.test_(false));
			this.resources.at(\infrastructure) !? (_.value);
			resources.condition !? _.wait;
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

	contains { |string|
		var array =	all {:x,x<-resources.keys,var y=resources.at(x.asSymbol),y.class==Part,(x.asString).contains(string)};
		array.postln;
		^array.collect{|i| resources.at(i)};
	}

	addPart {|key part| 
		resources.put(key,part);
		part.name=key;
		part.parent=this;^resources}

	durTillEnd {
		^(cursor..(sections-1)).collect{|i|this.secDur[i]}.sum
	}

	parse {|phrase array start=0| 
		var counter = 0;
		var beatNum; 
		//expand numbers greater than one
		//doesn't currently support numbers greater than one in sub-arrays
		//or decimal numbers greater than one
		array=array.collect{|i| 
			( i.class==Integer ).if{
			(i>1).if{ 1.dup(i) }{ i }
		}{
			i
		}};
		beatNum = array.flatten.collect{|m i| array.flatten.[0..i].sum};
		array.postln;
		beatNum = beatNum.collect{|i|(i-0.001).floor};
		^array.collect{ |item|
			item.isArray.not.if(
				{
					var b=beatNum[counter];
					counter=counter+1;
					item*durs[phrase].list[b+start]
				},
				{
					var subArray=item.collect{|i x| 
						var b = beatNum[counter+x];
						i*durs[phrase].list[b+start]
					}; 
					counter=counter+item.size; 
					subArray.sum;
				}
			);
		}
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
				(args.class==Part).if{args.name=key;args.parent=this;Part.current=args}
			},{
				^resources.at(key.asSymbol);
			}
		)
	}
}

Part { 
	classvar <>current;
	var <>start,<>syl,<>lag,<>music,<>resources,<>parent,<>name;

	*play{^current.play}

	*new {|start=0,syl,lag=0,music|
		^super.new.init(start,syl,lag,music)
	}

	init { |s,y,l,m|
		start=s;syl=y;music=m;lag=l}

	//play immediately
	play {switch (music.class,
		Function,{Server.default.bind{
			music.value(
				parent,
				//durs from event start
				parent.durs[start].list.drop(syl?0)
			)
		}},
		Message,{Server.default.bind{music.value}},
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
			this.sched(when);
			{this.name.postln}.sched(when);
			//when.postln
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
// a part which registers itself with its parent song
P { 
	*new{
		|key start=0 syl lag=0 music song|
		var part=Part(start,syl,lag,music);
		key=(key++\_).asSymbol;
		Message(  Song.songs.at(Song.current) , key ).value(part)
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
