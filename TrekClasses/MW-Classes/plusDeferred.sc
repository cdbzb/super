+ Deferred {
    *fromCallback { |function|
        var def = Deferred();
        function.value({|res| def.value = res });
        ^def
    }
    --> {|that|
	    this.then(that)
    }
}
+ Function {
	deferred { ^Deferred().using(this) }
}
+ Object{
	syncThen {|i|
		^deferred{
			Server.default.sync; this 
		}.then(i)
	}
}

// usage
