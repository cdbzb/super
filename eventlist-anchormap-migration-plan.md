# Plan: EventList.tempoMap holds an AnchorMap

Status: decided, 2026-10-31. Branch `eventlist-anchormap`, cut from `audio-beat-marking` at `5d362df6`.

## Goal

`EventList.tempoMap` is either `nil` (flat, read through `beatDur`) or a
concrete beat -> sec `AnchorMap`. MonoMap methods then work on it directly:

```supercollider
e.tempoMap = e.tempoMap.quantizeWindow(0.5);
e.tempoMap = e.tempoMap.curve(0.5).clump(2);
```

No `.asMonoMap` on the way out, and no `asAnchorTempoMap` on the way in.

Out of scope: `MIDIItemPlayer.tempoMapOverride`, `Take.tempoMap`,
`MIDIItemTempoMap` and `AnchorTempoMap` themselves. They keep the old form.
Retiring the old classes is a later job.

## Contract

The stored map is **normalized**: `xs.first == 0` and `ys.first == 0`, frames
`\beat -> \sec`, and the list keeps the removed seconds offset in a new ivar `t0`.

Why normalized, and not an absolute map with `ys.first` as t0:

- The list clock is a shape read from beat 0. `prBaseWallAt` (`EventList.sc:1642`)
  answers `tempoMap.timeAt(beat)` and never subtracts an origin. The comment on
  `tempoMap_` already says so.
- User code reads `e.tempoMap.timeAt(b)` as seconds from the list's start
  (org.org:614 uses `e.tempoMap.timeAt(6)` as an Env duration). With a normalized
  map that stays true, and `timeAt` keeps its MonoMap meaning.
- Every other reader is already origin-safe: `baseWallDelta` takes a difference,
  and `wallToBeat` (`:1760`), `AudioItem.sc:747` and `addItem` (`:2657`, `:2680`)
  all add the result of `timeAt` before calling `beatAt`.

The cost is that t0 is no longer inside the map. See "Handing a list's map
elsewhere" below.

## Steps

### 1. Golden schedules (before any code changes)

Record, on the current code, everything the clock produces for a fixture set,
and save it to `standalone-tests/fixtures/eventlist-clock-golden.scd`:

- a flat list (`beatDur` only)
- a list from `MIDIItem.asEventList` on a selection (t0 != 0)
- the same list with a `\tempoTrack` ramp, a step, and a hold past the end
- a list whose map came from a MonoMap edit (`quantize`, `alignTo`, `easeTo`)
- a list from a curved `MIDIItemTempoMap`
- a nested `\eventList` child, `addItem(at: \original)`, `followTrack: \list`, and
  `align:`

For each fixture, record `prepare` schedules, `beatToWall` and `wallToBeat` on a
grid, `itemStartBeat` and `prItemBeat`, and `bpmAt`. The prepare perf pass did
this the same way. The after-state must match bit-identically, or within 1e-9
where float order changes. Any difference must have an explanation written
down.

**Done 2026-10-31:** `standalone-tests/eventlist-clock-golden.scd` (14 fixtures,
98 measurements), data in `standalone-tests/fixtures/eventlist-clock-golden-data.scd`,
recorded on `5d362df6`. A check run on the same code passes 98/98. Run it with
`~eventListGoldenRecord = nil` in the live session (record mode is `true`).

Differences already expected from decision 2 (an assigned MonoMap keeps its t0):
`editAlign` and `editEase` record `t0: [0]` today, because `alignTo` and an
`easeTo` result arrive as MonoMaps and are rebased. After the migration they
should read 3.2, and their `place` values (`itemStartBeat`, `prItemBeat`) shift
with it. Their schedules and grids should not change.

Recorded current behaviour worth knowing: assigning the curved map warns
"could not re-attach t0 … leaving it rebased to 0", but the list still reads
t0 = 3.2, because the curved `MIDIItemTempoMap` is stored as is and keeps its own.

### 2. `t0` ivar and `tempoMap_`

```supercollider
var <t0 = 0;
tempoMap_ { |map| ... }
```

What `tempoMap_` does with each input:

| input | result |
|---|---|
| `nil` | `tempoMap = nil`, `t0 = 0` |
| Array | `reduce('++')`, then as below (unchanged) |
| `AnchorMap`, beat -> sec | normalize: `xs - xs.first`, `ys - ys.first`; `t0 = ys.first` |
| other MonoMap | `bake`; if the result is an AnchorMap, as above; else refuse, naming `.sample(n)` |
| `MIDIItemTempoMap` / `AnchorTempoMap`, linear | `asMonoMap(origin: \absolute)`, then as above |
| `MIDIItemTempoMap`, curved | see step 3 |
| legacy `TempoMap` | `asMonoMap`, then as above |
| anything else | refuse (today it is stored as is) |

Notes:
- **Rebasing behaviour changes.** A MonoMap assigned today loses its t0 (it uses
  `rebase: true`), while an old map keeps it. Under this table both keep it.
  That only affects `t0`, which is read solely for recorded-take placement
  (`prItemBeat`, `:854-855`). The golden test will show whether any fixture
  depends on the old difference.
- `prWallEnv = nil` stays.
- `prFreezeItemMap` and `prWithT0` are deleted. The normalization replaces both.

### 3. Curved old maps

Today a curved `MIDIItemTempoMap` passes through `prWithT0`. That fails, because
`asMonoMap` refuses a curve, so the map is stored as the old object.

- Check whether `asMonoMap(origin: \absolute, allowCurved: true).curve(curveAmount, n)`
  reproduces the old curve. The new `monomap-test` case already matches at the
  nodes to within 1e-6 with oversample 32. Also check between the nodes, and
  whether the old map records its oversample.
- If it reproduces the curve, convert automatically.
- If not, refuse with a message pointing to the V2 route
  (`m.asMonoMap(origin: \absolute).curve(amount)`), which is the `allowCurved`
  pattern again.

### 4. Readers inside EventList

- `prBaseWallAt`, `baseWallDelta`, `wallToBeat`, `prBuildWallCache`, ramp
  sub-grids: no logic change. `timeAt` and `beatAt` exist on AnchorMap.
  - **Performance:** `MonoMap.timeAt` checks the dimensions before calling `at`.
    These are the hottest calls in `prepare`, so call `tempoMap.at` and
    `tempoMap.invAt` directly here (the dimensions were already checked in
    `tempoMap_`), and measure against the 92 ms prepare baseline.
- `prItemBeat` (`:854-855`): `srcT0` and `dstT0` read `list.t0` instead of
  `tempoMap.tryPerform(\t0)`.
- `copy` (`:342`) and `prClockSnapshot` (`:2384`): copy `t0` along with the map.
- `monoMap` (`:1511`): delete it. Its only caller (org.org:1913, plus commented
  lines 1924–1926) is respelled to `.tempoMap`, which works before and after the
  migration.
- Edit methods (`quantize`, `quantizeWindow`, `detrend`, `scaleTempo`, `setTempo`,
  `setBpm`, `alignTo`, …): `prMapEdit` becomes
  `this.tempoMap_(func.(tempoMap))`. To keep t0, either have `tempoMap_` keep the
  current t0 when it is given an already-normalized map, or let `prMapEdit` pass
  t0 through explicitly. The second is clearer.
- `alignTo`: drop its own `asMonoMap` call. It builds an AnchorMap already.
- `addItem` / `prEmitMi2Follow` (`:2576` on): `tm.respondsTo(\beatAt)` still holds.
  At `:2641`, a MonoMap `srcMap` from the user is still converted at `:2582`, so
  the `timeDomain.first` fallback is unaffected. Keep that conversion.
- Rewrite the comment on `tempoMap_` (`:1477`).

### 5. Readers outside EventList

- `Retune.sc:113`: `beatDomain.last` is supported by `0529f65a`.
- `AudioItem.sc:747`: origin-safe; no change.
- `ParamSpace.sc:151` (`asEventList`): `el.tempoMap = tm` now goes through the
  table. The `\when` calculation just above it reads the player's map and is
  unchanged.
- `keyRecorder.sc:107`: `.warpTo(e.tempoMap)`. Today an `AnchorTempoMap` matches
  neither `[TempoMap, MIDIItemTempoMap].includes(quarters.class)` nor `MonoMap`
  in `Array.warpTo`, so it probably falls through to the array path, which is
  wrong. With an AnchorMap it takes the MonoMap branch. Check this; it may be a
  fix rather than a change.

### 6. Handing a list's map elsewhere

`e.tempoMap` no longer carries t0. Places this matters:

- `player.tempoMap = e.tempoMap` would place the map at t0 = 0. If org code does
  this, add `EventList.placedTempoMap { ^tempoMap !? { tempoMap.place(0, t0).bake } }`.
- `e.tempoMap = f.tempoMap` (org.org:4390) copies the shape but not f's t0. That
  only matters for recorded-take placement on `e`. Accept it and document it, or
  let `tempoMap_` take an EventList (`e.tempoMap = f` copies both).

Decided: no helper for now. A search of org found no list -> player hand-offs
(every `.tempoMap_(…)` / `.tempoMap = …` hand-off targets a list). The
list -> list copy at org.org:4390 losing the source's t0 is accepted. Add
`placedTempoMap` when a hand-off to a player first appears.

### 7. Tests

- New suite, `standalone-tests/eventlist-anchormap-test.scd`:
  - the conversion table
  - normalization and t0
  - t0 surviving each edit method, `copy` and `prClockSnapshot`
  - MonoMap methods working directly on `e.tempoMap`
  - refusals: FunctionMap, infinite MapSeq, a non-beat->sec map
- The golden comparison from step 1.
- Update the existing suites that assert "the list never holds a raw MonoMap"
  and "a list clock is rebased: t0 == 0" (`monomap-test` §12 seam,
  `tempomap-test`, `align-test`, `tempo-frame-test`).
- Re-run all suites (all six green at `5d362df6`).

### 8. Docs

- Update `tempomap-v2-design.md` §12 (the seam).
- Rewrite the `EventList.sc:1477` comment.
- Note in `anchortempomap-wrapper-plan.md` that the direct approach replaces it
  for EventList.
- Org: from here on, use MonoMap methods on `e.tempoMap` directly. The old
  `.asMonoMap` calls keep working only if MonoMap answers `asMonoMap`. It does
  not today, so add `MonoMap.asMonoMap` returning `^this` in step 2. Spell out the
  old form's arguments (`fromFrame, toFrame, origin, allowCurved, extendBelow,
  extendAbove`) and ignore them, rather than using `...args`, so keyword calls
  like `asMonoMap(origin: \absolute)` bind cleanly. One wrinkle: with
  `origin: \relative` the old form re-zeroed the seconds, and a normalized list
  map already starts at 0, so the result is the same.

## Decisions (2026-10-31)

1. Normalized map plus a list `t0` ivar (not an absolute map).
2. An assigned MonoMap keeps its t0, like an old map does. The golden test
   checks that nothing depends on the old reset.
3. `tempoMap_` refuses objects it does not recognise. Legacy `TempoMap` is still
   accepted through `asMonoMap`.
4. Curved old maps convert automatically if step 3 shows the conversion is
   exact; otherwise they are refused with a pointer to the V2 route.
5. No `placedTempoMap` for now (step 6).
6. `EventList.monoMap` is deleted; org is respelled.
7. `MonoMap.asMonoMap` returning itself is added in step 2.

## Size estimate

About 60 lines changed in `EventList.sc` (`tempoMap_`, deleting `prWithT0` and
`prFreezeItemMap`, the t0 ivar, `prMapEdit`, copy, snapshot, the hot-path
readers). A new test suite of about 150 lines, plus the golden fixture, plus
updates to roughly 10 assertions in existing suites.
