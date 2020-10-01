+ Object {
	//?= {|that| this ? (this=that) }

	dm { |root=0 octave=5 scale=\major|
	^this.degreesmidi(root,octave,scale)
	}

	df { |root=0 octave=5 scale=\major|
	^this.degreescps(root,octave,scale)	
	}

}

