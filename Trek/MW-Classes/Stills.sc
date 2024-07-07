//(
//	t=StaticText.new(w,Rect(0,0,500,200))
//	.string_('LLLL')
//	.stringColor_(Color.rand)
//	//.align_(\left)
//	.font_(Font(\helvetica,90,bold:true))

//)
Stills {
	classvar <>stillsLocation;
	classvar <>current;
	classvar <>muted=false;
	classvar <>scale=1;
	classvar <>trimWidth=1; //0.87 for no border
	classvar <>trimLeft=0; // 180 for no border
	classvar <>monitorChoiceFunction;
	var <>file;
	var <>markers;
	var <>fade;
	var <>font;
	var <>window;
	var <>stills;
	var <>size=1200;
	classvar <>monitors ;


	*new {|movie| ^super.new.init(movie)}

	*rootDir {
		^this.class.filenameSymbol.asString.dirname.dirname +/+ "Stills"
	}

	*initClass {
		stillsLocation = this.rootDir +/+ "cache/"
	}

	*emptyCache {
		"rm" + this.rootDir +/+ "cache/*" => _.unixCmd
	}

	*reaper {
		("open" + this.rootDir +/+ "video for stills etc.RPP".escapeChar(Char.space)).unixCmd
	}

	dual {
		monitors= [
			Rect(left:0,top:200,width:1400,height:800),
			Rect(left:-1500,top:200,width:1400,height:800)
		]
	}

	init {|movie| 
		// file=movie ? ( this.class.filenameSymbol.asString.dirname.dirname +/+ "return-to-tomorrow.cropped.mov" ); 
		// file=movie ? ( this.class.filenameSymbol.asString.dirname.dirname +/+ "return-to-tomorrow.mov" ); 
		// file=movie ? ( this.class.filenameSymbol.asString.dirname.dirname +/+ "new.mp4" ); 
		file=movie ? ( this.class.rootDir +/+ "trimmed433.mov" ); 
		markers=();
		monitors = switch( Platform.machine,
			// monitor size = 1440 x 900
			"MacBookPro16,2",{ [Rect(left:0,top:200,width:1400,height:800)] },
			"MacPro6,1",{ [
				Rect(left:0,top:200,width:1400,height:800),
				Rect(left:-1500,top:200,width:1400,height:800)
			] }
		)
	}

	//monitor -1 for left 0 for center default is -1
	preview { |markerName wait=5 fade=0 monitor text fadeIn| 
		var w;
		muted.not.if{
			if (markerName.asString.contains ( "clear")) {
				Stills.monitors.do{ |i x|
					w=this.plotClear(markerName, x);
					fadeIn.notNil.if{w.fadeIn(fadeIn)};
					text.notNil.if{this.title(w,text)};
					{w.fade(fade)}.defer(wait);
				};
				^w
			}{
				w=this.plot(markerName, monitor)
			};
			fadeIn.notNil.if{w.fadeIn(fadeIn)};
			text.notNil.if{this.title(w,text)};
			{w.fade(fade)}.defer(wait);
			^w
		}
	}

	current {
		Stills.current = this
	}

	set {|markerName seconds| 
		( markers.at(markerName) == seconds ).not.if {
			try{
				markers.put(markerName,seconds);
				this.writeImage(seconds)
			}
		}
	}

	writeImage { |seconds |
		File.exists(stillsLocation++seconds.asString++".png").not.if{
			(
				//faster but less accurate
				"ffmpeg -y -ss"
				+ seconds.asString 
				+ "-i"
				+ "'"++file.asSymbol++"'"
				+ "-vframes 1  -f image2"
				+ "-nostdin"
				+ "-hide_banner -loglevel error" //make silent
				+ stillsLocation
				++ seconds.asString
				++ ".png "
				+ "> /dev/null"
			).systemCmd;
			//slower but more accurate
			// "ffmpeg -y " ++ " -i "++"'"++file.asSymbol++"'" + "-ss "++ seconds.asString++ "  -vframes 1  -f image2 "++stillsLocation++seconds.asString++".png ").systemCmd;
			//("ffmpeg -ss "++ seconds.asString++" -i "++"'"++file.asSymbol++"'"++ "  -vframes 1  -f image2 "++stillsLocation++seconds.asString++".png ").postln
		}
	}

	viewer {
		("open "++"'"++this.file++"'").unixCmd
	}


	image {|symbol| 
		var img;
		var seconds = markers.at(symbol);
		var fileName = stillsLocation++seconds.asString++".png";
		try{ img = Image.open(fileName) }
		^img
	}

	//set marker or retrieve image
	mark { |markerName seconds |
		var image;
		seconds.isNil.if{image=this.image(markerName);^image}{this.set(markerName,seconds)}
	}
	still { | key wait=5 fade=0 monitor text onTop=false|
		^Still.new(this,key,wait,fade,monitor,text, onTop)
	}
	at {|seconds|
		var fileName = stillsLocation++seconds.asString++".png";
		^Image.open(fileName)
	}
	*plotTitleCard{ |text monitor=0 dur=2 top=0 fade=1|
		var w;
		w = Window(bounds:Rect(1500*monitor, top,1440,900).postln.scale(scale ? 1).postln,border:false)
		.background_(Color.rand)
		.front;
		{ w.fade(fade, 1) }.defer(dur);
			 StaticText(w, Rect(1500*monitor,top, 1440, 900 ).scale(scale))
			.string_(text)
			.stringColor_(Color.rand)
			.align_(\center)
			.font_(Font(\helvetica,90 * Stills.scale => _.asInteger, bold:true))
		^w
	}
	plotClear{ |markerName monitor|
			var w;
			try{
				// w = Window(bounds:Rect(1500*monitor,200,1400,800) + Rect( trimLeft) => _.scale(scale),border:false)
				w = Window(bounds:monitors[monitor] + Rect(trimLeft,0,-1 * trimLeft,0) => _.scale(scale),border:false)
				//1196 x 676
				.background_( Color.clear)
				.front;  
			}{
				w = Window(bounds:Rect(0,200,1400 * scale,800 * scale).scale(scale),border:false)
				.background_( Color.clear)
				.front;  
			}
		^w
	}
	plot {|markerName monitor=0|
		var image=this.mark(markerName);
		var w;

		//first scale the image to the monitor
		image.setSize(monitors[monitor].width-10 * scale => _.asInteger, monitors[monitor].height-10  * scale => _.asInteger, \keepAspectRatio);
		//turn off scaling to trim - can I not do this with the drawFunc?
		image.scalesWhenResized_(false);
		//now trim the right black edges with trimWidth (trimLeft for left black edge)
		image.width_(image.width * trimWidth => _.asInteger);

		try{
			w = Window(bounds:monitors[monitor] + Rect(trimLeft, 0, -1 * trimLeft,0) => _.scale(scale),border:false)
			.background_( Color.clear)
			.drawFunc_({Pen.drawImage(Point(( -1 * trimLeft + 50 * scale ).asInteger,50),image,operation:'sourceOver',opacity:1)})
			.front;  
		}{
			w = Window(bounds:monitors[monitor],border:false)
			.background_( Color.clear)
			.drawFunc_({Pen.drawImage(Point(100,100),image,operation:'sourceOver',opacity:1)})
			.front;  
		}
		^w
	}
	//wiggle - get frames +- 10 
	//for backwards compat  
	title { |window text |
		( text.size == 1 ).if
		{
			StaticText(window,Rect (0,size/1200*600,size/12*14,200) + Rect(trimLeft,0,0, 0, 0))
			.string_(text[0])
			.stringColor_(Color.rand)
			.align_(\center)
			.font_(Font(\helvetica,size/1200*90,bold:true))
		}{
			StaticText(window,Rect (0,size/1200*100,size/12*14,200)+ Rect(trimLeft,0,-0, 0, 0))
			.string_(text[0])
			.stringColor_(Color.rand)
			.align_(\center)
			.font_(Font(\helvetica,size/1200*90,bold:true))
			;
			StaticText(window,Rect (0,size/1200*600,size/12*14,200)+ Rect(trimLeft,0,-0, 0, 0))
			.string_(text[1])
			.stringColor_(Color.rand)
			.align_(\center)
			.font_(Font(\helvetica,size/1200*90,bold:true))
		}
	}
}

Still {
	var <>stills,<>image;
	var <>markerName,<>wait,<>fade,<>fadeIn,<>monitor;
	var <>window,<>textUpper,<>textLower,timecode,<>text;
	var <>onTop, <>bounds, <>shrink;

	*new{|markerName timecode wait=5 fade=0 monitor text fadeIn stills onTop=false bounds shrink |
		^super.new.init(markerName,timecode,wait,fade,monitor,text,fadeIn,stills, onTop, bounds, shrink)
	}

        init{| n c w f m x i t o b, k |
          //DO WE EVEN NEED A MARKER NAME???????
          markerName = n;
		  bounds = b; shrink = k;
          x.isNil.if{text=["",""]}{text=x};
          t.isNil.if{ stills = Stills.current }{ stills = t };
          timecode = c;
          stills.set(markerName,timecode);
          image = stills.image(markerName);
          wait = w;fade=f;monitor=m;fadeIn=i;onTop=o;
        }

        play { 
			var view;
			Stills.muted.not.if{
				{ 
					window = stills.preview(markerName, wait,fade, monitor,fadeIn:fadeIn);
					window.alwaysOnTop_(onTop);
					view = window.view;
					// view.keyDownAction_({ this.window.close; CmdPeriod.run});
					view.keyDownAction_({|view key|
						Window.closeAll;
						TempoClock.all.do(_.clear);
						Server.default.freeMyDefaultGroup;
						Trek.transitionGroup.release;
						SCNvim.luaeval( "vim.api.nvim_input('%')".format(key) );
						"open -a WezTerm.app".unixCmd;
					});
					this.title(["",""], bounds, shrink);
					this.setText(text) 
				}.defer(Server.default.latency - 0.1); // timing fudge factor!! why does this work(or does it?) 
			}
          //{
          //}.defer
          ^this 
        }

        setText { 
          |strings|
          text = strings;
            ( strings.size==1 ).if{
              defer{ textLower.string_( strings[0] );
              textUpper.string=""
            };
            }{

              defer{textUpper.string_( strings[0] )};
              defer{textLower.string_( strings[1] )}
            }
        }

        sequenceText { | array |
          fork{
            array.pairsDo{ |time, textt|
              time.wait;
              this.setText(textt)
            }            
          }
        }
	sequenceText2 { | times texts |
		var array = [times, texts].flop.flatten;
		this.sequenceText( array )
	}

	plot {|markerName monitor=0|
		var image=this.mark(markerName);
		var w;
		try{
			w = Window(bounds:Rect(1500*monitor,200,1400,800),border:false)
			.background_( Color.clear)
			.drawFunc_({Pen.drawImage(Point(100,100),image,operation:'sourceOver',opacity:1)})
			.front;  //}.defer(Server.default.latency);
		}{
			w = Window(bounds:Rect(0,200,1400,800),border:false)
			.background_( Color.clear)
			.drawFunc_({Pen.drawImage(Point(100,100),image,operation:'sourceOver',opacity:1)})
			.front;  //}.defer(Server.default.latency);
		}
		^w
	//wiggle - get frames +- 10 
        //
	}
	
	title { |text b shrink|
		var size=stills.size;
		var bounds =  b ? Stills.monitors[monitor] + Rect(-1 * Stills.trimLeft) => _.scale(Stills.scale);
		var textHeight = bounds.height/4;
		//  top in Rects below really should ALSO depend on textHeight also!

		// var top = Rect(bounds.left, bounds.height/8, bounds.width, textHeight);
		var top = Rect(0, bounds.height/8, bounds.width, textHeight);

		var bottom = Rect(0, bounds.height*3/4, bounds.width, textHeight);
		shrink = shrink ? 0;
		bounds.postln;
		( text.size == 1 ).if
		{
			textUpper = StaticText(window,top)
			.string_("")
			.stringColor_(Color.rand)
			.align_(\center)
			.font_(Font(\helvetica,90 * Stills.scale * (1-shrink) => _.asInteger, bold:true))
			;
			textLower = StaticText(window,bottom)
			.string_(text[0])
			.stringColor_(Color.rand)
			.align_(\center)
			.font_(Font(\helvetica,90 * Stills.scale * (1-shrink) => _.asInteger, bold:true))
			;
		}{
			textUpper = StaticText(window,top)
			.string_(text[0])
			.stringColor_(Color.rand)
			.align_(\center)
			.font_(Font(\helvetica,90 * Stills.scale * (1-shrink) => _.asInteger, bold:true))
			;
			textLower = StaticText(window,bottom)
			.string_(text[1])
			.stringColor_(Color.rand)
			.align_(\center)
			.font_(Font(\helvetica,90 * Stills.scale * (1-shrink) => _.asInteger, bold:true))
		}
	}
	value { //for backward comp
		|monitor=0 wait fade fadeIn text onTop = false bounds shrink|

		monitor.notNil.if{ this.monitor = Stills.monitorChoiceFunction.() ? monitor}

		// this.monitor = 2.rand // to make image switch back and forth between two monitors
		//replace this with a function - `monitorChoiceFunction`
		;
		wait.notNil.if{ this.wait = wait};
		fade.notNil.if{ this.fade = fade};
		fadeIn.notNil.if{ this.fadeIn = fadeIn};
		text.notNil.if{ this.text = text};
		onTop.notNil.if{ this.onTop = onTop};
		bounds.notNil.if{ this.bounds=bounds};
		shrink.notNil.if{ this.shrink=shrink};
		this.play
	}

}
Display {
	classvar <>connected;
	classvar <>array, <>event;
	classvar <>monitors, <>mainMonitor;
	*initClass {
			// "displayplacer list > /tmp/displayList".systemCmd
			var raw = Pipe("displayplacer list", "r");
			var res = List[];
			var line = raw.getLine;
			monitors = List[ res ];
			while({ line.notNil }, 
				{monitors.last.add(line);
				line=raw.getLine;
				//each monitors description starts with "Persistent screen id" so add new entry
				line.asString.contains("Persistent screen id:").if { monitors.add(List.new)} 
			});
			raw.close;
			monitors = monitors.collect { |i|
				i.collect(_.split($:))
				[..8]
				.inject((), {|i j| 
					j = [j[0].toLower.asSymbol, j[1]].asEvent;
					i ++ j
				});
			};
			//clean up and parse 
			monitors.do({|ev| 
					ev.origin.contains("main").if { ev.put(\main, true); mainMonitor = ev }{ ev.put(\main, false) };
					ev.put(\resolution, "Point(" ++ ev.resolution.replace("x",",") ++ ")" => _.interpret);
			});
				monitors.do{|ev x| 
					ev.put(\origin, "Point" ++ ev.origin.split($))[0]++")" => _.interpret);
					//need to subtract resolution.y from origin.y because 'bounds'
					//uses x an y for lower left corner and displayplacer origin 
					//uses upper left corner
					// ev.put(\bounds, Rect(ev.origin.x, ev.origin.y - ev.resolution.y, ev.resolution.x, ev.resolution.y))
					ev.put(\bounds, Rect(ev.origin.x, mainMonitor.resolution.y - ev.origin.y - ev.resolution.y, ev.resolution.x, ev.resolution.y))
				}
	}
	*raw {
		// "displayplacer list > /tmp/displayList".systemCmd
		var raw = Pipe("displayplacer list", "r");
		var res = List[];
		var line = raw.getLine;
		while({ line.notNil }, {res.add(line); line=raw.getLine});
		raw.close
		^res
	}
	*at {|num|
		^monitors[num]
	}

	*resolutions {
		^"displayplacer list | grep -e Type -e Resolution:".systemCmd
	}
	*ids {
		^"displayplacer list | grep -e Type -e 'Persistent screen id:'".systemCmd
	}
	*list {
		"displayplacer list".systemCmd
	}

}

+ Window {
	fade { |fadeTime=1 alpha=1|
		fork{
			{alpha>0}.while{
				{this.alpha=(alpha-0.01)}.defer;
				alpha=alpha-0.01;
				(fadeTime/100).wait;
			};
			{this.close}.defer;
		}
	}
        fadeIn {
          | time fps=24 alpha=1 | 
          var alphaGoal = alpha; 
          var a = Env([0,alphaGoal],time).asStream;
          alpha = 0;
          fork{
            {alpha<alphaGoal}.while {
              { this.alpha = a.value; alpha = a.value }.defer;
              fps.reciprocal.wait;
            }
          }
        }
}
+P {
	*still {   // renders the still when compiled
		// and stores it in resources.still (e.still)
		|key start syl lag=0 timecode=60 music|
		var aStill;
		start = P.calcStart(start);
		key = key ++ start;
		aStill = timecode.isNumber.if{
			Still(Song.key ++ key ++ ( Song.calcStart( start ) ) => _.asSymbol, timecode:timecode);
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
				still: aStill,
				timecode: ( timecode.isNumber and: timecode.isStrictlyPositive ).if{timecode}{nil}
			),
			start: start,
			syl: syl,
			lag: lag,
			music: music
		)


	}
}
