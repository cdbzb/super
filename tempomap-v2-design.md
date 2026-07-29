# TempoMap V2 — core design

Drafted 2026-07-28. Normative spec for the rebuilt tempo-map core. History, bug ledger,
and the current system live in `quantize-tempomap-project.md`; this doc states what the
new thing IS. Where the two disagree on the new core, this doc wins; the old doc's §6b
(song compatibility) still owns the facade contract.

## Motivation

The current system grew one class per situation: `TempoMap`, `MIDIItemTempoMap`,
`AnchorTempoMap`, `PlacedTempoMap`, `TempoWarp`, `Groove`, plus EventList's composed
map. They are all the same mathematical object — a strictly monotone map between two
time-like axes — wearing different constructors. V2 builds that object once, with a
small set of combinators, so that every construction method and every transform is
available on every map.

## Core object

As built (2026-07-28, `Trek/MW-Classes/MonoMap.sc`): abstract `MonoMap`, concrete
`AffineMap` / `AnchorMap` / `ComposedMap`, frames as `MapFrame` instances. Suite:
`standalone-tests/monomap-test.scd`.

A **map** is a strictly increasing function with an inverse:

```
at(x)          // forward
invAt(y)       // inverse (or .inverse returning a map)
domain         // [lo, hi] in input coords, or nil = total
fromFrame      // MapFrame naming the input axis
toFrame        // MapFrame naming the output axis
extendBelow    // \carry | \error — per END, not per map
extendAbove    //   (a pickup before the first anchor and a run past the
               //    last are different musical situations)
```

### Frames

A frame names a *specific* axis, not a dimension: `MapFrame(\beat, \take3)`,
`MapFrame(\sec, \wall)`. Two maps compose only when the inner map's `toFrame` equals
the outer's `fromFrame`; composition checks this at construction and hard-errors on
mismatch. This is what makes "seconds to seconds but not the identity" (the old
TempoWarp) representable, and it kills the `at`-direction ambiguity: with frames on
the object, one `at` is enough. Frames are load-bearing, not metadata: `timeAt`/
`beatAt` dispatch on frame dimensions (and refuse beat->beat maps), replacing
respondsTo duck-typing.

There are no wildcard frames, and no frame-free maps. `MapFrame.mint(dim)` makes a
unique frame that composes with nothing — the template idiom: build a reusable shape
(a swing cell, a metronome) on minted frames, then bind each use explicitly with
`withFrames(from, to)` (same mapping, new axes; on a composition it rebinds only the
outer ends). Reuse is by explicit rebinding, never by tag coincidence.

### Extension

Outside its domain a map either carries its boundary slope forward (`\carry`) or
errors (`\error`), chosen per end. There is no `\clamp` in V2: a clamped map is
constant outside its domain, hence not invertible, and everything downstream
(inversion, composition) breaks silently. The legacy facade keeps clamping for the
songs; the core refuses it. Composed chains are lazy about domains — errors surface
at the offending lookup; `checkComposable` is the opt-in early range check for
authoring and tests.

## Combinators

- `compose(other)` / `>>` — frame-checked. Inverse of a composition is the reversed
  composition of inverses. Lazy by default (see Performance).
- `inverse` — swaps frames, domain becomes range.
- `place(fromOrigin, toOrigin)` — shift either axis. Just composition with an affine
  map; replaces `PlacedTempoMap` and scattered `+ t0` arithmetic.
- `MapSeq(maps, repeats: 1)` — concatenation: finite-domain maps laid end to end,
  each starting where the previous ended, cycling the list Pseq-style for `repeats`
  passes (`inf` = total tiling). `++` is sugar for the 2-element finite case. Kept
  verbally distinct from composition: composition nests functions (frames must
  chain), concatenation abuts domains (segments are shapes; the MapSeq binds its
  own frames). See Cyclic maps below.

The old classes become expressions: `TempoWarp(f, g)` is `f.inverse >> g` sharing the
beat axis; a `Groove` is a total map whose two frames are the same beat axis.

## Constructors

All produce the same kind of object; pick by what data you have.

- `fromAnchors(xs, ys)` — paired increasing positions on each axis. Piecewise linear.
  The media-neutral workhorse (was `AnchorTempoMap`).
- `fromSpans(spansIn, spansOut)` — paired span arrays (was `TempoMap(beats, durs)`).
  Same map as `fromAnchors` of the cumulative sums.
- `fromCell(...)` — one period of a cyclic map (swing ratio, wave shape, or anchors).
- `fromFunction(f, fInv)` — analytic escape hatch; caller guarantees monotone.
  Built 2026-07-29 as `FunctionMap`. Its `domain` is a *declaration* of where the
  caller vouches for monotonicity rather than a table bound, so `\carry` there
  means "the wrapped function is trusted outside the domain" and `\error` is the
  only way to fence off a region where it is not invertible. Cannot fuse: `bake`
  returns it unchanged and any chain holding one stays symbolic; `sample(n)` is
  the explicit, approximate freeze (named apart from `bake`, which is exact by
  contract).

## Cyclic maps (changing meters) — `MapSeq`

(Redesigned 2026-07-29 from the earlier `Cyclic` sketch: tiling is repeated
concatenation, so one combinator does both, named after Pseq whose semantics it
borrows.)

A **cell** is any finite-domain map. `MapSeq(cells, repeats: 1)` lays cells end to
end, each starting where the previous ended (cumulative offsets on both axes),
cycling the list for `repeats` passes — continuous and monotone by construction,
total when `repeats` is inf. It is a MonoMap like the others (each subclass is an
evaluation strategy for one protocol; MapSeq's is "locate tile, delegate to cell").
The combinator knows nothing about swing, meter, or periods:

- Groove = infinite MapSeq of beat->beat cells whose input width equals their
  output width (no drift). A swing cell is a 3-anchor AnchorMap:
  [0, 1, 2] -> [0, 1.2, 2].
- Changing meter = different-width cells cycled. Per-bar template / humanize = an
  anchor cell per bar.
- Looped tempo template = beat->sec cells (a vamp that breathes the same way every
  pass) — the old beat-beat-only Groove could not say this.
- Drift is allowed (output width != input width tiles into steady per-cycle
  stretch); "no net drift" is a checkable property, not a construction constraint.
- Slope may jump at cell joins (bar-line tempo changes); position never does.

Cells are shapes: the MapSeq ignores their frames (requiring only consistent
dimensions) and binds its own, like `withFrames`. Sine/tri modulation cells are
constructor sugar producing sampled anchor cells; a closed-form analytic cell class
comes only if an audible difference ever justifies it. Aperiodic reparametrization
(a groove that never repeats) is just an ordinary domain-bounded map on matching
frames; it needs no special class. Finite all-PL MapSeqs flatten to one AnchorMap
via `bake`, not in the constructor — symbolic keeps the cell structure editable.

## Transforms vs application

Two separate vocabularies, never mixed:

- **Transforms** take a map, return a new map: `clump`, `curve`, `smooth`,
  `quantize*`. They operate on the anchor representation.
- **Application** pushes data through a map: scalar `at`/`invAt`, and span mapping
  (`mapSpans(spans, from:)` / `unmapSpans`) written ONCE generically as differences of
  cumulative `at` — deleting the per-class `mapBeats`/`mapSpans`/`warpDurs` copies.
  Rebasing, origin choice, and destructive timestamp rewrites happen here, explicitly.

## Performance

- Piecewise-linear composed with piecewise-linear is exactly piecewise-linear:
  breakpoints are the inner map's plus the preimages of the outer's. So chains of PL
  maps fuse exactly — no oversampling, no anchor blowup (the bug that once grew an
  env 32x and stalled the scheduler).
- Chains stay symbolic by default; `.bake` fuses the PL runs exactly and leaves
  curved/analytic segments symbolic with bisection inverses.
- Scalar lookups binary-search cumulative breakpoints (the `prEnvAtFast` lesson).

## Compatibility (binding — see old doc §6b)

`Trek/Songs` is live and must keep working. Therefore:

- `TempoMap` stays as a facade with bit-identical song-facing behavior: constructor,
  `beats`/`durs`, `at`, `mapBeats`, `warpTo`, all `quantize*`, `++`, clamping
  boundary, concrete `TempoMap` return types from transforms.
- A compat suite pinning those idioms is written against the CURRENT classes before
  any core work starts, and must pass unchanged when the facade later delegates to
  the core.
- Deprecations only after the song corpus migrates; nothing removed mid-project.

## Build order

1. Core protocol: frames, domain, extension, `compose`/`inverse`/`place`, generic
   span mapping. Pure language; headless suite from day one. **DONE 2026-07-28**
   (MonoMap.sc + monomap-test.scd; includes the AnchorMap PL implementation and
   `fromAnchors`/`fromSpans`, pulled forward from step 2, plus `withFrames`).
2. PL implementation, exact PL fusion, `fromAnchors`/`fromSpans`. **DONE 2026-07-28.**
   `ComposedMap.bake`: all-affine chains fold to one AffineMap; chains with
   AnchorMaps fuse exactly to one AnchorMap (pulled-back breakpoint union,
   scale-relative dedupe on both axes, per-side \error-wins extension, carry
   regions exact). Unknown link classes (future MapSeq/curved) return the chain
   unbaked. Suite at 86 checks.
3. `MapSeq` + cells; express Groove as cells (changing meter falls out). `++` as
   finite-pair sugar. **DONE 2026-07-29.** Tile location = floor-div + binary
   search over cached cumulative widths; negative side tiles for `repeats: inf`
   (total, like Groove); finite repeats get domain + per-end extension, with
   out-of-domain delegated to the end cells. Cell sugar: `swingCell` (3-anchor,
   exact vs Groove.swing), `waveCell` (sampled 16-segment sine/tri, endpoints
   exact), `swing`/`modulate`/`groove` conveniences. Finite all-AnchorMap MapSeqs
   bake to one AnchorMap; `repeats: inf` and mixed chains stay symbolic. Suite at
   146 checks.
4. `clump`/`curve`/`quantize`/`quantizeWindow` as transforms on AnchorMap.
   **DONE 2026-07-29.** Non-mutating, frames/extension carry over; MapSeq/
   ComposedMap transform via `.bake` first. `curve` = PCHIP (Fritsch-Carlson)
   sampled to PL, original anchors bit-exact; `quantize` = anchor blend toward
   the endpoint line (numerically equal to old `TempoMap.quantize`);
   `quantizeWindow` diverges from the old one by design — window in INPUT-axis
   units, overlap-weighted local mean, total extent preserved by global rescale.
   `smooth`/DFT stay gated on real-take evidence (old doc §3b). Suite at 184.
5. **Bridge, not delegation** (reframed 2026-07-29). TempoMap's warts ARE its
   contract and it will never evolve; rewriting its internals to delegate would
   mean re-manufacturing every wart on top of clean core code, for no reward.
   Instead the old world enters V2 at explicit seams, and TempoMap itself is
   never touched (compat suite stays trivially green):
   a. `TempoMap.asMonoMap(fromFrame:, toFrame:)` — snapshot of beats/durs as an
      AnchorMap (immutable; later mutation of the TempoMap does not leak in).
      Deliberately `\carry`, not the old clamp.
   b. `array.warpTo(aMonoMap)` → `mapSpans` in the plusArray dispatch — the
      songs' central idiom accepts new maps with no facade surgery.
   c. `MIDIItemTempoMap.asMonoMap` — **DONE 2026-07-29.** Exact, not a
      resampling: `prBuildLinear` builds env/invEnv from precisely the `times`
      and `beats` the snapshot reads. Its declared extrapolation is already
      `\carry`, so unlike TempoMap there is no clamp to argue with.
      `origin: \relative` (default) matches `timeAt`; `\absolute` adds `t0`,
      matching `EventList.timeAtBeat`. The two are deliberately different axes
      with different frames — composing them is the t0 bug the frame system
      exists to catch. Producer-minted frames land here: the `\sec` frame is
      keyed on the TAKE (the midiEvents array), so several readings of one
      recording share a wall axis and compose, while the `\beat` frame is keyed
      on the map, since a different `choiceFunc` is a different reading of the
      beats. Curved maps are refused rather than silently flattened
      (`allowCurved: true` takes the linear anchors on purpose) — curved
      snapshot is DEFERRED until a real need appears; the linear anchors survive
      `curve` untouched, so nothing is lost by waiting.
   d. `list.asMonoMap` — **DONE 2026-07-29.** EventList's beatToWall/wallToBeat
      wrapped in `FunctionMap`, frames minted per list. Closes the "any tempo
      source answers the protocol" goal by wrapping, not merging. Three
      decisions worth remembering:
      - **Live, not a snapshot** — the map reads the list, so later edits to
        events / tempoMap / beatDur show through. An EventList is a live object
        and a silently stale snapshot would be worse; `.sample(n)` freezes it.
        This is the one place the bridges deliberately differ (5a and 5c both
        snapshot).
      - **`\error` below beat 0** — `beatToWall` CLAMPS there (returns 0 for any
        beat <= 0), and a clamped region is not invertible, so the map fences it
        off instead of carrying it. A pickup before beat 0 now raises where it
        used to quietly read 0. Above the last event the wrapped function holds
        its final multiplier, which is honest `\carry`.
      - The tempoEnv is captured ONCE at construction, because beatToWall
        memoizes against its identity; `useTempoTrack: false` captures nil
        instead, which is the materially different base-tempo-only map.
   Frames for both bridges come from `MapFrame.forSource(source, dimension,
   slot)`, a strong-keyed registry so that maps off one source land on one axis.
   Internal delegation is demoted to an option held in reserve, exercised only
   if a shared bug ever needs fixing in both engines. (`asMap` was rejected as a
   name: already means Synth-control-to-bus mapping in the class library.)
   Suite at 255 checks; the compat suite (41) stays green, TempoMap untouched.

Existing suites (tempomap-test 141, groove-test 46) are the porting harness: move
assertions over before internals.
