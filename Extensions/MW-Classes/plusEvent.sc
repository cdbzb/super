EventWithDefault  {
	var <>event;
	*new { |...args| ^super.new.init(args) }
	init {|...args| 
		event = Event.newFrom(*args)
	}
	at {|key|
		^( event.at(key) ? event.at(\default) )
	}
	doesNotUnderstand { |selector value|
		( selector.asString.last == $_ ).if{
			selector.asString.dropLast.asSymbol
			=> event.put(_,value);
		} {
			^event.at( selector ) ? event.at(\default);
		}
	}


}
/*
a=EventWithDefault()
*/
