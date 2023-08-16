Reaper {
	classvar <>executable="'/Applications/REAPER ƒ/REAPER64.app/Contents/MacOS/REAPER'";
	//classvar <>ip="192.168.1.213",<>port=8000;
	classvar <>ip="127.0.0.1",<>port=8000;
	classvar <clock,<cursor=0,<>lastPlayLength;
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
	*go {| seconds| this.address.sendMsg('time',seconds.asFloat.asSeconds); cursor=seconds.asFloat.asSeconds}
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
	*action{ |actionID|
		this.address.sendMsg('action', actionID )
	}
	*updateTempo {
		this.address.sendMsg('action','_RSdbf0557c9d37b721397192124cb1b286f3c3bab4')
	}
        
	*play {| seconds, stopAt | 
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
	*save { this.address.sendMsg('action',40026) }
	*saveAndRenderPROX { this.address.sendMsg('action',42332 ) }
	*render{ this.address.sendMsg('action',41824) }
	*selectAllItems{ this.address.sendMsg('action',40182) }
	*setItemTimeBaseToAuto{ this.address.sendMsg('action','_SWS_AWITEMTBASEBEATSTRETCH') }
	

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
