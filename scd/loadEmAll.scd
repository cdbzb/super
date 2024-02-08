(
// s.options.numBuffers
~loop = Routine{
	Trek.allTheSongs.do{|song|
		SynthV.buffers_(MultiLevelIdentityDictionary.new());
		Buffer.freeAll(s);
		song.load;
		// s.newBufferAllocators;
		// song.postln.yield
		song.postln; 1.wait;
	}
};
~loop.play;
)
~loop.next
Buffer.new
Trek.allTheSongs[9]
Song.songs.size
Trek.allTheSongs[6]
~keys = ~dict.keys.select{|i| i.class == Symbol}
~keys.collect(~dict.at(_)).sum/60=>_.round(1)
~dict.at("/Users/michael/tank/super/Trek/Songs/23-Ending.scd")
~dict.keys.select{|i| i.isString}.collect{|i| ~dict.at(i)}
