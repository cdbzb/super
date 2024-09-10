
(
a= "ls" + SynthV.directory +/+ "silverlake"  => _.unixCmdGetStdOutLines;
a.select{|i|
	i.asInteger == 0
}.do{|name|
	"mv" 
	+ SynthV.directory +/+ "silverlake" +/+ name
	+ SynthV.directory +/+ "silverlake" +/+ Song.lyrics[Song.section( name.replace("_"," ") )].hash.abs.asString
	=> _.unixCmd
	=> _.postln
}
)
