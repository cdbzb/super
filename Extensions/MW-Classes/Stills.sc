//(
//	t=StaticText.new(w,Rect(0,0,500,200))
//	.string_('LLLL')
//	.stringColor_(Color.rand)
//	//.align_(\left)
//	.font_(Font(\helvetica,90,bold:true))
//)
Stills {
	classvar <>stillsLocation = "/tmp/";
	var <>file;
	var <>markers;
	var <>fade;
	var <>font;
	var <>window;
	*new {|movie| ^super.new.init(movie)}
	init {|movie| file=movie; markers=()  }

	//monitor -1 for left 0 for center default is -1
	preview {|markerName wait=5 fade=0 monitor text| 
		var w=this.plot(markerName,monitor);
		text.isNil.not.if{this.title(w,text)};
		{w.fade(fade)}.defer(wait);
		^w}


	viewer {
		("open "++"'"++this.file++"'").unixCmd
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
	

	title { |window text|
		StaticText(window,Rect (0,600,1400,200))
		.string_(text[0])
		.stringColor_(Color.rand)
		.align_(\center)
		.font_(Font(\helvetica,90,bold:true))
		;
		StaticText(window,Rect (0,810,1400,200))
		.string_(text[1])
		.stringColor_(Color.rand)
		.align_(\center)
		.font_(Font(\helvetica,90,bold:true))
	}

	set {|markerName seconds| 
		( markers.at(markerName) == seconds ).not.if {
			markers.put(markerName,seconds);this.fetch(markers.at(markerName))
		}
	}

	//gets frame at |seconds| and saves it in classvar stillsLocation
	fetch { |seconds |
		("ffmpeg -ss "++
			seconds.asString++" -i "++"'"++file.asSymbol++"'"++
			"  -vframes 1  -f image2 "++stillsLocation++seconds.asString++".png ").systemCmd
		}
		

	//opens image at |seconds| in stillsLocation

	at {|seconds|
		var fileName = stillsLocation++seconds.asString++".png";
		^Image.open(fileName)
	}

	//returns the image at key |symbol| if on disk, otherwise fetches and saves it.
	//todo is some kind of waiting/Promise thing to return the image in the second
	//case

	image {|symbol| 
		var img;
		img=try {this.at(markers.at(symbol))}
				{this.fetch(markers.at(symbol));}
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
	
}

Still {
	var <>stills;
	var <>markerName,<>wait,<>fade,<>monitor,<>text;
	var <>window;

	*new{|stills markerName wait=5 fade=0 monitor text| ^super.newCopyArgs(stills,markerName,wait,fade,monitor,text)}

	play { defer{ window=stills.preview(markerName,wait,fade,monitor,text) } }

	add {|seconds| stills.set(markerName,seconds) }

	//wiggle - get frames +- 10 
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
}
