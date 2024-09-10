(
fork{
	"~/tank/super/Trek/Songs/*".standardizePath.pathMatch.select{|i| i.extension == "scd"}
	.do{|i| 
		i.load;
		10.wait;
		s.newBufferAllocators;
		// ~myFree.()
		// 20.wait;
		// ~lengths.add(
			Song.sections.collect(Song.secDur[ _ ]).select(_.notNil).sum.postln
		// )
	}
}
)
