(
	~out=Bus.audio(s,6);
	m=Monitor.new;
	m.play(~out.index,2,0,2,multi:true);
	m.play(~out.index+4,2,0,2, multi:true);
	"/Users/michael/tank/super/Gotland/BOUNCE/klank.scd".load 
	"/Users/michael/tank/super/Gotland/BOUNCE/membrane.scd".load 
	"/Users/michael/tank/super/Gotland/BOUNCE/chordwave.scd".load 
)


History.start;

~membrane.play(fadeTime:30); // set los and tensionn + lags and fadeTime
~membrane.stop(fadeTime:60); // set los and tensionn + lags and fadeTime
~chordWave.(tempo:1);
~klankRoutine.reset;
~klankRoutine.play;

( //little gesture
	~membrane.fadeTime_(25);
	~membrane.lag(\tensionn,40); //too fast
	{
		~membrane.set(\tensionn, 0.0076);
		20.wait;
		~membrane.xset(\tensionn, 0.00800);
	}.fork
)

~out.scope;
