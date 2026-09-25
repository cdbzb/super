// tempoFollowMode: \notes — the per-note rate plan (onset-gated-tempo-follow.md).
//
// A take marked at irregular file seconds is played on a flat list (1 s/beat) from
// list beat 8. The plan is ONE rate envelope: steps rateLead source-seconds before each
// note start, boundaries rounded to control blocks, each rate from its rounded
// duration — so the integrated source equals the played source span exactly, and each
// step lands (to within half a block) at the wall time of its note start's beat.
//
// Pure language (prNotePlan reads the fixture archive; nothing is sent). No 0.exit, so it
// can run in the live session: bin/sctest standalone-tests/note-plan-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var assertClose = h[\assertClose];
var name = "zzz-note-plan";
var srcs = [0.73, 1.21, 1.74, 2.2, 2.71];
var starts = [0.9, 1.5, 2.3];
var b0 = 8, blk = 64 / 48000, sourceDur = 4.0, lead = 0.05;
var list, cleanup, sf, sig, ev, res, plan, cum, beatOf, wall;

"== note plan tests ==".postln;

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

// noteStarts: an Array source is sorted and chord clusters (40 ms) merge to the earliest
assert.(AudioItem.noteStarts(name, 0, [1.5, 0.9, 1.52, 2.3]) == [0.9, 1.5, 2.3],
	"noteStarts: sorted, 1.5/1.52 merged");
assert.(AudioItem.noteStarts(name, 0, \keyboard).isNil, "noteStarts: \\keyboard with no cache -> nil");

ev = (type: \audioItem, item: name, take: 0, when: b0, sourceTempoMap: \marks, rateLead: lead);
res = AudioItem.prResolveSourceMap(ev, name, 0);
beatOf = { |t| AudioItem.prSrcEndBeat(res, list, b0, res[\start], t, 0) };
wall = { |bt| list.beatToWall(bt, nil) };

plan = AudioItem.prNotePlan(ev, list, nil, starts, b0, nil, sourceDur, blk);
assert.(plan.notNil, "plan built");
assert.(plan[\steps] == 3, "one step per note start (got %)".format(plan[\steps]));
assertClose.(plan[\srcStart], 0.73, "starts at the first mark (trim mode)");
assertClose.(plan[\srcEnd], sourceDur, "runs to the end of the file");
assertClose.((plan[\levels] * plan[\durs]).sum, plan[\srcEnd] - plan[\srcStart],
	"integrated rate == source span (no drift)", 1e-9);
assertClose.(plan[\delay], 0, "from == when: sounds at once");

// step k sits at the wall time of (note start k - lead)'s beat, to within half a block
cum = plan[\durs].integrate;
starts.do { |t, k|
	assertClose.(cum[k], wall.(beatOf.(t - lead)) - wall.(b0),
		"step % at note start % - lead".format(k, t), blk / 2 + 1e-9);
};

// rateLead 0: steps move to the note starts themselves
plan = AudioItem.prNotePlan(ev.copy.put(\rateLead, 0), list, nil, starts, b0, nil, sourceDur, blk);
cum = plan[\durs].integrate;
assertClose.(cum[0], wall.(beatOf.(starts[0])) - wall.(b0), "rateLead 0: step on the note start", blk / 2 + 1e-9);

// noteMinGap in beats: 1.5 and 1.6 (~0.2 beat apart) merge under a 0.5-beat gap
plan = AudioItem.prNotePlan(ev.copy.put(\noteMinGap, 0.5), list, nil, [0.9, 1.5, 1.6, 2.3], b0, nil, sourceDur, blk);
assert.(plan[\steps] == 3, "noteMinGap 0.5: 1.6 merged into 1.5 (got % steps)".format(plan[\steps]));

// mid-list start: nothing before `from`, and the first level starts at from's source position
plan = AudioItem.prNotePlan(ev, list, nil, starts, 10, nil, sourceDur, blk);
assertClose.(plan[\startBeat], 10, "from 10: plan starts at beat 10");
assert.(plan[\steps] == 1, "from 10: only the note start after beat 10 remains (got %)".format(plan[\steps]));
assertClose.(plan[\delay], 0, "from 10: sounds at once");

// routing: tempoFollowMode: \notes alone follows; a bare \env still does not
assert.(list.prIsAudioFollow((type: \audioItem, item: name, tempoFollowMode: \notes)),
	"tempoFollowMode: \\notes routes to the follow path");
assert.(list.prIsAudioFollow((type: \audioItem, item: name, tempoFollowMode: \env)).not,
	"bare tempoFollowMode: \\env unchanged (sealed path)");

// no cached notes -> falls back to the grid builder (many segments, not one synth)
assert.(AudioItem.tempoFollowNoteActions((type: \audioItem, item: name, take: 0, when: b0,
	sourceTempoMap: \marks, notes: \keyboard), list, nil, b0).size > 1,
	"no \\keyboard cache: falls back to the 0.25-beat grid");

cleanup.();
h[\report].();
)
