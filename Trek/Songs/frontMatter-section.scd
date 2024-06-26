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
Trek.prepare
(
fork{
	Stills.scale_(0.75);
	Trek.playRange(16, 0);
	5.wait;
	OBS.record; 
	0.5.wait;
	Trek.editFile(16);
	// 1.wait;
	Song.durTillEnd + 7  =>_.wait;
	OBS.stop
}
)
s.pkill




