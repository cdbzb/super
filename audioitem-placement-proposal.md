# Moving AudioItems between EventLists

Status: proposal, rev 4, 2026-09-21. Partly built (as of 2026-09-24): numeric `at:` via
`EventList.prAddAudioItem`; `at: nil` / `at: \original` still deferred (§3).

**Goal:** make this work —

```supercollider
e.addItem(AudioItem("tambo-test").take(0), at: 8)
```

Today that is a doesNotUnderstand, and placing an audio take by hand means supplying
five quantities, two of which have branch-dependent meanings.

**Four changes**, ~65 lines total: `freeze-beatdur` (1 line), `persist-recordwall`
(~15), `addItem-audio` (~40), `t0` (~10 across two files). Sizes are
estimates.

**One behavioural break:** ad-hoc tempo-follow events that hand-add `+ rt` to
`start:` must drop it. Nothing in the songs is affected.

---

## 0. Vocabulary

Three terms used throughout.

**`rt` — the round trip, and the `\raw` convention.** The measured input+output
latency of the rig (`AudioItem.sc:4-14`). A mic take lands `rt` late in the file
relative to the grid: the performer played against monitoring already `L_out` late,
and their sound took `L_in` to get back through the converter. Latencies add. The
file on disk is **never trimmed** — compensation is applied at read time. A
representative measured value on this rig is ~51 ms (`AudioItem.sc:772`).

**The record stamp.** At record time the clock a take was cut against is frozen and
stored under `(item, take)`. It exists in **two shapes**:

| shape | where | holds | built by |
|---|---|---|---|
| in-memory | `AudioItem.recordedMaps` | `list` (a detached `EventList`) + `tempoEnv` | `EventList.prRecordStamp:2124` |
| on disk | a `.retune` archive | serialized anchors as an `AnchorTempoMap` (`\map`) | `TakeArchive (née RetuneArchive).writeStamp:77` |

`AudioItem.recordedMap:342` prefers the in-memory one. **That the two shapes are
built at different times is the whole of §2.1.**

**A "wild" list.** An `EventList` with `tempoMap == nil` *and* `beatDur == nil` —
i.e. one made with `EventList.new` and never given a clock. A take recorded against
one is the motivating case.

---

## 1. The gap

MIDI items have a placement protocol. Audio items have none.

| | MIDI | Audio |
|---|---|---|
| insert into a list | `list.addItem(player, at:, voice:, mk:, offset:, align:, grid:)` | hand-written `list.add(when, newType:, item:, take:, start:, sourceTempoMap:)` |
| recorded position | `at: nil` | — |
| recorded wall moment through current map | `at: \original`, `itemStartBeat`, `itemAnchorBeat` | — |
| nest instead of flatten | `align:` | — |
| self-describing clock | `player.tempomap` (`MIDI-Item2.sc:2080`) | — (stamp, read indirectly) |

`EventList.addItem:591` opens with `player = player.player;`. `Take : AudioItem`
(`AudioItem.sc:746`) implements no `player` — the only definitions in the tree are
`Retune.sc:538,566` and `MIDI-Item2.sc:1312,1455` — so passing a `Take` throws.

---

## 2. What to build

Each subsection is one defect and its fix. Order is dependency order.

### 2.1 `freeze-beatdur` — the source clock is re-resolved at playback time

**Defect.** A wild list has `beatDur == nil` (`EventList.sc:22` declares it with no
initializer; `clear:2373` nils it; only `:1748`, `ParamSpace.sc:122` and
`Mandarin.sc:56` pin it). `prClockSnapshot:2111` copies the nil into the stamp.
`prSrcOffset`'s in-memory branch (`AudioItem.sc:390-392`) then calls
`sl.beatToWall(...)` on that snapshot, reaching `baseWallDelta:1434`:

```supercollider
^(b - a) * (beatDur ? TempoClock.default.beatDur)
```

resolved **at playback time**. The disk path does not have this bug —
`prStampAnchors` (`Retune.sc:107`) samples at write time, which is record time.
`recordedMap` prefers memory.

So the same take plays at one rate in the session it was recorded in and a
different, correct rate after an sclang restart. **Error magnitude: the ratio of
record-time to playback-time `TempoClock.default.tempo`** — unbounded, 2× or worse
in practice. `TempoClock.tempo_` is called live in the tree (`panel2.scd:10,123`,
`panelTesting.scd:10,130`, `tangled.scd:6,312`, `Yoeminrak.sc:399`).

Blast radius is narrow: `asEventList` lists get `beatDur = 1` *and* a `tempoMap`,
Mandarin lists pin from `Song.clock`. Affected population is exactly `EventList.new`
scratch lists — the `tambo-test` case, nothing in the songs.

**Fix.** In `prClockSnapshot`:

```supercollider
snap.beatDur = beatDur ?? { tempoMap.isNil.if { TempoClock.default.beatDur } };
```

`prClockSnapshot` has two callers — `prRecordStamp:2126` and `lastPlayEpoch:1812` —
so this also freezes the four MIDI placement paths that resolve through `ep[\list]`.
Same bug, same direction; note it in the commit.

No test changes: `add-item-test.scd` pins `beatDur` explicitly at
`:26,44,55,67,78,84,96`, as do `align-test.scd`, `groove-test.scd`,
`prepare-fire-test.scd`.

### 2.2 `persist-recordwall` — no wall reference survives a restart

**Defect.** MIDI takes carry `recordEpoch` (`MIDI-Item2.sc:903`) and
`recordPlayEpoch` (`:909`), giving `recordWall:1569`, giving
`EventList.itemStartBeat:687` / `itemAnchorBeat:701` — which is what makes
`addItem(at: nil)` and `at: \original` work. `prRecordStamp:2124` stores no wall
reference, and the persisted block (`Retune.sc:85-92`) drops `list`/`tempoEnv` too.

**Audio needs far less than MIDI here.** A MIDI performance happens at an arbitrary
wall moment, so it needs an epoch. An audio record event *fires at a known beat*, so
in memory the analogue is computable today with no new state:

```supercollider
stamp[\list].beatToWall(stamp[\when], stamp[\tempoEnv])
```

Only the **disk** form is missing it, because its anchors are rebased to start at
`when`.

**Fix.** Add that scalar as `recordWall` to the `recordedAgainst` block in
`writeStamp`, and add `Take.recordWall` reading memory when present, disk otherwise.
No `fromBeat`. **No absolute `Main.elapsedTime`** — it is meaningless after a
restart, which is exactly why MIDI's `recordWall` is a *difference* of same-session
epochs (`MIDI-Item2.sc:1566-1572`).

The MIDI/audio latency asymmetry is preserved automatically — MIDI capture subtracts
`outputLatency` only (`MIDI-Item2.sc:1201`), audio uses the full round trip
(`AudioItem.sc:210-219`) — because `roundTrip` stays a separate stamp field.

### 2.3 `addItem-audio` — `EventList.addItem` accepts audio takes

**Defect.** §1.

**Fix.** `Take.player { ^this }`, mirroring `MIDIItemPlayer.player`
(`MIDI-Item2.sc:1455`), plus an audio branch in `addItem` emitting one
`\audioItemTempoFollow` event with `item`, `take`, `at` → `when`, `start: 0`, and
**no `sourceTempoMap`** — so the existing stamp branch of `prSrcOffset` supplies both
the clock and `rt` with no new machinery.

**Why it cannot reuse `prInsertItemEvents`:** that method iterates
`player.midiEvents` and reads `player.source` unguarded at `:553`. `Take` has
neither. The audio branch must bypass it, which means re-implementing the preview
path (`:561-566`, `nextPreviewOffset`/`storeAndPreview`) — the motivating call site
uses `e.preview_(true)`.

`at:` is required until `persist-recordwall` lands; then `at: nil` works.

Compile check before adding methods to `Take`: it re-declares `var name, ..., buffer`
which `AudioItem` already declares as `<>name`/`<>buffer` (`:18` vs `:747`). If those
are shadow slots, `newTake.buffer = ...` (superclass setter) and `playbuf`'s bare
`buffer` read (subclass slot) refer to different storage.

### 2.4 `t0` — `start:` means different things on different branches

**Defect.** `rt` is applied as a **read-position** adjustment in two places that must
agree, and on the follow path it is applied per-branch:

| `prSrcOffset` branch | line | adds `rt` today | after `t0` |
|---|---|---|---|
| `ev[\sourceTempoMap]` (map object) | `:376-379` | no | no |
| `ev[\sourceBeatDur]` (flat) | `:380-382` | no | no |
| stamp, disk form (`\map`) | `:389` | **yes** | no |
| stamp, in-memory form | `:392` | **yes** | no |
| list base clock | `:394` | no | no |

Nothing at the call site signals which branch applies. The sealed `\audioItem` path
meanwhile reads at `(startPos + rt)` (`:174`) — **and that is the semantics we
want**; it is the follow path that is inconsistent with it. (With an explicit
`sourceTempoMap:`, `start` is a raw file offset and the caller owns latency —
`quantize-tempomap-project.md` §9b. That rule is fine; the problem is that it is
invisible.)

**Error magnitude: one round trip, ~51 ms.**

**Fix — give the take an explicit frame origin, applied uniformly.** (A DAW
factors this by moving the *item on the timeline* and leaving the source read offset
a pure user-authored number. The mechanism below does not go that far — it still
adjusts read positions — so do not read the DAW analogy as a description of the
equations.)

`Take.t0` answers the file second at which the take's musical zero sits — for
a stamped mic take that is its stamped `roundTrip`; nil/0 for an imported file with
no stamp (preserving the face-value rule at `AudioItem.sc:156-158`); for an authored
marker map it is the first marker, which is *not* a latency. **This is a rename of
the existing `Take.roundTripLatency` (`:765-767`)**, which is already exactly that
expression. `roundTripLatency` names the rig measurement and stays valid as such;
`t0` names the take's frame origin, which is what consumers actually use.

Naming note: `t0` is taken (a tempo map's first-anchor timestamp,
`MIDI-Item2.sc:2475`, and a live local in `prSrcOffset:377`), and bare `offset`
means a *beat* nudge on this very call (`addItem:591`, `:627`). `t0` collides
with neither. `prSrcOffset` drops `+ rt` on both stamp branches.

**Mechanism is still open — two spellings, and the call-site one is error-prone.**

*(a) Add `t0` at each source-position seam.* There are **four**, in two methods:

```supercollider
// tempoFollowActions, and its line-for-line twin tempoFollowEnvActions
endSec      = t0 + startSec + srcOffset.(b0 + ev[\dur])   // :466  .min(sourceDur)
fromSec     = t0 + startSec + srcOffset.(fromBeat)        // :472
sourceBFull = t0 + startSec + srcOffset.(nextBeat)        // :493  inside the loop
```

plus `prSrcEndBeat:398`, which takes `startSec + t0` as its `startSec` and
drops both `- rt`s at `:412`/`:415` (they are the algebraic inverse of
`prSrcOffset`'s `+ rt`, present only on the stamp branches).

Every one is load-bearing. Miss `endSec` and `rt` no longer cancels against
`fromSec`, so the span becomes `m.timeAt(dur) - rt` and every `dur:`-bounded take
truncates one round trip early — `endSec` also gates the `while { srcCarry < endSec }`
loop and the `sourceB.min(endSec)` clamp. Miss `sourceBFull` and segment 1's `rate`
is wrong, and since `srcCarry = sourceBFull` carries forward (`:520`), **every
segment after the first reads uncompensated** — the fix silently undoes itself
0.25 beats in.

Two review passes missed `sourceBFull`. That is the counterproposal's central
argument against this spelling, and it is well taken.

*(b) Keep the term inside `prSrcOffset`, applied on all five branches.* The closure
already returns a beat→source-seconds mapping; adding the origin there means
`fromSec`, `endSec` and `sourceBFull` all get it with no call-site edits, and
`prSrcEndBeat`'s inverse becomes uniform. This is today's structure minus the branch
inconsistency, and it is *smaller* than (a). Cost: the authored-map case needs one
provenance flag, since a map authored from physical file positions already includes
the delay and must not be shifted again.

**(b) is the better spelling.** (a) is retained here only to document why — it is the
same argument the counterproposal makes in its §2, and `sourceBFull` is the evidence.

Free: `tempoFollowEnvActions:630` (`startPos: fromSec * BufSampleRate.kr`) consumes
`fromSec` directly, and `wallDur`/`totalSourceDur` at `:579-580` derive from
`fromSec`/`endSec`/`lastBeat`.

**Implementation hazard.** Do not construct a `Take` on the playback path.
`Take.new:748-760` calls `Buffer.read` — an async server allocation — whenever the
buffer is uncached. `tempoFollowActions` has only `itemName` and `takeNum`
(`:427-429`), and the sealed path at `:174` runs *inside the event's send*, which
`EventList.fire` runs only `latency` ahead of the sound. The existing code avoids
this deliberately (`:159-160`, after a prior late-bundle bug). Implement as
`AudioItem.t0(name, takeNum)` with `Take.t0` delegating.

**Scope note.** `Take.play`/`playbuf` (`:776-806`) apply no `rt` at all — a direct
`.play` reads at face value, matching the "direct `.play` stays sealed" precedent at
`EventList.sc:2055`. So `start` means one thing on every *list* path; the direct-play
exception stands.

**Independence.** `rt` stays a scalar outside the map, so none of the
map-representation traps in §3.2 apply. This is why `t0` does not need
`take-tempomap`.

---

## 3. Deferred

**`addItem-audio`: `at: nil` and `align:`.** `at: nil` needs the
`player.isKindOf(MIDIItemPlayer).not` guard at `:613` relaxed. `align:` is not free:
`prAddItemNested:636` calls `player.asEventList(nil, mk)`, defined only on
`AbstractMidiEvents` (`ParamSpace.sc:104`). Needs a new `Take.asEventList` emitting a
one-event child list.

**`take-tempomap`** — give audio takes a self-describing map so `prSrcOffset`'s
ladder collapses. With `t0` taking `rt` out of `prSrcOffset`, this is a
*representation* cleanup, not a correctness fix, and should be argued on those terms.
If attempted, `rt` must not go in the map: `prSrcOffset:377` reads
`sm.timeDomain.first`, and `MIDIItemTempoMap.timeDomain` (`MIDI-Item2.sc:2701`) is
hardcoded `^[0, ...]`, so a map-carried `rt` is silently dropped; baking it into the
anchor times instead breaks `repinRoundTrip:275` / `setRoundTripLatency:773` and the
`\raw` invariant at `Retune.sc:71`; and `prStampAnchors` (`Retune.sc:108`) reads
`stamp[\list]`/`[\tempoEnv]` on the record path, behind a `try` that only warns — so
dropping them would make every future take fail to persist *quietly*.

One win available regardless: `prRecordStamp` runs at **prepare** time
(`EventList.sc:2140`), while `prStampAnchors` currently runs from `writeStamp`
*inside the send* (`AudioItem.sc:144`), delaying every later send in that fire.
Moving anchor-building into `prRecordStamp` is a latency improvement. Gate it on
`AudioItem.armed`.

**`collapse-types`** — merging `\audioItemTempoFollow` into `\audioItem` +
`followTrack:`. Harder than it looks: `prForwardAudioFollow:2056-2071` maps
`followTrack: true` → `sourceBeatDur: 1` (flat), while bare `\audioItemTempoFollow`
uses the stamp/base-map default. Only `followTrack: \eventList` is equivalent, and
`followtrack-forward-test.scd:136,140` asserts the distinction. Defaulting
`\audioItem` to following would also re-route every existing `\audioItem` event
(`Neon-tangled.scd:260,387,389`) from `PlayBuf` to segment-chopped `RubberBand`, and
the follow path never calls `.play`, so `finish: { ~out = Effect.bus(...) }` at
`Neon-tangled.scd:262` would never run and that voice would route to bus 0.
`numChannels: 1` at `:264` is likewise ignored (`RubberBand.ar(1, ...)` is hardcoded
mono).

**`Take` vs a new `AudioItemPlayer`.** The tree already has an audio-side player axis
(`Retune.sc:538,566`), but it yields note events, not audio playback, so it is not a
drop-in. `quantize-tempomap-project.md` §9c says the audio editor should "rehost"
rather than grow a third copy. Suggest placement on `Take`, filter story on the
Retune axis.

---

## 4. Tests and migration

### Tests

- `standalone-tests/retune-archive-test.scd` already compares in-memory and disk
  stamps — this is the **`freeze-beatdur` regression harness**. Needs one case with
  `beatDur` left nil and `TempoClock.default.tempo` changed between stamp and read.
- `standalone-tests/add-item-test.scd` — the `addItem` contract `addItem-audio`
  extends.
- `standalone-tests/followtrack-forward-test.scd:136,140` — the `followTrack`
  equivalence table. Only `collapse-types` would rewrite it.

**Missing, and the acceptance criterion for `t0`:** a round-trip onset test.
Record a take at beat 8 on list X, replay on list Y with `start: 0`, assert its first
transient sounds at beat 8 — on both the sealed and follow paths.
`AudioItem.takeOnset:305` already measures this, but it measures **from file start**,
so the assertion is `takeOnset ≈ t0`, not `≈ 0`.

### Migration

- The only `\audioItem` events with a `start:` in the tree are
  `Mandarin/Neon-tangled.scd:387` (`start: EventList(\verse).secPerBeatAt(25) * 3` —
  musical seconds, no hand `rt`) and `:389` (`start: 0`). Both sealed-path, semantics
  unchanged. Ad-hoc follow events that hand-add `+ rt` must drop it.
- Takes stamped before any of this have in-memory stamps with nil `beatDur` and disk
  anchors sampled at whatever the default tempo was. `freeze-beatdur` changes nothing
  for them — their stamps are already written.
- `recordedAgainst[\start]` (written `Retune.sc:88`, read back `:148`) is **read by
  nothing** — verified across every consumer of `recordedMap` (`AudioItem.sc:160,
  383, 408, 766`) and of the raw stamp (`Retune.sc:87-92, 108`). So `t0` does
  not break it. But old archives carry a `\start` under the old raw-file-offset
  meaning with no version marker: a trap for whoever attempts `take-tempomap`.

---

## 5. Files

- `Trek/MW-Classes/AudioItem.sc` — `prSrcOffset` `:373`, `prSrcEndBeat` `:398`,
  `tempoFollowActions` `:426`, `tempoFollowEnvActions` `:529`, `recordedMap` `:342`,
  `repinRoundTrip` `:275`, `takeOnset` `:305`, `Take` `:746`,
  `Take.roundTripLatency` `:765`
- `Trek/MW-Classes/EventList.sc` — `addItem` `:591`, `prInsertItemEvents` `:~540`,
  `itemStartBeat` `:687`, `itemAnchorBeat` `:701`, `prAddItemNested` `:630`,
  `prForwardAudioFollow` `:2056`, `prIsAudioFollow` `:2091`, `prClockSnapshot` `:2111`,
  `prRecordStamp` `:2124`, `prEmit` `:2143`, `baseWallDelta` `:1434`,
  `lastPlayEpoch` `:1812`
- `Trek/MW-Classes/Retune.sc` — `writeStamp` `:77`, `prStampAnchors` `:107`,
  `loadStamp` `:137`, `\raw` invariant `:71`
- `Trek/MW-Classes/MIDI-Item2.sc` — `recordWall` `:1569`, `recordBeat` `:1577`,
  epochs `:903`/`:909`/`:1196`, `tempomap` `:2080`, `timeDomain` `:2701`,
  `initAnchors` `:2536`
- Tests: `standalone-tests/{retune-archive,followtrack-forward,add-item}-test.scd`
- Background: `quantize-tempomap-project.md` §9a, §9b, §9c, §10

---

## 6. Review — 2026-09-21

Reviewed rev 4 against the relevant implementation. The direction makes sense,
and the `freeze-beatdur` change looks sound. Resolve the following before
implementation:

1. **`t0` misses a fourth calculation.** In
   `AudioItem.tempoFollowActions`, `sourceBFull` (`AudioItem.sc:492`) also needs
   the offset. Correcting `fromSec` without correcting `sourceBFull` makes the
   first segment's rate wrong; subsequent iterations inherit the uncompensated
   source position through `srcCarry`. Define one corrected source origin
   (`startSec + t0`) and use it consistently for `fromSec`, `endSec`,
   `sourceBFull`, and the `prSrcEndBeat` argument.

2. **`recordWall` alone does not enable the existing placement helpers.**
   `EventList.prItemBeat` (`EventList.sc:709`) calls `recordPlayEpoch`
   unconditionally once `recordWall` is present, then uses the source map's `t0`
   for frame conversion. Adding only `Take.player` and `Take.recordWall` leaves
   that call unsupported. Audio needs an explicit placement path that preserves
   the intended source/destination frame conversion after restart. Also update
   `TakeArchive.loadStamp` to restore the new persisted `recordWall` field;
   writing it in `writeStamp` alone is insufficient.

3. **Preview machinery need not be duplicated.** `EventList.add`
   (`EventList.sc:746-748`) already calls `nextPreviewOffset` and dispatches to
   `storeAndPreview`. The audio branch can insert its single event through
   `this.add(...)`, preserving `addItem`'s array return contract, instead of
   reimplementing the preview path from `prInsertItemEvents`.

4. **The proposed onset assertion does not verify playback compensation.**
   `takeOnset ≈ t0` checks the transient's position in the recorded file;
   it can pass even when playback applies the offset incorrectly. Keep that
   check, but also measure replay alignment on the sealed and follow paths.
   Check segment continuity and duration, including bounded and unbounded
   playback, so an onset-only test does not miss the `sourceBFull` defect above.

5. **Clarify the scope of recorded placement.** Section 2.3 promises that
   `at: nil` works after `persist-recordwall` lands, while section 3 defers it.
   State whether this revision supports numeric placement only or also recorded
   placement, and specify `at: nil` versus `at: \original` behavior explicitly.

This was a source review; no runtime tests were run.

---

## 7. Implementation log — 2026-09-21

Branch `audioitem-placement`, three commits. Full `standalone-tests/` suite green
before and after each one (27 files at the start, 28 after §2.4's new suite).

### Landed

**`320d5655` — `freeze-beatdur` (§2.1).** `prClockSnapshot` resolves
`TempoClock.default.beatDur` at snapshot time when the list has neither a
`tempoMap` nor a `beatDur`, exactly as proposed. Also freezes MIDI play-epoch
snapshots, since `lastPlayEpoch` is the other caller. Regression added to
`retune-archive-test.scd`: a wild list stamped at default tempo 1, default moved
to 4, in-memory stamp asserted still 1 s/beat and still equal to the disk form.
Verified to fail without the fix (3 failures, max err 3.0 s over 4 beats).

**`59438db6` — `addItem-audio` (§2.3), numeric `at:` only.** `Take.player { ^this }`
plus `EventList.prAddAudioItem`, emitting one `\audioItemTempoFollow` event
(`item`, `take`, `when: at + offset`, `start: 0`, no `sourceTempoMap`, `voice:`
honoured) through `this.add`, so `nextPreviewOffset` / `storeAndPreview` are
reused rather than reimplemented. `at: nil`, `at: \original` and `align:` warn and
insert nothing. `Take.recordWall` deliberately NOT added — `prItemBeat` calls
`recordPlayEpoch` unconditionally once `recordWall` answers. 20 checks added to
`add-item-test.scd`.

**`e82356b7` — `t0`, spelling (b) (§2.4).** `AudioItem.t0(name,
takeNum)` (class method, never builds a `Take`), `Take.t0` delegating,
`Take.roundTripLatency` unchanged. `prSrcOffset` applies the origin inside the
returned closure on all five branches; `prSrcEndBeat` removes it once from its
target. The sealed `\audioItem` path now calls `t0` for the same number
it used to compute inline, so the two paths agree by construction. Provenance key
is `sourceMapIsPhysical: true`. New `standalone-tests/audioitem-t0-test.scd`,
40 checks.

### The `Take` shadow-slot question (§2.3, closing paragraph)

It IS shadowing, and it is real duplicate storage: `Take.instVarNames` answered
ten names, `name` at indices 0 and 7, `buffer` at 1 and 9. But the duplicates were
*unreachable*. sclang resolves a bare instance-variable reference to the FIRST
match in the flattened list, confirmed by bytecode — `Take:playbuf` compiles its
bare `buffer` to `PushInstVar` index 1, the inherited slot, which is the one
`newTake.buffer = ...` writes through `AudioItem`'s setter. So `playbuf` was
always reading the right buffer and slots 7/9 were dead weight reachable only
through `newCopyArgs`, `instVarAt`, `.copy` and archiving. Declaration reduced to
`var <>num` before the new methods were added, per the brief.

### Deviations from the brief

1. **No `main` branch exists** in `~/tank/super` (`master`, `return-to-tomorrow`
   and feature branches only). `audioitem-placement` was cut from
   `guide-track-features`, the branch carrying this code and these proposals.
2. **Guards answer the warning String, not nil.** `^"...".warn` returns the
   String, which is what `addItem`'s existing guards do and what
   `add-item-test.scd` asserts (`added.isKindOf(String)`). Matching the file beat
   "return nil" literally.
3. **"all five branches return 0.05" is not achievable for the list-base-clock
   branch.** It is reached only when the take has NO stamp, and `t0`
   answers non-zero only when one exists — a stamped take takes the stamp branch
   first. The test asserts 0.05 on the four reachable branches and 0 on the base
   clock, and the code writes `t0 +` there anyway so the rule reads the same.
4. **The seams were verified by source reading**, as instructed, not by an
   end-to-end headless render: `tempoFollowActions`' `endSec`, `fromSec` and
   in-loop `sourceBFull` all evaluate `startSec + srcOffset.(...)` from the one
   closure, and `srcCarry` is initialised to `fromSec` then advanced to
   `sourceBFull`, so every carried source position inherits the origin.
   `tempoFollowEnvActions` is the line-for-line twin plus the `prSrcEndBeat` call.
   `sourceB`/`endSec`/`sourceDur` all stay in physical file coordinates.

### Deferred / still open

- **Audio-onset acceptance test.** Replay onset and end against a reference click,
  on the sealed and follow paths, with bounded and unbounded duration and a
  segment shorter than the round trip (review §6.4). Needs the live server; not
  run.
- **Recorded placement** (`at: nil`, `at: \original`, `persist-recordwall`) and
  **`align:`** for audio, per §3 and review §6.5.
- **Nested-capture stamp gap.** `prEmit` receives the composed `place` but passes
  only `this` and `tempoEnv` into `prRecordStamp`, so under nesting the stamp
  records the child's own clock rather than the clock the take actually heard
  (counterproposal §6). Noted, not fixed.
- `take-tempomap` and `collapse-types` remain as argued in §3.
