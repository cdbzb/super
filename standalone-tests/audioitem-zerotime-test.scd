// AudioItem.zeroTimeFor — the take's frame origin, applied UNIFORMLY by
// prSrcOffset and removed again by prSrcEndBeat.
//
// Before this, `rt` (the stamped round trip) was added only on prSrcOffset's two
// stamp branches and subtracted only there by prSrcEndBeat, so `start:` meant a
// compensated read position on some branches and a raw file offset on others,
// with nothing at the call site to say which. The sealed \audioItem path always
// read at startPos + rt — that is the semantics; the follow path was the odd one.
//
// Asserted here, for a take stamped with roundTrip = 0.05:
//   * every prSrcOffset branch answers the origin at bt == b0
//   * prSrcEndBeat inverts prSrcOffset exactly, on every branch
//   * sourceMapIsPhysical: true suppresses the origin (a map authored from
//     physical file positions already contains the delay)
//   * an UNSTAMPED take is unshifted on every branch (the face-value rule)
//
// Pure language; fixtures live under AudioItem.folder/_retune and are removed at
// the end. No server, no audio.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/audioitem-zerotime-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var assertClose = h[\assertClose];
var name = "zzz-zerotime-test";       // stamped, roundTrip 0.05
var bare = "zzz-zerotime-bare-test";  // never stamped
var rt = 0.05;
var savedRt = AudioItem.roundTripLatency;
var b0 = 2;
var cleanup, list, mapList, env, stamp, srcMap;
var evMap, evFlat, evStamp, evPhys, evBare, evBareMap;
var branches, originOf, invertsAt;

"== AudioItem zeroTime tests ==".postln;

cleanup = {
	[name, bare].do { |n|
		[0, 1].do { |num|
			var dir = RetuneArchive.dir(n, num);
			(dir +/+ "*.retune").pathMatch.do(File.delete(_));
			File.exists(dir).if { File.delete(dir) };
			AudioItem.recordedMaps.removeAt(n.asSymbol, num);
		}
	}
};
cleanup.();

// --------------------------------------------------------------- fixtures
// A flat 1 s/beat list, and a map-carrying one so prSrcEndBeat's tempoMap branch
// is exercised too. tempoEnv nil keeps the composed clock equal to the base clock.
list = EventList.new;
list.beatDur = 1;
mapList = EventList.new;
mapList.tempoMap = AnchorTempoMap([0, 8], [0, 8]);
env = nil;

AudioItem.roundTripLatency = rt;
stamp = list.prRecordStamp((when: b0), env);
AudioItem.roundTripLatency = 0;
assertClose.(stamp[\roundTrip], rt, "fixture: the stamp froze roundTrip 0.05");
// take 0 keeps the in-memory (list + tempoEnv) form; take 1 is disk only, so
// recordedMapAt rebuilds it as the \map form
AudioItem.recordedMaps.put(name.asSymbol, 0, stamp);
RetuneArchive.writeStamp(name, 1, stamp);

// A source map in the take's own item frame: 1 s/beat, domains starting at 0.
srcMap = AnchorTempoMap([0, 8], [0, 8]);

// The five prSrcOffset branches, in priority order. The last one is reached ONLY
// when the take has no stamp (the stamp branch would have answered first), so its
// origin is 0 by construction — it is listed to show the rule is uniform, not to
// claim a stamped take can reach it.
evMap   = (type: \audioItemTempoFollow, item: name, sourceTempoMap: srcMap);
evFlat  = (type: \audioItemTempoFollow, item: name, sourceBeatDur: 1);
evStamp = (type: \audioItemTempoFollow, item: name);
evPhys  = (type: \audioItemTempoFollow, item: name, sourceTempoMap: srcMap,
	sourceMapIsPhysical: true);
evBare  = (type: \audioItemTempoFollow, item: bare);
evBareMap = (type: \audioItemTempoFollow, item: bare, sourceTempoMap: srcMap);

// ------------------------------------------------------- zeroTimeFor itself
assertClose.(AudioItem.zeroTimeFor(name, 0), rt, "zeroTimeFor: in-memory stamp -> 0.05");
assertClose.(AudioItem.zeroTimeFor(name, 1), rt, "zeroTimeFor: disk stamp -> 0.05");
assertClose.(AudioItem.zeroTimeFor(bare, 0), 0, "zeroTimeFor: no stamp -> 0, not nil");
assertClose.(AudioItem.zeroTimeFor(nil, 0), 0, "zeroTimeFor: nil name -> 0");
assertClose.(AudioItem.prEventZeroTime(evPhys, 0), 0,
	"prEventZeroTime: sourceMapIsPhysical suppresses the origin");
assertClose.(AudioItem.prEventZeroTime(evMap, 0), rt,
	"prEventZeroTime: an explicit map gets the origin by default");

// ------------------------------- the origin at bt == b0, on every branch
// [label, event, takeNum, list, expected origin]
branches = [
	["explicit sourceTempoMap", evMap,   0, list,    rt],
	["flat sourceBeatDur",      evFlat,  0, list,    rt],
	["stamp, in-memory form",   evStamp, 0, list,    rt],
	["stamp, disk \\map form",  evStamp, 1, list,    rt],
	["list base clock (flat)",  evBare,  0, list,    0],
	["list base clock (map)",   evBare,  0, mapList, 0],
	["physical map (opt out)",  evPhys,  0, list,    0],
	["unstamped + map",         evBareMap, 0, list,  0]
];
originOf = { |ev, takeNum, lst| AudioItem.prSrcOffset(ev, lst, b0, takeNum).(b0) };
branches.do { |b|
	assertClose.(originOf.(b[1], b[2], b[3]), b[4],
		"prSrcOffset origin at b0 — %".format(b[0]))
};

// ------------------------------ prSrcEndBeat is the exact inverse, per branch
// startSec + srcOffset.(endBeat) == endSec  <=>  prSrcEndBeat.(endSec) == endBeat
invertsAt = { |label, ev, takeNum, lst, startSec, targetBeat|
	var f = AudioItem.prSrcOffset(ev, lst, b0, takeNum);
	var endSec = startSec + f.(targetBeat);
	var got = AudioItem.prSrcEndBeat(ev, lst, b0, startSec, endSec, takeNum);
	assertClose.(got, targetBeat, "prSrcEndBeat inverts prSrcOffset — %".format(label), 2e-3)
};
branches.do { |b|
	invertsAt.(b[0], b[1], b[2], b[3], 0, b0 + 3);
	// a non-zero start: the origin must still cancel exactly
	invertsAt.(b[0] + "(start 0.4)", b[1], b[2], b[3], 0.4, b0 + 3)
};

// --------------------------- the origin SHIFTS positions without changing spans
// Compensation moves every file position by the same amount; it must not stretch
// or squash the source span between two beats.
branches.do { |b|
	var f = AudioItem.prSrcOffset(b[1], b[3], b0, b[2]);
	assertClose.(f.(b0 + 3) - f.(b0 + 1), 2,
		"origin shifts, never scales — %".format(b[0]), 2e-3)
};

// ------------------------- the two stamp forms agree, origin included
assertClose.(originOf.(evStamp, 0, list), originOf.(evStamp, 1, list),
	"in-memory and disk stamp forms answer the same origin", 2e-3);

cleanup.();
AudioItem.roundTripLatency = savedRt;
h[\report].();
0.exit;
)
