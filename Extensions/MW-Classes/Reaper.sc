Reaper {
	classvar executable="'/Applications/REAPER ƒ/REAPER64.app/Contents/MacOS/REAPER'";
	classvar <>ip="192.168.1.185",<>port=8000;
	classvar <clock,cursor;
	*initClass {
		clock=TempoClock.new().permanent_(true);
		CmdPeriod.add({Reaper.stop})
	}
	*address {^NetAddr(ip,port)}
	*open { Pipe.new(executable,"w") }
	*go		{| seconds| this.address.sendMsg('time',seconds.asFloat.asSeconds); cursor=seconds}
	*play	{| seconds| 
		seconds.isNil.not.if{
			this.go(seconds);
			cursor=seconds; 
		};
		this.address.sendMsg('/play'); 
		clock.beats_(cursor)}
	*sched { |time, function| clock.schedAbs(time,function) }
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
Reaper.play
100.0.asSeconds
100.0.asSeconds
"1:38".asSMPTE
SMPTE.array([0,1,1,3]).asSeconds
101.4 / 100 => _.floor * 60 
101.9.asSeconds

*/
