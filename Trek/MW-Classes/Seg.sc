Seg { //segment - builds up Song structure
	classvar <>all;
	var <>name, <>segs, <>dur, <>filters, <>parts;

	*initClass {
		all = Dictionary.new
	}

	*new { |key ...args, kwargs|
		var instance = super.new;
		instance.name = key;
		all.put(key, instance);
		instance.segs = args;
		instance.filters = kwargs;
		// make Segs for any args that work
		args.do{|i| (all[i].isNil and: (Song.section(i) != (-1))).if {Seg(i, i)}};
		(args.size <= 1).if { 
			// if there is one arg we are referencing a single Song section so set the dur
			instance.dur = Song.secDur[args[0]];
		} {
			// otherwise recurse
			instance.dur = instance.segs.collect{|i| all[i].dur }.sum;
		};
		^instance
	}

	play {
		fork{
			(segs.size > 1).if {
				// if many segs recurse
				segs.do{ |i| 
					all[i].play.wait
				}
			} {
				//finally play the section
				parts = Song.at(segs[0]);
				Song.cursor_(Song.section(segs[0]));
				//apply filters
				filters.pairsDo {|j k|
					this.performArgs(j, [k])
				};
				parts.do{|i|
					i.p
				}
				// Song.secDur[name]
			}
		}
		^dur
	}
	mute { |what|
		var res = parts;
		
		what.asArray.do {|i|
			res = res.reject {|j| j.name.asString.contains(i.asString)}
		};
		parts = res;
		^this
	}
	solo {|what|
		var res = parts;
		what.asArray.do {|i|
			res = res ++ res.select{|j| j.name.asString.contains(i.asString)}
		};
		parts = res.flat
		^this
	}
}
