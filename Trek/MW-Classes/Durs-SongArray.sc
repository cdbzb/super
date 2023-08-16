Durs { 
	//Song.durs returns a Durs
	var <>song;
	var filters;
	*new { |song|  ^super.new.init(song)}
	init { |i|  song={ i.key }.try ? Song.current;
	filters = Order.new;
	
}
	at{|i|
		song ? song=Song.current; 
		i.isInteger.not.if{i=Song.songs.at(song).section(i.asSymbol)};
		// ^Song.songs.at(song).lyricsToDurs.at(Song.songs.at(song).lyrics[i]) 
		^Song.songs.at(song).lyricsToDurs.at(Song.songs.at(song).lyrics.clipAt(i)) 
			? [1].q

		=> {|x| ( filters.at(i) ? {|j|j} ).(x.list) => _.q } //apply filter
	}
	clipAt { |i|

		song ? song=Song.current; 
		i.isInteger.not.if{i=Song.songs.at(song).section(i.asSymbol)};
		^Song.songs.at(song).lyricsToDurs.at(Song.songs.at(song).lyrics.clipAt(i)) 
			? [1].q

		=> {|x| ( filters.at(i) ? {|j|j} ).(x.list) => _.q } //apply filter
	}
	copySeries {|i j k|
		song ? song=Song.current; 
		i.isInteger.not.if{i=Song.songs.at(song).section(i.asSymbol)};
		^ Song.songs.at(song).lyrics.collect{ |x| Song.songs.at(song).lyricsToDurs[x] ? [1].q }
			.copySeries(i,j,k)
	}

	put{|i j| 
		var curSong;
		//should make a method that picks by number OR symbol
		song.isNil.if{ song=Song.current } ;
		curSong= Song.songs.at(song);


		case
		{i.isInteger}{curSong.lyricsToDurs.put(curSong.lyrics[i],j)}
		{i.class==Symbol}{curSong.lyricsToDurs.put(curSong.lyrics[curSong.section(i)],j)}
	}
	scale {|section amount|
		section =  P.calcStart(section);
		this.put(section, this.at(section).list * amount => _.q)
	}
	scaleEnv {|section env|
		( section.class == Env ).if {env = section; section = nil};
		section =  P.calcStart(section);
		// this.put(section, this.at(section).list.asArray.scaleEnv( env ) => _.q)
		filters.put(section, {|d| d.asArray.scaleEnv( env ) })
	}
	filter { | section function|
		( section.class == Function ).if {function = section; section = nil};
		section =  P.calcStart(section).postln;
		// this.put(section, function.( this.at( section ).list ) => _.q)
		filters.put(section, function)
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








