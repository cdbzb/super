// Headless regression suite for the §12B "throat clearing" intro-drop
// (quantize-tempomap-project.md): MIDIItemPlayer.fromSelection, warpTo's
// dropBefore threshold, and quantize's dropIntro policy. Pure language — the
// fixtures are built with the keyword-array builder, so no server and no disk.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/trim-intro-test.scd
//
// Fixture convention: [midinote:..., dur:...].asMIDIItem stamps timestamps in
// BEATS, which these tests read as seconds — fine here, the maps only care that
// the two axes are consistent.
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var assertClose = { |a, b, msg, tol = 1e-6| h[\assertClose].(a, b, msg, tol) };
var assertArr = { |a, b, msg, tol = 1e-6| h[\assertArr].(a, b, msg, tol) };
var mkPlayer, onsets, stamps, shortenNote, sameArr;
var throws = { |fn| var t = false; try { fn.value } { t = true }; t };
var p, sliced, q, qKeep, plain, noJunk, cc, ccOut, warpedPlain, held, item;
var tm, mono, monoRel, manual, other, otherRel;
var flush, selA, seed, oldFolder;

"== trim intro (§12B) tests ==".postln;

// player from a pitch/dur spec, optionally with a selection stamped on it.
// indices/coords index the NOTES (noteOns), matching a saved selection.
mkPlayer = { |midinotes, durs, indices, coords|
	var pl = [midinote: midinotes, dur: durs].asMIDIItem.player;
	indices !? { pl.markSelection(indices, coords) };
	pl
};
onsets = { |pl| pl.notes.collect(_.timestamp) };
stamps = { |pl| pl.midiEvents.collect(_.timestamp) };
// asMIDIItem lays notes end to end, so a junk note's release lands EXACTLY on the
// next onset. A note occupies [timestamp, timestamp + sustain), so that note is
// already over and does NOT straddle (pinned below) — but a real take has an
// audible gap there, so these fixtures open one by releasing the note early.
shortenNote = { |pl, noteIdx, newSustain|
	var note = pl.notes[noteIdx];
	var off = pl.midiEvents.detect { |e|
		((e.midicmd == \noteOff) and: { e.midinote == note.midinote })
			and: { e.timestamp >= note.timestamp }
	};
	note.sustain = newSustain;
	off !? { off.timestamp = note.timestamp + newSustain };
	pl
};
// exact equality, for the "must be bit-identical" claims (assertClose's strict
// `<` tolerance can never pass with tol 0)
sameArr = { |a, b, msg| h[\assert].((a == b), msg + "(got % want %)".format(a, b)) };

try {

// ---------------------------------------------------------------- fromSelection
// note 0 is junk at t=0 (released at 0.4); the real content starts at note 1 (t=0.5)
p = shortenNote.(mkPlayer.([48, 60, 62, 64, 65], [0.5, 1, 1, 1, 1], [1, 2, 3, 4]), 0, 0.4);
assertClose.(p.notes[0].timestamp, 0, "fixture: junk note at 0");
assertClose.(p.notes[1].timestamp, 0.5, "fixture: content starts at 0.5");

sliced = p.fromSelection;
assert.(sliced.isKindOf(MIDIItemPlayer), "fromSelection: returns a player");
assert.(sliced.notes.size == 4, "fromSelection: junk note dropped (4 notes left)");
assert.(sliced.notes.every { |e| e.midinote != 48 },
	"fromSelection: the junk PITCH is absent from the result");
assert.(sliced.midiEvents.every { |e| e.midinote != 48 },
	"fromSelection: junk noteOn AND noteOff are absent from the events");
assertArr.(onsets.(sliced), [0, 1, 2, 3], "fromSelection: content rebased to 0");
assertClose.(sliced.midiEvents.collect(_.timestamp).minItem, 0,
	"fromSelection: no event lands before 0");

// markers ride the slice, so the sliced player still knows its selection
assert.(sliced.selectedNotes.size == 4, "fromSelection: \\selBeat markers survive");
assertClose.(sliced.selectedNotes.first.timestamp, 0,
	"fromSelection: first selected note is now the start");

// trim: false keeps the same note set (nothing straddles here) but is accepted
assert.(p.fromSelection(false).notes.size == 4, "fromSelection(false): still drops the junk");

// Pinned inherited semantics: fromSelection IS `from`, so a junk note still
// SOUNDING at the content start is not deleted — it is clipped to the start,
// exactly like any other slice (dropping it would cut off audible sound).
// Only notes that finished before the content start disappear.
held = shortenNote.(mkPlayer.([48, 60, 62, 64, 65], [0.5, 1, 1, 1, 1], [1, 2, 3, 4]), 0, 0.9);
sliced = held.fromSelection;
assert.(sliced.notes.size == 5, "straddler: a junk note held past the start is kept");
assertClose.(sliced.notes.first.timestamp, 0, "straddler: clipped to the content start");
assertClose.(sliced.notes.first.sustain, 0.4, "straddler: sustain clipped by the removed head");

// The boundary itself: a note RELEASED exactly at the content start is over, not
// straddling — occupancy is half-open [timestamp, timestamp + sustain), matching
// onsets/beatTimes' [from, to) windows. When the release end was >=, `from` took
// it as a straddler and clipped it to sustain 0: a silent ghost noteOn at the
// slice start. asMIDIItem lays notes end to end, so this fixture IS that edge.
p = mkPlayer.([48, 60, 62, 64, 65], [0.5, 1, 1, 1, 1], [1, 2, 3, 4]);
assertClose.(p.notes[0].timestamp + p.notes[0].sustain, 0.5,
	"boundary fixture: the junk note is released exactly at the content start");
assert.(p.notesStraddling(0.5).size == 0,
	"notesStraddling: a note released exactly at the boundary is NOT straddling");
assert.(p.notesStraddling(0.4).size == 1,
	"notesStraddling: a note still sounding at the boundary IS straddling");
sliced = p.fromSelection;
assert.(sliced.notes.size == 4, "boundary: no ghost note at the slice start");
assert.(sliced.notes.every { |e| e.sustain > 0 }, "boundary: no zero-sustain ghost survives");
assert.(sliced.notes.every { |e| e.midinote != 48 }, "boundary: the junk pitch is really gone");

// legacy index-based selection (no \selBeat markers) resolves the same start
p = shortenNote.(mkPlayer.([48, 60, 62, 64, 65], [0.5, 1, 1, 1, 1]), 0, 0.4);
p.currentSelection = (indices: [1, 2, 3, 4], beats: [1, 1, 1]);
assertArr.(onsets.(p.fromSelection), [0, 1, 2, 3],
	"fromSelection: falls back to currentSelection[\\indices]");

// no selection at all: warn and hand back the receiver untouched
p = mkPlayer.([60, 62, 64], 1);
"  (expect one 'needs a loaded selection' warning next)".postln;
assert.(p.fromSelection === p, "fromSelection: no selection -> returns the receiver");
assert.(p.notes.size == 3, "fromSelection: no selection -> receiver unchanged");

// ------------------------------------------------------- quantize dropIntro
// A sloppy take: junk at 0, then 4 notes whose performed gaps wobble
// (0.8 / 1.3 / 0.9) but which are meant to be 4 even beats.
p = mkPlayer.([48, 60, 62, 64, 65], [0.6, 0.8, 1.3, 0.9, 1], [1, 2, 3, 4]);
assertArr.(onsets.(p), [0, 0.6, 1.4, 2.7, 3.6], "fixture: performed onsets");

q = p.quantize;                    // dropIntro defaults to true
assert.(q.notes.size == 4, "quantize: junk note dropped by default");
assert.(q.notes.every { |e| e.midinote != 48 }, "quantize: the junk pitch is gone");
// anchors land on the ideal grid; t0 (0.6) is preserved as the placement origin
assertArr.(onsets.(q), [0.6, 1.6, 2.6, 3.6], "quantize: content on ideal beats");
assert.(q.midiEvents.every { |e| e.timestamp >= (0.6 - 1e-9) },
	"quantize: nothing survives before the first anchor");

qKeep = p.quantize(dropIntro: false);   // old behaviour
assert.(qKeep.notes.size == 5, "quantize(dropIntro: false): junk note kept");
assert.(qKeep.notes.first.midinote == 48, "quantize(dropIntro: false): junk is note 0");
assert.(qKeep.notes.first.timestamp < 0.6,
	"quantize(dropIntro: false): junk extrapolated BEFORE the first anchor (got %)"
		.format(qKeep.notes.first.timestamp.round(1e-6)));
// the kept anchors are identical either way — dropping changes nothing downstream
assertArr.(onsets.(qKeep).drop(1), onsets.(q), "quantize: kept notes identical either way");

// A MIDIItem receiver reaches warpTo through doesNotUnderstand — check the new
// second argument survives that hop (kwargs don't bind to ...rest, so it's positional).
// NB: mark the ITEM's own events — MIDIItem.notes/.player hand back a fresh deepCopy
// each call, so markSelection on `item.player` would stamp a throwaway.
item = [midinote: [48, 60, 62, 64, 65], dur: [0.6, 0.8, 1.3, 0.9, 1]].asMIDIItem;
item.midiEvents.select { |e| e.midicmd == \noteOn }.drop(1).do { |e, i| e[\selBeat] = i };
assert.(item.selectedNotes.size == 4, "MIDIItem receiver: selection stamped on the item");
q = item.quantize;
assert.(q.notes.size == 4, "MIDIItem receiver: dropIntro reaches warpTo via dnu");
assert.(item.quantize(dropIntro: false).notes.size == 5,
	"MIDIItem receiver: dropIntro false still keeps the junk");

// --------------------------------------------------- behaviour compatibility
// No junk before the first anchor => dropIntro true/false are bit-identical.
noJunk = mkPlayer.([60, 62, 64, 65], [0.8, 1.3, 0.9, 1], [0, 1, 2, 3]);
sameArr.(onsets.(noJunk.quantize), onsets.(noJunk.quantize(dropIntro: false)),
	"no-junk take: dropIntro true == false (note onsets)");
sameArr.(stamps.(noJunk.quantize), stamps.(noJunk.quantize(dropIntro: false)),
	"no-junk take: dropIntro true == false (ALL event timestamps)");
assert.(noJunk.quantize.midiEvents.size == noJunk.quantize(dropIntro: false).midiEvents.size,
	"no-junk take: same event count either way");

// ------------------------------------------------------- warpTo CC clamping
// A CC set during the junk intro must survive: it is the controller state the
// content begins in. It lands exactly ON the threshold, like chaseCCs does.
p = mkPlayer.([48, 60, 62, 64, 65], [0.6, 0.8, 1.3, 0.9, 1], [1, 2, 3, 4]);
p.midiEvents.add((midicmd: \control, type: \cc, ctlNum: 64, val: 127, timestamp: 0.1));
p.midiEvents.sort { |a, b| a.timestamp < b.timestamp };

ccOut = p.quantize;                       // dropBefore == t0 == 0.6
cc = ccOut.midiEvents.select { |e| e.midicmd == \control };
assert.(cc.size == 1, "warpTo/dropBefore: the intro CC survives");
assertClose.(cc.first.timestamp, 0.6,
	"warpTo/dropBefore: intro CC clamped to the threshold");
assert.(cc.first.val == 127, "warpTo/dropBefore: CC value untouched");
assert.(ccOut.notes.size == 4, "warpTo/dropBefore: notes still dropped alongside");

// same map, no threshold: the CC is extrapolated backwards instead
warpedPlain = p.warpTo(p.tempomap);
cc = warpedPlain.midiEvents.select { |e| e.midicmd == \control };
assert.(cc.first.timestamp < 0.6,
	"warpTo (no dropBefore): intro CC extrapolated below the first anchor");
assert.(warpedPlain.notes.size == 5, "warpTo (no dropBefore): junk note kept");

// notes exactly AT the first anchor are kept (strict <)
p = mkPlayer.([60, 62, 64, 65], [1, 1, 1, 1], [0, 1, 2, 3]);
plain = p.warpTo(p.tempomap, p.tempomap.t0);
assert.(plain.notes.size == 4, "dropBefore: note AT the threshold is kept (strict <)");

// ------------------------------------------------- §12 seam: warpTo(MonoMap)
// A V2 core map is converted at the seam; the walk below it is untouched, so the
// result must equal warping through the AnchorTempoMap that conversion produces.
p = mkPlayer.([48, 60, 62, 64, 65], [0.6, 0.8, 1.3, 0.9, 1], [1, 2, 3, 4]);
tm = p.tempomap;
mono = tm.asMonoMap(origin: \absolute);            // beat -> ABSOLUTE take seconds
manual = AnchorTempoMap(tm.times + tm.t0, [0] ++ tm.beats.integrate);
assert.(mono.mapsDimensions(\beat, \sec), "fixture: the MonoMap really is beat -> sec");
sameArr.(stamps.(p.warpTo(mono)), stamps.(p.warpTo(manual)),
	"warpTo(MonoMap) is bit-identical to warpTo(the hand-converted AnchorTempoMap)");
assertArr.(stamps.(p.warpTo(mono)), stamps.(p.warpTo(tm)),
	"and agrees with warping through the source MIDIItemTempoMap itself");
// dropBefore keeps working through the converted map
q = p.warpTo(mono, tm.t0);
assert.(q.notes.size == 4, "dropBefore: junk note still dropped through the MonoMap path");
assert.(q.midiEvents.every { |e| e.timestamp >= (tm.t0 - 1e-9) },
	"dropBefore: nothing survives before the threshold through the MonoMap path");
sameArr.(stamps.(p.warpTo(mono, tm.t0)), stamps.(p.warpTo(manual, tm.t0)),
	"dropBefore: MonoMap path bit-identical to the hand-converted map");

// A map snapshotted with origin: \relative measures seconds from its OWN first
// anchor. Warping absolute timestamps through it would subtract t0 twice, so the
// seam refuses it — recognized by the take's registered relative seconds frame.
monoRel = tm.asMonoMap(origin: \relative);
assert.(throws.({ p.warpTo(monoRel) }),
	"warpTo refuses a map built with origin: \\relative (t0 would be subtracted twice)");
assert.(throws.({ p.warpTo(monoRel, tm.t0) }),
	"the relative refusal does not depend on dropBefore");
// ...but only for THIS take: a relative map off other events is foreign, and a
// foreign map is trusted (player identity is not stable across deepCopy hops, so
// a mismatch must never become a false error).
other = mkPlayer.([60, 62, 64, 65], [1, 1, 1, 1], [0, 1, 2, 3]);
otherRel = other.tempomap.asMonoMap(origin: \relative);
assert.(throws.({ p.warpTo(otherRel) }).not,
	"a map off ANOTHER take is foreign — trusted, not refused");
assert.(throws.({ p.warpTo(mono) }).not,
	"the absolute map is still accepted after a relative one exists for the take");

// ------------------------------------ selection versioning (addSelection \manual)
// Parked in this suite for want of one covering MIDIItem selection persistence.
// \manual is the hand-picked/grid-picked partition of \indices and the gui cannot
// recover it from \indices on reload, so two saves differing only there are two
// selections — it belongs in addSelection's dedupe key set.
//
// No disk: the dedupe branch returns before this.save, and for the append branch
// MIDIItem.folder is nil'd so save raises (on `nil +/+ name`) BEFORE any file
// operation. The version list is appended to before save is called, so what is
// asserted — that the save was not treated as a duplicate — still holds.
item = [midinote: [60, 62, 64, 65], dur: 1].asMIDIItem;
seed = { |sel| var d = Dictionary.new; d[0] = List[sel]; item.instVarPut(\beatSelections, d) };
flush = { |sel| try { item.addSelection(0, sel) } { } };   // swallows the save raise

selA = (indices: [0, 1, 2], beats: [1, 1], manual: [0, 1]);
seed.(selA);
oldFolder = MIDIItem.folder;
MIDIItem.folder = nil;   // no suite run may write into the real MIDI-items folder
assert.(item.addSelection(0, (indices: [0, 1, 2], beats: [1, 1], manual: [0, 1])).isString,
	"addSelection: an identical save (\\manual included) still dedupes");
assert.(item.selections(0).size == 1, "addSelection: the dedupe appended nothing");
flush.((indices: [0, 1, 2], beats: [1, 1], manual: [0, 2]));
assert.(item.selections(0).size == 2,
	"addSelection: same notes, different \\manual set -> a new version");
// legacy saves carry no \manual at all: nil vs nil must still dedupe
seed.((indices: [0, 1, 2], beats: [1, 1]));
assert.(item.addSelection(0, (indices: [0, 1, 2], beats: [1, 1])).isString,
	"addSelection: legacy saves with no \\manual dedupe (nil vs nil)");
assert.(item.selections(0).size == 1, "addSelection: the legacy dedupe appended nothing");
// ...but gaining one is a real edit
flush.((indices: [0, 1, 2], beats: [1, 1], manual: [0, 1]));
assert.(item.selections(0).size == 2,
	"addSelection: nil vs a \\manual set -> a new version");
MIDIItem.folder = oldFolder;

} { |err|
	("UNCAUGHT: " ++ err.errorString).postln;
	err.throw;
};

(h[\report].() == 0).if { 0.exit } { 1.exit };
)
