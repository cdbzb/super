f=File.readAllString("tempoMap.RPP","r")
f.class
f.find("TEMPOENV")
g=f.split($<)
g.size
g.do({|x i| x.contains("TEMPOENVEX").if{i.postln;x.postln}})
g[7]


(
var tempomap = "PT 0 180 1";
var out="";
var line="";
var next = {out = out ++ line; line = file.getLine};
var file=File.open("tempoMap.RPP","r");
next.();
while ({ line.contains("TEMPOENVEX").not },{next.()});
while ({ line.contains("PT").not },{next.()});
    out = out ++ tempomap;
    while({line.contains("PT")},{line=getLine(file)});
    while({line.notNil},next);
    out.replace("",Char.ret);
out.write("/tmp/reWrite.RPP");
"/tmp/reWrite.RPP".fixLineEndings("reWrite.RPP")
//"tr '\r' '\n' < reWrite.RPP > fix.RPP".unixCmd;
)
//"sed -e s//\\r/ reWrite.RPP".unixCmd; 

//put back together and glue
a=File.readAllString("Part1","r");
b=File.readAllString("afterPT-uptoLENGTH","r");
c=File.readAllString("afterLENGTH-uptoFILE","r");
d=File.readAllString("afterFILE-uptosubprojectFILE","r");
e=File.readAllString("tail","r");

~length = "      LENGTH 5.00000\n";
~file = "        FILE " ++ "/Users/michael/tank/super/RPP/prison.wav".quote++"\n";
~subproject = "        FILE " ++ "/Users/michael/tank/super/RPP/EXAMPLE/media/02-210914_0752.rpp".quote++"\n";
~makePTs = { |durs|
	var point = {|dur index| "    PT" + index + ( 60.0 / dur ) + "1\n"}; // "1" is square shape
	durs.collect(point).inject("",{|i j| i++j});
}
f={|durs| a++ ~makePTs.(durs)++b++~length++c++~file++d++~subproject++e}
g=f.([1,2,3])
g.write("/tmp/test.RPP")
"open /tmp/test.RPP".unixCmd;

// TODO make filenames arguments then make a method!
