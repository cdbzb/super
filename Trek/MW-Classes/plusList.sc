+SequenceableCollection{
	dropLast { |x 1|
		^this[0.. (this.size - 1 - x)]
	}
}
