+ EnvGen {
	*cutoff { |wait release curve doneAction = 2|
		^Env([1,1,0],[wait, release],curve).kr(doneAction)
	}
	*noRetrig {|env gate lscale=1 lbias=1 tscale=1 doneAction=0|
		var first = Env([0, 1], 0.001).kr(0,gate:gate); //quick change to make Latch grab the initial 1
		var oneThenZero = Env([1,0],0.1 ).kr(0,gate); // this will be zero the next time gate changes (to 0) and after
		var latch = Latch.ar(oneThenZero, Changed.kr(gate + first));
		^env.kr(2, gate:latch)
	}
}

+Env{
	noRetrig{ |doneAction=0 gate=1|
		^EnvGen.noRetrig(this, gate, 1, 1, 1, doneAction)
	}
}
