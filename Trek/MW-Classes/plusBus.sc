+Bus {
	asMaps {
		var prefix;
		if(index.isNil) { MethodError("bus not allocated.", this).throw };
		prefix = if(rate == \control) { "c" } { "a" };
		^(index .. (index + numChannels - 1)).collect { |i| (prefix ++ i).asSymbol }
	}
}