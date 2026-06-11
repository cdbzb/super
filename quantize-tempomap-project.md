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
| **resolution** | how many control points / anchors? | `choiceFunc` (manual) | interval anchoring |
| **between-anchor shape** | how to flow between control points? | `.curve` | (done) |
| **at-anchor fidelity** | pass *through* anchors, or *near* them? | (none — always through) | `.smooth` / approximation |

`.curve` is **interpolation** (honors anchors exactly). The jitter problem is that the
anchors themselves are noisy, so we also want **approximation** (pass near, not through)
and **resolution control** (fewer, structural anchors). They compose:

```
anchorEvery(n)  →  .curve(amount)  →  .smooth(amount)   (each optional)
   resolution        shape              residual fidelity
```

---

## 3. Hanging design items (from the 2026-06-08/09 discussion)

### 3a. Interval anchoring — `anchorEvery(n, mode, reduce)`  ← recommended first build
Reduce anchor density to every Nth point. Lower density can't represent high-frequency
wobble (Nyquist), so it low-passes the tempo while staying musically legible ("trust the
bar lines"). `interval 1` == current behavior.

Decisions:
- **`mode: \note` vs `\beat`.** `\note` = index stride (trivial: `indices[(0, n ..)]`), only
  musical if notes are evenly spaced in beats. `\beat` = anchor at beats 0, N, 2N… (bar grid);
  needs each note's beat position and a rule when no note sits on the anchor beat (nearest-note
  snap, or interpolate a synthetic anchor time). Start with `\note`; `\beat` needs a per-note
  beat list at call time — **confirmed available** (2026-06-10): a saved selection's `beats`
  spans integrate to per-anchor beat positions, and `MIDIItemTempoMap.at` gives any note's
  beat position from its timestamp.
- **`reduce: \pick` vs `\mean`.** Pure pick-every-Nth **aliases** sub-grid jitter into the
  low-frequency tempo. `\mean` (bin-average the notes in each interval = non-overlapping
  `quantizeWindow`) is the robust default.
- **Pin endpoints** — always keep first & last note as anchors so the map spans the full
  region and total duration is preserved.
- Implementation: build anchor indices from stride → **re-aggregate `beats`** (each new gap =
  sum of original beats it spans) → feed the existing `invEnv`/`.curve` machinery. API as a
  composable transform (`t.anchorEvery(4, mode: \note, reduce: \mean)`), not a constructor arg.

Likely outcome: **interval-anchoring + `.curve` alone covers most jitter**; spectral smoothing
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

---

## 5. Known bugs / cleanup backlog
- [ ] `polynomial` ivar never assigned → `mapBeatsPoly` dead (`TempoMap.sc:3,29`).
- [ ] `quantizeDft` rect/hamming asymmetry (`TempoMap.sc:85-86`).
- [ ] `warpTo(t.tempoMap)` truncates vs `warpTo(t)` carries forward (§3e).
- [ ] MIDIItem `quantize` takes `beats` at face value (→ 4c).
- [ ] Machine-confirm the carry-forward boundary fix (see Testing notes).
- [x] `chaseCCs` `[nil]` on CC-less region; `notesStraddling` exact-onset duplicate;
      `from()` partial rebase (straddlers/chased CCs) — fixed 2026-06-10.
- [ ] Stamp `mi.player` with `takeIndex` when `midiEvents === takes.last` (selection
      addressing from the post-record player; see §1 scoping contract).
- [ ] `AbstractMidiEvents.doesNotUnderstand` error path does `class + "doesnt understand"`
      → masks real errors with `Message '+' not understood`.
- [ ] Deferred beat-domain selectors: `beats` (per-note positions), `beatOf`, `beatFilter`,
      `onBeats` (designed 2026-06-10, only `fromBeat` + upstream built).
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
1. **`anchorEvery(n, mode:\note, reduce:\mean)`** + endpoint pinning + beats re-aggregation.
   Lowest effort, likely highest payoff. (§3a)
2. **`.smooth`** pragmatic version over `quantizeWindow`; fix `quantizeDft` windowing. (§3b, 3d)
3. **Carry-forward / `t.tempoMap` consistency** + machine-confirm boundary. (§3e, §5)
4. **`quantizeInPlace` auto-scale** + **high-pass ("keep jitter") filter**. (§4b, 4c)
5. ~~**Interactive quantization tool** prototype.~~ (§4a — done 2026-06-09/10, see §1 Selections)
6. **Unify TempoMap / MIDIItemTempoMap** (or method-parity audit). (§4d)
7. (stretch) **Monotone smoothing-spline** λ unifier, and/or B-spline approximation. (§3b, 3c)

---

## 7. Testing notes
- These are **pure-language** tests (no audio server needed) — `MIDIItemTempoMap`, `warpTo`,
  `mapBeats`, `quantize*` are all language-side.
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
  pins, tunable weights).
- `Trek/MW-Classes/TempoMap.sc` — quantize family (`:67`–`:130`).
- `Trek/MW-Classes/plusArray.sc` — array `warpTo` / `warpToTempoMap` dispatch.
- Journal seed: `~/home/org_roam_files/org.org` (Jun 09, 2026).
