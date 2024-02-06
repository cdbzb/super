//(
//	t=StaticText.new(w,Rect(0,0,500,200))
//	.string_('LLLL')
//	.stringColor_(Color.rand)
//	//.align_(\left)
//	.font_(Font(\helvetica,90,bold:true))

//)
Stills {
	classvar <>stillsLocation = "/tmp/";
	classvar <>current;
	classvar <>muted=false;
	classvar <>scale=1;
	var <>file;
	var <>markers;
	var <>fade;
	var <>font;
	var <>window;
	var <>stills;
	var <>size=1200;
	var <>monitors;


	*new {|movie| ^super.new.init(movie)}


	*reaper {
		("open "++ this.class.filenameSymbol.asString.dirname.dirname +/+ "Stills/video for stills etc.RPP".escapeChar(Char.space)).unixCmd
	}
	dual {
		monitors= [
			Rect(left:0,top:200,width:1400,height:800),
			Rect(left:-1500,top:200,width:1400,height:800)
		]
	}

	init {|movie| 
		// file=movie ? ( this.class.filenameSymbol.asString.dirname.dirname +/+ "Stills/return-to-tomorrow.cropped.mov" ); 
		// file=movie ? ( this.class.filenameSymbol.asString.dirname.dirname +/+ "Stills/return-to-tomorrow.mov" ); 
		// file=movie ? ( this.class.filenameSymbol.asString.dirname.dirname +/+ "Stills/new.mp4" ); 
		file=movie ? ( this.class.filenameSymbol.asString.dirname.dirname +/+ "Stills/trimmed433.mov" ); 
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
	preview { |markerName wait=5 fade=0 monitor=0 text fadeIn| 
		var w;
		muted.not.if{
			(markerName.asString.contains ( "clear")).if{
				w=this.plotClear(markerName,monitor)
			}{
				w=this.plot(markerName,monitor)
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

	plotClear{
		|markerName monitor=(-1)|
		var image=this.mark(markerName);
		var w;
		try{
			w = Window(bounds:Rect(1500*monitor,200,1400,800).scale(scale),border:false)
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
		// image.setSize(monitors[monitor].width-10 * scale => _.asInteger,monitors[monitor].height-10 => _.asInteger * scale, \keepAspectRatio);
		image.setSize(monitors[monitor].width-10 * scale => _.asInteger,monitors[monitor].height-10  * scale => _.asInteger, \keepAspectRatio);
		try{
			//w = Window(bounds:Rect(1500*monitor,200,size/12*14,size/12*8),border:false)
			w = Window(bounds:monitors[monitor].scale(scale),border:false)
			// w = Window(bounds:Rect(1500*monitor,200,1400 * scale,800 * scale),border:false)
			.background_( Color.clear)
			// .drawFunc_({Pen.drawImage(Point(100,100),image,operation:'sourceOver',opacity:1)})
			.drawFunc_({Pen.drawImage(Point(50,50),image,operation:'sourceOver',opacity:1)})
			.front;  
		}{
			//w = Window(bounds:Rect(0,200,size/12*14,size/12*8),border:false)
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
			StaticText(window,Rect (0,size/1200*600,size/12*14,200))
			.string_(text[0])
			.stringColor_(Color.rand)
			.align_(\center)
			.font_(Font(\helvetica,size/1200*90,bold:true))
		}{
			StaticText(window,Rect (0,size/1200*100,size/12*14,200))
			.string_(text[0])
			.stringColor_(Color.rand)
			.align_(\center)
			.font_(Font(\helvetica,size/1200*90,bold:true))
			;
			StaticText(window,Rect (0,size/1200*600,size/12*14,200))
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
	var <>onTop;

	*new{|markerName timecode wait=5 fade=0 monitor text fadeIn stills onTop=false  |
		^super.new.init(markerName,timecode,wait,fade,monitor,text,fadeIn,stills, onTop)
	}

        init{| n c w f m x i t o |
          //DO WE EVEN NEED A MARKER NAME???????
          markerName = n;
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
						SCNvim.luaeval( "vim.api.nvim_input('%')".format(key) );
						"open -a WezTerm.app".unixCmd;
					});
					this.title(["",""]);
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
	
	title { |text|
		var size=stills.size;
		var bounds = stills.monitors[monitor].scale(Stills.scale);
		var textHeight = bounds.height/4;
		//  top in Rects below really should ALSO depend on textHeight also!
		var top = Rect(bounds.left,bounds.height/8,bounds.width,textHeight);
		var bottom = Rect(bounds.left,bounds.height*3/4,bounds.width,textHeight);
		( text.size == 1 ).if
		{
			textUpper = StaticText(window,top)
			.string_("")
			.stringColor_(Color.rand)
			.align_(\center)
			.font_(Font(\helvetica,90 * Stills.scale => _.asInteger, bold:true))
			;
			textLower = StaticText(window,bottom)
			.string_(text[0])
			.stringColor_(Color.rand)
			.align_(\center)
			.font_(Font(\helvetica,90 * Stills.scale => _.asInteger, bold:true))
			;
		}{
			textUpper = StaticText(window,top)
			.string_(text[0])
			.stringColor_(Color.rand)
			.align_(\center)
			.font_(Font(\helvetica,90 * Stills.scale => _.asInteger, bold:true))
			;
			textLower = StaticText(window,bottom)
			.string_(text[1])
			.stringColor_(Color.rand)
			.align_(\center)
			.font_(Font(\helvetica,90 * Stills.scale => _.asInteger, bold:true))
		}
	}
	value { //for backward comp
		|monitor=0 wait fade fadeIn text onTop = false|
		monitor.notNil.if{ this.monitor = monitor};
		wait.notNil.if{ this.wait = wait};
		fade.notNil.if{ this.fade = fade};
		fadeIn.notNil.if{ this.fadeIn = fadeIn};
		text.notNil.if{ this.text = text};
		onTop.notNil.if{ this.onTop = onTop};
		this.play
	}

}
Display {
	classvar <>connected;
	classvar <>array;
	*initClass {
		var p, l, r, ll, rr;
		connected = Dictionary.new;
		array = List.new;
		p=Pipe("displayplacer list | grep -e Type -e Resolution:","r");
		l = p.getLine;
		while({l.notNil},{
			var e = ();
			var r = p.getLine;
			ll = l.split(Char.space)[0].drop(-1); rr = r.split(Char.space)[0].drop(-1);
			e.put(ll, l.drop(ll.size));
			e.put(rr, r.drop(rr.size));
			array = array.add(e);
			l = p.getLine;
		});
	}
	*resolutions {
		"displayplacer list | grep -e Type -e Resolution:".systemCmd
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
