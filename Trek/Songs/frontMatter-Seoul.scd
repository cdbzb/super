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
Monitors.foldDown.do(_.value)
Trek.prepare
(
// var post = 47 * 1.5;
// var stillScale = 0.87;
var post = 45 * 1.5 -5;
var stillScale = 0.915;
{
	Nvim.cmd("wincmd l");
	Nvim.cmd("vertical resize" + (post));
	Nvim.cmd("wincmd h");
}.defer(0.5);

fork{
	Stills.scale_(stillScale);
	OBS.record; 
	2.wait;
	Trek.playRange(13, 0); Trek.editFile(13); 49.wait; 
	Trek.playRange(16, 0, 2);
	0.5.wait;
	Trek.editFile(16);
	1.wait;
	Song.durTillEnd + 5  =>_.wait;
	OBS.stop
}
)





