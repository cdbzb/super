FFMPEG {
	classvar defaultFile= "~/tank/super/Trek/Stills/2023-07-03_01-37-42.mp4",
	csvFile = "~/tank/super/Trek/Stills/Warping/2023-07-03 01-37-42.mp4.csv",
	<>csv, <words, lineIndices, timecode
	;

	*initClass {
		csv = CSVFileReader.read("~/tank/super/Trek/Stills/Warping/2023-07-03 01-37-42.mp4.csv".standardizePath);
		words = csv.slice(nil, 0).drop(1).collect( _.replace($\",""));
		timecode = csv.slice(nil, 1).drop(1);
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

	*rates{ ///rates for each line
		^Song.lyrics.collect{|i x| try{ Song.secDur[x] / this.durs[x] }}
	}


	*lineIndices { //index in words array for each line start
		var indexOfMatch = {| lineNumber |
			var line = Song.lyrics[lineNumber].split(Char.space)
			.reject({|i| i.size == 0});
			// if line is super short append next to get better match
			(( line.size < 2 ) and: (lineNumber + 2 <Song.lyrics.size)).if{
				line = line ++ Song.lyrics[lineNumber + 1].split(Char.space)
			};
			words.collect{|i x| words[x..(x + line.size)].editDistance(line, {|a b| a.contains(b)}) }.minIndex + 1
		};
		lineIndices.isNil.if{
			'calculating line indices...'.postln;
			lineIndices = Song.lyrics.size.collect(indexOfMatch.(_))
		};
		^lineIndices
	}

	*warpSegments {  |boundaries = #[3, 3, 3] rates=#[1, 2, 3] videoFile audioFile|
	//// this generates an ffmpeg command that will warp 
	//// based on supplied boundaries in seconds and rates
	//// audioFile is added in
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
