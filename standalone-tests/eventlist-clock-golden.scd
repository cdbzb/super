/* Golden clock fixtures for the EventList -> AnchorMap migration
   (eventlist-anchormap-migration-plan.md, step 1).

   Builds a fixed set of lists, measures everything the list clock answers
   (prepare schedules, beatToWall / wallToBeat grids, bpmAt, item placement),
   and either RECORDS the numbers to fixtures/eventlist-clock-golden-data.scd or
   CHECKS the current code against that file.

     ~eventListGoldenRecord = true;  "…/eventlist-clock-golden.scd".load;  // record
     ~eventListGoldenRecord = nil;   "…/eventlist-clock-golden.scd".load;  // check

   Record once on the pre-migration code; every later run checks. Pure
   language, no server. Lists are named \golden* (EventList(name) is global). */
(
var dir = "/Users/michael/tank/super/standalone-tests";
var h = (dir +/+ "test-helpers.scd").load;
var assert = h[\assert];
var dataPath = dir +/+ "fixtures/eventlist-clock-golden-data.scd";
var epoch = 100, tol = 1e-9;
var mkNotes, mkTakePlayer, mkRecPlayer, measure, fixtures = (), results = (), golden;
var serialize, fails = 0, checked = 0;

/* note events at the given take timestamps */
mkNotes = { |stamps|
	List.newFrom(stamps.collect { |t, i|
		(midicmd: \noteOn, type: \mk, midinote: 60 + (i % 12), amp: 0.5,
			timestamp: t, sustain: 0.2, dur: 0.2)
	})
};
/* a take whose clock is an explicit map with t0 = 3.2 (first anchor, mid-take) */
mkTakePlayer = { |map|
	var p = MIDIItemPlayer(mkNotes.([3.0, 3.2, 3.7, 4.5, 5.0, 6.1, 6.4, 7.3]), nil);
	p.tempoMap = map ?? { AnchorTempoMap([3.2, 3.7, 4.5, 5.0, 6.1, 7.3], [0, 1, 2, 3, 4, 5]) };
	p
};
/* a take recorded while `list` played: started 2.3 s after the play epoch's beat 1 */
mkRecPlayer = { |list|
	var snap = list.prClockSnapshot;
	MIDIItemPlayer(mkNotes.([0, 0.5, 1.5, 2.25]), nil)
		.recordEpoch_(52.3)
		.recordPlayEpoch_((seconds: 50, fromBeat: 1, tempoEnv: snap.tempoEnv, list: snap))
};

/* everything the clock answers, as name -> Array of numbers */
measure = { |l|
	var env = l.tempoEnv, rec = mkRecPlayer.(l), r = ();
	r[\sched0] = l.prepare(epoch, 0).collect { |i| i[\time] }.asArray.sort;
	r[\sched15] = l.prepare(epoch, 1.5).collect { |i| i[\time] }.asArray.sort;
	r[\b2w] = (0, 0.25 .. 12).collect { |b| l.beatToWall(b, env) };
	r[\w2b] = (0, 0.3 .. 10).collect { |s| l.wallToBeat(s, env) };
	r[\bpm] = (0 .. 10).collect { |b| l.bpmAt(b, 1, env) ? -1 };
	r[\t0] = [(l.respondsTo(\t0).if { l.t0 } { l.tempoMap.tryPerform(\t0) }) ? 0];
	r[\place] = [l.itemStartBeat(rec) ? -1, l.prItemBeat(rec, 0.7) ? -1];
	r
};

// ---- fixtures ----------------------------------------------------------------
fixtures[\flat] = {
	var l = EventList(\goldenFlat).clear;
	l.beatDur = 0.5;
	(0 .. 8).do { |b| l.add(b, foo: b) };
	l
};
fixtures[\take] = { mkTakePlayer.().asEventList(\goldenTake, nil) };
fixtures[\takeTempoTrack] = {
	var l = mkTakePlayer.().asEventList(\goldenTakeTT, nil);
	l.add(0, tempoTrack: 1);
	l.add(1, tempoTrack: Tuple3(1.5, 2, \lin));
	l.add(4, tempoTrack: 0.8);
	l.add(9, foo: \past);   // events past the map's end: the hold
	l
};
fixtures[\editQuantize] = { mkTakePlayer.().asEventList(\goldenQ, nil).quantize(0.5) };
fixtures[\editWindow] = { mkTakePlayer.().asEventList(\goldenQW, nil).quantizeWindow(0.7) };
fixtures[\editSpan] = { mkTakePlayer.().asEventList(\goldenSpan, nil).setBpm(90, 1, 3) };
fixtures[\editAlign] = {
	var parent = EventList(\goldenAlignParent).clear;
	parent.beatDur = 0.6;
	parent.add(0, tempoTrack: 1); parent.add(2, tempoTrack: Tuple3(1.3, 4, \lin));
	mkTakePlayer.().asEventList(\goldenAlign, nil).alignTo(parent, 2, 0.5)
};
fixtures[\editEase] = {
	var a = mkTakePlayer.().asEventList(\goldenEaseA, nil);
	var b = mkTakePlayer.(AnchorTempoMap([3.2, 3.6, 4.0, 4.5, 4.9], [0, 1, 2, 3, 4]))
		.asEventList(\goldenEaseB, nil);
	a.tempoMap = a.tempoMap.fromBeat(0, 4).easeTo(b.tempoMap.fromBeat(0, 4), 1, 1);
	a
};
fixtures[\curved] = {
	mkTakePlayer.(MIDIItemTempoMap.fromAnchors([3.2, 3.7, 4.5, 5.0, 6.1, 7.3],
		[0, 1, 2, 3, 4, 5]).curve(1)).asEventList(\goldenCurved, nil)
};
fixtures[\listCopy] = {
	var src = mkTakePlayer.().asEventList(\goldenCopySrc, nil);
	src.copy
};
fixtures[\nestFollow] = {
	var parent = EventList(\goldenNestF).clear;
	parent.beatDur = 1;
	parent.add(0, tempoTrack: 2);
	parent.add((when: 2, newType: \eventList,
		eventList: mkTakePlayer.().asEventList(\goldenNestFChild, nil), followTrack: true));
	parent
};
fixtures[\nestAlign] = {
	var parent = EventList(\goldenNestA).clear;
	parent.beatDur = 1;
	parent.add(0, tempoTrack: 2);
	parent.add((when: 2, newType: \eventList,
		eventList: mkTakePlayer.().asEventList(\goldenNestAChild, nil), align: 0.5));
	parent
};
fixtures[\addOriginal] = {
	var l = mkTakePlayer.().asEventList(\goldenAddOrig, nil);
	l.addItem(mkRecPlayer.(l), at: \original);
	l
};
fixtures[\addAlign] = {
	var l = mkTakePlayer.().asEventList(\goldenAddAlign, nil);
	l.addItem(mkTakePlayer.(), at: 2, align: 1);
	l
};

// ---- measure -----------------------------------------------------------------
fixtures.keys.asArray.sort.do { |k|
	results[k] = try { measure.(fixtures[k].value) } { |err|
		"golden: fixture % threw: %".format(k, err.errorString).postln;
		(error: [err.errorString])
	}
};

// ---- record or check ---------------------------------------------------------
serialize = { |v|
	v.isNumber.if { v.asFloat.asStringPrec(17) } {
		v.isString.if { v.asCompileString } {
			"[" ++ v.collect(serialize).join(", ") ++ "]"
		}
	}
};
(~eventListGoldenRecord == true).if {
	var f;
	File.mkdir(dataPath.dirname);
	f = File(dataPath, "w");
	f.write("// Recorded by eventlist-clock-golden.scd on " ++ Date.getDate.stamp
		++ ". Regenerate only on purpose.\n(\n");
	results.keys.asArray.sort.do { |k|
		f.write("\t" ++ k ++ ": (\n");
		results[k].keys.asArray.sort.do { |m|
			f.write("\t\t" ++ m ++ ": " ++ serialize.(results[k][m]) ++ ",\n")
		};
		f.write("\t),\n")
	};
	f.write(")\n");
	f.close;
	"golden: recorded % fixtures to %".format(results.size, dataPath).postln;
} {
	golden = dataPath.load;
	golden.keys.asArray.sort.do { |k|
		golden[k].keys.asArray.sort.do { |m|
			var want = golden[k][m], got = results[k] !? { results[k][m] };
			var ok = got.notNil and: { got.size == want.size } and: {
				want.every { |w, i|
					w.isNumber.if { (got[i] - w).abs <= (tol * max(1, w.abs)) } { got[i] == w }
				}
			};
			checked = checked + 1;
			assert.(ok, "golden %.%%".format(k, m,
				ok.if { "" } { " (got % want %)".format(got, want) }));
		}
	};
	(results.keys.asArray.sort != golden.keys.asArray.sort).if {
		assert.(false, "golden: fixture set changed (% vs %)"
			.format(results.keys.asArray.sort, golden.keys.asArray.sort))
	};
	h[\report].();
};
)
