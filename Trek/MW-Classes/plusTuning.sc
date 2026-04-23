+ Tuning {
	add { |key|
		Tuning.all[(key ?? { name }).asSymbol] = this;
		^this
	}
}
