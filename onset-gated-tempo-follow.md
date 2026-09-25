# Onset-gated tempo follow (AudioItem)

Status: design, 2026-09-24. Unimplemented; ByteDance detection tested on vibes.
Step 12 of `audio-beat-marking-plan.md`.

## Problem
Segment mode (`tempoFollowActions`) re-starts RubberBand every `segBeats` (0.25) with a
30 ms crossfade: rate jumps + crossfades land mid-sustain (smear/phasiness on vibes).
`\env` mode is one continuous synth but its rate is `1/tempoMult` only — it ignores the
source map (marks/stamp), so a take not played on the list's base clock runs at the wrong
speed (`totalSourceDur` computed, unused — `AudioItem.sc:835`).

## Idea
This is `retune-project.md` §9 ("Anchors for non-tune audio") applied to tempo follow:
note onsets, transients and hand-placed marks are all **anchors** feeding the same
src↔output warp and the same per-segment renderer (`tempoFollowActions`). The one new rule
here: **rate changes only at anchors**, where the attack masks it.
1. Anchor times (file seconds) from whichever source you pick (below).
2. Beat per anchor: `srcMap.beatAt(t)` (marks / stamp / whatever resolved).
3. Wall per anchor: `wallAt.(beat)` (tempoMap + `\tempoTrack` + `align:`).
4. Per-note rate = source IOI / wall IOI. Exact at every anchor; tempo averaged within a note.

## Playback options
- **A — segment mode, anchor boundaries.** Replace the `segBeats` grid with anchor beats;
  pre-roll each synth a few ms so the fade doesn't eat the attack. ~20 lines. Quick test.
- **B — one synth, stepped rate (preferred).** `\env`-style single RubberBand; rate Env
  with `\step` curves at anchor wall times, levels from step 4. No crossfades. Correct
  kr-block quantization drift (~1.45 ms/change) by computing levels from block-rounded
  times, or run the rate env at audio rate.

## Anchor sources
Chosen **by hand** — no per-item defaults, no inference. Tempo follow reads only times.

| Method | Code | Output | Status |
|---|---|---|---|
| `\attack` | `Take.transients` / `TakeTransients` (SC `Onsets`, NRT, backtracked) | times | exists |
| `\melody` | `Take.retune` / `RetuneItem` notes (FluidPitch + `prSegment`) | mono notes | exists; piano-roll edit + versions |
| `\keyboard` | ByteDance (`~/tank/piano-transcribe`, Python) | poly notes | new |

- Basic Pitch: optional, only if Retune's segmentation fails on legato/polyphonic
  material. madmom dropped unless SC `Onsets` proves weak.
- `\keyboard` notes use RetuneItem's note fields (`timestamp`, `dur`, `midinote`,
  `srcStart`, `srcDur`, `\key`) so the Retune piano roll can show them. The Retune model is
  monophonic: for tempo follow collapse chords to one anchor (40 ms cluster).
- Shared post-processing: chord-cluster merge, minimum-gap merge (~1/16 beat, avoids rate
  chatter in tremolos/runs), per-method latency correction.
- No anchor data → fall back to the grid + warn. Detection never runs at play time.

### Proposed API (not built)
- `method:` becomes one more `TakeTransients` param (so it is in the cache key):
  `Take(\vibes, 0).transients(method: \keyboard)`; default `\attack` = current SC path.
  Python methods run `detect.py` via `unixCmd` and return the same Event shape.
  (Not a new `Take.detect` — `TakeTransients.detect` already means "uncached".)
- **Detection is cached, not versioned**: output is a pure function of file (size+mtime),
  method and params, same as `TakeTransients` today. **Versions only for hand edits**
  (deleted false hits / added missed ones), like marks and Retune edits in TakeArchive.
- GUI: `Take(\vibes, 0).gui(method: \keyboard)` already flows (gui passes kwargs to
  detection); add a key to re-detect with another method; draw pitch on ticks when present.
- `onset_audit.py --compare a,b` overlays two methods.

## Test: ByteDance on vibes (2026-09-24)
`vibes-test-1201` take 0 (87 s, 48 kHz mono) through
`~/tank/piano-transcribe/transcribe.py`: 28 s (3.1x realtime), 55 notes / 54 onsets
(MIDI 60–90), minimum IOI 0.31 s, median 1.32 s. Against librosa `onset_detect`: 52/54
matched within 50 ms, ByteDance ~20 ms earlier (librosa marks the flux peak, after the
attack). librosa found 26 onsets ByteDance didn't, mostly weak; the strong ones cluster at
79–85 s. **Checked by ear with the piano-roll page below: ByteDance works for vibes
onsets.**
Audit page (take + transcription synth, L/R split, librosa-only onsets flagged):
https://claude.ai/artifact/Bn6VMeuu4BgjDKkjuKAWT9. Rebuild for any take with
`~/tank/piano-transcribe/onset_audit.py TAKE.wav [OUT.html] [--mid X.mid]` (templates in
`onset_audit/`), then publish the HTML.

## Event surface
`tempoFollowMode: \transients` (not `\onsets` — in this codebase "onset" means a MIDI
note-on, "transient" an audio hit; see `TakeTransients.sc`), `transientMethod: \keyboard`
(+ params, read from cache), or `transientsVersion: N` for a hand-edited set. Composes
with `followTrack: \marks`.

## Side fix
`\env` rate should be `k / tempoMult`, `k = totalSourceDur / list.baseWallDelta(fromBeat, lastBeat)`,
so endpoints land even without onsets.
