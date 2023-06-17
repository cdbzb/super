+ TempoClock {
	*newFromQuarters { |quarters|
	var clock = this.new();
	quarters.do{|i x| clock.schedAbs( x , { clock.tempo_(i.reciprocal) } )};
	^clock;
	}
}

+ Array {
	asTempoClock {
		^TempoClock.newFromQuarters(this)
	}
}

+ List {
	asTempoClock {
		^TempoClock.newFromQuarters(this)
	}
}

+ Pseq {
	asTempoClock {
		^TempoClock.newFromQuarters(this.list)
	}
}
