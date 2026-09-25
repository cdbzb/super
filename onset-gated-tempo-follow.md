# Per-note tempo follow (AudioItem)

Status: design, 2026-09-25 (revised after two reviews; vocabulary settled). Unimplemented;
ByteDance detection tested on vibes. Step 12 of `audio-beat-marking-plan.md`. (Filename
keeps the old "onset-gated" name so references resolve.)

**Scope.** This doc owns: note detection (methods, API, cache), the per-note rule, the
tempo-follow event surface, the `\env` fix. `retune-project.md` §2e owns: the two-span note
model and its fields, `moveNote` / note quantize, the renderer choice (fork 3), the
note-timing editor (fork 5), and the version event key (fork 6). Decisions on those are
made there, not here.

**Vocabulary**
- *note*: a start time (file seconds), plus dur / pitch / vel when the method gives them.
  `Take.notes(method)` with method `\transients | \keyboard | \melody`. A note from
  `\transients` is a start + strength only.
- *note start*: where per-note tempo follow may change rate.
- *transient*: an audio hit from SC `Onsets` (`TakeTransients`); `\transients` notes are
  transients.
- *mark*: a saved beat line (TakeGui `w`); marks are stored as anchors.
- *anchor*: a pinned source↔beat point (marks, record stamps). Reserved for that.
- *onset*: a MIDI note-on (existing code). Not used for audio.

## Problem
Segment mode (`AudioItem.tempoFollowActions`, `AudioItem.sc:639`) starts a new RubberBand
synth every `segBeats` (0.25). Each boundary gets a 30 ms fade-in, and each synth runs
`2·fade` (60 ms) past its boundary at the old rate (`sustain: wallDur + fade * 2`,
`:751`). Rate jumps and overlapping synths land mid-sustain (smear/phasiness on vibes).
`\env` mode (`tempoFollowEnvActions`, `:770`) is one continuous synth and uses the source
map for its endpoints (`:815–834`), but between them its rate is `1/tempoMult` only, so a
take not played on the list's base clock runs at the wrong speed (`totalSourceDur` is
computed and unused, `:835`).

## Idea
`retune-project.md` §2e ("Anchors for non-tune audio") applied to tempo follow: notes feed
the same src↔output warp and the same renderer. The rule this doc adds: **rate changes only
at note starts**, where the attack masks it.
1. Note starts `t` (file seconds) from the chosen method (below).
2. Clip to the played range `(fromSec, endSec)`. Before the first mark the source is
   trimmed (`start = m.t0`, `AudioItem.sc:525`) **only when the marks' beat origin is 0**;
   marks on a stamp axis (`srcBeatOrigin > 0`) make `prSrcOffset` read below the first
   anchor (`AudioItem.sc:608–613`), and `AnchorTempoMap` extrapolates past both ends
   (`MIDI-Item2.sc:2668–2690`), so audio there plays. Note starts in an extrapolated
   region are allowed; warn if many fall there.
3. Beat per note start: `AudioItem.prSrcEndBeat(ev, list, b0, startSec, t, takeNum)`
   (`:622`), the exact inverse of `prSrcOffset`, so `t0`, `start`, map origins,
   `fromBeat`/`srcBeatOrigin`, `b0` and the `\eventList` (nil `srcMap`) case are all
   handled. Not `srcMap.beatAt(t)`, which ignores all of these. Verified exact for any `t`
   on every source branch (second review, 2026-09-25). `startSec` must be the **resolved**
   event's start (`m.t0` in trim mode, `AudioItem.sc:525`), not the user's `start:`.
4. Wall time per note start: `wallAt.(beat)` (tempoMap + `\tempoTrack` + `align:` + `place`).
5. Per-segment rate = Δ`srcOffset` / Δ`wallAt` between consecutive note starts, as segment
   mode computes it today (`:739`). Exact at every note start; tempo averaged within a note.

Segment boundaries that are not note starts: the first segment starts at `fromBeat`
(bisected under `align:` or a mid-list start, `:699–705`); without `\dur`,
`lastBeat = inf` (`:721`), so the last segment ends at `prSrcEndBeat(..., endSec)`.

## Playback
Renderer options and the decision: retune §2e fork 3. Requirements this doc adds for the
per-segment option (more than "~20 lines"):
- SynthDef envelope: the fade-out must end *before* the next note start, not `2·fade`
  after it, or the next attack plays twice at two rates. Add a pre-roll `p` so the fade-in
  ends at the attack: `startPos - p·rate`, `delay - p`. Clamp both: the first segment's
  delay is already `delay.max(0)` (`:741`), and `startPos` must not go below 0.
- The first and last boundaries above.
- Notes read from cache only (for `\transients`, `TakeTransients.load`,
  `TakeTransients.sc:58`, never renders; not `forTake`, `:67–80`, which starts an NRT
  render on a miss). Miss → segBeats grid + warn.

## Note methods
Chosen **by hand**; no per-item defaults, no inference. Tempo follow reads only starts.

| Method | Code | Gives | Status |
|---|---|---|---|
| `\transients` | `TakeTransients` (SC `Onsets`, NRT, backtracked) | starts + strength | exists (`Take.transients`) |
| `\melody` | `RetuneItem` notes (FluidPitch + `prSegment`) | mono notes | exists (`Take.retune`); piano-roll edit + versions |
| `\keyboard` | ByteDance (`~/tank/piano-transcribe/transcribe.py`) | poly notes | new |

- Basic Pitch: optional, only if Retune's segmentation fails on legato/polyphonic
  material. madmom dropped unless SC `Onsets` proves weak.
- `\melody` / `\keyboard` notes are stored **poly** in TakeArchive `midiEvents`, with the
  two-span fields defined in retune §2e and `notesSource: \keyboard | \melody`.
  `\keyboard` versions have **no pitch block**; RetuneItem loads only versions that have
  one (retune §2e step 4b). Chords are collapsed only when building note starts for tempo
  follow.
- Note-start post-processing, in this order:
  1. merge chord clusters in **file seconds** (40 ms), keeping the earliest time;
  2. map to beats (Idea step 3);
  3. minimum-gap merge in **beats** (~1/16 beat; avoids rate chatter in tremolos/runs).
- Per-method latency correction fixes **detector bias only** (e.g. residual Onsets lag
  after backtrack). Times stay raw file seconds (`TakeTransients.sc:4`); `t0` is applied
  by `prSrcEndBeat`, so nothing is corrected twice.

### Proposed API (not built)
- `Take(\vibes, 0).notes(\keyboard)`; `.notes(\transients)` wraps the existing
  `Take.transients`; `.notes(\melody)` answers `Take.retune`'s notes. Same Event shape
  (`timestamp`, `strength`, plus `dur`/`midinote`/`vel` when present).
- Caches, each keyed on **its own method's params** + file size/mtime:
  - `\transients`: the existing `_transients/` cache, **unchanged** (no method in its key,
    so existing caches stay valid; `TakeTransients.sc:45–48`).
  - `\keyboard`: a sibling `_notes/` cache; a new `detect.py` (not written yet;
    `~/tank/piano-transcribe` has `transcribe.py`, `batch.py`, `onset_audit.py`) run via
    `unixCmd`.
  - `\melody`: already persisted by RetuneItem in TakeArchive.
- **Detection is cached, not versioned.** Hand edits are versioned in TakeArchive:
  - `\transients` (deleted false hits, added missed ones): **their own block**,
    `transients: [...]` + `transientParams:`, recognised by presence (a new
    `TakeArchive.isTransients`, like `isMarks`/`isStamp`). **No `anchorSource`:** that key
    names where a version's *anchors* came from, and this block has times only.
  - `\keyboard` / `\melody`: `midiEvents` with `notesSource:`, as above.
- GUI: `Take(\vibes, 0).gui(notes: \keyboard)` shows those notes and snaps mark lines to
  their starts; default `\transients` (today's behaviour). For vibes, `\keyboard` is likely
  the better snap source (cleaner attacks than `Onsets`). Kwargs already reach TakeGui
  (`TakeGui.sc:498–500`); it needs a branch that loads notes instead of calling
  `TakeTransients` (`:41`). Draw pitch when present.
- **Key `n`** (free outside map-edit mode) cycles the snap source `\transients` →
  `\keyboard` → `\melody`, skipping methods with nothing cached. Practical because
  `prSetTransients` (`TakeGui.sc:70`) already rebuilds `BeatMarkMode` from any Event array
  with `timestamp`/`strength`, and `resume` restores a grid by *times* (plan step 4c), so
  lines re-snap to the new candidates. Resume from the **live** grid, not only the saved
  `marks[\selection]` (`:77`), or unsaved edits are lost on switch. `w` records the active
  method with the marks (the event's method fallback).
- `onset_audit.py --compare a,b` overlays two methods (not written yet).

## Test: ByteDance on vibes (2026-09-24)
`vibes-test-1201` take 0 (87 s, 48 kHz mono) through
`~/tank/piano-transcribe/transcribe.py`: 28 s (3.1x realtime), 55 notes / 54 note starts
(MIDI 60–90), minimum spacing 0.31 s, median 1.32 s. Against librosa `onset_detect`: 52/54
matched within 50 ms, ByteDance ~20 ms earlier (librosa marks the flux peak, after the
attack). librosa found 26 hits ByteDance didn't, mostly weak; the strong ones cluster at
79–85 s. **Checked by ear with the piano-roll page below: ByteDance works for vibes
notes.**
Audit page (take + transcription synth, L/R split, librosa-only hits flagged):
https://claude.ai/artifact/Bn6VMeuu4BgjDKkjuKAWT9. Rebuild for any take with
`~/tank/piano-transcribe/onset_audit.py TAKE.wav [OUT.html] [--mid X.mid]` (templates in
`onset_audit/`), then publish the HTML.

## Prototype results (2026-09-25, vibes take 0, by ear)
Runtime-only prototype (no class edits; session scratchpad, not kept): ByteDance note
starts, beats via `prSrcEndBeat`, list clock from `EventList.current`.
- **Per-segment (option A) rejected:** on vibes every crossfade is audible, even with the
  fade confined to 8 ms before each attack.
- **One synth, stepped rate (option B) chosen:** one RubberBand synth, `Env.step` rate
  levels; note starts rounded to control blocks and each rate computed from the rounded
  duration, so the integrated source equals the source span exactly (87.0587 s) — no drift.
- **Lead:** placing each rate step **50 ms of source before** the note start is an audible
  improvement (clearer attacks) over stepping at the attack; 30 ms less so. The lead moves
  the exact-sync points 50 ms early; within-note error ≈ lead × rate change (a few ms).
  Make it a parameter (`rateLead:`, default 0.05).
- Found on the way: marks v3 on this take count ~half the list's beats (rates 2.1–2.6× at
  scale 1). Listening used a beat-scale override (2–3). Needs re-marking or a marks beat
  scale; the §11 beat-scale check only covers stamped takes.

## Event surface
`tempoFollowMode: \notes, notes: \keyboard` (`\transients` | `\keyboard` | `\melody`).
Wiring needed:
- Dispatch is a two-way `== \env` test at two sites (`EventList.sc:1204`, `:2237`); make it
  three-way.
- Add `tempoFollowMode` and `notes` to `AudioItem.timingKeys` (`AudioItem.sc:423`), or an
  event without `followTrack` stays on the sealed path (`EventList.sc:2170`).
  **Behaviour change:** a bare `tempoFollowMode: \env` event (no `followTrack`) would then
  also take the follow path.
- Which cached set: the method plus params **taken from the marks version's detection
  params** (`transientParams`, `TakeGui.sc:105`; extend it to record the note method) unless
  given, so the event hits the cache the GUI wrote; or a pinned hand-edited version (key:
  retune §2e fork 6). Precedence for the method: explicit `notes:`, then the marks
  version's recorded method, then `\transients`.
- Composes with `followTrack: \marks`.

## Follow-on: note quantize (fixing misplaced notes)
Marks fix beats; a late note *between* beats needs per-note targets. Built in retune §2e
build step 4 (at the `AbstractWarp` level); per-note tempo follow is its `amount = 0` case.
Editor for moving notes by hand: retune §2e fork 5.

## `\env` fix
Endpoints-only fix: `rate = k / tempoMult`, `k = totalSourceDur / list.baseWallDelta(fromBeat,
lastBeat)`. **Not correct between endpoints** unless the source's seconds-per-beat stays
proportional to the base clock's: wrong for marks, for `\flat` over a tempoMap, and for a
stamp recorded under a varying `\tempoTrack` (source s/beat is `src'(x)`, wall s/beat is
`base'(x)·m(x)`, `EventList.sc:1524–1528`). Under `place` (`EventList.sc:2238`) even the
endpoints miss, because the EnvGen levels still come from the list's own `tempoEnv`
(`AudioItem.sc:767–769, 850–853`). EnvGen also ramps `m` linearly in wall time while
`beatToWall` ramps it linearly in beats.
**Proper fix:** build the rate levels as Δ`srcOffset` / Δ`wallAt` over the **union of the
`tempoEnv` breakpoints and the source map's anchors** (e.g. marks); today's points are
`tempoEnv` only (`AudioItem.sc:838–850`). That is the one-synth stepped-rate renderer of
retune fork 3; specify it once, there.
