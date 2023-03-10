///////////////////////////////////////////////////
// History, as it was on Wed Jun 12 23:12:18 2019.
///////////////////////////////////////////////////

// - 0:26:12.6 -  
			m.play(~out.index,2,0,2,multi:true);

// - 0:26:14.58 -  
			m.play(~out.index+4,2,0,2, multi:true);

// - 0:26:17.36 -  
~ambience.play(~out.index+6,fadeTime:180);

// - 0:26:31.47 -  
~ambience.play(~out.index+6,fadeTime:0);

// - 0:26:43.25 -  
~locate.(3858);

// - 0:26:49.15 -  
s.record(bus:~out)

// - 0:26:49.16 -  
~startFrom.(3858);

// - 0:27:1.67 -  
~chordWave.(tempo:1,vol:0.005);

// - 0:28:12.67 -  
~ambience.play(~out.index+6,vol:2,fadeTime:0);

// - 0:29:33.19 -  
~tighten.(100);

// - 0:31:3.66 -  
~klankRoutine.reset;

// - 0:31:5.72 -  
~klankRoutine.play;

// - 0:32:17.08 -  
~chordWave.(tempo:1,vol:0.005);

// - 0:32:22.65 -  
~tighten.(100);

// - 0:33:40.26 -  
(\instrument: \fibs, \fr: [4,4.5,5,6,8,9,10]*2*1.2,\amp:0.2,\bus:~out.index+8).play

// - 0:34:2.91 -  
~membrane.play(fadeTime:300); // set los and tensionn + lags and fadeTime

// - 0:40:37.31 -  
History.playCmdPeriod

// - 0:40:51.95 -  
//This one prettu NOICE

