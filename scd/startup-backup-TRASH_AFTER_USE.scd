var files="/Users/michael/tank/super/Library/functions/*".pathMatch;
files=files++"/Users/michael/tank/super/Library/synthdefs/*".pathMatch;
files=files++"/Users/michael/tank/super/SynthDefLibrary/*".pathMatch;
files.do({|file| file.load; file.postln});
Library.postTree;
//( ServerOptions.outDevices ==  [ "Built-in Output" ] ).if{
//	~quad= Monitor.new.play(2,2,0,2,target:RootNode(s));
	//	CmdPeriod.add({ ~quad=Monitor.new.play(2,2,0,2);\monitor.postln });
s.options.memSize=32768*4;
s.options.numWireBufs=256;
thisProcess.platform.recordingsDir_("~/tank/SC_Recordings".standardizePath)
//StageLimiter.activate;
