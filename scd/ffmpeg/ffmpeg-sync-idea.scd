( //example
"ffmpeg -i ~/tank/super/Trek/Stills/new.mp4 "
"-i ~/Music/SuperCollider\\ Recordings/someMuzik.mp3 "
"-filter_complex "
"\""
"[0:v]trim=20:20[v0]; "
"[0:v]trim=20:40,setpts=(PTS-STARTPTS)*5[v1]; "
"[0:v]trim=40:60,setpts=PTS-STARTPTS[v2]; "
"[v0][v1][v2]concat=n=3:v=1[new]\" "
" -map \"[new]\" -map 1:a /tmp/outputPlusAudio.mp4 "
=> _.unixCmd
)

// ffmpeg -i video.mp4 -i audio.m4a -map 0:v -map 1:a output.mp4

( // ~segments calls ffmpeg
~seg = { |segment=#[20,40] rate=0.5 number=0 |
    rate = rate.asString;
	( rate[0]==0 ).if{ rate=rate.drop(1) };

	"[0:v]trim="
	++segment[0]++":"++segment[1]
	// "20:40"
	++",setpts=(PTS-STARTPTS)*"
	++rate
	// ".5"
	++"[v" ++ number ++ "]; ";
};
~segments = { |boundaries = #[3, 3, 3] rates=#[1, 2, 3]|
	// var boundaries = [0] ++ durs.integrate;
	var num = boundaries.size - 1; //number of regions

	"ffmpeg -i ~/tank/super/Trek/Stills/2023-07-03_01-37-42.mp4 "
	"-i /tmp/recording.wav "
	"-y "
	"-filter_complex "
	"\""

	+ num.collect{|i| 
		~seg.(boundaries[i..(i+1)], rates[i], i)
	}.reduce( '++' )

	+ num.collect{|i| "[v"++i++"]"}.reduce('++')

	++ "concat=n="++num++":v=1[new]\" "

	+ " -map \"[new]\" -map 1:a /tmp/output.mp4 "
	
};
)

( // load timecode for words
Trek.allTheSongs[0].load;
~csv = CSVFileReader.read("~/tank/super/Trek/Stills/Warping/2023-07-03 01-37-42.mp4.csv".standardizePath)
.collect{|i|
	i.reject{|i|
		i=="\""
	}
}
;
~words = ~csv.slice(nil, 0).drop(1).collect( _.replace($\",""))
;
~indexOfMatch = {| lineNumber |
	var line = Song.lyrics[lineNumber].split(Char.space)
	.reject({|i| i.size == 0});
	// if line is super short append next to get better match
	(( line.size < 2 ) and: (lineNumber + 2 <Song.lyrics.size)).if{
		line = line ++ Song.lyrics[lineNumber + 1].split(Char.space)
	}; 
	~words.collect{|i x| ~words[x..(x+line.size)].editDistance(line, {|a b| a.contains(b)}) }.minIndex + 1
 };
~lineIndices = Song.lyrics.size.collect( ~indexOfMatch.(_) );
~timecode = ~csv.slice(nil, 1).drop(1);
 )

( //renders out a section of lyrics

~segments.(t[1..2].postln, [ 1]) .unixCmd
)
( // calculate rates
~durs = ~timecode[~lineIndices]
	.collect({ |i| 
		i.split($:).collect(_.asInteger)
	}).collect{|i| SMPTE.array(i, 60).asSeconds}
	.differentiate.drop(1);
~rates = Song.lyrics.collect{|i x| try{ Song.secDur[x]/~durs[x] }}
)

(
fork{
	//render audio
	Song.currentSong.recordSection(0, 15, path:"/tmp/recording.wav"); // add this to ~segments ?
	Song.secDur[..15].sum + 1 => _.wait;
	//calculate segment boundaries
	t=~timecode[~lineIndices]
	.collect({ |i|
		i.split($:).collect(_.asInteger)
	}).collect({ |i| SMPTE.array(i, 60).asSeconds });
	//ffmpeg command
	~segments.(t[..15], ~rates[..15].round(0.01)) .unixCmd
}
)
~durs
~lineIndices[8]
~timecode[0].asSeconds
Song.lyrics[5]

