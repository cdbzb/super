+ String {
	pbcopy { 
		Pipe.new("echo " ++ this ++ "pbcopy","w")
	}

	asBeats { 
		var dict= [$h,2,$q,1,$x,1/4,$e,1/2,$h,2,$w,4,$H,4/3,$Q,2/3,$E,1/3,$X,1/6]
		.collect({
			|i|(i.class==Char).if{
				i.ascii
			}{
				i
			}
		}) => Dictionary.newFrom(_);
		^this.split(Char.space).ascii
		.deepCollect(2, {|i| dict.at(i) ? 0})
		.collect(_.sum)
	}
	fileName {
		^try{this.asPathName.fileName}
	}
        fixLineEndings { |out|
          "tr '\r' '\n' <" + this ++ ">" + out => _.unixCmd;
        }
        df { | ...args |
          ^this.split(Char.space)
		.reject({|i| i.size == 0})
		.collect(_.asFloat)
		.df(*args)
        }
        dm { | ...args |
          ^this.split(Char.space)
		.reject({|i| i.size == 0})
		.collect(_.asFloat)
		.dm(*args)
        }
}
