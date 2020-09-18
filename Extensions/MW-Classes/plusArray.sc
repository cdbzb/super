+ Array {
	asDegrees { |root=0 octave=5 scale=\major| 
		^this.collect{|i| 
			i.asDegrees(root,octave,scale)
		}
	}

	degreescps { |root=0 octave=5 scale=\major|
		^this.collect{|i|
			i.degreescps(root,octave,scale)
		}
	}

	degreesmidi {|root=0 octave=5 scale=\major|
		^this.collect{|i|
			i.degreesmidi(root,octave,scale)
		}
	}

	flopEvents {
		^this.flop.collect(_.asEvent)
	}

	quantize {
		| percent=1| ^( this*(1-percent) + ( this.mean*(percent) ) )
	}

	quantizeWindow {
		|percent=0.25 windowSize=5|
		(this.size-windowSize).postln;
		this[0..(this.size-windowSize)].do{|i x|
			var chunk = this[x..(x +windowSize)];
			chunk=chunk.quantize(percent);
			chunk.do{|it in| this.put(in+x,it)}
		};
		^this;
	}

	addLine {
//		Song.songs.at(Song.current).addLine(this);
		Song.currentSong.addLine(this);
	}
}

+ SimpleNumber {
	asDegrees { |root=0 octave=5 scale=\major| 
		var i=this;
		(root.class==Symbol).if{ root=
			(
				c:0,'c#':1 ,d:2,'d#':3,'e-':3,e:4,f:5,'f#':6,'g-':6,g:7,'g#i':8,'a-':8,a:9,'a#':10,'b-':10,b:11,
				C:-12,'C#':-11 ,D:-10,'D#':-9,'E-':-9,E:-8,F:-7,'F#':-6,'G-':-6,G:-5,'G#I':-4,'A-':-4,A:-3,'A#':-2,'B-':-2,B:-1
			).at(root)
		};
		i=i-1; 
		^[
			(i / 10).floor * 12, 
			Scale.at(scale)[i % 10]
		].sum.asInt
		+ (i.frac*2)
		+root+(octave*12)
	}

	degreesmidi {|root=0 octave=5 scale=\major|
		^this.asDegrees(root,octave,scale)
	}

	degreescps { |root=0 octave=5 scale=\major|
		^this.asDegrees(root,octave,scale).midicps
	}

}

+Symbol {
	degreesmidi {
		^this
	}
	degreescps {
		^this
	}
}
+Pseq {
	quantize { |amount|
		var pseq= this.copy;
		var list =pseq.list.asArray.quantize(amount);
		pseq.list_(list);
		^pseq
	}

	quantizeWindow { |amount|
		var pseq= this.copy;
		var list =pseq.list.asArray.quantize(amount);
		pseq.list_(list);
		^pseq
	}
}


