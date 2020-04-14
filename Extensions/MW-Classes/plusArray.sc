+ Array {
	asDegrees { |root=0 octave=5 scale=\major| 
		^this.collect{|i| 
			i=i-1; 
			[
				(i / 10).floor * 12, 
				Scale.at(scale)[i % 10]
			].sum.asInt
			+ (i.frac*2)
		}+root+(octave*12)
	}

	degreescps { |root=0 octave=5 scale=\major|
		^this.asDegrees(root,octave,scale).midicps
	}

	flopEvents {
		^this.flop.collect(_.asEvent)
	}
}
+ Integer {
	asDegrees { |root=0 octave=5 scale=\major| 
		var i=this;
			i=i-1; 
			^[
				(i / 10).floor * 12, 
				Scale.at(scale)[i % 10]
			].sum.asInt
			+ (i.frac*2)
		+root+(octave*12)
	}


	degreescps { |root=0 octave=5 scale=\major|
		^this.asDegrees(root,octave,scale).midicps
	}

}
