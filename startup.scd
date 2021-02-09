(
var files="/Users/michael/tank/super/Library/functions/*".pathMatch;
var s=Server.local;
( ServerOptions.outDevices ==  [ "Built-in Output" ] ).if{
	~quad= Monitor.new.play(2,2,0,2,target:RootNode(s));
	//	CmdPeriod.add({ ~quad=Monitor.new.play(2,2,0,2);\monitor.postln });
};
files=files++"/Users/michael/tank/super/Library/synthdefs/*".pathMatch;
files.do({|file| file.load; file.postln});
Library.postTree;
s.options.memSize=32768;
s.options.numWireBufs=256;
s.options.numOutputBusChannels=5;
//2**14
//startup
StageLimiter.activate;
)
