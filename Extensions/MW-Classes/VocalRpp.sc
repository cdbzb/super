VocalRPP {
    var <>key, <>name, <>range=1, <>tail=5, <>song;
    var section,<>mediaFolder,<>wav,<>prox,<>subproject;
    var <>reaperProjectPath,<>rpp,<>buffer;

    *new { |...args| ^super.newCopyArgs(*args).init}


//      * check tempo changed
//        if so open project - VocalRPP.writeReaperAction - reaper.updateTempo - render - reload buffer
//        else check dirty if so render reload buffer
//          * else (free and?) reload buffer
//
    init { 
        song.isNil.if{song=Song.currentSong};
        section =song.section(key);
        reaperProjectPath = Song.reaperFolder +/+ song.key;
        name.notNil.if{
            key = key ++ "-" ++ name
        };
        mediaFolder = reaperProjectPath +/+ "media";
        File.exists(mediaFolder).not{"mkdir" + mediaFolder => _.unixCmd};
        subproject = mediaFolder +/+ key ++ "-subproject.rpp";
        prox =subproject ++ "-PROX";
        wav=mediaFolder +/+ key ++ "-subproject.wav";
        this.checkDursChanged.if{
		// Does this wk???
	    //this.updateGuide;
            this.updateProxy;
            //this.storeDurs;
        } {
            this.copyPROXtowav;
            buffer=Buffer.read(Server.default,wav);
        };
    }

    copyPROXtowav{
        File.exists(prox).if { 
            File.exists(wav).if{
                ((File.mtime(prox) - File.mtime(wav)).abs > 0 ).if {
                    "cp" + prox + wav => _.unixCmd;
                    "touch" + prox => _.unixCmd;
                    'dirty - copied'.postln;
                } 
            }{

                "cp" + prox + wav => _.unixCmd;
                "touch" + prox => _.unixCmd;
                'clean copied'

                //open project and send a save message to generate a prox ??
            }
        }{
                'no PROX!'.postln;
        }
    }


    updateProxy {
	    var path=reaperProjectPath +/+ "media" +/+ key.asString ++ ".wav";
	    var s = Server.default;
	    this.writeReaperAction;
	    fork{
		    s.prepareForRecord(path);
		    0.1.wait;
		    s.sync;
		    Song.cursor_(section);
		    range.do(
			    { |i|
				    //crude method delete if second method works!
				    var parts = song.at(section + i).select{
					    |part| part.music.cs.contains("RPP").not
				    };
				    // look exactly for this rpp 
				    parts = parts.select{
					    |part|
					    part.resources.rpp == nil // this
				    };
				    //song.play(song.at(section+i));
				    parts.do(_.p)
			    }
		    );
		    s.record(duration: range.collect{|i| Song.secDur[ section + i ]}.sum + tail);
		    (range.collect{|i| song.secDur[ section + i ]}.sum + tail + 0.5).wait;
		    //put name in variable
		    //open the project and subProject and fire reapercommand
          this.open;
          0.1.wait;
          "open" + subproject => _.unixCmd;
          0.1.wait;
          Reaper.updateTempo;
          0.1.wait;
          Reaper.save;
          this.copyPROXtowav;
          0.05.wait;
          buffer=Buffer.read(Server.default,wav);


            this.storeDurs;
      }
    }

    makeRPPs { 
        |durs=#[1,2,3] |
        var guide=reaperProjectPath +/+ "media" +/+ key.asString ++ ".wav";
        var examplesPath = "/Users/michael/tank/super/RPP/";
        // build subproject
        var dummy = examplesPath ++ "example-sub"
        => File.readAllString(_,"r")
        => _.replace("PTS",durs.makePTs)
        => _.replace("ENDMARKER",durs.sum + 5 => _.asString)
        => _.write(reaperProjectPath +/+ "media" +/+ key ++  "-subproject.rpp",overwrite:true); //maybe datestamp
        var sections = [
            "Part1",
            "afterPT-uptoLENGTH",
            "afterLENGTH-uptoFILE",
            "afterFILE-uptosubprojectFILE",
            "tail",
        ].collect({|i| 
            File.readAllString(examplesPath ++ i,"r") 
        });
        var outFile = reaperProjectPath +/+ key++ ".RPP";
        var length = "      LENGTH" +  ( durs.sum + 5 ) ++ "\n";
        var file = "        FILE " ++ guide.quote++"\n";
        //var subproject = "        FILE " ++ "/Users/michael/tank/super/RPP/EXAMPLE/media/02-210914_0752.rpp".quote++"\n";
        var subproject = "        FILE " ++ (reaperProjectPath +/+ "media" +/+ key ++"-" ++ "subproject.rpp").quote++"\n";
        ^(
            sections[0] ++ 
            // durs.makePTs ++
            sections[1] ++
            length ++
            sections[2] ++
            file ++
            sections[3] ++
            subproject ++
            sections[4]
        ).replace("GUIDEOFFSET","SOFFS 0.4") //adjust for server latency 
        .replace("LENGTH 5.00000","LENGTH"+(durs.sum + 5 - 0.4))
        // may not be necessary
        .write(outFile,overwrite:true )
    }

    updateGuide{
	    var path=reaperProjectPath +/+ "media" +/+ key.asString ++ ".wav";
	    var s = Server.default;
	    fork{
		    s.prepareForRecord(path,2);
		    0.1.wait;
		    Monitor.new=>_.play(0,6,0,2);
		    Song.cursor_(section);
		    range.do(
			    { |i|
				    //crude method delete if second method works!
				    var parts = song.at(section + i).select{
					    |part| part.music.cs.contains("RPP").not
				    };
				    // look exactly for this rpp 
				    parts = parts.select{
					    |part|
					    part.resources.rpp == nil // this
				    };
				    parts = parts.reject{
					    |part|
					    part.music.cs.contains("vocodeTune")
				    };
				    //song.play(song.at(section+i));
				    Server.default.sync;
				    parts.do(_.p)
			    }
		    );
		    s.record(duration: range.collect{|i| Song.secDur[ section + i ]}.sum + tail);
		    (range.collect{|i| song.secDur[ i ]}.sum + tail + 0.5).wait;
		    //put name in variable
	    }
    }
build {
    var path;
    var s = Server.default;
    File.exists(reaperProjectPath).not.if(File.mkdir(reaperProjectPath +/+ "media"));
    path=reaperProjectPath +/+ "media" +/+ key.asString ++ ".wav";
    fork{
        s.prepareForRecord(path);
        0.1.wait;
        Song.cursor_(section);
        range.do(
            { |i|
		    //crude method delete if second method works!
                var parts = song.at(section + i).select{
                    |part| part.music.cs.contains("RPP").not
                };
		    // look exactly for this rpp 
		parts = parts.select{
			|part|
			part.resources.rpp == nil // this
		};
                //song.play(song.at(section+i));
		parts.do(_.p)
            }
        );
        s.record(duration: range.collect{|i| Song.secDur[ section + i ]}.sum + tail);
        (range.collect{|i| song.secDur[ i ]}.sum + tail + 0.5).wait;
        //put name in variable
        this.makeRPPs(
            song.durs[section].list, //durs
             //path to reaper dir (redundant!!)
        );
        this.storeDurs;
        //try{ buffer = Buffer.read(Server.default,wav) };
    };

}

writeReaperAction{
	 var string = "durs = {" + Song.durs[section].list.asString.replace("]","").replace("[","").replace("List","") ++ "}\n"
	++ File.readAllString(
		Song.reaperFolder +/+ "updateTempo.lua"
	);
		var file = File("/Users/michael/Library/Application Support/REAPER/Scripts/updateTempo.lua","w");
		file.write(string);
		file.close;

}

storeDurs{
    Song.durs[section].list.writeArchive(
        reaperProjectPath +/+ "media" +/+ key.asString ++ "_durs"
    )
}

checkDursChanged{
    var dursPath = mediaFolder +/+ key.asString ++ "_durs";
    File.exists(dursPath).if{
        ^song.durs[section].list != Object.readArchive( 
            mediaFolder
            +/+ key.asString 
            ++ "_durs"
        )
    } {
        ^false
    }
        
}

open {
    "open" + reaperProjectPath +/+ key ++ "*RPP" => _.unixCmd
}
}
