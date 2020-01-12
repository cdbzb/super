Stills {
	classvar <>stillsLocation = "/tmp/";
	var <>file;
	var <>markers;
	*new {|movie| ^super.new.init(movie)}
	init {|movie| file=movie; markers=()  }

	//monitor -1 for left 0 for center default is -1
	preview {|markerName wait=5 monitor| var w=this.plot(markerName,monitor);{w.close}.defer(wait);^w}

	plot{|markerName monitor=(-1)|
		var image=this.mark(markerName);
		var w = Window(bounds:Rect(1500*monitor,200,1400,800),border:false)
		.background_( Color.black)
		.drawFunc_({Pen.drawImage(Point(100,100),image,operation:'sourceOver',opacity:1)});
		{w.front}.defer(Server.default.latency);
		^w
	}

	set {|markerName seconds| markers.put(markerName,seconds);this.fetch(markers.at(markerName))}

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
	
}


