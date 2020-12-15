+ Object {
	//?= {|that| this ? (this=that) }

	dm { 
		|root=0 octave=5 scale=\major tuning	|
		^this.degreesmidi(root,octave,scale,tuning)
	}

	df { 
		|root=0 octave=5 scale=\major tuning|
		^this.degreescps(root,octave,scale,tuning)	
	}

}

+ SimpleNumber {
	asDegrees { |root=0 octave=5 scale=\major tuning| 
		var i=this;
		scale = Scale.at(scale,tuning).deepCopy;
		tuning !? {|i|scale.tuning_(i)};
		(root.class==Symbol).if{ root=
			(
				c:0,'d-':1,'c#':1 ,d:2,'d#':3,'e-':3,e:4,f:5,'f#':6,'g-':6,g:7,'g#i':8,'a-':8,a:9,'a#':10,'b-':10,b:11,
				C:-12,'C#':-11 ,D:-10,'D#':-9,'E-':-9,E:-8,F:-7,'F#':-6,'G-':-6,G:-5,'G#I':-4,'A-':-4,A:-3,'A#':-2,'B-':-2,B:-1
			).at(root)
		};

		( i<0 ).if{
			var octavesDown;
			i=i.abs;
			octavesDown=i/10=>_.floor + 1;
			octave=octave-octavesDown;
			i=i%10;
		};
		i=i-1; 
		^[
			(i / 10).floor * 12, 
			scale[i % 10]
		].sum
		//.asInteger

		+ (i.frac*2)
		+root+(octave*12)
	}

	degreesmidi {|root=0 octave=5 scale=\major tuning|
		^this.asDegrees(root,octave,scale,tuning)
	}

	degreescps { |root=0 octave=5 scale=\major tuning|
		^this.asDegrees(root,octave,scale,tuning).midicps
	}

	q {
		^[this].q
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
