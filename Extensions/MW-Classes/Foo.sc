Foo { 
	//Song.durs returns a Foo
	var <>song;
	*new {  ^super.new.init()}
	init { song=Song.currentSong }
	at{|i|
		i.isInteger.not.if{i=song.section(i.asSymbol)};
		^ song.lyrics.collect{ |x| song.lyricsToDurs[x] }[i] 
			? [1].q
	}
	put{|i j| 
		//should make a method that picks by number OR symbol
		case
		{i.isInteger}{song.lyricsToDurs.put(song.lyrics[i],j)}
		{i.class==Symbol}{song.lyricsToDurs.put(song.lyrics[song.section(i)],j)}
	}
}



