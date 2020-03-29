Song {
	classvar <> dursFile="/Users/michael/tank/super/theExtreme3";
	classvar < songs;
	classvar <> current;
	var <song, <key, <>cursor=0, <sections, <lyrics, <tune; 
	var <durs,  <>resources;

	*initClass {
		songs=();
	}

	*new { |key array|
		^super.new.init(key, array);
	}

	*play { |...args|
		args ? current.play;
		(args.class == Array).if{
			fork{
				//args.do({|i|argss.at(i).play;argss.at(i).durTillEnd.wait})
				args.do({|i|
					songs.at(i).valueInfrastructure;
					songs.at(i).condition.wait;
				});
				args.do({|i|
					songs.at(i).playParts;
					songs.at(i).durTillEnd.wait;
				})
			}
		}
	}

	*doesNotUnderstand { |selector   args|
		var key = selector.asString;
		//key.contains($_).if{
		//}
		^songs.at(selector)
	}

	//there should be a way to make it so you can insert lines
	// or add lines individually
	// 

	//c=[1,2,3,4].asAssociations(List)
	//c.insert(1,("aaa"->"c3"))
	//c.asPairs
	
	init {|symbol array|
		key=symbol;
		songs.put(symbol,this);
		song=array;
		resources=();
		sections=(song.size/2).asInt;
		lyrics=song.copySeries(0,2,song.size);
		tune=song[1,3..song.size].collect({|i|
			Panola.new(i).midinotePattern
		});
		this.setupDurs;
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

	save { Archive.global.put(key,durs);Archive.write(dursFile) }

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

	addPart {|key part| 
		resources.put(key,part);
		part.name=key;
		part.parent=this;^resources}

	durTillEnd {
		^(cursor..(sections-1)).collect{|i|this.secDur[i]}.sum
	}

	parse {|phrase array start=0| 
		var counter = 0;
		var beatNum = array.flatten.collect{|m i| array.flatten.[0..i].sum};
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
				(args.class==Event).if{args=this.asPart(args)};
				resources.put(key.asSymbol,args);
				args.postln;
				(args.class==Part).if{args.name=key;args.parent=this}
			},{
				^resources.at(key.asSymbol);
			}
		)
	}
}

Part { 
	var <>start,<>syl,<>lag,<>music,<>resources,<>parent,<>name;

	*new {|start=0,syl,lag=0,music|
		^super.new.init(start,syl,lag,music)
	}

	init { |s,y,l,m|
		start=s;syl=y;music=m;lag=l}

	//play immediately
	play {switch (music.class,
		Function,Server.default.bind{music.value},
		Message,Server.default.bind{music.value},
		{music.play}
		) 
	}

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
			when.postln
		}
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
