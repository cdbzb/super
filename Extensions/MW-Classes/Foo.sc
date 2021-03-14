Durs { 
	//Song.durs returns a Durs
	var <>song;
	*new { |song|  ^super.new.init(song)}
	init { |i|  song=i ? Song.currentSong }
	at{|i|
		song ? song=Song.currentSong; 
		i.isInteger.not.if{i=song.section(i.asSymbol)};
		^ song.lyrics.collect{ |x| song.lyricsToDurs[x] }[i] 
			? [1].q
	}
	copySeries {|i j k|
		song ? song=Song.currentSong; 
		i.isInteger.not.if{i=song.section(i.asSymbol)};
		^ song.lyrics.collect{ |x| song.lyricsToDurs[x] ? [1].q }
			.copySeries(i,j,k)
	}

	put{|i j| 
		//should make a method that picks by number OR symbol
		song ? song=Song.currentSong; 
		case
		{i.isInteger}{song.lyricsToDurs.put(song.lyrics[i],j)}
		{i.class==Symbol}{song.lyricsToDurs.put(song.lyrics[song.section(i)],j)}
	}
}

SongArray { //array which can be indexed by current song lyric
	var <>array,<>song;
	*new {|array key| ^super.new.init(array,key)}
	init {|ary key size=128| 
		array=ary ? Order(size);
		key.isNil.if (
			{song=Song.currentSong},
			{song=Song.songs.at(key)}
		);
	}
	at { |i| 
		i.isInteger.not.if{i=song.section(i.asSymbol)};
		^array[i]
	}
	copySeries{|i j k| ^array.copySeries(i,j,k) }
	put { |i x| 
		i.isInteger.not.if{i=song.section(i.asSymbol)};
		array.put(i,x)
	}
}




