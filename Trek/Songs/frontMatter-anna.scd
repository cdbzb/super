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

"displayplacer \"id:1A8406AB-8D6E-73E1-E5D9-5BC83BA95E85+62C4AE15-912A-B886-22C4-75EC76BFB94B res:1600x900 hz:60 color_depth:8 enabled:true scaling:off origin:(0,0) degree:0\" \"id:D1CCAD2F-3897-8E7D-A11F-24704BC1F22F res:1280x720 hz:60 color_depth:8 enabled:true scaling:off origin:(1600,0) degree:0\"".unixCmd
Displays.initClass;
Trek.prepare;
Song.cursor_(0);
Stills.scale_(0.82)
{
	Nvim.cmd("wincmd l");
	Nvim.cmd("vertical resize 47")
}.defer(0.5)
Stills.titleFunction_({2})
Trek.playAll
//optional
Stills.clearOnAll_(true)
Stills.activeDisplays_([0,2])
