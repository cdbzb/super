// A list clock's t0 rides on its map: MapFrame(\sec, <Number>) origin.
// EventList.tempoMap_ stamps t0 into the stored map's seconds frame and reads
// a Number origin back on the way in, so handing one list's clock to another
// (copy, slice, edit, ++) keeps its place in recorded time, and a list clock
// used as an \mi2 source map (sourceTempoMap: t, t = e.tempoMap.copy) places
// the take where followTrack: \marks does. Pure language.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/map-origin-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert], assertClose = h[\assertClose], assertArr = h[\assertArr];
var throws = { |fn| var t = false; try { fn.value } { t = true }; t };
var abs, src, dst, m, cat, eased, other, probes, mkNote, notes, mkPlayer, mt, list, timesFor,
	tMarks, tCopy, tSlice, mOff, fr;

"== map origin (list t0 on the seconds frame) ==".postln;

// ---------------------------------------------------------------- MapFrame
fr = MapFrame(\sec, 2.5);
assert.(fr.isOffset and: { fr.isRelative.not }, "a Number origin is an offset, not \\relative");
assert.(MapFrame(\sec, \relative).isOffset.not, "\\relative is not an offset");
assertClose.(fr.shiftedBy(1.5).origin, 4, "shiftedBy moves a Number origin");
assert.(MapFrame(\sec, \absolute).shiftedBy(3) == MapFrame(\sec, \absolute),
	"shiftedBy leaves a Symbol origin alone");
assert.(throws.({ MapFrame(\sec, \wall) }), "unknown Symbol origins are still refused");
assert.(fr.unifies(MapFrame(\sec, \absolute)), "offset frames still compose by dimension");

// ---------------------------------------------------------------- tempoMap_
// take-absolute clock: beats 0..4 at seconds 10, 11, 13, 14, 16
abs = AnchorMap([0, 1, 2, 3, 4], [10, 11, 13, 14, 16], \beat, MapFrame(\sec, \absolute));
src = EventList.new;
src.tempoMap = abs;
assertClose.(src.t0, 10, "an absolute map's first second becomes t0");
assertClose.(src.tempoMap.ys.first, 0, "the stored clock is still normalized");
assertClose.(src.tempoMap.secOrigin, 10, "the stored clock carries t0 as its origin");

dst = EventList.new;
dst.tempoMap = src.tempoMap;
assertClose.(dst.t0, 10, "assigning another list's clock keeps its t0");
dst.tempoMap = src.tempoMap.copy;
assertClose.(dst.t0, 10, "a copy of a list's clock keeps its t0");
dst.tempoMap = src.tempoMap.deepCopy;
assertClose.(dst.t0, 10, "a deepCopy keeps it too");

dst.tempoMap = src.tempoMap.fromBeat(2);
assertClose.(dst.t0, 13, "a slice from beat 2 lands t0 at that beat's take time");
assertClose.(dst.tempoMap.timeAt(1), 1, "the slice's shape starts at its own beat 0");
dst.tempoMap = src.tempoMap.fromBeat(1, 3);
assertClose.(dst.t0, 11, "a bounded slice starts at its first beat's take time");
dst.tempoMap = src.tempoMap.slices([2]).last;
assertClose.(dst.t0, 13, "slices keep the origin");

dst.tempoMap = src.tempoMap.setTempo(1.2);
assertClose.(dst.t0, 10, "an edited copy (setTempo) keeps t0");
dst.tempoMap = src.tempoMap.quantizeWindow(0.4);
assertClose.(dst.t0, 10, "quantizeWindow keeps t0");
dst.tempoMap = src.tempoMap.scaleTempo(2);
assertClose.(dst.t0, 10, "scaleTempo keeps t0");

// edits in place go through prMapEdit
dst.tempoMap = src.tempoMap;
dst.setTempo(1.2);
assertClose.(dst.t0, 10, "list.setTempo keeps t0");
assertClose.(dst.tempoMap.secOrigin, 10, "... and the getter's map still carries it");
dst.quantizeWindow(0.5);
assertClose.(dst.tempoMap.secOrigin, 10, "list.quantizeWindow keeps the stamped origin");

// ++ : MapSeq lays cells out from 0, the origin follows the first piece
other = AnchorMap([0, 2], [0, 2], \beat, \sec);
cat = src.tempoMap.fromBeat(2) ++ other;
assertClose.(cat.bake.ys.first, 0, "MapSeq rebases the concatenation to 0");
assertClose.(cat.secOrigin, 13, "++ moves the origin by the first piece's start");
dst.tempoMap = cat;
assertClose.(dst.t0, 13, "a list clock built with ++ keeps the first piece's take time");
dst.tempoMap = [src.tempoMap.fromBeat(2), other];
assertClose.(dst.t0, 13, "an Array clock (reduced with ++) does too");

eased = src.tempoMap.fromBeat(0, 3).easeTo(other, 1, 0);
dst.tempoMap = eased;
assertClose.(dst.t0, 10, "easeTo keeps this map's origin");

// hand-built and relative maps: unchanged behaviour
dst.tempoMap = AnchorMap([0, 4], [0, 5], \beat, \sec);
assertClose.(dst.t0, 0, "a hand-built map (no origin) starts at its own y0");
dst.tempoMap = AnchorMap([0, 4], [3, 8], \beat, \sec);
assertClose.(dst.t0, 3, "... including a nonzero y0");
dst.tempoMap = AnchorMap([0, 4], [0, 5], \beat, MapFrame(\sec, \relative));
assertClose.(dst.t0, 0, "a \\relative map carries no offset");

// prSetT0 restamps the frame
dst.tempoMap = src.tempoMap;
dst.prSetT0(4.5);
assertClose.(dst.tempoMap.secOrigin, 4.5, "prSetT0 restamps the getter's origin");
assertClose.(dst.t0, 4.5, "prSetT0 sets t0");

// copyFrom (EventList.copy) carries both
dst.tempoMap = src.tempoMap;
m = dst.copy;
assertClose.(m.t0, 10, "EventList.copy keeps t0");
assertClose.(m.tempoMap.secOrigin, 10, "EventList.copy keeps the stamped origin");

// ---------------------------------------------------------------- asAbsolute
probes = [0, 0.5, 1, 2.25, 4, 5];
assertArr.(probes.collect { |b| src.tempoMap.asAbsolute.timeAt(b) }, probes.collect { |b| abs.timeAt(b) },
	"asAbsolute adds the origin back: take time again", 1e-9);
assert.(src.tempoMap.asAbsolute.toFrame.origin == \absolute, "asAbsolute marks the axis \\absolute");
assertArr.([10, 12, 15].collect { |t| src.tempoMap.inverse.asAbsolute.beatAt(t) },
	[10, 12, 15].collect { |t| abs.beatAt(t) }, "asAbsolute on a sec -> beat map", 1e-9);
assert.(abs.asAbsolute === abs, "an \\absolute map is its own asAbsolute");
mOff = AnchorMap([0, 4], [0, 5], \beat, MapFrame(\sec, \relative));
assert.(mOff.asAbsolute === mOff, "a \\relative map has no offset to add");

// ---------------------------------------------------------------- \mi2 follow
// The 2026-10-31 harp: a list clock copied into `t` and passed as
// sourceTempoMap: t played the take ~1 s late — the copy had lost t0, so the
// follower fell back to player.start. Notes from recorded second 2: the
// player's own map (t0 2) and a copy of the list clock must place them alike.
mkNote = { |ts, note = 60| (midicmd: \noteOn, type: \mk, timestamp: ts,
	midinote: note, dur: 0.5, sustain: 0.5, amp: 0.5) };
notes = [2, 3, 4, 5, 8, 9].collect { |ts| mkNote.(ts) };
mkPlayer = { MIDIItemPlayer(notes.deepCopy, nil) };
mt = MIDIItemTempoMap(mkPlayer.(), { |n| n[0..4] }, [1, 1, 1, 1, 1]);
assertClose.(mt.t0, 2, "fixture: the take map starts at recorded second 2");
list = EventList.new;
list.tempoMap = mt;
assertClose.(list.t0, 2, "fixture: the list's t0 is the take map's");
timesFor = { |ev| var l = EventList.new; l.tempoMap = mt; l.events.add(ev);
	l.prepare(100, 0).collect { |i| i[\time] }.asArray.sort };
tMarks = timesFor.((when: 0, type: \mi2, player: mkPlayer.().tempoMap_(mt), followTrack: \marks));
tCopy = timesFor.((when: 0, type: \mi2, player: mkPlayer.().tempoMap_(mt),
	sourceTempoMap: list.tempoMap.copy));
assert.(tMarks.size == 6, "mi2: all 6 notes scheduled (got %)".format(tMarks.size));
assertArr.(tCopy, tMarks, "mi2: a copied list clock places the take like followTrack: \\marks", 1e-6);
tSlice = timesFor.((when: 0, type: \mi2, player: mkPlayer.().tempoMap_(mt),
	followTrack: list.tempoMap));
assertArr.(tSlice, tMarks, "mi2: followTrack: <list clock> places it the same", 1e-6);

// ---------------------------------------------------------------- warpTo
// a list clock now names its take time: warpTo through it == through the take map
assertArr.(mkPlayer.().warpTo(list.tempoMap).midiEvents.collect(_.timestamp),
	mkPlayer.().warpTo(mt).midiEvents.collect(_.timestamp),
	"warpTo through a list clock == through the take map it was built from", 1e-6);

h[\report].();
)
