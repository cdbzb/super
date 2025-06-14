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
		args.do{|i| (all[i].isNil and: (Song.section(i) != (-1))).if {Seg(i, i)}};
		(args.size <= 1).if { 
			instance.dur = Song.secDur[key];
		} {
			instance.dur = instance.segs.debug("SEGS").collect{|i| all[i].dur }.sum;
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
				Song.cursor_(Song.section(segs[0]));
				Song.at(segs[0]).do(_.p);
				// Song.secDur[name]
			}
		};
		^dur
	}
	dump {
		// args.collect{|i| all[i] ? i}
	}
}
