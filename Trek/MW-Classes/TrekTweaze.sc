+Trek {
	// makePersistentFader lives in Trek.sc (main class)
	*showFaderAndSynthV { |num part|
		faders[num].cs.postln;
		Song.songs[keys[num]].synthVTracks[part].cs.postln
	}
}
