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
