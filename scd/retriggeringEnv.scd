
(

y = {
	var gate = \gate.kr(1);
	var first = Env([0, 1], 0.01).kr(0,gate:gate); //quick change to make Latch grab the initial 1
	var env = Env([1,0],0.1 ).kr(0,gate); // this will be zero the next time gate changes (to 0) and after
	var latch = Latch.ar(env, 
		Changed.kr(gate + first )) ;
	Env.asr(releaseTime: 10).kr(2,gate:latch) 
	* SinOsc.ar(333)
	/10;
	
}.play
)
y.set(\gate, 1)
y.set(\gate, 0)
(
~nonRetriggering = {|gate| 
	var first = Env([0, 1], 0.01).kr(0,gate:gate); //quick change to make Latch grab the initial 1
	var env = Env([1,0],0.1 ).kr(0,gate); // this will be zero the next time gate changes (to 0) and after
	var latch = Latch.ar(env, 
		Changed.kr(gate + first )) ;
		Env.asr(releaseTime: 10).kr(2,gate:latch) 
		* SinOsc.ar(333)
		/10;
	}
)
a = { ~nonRetriggering.(\gate.kr(1)) }.play
a.set(\gate, 1)
