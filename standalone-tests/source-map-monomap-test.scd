// A V2 MonoMap as sourceTempoMap: (audio-beat-marking-plan.md step 2a).
//
// MapEditor.last is a bare AnchorMap (beat -> absolute take seconds). It once
// had no beatDomain/timeDomain, so prSrcOffset / prSrcEndBeat threw
// doesNotUnderstand on it; they convert it once with asAnchorTempoMap, the same
// seam warpTo uses. AnchorMap now answers its real domain and range too, so the
// domain-relative readers agree on either form.
//
// Asserted:
//   * prSrcOffset on a bare AnchorMap answers the anchor spacing, relative to the
//     first anchor (item frame), and matches the explicitly converted map
//   * prSrcEndBeat inverts it
//   * a physical map (sourceMapIsPhysical: true) adds no origin
//
// Pure language. No server, no audio, no fixtures on disk.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/source-map-monomap-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var assertClose = h[\assertClose];
var times = [1.0, 1.5, 2.1, 2.6, 3.0];
var b0 = 4;
var mono, converted, list, ev, evConv, f, fConv, endB;

"== sourceTempoMap: MonoMap tests ==".postln;

mono = MapEditor.mapFromTimes(times, 1);
converted = mono.asAnchorTempoMap;
list = EventList.new;
ev = (item: "zzz-monomap-src-test", sourceTempoMap: mono, sourceMapIsPhysical: true);
evConv = (item: "zzz-monomap-src-test", sourceTempoMap: converted, sourceMapIsPhysical: true);

assert.(((mono.timeAt(mono.beatDomain.first + 2) - mono.timeDomain.first)
	- (converted.timeAt(converted.beatDomain.first + 2) - converted.timeDomain.first)).abs < 1e-12,
	"domain-relative reads agree on the bare AnchorMap and its conversion");

f = { AudioItem.prSrcOffset(ev, list, b0, 0) }.try { |e| e.errorString.postln; nil };
assert.(f.notNil, "prSrcOffset accepts a bare AnchorMap");
fConv = AudioItem.prSrcOffset(evConv, list, b0, 0);

f !? {
	times.do { |t, k|
		assertClose.(f.(b0 + k), t - times.first,
			"beat % sits at its anchor, item frame".format(b0 + k));
		assertClose.(f.(b0 + k + 0.5), fConv.(b0 + k + 0.5),
			"matches the converted map at beat %".format(b0 + k + 0.5));
	};
};

endB = { AudioItem.prSrcEndBeat(ev, list, b0, 0, 1.6, 0) }.try { |e| e.errorString.postln; nil };
assert.(endB.notNil, "prSrcEndBeat accepts a bare AnchorMap");
(f.notNil and: { endB.notNil }).if {
	assertClose.(f.(endB), 1.6, "prSrcEndBeat inverts prSrcOffset")
};

h[\report].();
0.exit;
)
