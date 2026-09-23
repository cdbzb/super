# Audio beat marking — build plan (drafted 2026-09-22, two review passes)

Goal: do for AudioItem takes what `AbstractMidiEvents.gui` already does for MIDI:
mark beats, derive a tempo map, edit it on the tempo lane. This **includes
non-melodic material** (drums, percussion, speech). Picks snap to detected transients
or are placed and dragged by hand. The resulting map warps the take onto an EventList
grid through the existing `sourceTempoMap:` seam.

Supersedes the ordering in `quantize-tempomap-project.md` §9c steps 2–4. Step 1 there
(the `BeatMarkMode` extraction) is done. `retune-project.md` §2e still owns the archive
schema; this plan adds one writer and one reader and fixes one filter.

---

## Status (2026-09-23, branch `audio-beat-marking`)

M1 (steps 1–6) built; step 7 (DP time pins) not started; M3 (steps 8–11:
interface cleanup with `sourceTempoMap:` as the one timing field, `align:`,
named sources and functions over `~marks` / `~stamp`, stamped-take repair)
planned.

| Step | State | Suite |
|---|---|---|
| 1 rename `TakeArchive` | done | `take-archive-stamp-test` (alias checks) |
| 2a MonoMap as `sourceTempoMap:` | done | `source-map-monomap-test` |
| 2b `isStamp` | done | `take-archive-stamp-test` |
| 2c sealed-path `prEventT0` | done — **no test** (server-bound) | — |
| 3 `TakeTransients` | done | `take-transients-test` (NRT, 5/5 hits, 0.04 ms) |
| 4a click math | done | `beat-mark-test` |
| 4b `gridTimes` + picks | done — **changes MIDI gui clicks/lane** | `beat-mark-test`, `map-editor-test` |
| 4c save/resume by times | done | `beat-mark-test` |
| 4d free pins (pick mode) | done | `beat-mark-test` |
| 5 `TakeGui`, marks API, `loadMap`, `take.tempoMap` | done — **needs a hands-on session**; key strip + `?` help window added | `take-marks-test`, `take-gui-smoke` (opens a window) |
| 3′ NRT silent for clientID ≠ 0 | fixed (OfflineProcess default group) | `take-transients-test` (clientID-1 check) |
| 6 `addItem(marks:)`, `prResolveMarks` | done — **no listening check yet** | `take-marks-playback-test` |
| 7 DP time pins | not started | — |
| 8 interface cleanup, one timing field (drop `marks:`) | planned | parity test (planned) |
| 9 `align:` for audio | planned | — |
| 10 `sourceTempoMap:` names + functions (`~marks`, `~stamp`) | planned | — |
| 11 stamp seeding + automatic `at:` | planned | — |

Unverified by ear or eye: `TakeGui` interaction feel (drag, snap, lane), click
and playback alignment in the window, and a marked drum take playing on a list
grid (plan §6 acceptance, sealed vs follow).

---

## Vocabulary

One word per concept. New names follow what the codebase already says
(`quantize-tempomap-project.md` §12d).

| Concept | Name | Lives in |
|---|---|---|
| Versioned per-take history | `TakeArchive` (née `RetuneArchive`, alias kept) | `Retune.sc` |
| Record-time clock version | **stamp**: `writeStamp` / `loadStamp` / `isStamp` | `TakeArchive` |
| Beat-marked version | **marks**: `writeMarks` / `loadMarks(name, num, version)` | `TakeArchive` |
| Version origin | `anchorSource: \recordStamp \| \beatMark` | archive Event |
| (time, beat) point of a map or archive | **anchor** (`anchors`, `xs`/`ys`), and nothing else | MonoMap / archive |
| Detected hit in audio | **transient** `(timestamp:, amp:, strength:)` | `TakeTransients` |
| Detector call / cache | `take.transients(action:, force:)`, `_transients/` | `Take` |
| MIDI note-on window query | `onsets(fromBeat, toBeat)`, unchanged | `MIDIItemPlayer` |
| Hand choice on the grid | **pick** (`manualPicks`); **pin** = DP-forced beat; **free pin** = pin with no note under it | `BeatMarkMode` |
| DP start point | `seedTime` (`anchorIndex` kept as alias) | `MIDIBeatTracker` |
| Beat times on screen | `gridTimes` (fixed to include the picks) | `BeatMarkMode` |
| Persisted marking state | `selectionEvent` (+ `anchors`, pick/pin times) / `resume` | `BeatMarkMode` |
| Click math | `*clickSchedule`, `*localPeriod` | `BeatMarkMode` (class side) |
| Committed map | `MapEditor.last`, converted where it is used | `MapEditor` |
| Take's marked tempo map | `take.tempoMap(version)` → `AnchorTempoMap` | `Take` |
| Take window | `take.gui` / `TakeGui` | new `TakeGui.sc` |
| Timing source of an audio event | `sourceTempoMap:` — a map, `\marks` / `\stamp` / `\eventList` / `\flat`, or a function over `~marks` `~stamp` `~list` `~flat` (step 10); `marksVersion: N`. (`marks:` from step 6 is removed in step 8.) | audio events |

Notes:
- **Words kept apart.** "Onset" keeps meaning a MIDI note-on (`MIDIItemPlayer.onsets`)
  and "transient" means an audio hit. `AudioItem.takeOnset` (a latency probe) is
  unchanged.
- **Strength vs salience.** `strength` is the detector's ODF peak; `salience` stays the
  tracker's derived weight.
- **camelCase.** New names use `tempoMap`, never `tempomap`.

---

## 0. Where we are

Built, and media-agnostic (they read only `timestamp` and seconds):

| Piece | File | Status |
|---|---|---|
| `BeatMarkMode`: e/E grid, h/l/j/k, DP pins, save/resume | `BeatMarkMode.sc` | done; hosted only by the MIDI gui |
| `MapEditor`: tempo lane, span ops, undo, audition, commit | `MapEditor.sc` | done; hosted only by the MIDI gui |
| `MIDIBeatTracker`: Ellis DP, `salienceFunc` hook | `BeatTracker.sc` | done |
| `(times, beats)` constructors | `MapEditor.mapFromTimes`, `AnchorMap.fromAnchors`, `AnchorTempoMap` | done |
| v2 archive with `anchors:` + `anchorSource:` | `RetuneArchive`, `Retune.sc` | schema done; only writer is `writeStamp` |
| `sourceTempoMap:` seam | `AudioItem.prSrcOffset` / `prSrcEndBeat` | needs `beatDomain`/`timeDomain`; a bare `AnchorMap` throws (step 2) |
| `EventList.addItem(take, at:)` | `EventList.sc` `prAddAudioItem` | done; plays the record stamp, takes no map |

`AbstractRetune.gui` is a pitch piano roll. The §9c idea of hosting beat mode there
is dropped: `RetuneItem` runs pitch analysis on construction, which is wasted (and
fails) on unpitched material. The host is a Take window; the retune gui can embed it
later.

---

## 1. Rename `RetuneArchive` → `TakeArchive` (independent — can land any time)

Why: the class already stores record stamps (no pitch) and is about to store marks
(no pitch). Pitch became an optional block in the 2026-07-13 schema. `TakeArchive`
matches the `Take` class and its `(name, num)` identity.

- Rename the class. Keep `RetuneArchive : TakeArchive {}` as an alias: everything is
  class-side and there are no classvars, so it inherits cleanly.
- Update the hardcoded `"RetuneArchive.…"` warning strings.
- Scope, about 40 references: `Retune.sc` (12), `AudioItem.sc` (5), `EventList.sc`
  (1), `retune-archive-test.scd` (15), `audioitem-t0-test.scd` (2), docs (7).
- **Unchanged:** the on-disk `_retune/` folder (22 take dirs on the NAS) and the
  `retuneVersion:` key.
- Nothing depends on this step. Alternative: fold it into the `retune-project.md`
  §2e renames (Tune/Clip) for a single churn.
- Acceptance: both archive suites pass after the name change; a take recorded before
  the rename still loads its stamp.

---

## 2. Fixes to existing code (small; land first)

**2a. Any MonoMap works as `sourceTempoMap:`.** `MapEditor.last` is a bare
`AnchorMap`. `prSrcOffset` checks only `respondsTo(\timeAt)`, then calls
`sm.beatDomain.first`, which throws doesNotUnderstand. `EventList.prSrcTimeAt` does the
same. So the hint `MapEditor.commit` prints (`MapEditor.sc:325`) is wrong today, for
MIDI too.
- Fix: convert where the map is used, as `warpTo` already does
  (`MIDI-Item2.sc:1722`): `sm.isKindOf(MonoMap).if { sm = sm.asAnchorTempoMap }`.
- `commit` and `last` don't change, and the hint becomes true.

**2b. `loadStamp` reads stamps only.**
- `TakeArchive.isStamp(d)` = `recordedAgainst.notNil and: { anchors >= 2 } and:
  { (anchorSource ? \recordStamp) == \recordStamp }`.
- Used by `loadStamp`, `AudioItem.repinRoundTrip` (which duplicates the predicate
  today) and `RetuneItem.prInit`'s anchor scan (`Retune.sc:394-397`), which currently
  takes the newest version that has anchors, whatever its source.
- Marks versions never carry `recordedAgainst`.
- `RetuneItem` doesn't use marks, so it needs no marks field.

**2c. Sealed-path `t0` parity.** The sealed `\audioItem` branch adds `AudioItem.t0`
unconditionally (`AudioItem.sc:163`) and ignores `sourceMapIsPhysical`. Switch it to
`prEventT0(ev, takeNum)` so both playback paths agree.

Tests:
- a bare `AnchorMap` as `sourceTempoMap:` plays;
- a stamp, then a marks version: `recordedMap` still answers the stamp;
- `repinRoundTrip` after a marks version leaves `loadMarks` unchanged;
- sealed and follow paths agree on a stamped take.

---

## 3. `TakeTransients` — detection (headless, testable)

Output: a time-sorted Array of transient Events `(timestamp:, amp:, strength:)`. It
works directly as `BeatMarkMode` notes and as `MIDIBeatTracker` input.

- **Detection.** Follow `trackPitchOffline` (`OfflineProcess.putKr`,
  `vocoders.sc:315-343`): `Onsets.kr(FFT(LocalBuf(...)), thresh, odftype)` +
  `Amplitude.kr` + the ODF value as kr channels. Read the result with `SoundFile`,
  never `Buffer.read`, so the user's server is not touched. Peak-picking happens in
  sclang.
- **Leading-edge backtrack.** `Onsets` fires about one FFT window late (512 samples
  ≈ 10 ms). Walk back through the file's amplitude envelope to where it crosses a
  fraction of the local peak, bounded by the window and the previous transient.
- **API.** `take.transients(action:, force:, odftype:, thresh:, minGap:, channel:)`.
  One form: `action` receives the Array, synchronously on a cache hit and after the
  render on a miss. The method answers the cached Array or nil. Routine callers wrap
  the call in a `Condition`.
- **Cache.** `_transients/<name>_<num>/<hash>.archive`, hashed over params and the
  file's size/mtime. It must NOT be created under `_retune/<name>_<num>/`: creating
  that dir blocks `RetuneItem`'s legacy migration (`Retune.sc:380`).
- **Salience.** `TakeTransients.salienceFunc` = normalised `strength`, handed to
  `MIDIBeatTracker`.
- **Scaling.** A take can have thousands of transients. Two loops are O(n²):
  `MIDIBeatTracker.prCalcSaliences` (`BeatTracker.sc:40`) and
  `BeatMarkMode.rebuildGrid` (`BeatMarkMode.sc:74`). Use a binary search over the
  time-sorted notes. Behaviour-preserving for MIDI.
- Tests (`standalone-tests/take-transients-test.scd`):
  - a synthetic click train rendered NRT; detected times within 1 ms of the truth;
  - a cache hit on the second call;
  - a param change misses the cache.

---

## 4. `BeatMarkMode` changes (pure language)

**4a. Click math, class-side.** Move the inline `scheduleClicks` / `localPeriod` /
count-in math out of `AbstractMidiEvents.gui` (`MIDI-Item2.sc:148-200`) into
`BeatMarkMode.clickSchedule(times, fromTime, countIn)` → `[[delay, amp], ...]` and
`BeatMarkMode.localPeriod(times, t)`. The MIDI gui calls them; nothing else changes. A
full transport controller is not planned: revisit only if `TakeGui` duplicates more
than this.

**4b. `gridTimes` includes the picks.** Today it holds only gridLines. It leaves out
the manual picks, and in DP mode the seed note too. So a map built from it starts
*after* the first mark, in the MIDI lane as well. Fix the one method; there is no
second list.
- **Behaviour change for MIDI:** clicks and snapping will now include the hand picks.
  Verify that in the MIDI gui.

**4c. Save by times.** `selectionEvent` additionally writes `anchors: [(src, beat)]`
(the picks + grid lines in time order, with beat = line position) and pick/pin
**times**. `resume` prefers `anchors`: it re-attaches each one to the nearest note
within `tol` (15 ms), or keeps it as a free pin. It falls back to `indices` for old
MIDI saves.
- Add `\anchors` to `addSelection`'s dedupe keys (`MIDI-Item2.sc:1411`).
- One save/resume path for both media.

**4d. Free pins in pick (e) mode.** A line state `pinned: true, time: t, noteIndex:
nil`. `effTime` already falls back to `\time`, so drawing, `gridTimes` and map
building need no change.
- `manualIndices` becomes `manualPicks`: `(time:, noteIndex: | nil)` entries, with
  `anchorPair` built from them.
- A free pin re-extrapolates the lines after it, like a pick.

Tests (extend `map-editor-test.scd` or add `beat-mark-test.scd`):
- `gridTimes` starts at the first pick;
- save → change transient params → resume gives the same anchor times;
- a free pin with no note nearby survives resume;
- old index-only MIDI saves still resume.

---

## 5. `TakeGui` — the Take window

`take.gui` opens a window over one take. No pitch analysis.

- **Waveform.** `SoundFile.readData` in chunks → a min/max peak pyramid (256-sample
  bins, coarser levels derived from it). Channel 0 or a mono sum.
- **Transient ticks**, alpha by strength.
- **Controllers.** `BeatMarkMode(transients, fileDur)`, and `MapEditor` with
  `sourceFunc = { [beatMark.gridTimes ?? { savedAnchorTimes }, 1] }`.
  `beatMark.draw`, `mapEd.drawLane` and `drawEditOverlay` already exist.
- **Navigation.** `PianoRollNav` for time; the pitch axis goes unused.
- **Playback.** PlayBuf from the cursor via a new n-channel preview SynthDef
  (`\retunePreview`, `vocoders.sc:275`, is mono). Clicks come from
  `BeatMarkMode.clickSchedule`. Everything is in file seconds, so there is no `t0`
  shift while auditioning.
- **Mouse.**
  - Drag a grid line and release: it snaps to the nearest transient within a pixel
    tolerance. Alt: no snap, which makes a free pin.
  - Double-click empty space: add a free pin.
  - Right-click: remove a pick or pin.
- **Save (`w`).** `TakeArchive.writeMarks(name, num, selectionEvent)` → a version with
  `anchorSource: \beatMark`, `anchors`, the resume block and the transient-cache hash.
  **`W`** (MapEditor commit) writes the edited map's anchors the same way, so every
  committed map has a version number.
- Acceptance: open a drum take, E on two hits → the DP grid follows the playing, the
  lane shows the map, `w` persists it, reopening restores it, and clicks line up by
  ear.

---

## 6. Playback from marks

- **`take.tempoMap(version)`** → an `AnchorTempoMap` over `TakeArchive.loadMarks`
  (newest by default).
  - `initAnchors` rebases both axes to 0 and keeps the first src time as `t0`
    (`MIDI-Item2.sc:2538`), so `timeDomain.first == 0` always.
- *(Superseded by steps 8/10: `marks:` becomes `sourceTempoMap: \\marks` + `marksVersion:`.)*
- **`EventList.addItem(take, at:, marks: N)`** (`marks: true` = newest) →
  `\audioItemTempoFollow` with `marks: N`. The map is resolved from the archive at
  prepare time, so the list survives a restart. `prAddAudioItem` sets these frame
  rules itself, not the caller:
  - `start: map.t0`. **Not** `timeDomain.first`, which is 0. Same rule as
    `EventList.sc:2303`.
  - `sourceMapIsPhysical: true`: anchors are file positions and already include the
    recording delay.
  - `at:` places the first marked beat (content start), mirroring
    `EventList.itemAnchorBeat`.
- In-session, with no archive, `sourceTempoMap: MapEditor.last` works once step 2a
  lands.
- **Precedence** on a stamped take: marks > record stamp. Rewrite `prAddAudioItem`'s
  comment: naming a map is now intended.
- Acceptance:
  - mark a click-track take, place it at beat 8 on a list with a tempo change; the
    replayed transient lands within 2 ms on both the sealed and follow paths, stamped
    and unstamped;
  - a listening check on a real drum take.

---

## 7. Later: DP pins by time

Only needed for free pins inside **DP (E) mode**; pick mode already has them (4d).

- `MIDIBeatTracker.prTrackSegment(tStart, tEnd, forcedIdx | nil)`, with a virtual end
  node for a pin that has no note under it.
- `anchorIndex` becomes `seedTime`; index pins are still accepted and converted on
  entry.
- In `BeatMarkMode`, `pinSet`, `repin` and the `currentLine` lookup move to times.
- **No synthetic-note shortcut.** Inserting fake notes shifts every later index, and
  appending them unsorted breaks the DP's time-ordered early exit
  (`BeatTracker.sc:96-100`).
- Regression test: DP with time pins equals DP with the equivalent index pins on MIDI
  data.

---

## 8. Interface cleanup — one event dialect, one timing resolver

Drift found after M1 (2026-09-23): three surfaces play an audio take and disagree.

| | `add(newType: \audioItem)` | `add(newType: \audioItemTempoFollow)` | `addItem(take, at:)` |
|---|---|---|---|
| Playback | one synth, plays straight (`PlayBuf`) | segment-by-segment, follows the list's tempo | builds the middle column |
| Timing source | none, or what `followTrack:` routes to | `sourceTempoMap:` / `sourceBeatDur:` / stamp / list clock | same, plus `marks:` |
| `followTrack: true` | follow, take seconds read as beats | n/a | n/a |
| Bare default | plays straight | follows (stamp, else list clock) | stamp |
| `marks:` | **silently ignored** | honoured | honoured |
| `start:` | file seconds, `t0` added | file seconds, `t0` added | forced 0, **overwritten** by marks |
| `align:` | no | no | refused for audio (works for MIDI) |

Everything that decides the source clock today — more than one resolver:

| Key / path | What it does | Where |
|---|---|---|
| `sourceTempoMap:` | a map object; MIDI also `\eventList` | `prSrcOffset` / `prSrcEndBeat`, `prEmitMi2Follow` |
| `sourceBeatDur:` | flat seconds per beat | `prSrcOffset` |
| `sourceMapIsPhysical:` | the map already includes the recording delay → renamed `sourceMapIncludesLatency:` (rule 3) | `prEventT0` |
| `followTrack: <value>` | audio: map → `sourceTempoMap:`; `true`/`\flat` → `sourceBeatDur: 1`; `\eventList` → nothing (= default) | `prForwardAudioFollow` (EventList.sc:2118) |
| `followTrack: <value>` on `\mi2` | read DIRECTLY as the source map | `prEmitMi2Follow` (EventList.sc:2312) |
| `marks:` | which marks version (step 6) | `prResolveMarks` |
| record stamp, both forms | the default: in-memory (list/tempoEnv/when) or disk (anchors) | `prSrcOffset` AND `prSrcEndBeat` (two copies) |
| list base clock | the last fallback | `prSrcOffset`, `prSrcEndBeat` |

Rules:
1. **The event is the single source of truth.** Every feature is an event key,
   resolved at prepare time. `addItem` only fills keys (`when:` from `at:`,
   `item`/`take` from the Take, `type: \audioItem, followTrack: \eventList`) and
   forwards every other keyword into the event. `addItem` never grows another
   parameter. The parity test (rule 8) compares against exactly that event.
2. **One resolver, `prResolveSourceMap`, and it ALWAYS answers a map** — also when no
   timing key is given (then: stamp if stamped, else the list clock). The stamp and
   list-clock branches are deleted from `prSrcOffset` / `prSrcEndBeat`, which from
   then on only read a map. Both stamp forms go through ONE builder (the existing
   `prStampAnchors` → `AnchorMap.fromAnchors(beats, src + t0)`), so in-memory and disk
   stamps can no longer disagree.
3. **One timing field: `sourceTempoMap:`.** **`marks:` is removed** (unmerged branch
   only) → `sourceTempoMap: \marks`, with `marksVersion: N`. `sourceBeatDur: d`
   becomes the parameter of `\flat` (kept as a key, read only by the resolver).
   **`sourceMapIsPhysical:` → `sourceMapIncludesLatency:`** (boolean, same default
   false = add the take's `t0`): true says the map's seconds are file positions,
   drawn on the waveform, so they already contain the recording delay. Written by
   hand only for a hand-built map object; for names and functions the resolver sets
   it. The old key is read as an alias.
4. **`followTrack:` only turns following on.** `true` / `\eventList` forward NOTHING
   — they mean "follow, default source" (today's `\eventList` meaning; forwarding it
   as a named source would silently drop every take's stamp). A map value, or
   `\flat`, forwards into `sourceTempoMap:`. `\mi2`'s direct read of `followTrack`
   (EventList.sc:2312) goes through the same resolver, so both media agree.
5. **One type: `\audioItem`.** Following is decided by keys: `followTrack:`, and any
   timing key (`sourceTempoMap:`, `sourceBeatDur:`, `align:`) implies it — except
   that `record: true` while armed stays on the sealed recording path
   (EventList.sc:2153). `\audioItemTempoFollow` = alias for `\audioItem` +
   `followTrack: \eventList`.
6. **One timing order:** `sourceTempoMap:` (any form) → `sourceBeatDur:` (`\flat`)
   → record stamp → list clock — all inside the resolver. `align:` is a blend on top.
7. **`start:` trims, it never shifts.** For a resolved map, `start:` seconds skip
   source before `origin + start`, and every beat stays where the map puts it
   (the origin is the map's first anchor's file second, `t0`). Shifting source
   against beats would put no marked beat on a list beat. (Today `prResolveMarks`
   OVERWRITES a user `start:` — a live bug, e.g. org.org:325
   `e.addItem(a, start:2, dur:4, at:-2, marks:true)`.)
   **`startBeat: b`** (decided 2026-09-23): start playback at beat `b` of the source
   map — the take's audio from that beat on, with beat `b` sounding at
   `when: + (b - map's first beat)`, i.e. the map is NOT re-based; to put beat `b`
   at list beat 8, use `at: 8 - b` or `offset:`. `dur:` still counts beats from where
   playback starts. `start:` (seconds) and `startBeat:` together: the later of the
   two wins, with a warning.
8. **Key table for both media**, and a **parity test**: for a set of keys,
   `addItem(take, at:, …)` and the hand-written event of rule 1 prepare the same
   schedule.

Migration: `take-marks-playback-test.scd` and org.org:325-326 move off `marks:`; an
unknown Symbol in `sourceTempoMap:` (e.g. the test's `\mine`) now warns.

---

## 9. `align:` for audio — quantize strength (segment path)

`align: a`: 0 = as performed, 1 = every beat of the source map on its list beat.
Same sense as `prExpandBlended` (EventList.sc:2076): blend **wall time at a fixed
source beat** — at each segment node,
`wallB = blend(anchorW + (src(bt) - src(b0)), wallAt(bt), a)` — not source position
at a fixed list beat (not equivalent). `fromBeat` for a mid-list `from` is bisected
the way `prBisectBeat` does; delays stay relative to `wallAt(from)`.

**Segment path (`tempoFollowActions`) only.** The env path (`tempoFollowEnvActions`)
uses the source map only for its two endpoints and takes its rate from `tempoEnv`
(AudioItem.sc:717), so it ignores a marks map's inner tempo already — `align:` and
`\marks` on `tempoFollowMode: \env` warn. Building env levels from the blended rates
is deferred.

---

## 10. `sourceTempoMap:` — names and functions

```supercollider
sourceTempoMap: aMap                         // a map object, as today
sourceTempoMap: \marks                       // or \stamp, \eventList (list clock), \flat
sourceTempoMap: { ~stamp.quantize(0.5) }     // a function, evaluated with .use
```

- **Function environment: `~marks`, `~stamp`, `~take` only.** `~list` / `~flat` are
  cut: the list clock is a FunctionMap `asAnchorTempoMap` refuses, it needs the file
  length and a stated beat axis, and `~list` would clash with the `list:` every lazy
  function already sees. They stay available as NAMES. `.use` form only — an `|arg|`
  form would clash with the lazy convention (argument = the event).
- **One frame for every candidate:** a MonoMap, beat → FILE seconds, so the MapEditor
  vocabulary works (`quantize(amount, from, to)`, `curve`, `ritardSpan`,
  `setBpm(bpm, from, to)`, `transformSpan`).
  - marks: stored in file seconds;
  - stamp: src is 0 at record fire, round trip NOT baked (\raw), so offered as
    `src + t0`; beats are the list beats (`+ stamp[\when]` on the rebased disk form);
    `recordedAgainst.start` is the record event's own key and is NOT added.
  - the resolver sets `sourceMapIncludesLatency: true` itself for names and functions.
- **Beat origin survives.** `AnchorTempoMap`'s `initAnchors` drops the first beat
  (keeps only the first time as `t0`), so the resolver reads the result's
  `xs.first` BEFORE converting. Placement rule: `when:` is the list beat of the
  map's beat axis origin — for a map in list beats (stamp; stamped-take marks, step
  11) `when:` defaults to 0 offset and the result's `xs.first` places it; for a
  0-based map (unstamped marks, a hand map) the first beat lands at `when:` as today.
  So a splice that starts on the stamp does not play off by (first mark − record beat).
- **Not a lazy value, for either medium.** `\sourceTempoMap` joins the (global)
  `EventList.lazyExclude`, and `\mi2` resolves through the same resolver (names
  `\eventList` / `\flat` and map objects there; no `~marks` / `~stamp`), so a
  Function on a MIDI event keeps working instead of silently playing flat
  (EventList.sc:2327).
- **The inverse sense, documented:** the function edits where the beats ARE. 
  `{ ~stamp.quantize }` pretends the take was steadier, which corrects LESS.
  Quantize strength is `align:`.

Tests: each form = its hand-built equivalent; `~stamp` in file seconds, no double
`t0`, both stamp forms identical; a missing `\marks` warns and falls back; a
Function on `\mi2` still resolves; beat origin kept through conversion.

---

## 11. Stamped takes — fix a sloppy take recorded against a list

The stamp says where the beats SHOULD be; marks say where they ARE.
`sourceTempoMap: \marks` plays the correction; `{ ~stamp.… }` edits the expectation.

1. **Seed the grid from the stamp.** In `TakeGui`, a key draws one line per stamped
   beat (expected times, file seconds) and snaps each to the nearest transient within
   tolerance (`moveLine` logic); lines with nothing near stay where the stamp puts
   them. Plus the stamp overlay step 5 promised.
2. **On a stamped take, `w` writes marks in LIST beats** (open decision 3 → absolute
   beats for stamped takes; unstamped stay 0-based). The first mark's list beat comes
   from the stamp (first mark's file second → stamp map), **rounded** — to 1, or
   `prAlignGrid` (EventList.sc:701) — so first-beat sloppiness is not baked into
   every beat. The rounding happens in the window, where it is visible; the resolver
   does no alignment. Stamp seeding makes marks beats = stamp beats by construction.
   - **Beat-scale check:** marks count grid lines; if the user marked half notes the
     scale is off. Compare the marks' beat span to the stamp's over the same file
     span; warn when the ratio is not ~1.
   - Marks before the record-fire point get beats below the record beat — fine,
     `\carry` extrapolates.
3. **Automatic `at:`** falls out of rule 10's placement: a list-beat map places
   itself (`xs.first`), so `addItem(take, sourceTempoMap: \marks)` needs no `at:` on
   a stamped take. Unstamped takes still need `at:`.
4. **Partial marks / splices.** With marks and stamp on one beat axis, a function
   can splice them (`~stamp` outside, `~marks` inside); a built-in splice is deferred
   until a real case needs it.

With `align:` on top, you choose how much of the sloppiness to fix.

---

## Milestones

```
1 rename (any time, independent)

2 fixes ─┬──────────────────────────┐
3 transients ─┐                     │
4 BeatMarkMode ┴─ 5 TakeGui ────────┴─ 6 playback from marks      = M1
                                                                    7 DP time pins = M2
```

- **M1** = 2–6. You can mark drums with snapped picks and free pins, edit the map, save
  it, and play the take on a list grid. This covers almost all of the goal.
- 2, 3 and 4 are independent of each other.
- **M2** = step 7. Only for hand pins that the DP tracker must respect.
- **M3** = 8 → 9 → 10 → 11. The cleanup first, so `align:` and the
  `sourceTempoMap:` forms land as plain event keys on one timing field; stamp
  seeding last (it uses the resolver's marks-to-stamp alignment). Independent of M2.

## Open decisions (recommended default in bold)

1. Rename: **now as step 1, independent** / fold into the §2e Tune/Clip renames.
2. Detector: **NRT `Onsets.kr` via `putKr` + backtrack** / language-side spectral flux /
   aubio (not installed).
3. Marks beat origin: **0 at the first mark** / absolute list beats like stamps.
4. `gridTimes` including picks in the MIDI gui: **yes (bug fix)** / audio host only.

## Review log

- **Pass 1 (2026-09-22), correctness.** Adopted:
  - the AnchorMap domain crash;
  - `start: map.t0`;
  - sealed-path `t0` parity;
  - the stamp/marks split;
  - `putKr`, SoundFile reads, the async API and window-sized backtrack;
  - a cache folder outside `_retune/`;
  - the O(n²) loops;
  - the beat-0 source;
  - the mono preview;
  - dropping the synthetic-note stopgap;
  - persisting by version.
- **Pass 3 (2026-09-23), M3 steps 8–11.** Adopted: `followTrack: true/\eventList`
    forward nothing (else every stamp is dropped); ONE resolver that always answers
    a map, stamp/list branches deleted from `prSrcOffset`/`prSrcEndBeat`, one stamp
    builder; `sourceBeatDur` folded into `\flat`; `\mi2` through the same resolver;
    `start:` trims instead of shifting (and the live overwrite bug); beat origin read
    before `AnchorTempoMap` conversion; stamped-take marks written in list beats,
    rounded in the window, with a beat-scale check; `~list`/`~flat` cut from the
    function environment, `.use` only; `align:` on the segment path only, blending
    wall time at a fixed source beat; record+armed stays sealed; parity against the
    exact event `addItem` emits; migration of `marks:` users.
- **Pass 2 (2026-09-22), simplification + naming.** Adopted:
  - convert MonoMaps where used, instead of a second `MapEditor.lastTempoMap`;
  - `anchorSource` collapsed to two values;
  - removed `stampVersion:` and the marks fields on `RetuneItem`;
  - fix `gridTimes` instead of adding `anchorTimes`;
  - extend `selectionEvent`/`resume` instead of adding `anchorEvent`/`resumeFromAnchors`;
  - `marks:` only, no `map:` keyword;
  - click math class-side on `BeatMarkMode`, transport controller dropped;
  - a single `action:` API;
  - milestones M1/M2, with free pins split into pick mode (4d) and DP (7);
  - renames: onsets → transients, `manualAnchors` → `manualPicks`, `anchorTime` →
    `seedTime`, free anchor → free pin, `latestMarking` → `loadMarks`,
    `anchorMap` → `tempoMap`, `version:` → `marks:`, `AudioBeatView`/`beatGui` →
    `TakeGui`/`gui`.

  Not adopted: deferring the rename. It was requested, so it stays as an independent
  step 1, with folding into §2e listed as the alternative.
