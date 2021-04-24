+String{ 
	version {  
		// make -bak directory if needed and put time-stamped copy of file in
		var path=this.standardizePath;
		var backupDir = path ++ "-bak";
		File.exists(backupDir).not.if{File.mkdir(backupDir)};
		path ++"-bak"
		+/+ path.basename.splitext[0]
		++ Date.getDate.stamp ++ "." ++ path.extension 
		=> File.copy(path,_)
		=> _.postln
	}
	unversion {
		// version current file and replace with previous version
		var old = this++"-bak/*"=>_.pathMatch=>_.sort=>_.reverse=>_[0];
		this.version;
		"mv" + old + this => _.unixCmd;
	}
	record { | bus=0, numChannels=1, length=5 |
		//TODO other formats
		var g = Group.after(1);
		var b = Buffer.alloc(Server.default, 65536, 2);
		var d;
		b.write(this.standardizePath, "wav", "int24", 0, 0, true);
		// create the diskout node; making sure it comes after the source
		d = Synth.tail(g, "diskout"++numChannels.asString, [\bufnum, b]);
		fork{ 
			length.wait ;
			"stopping " + this => _.postln;
			d.free; 
			b.close;
			b.free;
		}

	}
	default {
		^Platform.recordingsDir +/+ this
	}
	
}
/*
{Saw.ar(486,0.1!2)}.play;
"kookoo.wav".default.record;
"~/tank/super/recordTest.wav".version.record(bus:0,numChannels:2,length:5)
"~/tank/super/recordTest.wav".unversion
.record(bus:0,numChannels:2,length:5)
*/
