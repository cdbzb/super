/* 
Trek.allTheSongs[0].load; 
*/
Song.lyrics.do(_.postln);
(
Song.sylables = SongArray.new;
Song.sylables[\reading]=[1, 2, 2, 2, 2];
Song.sylables[\directly]=[2, 1, 1, 2, 2, 3, 2];
Song.sylables['not a signal']=[1, 1, 1, 2, 1];
Song.sylables[\seem]=[1, 1, 1, 1, 1, 2, 2, 1, 1];
Song.sylables[\channels]=[1, 3, 1, 1, 2];
Song.sylables[\Well]=[1];
)

~dursPerWord = 5.collect{|i|
	Song.durs[i].list
		.clumps(Song.sylables[i])
		.collect(_.sum)
}

