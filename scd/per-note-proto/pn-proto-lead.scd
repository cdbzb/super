/* ~pnLead: seconds of SOURCE before each note start where the rate step (and, in
   \perNote mode, the crossfade) happens. 0 = at the note start. */
(
topEnvironment[\pnLead] = 0.03;
topEnvironment[\pnPlay] = { |mode = \perNote, from|
	var ev, list, tempoEnv, actions, starts, lead = topEnvironment[\pnLead] ? 0;
	#ev, list, tempoEnv = topEnvironment[\pnEvent].value;
	from = from ? (ev[\when] ? 0);
	starts = topEnvironment[\pnStarts].collect { |t| t - lead };
	actions = switch(mode,
		\grid, { AudioItem.tempoFollowActions(ev, list, tempoEnv, from) },
		\oneSynth, { topEnvironment[\pnOneSynth].(ev, list, tempoEnv, starts, from) },
		{ topEnvironment[\pnActions].(ev, list, tempoEnv, starts, from) });
	"pnPlay %: % synths from beat %, lead % s, beat scale %"
		.format(mode, actions.size, from, lead, topEnvironment[\pnBeatScale] ? 1).postln;
	actions.do { |pair| SystemClock.sched(pair[0], { pair[1].value; nil }) };
	actions.size
};
"pn lead: % s".format(topEnvironment[\pnLead]).postln;
)
