Reaper {
	classvar executable="'/Applications/REAPER ƒ/REAPER64.app/Contents/MacOS/REAPER'";
	*address {^NetAddr("192.168.1.136",8000)}
	*open { Pipe.new(executable,"w") }
	*go		{| seconds| this.address.sendMsg('time',seconds)}
	*play	{| seconds| seconds.isNil.not.if{this.go(seconds)};this.address.sendMsg('/play')}
	*new	{Pipe.new(executable ++ " -new" , "w");
	CmdPeriod.add({Reaper.stop})
}
	*saveas	{|filename| 
		Pipe.new(executable++ " -saveas " ++File.getcwd.asString++"/"++filename, "w")
	}
	*stop	{this.address.sendMsg('/stop')}
	*h		{^'address,go,play,stop,new,saveas'}
	*help   {this.h}
}
