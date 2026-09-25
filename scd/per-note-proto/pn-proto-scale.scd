/* Beat scale for the prototype: ~pnBeatScale = 2 makes each marks-v3 beat span 2 list
   beats. The event gets a scaled copy of the marks as a map-object sourceTempoMap:
   (file seconds, so sourceMapIncludesLatency: true; start: = first mark's file second,
   as \marks would resolve it). All three ~pnPlay modes read it. 1 = marks as saved. */
(
topEnvironment[\pnBeatScale] = 2;
topEnvironment[\pnEvent] = {
	var list = EventList.current, k = topEnvironment[\pnBeatScale] ? 1, mk;
	var ev = list.events.detect { |e|
		((e[\item] ? "").asString == "vibes-test-1201") and: { e[\followTrack] == \marks } and: { e[\tempoFollowMode] != \env }
	};
	ev.isNil.if { Error("pnEvent: no vibes-test-1201 event with followTrack: \\marks in EventList.current").throw };
	ev = ev.copy;
	(k != 1).if {
		mk = TakeArchive.loadMarks("vibes-test-1201", ev[\take] ? 0, ev[\marksVersion]);
		ev[\sourceTempoMap] = AnchorTempoMap(mk[\anchors].collect(_[\src]), mk[\anchors].collect { |a| a[\beat] * k });
		ev[\sourceMapIncludesLatency] = true;
		ev[\start] = mk[\anchors].first[\src];
		ev[\followTrack] = true; ev[\marksVersion] = nil;
	};
	[list.prForwardAudioFollow(ev), list, list.prLazyTempoEnv]
};
"pn beat scale: %".format(topEnvironment[\pnBeatScale]).postln;
)
