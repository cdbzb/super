(
	SynthDef(\cloud, { arg fr=100, amp=1; var out;  
		fr = Lag.kr(fr,60);
		Out.ar(0,{
			Mix.arFill(20, //number of harmonics
			    { arg x  ; var sig, frq;
				frq=fr;
				sig = SinOsc.ar( x+1*frq ,0,0.01 * LFNoise1.kr(18*LFNoise1.kr));
				sig = Pan2.ar(sig, LFNoise1.kr(1));
				sig= sig * EnvGen.kr(Env.linen(5,60,10),doneAction: 2);
				sig*amp;
			})
		})}).add;
	{
Pipe.new("open -a 'QuickTime Player.app' /Users/michael/tank/THE\\ FUTURE\\ local/TheFuture_Vimeo_20181025-fast1080.mp4","w" );

0.3.wait;

Pipe.new( "osascript ~/scripts/play-front-qt-movie.scpt","w");

4.wait;

//{PinkNoise.ar(0.1) }.play

}.fork;
)
(

{
a=(\instrument: \cloud, \fr: 90).play;
6.wait;
// a.set(\fr, 110); //PORTAMENTO
(\instrument: \cloud, \fr: [100,120,130]).play;
9.wait;
(\instrument: \cloud, \fr: [300,360], \amp: 0.1).play;
6.wait;
(\instrument: \cloud, \fr: [200,240], \amp: 0.01).play;
}.fork
)

(
	{
		b=Buffer.read(s,"/Users/michael/tank/THE FUTURE local/Ocean/243591__sonic-ranger__ocean-waves-sea-tide-hayburn-wyke-22-july-14.wav");

		s.sync;
		c={PlayBuf.ar(b.numChannels,b)*0.03}.play;
	}.fork

)
c.free;


