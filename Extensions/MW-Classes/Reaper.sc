Reaper {
	classvar executable="'/Applications/REAPER ƒ/REAPER64.app/Contents/MacOS/REAPER'";
	classvar <>ip="192.168.1.234",<>port=8000;
	classvar <clock,cursor,<>lastPlayLength;
	*initClass {
		clock=TempoClock.new().permanent_(true);
		CmdPeriod.add({Reaper.stop})
	}
	*address {^NetAddr(ip,port)}
	*open { Pipe.new(executable,"w") }
	*open2 {|path|
		Pipe.new(executable ++ " " ++ path,"w")
	}
        *openAndSaveas {|path|
		Pipe.new(executable + path ++ " -saveas " ++ path ,"w")
        }
	*go		{| seconds| this.address.sendMsg('time',seconds.asFloat.asSeconds); cursor=seconds.asFloat.asSeconds}
	*record {| seconds, stopAt | 
		seconds.isNil.not.if{
			this.go(seconds);
		};
		this.address.sendMsg('/play'); 
		clock.beats_(cursor);
		stopAt.notNil.if {
			this.sched(stopAt,{this.stop});
			lastPlayLength=stopAt-seconds
		}
	}
        
	*play	{| seconds, stopAt | 
		seconds.isNil.not.if{
			this.go(seconds);
		};
		this.address.sendMsg('/play'); 
		clock.beats_(cursor);
		stopAt.notNil.if {
			this.sched(stopAt,{this.stop});
			lastPlayLength=stopAt-seconds
		}
	}
	*sched { |time, function| ( time.asFloat.asSeconds>cursor ).if {
		clock.schedAbs(time.asFloat.asSeconds,function
		)} 
	}
	*new	{Pipe.new(executable ++ " -new" , "w");
}
	*saveas	{|filename| 
		Pipe.new(executable++ " -saveas " ++File.getcwd.asString++"/"++filename, "w")
	}
	*stop	{this.address.sendMsg('/stop')}

        *buildVocalRPP { |guide durs=#[1,2,3] path="/tmp" name="test3.RPP" |
          
          var examplesPath = "/Users/michael/tank/super/RPP/";
          // build subproject
          var subprojectOutPath = "mkdir" + path +/+ "media" => _.unixCmd;
          var sink = examplesPath ++ "example-sub"
            => File.readAllString(_,"r")
            => _.replace("PTS",durs.makePTs)
            => _.replace("ENDMARKER",durs.sum + 5 => _.asString)
            => _.write(path +/+ "media" +/+ name ++  "-" ++ "subproject.rpp",overwrite:true); //maybe datestamp
          var sections = [
            "Part1",
            "afterPT-uptoLENGTH",
            "afterLENGTH-uptoFILE",
            "afterFILE-uptosubprojectFILE",
            "tail",
          ].collect({|i| 
            File.readAllString(examplesPath ++ i,"r") 
          });
          var outFile = path +/+ name;
          var length = "      LENGTH" +  ( durs.sum + 5 ) ++ "\n";
          var file = "        FILE " ++ guide.quote++"\n";
          //var subproject = "        FILE " ++ "/Users/michael/tank/super/RPP/EXAMPLE/media/02-210914_0752.rpp".quote++"\n";
          var subproject = "        FILE " ++ (path +/+ "media" +/+ name++"-" ++ "subproject.rpp").quote++"\n";
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
}
+Float {
	asSeconds{ |float|
		^ this / 100 => _.floor * 60 + (this % 100)
	}
}
+SequenceableCollection{
  makePTs {
    var indices = [0] ++ this.collect{|i x| this[..x].sum};
    var point = {|dur index| "    PT" + indices[index] + ( 60.0 / dur ) + "1\n"}; // "1" is square shape
	^this.collect(point).inject("",{|i j| i++j});
  }
}
/*
Reaper.new
Reaper.go(101.0)
Reaper.play(155,205)
Reaper.play(155,205);Reaper.clock.beats
100.0.asSeconds
100.0.asSeconds
"1:38".asSMPTE
SMPTE.array([0,1,1,3]).asSeconds
101.4 / 100 => _.floor * 60 
101.9.asSeconds
a=TempoClock.new
a.beats.postln;a.seconds
a.seconds_(0)

Reaper.clock.beats_(1)
Reaper.clock.seconds
TempoClock
*/
