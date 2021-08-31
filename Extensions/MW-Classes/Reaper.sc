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
	*h		{^'address,go,play,stop,new,saveas'}
	*help   {this.h}
}
+Float {
	asSeconds{ |float|
		^ this / 100 => _.floor * 60 + (this % 100)
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
