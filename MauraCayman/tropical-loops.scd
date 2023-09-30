(// loop with pad on top
var sections = [13,12].q(inf).asStream;
	var r = Recorder.new(s);
    r.recHeaderFormat = "wav";
    r.recSampleFormat = "int24";
    r.filePrefix = "ArpeggiosLoop_";
fork{
	0.1.wait;
	// r.record;
	6.do{
		var thisSec = sections.next;
		Song.playSection(thisSec);
		Song.secDur[thisSec].wait;
	};
	Song.secDur[12] + 3 => _.wait; 
	r.stopRecording
}

);
( //calypsoTheme loop with tremolo
var durs = [Song.secDur[\VerseLoop],Song.secDur['VersTwoLoop'],"qqqqqqqq".asBeats.warpTo(Song.tempoMap[\VersLoopConnecter]).unbubble];
	var r = Recorder.new(s);
    r.recHeaderFormat = "wav";
    r.recSampleFormat = "int24";
    r.filePrefix = "CalypsoLoop_";
	Song.guitarFXSynthFunc = {
		In.ar(Song.guitarFx,1) / 4 
		=> HPF.ar(_,150)
=> Out.ar(1,_)
	};
fork{
	// r.record;0.1.wait;
	6.do{
		[\VerseLoop,\VersTwoLoop,\VersLoopConnecter].do { |x i|
			x.postln;
			Song.playSection(x);
			// Song.secDur[x].wait
			durs[i].wait

		};
	};
		3.wait;
		r.stopRecording

}
)
