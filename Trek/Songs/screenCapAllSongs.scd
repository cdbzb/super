(
~songs = "~/tank/super/Trek/Songs/*".standardizePath.pathMatch.sort;
fork{
	~songs[[2,3]].do{|i|
		Song.initClass;
		0.1.wait;
		i.load;
		20.wait;
		Song.recordOBS;
		Song.sections.collect{|i| Song.secDur[i]}.sum + 5 => _.wait;
		Window.closeAll;
	}
}
)

