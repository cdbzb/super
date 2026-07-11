# Quantize / TempoMap overhaul — project notes

Started 2026-06-09. Working branch: `guide-track-features`.

Goal: unify and extend the tempo-map / quantize machinery so that turning a jittery
recorded performance into a usable tempo reference is principled, composable, and
consistent between `TempoMap` and `MIDIItemTempoMap`.

Journal seed: `~/home/org_roam_files/org.org` → "Jun 09, 2026 › quantizing / tempoMap
design ideas".

---

## 1. Where things stand (as of 2026-06-09)

### `MIDIItemTempoMap` (`Trek/MW-Classes/MIDI-Item2.sc:1139`)
Built from a `MIDIItem`/player + a `choiceFunc` selecting anchor noteOns + a `beats`
array (ideal beat positions between anchors). Holds two inverse, piecewise-linear maps:

- `env` — performedTime → idealBeat  (direction 1; `at`, `quantizeFunc`, player `warpTo`)
- `invEnv` — idealBeat → performedTime (direction 2; pattern `warpTo`, `mapBeats`)  (`:1164`)

Recent work this session:
- **Direction 2 revived** — `invEnv` is an exact inverse of `env`'s anchor nodes; both
  `pattern.warpTo(t)` and `pattern.warpTo(t.tempoMap)` produce durations for Pbinds.
- **`.curve(amount = 1, oversample = 32)`** (`:1206`) — returns a NEW map whose mapping is
  a **monotone cubic Hermite (PCHIP)** curve through the anchors instead of piecewise-linear.
  - passes through every anchor exactly → per-span integral preserved (anchors locked).
  - Fritsch–Carlson tangent clamp → tempo never goes negative.
  - `amount` blends linear↔curve (0 = identical to linear; 1 = full curve); `oversample`
    is the baked Env resolution. Helpers: `prCurve`/`prHermite`/`prMonotoneTangents`.
  - Verified live: anchor error 0, monotone, `curve(0)` == linear bit-for-bit.
- **Boundary = carry final tempo forward** — `prMapThrough` (`:1179`) extrapolates positions
  past the map's domain at the env's final slope (linear secant OR curved endpoint tangent →
  continuous). `domain` is taken from the env's real extent (`invEnv.times.sum` /
  `env.times.sum`), NOT `beats.sum`, so it's robust when `beats.size` ≠ anchor count.
  - Replaces the old silent truncation (overflow beats were dropped → desync).
  - Retired the earlier `++ gaps.last` hack; inner `tempoMap` kept only for `doesNotUnderstand`
    forwarding of `TempoMap` methods.
  - Hand-traced correct against live data; NOT yet machine-confirmed (see Testing notes).

### Selections + beat-domain access (2026-06-09/10 session)
Versioned beat selections now live on `MIDIItem` and drive quantize/tempomap/beat addressing:

- **Storage**: `MIDIItem.beatSelections` — Dictionary `take -> List` of selection Events,
  **append-only/immutable** (identical saves no-op). A selection holds `indices`, `beats`
  (spans between anchors — same quantity as the `beats` arg to `MIDIItemTempoMap`),
  and DP-tracker state (`pins`, `periodPrior`, `anchor`).
- **Access rule**: plural = data, singular = configured player.
  `mi.selections(3)[2]` → raw Event; `mi.selection(2, 3)` == `mi.take(3).selection(2)` →
  player with `currentSelection` loaded (take/version default to -1 = latest).
- **gui**: `e` manual extrapolate mode, `E` DP beat tracker (`MIDIBeatTracker`,
  `Trek/MW-Classes/BeatTracker.sc` — Ellis-style salience DP, j/k pin notes), `w` persists.
  Opening a take preloads its latest selection.
- **Consumers**: `quantize`/`quantizeFunc`/`tempomap` fall back to `currentSelection` for
  omitted `choiceFunc`/`beats` (via `prSelectionArgs`, which appends the trailing
  anchor-to-end span). So: `mi.take(-1).selection.quantize`, and for Pbinds:
  `durs.warpTo(mi.selection.tempomap)` (alias `tempoMap` exists).
- **Beat-domain methods**: `MIDIItemTempoMap.timeAt(beat)` (scalar dir-2, extrapolates past
  BOTH ends at boundary tempo, unlike clamping `at`/`[]`; `t0` ivar = absolute time of first
  anchor), player `timeAtBeat(beat)` (absolute; negative beats = pickup), and
  `fromBeat(from, to, trim)` — beat-domain mirror of `fromNote`, delegates to `from`.
- **Scoping contract**: only `take()`-stamped players (`takeIndex`) can address selections;
  derived players (filter/from/quantize results) deliberately refuse — their index space
  diverged. Open: stamp `mi.player` with `takeIndex = takes.size - 1` when
  `midiEvents === takes.last` (true after `stop`).
- **`from()` fixes** (latent, exposed by `fromBeat` landing exactly on onsets / CC-less takes):
  `chaseCCs` returned `[nil]` on empty (`[].separate` → `[[]]`); `notesStraddling` `<=` → `<`
  (exact-onset duplicate); rebase-to-zero now covers straddlers + chased CCs (CCs deep-copied,
  placed at start — previously uncopied and left at original timestamps).

### `TempoMap` (`Trek/MW-Classes/TempoMap.sc`) — existing quantize family
- `quantize(amount, start, end)` (`:67`) — blend each span toward the **single global mean**
  tempo. Rigid metronome at amount 1.
- `quantizeRange(amount, range)` (`:101`) / `quantizeRangeInPlace` (`:92`) — same on a sub-range.
- `quantizeWindow(amount, window)` (`:107`) — sliding-window blend toward the **local mean**.
  Effectively a moving-average tempo smoother: kills local jitter, keeps drift.
- `quantizeDft(amt = 0.78)` (`:77`) — DFT the `quarters` (per-beat tempo), keep the lowest
  `amt·size` frequency bins, iDFT back. Spectral **low-pass** of the tempo signal.
- `goodBeats(amount, ...args)` (`:124`) — per-region quantize with explicit boundaries.
- `mapBeatsPoly` (`:29`) — polynomial-trend mapping. **DEAD**: `polynomial` ivar (`:3`) is
  never assigned.

---

## 2. Mental model — three orthogonal axes

Quantizing a jittery performance is really three independent choices:

| axis | question | tool today | tool wanted |
|---|---|---|---|
| **resolution** | how many control points / anchors? | `choiceFunc` (manual) | `clump` / `newBeats` |
| **between-anchor shape** | how to flow between control points? | `.curve` | (done) |
| **at-anchor fidelity** | pass *through* anchors, or *near* them? | (none — always through) | `.smooth` / approximation |

`.curve` is **interpolation** (honors anchors exactly). The jitter problem is that the
anchors themselves are noisy, so we also want **approximation** (pass near, not through)
and **resolution control** (fewer, structural anchors). They compose:

```
clump(n)  →  .curve(amount)  →  .smooth(amount)   (each optional)
 resolution     shape              residual fidelity
```

---

## 3. Hanging design items (from the 2026-06-08/09 discussion)

### 3a. Resolution reduction — `clump` / `newBeats`  ← recommended first build
(Redesigned 2026-07-08 from the earlier `anchorEvery(n, mode, reduce)` sketch — Michael's
naming: the old `mode:\note` was misleading since in this codebase `beats` already means
spans-between-anchors; the operation is really a transform of the `beats` array.)

Reduce anchor density. Lower density can't represent high-frequency wobble (Nyquist), so it
low-passes the tempo while staying musically legible ("trust the bar lines"). All variants
are **resampling the map at lower resolution**; they differ only in where the new anchors
sit and in the estimator for each new anchor's time:

| operation | new anchor positions | new anchor time estimated by |
|---|---|---|
| `clump` (pick) | subset of existing anchors | that note's performed time, verbatim |
| `clump(…, mean:)` | subset of existing anchors | average over the group's notes |
| `newBeats` | arbitrary ideal beats | point-sample `timeAt(beat)` (linear interp of neighbor anchors) |

**`clump(n)` / `clump(array)`** — the SC idiom, operating on the `beats` array:
- `t.clump(2)`: merge every 2 spans into one — new `beats` = old beats clumped and summed
  (`beats.clump(2).collect(_.sum)`); keep boundary anchors, drop interior ones. Equivalent
  to the old `anchorEvery(2, mode:\note)`.
- `t.clump([2,4,6,5,3])`: variable group sizes — clump by bar across mixed meters.
  SC precedent `clumps([...])` **cycles** the array; adopt that (`clump([4])` = clump by
  4-beat bars forever), remainder group always kept so the final anchor pins.
- **Pin endpoints** — first & last anchors always survive, so the map spans the full region
  and total duration is preserved.
- Implementation: re-aggregate `beats` + thin the anchor list → feed the existing
  `invEnv`/`.curve` machinery. Composable transform on the map, not a constructor arg.
  Needs nothing new — buildable today.
- Alternate name if Collection's `clump` feels too close: `clumpBeats`.

**Aliasing / the mean option.** Plain clump = *pick*: boundary anchors keep their performed
times, so those specific notes' jitter survives and **aliases** into low-frequency tempo
(one rushed note at a kept anchor bends the whole group's span). Mean placement (boundary
anchor at a locally-averaged position ≈ non-overlapping `quantizeWindow`) is the robust
estimator. Decision (2026-07-08): **one method, placement as a flag** — `clump(4, mean: true)`
— not two names (`bin`/`downsample` etc. were considered and dropped; pick-vs-mean is one
operation with two placement policies). Build `pick` first, listen on real takes, add `mean:`
if pick-jitter is audible.

**`newBeats([0, 4, 8, ...])`** — resample the map at an explicit ideal-beat grid: new anchor
times = `timeAt(beat)` point-samples. This resolves the old "no note sits on the anchor beat"
question (synthetic anchor via interpolation wins — no nearest-note snap rule needed) and is
the true "bar grid" mode (old `mode:\beat`). Caveats:
- Point-sampling does **not** anti-alias — a synthetic anchor inherits the jitter of its two
  neighboring performed anchors. Anti-aliasing must come from sampling a smoothed/`.curve`'d
  map, or a future local-mean estimator.
- Wants the frozen `timeAt` protocol name (M0 open item) and dovetails with §4d's
  `(times, beats)` constructor. Build AFTER `clump`, on evidence of need.
- (2026-07-01 note still applies: for guide-track recordings, per-note beat positions come
  free from §9a's `wallToBeat`.)

A fully unified `resample(positions, estimator:)` (pick / interpolate / local-mean as one
axis, anchor placement as the other) was considered 2026-07-08 — deferred: `clump(n, mean:)`
+ `newBeats(array)` likely covers real usage with less API surface.

Likely outcome: **`clump` + `.curve` alone covers most jitter**; spectral smoothing
may be unnecessary.

### 3b. Anchor denoising — `.smooth(amount, window)`
Make the curve pass *near* jittery anchors, not through them.
- **Pragmatic:** delegate to the existing `quantizeWindow`/`quantizeDft` via the inner
  `tempoMap`, then re-wrap the smoothed `TempoMap` back into a `MIDIItemTempoMap` (rebuild
  `times`/`invEnv` from new durs). Mostly wiring.
- **Principled (unifier):** a **monotone smoothing spline** with one penalty knob λ. λ=0 =
  exact interpolation (= `.curve`), λ→∞ = straight line (constant tempo); in between, trades
  fidelity for smoothness, handles irregular spacing, keeps tempo positive. Makes `.curve` and
  `.smooth` a single continuum. More code (penalized least-squares).
- Smooth the **tempo** (rate), not cumulative position (smoothing position under-smooths tempo).
- Endpoint anchoring decision: pin first/last (preserve span) or let it float.
- **Build gate (2026-07-02):** don't start `.smooth` until `clump` + `.curve`
  (milestone 1) has been tried on real takes and the anchors are still audibly noisy.
  §3a already predicts it may be unnecessary; the kill criterion is real material, not
  intuition. Same gate, doubled, for the milestone-10 spline work.

### 3c. B-spline approximation (note the asset doesn't exist yet)
A **B-spline** of order > linear passes *near* its control points, not through — i.e. it is
inherently the "don't honor jittery anchors" tool. The `~bsplineKr` / `BSpline` / `SplineGen`
snippet in the journal (May 17) is **aspirational**: those classes do not exist anywhere in the
class library or quarks (only `wslib`'s Pen `splineCurve`). If we want B-spline approximation we
must implement it (a uniform cubic B-spline basis is ~the same effort as the Hermite we already
have). Worth weighing against the smoothing-spline route in 3b.

### 3d. `quantizeDft` caveats / cleanup
- Assumes **regularly-sampled** data (DFT). Works on `quarters` because that's resampled to
  1-dur-per-beat; irregular anchors must be resampled first.
- The real/imag windowing is asymmetric — `rectWindow` on real, `hammingWindow` on imag
  (the code's own `//why?`). Distorts phase; a clean low-pass should mask both identically or
  zero whole bins. **Probable latent bug — fix when we lean on it.**

### 3e. Consistency wrinkle
`pattern.warpTo(t.tempoMap)` goes through `TempoMap.mapBeats` → still **truncates** at the
boundary, while `pattern.warpTo(t)` carries forward. Document or unify (relates to §4d).

---

## 4. Journal directions (Jun 09) folded in

### 4a. Better interactive quantization tool — **largely DONE (2026-06-09/10)**
"Guess from the first couple of selections and carry the suggested tempo forward." Built as
the gui's `e` (greedy last-pair extrapolation) and `E` (`MIDIBeatTracker` DP — globally
optimal, salience-weighted, j/k pins) modes, with `w` persisting versioned selections and
`mi.take(-1).selection.quantize` closing the loop. Remaining polish lives in §1
"Selections" scoping note and the fromBeat follow-ons (beatFilter/onBeats deferred).

### 4b. "Clamp slow change but keep jitter" — inverse of `quantizeDft`
A **high-pass** tempo filter: remove slow drift, preserve fast articulation/jitter. Literally
`tempo - quantizeDft(tempo)` (or keep high bins instead of low). Useful for the opposite
aesthetic — lock the macro pulse, keep the human micro-timing.

### 4c. `quantizeInPlace` that auto-scales
"`quantize` on MIDIItems currently takes the `beats` at face value." Add a quantize variant
that auto-scales the supplied `beats` to the measured span instead of trusting absolute
values — removes a class of "my beats summed to the wrong total" errors.

### 4d. (maybe) Fold `TempoMap` and `MIDIItemTempoMap` together
At minimum, ensure every method works in both contexts (beats-vs-time vs irregular-anchor-time)
so the API is consistent. The duplicated `mapBeats`/`quantize`/`warpTo` surfaces are the main
friction. Decide: shared superclass, mixin, or one class with two construction modes.

**Reframed 2026-07-01 — unify as a protocol, not a merge.** Since `b50cff46`/`abe53a74` the
center of gravity is `EventList.beatToWall` — a THIRD engine (base map × `\tempoTrack`
multiplier env, with its own integration cache and extrapolation policy) that AudioItem
tempo-follow and VoiceSpace consume exclusively. (`TempoClock.newFromQuarters` in
`plusTempoClock.sc` is a vestigial fourth — fold or deprecate.) Target: any tempo source
answers `timeAt(beat)`, `beatAt(time)`, `mapBeats(beats)`, `mapDurs(durs)` plus a **stated** extrapolation
policy; implemented by `TempoMap`, `MIDIItemTempoMap`, and a first-class composed-map object
that EventList exposes (wrapping its `prWall*` cache). That resolves §3e for free (both
`warpTo` forms hit one protocol) and provides the seam for §9's
source → ideal → list → wall composition.
- Parity audit item #1: **`at` is inverted between the classes** — `TempoMap.at(beat)` → time
  (`TempoMap.sc:18,37`) vs `MIDIItemTempoMap.at(time)` → beat (`MIDI-Item2.sc:1725`), and
  `doesNotUnderstand` forwarding means the SAME object can answer both conventions. Pick
  direction-encoding names (`timeAt`/`beatAt`), alias `at` to exactly one.
- **Decide the protocol NAMES now; implement the unification at milestone 9 (2026-07-02).**
  Milestones 4, 7, and 8 each add new consumers of the tempo-map API (`wallToBeat`,
  `sourceTempoMap:`, the `(times, beats)` constructor); every consumer written before the
  `at` rename bakes in the ambiguous convention and enlarges the migration. Cheap move:
  freeze `timeAt(beat)` / `beatAt(time)` / `mapBeats(beats)` / `mapDurs(durs)` + the extrapolation-policy
  vocabulary up front (part of milestone 0), add them as thin aliases on both classes, and
  require all new §9 code to use ONLY those names. Full unification stays at milestone 9.
- dNU-forwarded methods (e.g. a forwarded `quantize`) return a bare `TempoMap`, not a
  re-wrapped `MIDIItemTempoMap` — build the rewrap helper (already implied by §3b's
  pragmatic route) as its own primitive; §9a fragment capture wants it too.
- Add a `(times, beats)` constructor so a map doesn't require a MIDI item at all (§9c.2 —
  audio selections reduce to exactly that pair).

---

## 5. Known bugs / cleanup backlog

Items tagged **[M0]** are pulled into milestone 0 (fix-before-build, test-driven — see §6).

- [ ] `polynomial` ivar never assigned → `mapBeatsPoly` dead (`TempoMap.sc:3,29`).
- [ ] `quantizeDft` rect/hamming asymmetry (`TempoMap.sc:85-86`).
- [ ] `warpTo(t.tempoMap)` truncates vs `warpTo(t)` carries forward (§3e).
- [ ] MIDIItem `quantize` takes `beats` at face value (→ 4c).
- [x] **[M0]** Machine-confirm the carry-forward boundary fix — done 2026-07-07 (test 11
      in `standalone-tests/tempomap-test.scd`: unit-beats past the map domain hold the
      final performed tempo, length preserved).
- [x] `chaseCCs` `[nil]` on CC-less region; `notesStraddling` exact-onset duplicate;
      `from()` partial rebase (straddlers/chased CCs) — fixed 2026-06-10.
- [ ] Stamp `mi.player` with `takeIndex` when `midiEvents === takes.last` (selection
      addressing from the post-record player; see §1 scoping contract).
- [ ] `AbstractMidiEvents.doesNotUnderstand` error path does `class + "doesnt understand"`
      → masks real errors with `Message '+' not understood`.
- [ ] Deferred beat-domain selectors: `beats` (per-note positions), `beatOf`, `beatFilter`,
      `onBeats` (designed 2026-06-10, only `fromBeat` + upstream built).

Fixed 2026-07-05:
- [x] **`MIDIItemTempoMap.timeAt`/`mapBeats` linear-scanned the Env every call** — `Env.at`
      is O(segments), and `.curve(1)` bakes `oversample` (default 32) points **per span**, so
      the invEnv grows ~32× and every `timeAt` got ~32× slower. `VoiceSpace.playFrom` calls
      `beatToWall→timeAt` 3× per warped guide note (`prWarpItemToTrack`) and per env segment in
      `rescaleEnv` (the latter **inside the scheduling Routine**), so a curved base map stalled
      the Routine ~1-2 s → silence then a burst of "late" messages, then normal. Fix
      (`MIDI-Item2.sc`): identity-keyed per-Env cache (`prEnvLinCache`/`prEnvAtFast`/
      `prEnvDomain`) does O(log n) binary search over cumulative times for the linear envs
      (env/invEnv/`.curve` outputs are all `\lin`), falling back to `Env.at` for any non-linear
      Env. `prCurve` resets the cache (copy had shared the parent's dict). Confirms the doc's
      "extend the wall cache to the base map" note — `EventList.beatToWall`'s `prWall*` cache
      only ever covered the `\tempoTrack` path, never `tempoMap.timeAt`.

Found in the 2026-07-01 review (all four **[M0]** items FIXED 2026-07-07 — see block below):
- [x] **[M0]** **`TempoMap.quantizeRangeInPlace` writes to wrong indices** (`TempoMap.sc:92-99`):
      `(start..end).do{|i| dursCopy.put(start+i, quantized[i])}` — `.do` yields the VALUES
      `start, start+1, …`, so it writes at `start+start …` and reads past `quantized`'s end
      (size is only `end-start+1`). Only correct when `start == 0`. Fixed:
      `quantized.do{|v i| dursCopy.put(start+i, v)}`. Also `quantize`'s range branch defaulted
      `end = durs.size` (`:73`) — one past the last index; `quantizeRange` then sliced a nil.
      Both `end` defaults now `durs.size - 1`.
- [x] **[M0]** **`TempoMap.env` goes stale after any mutation** — built once in `init` (`:18`);
      `beats_`/`durs_` (`:21-28`) only rebuilt `timesIn*`, and `quantizeWindow` (`:107`)
      mutated `result.durs` in place, patching `timesInDurs` but never `env`. Since
      `at`/`mapBeats` read `env`, a `quantizeWindow` result MAPPED LIKE THE UNQUANTIZED
      ORIGINAL. **Was blocking §3b's pragmatic `.smooth`.** Fixed with one shared `prRebuild`
      (rebuilds timesIn*/env) called from `init` + both setters + `quantizeWindow`; debug
      `.postln` removed.
- [x] **[M0]** **`TempoMap.mapBeats:55` clamp is a no-op** — `b.collect{|i| 0.000001 max: i};`
      result discarded. Dead line removed; clamp moved to the OUTPUT (see next item).
- [x] **[M0]** **`mapBeats` silently changes array length** — `.select(_.isStrictlyPositive)` in
      `TempoMap.mapBeats` (`:56`), `MIDIItemTempoMap.mapBeats` (`MIDI-Item2.sc:1947`), and
      `warpToArray` (`plusArray.sc:102`) DROPPED non-positive durs, so a Pbind's `\dur` desynced
      from its `\midinote` array from that point on. All three now clamp non-positive spans to
      `1e-9` (`.collect{|i| 1e-9 max: i}`) instead of dropping — preserves alignment.
- [x] **`EventList.copyFrom` drops `tempoMap` and `beatDur`** — fixed 2026-07-06 (§10e):
      copies carry `beatDur`/`tempoMap`/`solo`/`mute` (decision: mix state travels).
- [ ] `at` direction inversion + dNU rewrap (see §4d).
- [ ] **AudioItem take numbering counts non-take files** — `PathName(directory).entries.size`
      (`AudioItem.sc:46-49,372`); a `.DS_Store` or future metadata sidecar misnumbers takes.
      Count numeric-stem matches instead. **Must land before §9a sidecars.**
- [ ] `asEventList` gives pickup events negative `when` (`ParamSpace.sc:127-131`) and
      `EventList.play`'s `(t >= from)` gate then drops them at `from = 0` — decide: fold
      pickups to 0, or accept a small negative window.
- [ ] MIDI capture subtracts `Server.default.latency` (`MIDI-Item2.sc:1001`) but audio via
      `Recorder` contains hardware INPUT latency instead — two conventions, constant
      ~20-40 ms offset between media. Record the convention per take (§9a sidecar).
- [x] `fromBeat(a,b).tempomap` degenerate final beat when the last selected note sustains
      past the slice: closing anchor used `bounds.end` (≈ last onset, because a trailing
      `mk` event sits there), so the final beat collapsed to a few ms. Fixed 2026-06-11 —
      `fromBeat` stamps `closingAnchor` (time:, beats:) from the parent's NEXT selected beat
      past `to`; `MIDIItemTempoMap.init` and `prSelectionArgs` consume it. The final span now
      follows the performed tempo at the boundary (beats 1→3 ⇒ 3 real beats, not 2 + a stub).
- [ ] **Revisit `fromBeat` last-beat fallback.** When `to` is the *last* selected beat there
      is no next parent beat, so `closingAnchor` stays nil and `init` falls back to
      `bounds.end` (unchanged today — still degenerate if that final note sustains past).
      Decide the right closing anchor: the note's sustain end, an extrapolated beat at the
      prevailing tempo, or leave as clip end. (Michael flagged 2026-06-11.)

---

## 6. Suggested milestones
0. **Headless regression suite + fix-before-build** (added 2026-07-02). **MOSTLY DONE
   2026-07-07.** Suite lives at `standalone-tests/tempomap-test.scd` (26 checks, pure
   language via stock `sclang <file>.scd` — attaches to scsynth on startup but is
   language-side; don't loop while the live rig is up). Covers: TempoMap `at` endpoint +
   monotonicity, MIDIItemTempoMap env↔timeAt round-trip, anchors preserved through `.curve`,
   `mapBeats`/`warpToArray` length preservation (incl. zero-span), `quantize(0)` == identity,
   `quantize(1)` rigid-mean, range-quantize indices, `quantizeWindow` env freshness, durs
   setter env rebuild, carry-forward boundary. All four **[M0]** §5 bugs FIXED driven by the
   suite (env staleness → shared `prRebuild`; `quantizeRangeInPlace` indices; `end` off-by-one;
   `mapBeats` clamp/length at all 3 sites). Machine-confirmed the carry-forward boundary.
   **DONE 2026-07-11:** froze the protocol names (`timeAt`/`beatAt`/`mapBeats`/`mapDurs` — §4d)
   on both map classes, with regression coverage. Naming convention: `beats` are musical
   spans and `durs` are elapsed seconds, so `mapBeats` maps beats→durs and `mapDurs` maps
   durs→beats. `TempoMap` retains its clamping
   boundary policy; `MIDIItemTempoMap` carries endpoint tempo in both scalar directions.
   All later milestones should code to these names. Rationale unchanged: recompiles reboot
   the server so regressions must be caught headless, and M1's `reduce:\mean` can't be verified
   against a broken `quantizeWindow`.
1. **`clump(n)` / `clump(array)` — DONE 2026-07-11** (pick placement) + endpoint
   pinning + beats re-aggregation. Integer sizes group regularly; arrays cycle and retain
   the remainder. The transform is non-mutating and resets curvature, so compose as
   `t.clump(4).curve(amount)`. `mean:` and `newBeats` remain gated on real-take listening.
   (§3a)
2. **`.smooth`** pragmatic version over `quantizeWindow`; fix `quantizeDft` windowing first
   (env staleness lands in milestone 0). **Gated on milestone 1 proving insufficient on real
   takes — see §3b build gate.** (§3b, 3d)
3. **Carry-forward / `t.tempoMap` consistency** + machine-confirm boundary. (§3e, §5)
4. **Guide-track fragment capture** — `wallToBeat` + play epoch + `captureFragment` +
   AudioItem take sidecar. Depends on 3; makes 5 more valuable (real fragments to smooth).
   Sub-steps 1–3 are pure-language. (§9a)
5. **`quantizeInPlace` auto-scale** + **high-pass ("keep jitter") filter**. (§4b, 4c)
6. ~~**Interactive quantization tool** prototype.~~ (§4a — done 2026-06-09/10, see §1 Selections)
7. **Wild-fragment alignment polish** — `sourceTempoMap:` composition on `\mi2` +
   tempoFollow, EventList-without-VoiceSpace gap, `t0` rebase, `list.addItem`. (§9b)
8. **Audio beat marking** — `BeatMarkMode` extraction → `(times, beats)` constructor +
   persisted anchors (schema owned by retune §2e's archive — see §9c.2) → waveform beat
   mode in the retune gui → `trackOnsetsOffline`. (§9c)
9. **Unify TempoMap / MIDIItemTempoMap / EventList composed map** as a protocol
   (method-parity audit; `at` inversion first — names already frozen in milestone 0, this
   milestone finishes the implementation + parity audit). Overlaps 4/7/8 — do the protocol
   pieces as those milestones touch them. (§4d)
10. (stretch) **Monotone smoothing-spline** λ unifier, and/or B-spline approximation.
    Same build gate as `.smooth` (§3b): only if real material shows anchors still noisy
    after milestones 1–2 — don't build by momentum. (§3b, 3c)

### 6a. Architecture review after milestone 1 (2026-07-11)

The long-term center should be an algebra of monotone coordinate transformations, not a
collection of unrelated quantizers. Quantization algorithms then become transforms of a
map; MIDI, audio, patterns, and EventLists become producers/consumers of that map.

**Move the protocol foundation earlier than milestone 9.** Milestones 4, 7, and 8 already
need it and must not grow new reads of `env`/`invEnv`, calls to ambiguous `at`, or manual
`t0` arithmetic. Before those milestones, establish these common operations:

```supercollider
timeAt(beat)
beatAt(time)
mapBeats(beats, fromBeat: 0) // musical beat spans -> elapsed-second durations
mapDurs(durs, fromTime: 0)   // elapsed-second durations -> musical beat spans
```

Settle the vocabulary: `durs` ALWAYS means elapsed seconds; `beats` means musical beat
spans. Both array mappings need an origin because duration mapping is position-dependent on
a changing tempo map. `mapBeats` is successive differences of `timeAt` at cumulative beat
positions; `mapDurs` is successive differences of `beatAt` at cumulative times. Also expose
the beat/time domains and the extrapolation policy (`\carry`,
`\clamp`, or `\error`) instead of leaving boundary behavior implicit in the concrete class.
For musical playback `\carry` is generally useful; `\error` is valuable for authoring and
tests because it exposes accidental out-of-domain access.

**Separate mapping from placement.** The core map should be relative. Absolute placement
belongs in a wrapper such as `PlacedTempoMap(map, beatOrigin, timeOrigin)`, rather than in
scattered `+ t0` conventions. Likewise, source→ideal→list→wall should become a first-class
composed map answering both directions, not closures reimplemented by EventList, MIDI, and
AudioItem consumers.

**Promote the `(times, beatPositions)` constructor.** A MIDI selection is one way to AUTHOR
anchor arrays, not part of a tempo map's identity. A media-neutral anchor-map constructor
should land before audio marking and general `sourceTempoMap:` work. It also supplies the
rewrap primitive and lets `MIDIItemTempoMap` retire `doesNotUnderstand` forwarding over time.

**Keep smoothing beat-domain aware.** `quantizeWindow` uses a count of anchor indices, which
represents inconsistent musical widths when anchors are irregular. If real-take listening
opens the `.smooth` gate, prefer `windowBeats:` and a local beat-domain regression over
further investment in DFT smoothing. For `clump(mean: true)`, do not average raw timestamps
belonging to different beat positions; fit local `time = offset + secondsPerBeat * beat` (or
average timing residuals) and evaluate the retained boundary beat.

**Keep map transforms separate from applying a map to events.** `clump`/`curve`/`smooth`
transform a mapping. `warpThrough`/`toBeatDomain`/pattern duration mapping apply it. Make
destructive timestamp rewrites, rebasing, and origin selection explicit at the application
stage.

Recommended dependency order from here:

1. **Position-aware span mapping — DONE 2026-07-11:**
   `mapBeats(..., fromBeat:)` and `mapDurs(..., fromTime:)` on both map classes; defaults
   preserve all existing zero-origin calls. **Protocol metadata DONE 2026-07-11:** both
   classes expose relative `beatDomain`, `timeDomain`, and `extrapolation`. `TempoMap`
   reports its legacy `\clamp` behavior for song compatibility; `MIDIItemTempoMap` reports
   `\carry`. New maps should prefer `\carry` for playback or `\error` for strict authoring;
   `\clamp` is descriptive legacy policy, not a recommended creation option.
2. **Media-neutral anchor-map constructor — DONE 2026-07-11.**
   `AnchorTempoMap(times, beatPositions)` accepts paired absolute seconds and cumulative
   ideal-beat positions without a MIDI item. It normalizes both axes, retains the first
   time as `t0`, validates equal-size numeric strictly-increasing anchors, and inherits the
   tested `curve`/`clump`/protocol behavior. `MIDIItemTempoMap.fromAnchors` exposes the same
   construction path for compatibility. A future placed-map wrapper will replace `t0` as
   the general placement mechanism.
3. **First-class placed map — DONE 2026-07-11.** `PlacedTempoMap(map, beatOrigin,
   timeOrigin)` wraps any protocol-compatible map without mutation. The origins specify
   where the wrapped domains begin in the external coordinate frame; scalar mappings,
   position-aware span mappings, and domains translate accordingly, while extrapolation
   policy is forwarded unchanged. Placement wrappers can nest. The composed-map half
   is now represented by **`TempoWarp(sourceMap, targetMap)` — DONE 2026-07-11**. A
   `TempoWarp` is deliberately NOT called a tempo map: it is a directional seconds→seconds
   transform through a shared beat coordinate, with `mapTime`/`unmapTime` and position-aware
   `mapDurs`/`unmapDurs`. It never guesses beat offsets; use `PlacedTempoMap` first when the
   source and target origins differ. It exposes source/target/mapped time domains, the shared
   beat-domain intersection, and both boundary policies. Once a unified map host exists,
   `sourceMap.warpTo(targetMap)` can be added as constructor sugar without duplicating logic.
4. **Protocol consumer migration — IN PROGRESS 2026-07-11.** EventList's
   `sourceTempoMap:\eventList` path now uses `timeAt`/`beatAt` instead of private
   `prAtExtrapolated` + `env`, so any invertible protocol map works. AudioItem's source-end
   inversion uses `beatAt` rather than ambiguous `at`; MIDI `quantizeFunc` computes its
   result through `beatAt` while retaining the callback's legacy `env` field. Deliberately
   deferred: `MIDIItemPlayer.warpTo` has two historical meanings depending on concrete map
   type and needs a compatibility audit before its private/ambiguous dispatch is changed.
5. `wallToBeat` and fragment capture.
6. Listen to `clump + curve` on real takes; build beat-domain smoothing only on evidence.
7. Audio authoring and general `sourceTempoMap:`.
8. Retire legacy forwarding only after compatibility coverage and migration.

### 6b. `Trek/Songs` backward-compatibility contract

The architecture work MUST NOT break the existing song corpus. `Trek/Songs` has extensive
live use of these concrete idioms:

```supercollider
durs.warpTo(e.tempoMap)
e.tempoMap.mapBeats(durs)
e.tempoMap.quantize(...)
e.tempoMap.quantizeWindow(...)
e.tempoMap.quantizeDft(...)
e.tempoMap ++ anotherMap
```

Some code also relies on concrete `TempoMap.beats`/`durs` access and on transformed maps
remaining concatenable `TempoMap` instances. Therefore protocol work is ADDITIVE during
migration:

- retain the `TempoMap` constructor, `beats`, `durs`, `at`, `mapBeats`, `warpTo`, all
  `quantize*` methods, and `++` with their current song-facing behavior;
- do not change existing transform return types to generic/composed map classes;
- add direction-explicit names and new map types first for new workflows;
- deprecate ambiguous methods only after the song corpus is migrated; do not remove them;
- add a compatibility suite covering the idioms above before changing TempoMap internals.

The protocol may become the internal foundation while `TempoMap` remains a stable facade.
Milestone 0/1 changes (`timeAt`/`beatAt`/`mapDurs`, `MIDIItemTempoMap.clump`) are additive and
do not change the song-facing API.

---

## 7. Testing notes
- These are **pure-language** tests (no audio server needed) — `MIDIItemTempoMap`, `warpTo`,
  `mapBeats`, `quantize*` are all language-side.
- Milestone 0 turns the ad-hoc checks below into a persistent headless suite (UnitTest2 is
  installed; a stock `sclang <file>.scd` run loads the Trek classes with no server). For
  one-off checks in the live session, `bin/sctest` runs SC code in the running scnvim sclang
  and captures output.
- Verifying an edited class requires recompiling the class library. In Michael's live scnvim
  session, `recompile()` **re-runs his startup and reboots scsynth** — recompile AT MOST once
  per change, warn him first, and prefer handing him a one-line check to run himself. (Burned
  his server doing this repeatedly on 2026-06-09.) See memory `feedback_scnvim_recompile_reboots`.
- Quick boundary/curve sanity (after one recompile):
  ```supercollider
  m = MIDIItem("drumset_241119_155106").player.fromNoteTo(0, 5);
  t = MIDIItemTempoMap(m, {|n| n[0..4]}, [1,1,1,1,1]);
  1.dup(8).warpTo(t);            // expect length 8, tail ≈ constant final tempo (carry-forward)
  1.dup(8).warpTo(t.curve(1));   // expect length 8, smooth
  ```

## 8. Key files
- `Trek/MW-Classes/MIDI-Item2.sc` — `MIDIItemTempoMap` (incl. `timeAt`/`t0`), `.curve`,
  `prMapThrough`, `quantize`/`quantizeFunc`/`prSelectionArgs`, selection API
  (`addSelection`/`selections`/`selection`), player `timeAtBeat`/`fromBeat`, gui modes.
- `Trek/MW-Classes/BeatTracker.sc` — `MIDIBeatTracker` (DP beat tracking; salience,
  pins, tunable weights). Media-agnostic — see §9c.
- `Trek/MW-Classes/TempoMap.sc` — quantize family (`:67`–`:130`).
- `Trek/MW-Classes/plusArray.sc` — array `warpTo` / `warpToTempoMap` dispatch.
- `Trek/MW-Classes/EventList.sc` — `beatToWall` + `prWall*` cache (`:457-524`), `tempoEnv`/
  `extractTempo`/`timelineToEnv`, `play` (`:526`). §9a's `wallToBeat` lands here.
- `Trek/MW-Classes/AudioItem.sc` — take storage, `tempoFollowActions`/`tempoFollowEnvActions`
  (`srcOffset` seam for `sourceTempoMap:`, `:176-183` / `:269-294`).
- `Trek/MW-Classes/VoiceSpace.sc` — `playFrom` routes (`:637`), `prWarpItemToTrack` (`:593`).
- `Trek/MW-Classes/Retune.sc` — `RetuneItem` note model + `_retune/` sidecar pattern
  (`:233-246`), `trackPitchOffline` harness (`:297`), `\retunePreview` (`:542`).
- `Trek/MW-Classes/PianoRollNav.sc` — the shared-gui-extraction precedent for `BeatMarkMode`.
- Journal seed: `~/home/org_roam_files/org.org` (Jun 09, 2026).

---

## 9. Cross-media fragment recording & alignment (2026-07-01 discussion)

Goal restated: one coherent tempo system across MIDIItem / AudioItem / EventList / Patterns,
supporting (a) recording a fragment **against a playing EventList**, and (b) recording
**wild**, marking beats, and aligning to the list's map afterwards. The system is closer to
coherent than §1 suggests: everything funnels through `EventList.beatToWall` (recorded
tempoMap × `\tempoTrack` multiplier), and MIDI items, audio tempo-follow, and VoiceSpace all
consume it. What's missing is mostly the **inverse direction** (wall → beat) and **metadata**.
Recurring conclusion in every sub-problem below: prefer maps that COMPOSE
(`source → ideal → list → wall`) over timestamps that get rewritten.

### 9a. Guide-track fragment capture (record while the list plays)
When recording against a playing list, the tempo map is KNOWN at record time — no beat
tracking needed. Recorded wall timestamps push through the inverse of the composed map and
land on the ideal-beat grid exactly, micro-timing preserved as fractional beats; the
quantize family then applies in the beat domain. The selections/tracker path (§1) stays for
free recordings (→ §9b).

Missing primitives, in dependency order:
1. **`EventList.wallToBeat(sec, tempoEnv)`** — DONE (2026-07-11). Inverse of
   `beatToWall` (`EventList.sc:551`).
   Monotone piecewise: binary-search `prWallCum` for the segment, closed-form solve for step
   and flat-base ramp segments, bisection for the subsampled tempoMap×ramp case. The
   existing `prWallStarts`/`prWallCum` cache is exactly the structure the inverse needs.
   Base-only maps use `beatAt`; step segments and the held tail invert directly; flat-base
   ramps use the quadratic solution; tempoMap×ramp segments bisect the same cached
   approximation used by `beatToWall`. Non-positive composed wall time clamps to beat 0,
   matching `beatToWall`'s existing composed-map boundary behavior.
2. **Play epoch** — `EventList.play` (`:526`) captures nothing at start. Add a
   `lastPlayEpoch`: (SystemClock second at transport start, `from` beat, tempoEnv snapshot).
   `MIDIItem.record` already stamps `SystemClock.seconds - latency` (`MIDI-Item2.sc:1001`)
   and EventList schedules on SystemClock — same clock, so alignment is pure arithmetic.
3. **`list.captureFragment(take, voice:)`** — convert each recorded event's wall time via
   `wallToBeat`, insert into `events` with `when:` in beats. Build as the same insertion
   primitive as §9b's `list.addItem` — both recording modes use it.
4. **AudioItem per-take metadata sidecar** — takes are bare numbered files today, and
   `tempoFollowActions` ASSUMES the take was recorded on the list's base clock
   (`AudioItem.sc:176-183`; flat `\sourceBeatDur` is the only escape). Sidecar Event next to
   the audio file: start beat, list name, tempoMap/tempoEnv snapshot, latency convention,
   sample rate. A captured audio fragment becomes
   `(type: \audioItemTempoFollow, name:, take:, when: startBeat, ...)` that keeps
   re-stretching correctly after later tempo-track edits — the point of tempo-following
   playback. **Prereq: fix take-numbering-by-entries first (§5)** or every sidecar bumps the
   take count.
5. **Latency convention** — decide and record per take (§5 last item): MIDI subtracts server
   latency, Recorder audio contains hardware input latency; unrecorded, fragments sit a
   constant ~20-40 ms off-grid. **Ordering correction (2026-07-02): decide this BEFORE
   step 3 ships** — fragments captured before the convention exists (and is stamped in the
   step-4 sidecar) are permanently off-grid. Listed last only because it's a decision, not
   code; it's a prereq of 3/4, not a follow-on.

Sketch:
```supercollider
list.play(from: 8);
mi.record(mk);                          // wall time, as today
// ... perform ... ; mi.stop;
list.captureFragment(mi.take(-1), voice: \lead);
```

### 9b. Wild recording → mark beats → align (MIDI ~90% in place; audio needs §9c)
A wild recording + a saved selection IS a tempo map (`mi.take(-1).selection.tempomap`).
Alignment then has two existing routes:
- **Route A (non-destructive)** — `\mi2` event with `followTrack: true`:
  `VoiceSpace.prWarpItemToTrack` (`VoiceSpace.sc:593`) places internal notes at
  `originBeat + t/rate`, then through `beatToWall` → the item follows the composed tempo.
- **Route B (destructive)** — `mi.selection.quantize` rewrites timestamps to ideal beats;
  anything that treats timestamps as beats then works, incl. `asEventList`.

Caveats = the work items:
- **followTrack assumes timestamps are already beats**, so by default Route A treats recorded
  seconds as beats (`rel / rate`) — correct only when the base map is flat. Cleaner: a
  **`sourceTempoMap:`** key on the `\mi2` event; `prWarpItemToTrack` composes
  performedTime → idealBeat → listBeat → wall. Original take stays intact and
  `.curve`/`.smooth` variants stay swappable at play time.
  - **Narrow case DONE (2026-07-05): `sourceTempoMap: \eventList`.** When the item was
    recorded against the list's OWN tempoMap, the source map IS `list.tempoMap` — no extra
    plumbing. `prWarpItemToTrack` (`VoiceSpace.sc:593`) now inverts performedTime → idealBeat
    through `list.tempoMap` (anchored at `tm.timeAt(originBeat)`, via `prAtExtrapolated` on
    `env`) instead of `rel/rate`, so a `\tempoTrack` re-warps the body correctly. Exact by
    construction: with no track, `tm.timeAt(tm.at(x)) == x` reproduces the recorded timing.
    Requires an invertible `MIDIItemTempoMap` base (warns + falls back to flat otherwise);
    needs `followTrack: true` (the flag only affects the warp, not the route gate).
  - **Still open — the general case:** `sourceTempoMap: <a DIFFERENT map>` (e.g.
    `mi.selection.tempomap` for a take recorded off a foreign clock). Same seam, but the
    source map is not `list.tempoMap`, so it needs the map passed/stamped on the event.
- ~~**Route A is VoiceSpace-only**~~ — CLOSED 2026-07-06 by §10: the followTrack warp now
  lives in `EventList.prEmitMi2Follow` and `EventList.play` routes through prepare/fire,
  so `followTrack: \mi2` works with or without a VoiceSpace.
- **`t0` offset trap in Route B** — `warpTo` (`MIDI-Item2.sc:1322`) yields `idealBeat + t0`,
  so a pickup/initial rest offsets every "beat" by the first anchor's absolute time. Need
  `quantize(rebase:)` or `from`/`trimTimeStampsToStart` before treating timestamps as list
  beats. (`asEventList` already subtracts `t0` correctly, `ParamSpace.sc:129`.)
- **No merge convenience** — `asEventList` builds a NEW list; want
  `list.addItem(player, at: beat, voice:)` (shared with §9a step 3).
- Tempo matching is already handled: `mi.bps`/`bpm` (`MIDI-Item2.sc:1721-1724`) measures the
  wild tempo; `\mi2`'s `rate = tempo/stretch` scales fragment-beats to list-beats for
  half/double-time takes.

**Audio wild bits — the `sourceTempoMap` generalization.** Selections/gui/tracker are
MIDI-only, and `srcOffset` in `tempoFollowActions`/`tempoFollowEnvActions` supports only the
list's base clock or a FLAT `\sourceBeatDur`. Generalize `srcOffset` to accept a per-take
irregular map (`sourceTempoMap.timeAt(beat)`) — the same key and convention as the `\mi2`
case above: **one seam, both media**. (Ownership note 2026-07-02: THIS doc owns the
`sourceTempoMap:` seam design; `retune-project.md` §2e describes the same seam from the
consumer side and defers here — keep edits here first.) Authoring the map for audio is §9c; available TODAY
with zero new code: tap along on a MicroKeys while recording (or while listening back),
record the taps as a MIDIItem, mark/save its selection, use that map as the audio take's
`sourceTempoMap`.

**Server-side integration (`Sweep`) — where it fits and where it doesn't (2026-07-06).**
`Sweep.kr(trig, rate)` outputs ∫rate dt, i.e. a real-time integrator — but it is CAUSAL:
it answers "what beat is it now", never "when will beat 37 land", so it cannot replace
the prepare-time beat→wall integrals (§10 needs future spans to stamp bundles ahead of
time), and a stateful block-rate float32 integrator is neither reproducible nor as
precise as the language-side cached sub-grid. Where it genuinely fits:
- **Tempo-follow playback by exact phase** — replace the 0.25-beat segment chopping in
  `tempoFollowActions` with one phase-driven player,
  `BufRd(phase: startFrame + Sweep(rate: sourceRate))`: sample-exact integration removes
  segment-boundary seams and the §10e caveat (env-mode within-segment rates approximate
  under nested followTrack). RubberBand env mode already integrates its rate input
  implicitly; this is the exact version of that idea.
- **Live beat-position bus** — a synth integrating the composed tempo onto a control bus:
  playhead guis, server-side beat-threshold triggering, visual sync.
- **§9a capture cross-check** — sample that bus at note-on to stamp recorded events with
  beats. Keep it as a CROSS-CHECK only: the planned language-side `wallToBeat` inverse is
  exact against the composed map and replayable; the bus read adds round-trip jitter.

### 9c. Audio beat marking (gui + detection)
Two big pieces already exist:
- **`RetuneItem` note model** (`Retune.sc:195`) — offline pitch tracking turns a take into
  midiEvents (timestamp/dur/sustain/midinote), and `AbstractRetune : AbstractMidiEvents`
  means audio notes INHERIT the selection machinery
  (`selectedNotes`/`markSelection`/`prSelectionArgs`/`quantize`, `MIDI-Item2.sc:733-807`).
  `MIDIItemTempoMap.init` only asks its item for `midiEvents`/`bounds`/`closingAnchor`
  (`:1689-1697`) — a `RetunePlayer` satisfies all three. Gap: `tempomap`/`tempoMap`/`bps`
  sit on `MIDIItemPlayer` (`:1557-1566`), not `AbstractMidiEvents` — move them up.
- **`MIDIBeatTracker` is media-agnostic** (`BeatTracker.sc:22`) — needs only `timestamp`
  (+ `amp`/`sustain`/`midinote` for salience, all gracefully defaulted). Zero changes to run
  on retune notes or onset events; audio-specific salience (detection strength instead of
  chord/bass bonuses) is a one-liner via the `salienceFunc` hook (`:15`).

To build, in order (1-2 are pure-language + archive I/O; only 4 needs the server):
1. **Extract `BeatMarkMode` from `MIDIItem.gui`** (`MIDI-Item2.sc:121-500`). The machinery —
   `effTime`/`rebuildGrid`/`updateExtrapSelection`/`applyManualPick`/`repin`/
   `scheduleClicks` + the e/E/j/k/w/c key handling — is already media-agnostic (touches only
   `notes[i].timestamp` and salience fields). Follow the `PianoRollNav` precedent (already
   shared by both guis, `Retune.sc:33`). Controller owns gridLines/currentLine/pins/
   selection; host hooks: `drawOver(pen, timeToX)`, `audition(fromTime)`,
   `onSave(selectionEvent)` (abstracts away the `respondsTo(\takes)` dance in the current
   `w` handler). Rehost `MIDIItem.gui` first — behavior-preserving, verifiable against the
   current gui. This is what prevents a third copy later.
2. **`(times, beats)` map constructor + persisted anchors.** The map shouldn't need a fake
   MIDI item — the note model is just the PICKER for anchor times (dovetails with §4d).
   **Storage superseded (2026-07-02):** the `_beats/<name>_<num>.beats` sidecar originally
   specced here duplicated `retune-project.md` §2e's versioned warp-anchor archive (unified
   dir + `kind` field; Tune anchors are a superset of bare anchors) — two stores for the
   same artifact on one take would silently disagree. §2e OWNS the on-disk schema; this
   step's deliverable is the `(times, beats)` constructor + reading anchors from that
   archive. The semantics carried over: append-only versioned, no-op-on-identical (like
   `addSelection`, `MIDI-Item2.sc:1106`). IMPORTANT: store anchor **times** (seconds),
   not note indices — retune indices are unstable across `reanalyze`/split/merge; timestamps
   are ground truth from the audio. After this step pitched audio works END-TO-END with no
   new gui (mark via `take.retune.gui` indices + code), de-risking step 3. Result:
   `take.beatSelection.tempomap` → `sourceTempoMap:` (§9b) → wild audio on the list's grid.
3. **Beat mode + waveform in the retune gui.** The genuinely new UI is small:
   `SoundFile.readData` → per-pixel min/max peaks drawn behind the note blocks (cache per
   zoom; decimate channel 0 for long files). Transport is SIMPLER than MIDI's: one PlayBuf
   synth with startPos (`\retunePreview` already does it, `Retune.sc:542`), no MicroKeys CC
   chasing; hihat clicks live in the controller. Put beat mode inside `AbstractRetune.gui`
   first (note model already on screen); split into an `AudioBeatView` only if crowded.
4. **`trackOnsetsOffline`** for unpitched/percussive takes — pitch segmentation only fires
   on voiced material and smears onsets ~±30-80 ms (median filter / min-frames): fine for
   marking by ear, poor for drums. Sibling of `VocoderPattern.trackPitchOffline`
   (`Retune.sc:297`): `Onsets.kr(FFT)` + `Amplitude.kr` to a buffer → onset events
   `(timestamp:, amp: strength)` → same gui, same tracker. `Onsets` is core SC; the
   OfflineProcess quark is installed if the NRT plumbing helps; no aubio on this machine.

---

## 10. EventList `prepare(epoch)` / `fire` split + nested `\eventList` composition

Design of record (sketched 2026-07-05). **IMPLEMENTED 2026-07-06** — see §10e for what
landed and where it deviates from the sketches below. Headless suite:
`standalone-tests/prepare-fire-test.scd` (27 checks, all passing; also serves as the
compile check). Two problems share one fix:

- **Play-start "late" messages.** `VoiceSpace.playFrom` sorts everything into one
  `pending` list and fires it from a `Routine` on SystemClock (`VoiceSpace.sc:811-820`).
  Every beat-0 event has `delay ≈ 0`, so the initial cluster runs back-to-back with
  `wait(0)` between actions — and several are expensive AT that instant: each
  `followTrack:\mi2` `warped.play` schedules hundreds of `clock.sched` calls
  (`MIDI-Item2.sc:1386`), per-voice `startVoice` compiles/`d_recv`s SynthDefs, `Effect.bus`
  allocates buses. Each consumes wall-time while the Routine's logical clock is frozen at 0
  → the later zero-delay actions run physically late → "late N".
- **Nesting `\eventList` events.** Goal: insert `type:\eventList` events into other lists.
  Today's event type fires the child at RUNTIME (`EventList.sc:18`,
  `~eventList…play(~start)`), so the child's whole beat-0 cluster runs inside a single
  parent action (re-creating the stall one level down), its clock start is anchored to a
  jittery language time (leads stack, don't compose), and the child plays on its OWN clock
  ignoring the parent's `tempoTrack` (same class of bug as `\mi2 followTrack` before §9b).

**The fix — separate prepare (all language/allocation work, synchronous) from fire (dispatch
pre-timestamped bundles).** `prepare` resolves the whole list — and any nested `\eventList`
events — into a flat schedule of absolute-timed server sends against a SHARED epoch; `fire`
just schedules them. The beat-0 cluster is then paid ONCE, up front, in a lead window before
the epoch, for the entire nested tree. This is the concrete form of §4d's "list → wall"
composition and §9b's "one seam" (insert-a-sublist == insert-a-warped-item).

### 10a. Schedule element + `prepare(epoch, from, place)`
Each entry: `( time: <absWallSeconds>, send: {…}, label: <sym> )`. `time` is ABSOLUTE
(SystemClock.seconds frame); `send` is lightweight (fires an already-built synth/bundle — no
warping/compiling/allocation, that all happened during prepare).

The key abstraction is `place`: "given a beat in THIS list's frame, what absolute wall-second
does it land on?" Top-level lists get the default; nested lists get a `place` from the parent.

```supercollider
// EventList
prepare { |epoch, from = 0, place|
    var sched    = List[];
    var tempoEnv = this.tempoEnv;                       // EventList.sc:434
    var fromWall = this.beatToWall(from, tempoEnv);
    place = place ?? { |beat| epoch + (this.beatToWall(beat, tempoEnv) - fromWall) };
    this.scopedEvents.do { |ev|
        (this.shouldPlay(ev) and: { ev[\tempoTrack].isNil }).if {
            (ev[\type] == \eventList).if {
                sched.addAll(this.prExpandList(ev, epoch, place, tempoEnv));   // hook, §10b
            } {
                // per-type builders REUSED but RETURNING [absTime, send] instead of
                // scheduling a clock:
                //   \mi2 followTrack     → prWarpItemToTrack, each warped note flattened to
                //                          (place.(noteBeat), send) — no inner TempoClock,
                //                          which structurally retires the queueSize:65536 hack
                //   audioItemTempoFollow → tempoFollowActions, times rebased onto `place`
                //   plain event          → ( place.(ev[\when]?0), { ev.copy.play } )
                sched.addAll(this.prEmit(ev, place, tempoEnv, epoch));
            }
        }
    };
    // voices (keyFrame) aggregate across the whole timeline, not per-event — the current
    // tls.keysValuesDo block becomes prepareVoices, emitting (place.(firstBeat), startVoice)
    // + env-write sends. Its existing firstWall/delayWall math just routes through `place`.
    voiceSpace !? { sched.addAll(voiceSpace.prepareVoices(this, epoch, from, place)) };
    ^sched
}
```

### 10b. The `\eventList` expansion hook
Mirrors the `\mi2` `followTrack` / `sourceTempoMap:\eventList` / `rate` convention (§9b), so
"insert a sublist" and "insert a warped item" share semantics:

```supercollider
prExpandList { |ev, epoch, place, tempoEnv|
    var child = ev[\eventList].isKindOf(EventList).if { ev[\eventList] } { EventList(ev[\eventList]) };
    var b0    = ev[\when] ? 0;                          // insert point, PARENT beats
    var cFrom = ev[\start] ? 0;                         // child start beat
    var rate  = (ev[\tempo] ? 1) / (ev[\stretch] ? 1);
    var childPlace;
    (ev[\followTrack] == true).if {
        // FOLLOW: child rides the PARENT's tempoTrack. child-beat k reinterpreted in the
        // parent frame (b0 + (k-cFrom)/rate) then placed through the parent's map.
        childPlace = { |cBeat| place.(b0 + ((cBeat - cFrom) / rate)) };
    } {
        // OWN TEMPO: child keeps its own beat→wall, shifted so cFrom lands at parent wall(b0).
        var cEnv = child.tempoEnv, cFromWall, anchor = place.(b0);
        cFromWall = child.beatToWall(cFrom, cEnv);
        childPlace = { |cBeat| anchor + (child.beatToWall(cBeat, cEnv) - cFromWall) };
    };
    ^child.prepare(epoch, cFrom, childPlace)   // recurse: whole tree shares one epoch
}
```

### 10c. `fire` + `play` wiring (the lead falls out here)
```supercollider
fire { |sched|
    var lat = Server.default.latency;
    sched.do { |item|
        // run the send `lat` early; it bundles at +lat → lands at item.time.
        SystemClock.schedAbs(item.time - lat, { item.send.value; nil })
    }
}
play { |from = 0|
    var t0 = SystemClock.seconds, lead = this.leadTime ? 0.25, epoch = t0 + lead;
    var sched = this.prepare(epoch, from);             // ALL heavy work here, before epoch
    var spent = SystemClock.seconds - t0;
    (spent > lead).if { var d = spent - lead + 0.02;   // adaptive: never already-late
        epoch = epoch + d; sched.do { |i| i.time = i.time + d } };
    this.fire(sched);
}
```

### 10d. Sharp edges / open decisions
- **`\eventList` is dual-interpretation.** Under `play` it's an expansion directive consumed
  by `prepare` (never a runtime `.play`). Keep the existing runtime event type
  (`EventList.sc:18`) for the PREVIEW path only — preview is inherently runtime, doesn't nest.
- **Voices are the one non-trivial builder.** `prepareVoices` must emit "start synth at
  `place.(firstBeat)`, then env-writes" rather than one send per event — a refactor of the
  `tls.keysValuesDo` block (`VoiceSpace.sc:705`), same shape (it already computes
  `firstWall`/`delayWall`).
- **Flattening `\mi2` into the parent schedule retires the queue hack.** Each warped note as
  its own `(absTime, send)` removes the inner `TempoClock(1, queueSize:65536)` entirely.
- **`Effect.bus` lifetime.** Buses/effect synths allocate during prepare and must not be
  idle-freed by `DetectSilence` (`Effect.sc:55`, default `time:1`) before `epoch` — safe at
  `lead ≈ 0.25`; don't set a huge lead. (Or give prepared effects `maxDur`/no-silence-free.)
- **`copyFrom` already drops `tempoMap`/`beatDur`/`solo`/`mute`** (§5) — fix before nested
  lists copy, or nested children play flat.
- **Preview vs prepare divergence risk** — two code paths for "how an event sounds." Keep the
  per-type `send` builders shared between `prEmit` and the preview event types where possible.
- Relationship to milestones: this is milestone-7-adjacent (composition seam) but stands
  alone; the `place`-composition is the same math as `prWarpItemToTrack`'s
  `sourceTempoMap:\eventList` (done §9b) generalized from one item to a whole list.

### 10e. As built (2026-07-06) — deltas from the sketches above
Landed in `EventList.sc` (`prepare`/`prExpandList`/`prEmit`/`prEmitMi2Follow`/`fire`/
`stop`/`prPlayPrepared`, `leadTime` ivar), `VoiceSpace.sc` (`prepareVoices`, `rescaleEnv`
via `place`, `playFrom` now a shim to `list.play`), `MIDI-Item2.sc` (`MIDIItemPlayer.play`
optional `sched:` hook), `AudioItem.sc` (`wallAt` arg on both tempoFollow builders).

- **Adding a nested list requires `newType: \eventList`**, not `type:` — `dispatch`
  overwrites `\type` with `newType ? defaultType` on every add. (Or register a route:
  `addRoute(\eventList, \eventList)`.)
- The §10a sketch's `place = place ?? { |beat| … }` was a bug — `??` calls the block with
  no args. Built as `place ?? { { |beat| … } }` (block returning the function).
- `prExpandList` resolves names via `EventList.at` (warn on unknown), NOT `EventList(name)`
  — the constructor registers a fresh empty list and reassigns `current` as a side effect.
- **Cycle guard**: `prepare(epoch, from, place, seen)` threads an IdentitySet of ancestors;
  cyclic nesting warns and returns empty rather than recursing forever.
- **from-trim**: followTrack children trim exactly (`cFrom += (from - b0) * rate`, the \mi2
  convention). Own-tempo children can't trim exactly without `wallToBeat` (§9a step 1);
  their pre-epoch entries are dropped in `prPlayPrepared` instead (tolerance 1 ms).
- `prWarpItemToTrack` MOVED from VoiceSpace to `EventList.prEmitMi2Follow`, converted to
  beat-domain warp + `place` placement, and flattened through the new `MIDIItemPlayer.play
  sched:` hook — so mk resolution/CC store/`playing` bookkeeping are reused, no inner
  TempoClock exists on this path (queue hack retired there; the sealed `\mi2` event type
  keeps its private clock for preview/standalone), and **followTrack \mi2 now also works
  under plain `EventList.play`** (closes part of §9b's "Route A is VoiceSpace-only").
- `fire` = ONE Routine on SystemClock walking the sorted schedule, each send fired
  `latency` early (sends self-bundle at +latency, landing on time). NOT the sketch's
  per-entry `schedAbs`: that put one slot per entry in SystemClock's fixed-size GLOBAL
  queue, so a flattened \mi2 take overflowed it ("scheduler queue is full") and silently
  dropped everything after — found on first live test 2026-07-06. Lightweight sends make
  the single-routine dispatch safe (the §10 premise); regression-tested with a 5000-entry
  list. Cancellation: generation counter `prPlayGen` — `EventList.stop` bumps it (the
  routine breaks at its next wake), replay auto-cancels the previous generation.
  VoiceSpace's `scheduledRoutine`/`stop` remain only as legacy no-ops for that path.
- **`leadTime` = deterministic prepare BUDGET** (Michael's call 2026-07-06, replacing the
  sketch's fixed 0.25 pre-roll): with `leadTime` set, the first sound lands at exactly
  `leadTime + s.latency` after the play call — same philosophy as server latency: fix the
  wait, don't minimize it. Choose it slightly above the list's prepare cost; if the budget
  is OVERRUN the epoch slides (with a warning) because sliding beats a late storm.
  `leadTime` nil = adaptive ASAP start (prepare-end + latency + 0.02), minimal but not
  deterministic. Since sends fire `latency` early, the language-side deadline for the
  first entry is `epoch - latency` = t0 + leadTime.
- **The epoch anchors to LOGICAL time** (`thisThread.seconds` at `.play`), like all sclang
  scheduling — so events co-evaluated with `.play` align by construction: a
  `(lag: leadTime)` event sounds exactly on the list's first beat, wrapped in a fork or
  not. (Found via Michael's fork/unwrap experiment: with a physical-time anchor,
  same-block work before `.play` — e.g. `tempoMap.curve(1)` — delayed the list relative
  to a co-evaluated lag note; forking past a `wait` re-aligned logical to physical and
  hid it.) Consequence: the budget must cover logical drift (same-block eval work before
  `.play`) + prepare; the overrun warning reports the combined figure. The safety
  deadline check itself stays PHYSICAL (`Main.elapsedTime`) — that part of the earlier
  "never anchor to SystemClock.seconds" note still stands; it's the epoch that is logical.
- **Ramp-segment sub-grid cache** (`prBuildRampSub`/`prRampSubAt`): `beatToWall` for a
  beat inside a ramp (`\lin` etc.) segment over a tempoMap base used to re-integrate the
  sub-sampled ramp from the segment start on EVERY call — 383 µs/call on the real guide
  list (env `[step, lin]`), which put ~0.2 s of the 0.22 s prepare inside the ramp window
  and made `leadTime: 0` feel like a lag-0.35 note. The wall cache now stores a cumulative
  sub-grid (same 16 steps/beat scheme, fixed grid) per such segment; in-ramp lookups are
  O(1) (~6 µs). Verified against a brute-force integral in the headless suite.
- **Anchor/measure with `Main.elapsedTime`, never `SystemClock.seconds`** —
  `SystemClock.seconds` is the calling thread's LOGICAL time, frozen for an entire
  synchronous evaluation. The first build anchored the epoch to it: prepare cost read as
  zero, the epoch sat Δ (eval lag + prepare) in the physical past, and since bundles are
  stamped logical + latency, every send left with latency - Δ of headroom → "late" storms
  whenever Δ > latency (empirically looked like "leadTime must be ≥ 2× s.latency" — it was
  really latency + Δ). Fixed 2026-07-06; the fire routine needed no change (its waits
  target absolute times, and SystemClock re-aligns logical to physical at each wake).
- **`copyFrom` now carries `beatDur`/`tempoMap`/`solo`/`mute`** (§5 item done — decision:
  mix state travels with the copy).
- `tempoFollowEnvActions` under a nested followTrack `place`: segment boundaries are exact
  but within-segment rate multipliers still come from the child's own tempoEnv (noted in
  the method comment). Non-env mode is exact (rates derive from wallAt diffs).
- **NOT done — voices still do heavy work at fire time.** `prepareVoices` emits entries
  (times through `place`, so nested lists with voiceSpaces compose) but the send bodies
  still `startVoice`/compile env synths inside `Server.default.bind` when they fire; the
  §10 "all allocation in prepare" ideal would need Function→SynthDef precompilation
  (`asSynthDef`/`d_recv` during the lead, `/s_new` at fire). Do it if voice-heavy lists
  still post "late"; the \mi2 flattening was the dominant beat-0 cost.
- Headless-test caveat: a stock `sclang <file>.scd` run loads startup functions that
  ATTACH to the running scsynth (client login, cached SynthDef loads, StageLimiter) —
  exit does not /quit it, but don't loop the suite while the live rig is up.
