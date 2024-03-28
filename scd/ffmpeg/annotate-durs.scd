/* 
Trek.allTheSongs[0].load; 
Song.recordSection(0,12,0,"/tmp/recording.wav")
*/
Song.lyrics.do(_.postln);
(
var words;
Song.sylables = SongArray.new;
Song.sylables[\reading]=[1, 2, 2, 2, 2];
Song.sylables[\directly]=[2, 1, 1, 2, 2, 3, 2];
Song.sylables['not a signal']=[1, 1, 1, 3];
Song.sylables[\seem]=[1, 1, 1, 1, 1, 2, 2, 1, 1];
Song.sylables[\channels]=[1, 3, 1, 1, 2];
Song.sylables[\Well]=[1];
Song.sylables[\attempting]=[2, 1, 2, 1, 3, 1, 2, 1, 3];
Song.sylables[\succeeded]=[2, 1, 2, 1, 3, 1 ]; //dis spanning!
Song.sylables[\tress]=[3, 1, 8, ];
Song.sylables[\activated]=[4, 1, 2, 2, 1, 3, 1, ];
Song.sylables[\follow]=[2, 1, 1, 1, 2, 1 ];
Song.sylables['I do not']=[1, 1, 1, 1, 1, 2, 1, 2, 1, 1, 1, 2];

/*
 Song.lyrics[Song.section('I do not')]
*/

words = Song.sylables.collect{|i| i}.flat.size;
~dursPerWord = Song.sylables.size.collect{|i|
	Song.durs[i].list
		.clumps(Song.sylables[i])
		.collect(_.sum)
};
~boundaries = FFMPEG.boundariesW[..words];
~rates = ~dursPerWord.flat/~boundaries.differentiate.drop(1);
FFMPEG.warpSegments(~boundaries, ~rates).unixCmd

)
~rates.do(_.postln)
FFMPEG.words.clump(8)[0..5].do(_.postln)
