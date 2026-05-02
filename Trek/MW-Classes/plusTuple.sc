+ Tuple2 { flop { ^this.prFlopTuple } }
+ Tuple3 { flop { ^this.prFlopTuple } }
+ Tuple4 { flop { ^this.prFlopTuple } }
+ Tuple5 { flop { ^this.prFlopTuple } }
+ Tuple6 { flop { ^this.prFlopTuple } }

+ Object {
	prFlopTuple {
		var args = this.storeArgs;
		var sizes = args.collect { |x| x.isArray.if { x.size } { 1 } };
		var n = sizes.maxItem;
		(n <= 1).if { ^[this] };
		^n.collect { |i|
			T(*args.collect { |x| x.isArray.if { x.wrapAt(i) } { x } })
		}
	}
}
