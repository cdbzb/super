// align: on audio events — quantize strength (audio-beat-marking-plan.md step 9).
//
// A take marked at irregular file seconds is played on a flat list (1 s/beat)
// from list beat 8. Each segment node is a source beat; its wall time must be
//   align 1: its list beat's wall time            (every beat on the grid)
//   align 0: anchor + its performed offset        (as played)
//   between: the blend of the two
// — the same sense as prExpandBlended's align on nested lists. A mid-list start
// bisects the source beat whose blended time is the start's wall time.
//
// Pure language (the builder reads the fixture file but sends nothing).
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/align-audio-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var assertClose = h[\assertClose];
var name = "zzz-align-audio";
var srcs = [0.73, 1.21, 1.74, 2.2, 2.71];
var b0 = 8, list, cleanup, sf, sig, nodes, ev, a, added;

"== align: on audio tests ==".postln;

cleanup = {
	[TakeArchive.dir(name, 0), AudioItem.folder +/+ name].do { |d|
		(d +/+ "*").pathMatch.do(File.delete(_));
		File.exists(d).if { File.delete(d) };
	};
	AudioItem.recordedMaps.removeAt(name.asSymbol, 0);
};
cleanup.();
File.mkdir(AudioItem.folder +/+ name);
sig = Signal.fill(48000 * 4, { 0.001.rand2 });
sf = SoundFile.new.headerFormat_("WAV").sampleFormat_("float").numChannels_(1).sampleRate_(48000);
sf.openWrite(AudioItem.folder +/+ name +/+ "0.wav"); sf.writeData(sig); sf.close;
TakeArchive.writeMarks(name, 0, srcs.collect { |t, i| [t, i] }, nil);
list = EventList.new; list.beatDur = 1;

// segment node wall times (delays from list beat `from`'s wall time), one per 0.25 beat
nodes = { |align, from = 0|
	ev = (item: name, take: 0, when: b0, start: 0, sourceTempoMap: \marks, type: \audioItem);
	align !? { ev[\align] = align };
	AudioItem.tempoFollowActions(ev, list, nil, from).collect(_[0])
};

// node k is source beat k/4; node 4 = marked beat 1, node 8 = marked beat 2
a = nodes.(nil);
assertClose.(a[4], 9, "no align: marked beat 1 on list beat 9 (plain follow)");
a = nodes.(1);
assertClose.(a[4], 9, "align 1: marked beat 1 on list beat 9");
assertClose.(a[8], 10, "align 1: marked beat 2 on list beat 10");
a = nodes.(0);
assertClose.(a[4], 8 + (srcs[1] - srcs[0]), "align 0: marked beat 1 as performed (8 + 0.48)");
assertClose.(a[8], 8 + (srcs[2] - srcs[0]), "align 0: marked beat 2 as performed (8 + 1.01)");
a = nodes.(0.5);
assertClose.(a[4], (9 + 8.48) / 2, "align 0.5: halfway between performed and grid");
assertClose.(a[0], 8, "align 0.5: the anchor (first mark) stays on when:");

// mid-list start at list beat 9 with align 0: the source beat whose performed time
// is wall 9 is where src = 0.73 + 1 = 1.73 — between marks 1 and 2:
// beat 1 + 0.52/0.53. Its first node sounds at once, the next 0.25 beat later
// at 8 + (src(that + 0.25) - 0.73).
a = nodes.(0, 9);
assertClose.(a[0], 0, "align 0, from 9: sounds at once", 1e-6);
assertClose.(a[1], (8 + (srcs[2] + ((1 + (0.52 / 0.53) + 0.25 - 2) * 0.46) - srcs[0])) - 9,
	"align 0, from 9: the start was bisected in blended time", 1e-6);

// addItem forwards align: and it implies following
added = list.addItem(Take(name, 0), at: b0, sourceTempoMap: \marks, align: 0.6).first;
assert.(added[\align] == 0.6, "addItem: align: goes into the event");
assert.(list.prIsAudioFollow((type: \audioItem, item: name, align: 0.5)),
	"align: alone routes \\audioItem to the follow path");

cleanup.();
h[\report].();
0.exit;
)
