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

## 8. Interface cleanup — one event dialect, one timing field

Drift found after M1 (2026-09-23): three surfaces play an audio take and disagree.

| | `add(newType: \audioItem)` | `add(newType: \audioItemTempoFollow)` | `addItem(take, at:)` |
|---|---|---|---|
| Playback | one synth, plays straight (`PlayBuf`) | segment-by-segment, follows the list's tempo | builds the middle column |
| Timing source | none, or what `followTrack:` routes to | `sourceTempoMap:` / `sourceBeatDur:` / stamp / list clock | same, plus `marks:` |
| `followTrack: true` | follow, take seconds read as beats | n/a | n/a |
| Bare default | plays straight | follows the list's map | stamp |
| `marks:` | **silently ignored** | honoured | honoured |
| `start:` | file seconds, `t0` added | file seconds, `t0` added | forced 0, **overwritten** by marks |
| `align:` | no | no | refused for audio (works for MIDI) |

And the keys that answer "where are the take's beats" are already spread out:

| Key | What it is | Read by |
|---|---|---|
| `sourceTempoMap:` | a map object (MIDI events also take `\eventList`) | `prSrcOffset` / `prSrcEndBeat`, `prEmitMi2Follow` |
| `sourceBeatDur:` | flat seconds per beat | `prSrcOffset` |
| `sourceMapIsPhysical:` | "the map already includes the recording delay" | `prEventT0` |
| `followTrack: <value>` | shorthand, forwards into the two above | `prForwardAudioFollow` |
| `marks:` | which marks version (added in step 6) | `prResolveMarks` |
| (record stamp) | implicit, found by take name | `prSrcOffset` fallback |

Rules:
1. **The event is the single source of truth.** Every feature is an event key,
   resolved at prepare time. `addItem` only fills keys (`when:` from `at:`,
   `item`/`take` from the Take) and forwards every other keyword into the event, so
   `addItem(take, at: 8, sourceTempoMap: \marks, align: 0.6, amp: 0.5)` ==
   `add((when: 8, type: \audioItem, item:, take:, sourceTempoMap: \marks, align: 0.6, amp: 0.5))`.
   `addItem` never grows another parameter.
2. **One timing field: `sourceTempoMap:`.** It answers "where are the take's beats"
   and nothing else does; its forms are step 10. **`marks:` is removed** — it exists
   only on this unmerged branch; `sourceTempoMap: \marks` replaces it, and
   `marksVersion: N` pins the version. `sourceBeatDur:` stays as convenience (a flat
   map). `followTrack: <value>` keeps forwarding into `sourceTempoMap:`.
   `sourceMapIsPhysical:` is user-facing only for a hand-given map object; for a
   named source or a function the resolver sets it.
3. **One type: `\audioItem`.** Following the list's tempo is decided by keys:
   `followTrack:` as today, and any timing key (`sourceTempoMap:`,
   `sourceBeatDur:`, `align:`) implies following. `\audioItemTempoFollow` stays as
   an alias for `\audioItem` + `followTrack: \eventList` (its current default), so
   existing lists play unchanged.
4. **One timing order, same on every path:** `sourceTempoMap:` (any form) →
   `sourceBeatDur:` → record stamp → list clock. Absent `sourceTempoMap:` still
   means stamp if stamped, else the list clock — the default does not change.
   `align:` is a blend applied on top of whichever wins, not a tier.
5. **One meaning for `start:`:** seconds after the take's origin — the resolved
   map's first anchor when a named source or function is in play, else `t0`.
   `start: 0` = from the origin; a non-zero `start:` is added, never discarded.
6. **A key table for both media:** `align:`, `offset:`, `sourceTempoMap:` shared;
   `mk:`/`grid:` MIDI-only; `marksVersion:` and the `\marks` / `\stamp` names
   audio-only (the MIDI counterpart of marks is a selection).
7. **Parity test:** for a set of keys, `addItem(take, at:, …)` and the hand-written
   `add((…))` prepare the same schedule.

Code: forwarding in `prAddAudioItem`; alias routing in `prIsAudioFollow`; timing
keys imply follow; `prResolveMarks` becomes the resolver of step 10 (renamed, e.g.
`prResolveSourceMap`), with `start:` added to the origin.

---

## 9. `align:` for audio — quantize strength

`align: a` on an audio event: 0 = as performed, 1 = every beat of the source map on
its list beat, in between a blend. Same key and sense as on nested `\eventList`
events (`prExpandBlended`), and it blends toward the list's REAL clock, so it stays
right under tempo changes — unlike `map.quantize(1 - s)`, which straightens toward
the take's own mean and agrees only when the list tempo equals that mean.

Where: `AudioItem.tempoFollowActions` / `tempoFollowEnvActions` already hold both
clocks — the source map (through `prSrcOffset`) and the list's `wallAt` — so the
blend is per segment, weight `align`. Event key (step 8 rule 1); `addItem` just
forwards it. Independent of which source step 10 resolves.

---

## 10. `sourceTempoMap:` — names and functions over the take's sources

Three forms, one resolver, at prepare time:

```supercollider
sourceTempoMap: aMap                            // a map object, as today
sourceTempoMap: \marks                          // or \stamp, \eventList, \flat — a named source
sourceTempoMap: { ~stamp.quantize(0.5) }        // a function over the named sources (.use)
sourceTempoMap: { |env| env.marks.curve(1) }    // same, argument style
```

- **The environment** holds every candidate map: `~marks` (the marks version;
  newest, or `marksVersion:`), `~stamp` (the record stamp), `~list` (the list's base
  clock over the take's span), `~flat` (`sourceBeatDur:` or 1 s/beat), plus `~take`.
  A candidate the take lacks is nil; naming a missing source warns and falls back to
  the default order. Nothing privileges marks: `{ ~stamp.… }` edits the stamp.
- **One frame for every candidate:** a MonoMap, beat → FILE seconds (physical), so
  the whole MapEditor vocabulary works on each (`quantize(amount, from, to)`,
  `curve`, `ritardSpan`, `setBpm(bpm, from, to)`, `transformSpan`).
  - marks are stored in file seconds already;
  - the stamp is stored relative to the record-fire moment WITHOUT the round trip
    (\raw convention), so it is offered with `t0` added;
  - so whatever the function returns is in file seconds, and the resolver sets
    `sourceMapIsPhysical: true` and the origin (step 8 rule 5) from the RESULT's
    first anchor — an edit that moves the first beat still starts in the right place.
- **Beat frames differ and the resolver owns the alignment.** Stamp beats start at
  the list beat the record event fired on; marks beats start at 0 at the first mark.
  Used alone, either is fine: the result's first beat lands at `when:` (the existing
  item-frame rule). Offered TOGETHER in the environment they must share a beat axis,
  so the resolver re-bases `~marks` onto the stamp's list beats when the take has a
  stamp (first mark's file second → stamp map → list beat, step 11.2), and a
  function combining them never does that itself.
- **Not a lazy value.** `\sourceTempoMap` joins `EventList.lazyExclude`, or the
  generic lazy pass calls the function first, with no `~stamp` / `~marks`.
- **The inverse sense, documented:** the function edits where the beats ARE, not
  where they land. `{ ~stamp.quantize }` pretends the take was steadier than it was,
  which corrects LESS. Quantize strength is `align:` (step 9), not this.
- One place: the resolver is the only code that turns `sourceTempoMap:` into a map;
  `prSrcOffset` / `prSrcEndBeat` / `prEmitMi2Follow` only ever see a map object.

Tests: each form resolves to the same map as its hand-built equivalent; a function
over `~stamp` on a stamped take reads file seconds with no double `t0`; a missing
`\marks` warns and falls back; `marksVersion:` pins; `addItem` forwards the key.

---

## 11. Stamped takes — fix a sloppy take recorded against a list

The stamp says where the beats SHOULD be (the clock the take was recorded
against); marks say where they ARE. With step 10, `sourceTempoMap: \marks` plays
the correction and `{ ~stamp.… }` edits the expectation. Gaps:

1. **Seed the grid from the stamp.** In `TakeGui`, a key draws one line per stamped
   beat (the stamp's expected times, in file seconds) and snaps each to the nearest
   transient within tolerance (`BeatMarkMode.moveLine` logic); lines with nothing
   near stay where the stamp puts them. For this case it is more robust than the DP
   tracker — the expected beats are known in advance. Fix the few it gets wrong,
   `w`. Includes the stamp-grid overlay step 5 promised and M1 did not build.
2. **Beat alignment of marks to the stamp** — the resolver's job (step 10): the
   first mark's file second through the stamp map gives the list beat it was played
   against. That same number is an **automatic `at:`**, so
   `addItem(take, sourceTempoMap: \marks)` with no `at:` places a stamped take
   where it was recorded. Unstamped takes still need `at:`. Seeding (1) makes marks
   and stamp beats identical by construction; the resolver's alignment covers marks
   made by hand.
3. **Partial marks.** Marks cover only what was marked; outside that the map
   extrapolates at the last marked tempo, not the stamp. Stamp seeding (1) covers the
   whole take, which makes this mostly moot; with both in one beat frame (2), a
   function can splice them (`~stamp` outside, `~marks` inside) — a built-in splice
   is deferred until a real case needs it.

With `align:` (step 9) on top, you choose how much of the sloppiness to fix.

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
