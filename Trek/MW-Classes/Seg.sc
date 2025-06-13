Seg { //segment - builds up Song structure
	classvar <>all;
	var <>name, <>segs, <>dur;
	*initClass {
		all = Dictionary.new
	}
	*new { |key ...args, kwargs|
		var instance = super.new;
		instance.name = key;
		all.put(key, instance);
		instance.segs = args;
		(args.size <= 1).if { 
			instance.dur = 1;
			instance.segs = [key];
		} {
			instance.dur = instance.segs.debug("SEGS").collect{|i| all[i].dur }.sum;
			// instance.dur=0;
			instance.segs = args;
		};
		^instance
	}
	play {
		name.postln;
		fork{
			(segs.size > 1).if {
				segs.do({ |i| 
					all[i].play.wait
				})
			} {
				(freq: 666.rrand(900)).play;
				dur.wait
			}
		};
		^dur
	}
	dump {
		// args.collect{|i| all[i] ? i}
	}
}
