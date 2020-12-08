+ Object {
	//?= {|that| this ? (this=that) }

	dm { |root=0 octave=5 scale=\major tuning	|
	^this.degreesmidi(root,octave,scale,tuning)
	}

	df { |root=0 octave=5 scale=\major tuning|
	^this.degreescps(root,octave,scale,tuning)	
	}

}

