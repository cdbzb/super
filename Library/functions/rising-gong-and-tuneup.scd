{ //rising gongs no globals version
var gong = { |freq group tolerance = 0.03 lowest=400 amp=0.1 release=20 |
	freq.isNil.if  { \help.postln; }
	{ {
		var even = Array.rand(100,lowest,20000);
		var near = { |fund| even.collect({|i| (nearHarmonic.(fund,i)<tolerance).if{0}{1}  })};
		var nearHarmonic = {|freq x| 20.collect({|i| (i*freq / x)-1 }).abs.inject(100,_ min: _)};
		var blend = 1-(Line.kr(0,1,9)*near.(freq));
		SinOsc.ar(even*VarLag.kr(\transpose.kr(1),\lag.kr(5),warp:\exp),0,0.01*blend)
		* blend
		=> Mix.ar(_)
		* Env.linen([ 0,0,0,5 ].choose,8,release).kr(2,gate:1)
		* 10 * amp
		=> Out.ar(4.rand,_)
	}.play(group ? s); }
    };
Event.addEventType(\tuningGong,{
	    var args = [~freq,~group,~tolerance,~lowest,~amp,~release];
	    gong.(*args)
    },(freq:400,lowest:300,tolerance:0.03,group:s))
}.();
//{ ~gong.(400,g,lowest:1000) }.sched([1,2,4]);
//{ g.set(\transpose,1.1) }.sched(10);

{ //tune up sound - sounds good with gongs...
var tuneUp = { |freq=150 amp=0.2 out=0.1|
var numberOfPartials = s.sampleRate/freq/2;
var noise = Array.rand(numberOfPartials,100,s.sampleRate/2).sort;
var tone = (numberOfPartials-1).asInteger.collect({|i| ( i + 1 ) * freq });
	{
		var line = Line.kr(0,1,10);
		var freq = line * tone + ( (1-line) * noise );
		(1..(numberOfPartials+1)).reciprocal;
		//Array.geom(~numberOfPartials,0.01,0.98);
		SinOsc.ar(freq,0,amp)
		=> Mix.ar(_)
		* Env.linen(1,1,11).kr(2,gate:1)
		* amp

	}.play(s,out);
};
Event.addEventType(\tuneUp,{var args = [~freq,~amp,~out]; tuneUp.(*args)},(type:\on,freq:300,amp:0.001,out:0));
}.();
