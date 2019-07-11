(
var executable="'/Applications/REAPER ƒ/REAPER64.app/Contents/MacOS/REAPER'";
		
~rpr=(
address: NetAddr("192.168.1.132",8000),
opn:    { Pipe.new(executable,"w") },
go:		{|self seconds| self.address.sendMsg('time',seconds)},
ply:	{|self seconds| seconds.isNil.not.if{self.go(seconds)};self.address.sendMsg('/play')},
new:	{Pipe.new(executable ++ " -new" , "w")},
saveas: {|self filename| 
			Pipe.new(executable++ " -saveas " ++File.getcwd.asString++"/"++filename, "w")},
stp:	{|self| self.address.sendMsg('/stop')},
h:		(postln('address,go,ply,stp,new,saveas'));
);
CmdPeriod.add({~rpr.stp});
)

//MIDIClient.init;
//MIDIIn.connectAll;
//MIDIFunc.noteOn({SinOsc.ar(400,0,0.1*EnvGen.kr(Env.perc))});
//MIDIFunc.noteOff({'off'.postln});

//(
//MIDIClient.init;
//MIDIIn.connectAll;
//m = MIDIFunc.noteOn({ |vel, num|
//    "note % @ velocity %\n".postf(num, vel);
//});
//)

// when finished

