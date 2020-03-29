+ Array {
	asDegrees { |root=0 octave=5 scale=\major| 
		^this.collect{|i| 
			i=i-1; 
			[
				(i / 10).floor * 12, 
				Scale.at(scale)[i % 10]].sum.asInt}+root+(octave*12)
	}
	degreescps { |root=0 octave=5 scale=\major|
		^this.asDegrees(root,octave,scale).midicps
	}
}
