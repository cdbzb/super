// wslib 2011
// quick way of monitoring all incoming osc messages
// exclude can be an array of Symbols with extra messages to exclude (i.e. not post)


MonitorOSC {
	
	classvar <>exclude;
	
	*value { |time = 0, addr, port, msg = ([])|
		if( port.size != 0 ) { msg = port };
		if( ([ '/status.reply', '/localhostOutLevels', '/localhostInLevels' ] 
				++ exclude.asCollection ).includes( msg[0] ).not ) {
			[ time.asSMPTEString, addr, msg ].postln;
		};
	}
	
	*valueArray { arg args; ^this.value(*args) }
}

+ Main {
	monitorOSC { |bool = true, exclude|
		if( bool == true ) {
			MonitorOSC.exclude = exclude;
			recvOSCfunc = recvOSCfunc.removeFunc( MonitorOSC ).addFunc( MonitorOSC );
		} {
			recvOSCfunc = recvOSCfunc.removeFunc( MonitorOSC );
		};
	}
}
