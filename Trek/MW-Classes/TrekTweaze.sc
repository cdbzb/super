+Trek {
	*makePersistentFader {|num|
		num = num ? keys.indexOf( Song.current );
		num.debug("number: ");
		this.loadTransitions;
		Trek.faders[num].();
		{
			fork{
				while { StageLimiter.activeSynth.isRunning.not } {0.1.wait};
				Trek.faders[num].()
			}
		} => ServerTree.add(_);
	}
	*showFaderAndSynthV { |num part|
		faders[num].cs.postln;
		Song.songs[keys[num]].synthVTracks[part].cs.postln
	}
}
