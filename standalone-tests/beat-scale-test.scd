// beatScale: on \audioItem events — list beats per source beat (MIDIItemPlayer
// .beatScale's sense). 0.5 when the take's marks count quarters and the list
// counts halves. Applied once in AudioItem.prResolveSourceMap, so prSrcOffset /
// prSrcEndBeat, fromBeat:/toBeat: (still take beats) and every source agree.
//
// Pure language (reads the fixture file, sends nothing). Fixtures under
// AudioItem.folder, removed at the end.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/beat-scale-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var assertClose = h[\assertClose];
var name = "zzz-beat-scale-test";
var srcs = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0];   // marks: one beat per 0.5 s
var b0 = 4, list, cleanup, sf, sig, off, off1, r, endB;
var res = { |e| AudioItem.prResolveSourceMap(e, name, 0) };
var srcAt = { |e, bt| AudioItem.prSrcOffset(e, list, b0, 0).(bt) };

"== beatScale tests ==".postln;

cleanup = {
	[TakeArchive.dir(name, 0), AudioItem.folder +/+ name].do { |d|
		(d +/+ "*").pathMatch.do(File.delete(_));
		File.exists(d).if { File.delete(d) };
	};
};
cleanup.();
list = EventList.new; list.beatDur = 1;

sig = Signal.fill(48000 * 4, { 0.001.rand2 });
File.mkdir(AudioItem.folder +/+ name);
sf = SoundFile.new.headerFormat_("WAV").sampleFormat_("float").numChannels_(1).sampleRate_(48000);
sf.openWrite(AudioItem.folder +/+ name +/+ "0.wav"); sf.writeData(sig); sf.close;
TakeArchive.writeMarks(name, 0, srcs.collect { |t, i| [t, i] }, nil);

// ------------------------------------------------------------ the map
assert.(AudioItem.timingKeys.includes(\beatScale), "beatScale is a timing key (routes to follow)");
r = res.((item: name, followTrack: \auto));
assertClose.(r[\srcBeatScale], 1, "no beatScale: scale 1");
r = res.((item: name, followTrack: \auto, beatScale: 0.5));
assert.(r[\srcName] == \marks, "beatScale: the marks still resolve");
assertClose.(r[\srcBeatScale], 0.5, "beatScale: recorded on the resolved event");

// one list beat = two marked beats = 1.0 s of source
assertClose.(srcAt.((item: name, followTrack: \auto), b0 + 1), 0.5, "scale 1: one list beat = one mark (0.5 s)");
off = { |bt| srcAt.((item: name, followTrack: \auto, beatScale: 0.5), bt) };
assertClose.(off.(b0), 0, "scale 0.5: when: is the first mark");
assertClose.(off.(b0 + 1), 1.0, "scale 0.5: one list beat = two marks (1.0 s)");
assertClose.(off.(b0 + 2.5), 2.5, "scale 0.5: 2.5 list beats = all five spans");
off = { |bt| srcAt.((item: name, followTrack: \auto, beatScale: 2), bt) };
assertClose.(off.(b0 + 2), 0.5, "scale 2: two list beats = one mark");

// ------------------------------------------------------------ fromBeat / toBeat stay take beats
off = { |bt| srcAt.((item: name, followTrack: \auto, beatScale: 0.5, fromBeat: 2), bt) };
assertClose.(off.(b0), 1.0, "fromBeat: 2 = mark 2 (1.0 s) at when:, in take beats");
assertClose.(off.(b0 + 1), 2.0, "fromBeat: 2, scale 0.5: next list beat = mark 4");
r = res.((item: name, followTrack: \auto, beatScale: 0.5, fromBeat: 1, toBeat: 5));
assertClose.(r[\dur], 2, "toBeat: 4 take beats at scale 0.5 = 2 list beats");

// prSrcEndBeat inverts prSrcOffset under a scale
endB = AudioItem.prSrcEndBeat((item: name, followTrack: \auto, beatScale: 0.5), list, b0, 0.5, 2.0, 0);
assertClose.(endB, b0 + 1.5, "prSrcEndBeat: 1.5 s of source (three marks) = 1.5 list beats at scale 0.5");

// ------------------------------------------------------------ other sources, refusals
off1 = AudioItem.prSrcOffset((item: name, sourceBeatDur: 0.4, beatScale: 0.5), list, b0, 0);
assertClose.(off1.(b0 + 1), 0.8, "flat source: scale applies (0.4 s beats, two per list beat)");
r = res.((item: name, followTrack: { AnchorMap.fromAnchors([0, 1, 2], [0.5, 1.0, 1.5], fromFrame: \beat, toFrame: \sec) }, beatScale: 0.5));
assert.(r[\srcName] == \function and: { r[\srcBeatScale] == 0.5 }, "function source: scaled");
r = res.((item: name, followTrack: \list, beatScale: 0.5));
assert.(r[\srcBeatScale] == 1 and: { r[\srcMap].isNil }, "list clock: beatScale ignored (warned)");
r = res.((item: name, followTrack: \auto, beatScale: -1));
assert.(r[\srcBeatScale] == 1, "negative beatScale: ignored (warned)");
r = res.((item: name, followTrack: \auto, beatScale: \half));
assert.(r[\srcBeatScale] == 1, "non-number beatScale: ignored (warned)");

cleanup.();
h[\report].();
0.exit;
)
