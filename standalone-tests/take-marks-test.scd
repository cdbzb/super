// Marks: beat-marked anchor sets in the per-take archive, and what reads them
// back (audio-beat-marking-plan.md steps 5-6): TakeArchive.writeMarks /
// loadMarks / isMarks, Take.tempoMap, MapEditor.loadMap, and Take.transients'
// keyword forwarding.
//
// Fixtures under AudioItem.folder (a tiny take file, its _retune and
// _transients dirs), removed at the end. The detector runs NRT in its own
// scsynth; nothing here needs the live server.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/take-marks-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var assertClose = h[\assertClose];
var assertArr = h[\assertArr];
var name = "zzz-take-marks-test";
var takeDir = AudioItem.folder +/+ name;
var takePath = takeDir +/+ "0.wav";
var cleanup, sel, v0, v1, v2, m, tm, me, amap, sig, sf, take, cond;

"== Take marks tests ==".postln;

cleanup = {
	[TakeArchive.dir(name, 0), TakeTransients.dir(name, 0), takeDir].do { |dir|
		(dir +/+ "*").pathMatch.do(File.delete(_));
		File.exists(dir).if { File.delete(dir) };
	};
};
cleanup.();

// ------------------------------------------------ writeMarks / loadMarks
sel = (anchors: [(key: 0, src: 1.0, beat: 0), (key: 1, src: 1.5, beat: 1), (key: 2, src: 2.1, beat: 2)],
	manualTimes: [1.0, 1.5], periodPrior: 0.5);
v0 = TakeArchive.writeMarks(name, 0, sel[\anchors], sel, (transientParams: (thresh: 0.3)));
v1 = TakeArchive.writeMarks(name, 0, [[1.0, 0], [1.6, 1], [2.2, 2], [2.8, 3]], nil, (edited: true));
m = TakeArchive.loadMarks(name, 0);
assert.(m[\version] == v1, "loadMarks: newest by default (version %)".format(m[\version]));
assert.(m[\anchorSource] == \beatMark, "writeMarks: anchorSource \\beatMark");
assert.(m[\recordedAgainst].isNil, "writeMarks: never carries recordedAgainst");
assertArr.(m[\anchors].collect(_[\src]), [1.0, 1.6, 2.2, 2.8], "writeMarks: [src, beat] pairs accepted");
assertArr.(m[\anchors].collect(_[\key]), [0, 1, 2, 3], "writeMarks: keys 0..n-1");
assert.(m[\edited] == true, "writeMarks: extra fields merged");
m = TakeArchive.loadMarks(name, 0, v0);
assert.(m[\selection][\manualTimes] == [1.0, 1.5], "loadMarks(v): that version, selection intact");
assert.(m[\transientParams][\thresh] == 0.3, "loadMarks(v): transientParams kept");
assert.(TakeArchive.isMarks(m) and: { TakeArchive.isStamp(m).not }, "isMarks, and not a stamp");
v2 = TakeArchive.write(name, 0, (retuneVersion: 2, midiEvents: []));
assert.(TakeArchive.loadMarks(name, 0)[\version] == v1, "loadMarks: skips non-marks versions");
assert.(TakeArchive.loadMarks(name, 0, v2).isNil, "loadMarks(v): nil when v is not a marks version");
assert.(TakeArchive.loadStamp(name, 0).isNil, "loadStamp: marks are not stamps");

// ------------------------------------------------------- Take.tempoMap
take = Take(name, 0);
tm = take.tempoMap;
assert.(tm.isKindOf(AnchorTempoMap), "Take.tempoMap: an AnchorTempoMap");
assertClose.(tm.t0, 1.0, "Take.tempoMap: t0 = first anchor's file second");
assertClose.(tm.timeDomain.first, 0, "Take.tempoMap: rebased (timeDomain starts at 0)");
assertClose.(tm.timeAt(2), 1.2, "Take.tempoMap: beat 2 is 1.2 s after the first anchor");
assertClose.(take.tempoMap(v0).timeAt(1), 0.5, "Take.tempoMap(v): a pinned version");

// ------------------------------------------------------- MapEditor.loadMap
amap = AnchorMap.fromAnchors([0, 0.25, 0.5, 0.75, 1], [1.0, 1.1, 1.2, 1.35, 1.5],
	fromFrame: \beat, toFrame: \sec);
me = MapEditor.new;
me.sourceFunc = { [[9, 10, 11], 1] };   // must NOT be read after loadMap
me.loadMap(amap);
assertArr.(me.times, [1.0, 1.1, 1.2, 1.35, 1.5], "loadMap: the map's times, not the source's");
assert.(me.subdiv == 4, "loadMap: subdiv recovered from even beat spacing (got %)".format(me.subdiv));
me.quantizeSpan(1);
me.revert;
assertArr.(me.times, [1.0, 1.1, 1.2, 1.35, 1.5], "loadMap: it is the revert target");

// --------------------------------------------- Take.transients kwargs forwarding
File.mkdir(takeDir);
sig = Signal.fill(48000, { |i| ((i % 12000) < 400).if { 0.7 * sin(i * 0.13) * exp((i % 12000).neg / 200) } { 0.001.rand2 } });
sf = SoundFile.new.headerFormat_("WAV").sampleFormat_("float").numChannels_(1).sampleRate_(48000);
sf.openWrite(takePath); sf.writeData(sig); sf.close;
cond = Condition.new;
fork {
	var got;
	take.transients({ |t| got = t; cond.unhang }, false, thresh: 0.25);
	cond.hang;
	assert.(got.size == 4, "Take.transients: detects the fixture's 4 hits (got %)".format(got.size));
	assert.(TakeTransients.load(name, 0, takePath, (thresh: 0.25)).notNil,
		"Take.transients: keyword params reach the cache key");
	assert.(TakeTransients.load(name, 0, takePath).isNil,
		"Take.transients: ...and the defaults are a different entry");
	cleanup.();
	h[\report].();
	0.exit;
};
)
