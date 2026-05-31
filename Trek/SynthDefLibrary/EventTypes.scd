Event.addEventType(\tuningGong,{
	    var args = [~freq,~group,~tolerance,~lowest,~amp,~time,~sustain,~release,~channels];
		var gong = { |freq group tolerance = 0.03 lowest=400 amp=0.1 time=9 sustain=8 release=20 channels |
			freq.isNil.if  { \help.postln; }
			{ {
				var out = channels ? 4.rand;
				var even = Array.rand(100,lowest,20000);
				var near = { |fund| even.collect({|i| (nearHarmonic.(fund,i)<tolerance).if{0}{1}  })};
				var nearHarmonic = {|freq x| 20.collect({|i| (i*freq / x)-1 }).abs.inject(100,_ min: _)};
				var blend = 1-(Line.kr(0,1,time)*near.(freq));
				SinOsc.ar(even*VarLag.kr(\transpose.kr(1),\lag.kr(5),warp:\exp),0,0.01*blend)
				* blend
				=> Mix.ar(_)
				* Env.linen([ 0,0,0,5 ].choose,sustain,release).kr(2,gate:1)
				* 10 * amp
				=> Out.ar(out,_)
			}.play(group ? Server.default); }
    };
	    gong.(*args)
    },(freq:400,lowest:300,tolerance:0.03,group:s,amp:0.1,time:9,sustain:8,release:20)
)
