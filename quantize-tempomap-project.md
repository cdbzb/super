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
- Note (2026-07-01): `\beat` mode gets easier once §9a lands — for guide-track recordings
  every note's beat position comes free from `wallToBeat`, so don't build `\beat` solely
  around the selection machinery.

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
- **Build gate (2026-07-02):** don't start `.smooth` until `anchorEvery` + `.curve`
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
answers `timeAt(beat)`, `beatAt(time)`, `mapDurs(array)` plus a **stated** extrapolation
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
  freeze `timeAt(beat)` / `beatAt(time)` / `mapDurs(array)` + the extrapolation-policy
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
- [ ] **[M0]** Machine-confirm the carry-forward boundary fix (see Testing notes).
- [x] `chaseCCs` `[nil]` on CC-less region; `notesStraddling` exact-onset duplicate;
      `from()` partial rebase (straddlers/chased CCs) — fixed 2026-06-10.
- [ ] Stamp `mi.player` with `takeIndex` when `midiEvents === takes.last` (selection
      addressing from the post-record player; see §1 scoping contract).
- [ ] `AbstractMidiEvents.doesNotUnderstand` error path does `class + "doesnt understand"`
      → masks real errors with `Message '+' not understood`.
- [ ] Deferred beat-domain selectors: `beats` (per-note positions), `beatOf`, `beatFilter`,
      `onBeats` (designed 2026-06-10, only `fromBeat` + upstream built).

Found in the 2026-07-01 review:
- [ ] **[M0]** **`TempoMap.quantizeRangeInPlace` writes to wrong indices** (`TempoMap.sc:92-99`):
      `(start..end).do{|i| dursCopy.put(start+i, quantized[i])}` — `.do` yields the VALUES
      `start, start+1, …`, so it writes at `start+start …` and reads past `quantized`'s end
      (size is only `end-start+1`). Only correct when `start == 0`. Should be
      `quantized.do{|v i| dursCopy.put(start+i, v)}`. Also `quantize`'s range branch defaults
      `end = durs.size` (`:73`) — one past the last index; `quantizeRange` then slices a nil.
- [ ] **[M0]** **`TempoMap.env` goes stale after any mutation** — built once in `init` (`:18`);
      `beats_`/`durs_` (`:21-28`) only rebuild `timesIn*`, and `quantizeWindow` (`:107`)
      mutates `result.durs` in place, patching `timesInDurs` but never `env`. Since
      `at`/`mapBeats` read `env`, a `quantizeWindow` result MAPS LIKE THE UNQUANTIZED
      ORIGINAL. **Blocks §3b's pragmatic `.smooth`** (which delegates to `quantizeWindow`) —
      fix first. Simplest: computed `env` property, or one shared `prRebuild` from init +
      both setters. Also two leftover `.postln`s in `quantizeWindow`.
- [ ] **[M0]** **`TempoMap.mapBeats:55` clamp is a no-op** — `b.collect{|i| 0.000001 max: i};` result
      discarded.
- [ ] **[M0]** **`mapBeats` silently changes array length** — `.select(_.isStrictlyPositive)` in
      `TempoMap.mapBeats` (`:56`), `MIDIItemTempoMap.mapBeats` (`MIDI-Item2.sc:1767`), and
      `warpToArray` (`plusArray.sc:106`) DROPS non-positive durs, so a Pbind's `\dur` desyncs
      from its `\midinote` array from that point on — worse than the glitch it avoids. Clamp
      to epsilon (what the dead `:55` line intended) to preserve alignment. Same "silent
      length change" family as the fixed boundary truncation.
- [ ] **`EventList.copyFrom` drops `tempoMap` and `beatDur`** (`EventList.sc:58-69`) — copies
      lose the base tempo and play flat 1 s/beat. (`solo`/`mute` also dropped — decide and
      comment either way.)
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
0. **Headless regression suite + fix-before-build** (added 2026-07-02). A pure-language test
   file (`sclang <file>.scd` headless, or UnitTest2) over TempoMap/MIDIItemTempoMap
   invariants: env/invEnv round-trip, anchors preserved through `.curve`, `mapBeats`
   preserves array length, `quantize(0)` == identity, range-quantize writes the right
   indices, carry-forward boundary values. Fix the **[M0]**-tagged §5 bugs in this
   milestone, driven by the failing tests: env staleness, `quantizeRangeInPlace` indices,
   `end = durs.size` off-by-one, `mapBeats` clamp/length. Also freeze the protocol names
   (`timeAt`/`beatAt`/`mapDurs` — §4d) as thin aliases so all later milestones code to them.
   Rationale: every recompile reboots the server, so regressions must be caught headless;
   and milestone 1's `reduce: \mean` can't be verified against a broken `quantizeWindow`.
1. **`anchorEvery(n, mode:\note, reduce:\mean)`** + endpoint pinning + beats re-aggregation.
   Lowest effort, likely highest payoff. (§3a)
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
1. **`EventList.wallToBeat(sec, tempoEnv)`** — inverse of `beatToWall` (`EventList.sc:478`).
   Monotone piecewise: binary-search `prWallCum` for the segment, closed-form solve for step
   and flat-base ramp segments, bisection for the subsampled tempoMap×ramp case. The
   existing `prWallStarts`/`prWallCum` cache is exactly the structure the inverse needs.
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
- **followTrack assumes timestamps are already beats**, so today Route A REQUIRES Route B's
  quantize first. Cleaner: a **`sourceTempoMap:`** key on the `\mi2` event
  (`mi.selection.tempomap`); `prWarpItemToTrack` composes
  performedTime → idealBeat → listBeat → wall. Original take stays intact and
  `.curve`/`.smooth` variants stay swappable at play time.
- **Route A is VoiceSpace-only** — plain `EventList.play` (`EventList.sc:545-563`) has no
  followTrack branch; a `\mi2` there plays on a private constant TempoClock
  (`MIDI-Item2.sc:1174-1180`): onset aligned, internals not. Port route (c) into
  `EventList.play`, or at least warn when a `followTrack:` event plays without a VoiceSpace.
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
