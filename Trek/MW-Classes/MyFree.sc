MyFree {
	classvar <>actions;

	*initClass {
		actions = FunctionList( [
			{ Server.default.freeMyDefaultGroup; },
			{
				fork{
					//s.latency.wait;
					TempoClock.all.do(_.clear);
					SystemClock.do(_.clear);
				};
			},
			// Alga.parGroups[s] = AlgaParGroup(s.defaultGroup);
			// ~vstRegistry.do{|i| 16.do{|x| i.midi.allNotesOff(x)}};
			{
				try{ Song.resources.select{|i| i.isKindOf(Node)}.do(_.release)};
			},
			{ Trek.transitionGroup.release },
			// MIDIItem.stopRecording;
		] )
	}
	*add{ |func|
		actions.addFunc(func)
	}
	*remove{ |func|
		actions.removeFunc(func)
	}
	*printOn{
		actions.do(_.cs.postln)
	}
	*new{
		actions.value
	}
}
