Pipe.new("open -a 'REAPER64.app' /Users/michael/tank/THE\\ FUTURE/VIDEO-ONLY.RPP","w" );
(
	s.waitForBoot({
			~out=Bus.audio(s,6);
			m=Monitor.new;
			m.play(~out.index,2,0,2,multi:true);
			m.play(~out.index+4,2,0,2, multi:true);
			"/Users/michael/tank/super/Gotland/BOUNCE/membrane.scd".load;
			"/Users/michael/tank/super/Gotland/BOUNCE/klank.scd".load;
			"/Users/michael/tank/super/Gotland/BOUNCE/chordwave.scd".load;
		})
)

//load sequence
~waves;

History.start;
~locate.(3600);m.play;
~locate.(3858);
~startFrom.(3858);
History.started;

~membrane.play(fadeTime:240); // set los and tensionn + lags and fadeTime
~membrane.[1]=\filter->{|in|HPF.ar(in,300)}; //for monitoring - do this in REAPER
~membrane.set(\los,0.99999);
~chordWave.(vol:0.0050);
a=~chordWave.(vol:0.0030);
~membrane.[1]=nil;

~lf.source=nil;
~membrane.stop(fadeTime:160); // set los and tensionn + lags and fadeTime
~chordWave.(tempo:1);
t.tempo=0.5;
t.tempo=3;
~chordWave.(tempo:0.8);
~klankRoutine.reset;
~klankRoutine.play;
~ambience.play(fadeTime:1);
~lf.gate_(1);

~lf.gate_(0);
~lf;
~lf.set(\gate,1);
~startup.();
~lf.dur_(200)
~lf.gate_(-20);
~ambience.play(vol:0.8);
~ambience.set.(\vol,0.4);
( //little gesture
	~membrane.fadeTime_(125);
	~membrane.lag(\tensionn,190); //too fast?
	{
		~membrane.set(\tensionn, 0.0074);
		20.wait;
		~membrane.xset(\tensionn, 0.00800);
	}.fork
)

~out.scope;
