
+ String{
	copyTuneFrom { 
		^Song.song[ Song.song.indexOfEqual( this ) + 1 ] 
	}
}
+ P{
	*clone{|section part resources| 
		var newPart;
		(part.size > 0).if{ part.do{ |singlePart|
			P.clone(section, singlePart) };
		} {
			part = Song.at(Song.section(section)).select{|i| i.key == part}[0];
			// newPart = part.copy; 
			newPart = try{ P(
				part.key,
				start: P.calcStart(),
				syl: part.syl,
				lag: part.lag,
				resources: part.resources ++ ( resources ? () ),
				music: part.music
			) };
			^newPart 
		}
	}
}
+Song{
	cloneDursAndTempoMap{ |original|
		var section = P.calcStart();
		Song.durs[section] = Song.durs[original];
		Song.tempoMap[section] = Song.tempoMap[original];
	}
	cloneDurs{ |original|
		var section = P.calcStart();
		Song.durs[section] = Song.durs[original];
	}
	getMusicFunction{ |section key|
		^Song.resources.at( key ++ "_" ++Song.section(section) => _.asSymbol ).music.cs

	}
}
