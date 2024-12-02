Params {
	*new { | array |
		var event = array.asEvent;
		^Prout{
			loop{
				event.params.collect{ |param|
					[param.asSymbol, 
						event[param].value(event).next
					]
				}
				.flatten
				.debug("param")
				.yield
			}
		}
	}
}
