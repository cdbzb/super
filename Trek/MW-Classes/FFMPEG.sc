FFMPEG {
	classvar 
	defaultFile, csvFile, <>csv, <words, lineIndices, <timecode
	;

	*initClass {
		Class.initClassTree(Trek);
		defaultFile = Trek.path.dirname +/+  "Stills/Warping/2023-07-03 01-37-42.mp4.csv";
		csvFile = Trek.path.dirname +/+  "Stills/Warping/2023-07-03 01-37-42.mp4.csv";
		csv = CSVFileReader.read(Trek.path.dirname +/+ "Stills/Warping/2023-07-03 01-37-42.mp4.csv");
		// csv = csv.deepCollect(2, (_.replace(Char.comma, "")));
		csv = csv.collect{|i| i.reject{|x| x.size==1 and: x[0]==$" }};
		words = csv.slice(nil, 0).drop(1).collect( _.replace($\",""));
		timecode = csv.slice(nil, 1).drop(1);
		lineIndices = ()
	}

	*warpLinesCmd { |sections|
		^this.warpSegments( this.boundaries[..sections], this.rates[..sections] )
	}

	*durs{  /// in seconds for each line
		^this.boundaries.differentiate.drop(1);
	}

	*boundaries{ //in seconds for each line
		^timecode[this.lineIndices]
		.collect({|i| i.split($:)
		.collect(_.asInteger)})
		.collect{|i| SMPTE.array(i, 60).asSeconds} //note framerate=60!!
	}
	*boundariesW{ //in seconds for each word
		^timecode
		.collect({|i| i.split($:)
		.collect(_.asInteger)})
		.collect{|i| SMPTE.array(i, 60).asSeconds} //note framerate=60!!
	}

	*rates{ ///rates for each line
		^Song.lyrics.collect{|i x| try{ Song.secDur[x] / this.durs[x] }}
	}


	*lineIndices { //index in words array for each line start
		var indexOfMatch = {| lineNumber |
			var line = Song.lyrics[lineNumber].split(Char.space)
			.reject({|i| i.size == 0});
			// if line is super short append next to get better match
			(( line.size < 2 ) and: (lineNumber + 2 < Song.lyrics.size)).if{
				line = line ++ Song.lyrics[lineNumber + 1].split(Char.space)
			};
			words.collect{|i x| words[x..(x + line.size - 1)].editDistance(line, {|a b| a.contains(b)}) }.minIndex + 1
		};
		lineIndices.at(Song.current).isNil.if{
			'calculating line indices...'.postln;
			lineIndices.put(Song.current, Song.lyrics.size.collect(indexOfMatch.(_)))
		};
		^lineIndices.at(Song.current)
	}

	//// this generates an ffmpeg command that will warp 
	//// based on supplied boundaries in seconds and rates
	//// audioFile is added in
	*warpSegments {  |boundaries = #[3, 3, 3] rates=#[1, 2, 3] videoFile audioFile|
	var num;
	var seg = { |segment=#[20,40] rate=0.5 number=0 |
	
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
	// var boundaries = [0] ++ durs.integrate;
	num = boundaries.size - 1; //number of regions

	^ "ffmpeg -i" + (videoFile ? defaultFile)
	+ "-i /tmp/recording.wav "
	"-y "
	"-filter_complex "
	"\""

	+ num.collect{|i| 
		seg.(boundaries[i..(i+1)], rates[i], i)
	}.reduce( '++' )

	+ num.collect{|i| "[v"++i++"]"}.reduce('++')

	++ "concat=n="++num++":v=1[new]\" "

	+ " -map \"[new]\" -map 1:a"
	+ ( audioFile ? "/tmp/output.mp4 " )

 }
 }
