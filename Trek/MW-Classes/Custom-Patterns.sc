MuteFirst {
	*new{
		^Routine{
			\r.yield;
			loop{
				1.yield
			}
		}.asStream
	}
}
