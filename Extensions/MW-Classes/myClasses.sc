ModSin : SinOsc {
	*new {|freq=400, rate=5,width=0.05, amp=0.1| ^SinOsc.ar( SinOsc.kr (rate,0,width*freq,freq),0,amp)
	}
}

VibSin : SinOsc {
	*new {|freq=400, rate=5, width=0.05, delay=0.6, amp=0.1, onset=0.15, trig=1, rateVar=0.04, widthVar=0.1|
		^SinOsc.ar( Vibrato.kr (freq,rate,width,delay, onset, rateVar, widthVar,trig),mul:amp)
	}
}

Verb {
	*new { |bus=10, mix=1, room=0.8, damp=0.1|
		^FreeVerb.ar (In.ar(bus),mix,room,damp)
	}
}

Send {
	*new { |in, bus,  dry=0.5, wet=1|
		^Out.ar([0,1,bus],[in*dry, in*dry, in*wet])
	}
}

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

	*play {current.play}

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

	play { |...args|
		var list = this.getPartsList(args);
		list.do(_.p)
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

	addPart {|key part| resources.put(key,part);part.name=key;part.parent=this;^resources}

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

	*new {|start=0,syl=0,lag=0,music|
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

//TempoClock.sched(2,{2.postln;Routine{1.postln}}.value)

	sched { |when=1|
		////////////////trying to make setup be part of Part
		//////////delete this line if not work
		//(music.class=Routine).if(music.play);
		TempoClock.sched(when,{this.play})
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

//parts returns the parts dict -- ?
// ~x.parts.kkk=(start)
// ~.parts

PF {
	var <controller;
	var <synth;
	var vsti;
	var synthdef;
	var <node,<bus;
	*new{^super.new.init}
	init{
		node=NodeProxy.audio().play;
		bus=Bus.audio(numChannels:2);
		node.source={In.ar(bus.index,2)};
		synthdef=SynthDef(\vsti,{|out=0|
			var sig=VSTPlugin.ar(nil,2);
			Out.ar(out,sig)
		}).add;
		//synth=Synth(\vsti);
		//controller=VSTPluginController(Synth(\vsti,[\out,self.bus]));
		controller=VSTPluginController(Synth(\vsti,[\out,bus.index]));
		controller.open('/Library/Audio/Plug-Ins/VST/Pianoteq 5.vst',info:true)  //++self.plugin
	}
}

+ SequenceableCollection {
	q{ arg repeats=1;
		^Pseq.new(this,repeats)
	}
}

+ Pbind {
	pad { arg release=10;
		^Pseq.new([this,Pbind.new(\note,Pseq([\r]),\dur,release)])
	}
}

+ String {
	asDrumPat {| beatsPerBar=8 reps=1|
		var b=List.new;
		var a=Array.newFrom(this);
		a.do({|m| (m=="|"[0]).not.if{b.add(m)}});
		b=b.collect{|j| (j=="x"[0]).if({1},{Rest(1)})};
		^Pseq(b/beatsPerBar,reps)
	}
}

+ String {
	asStrumPat {|beatsPerBar=8 reps=1|
		var b=List.new;
		var a=Array.newFrom(this);
		a.do({|m| (m=="|"[0]).not.if{b.add(m)}});
		//change line below
		b=b.collect{|j| (j=="x"[0]).if({1},{Rest(1)})};
		^Pseq(b/beatsPerBar,reps)
	}}

+ Array {
 ply {this.do{|x|x.p}}
}

+ Object{
	=> {|a| ^a.(this)}
	=>+ {|a b| ^a.(this,this)}//a is a fn of 2 vars
	
	pipe {|...fns|
		^fns.inject({|x| x}, {|acc, el| el<>acc }).(this)
	}
}
+ Server { plotTreeL {|interval=0.5 x=(-800) y=400 dx=400 dy=800|
		var onClose, window = Window.new(name.asString + "Node Tree",
			Rect(x,y,dx,dy),
			scroll:true
		).front;
		window.view.hasHorizontalScroller_(false).background_(Color.grey(0.9));
		onClose = this.plotTreeView(interval, window.view, { defer {window.close}; });
		window.onClose = {
			onClose.value;
		};
	}
}
