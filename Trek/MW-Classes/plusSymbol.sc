+ Symbol {
	contains { |what|
		^this.asString.contains(what)
	}
	pasteDef {
		var a = SynthDescLib.at(this).def.func.cs;
		fork{
			a.splitLines.collect{|i| 
				i.replace("\\", "\\\\")
				.replace("\n"," ")
				.replace(Char.tab,"    ")
			}.do{|i| 
					Nvim.cmd("exe \"normal o\"");
					Nvim.replace(i);
			}
		}
	}

}
