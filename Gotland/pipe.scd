(
	{
Pipe.new("open -a 'QuickTime Player.app' /Users/michael/tank/THE\\ FUTURE\\ local/TheFuture_Vimeo_20181025-fast1080.mp4","w" );

0.3.wait;

Pipe.new( "osascript ~/scripts/play-front-qt-movie.scpt","w");

4.wait;

{PinkNoise.ar(0.1) }.play

}.fork;

)

