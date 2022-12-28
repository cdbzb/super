NoteName {
	classvar <names;
	*initClass{ 
		names = (
			c:0,'d-':1,'c#':1 ,d:2,'d#':3,'e-':3,e:4,f:5,'f#':6,'g-':6,g:7,'g#i':8,'a-':8,a:9,'a#':10,'b-':10,b:11,
			C:-12,'C#':-11 ,D:-10,'D#':-9,'E-':-9,E:-8,F:-7,'F#':-6,'G-':-6,G:-5,'G#':-4,'A-':-4,A:-3,'A#':-2,'B-':-2,B:-1
				)
	}
	*doesNotUnderstand{ |i|
		i.postln;
		^try{names.at(i)}
	}
}
+Symbol {
	asNum {
		^NoteName.names.at(this)
	}
}

+ Object {
	//?= {|that| this ? (this=that) }

	dm { 
		|root=0 octave=5 scale=\major tuning	transpose|
		^this.degreesmidi(root,octave,scale,tuning,transpose)
	}

	df { 
		|root=0 octave=5 scale=\major tuning transpose|
		^this.degreescps(root,octave,scale,tuning, transpose)	
	}

}

+ Symbol {
	asNote{

	}
}
+ SimpleNumber {
	asDegrees { |root=0 octave=5 scale=\major tuning transpose| 
		var i=this;
		var rootToNum;
		scale = Scale.at(scale,tuning).deepCopy;
		tuning !? {|i|scale.tuning_(i)};
		rootToNum ={ |i|
			(i.class==Symbol).if{
				(
					cc:10,'dd-':11,'cc#':11 ,dd:12,'dd#':13,'ee-':13,ee:14,ff:15,'ff#':16,'gg-':16,gg:17,'gg#':18,'aa-':18,aa:19,'aa#':20,'bb-':20,bb:21,
					c:0,'d-':1,'c#':1 ,d:2,'d#':3,'e-':3,e:4,f:5,'f#':6,'g-':6,g:7,'g#i':8,'a-':8,a:9,'a#':10,'b-':10,b:11,
					C:-12,'C#':-11 ,D:-10,'D#':-9,'E-':-9,E:-8,F:-7,'F#':-6,'G-':-6,G:-5,'G#I':-4,'A-':-4,A:-3,'A#':-2,'B-':-2,B:-1
				).at(i) + (transpose ? 0)
			
		} {
			i (transpose ? 0)
		}
	};

		(root.isKindOf(SequenceableCollection)).if{root=root.collect(rootToNum.(_))}{root=rootToNum.(root)};
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

	degreesmidi {|root=0 octave=5 scale=\major tuning transpose|
		^this.asDegrees(root,octave,scale,tuning,transpose)
	}

	degreescps { |root=0 octave=5 scale=\major tuning transpose|
		^this.asDegrees(root,octave,scale,tuning,transpose).midicps
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
