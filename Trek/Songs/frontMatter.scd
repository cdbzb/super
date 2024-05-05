//
//
// 
 __   ___ ___       __         ___  __    
|__) |__   |  |  | |__) |\ |    |  /  \   
|  \ |___  |  \__/ |  \ | \|    |  \__/   

___  __         __   __   __   __       
 |  /  \  |\/| /  \ |__) |__) /  \ |  | 
 |  \__/  |  | \__/ |  \ |  \ \__/ |/\| 
//
//
//
Monitors.blackHole
s.queryAllNodes
fork{
	{
		In.ar(0,2)
		=> LeakDC.ar(_)
		// * -4.8.dbamp
		=> ReplaceOut.ar(0, _)
	}.play( target: StageLimiter.activeSynth.nodeID, addAction: \addBefore );
	Trek.prepare
}
Trek.recordOBS
s.pkill



