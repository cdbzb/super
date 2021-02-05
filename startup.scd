(
var files="/Users/michael/tank/super/Library/functions/*".pathMatch;
( ServerOptions.outDevices ==  [ "Built-in Output" ] ).if{
	~quad= Monitor.new.play(2,2,0,2,target:RootNode(s));
	//	CmdPeriod.add({ ~quad=Monitor.new.play(2,2,0,2);\monitor.postln });
};
files=files++"/Users/michael/tank/super/Library/synthdefs/*".pathMatch;
files.do({|file| file.load; file.postln});
Library.postTree;
StageLimiter.activate;
)
