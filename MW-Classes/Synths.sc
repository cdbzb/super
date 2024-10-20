Synths {
	var <>synths;
	var defName;

	*new {|def ...args|
		^super.new.init(def,args)
			}

	init {|def args|
		var voices = args.collect(_.size).inject(0,(_ max: _));
		defName = def;
		args.postln;
		synths=Array.newClear(voices);
		args.flop.do({|i x| synths[x]=Synth(def,i)})
		//^synths
		^this
		//super.new.init(args);
		//^this.synths;

	}
	add {|...args|
		synths=synths.add(Synth(defName,args))
	}

	free {
		synths.do(_.free)
	}
	release {|secs|
		synths.do(_.release(secs))
	}
	//TODO 
	set { |...args|
		(args.flop.size==1).if{args=[args[0]]++[args[1].dup(synths.size)]};
		args.postln;
		args.flop.do({|i x| 
			synths[x].set(*i)})
	}

	map { |control bus|
		(bus.numChannels==1).if(
			{synths.do(_.map(control,bus))}
			,
			{bus.numChannels.do{|i| synths[i].map(control,bus.subBus(i))}}
		)
	}
	dur { |length, release|
		synths.do{|i| i.dur(length,release)}
	}

	doesNotUnderstand { |selector val|
		synths.do({|i| selector.postln; i.postln})
	}
}
//a=Synths(\freq,[900,800])
//a.set(\freq,[200,300])
//a.release(2)

//valueArray
