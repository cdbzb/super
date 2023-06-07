Sequence : List {

	var condition;
	var <>infrastucture;

	*new {^super.new.init()}
	init {
		infrastucture=FunctionList.new;
		infrastucture.addFunc{\evaluating_infrastructure.postln};
	}

	prePlay {
		condition !? (_.test_(false));
		infrastucture.isNil.not.if{
			infrastucture.value;
		}
	}

	sched { |when what|
		this.add(T(when,what))
	}

	play { |from clock |
		clock = (clock ? TempoClock.default);
		this.do {|i|
			if(
				(i.at1 >= (from ? 0)) 
				, 
				{clock.sched( i.at1,i.at2) }
			);
		}
	}
}
