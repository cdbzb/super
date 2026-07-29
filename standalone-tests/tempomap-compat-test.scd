// Headless COMPATIBILITY suite for TempoMap — pins the song-facing behavior of
// the class as it stands before an internal rebuild.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/tempomap-compat-test.scd
//
// Scope note: this suite asserts CURRENT OBSERVED behavior, warts included.
// The contract it protects is "the Trek/Songs corpus keeps working", NOT
// "the behavior is correct". Several checks below deliberately pin asymmetries
// and degenerate outputs (marked WART). Do not "fix" them here — change the
// class first, then change the pin.
//
// Companion suite: tempomap-test.scd (invariants + M0 bug fixes).
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var assertClose = { |a, b, msg, tol = 1e-6| h[\assertClose].(a, b, msg, tol) };
var assertArr = { |a, b, msg, tol = 1e-6| h[\assertArr].(a, b, msg, tol) };
var t, r, d, warped;

"== TempoMap compatibility (pre-rebuild pin) ==".postln;

// wrap so an unexpected throw still reaches 0.exit (never leave a live sclang).
try {

// ------------------------------------------------ 1. construction / defaults
// WART: *new defaults are 7 beats and 8 durs, so the size-mismatch guard in
// init fires on the DEFAULT construction and trims both to (min - 1) = 7.
t = TempoMap.new;
assertArr.(t.durs, 1 ! 7, "TempoMap.new: defaults trim to 7 unit durs");
// WART: mismatched sizes trim to min(sizes)-1 as an INDEX, i.e. one element
// shorter than the shorter input would allow.
t = TempoMap([1,1,1], [1,2,3,4,5]);
assertArr.(t.durs, [1,2,3], "init: mismatch trims durs to the same extent");

// TempoMap.from(array) does NOT exist -> "Message 'from' not understood".
// The constructor songs actually use is *fromB (one unit beat per dur).
// *fromDurs is also SKIPPED: `TempoMap.fromDurs(Pseq([1,2,3],1))` throws
//   ERROR: Message 'array' not understood.   (dur.list.array — the Pseq's list
// is an Array, which has no `array`), so it is dead for its documented input.
r = TempoMap.fromB([1,2,3]);
assertArr.(r.beats, [1,1,1], "TempoMap.fromB: one beat per element");
assertArr.(r.durs, [1,2,3], "TempoMap.fromB: durs are the supplied array");

// ------------------------------------------------------- 2. concrete accessors
t = TempoMap([1,2,3], [4,5,6]);
assertArr.(t.beats, [1,2,3], ".beats returns the array given");
assertArr.(t.durs, [4,5,6], ".durs returns the array given");

// ------------------------------------------- 3. scalar mapping .at + clamping
// A jittery performance: ideal beats all 1, performed durs wobble.
t = TempoMap([1,1,1,1,1,1], [1,2,1,3,1,2]);
assertClose.(t.at(0), 0, "at(0) == 0");
assertClose.(t.at(6), 10.0, "at(total beats) == total durs");
// WART (self-documented as `extrapolation == \clamp`): outside the anchor
// range the underlying Env CLAMPS in both directions — it does not extrapolate
// the edge tempo, so out-of-range beats all collapse onto the endpoints.
assertClose.(t.at(-5), 0.0, "at() clamps below the domain to 0");
assertClose.(t.at(100), 10.0, "at() clamps above the domain to total durs");

// --------------------------------------------------------- 4. .mapBeats
assertArr.(t.mapBeats(1 ! 6), [1,2,1,3,1,2], "mapBeats: unit grid reproduces durs");
// non-positive spans clamp to 1e-9 instead of being .select-dropped (2026-07
// fix): dropping desynced a Pbind's \dur from its \midinote.
warped = TempoMap([1,1,1],[1,1,1]).mapBeats([1,0,1]);
assert.(warped.size == 3, "mapBeats: zero span keeps array length");
assertClose.(warped[1], 1e-9, "mapBeats: zero span clamped to exactly 1e-9", 1e-15);
// WART: because at() clamps, spans running past the beat domain collapse to 1e-9.
assertArr.(t.mapBeats([2,2,2,2]), [3.0, 4.0, 3.0, 1e-9],
	"mapBeats: span past the domain end collapses to 1e-9");

// --------------------------------------- 5. Array warpTo dispatch (plusArray)
// warpTo sees a TempoMap and forwards to warpToTempoMap -> tempoMap.mapBeats.
assertArr.([1,1,1,1,1,1].warpTo(t), [1,2,1,3,1,2], "warpTo(TempoMap): == mapBeats");
assert.([1,1].warpTo(nil) == [1,1], "warpTo(nil): returns the receiver unchanged");
// WART: a plain Array argument takes the OTHER branch (warpToArray —
// atInterpolated over a padded quarters array). Same selector, different
// algorithm; only the TempoMap branch is tempo-map dispatch.
assert.([1,0,1].warpTo([1,1,1,1]).size == 3, "warpTo(Array): length preserved");

// ----------------------------------------------- 6. quantize(amount) scalar
t = TempoMap([1,1,1,1,1,1], [1,2,3,4,5,6]);   // mean 3.5 seconds per beat
assertArr.(t.quantize(0).durs, [1,2,3,4,5,6], "quantize(0): identity on durs");
r = t.quantize(1);
assertArr.(r.durs, 3.5 ! 6, "quantize(1): rigid mean tempo");
assert.(r.isKindOf(TempoMap), "quantize: returns a TempoMap");
assertArr.(t.durs, [1,2,3,4,5,6], "quantize: original left unmutated");

// ------------------------------- 7. quantize(amount, start, end) / quantizeRange
// Indices start..end INCLUSIVE get the range mean; nothing else is touched.
assertArr.(t.quantize(1, 2, 4).durs, [1,2,4,4,4,6],
	"quantize(1,2,4): writes indices 2..4 inclusive");
// WART: `end` defaults to durs.size-1 (the last index, inclusive), so a
// two-argument call quantizes all the way to the end of the map.
assertArr.(t.quantize(1, 2).durs, [1,2,4.5,4.5,4.5,4.5],
	"quantize(1,2): end defaults to the last index (inclusive)");
// WART: quantizeRange returns a bare durs ARRAY covering only the range —
// not a TempoMap, and not the full-length durs.
d = t.quantizeRange(1, [2,4]);
assert.(d.isKindOf(Array) and: { d.isKindOf(TempoMap).not },
	"quantizeRange: returns a plain Array, not a TempoMap");
assertArr.(d, [4,4,4], "quantizeRange(1,[2,4]): 3 elements, the range mean");

// -------------------------------------------------------- 8. quantizeWindow
// Sliding-window smoothing. env must be REBUILT from the mutated durs (2026-07
// fix) or the result maps like the unquantized original — so pin the MAPPING,
// not just .durs.
t = TempoMap([1,1,1,1,1,1], [1,3,1,3,1,3]);
r = t.quantizeWindow(1, 3);
assert.(r.isKindOf(TempoMap), "quantizeWindow: returns a TempoMap");
assertArr.(r.durs, [2.0, 1.75, 2.0625, 2.0625, 2.0625, 2.0625],
	"quantizeWindow(1,3): smoothed durs");
assertArr.(r.mapBeats(1 ! 6), r.durs, "quantizeWindow: mapBeats reflects new durs");
assertClose.(r.at(3), 5.8125, "quantizeWindow: at() uses the fresh env (not 5.0)");

// ----------------------------------------------------------- 9. quantizeDft
// Frequency-domain smoothing of .quarters. NOTE: it posts two Signals as a
// side effect (the rect/hamming windows) — that noise in the log is expected.
t = TempoMap([1,1,1,1,1,1,1,1], [1,2,1,2,1,2,1,2]);
r = t.quantizeDft(0.78);
assert.(r.isKindOf(TempoMap), "quantizeDft: returns a TempoMap");
assertClose.(r.durs.sum, t.durs.sum, "quantizeDft: total duration ~preserved", 1e-4);
// at the default-ish amount the retained band is essentially DC -> flat mean.
assertArr.(r.durs, 1.5 ! 8, "quantizeDft(0.78): collapses to the mean quarter", 1e-5);
// WART: amt 1 masks EVERYTHING (rect window width == size zeroes the signal),
// so every dur bottoms out at the mapBeats epsilon. Degenerate, but pinned.
assertArr.(t.quantizeDft(1).durs, 1e-9 ! 8,
	"quantizeDft(1): degenerates to all-epsilon durs", 1e-15);

// ------------------------------------------------------- 10. ++ concatenation
// Defined on TempoMap itself (not inherited): plain concat of beats and durs.
r = TempoMap([1,1],[1,2]) ++ TempoMap([1,1,1],[3,4,5]);
assert.(r.isKindOf(TempoMap), "++: returns a TempoMap");
assertArr.(r.beats, [1,1,1,1,1], "++: beats concatenated");
assertArr.(r.durs, [1,2,3,4,5], "++: durs concatenated");

// -------------------------- 11. transforms return independent concrete copies
t = TempoMap([1,1,1], [1,2,3]);
r = t.quantize(0.5);
r.durs.put(0, 99);
assertArr.(t.durs, [1,2,3], "quantize: result durs are an independent copy");
r = t.quantizeWindow(1, 2);
r.durs.put(0, 99);
assertArr.(t.durs, [1,2,3], "quantizeWindow: result durs are an independent copy");
r = t.quantizeRangeInPlace(1, 0, 1);
assert.(r.isKindOf(TempoMap), "quantizeRangeInPlace: returns a TempoMap");
assertArr.(r.durs, [1.5, 1.5, 3], "quantizeRangeInPlace: range mean at 0..1");
r.durs.put(0, 99);
assertArr.(t.durs, [1,2,3],
	"quantizeRangeInPlace: result durs are an independent copy");

} { |e|
	h[\fail].("EXCEPTION - " ++ e.errorString);
};

// -------------------------------------------------------------------- report
h[\report].();
0.exit;
)
