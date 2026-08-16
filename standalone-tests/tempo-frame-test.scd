// The beat frame travels with the container, not with the notes: a
// tempoMapOverride slot on MIDIItemPlayer, carried through filters by
// copyBounds, cleared by anything that rewrites timestamps.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/tempo-frame-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert], assertClose = h[\assertClose], assertArr = h[\assertArr];
var throws = { |fn| var t = false; try { fn.value } { t = true }; t };

// a synthetic take: 8 notes a second apart, alternating registers so a pitch
// filter can decimate the anchors exactly as it did on the real item
var mk = {
	var evs = (0 .. 7).collect { |i|
		(midicmd: \noteOn, type: \noteOn, midinote: (i.even).if { 48 + i }{ 72 + i },
			timestamp: i * 1.0, sustain: 0.5, dur: 0.5, amp: 0.5, chan: 0, velocity: 64)
	};
	MIDIItemPlayer(evs, nil)
};
// mark every note as an anchor, one beat apart
var marked = { |p| p.markSelection((0 .. 7), (0 .. 7)) };

var p, low, warped, borrowed, base, one;

"---- the slot exists and answers before the derivation ----".postln;
p = marked.(mk.());
assert.(p.tempomap.isKindOf(MIDIItemTempoMap), "a marked player derives a map");
assert.(p.tempoMapOverride.isNil, "markSelection alone does not pin one");
base = p.tempomap;
p.tempoMap_(base);
assert.(p.tempoMapOverride === base, "tempoMap_ stores it");
assert.(p.tempomap === base, "and tempomap answers it without re-deriving");
assert.(p.tempoMap_(nil).tempoMapOverride.isNil, "nil clears it");

"---- an override answers only the UNPARAMETERISED question ----".postln;
p = marked.(mk.()).tempoMap_(base);
assert.(p.tempomap(beats: [2, 2, 2, 2, 2, 2, 2, 2]) !== base,
	"passing beats still derives — that is a different question");
assert.(p.tempomap !== nil, "and the no-arg call still answers the override");

"---- the frame survives a filter that decimates the anchors ----".postln;
// without the slot: filtering to the high register leaves 4 anchors here, and
// on a real take with 6 saved anchors it left ONE
p = marked.(mk.());
low = p.select { |e| e.midinote < 60 };
assert.(low.tempoMapOverride.isNil,
	"an unpinned player passes nothing down the filter chain");
p = marked.(mk.()).tempoMap_(base);
low = p.select { |e| e.midinote < 60 };
assert.(low.tempoMapOverride === base, "a pinned one hands the frame to the filtered player");
assert.(low.tempomap === base, "so the filtered player reports the SAME map");
assert.(low.selectedNotes.size < p.selectedNotes.size,
	"...even though it kept fewer anchors");
// and down a longer chain
assert.(p.select { |e| e.midinote < 60 }.filter(key: \midinote, func: _ - 12)
	.tempoMapOverride === base, "through select + filter");

"---- rewriting timestamps drops it ----".postln;
p = marked.(mk.()).tempoMap_(base);
warped = p.warpTo(base);
assert.(warped.tempoMapOverride.isNil,
	"warpTo clears the frame — the times it was keyed to are gone");
assert.(warped.selectedNotes.size == 8,
	"...and the markers survive, so the fallback derivation is still right");

"---- beatScale and closingAnchor ride along too ----".postln;
p = marked.(mk.());
p.beatScale = 2;
p.closingAnchor = (time: 9.0, beats: 1);
low = p.select { |e| e.midinote < 60 };
assert.(low.beatScale == 2, "beatScale survives a filter (it did not before)");
assert.(low.closingAnchor.notNil, "closingAnchor survives a filter");

"---- guards and warnings ----".postln;
assert.(throws.({ marked.(mk.()).tempoMap_(42) }),
	"tempoMap_ refuses something that is not a tempo map");
// a MonoMap is coerced, keeping t0 absolute (rebase: false)
p = marked.(mk.());
borrowed = p.tempomap.asMonoMap;
p.tempoMap_(borrowed);
assert.(p.tempoMapOverride.isKindOf(AnchorTempoMap), "a MonoMap is coerced to AnchorTempoMap");
assert.(p.tempoMapOverride.respondsTo(\prAtExtrapolated), "and answers the protocol");
// one anchor still builds a map, but no longer silently
one = mk.().markSelection([3], [0]);
assert.(one.selectedNotes.size == 1, "a single marked anchor is reachable");
assert.(one.tempomap.notNil, "it still answers a map (deliberate single-beat use)");

h[\report].();
"SUITE-DONE".postln;
)
