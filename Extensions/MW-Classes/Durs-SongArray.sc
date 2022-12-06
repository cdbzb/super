Durs { 
	//Song.durs returns a Durs
	var <>song;
	*new { |song|  ^super.new.init(song)}
	init { |i|  song={ i.key }.try ? Song.current }
	at{|i|
		song ? song=Song.current; 
		i.isInteger.not.if{i=Song.songs.at(song).section(i.asSymbol)};
		^ Song.songs.at(song).lyrics.collect{ |x| Song.songs.at(song).lyricsToDurs[x] }[i] 
			? [1].q
	}
	copySeries {|i j k|
		song ? song=Song.current; 
		i.isInteger.not.if{i=Song.songs.at(song).section(i.asSymbol)};
		^ Song.songs.at(song).lyrics.collect{ |x| Song.songs.at(song).lyricsToDurs[x] ? [1].q }
			.copySeries(i,j,k)
	}

	put{|i j| 
		//should make a method that picks by number OR symbol
		song ? song=Song.current; 
		case
		{i.isInteger}{Song.songs.at(song).lyricsToDurs.put(Song.songs.at(song).lyrics[i],j)}
		{i.class==Symbol}{Song.songs.at(song).lyricsToDurs.put(Song.songs.at(song).lyrics[Song.songs.at(song).section(i)],j)}
	}
	scale {|section amount|
		this.put(section,this.at(section).list * amount => _.q)
	}
}

SongArray { //array which can be indexed by current song lyric
	var <>array,<>song;
	*new {|array key| ^super.new.init(array,key)}
	init {|ary key size=128| 
		array=ary ? Order(size);
		song = key ? Song.current; // a Symbol
	}
	at { |i| 
		i.isInteger.not.if{i=Song.songs.at(song).section(i.asSymbol)};
		^array[i]
	}
	copySeries{|i j k| ^array.copySeries(i,j,k) }
	put { |i x| 
		i.isInteger.not.if{i=Song.songs.at(song).section(i.asSymbol)};
		array.put(i,x)
	}
}
/*
a=SongArray()
a.put(3,\polanet)
a.array
a.at(3)
a=Order()
a.put(0,3.5)
*/








