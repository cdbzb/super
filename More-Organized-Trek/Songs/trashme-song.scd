(
Song(\trash,[]).current;
	Song.currentSong.preroll_(1);
	["foo",[1,2,3,4,2,4,3,2,1].dm(\c)].addLine;
	P(\test,start:\foo,music:{|p b e| 
	});
		P.tune(\foo);
)

