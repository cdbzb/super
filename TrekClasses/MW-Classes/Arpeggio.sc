Arpeggio : Array {
	*new { |array numNotes=5 symbol=\up|
		^super.new.init(array,numNotes,symbol);
	}
	//TODO make direction depend on symbol
	init { |array numNotes symbol|
		^LazyList.iterate(0,_+7)
		.collect({|i|(i+array).asLazy}).flatten
		.take(numNotes).asArray
	}
}

//Octaves : LazyList {
//	LazyList.iterate(0,_+7)
//}

+Array{
	arpeggio{ |num symbol|
		^Arpeggio(this,num,symbol)
	}
}


