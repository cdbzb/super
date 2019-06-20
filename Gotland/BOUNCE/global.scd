Pipe.new("open -a 'REAPER64.app' /Users/michael/tank/THE\\ FUTURE/VIDEO-ONLY.RPP","w" );
~path="/Users/michael/tank/super/Gotland/";
(
	s.waitForBoot({
			~out=Bus.audio(s,10);
			m=Monitor.new;
			m.play(~out.index,2,0,2,multi:true);
			m.play(~out.index+4,2,0,2, multi:true);
			m.play(~out.index+6,2,0,2, multi:true);
			m.play(~out.index+8,2,0,2, multi:true);
			2.wait;
			"/Users/michael/tank/super/Gotland/BOUNCE/membrane.scd".load;
			"/Users/michael/tank/super/Gotland/BOUNCE/klank.scd".load;
			"/Users/michael/tank/super/Gotland/BOUNCE/chordwave.scd".load;
			"/Users/michael/tank/super/Gotland/BOUNCE/wave-membrane.scd".load;
			"/Users/michael/tank/super/Gotland/BOUNCE/window.scd".load;
			"/Users/michael/tank/super/Gotland/BOUNCE/sequence.scd".load;
		})
)
~membrane.stop;

(
	{
		s.prepareForRecord("/Users/michael/tank/THE FUTURE/SC-bounces/membrane9999-008-with-xdrop-10-mins");
		s.sync;
		s.record(duration:600);
		~membrane.play(0,fadeTime:300);
		200.wait;
		~membrane.xset(\tensionn, 0.0074);
		60.wait;
		200.wait;
		~membrane.set(\tensionn,0.008)
	}.fork
	



)
~membrane.stop;
~membrane.play;
~out.scope;
History.started;
History.end;
History.clear;
History.lines[9];
History.play;
History.saveCS("/tmp/test-hist");

History.start;
History.loadCS("/Users/michael/Library/Application Support/SuperCollider/HistoryLogs/log_History_190610_183404.scd.cs");
History.saveStory(~path++"story.scd")
~playStory={|story| History.loadStory(~path++story++".scd";History.play)};
~playStory.("story");


History.loadCS("/tmp/test-hist");
History.lines;
s.prepareForRecord("/tmp/8-chan-from-hist.aif", 10);
~ambience.play(vol:0.8);
~chordWave.(~chord,vol 0.005);
~chordWave.(~chord.scramble);
~locate.(3600);
~startFrom.(3858);
~chordWave.(vol:0.0050);
a=~chordWave.(vol:0.0030);
~tighten.(100);
Synth


~membrane.play(fadeTime:240); // set los and tensionn + lags and fadeTime
~membrane.[1]=\filter->{|in|HPF.ar(in,300)}; //for monitoring - do this in REAPER
~membrane.set(\los,0.9999);
~membrane.[1]=nil;

~membrane.stop(fadeTime:160); // set los and tensionn + lags and fadeTime
~chordWave.(tempo:1);
t.tempo=0.5;
t.tempo=3;
~chordWave.(tempo:0.8);
~klankRoutine.reset;
~klankRoutine.play;
~klankRoutine.stop;
~klank.play;
~ambience.play(fadeTime:1);
~lf.gate_(1);

~lf.gate_(0);
~lf;
~lf.set(\gate,1);
~startup.();
~lf.dur_(200)
~lf.gate_(-20);
( //little gesture
	~gesture={
		~membrane.fadeTime_(125);
		~membrane.lag(\tensionn,90); //too fast?
		{
			~membrane.set(\tensionn, 0.0074);
			60.wait;
			~membrane.xset(\tensionn, 0.00800);
		}.fork
	}
)

//END
	
	~gap=11; // space before video starts again in seconds;
	~startFrom.(5304); 
	  
	~startFrom.(4800); 
	//~locateSecs.(5401);
{ ////the Sequence: idea - set end and do some scheduling relatively
	s.sync;
	~membrane.play(fadeTime:10);
	~schedule.(4833,{~membrane.stop(fadeTime:300)});"fade".postln;
	~schedule.(5310,{~chd.value});"chd".postln;
	~schedule.(5314,{~klank.play(vol:0.2,fadeTime:30)});
	~schedule.(5314,{~ambience.release(51)});
	~klankBus.fadeTime=15;
	~schedule.(5340,{~klankBus.source=(~tones).scramble});//is this happening?
~out.scope;
