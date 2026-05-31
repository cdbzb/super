+ SequenceableCollection {
	asDefName {
		var out = Array(this.size);
		this.do { |item|
			if(item.respondsTo(\asDefName)) {
				out.add(item.asDefName)
			} {
				Error("Invalid item in defname array" + item).throw;
			};
		};
		^out
	}
}

