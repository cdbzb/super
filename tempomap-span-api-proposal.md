# Span/whole-map API unification + `toBpm` rename — proposal

Drafted 2026-08-21. Branch: `guide-track-features`. Status: **implemented 2026-08-21** (§A–E).
Kept as the rationale record; the open items below are the only live questions.
Owns a slice of `tempomap-v2-design.md`'s editor surface; fold in there once settled.

## Problem

1. Every whole-map editor has a `*Span` twin with the args in a different order, so you
   have to remember which is which (`quantize(amount)` vs `quantizeSpan(from, to, amount)`).
2. `toBpm` means two unrelated things in one class: `ritardSpan(..., toBpm:)` is a
   **terminal** tempo (arrive here by the end of the span), `AnchorMap.toBpm(bpm)` is a
   **mean** tempo over the whole map.
3. `scaleBpm` takes a *ratio*, not bpm. The name lies. Added 2026-08-20, unused.

## Proposal

### A. Optional trailing bounds

Shape args stay first, `from`/`to` go last and default to the domain ends. Omitted =
whole map; `from:` alone = "from there to the end" (same idiom as `fromBeat`).

```supercollider
quantize   { |amount = 1, from, to| }
scaleTempo { |k = 1,      from, to| }
setTempo   { |bps,        from, to| }
setBpm     { |bpm,        from, to| }
```

Existing whole-map calls are unchanged positionally. The `*Span` names are **removed, not
aliased** (MW, 2026-08-21 — call sites are low stakes and get an interactive pass). Removal
is the safe migration here: a missed call site is a `doesNotUnderstand` error, not a silent
change of meaning. That matters most for `stretchSpan` → `scaleTempo`, where the argument
INVERTS (`factor` is a y-multiplier, `k` is a tempo multiplier, `scaleTempo(1/factor)`) —
kept as an alias it would have been a silent inversion.

Removed: `quantizeSpan`, `setSpanTempo`, `setSpanBpm`, `setSpanSlope`, `stretchSpan`,
`toBpm`, `scaleBpm`. `setSpanSlope` becomes `setSlope(slope, from, to)`.

NOT renamed: `MapEditor`'s own `quantizeSpan` / `stretchSpan` / `setSpanBpm`. There "Span"
means "the currently selected span" and there are no bounds arguments — a different concept
that happens to share a suffix. Their internals move to the new API.
`MIDIItemPlayer.requantizeSpan` / `retimeSpan` are a separate family — see §F, which
corrects the "unrelated" call made here.
`ritardSpan` keeps its name and leading bounds (out of §A, see Scope).

**Verified bit-exact** (2026-08-21, `AnchorMap([0,1,2,3,4], [0,1.3,1.9,3.4,4.0])`):
the span form over the full domain reproduces the whole-map form exactly, `maxErr 0.0`,
for `quantize(1)`, `quantize(0.4)`, `ritard(0.5,2)`, `scaleTempo(2)`, `toBpm(90)`.
`transformSpan` does not cut where a boundary already IS a domain end, so the
whole-domain case degenerates to one cell — no resampling, no drift, no short-circuit
needed.

### B. `toBpm` → `setBpm` / `setTempo`

The mean-tempo setter is not a new verb, it is `setSpanBpm` with the bounds omitted.
Matches the existing `setSpanTempo` / `setSpanBpm` / `setSpanSlope` convention.
Applies at all three levels: `AnchorMap`, `MIDIItemTempoMap`, `EventList`.

`setTempo` (bps) and `setBpm` (bpm = bps × 60) are one operation in two units. Both set
the mean and preserve the rubato — every span scales by one common factor.

**Which mean:** total beats ÷ total seconds, i.e. exactly what `spanBpm`/`spanTempo` reads
back, NOT the arithmetic mean of the per-span tempi. Setter and reader are inverses:
`m.setBpm(x, from, to).spanBpm(from, to) == x`. Measured 2026-08-21 on spans of
120/30/120/60 bpm — `setSpanTempo(90 bpm)` gives `spanBpm 90.0`, arithmetic mean 123.75,
span duration 2.666667 s = 4 beats at 90. The divergence is large under rubato, so the
docstrings must say which one.

`setBpm` is the absolute form ("land on this value"), `scaleTempo` the relative one
("multiply by k"). Identical shape preservation; they differ only in how the destination
is named.

Rejected: `set` (set what — beats, frames, tempo?); `target` (`ritardSpan`'s own error
text already calls the *exit* tempo "the target", so it inherits the ambiguity).

### C. Delete `scaleBpm`

### D. `ritardSpan(toBpm:)` — no longer needed

DROPPED 2026-08-21. §B removes the `toBpm` METHOD, so the `toBpm:` keyword on `ritardSpan`
becomes the only `toBpm` in the codebase and the collision disappears on its own. "Ritard to
40 bpm" reads correctly for a terminal tempo. Left as is.

### E. `ritard` becomes multiplicative; `quantize:` selects the base

Today `ritard` REPLACES the interior timing — at `amount: 1` the original y-values drop
out entirely (`MonoMap.sc:471`), so a performance run through it comes back smooth. There
is no way to tilt a performance and keep its rubato.

**The identity that settles the design** (measured 2026-08-21, bit-exact, `maxErr 0.0`
for w 0.5/q 2/os 1, w 0.5/q 1/os 4, w 1.8/q 2/os 8):

```
m.ritard(w, q, ...)  ==  m.quantize(1).ritardMultiplicative(w, q, ...)
```

So the multiplicative form is the GENERAL operation and today's is the special case where
the base is flattened first. `quantize:` is therefore not a mode flag — it is sugar for a
pre-step that already exists as a method, and it takes the same 0–1 blend as
`AnchorMap.quantize(amount)`, NOT a boolean. (A boolean next to a numeric `quantize`
method invites `quantize: 0.5` being read as a blend and silently treated as truthy.)

```supercollider
ritard { |w, q = 2, amount = 1, oversample = 32, quantize = 0| }
```

- `quantize: 0` (new default) — the performance is the base, rubato survives, the q curve
  is a tempo MULTIPLIER. `quantize: 1` — today's behaviour, bit-exact. In between is a
  real blend (verified: a `quantize(0.5)` base gives alternation depth 1.29, between the
  flattened 1.0 and the full 1.60).
- Default flips to 0 deliberately: discarding the performance should be opt-in. Existing
  output changes; MW is fine adjusting call sites (2026-08-21).
- Implementation is ~4 lines: weight the trapezoid integrand by the original performed
  duration instead of by input width. `origYs` is already computed for the `amount` blend.

```supercollider
// today
cum = cum.add(cum[i] + ((allXs[i+1] - allXs[i]) * 0.5 * (vs[i].reciprocal + vs[i+1].reciprocal)))
// multiplicative
cum = cum.add(cum[i] + ((origYs[i+1] - origYs[i]) * 0.5 * (vs[i].reciprocal + vs[i+1].reciprocal)))
```

- Verified to carry over unchanged: end pinning, total-width preservation, monotonicity,
  and the bit-exact identity at `amount: 0`.
- **`w = nil` is refused when `quantize < 1`.** A fitted `w` reads the trend off the map's
  own end slopes; multiplying that back onto the unflattened map doubles the trend.
- Unchanged: total width stays pinned, so a decelerating tilt SPEEDS UP the start to
  compensate (ratios ran 1.356 → 0.742 in the prototype). For a ritard that actually
  lengthens, go through `ritardSpan(pinEntry: true)`, which already stretches.
- `easeTo` KEEPS `quantize: 1`. Proposed as `quantize: 0` on 2026-08-21 and **retracted the
  same day — the suite disproved it.** The thing `easeTo` removes is the tempo STEP at the
  join, and the step is part of the joined map's shape, so a multiplicative ritard scales the
  step along with everything else and leaves it there: the window then exits at the wrong
  tempo (measured 3.96 bps where the far side runs at 2.0, `ritard-test` "tempo is continuous
  LEAVING the window"). Flattening inside the window is the MECHANISM, not a wart. It costs
  the performance inside `[lo, hi]` and buys the continuity the method exists for; narrow the
  window if that is too much rubato to give up. Outside the window the takes are untouched,
  and that is the guarantee worth asserting.

Equivalent framing (for the doc, not the API): this is composition with an output-side
map. `(m >> g)'(x) = g'(m(x)) · m'(x)`, so a `sec -> sec` g whose slope is `1/γ` is a tempo
multiplier; building g's anchors on `m.ys` pulls a beat-domain ramp through `m⁻¹` for free.
Verified, including `scaleTempo(k) == m >> AffineMap(1/k, y0 - y0/k)` bit-exact. No new
operator is needed in the algebra — only a constructor for the factor map.

`q` semantics, for the docstrings: `v(u) = (1 + (w^q - 1)·u)^(1/q)`, `u` = normalised BEAT
position. `q = 1` is tempo linear in beats; `q = 2` is tempo linear in clock time
(`dv/dt = (w² - 1)/2`, constant); `q → 0` is `w^u`, constant percentage per beat.

**Where `quantize:` belongs — the rule.** Only where the ORDER is load-bearing, i.e. where
quantizing before and after differ. `ritard` qualifies: quantizing before chooses the base
the curve multiplies, quantizing after would flatten the curve back out of existence
(`quantize(1)` is a constant slope). `setBpm`/`setTempo`/`scaleTempo` do NOT qualify —
measured 2026-08-21, `quantize` preserves the mean AND the total width exactly at every
amount (60.0 bpm / width 8.0 at amounts 0, 0.25, 0.6, 1), so it commutes with the tempo
setters (`maxErr 0.0`, one ulp at amount 0.25). A keyword there would be a second spelling
of `m.quantize(x).setBpm(y)` with no order to protect. So: `quantize:` on `ritard` and
`ritardSpan`, nowhere else.

Corollary worth a docstring: "how straight" and "how fast" are orthogonal — either can be
set without disturbing the other, in either order.

**Objection considered (MW, 2026-08-21):** without the keyword, composing over one span
states the bounds twice — `m.quantize(1, from:4, to:6).setBpm(60, from:4, to:6)` — which is
duplication and a place to typo one of them. Real, and the order-only rule above missed it.
Answered by `transformSpan`, which states the bounds ONCE and composes anything:

```supercollider
m.transformSpan(4, 6, { |c| c.quantize(1).setBpm(60) })
```

Verified identical to the doubled-bounds chain (2026-08-21, `xs match`, `maxErr 0.0`).
§A is what makes the closure read well — bounds omitted inside it means "this whole cell".
`MapEditor.applyToSpan` (`MapEditor.sc:234`) already treats this as the idiom.

Decision: `quantize:` on `ritard`/`ritardSpan` only; document `transformSpan` as the
bounds-once composition idiom. Adding the keyword to the setters later is backwards
compatible, removing it is not — so defer, and revisit if the idiom grates in real use.

### F. `requantizeSpan` -> `quantizeToRhythm`

**Correction to an earlier reading in this doc.** `requantizeSpan` was first ruled out of
scope as "unrelated — destructive note re-timing, no whole-take twin". Wrong: the twin is
`MIDIItemPlayer.quantize` (`MIDI-Item2.sc:851`) on the SAME class, which takes intended
`beats` for the selection's anchors, rebuilds the map and warps the whole take. The "re-" in
`requantizeSpan` was pointing at exactly that. It belongs to the `quantize` family.

```supercollider
quantizeToRhythm { |durs, onsets, from, to, amount = 1|   // was requantizeSpan(from, durs, onsets, to, amount)
retimeSpan       { |durs, onsets, from, to, amount = 1|   // the MAP form, args reordered to match
```

They still do NOT merge under §A — cousins, not twins. Different payload (durs + measured
onsets vs anchor beats), different mechanism (one edited cell vs a rebuilt map), and the
no-ripple guarantee belongs to the local one alone. Shared verb, separate methods.

Name: `quantizeToRhythm` over `snapOnsets` (considered 2026-08-21). `snapOnsets` matches the
time-snap vocabulary in `retune-project.md:194` and reads well, but it hides the family the
correction above uncovered, and it suggests snap-to-GRID when the target is a rhythm you
author. `quantizeToRhythm` names the target and keeps the family. Cost, stated plainly: it
adds a fourth surface to a verb that already carries three senses here — straighten a tempo
map (`AnchorMap.quantize`), rewrite timestamps (`MIDIItemPlayer.quantize`), choose a ritard's
base (the `quantize:` keyword). That overload predates this work and is flagged in
`EventList`'s docstring; the family relationship was judged worth more than avoiding it.

`retimeSpan` keeps its name (its return type, an AnchorMap, is the difference) but takes the
new argument order so the pair does not diverge. Bounds trail, per §A; the rhythm leads,
because that is what the method names.

Arg-swap hazard: `durs` and `onsets` are both same-length numeric arrays, so a swapped call
is the one reorder that could pass quietly. In practice the existing guards fire —
`onsets` must be strictly increasing performed seconds whose first sits at the span start
(`retime-span-test.scd:316-323`).

## Scope

- In: `quantize`, `scaleTempo`, `setTempo`, `setBpm` — the three clean pairs plus the rename (§A–C).
- In: §E, which touches `ritard`/`ritardSpan`/`easeTo` but is a separate concern from the
  bounds work and can land independently (either order).
- In: §F (`quantizeToRhythm`), likewise independent.
- Out of §A: `ritard`/`ritardSpan` keep their separate names. They differ in more than bounds
  (`pinEntry`, `toBpm`, the automatic `extendTo`, `oversample` only on the whole-map form);
  merging makes those inert-but-accepted on the whole-map path and the signature long.
- Out: `quantizeWindow` — a moving window is not a bounded span.
- `EventList` mirrors get the same treatment through `prMapEdit`.

## Open

- Keep both `setTempo` (bps) and `setBpm` (bpm), or only `setBpm`? (BOTH SHIPPED, still open)
  No caller outside the class files uses the bps form — `MapEditor.sc:229` takes bpm and
  divides by 60 itself. One operation currently has three layers: `setSpanSlope` (sec/beat,
  any dimensions) → `setSpanTempo` (bps, guards beat→sec) → `setSpanBpm` (bpm). If one goes
  it should be the bps middle layer, not `setBpm`. Against cutting: the READERS are
  `spanTempo`/`spanBpm`, so setters in one unit only breaks the symmetry; and
  `TempoClock.tempo` is bps.
- ~~`*Span` aliases~~ — DECIDED 2026-08-21: removed outright, see §A.

## Test obligation

For each unified pair, assert the bounded form over the full domain is bit-exact against
the unbounded form. `tempomap-test.scd` (166 checks) and `ritard-test.scd` (184) must stay clean.

NOTE: `assertArr`'s tolerance test is `< tol`, so `tol: 0` never passes — use
`assert.(a.ys == b.ys, ...)` for bit-exactness, not `assertArr(..., 0)`.

For §E: assert `m.ritard(w, q, quantize: 1)` equals `m.quantize(1).ritard(w, q, quantize: 0)`
bit-exactly (the identity the design rests on), that `quantize: 0` leaves a jittered input's
per-span deviations intact, that `amount: 0` is still bit-exact identity at every `quantize`,
and that `w = nil` with `quantize < 1` throws. `ritard-test.scd`'s existing assertions were
written against the flattening behaviour — they move to explicit `quantize: 1`.
