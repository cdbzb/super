Synths {
	var <>synths;

	*new {|def ...args|
		^super.new.init(def,args)
			}

	init {|def args|
		var voices = args.collect(_.size).inject(0,(_ max: _));
		args.postln;
		synths=Array.newClear(voices);
		args.flop.do({|i x| synths[x]=Synth(def,i)})
		//^synths
		^this
		//super.new.init(args);
		//^this.synths;

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
			synths[x].set(i)})
	}
	doesNotUnderstand { |selector val|
		synths.do({|i| selector.postln; i.postln})
	}
}
//a=Synths(\freq,[900,800])
//a.set(\freq,[200,300])
//a.release(2)

//valueArray
