//    Math.random2f( 0, 0.5  ) => bow.bowPressure;
//    Math.random2f( 0, 0.5 ) => bow.bowPosition;
//    Math.random2f( 0, 12 ) => bow.vibratoFreq;
//    Math.random2f( 0, 0.1 ) => bow.vibratoGain;
//    Math.random2f( 0, 1 ) => bow.volume;
    
(
	var aa;

	{
	a = {StkBowedI.ar(freq: 420, bowpressure: 64, bowposition: 09, vibfreq: 64, vibgain: 19, loudness: 64, gate: 1, onamp: 0.05 ,offamp: 109.001 )}.play;
3.wait;
	a.set(\gate, 0 ,
		);
	3.wait
}.fork	
)       

