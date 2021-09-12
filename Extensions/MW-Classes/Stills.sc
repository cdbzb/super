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
	var <>file;
	var <>markers;
	var <>fade;
	var <>font;
	var <>window;
        var <>stills;

	*new {|movie| ^super.new.init(movie)}

        *reaper {
		("open "++ "/Users/michael/trek/video for stills etc/video for stills etc.RPP".escapeChar(Char.space)).unixCmd
        }

	init {|movie| file=movie; markers=()  }

	//monitor -1 for left 0 for center default is -1
	preview {|markerName wait=5 fade=0 monitor text fadeIn| 
		var w=this.plot(markerName,monitor);
                fadeIn.notNil.if{w.fadeIn(fadeIn)};
		text.notNil.if{this.title(w,text)};
		{w.fade(fade)}.defer(wait);
		^w}

        current {
          super.current = this
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
		(
                  "ffmpeg -y -ss "++ seconds.asString++" -i "++"'"++file.asSymbol++"'"++ "  -vframes 1  -f image2 "++stillsLocation++seconds.asString++".png ").systemCmd;
                  ("ffmpeg -ss "++ seconds.asString++" -i "++"'"++file.asSymbol++"'"++ "  -vframes 1  -f image2 "++stillsLocation++seconds.asString++".png ").postln
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
	still { | key wait=5 fade=0 monitor text|
		^Still.new(this,key,wait,fade,monitor,text)
	}

        at {|seconds|
                var fileName = stillsLocation++seconds.asString++".png";
                ^Image.open(fileName)
        }

	plot{|markerName monitor=(-1)|
		var image=this.mark(markerName);
		var w;
		try{
			w = Window(bounds:Rect(1500*monitor,200,1400,800),border:false)
			.background_( Color.black)
			.drawFunc_({Pen.drawImage(Point(100,100),image,operation:'sourceOver',opacity:1)})
			.front;  //}.defer(Server.default.latency);
		}{
			w = Window(bounds:Rect(0,200,1400,800),border:false)
			.background_( Color.black)
			.drawFunc_({Pen.drawImage(Point(100,100),image,operation:'sourceOver',opacity:1)})
			.front;  //}.defer(Server.default.latency);
		}
		^w
	}
	//wiggle - get frames +- 10 

        //for backwards compat  
        title { |window text |
          ( text.size == 1 ).if
          {
            StaticText(window,Rect (0,600,1400,200))
            .string_(text[0])
            .stringColor_(Color.rand)
            .align_(\center)
            .font_(Font(\helvetica,90,bold:true))
          }{
            StaticText(window,Rect (0,100,1400,200))
            .string_(text[0])
            .stringColor_(Color.rand)
            .align_(\center)
            .font_(Font(\helvetica,90,bold:true))
            ;
            StaticText(window,Rect (0,600,1400,200))
            .string_(text[1])
            .stringColor_(Color.rand)
            .align_(\center)
            .font_(Font(\helvetica,90,bold:true))
          }
	}
}

Still {
  var <>stills,<>image;
	var <>markerName,<>wait,<>fade,fadeIn,<>monitor;
        var <>window,<>textUpper,<>textLower,timecode,<text;

	*new{|markerName timecode wait=5 fade=0 monitor text fadeIn stills  | ^super.new.init(markerName,timecode,wait,fade,monitor,text,fadeIn,stills)}

        init{| n c w f m x i t |
          //DO WE NEED A MARKER NAME???????
          markerName = n;
          x.isNil.if{text=["",""]}{text=x};
          t.isNil.if{ stills = Stills.current }{ stills = t };
          timecode = c;
          stills.set(markerName,timecode);
          image = stills.image(markerName);
          wait = w;fade=f;monitor=m;fadeIn=i;
        }

        play { 
          { 
            window = stills.preview(markerName, wait,fade, monitor,fadeIn);
            this.title(["",""]);
          }.defer; 
          {
            this.text_(text) 
          }.defer
          ^this 
        }

        text_ { 
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

	plot{|markerName monitor=(-1)|
		var image=this.mark(markerName);
		var w;
		try{
			w = Window(bounds:Rect(1500*monitor,200,1400,800),border:false)
			.background_( Color.black)
			.drawFunc_({Pen.drawImage(Point(100,100),image,operation:'sourceOver',opacity:1)})
			.front;  //}.defer(Server.default.latency);
		}{
			w = Window(bounds:Rect(0,200,1400,800),border:false)
			.background_( Color.black)
			.drawFunc_({Pen.drawImage(Point(100,100),image,operation:'sourceOver',opacity:1)})
			.front;  //}.defer(Server.default.latency);
		}
		^w
	//wiggle - get frames +- 10 
        //
	}
	

        title { |text|
          ( text.size == 1 ).if
          {
            textUpper = StaticText(window,Rect (0,100,1400,200))
            .string_("")
            .stringColor_(Color.rand)
            .align_(\center)
            .font_(Font(\helvetica,90,bold:true))
            ;
            textLower = StaticText(window,Rect (0,600,1400,200))
            .string_(text[0])
            .stringColor_(Color.rand)
            .align_(\center)
            .font_(Font(\helvetica,90,bold:true))
            ;
          }{
            textUpper = StaticText(window,Rect (0,100,1400,200))
            .string_(text[0])
            .stringColor_(Color.rand)
            .align_(\center)
            .font_(Font(\helvetica,90,bold:true))
            ;
            textLower = StaticText(window,Rect (0,600,1400,200))
            .string_(text[1])
            .stringColor_(Color.rand)
            .align_(\center)
            .font_(Font(\helvetica,90,bold:true))
          }
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
            {alpha<alphaGoal}.while
            {
              { this.alpha = a.value; alpha = a.value }.defer;
              fps.reciprocal.wait;
            }
          }
        }
}
