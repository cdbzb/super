# SynthVVST → EventList — proposal

Drafted 2026-08-29; revised after review; **implemented 2026-08-30, committed in 87df777b**. Branch: `guide-track-features`.

## Goal

Play a SynthVVST take from an EventList without going through `Song` at all — no
section index, no `Song.currentSong`, no Part registration — while keeping
`P.synthVVST` working unchanged for existing songs.

## Why this is small

`SynthVVST` the class is already Song-free. The whole file has one `Song`
reference, `SynthVVST.sc:352`, and it is inside the `P.synthVVST` factory:

```supercollider
song = song ? Song.currentSong;
```

`*new(voice, params, version)` (`:113`) takes a params Event directly; `init`
(`:124-142`) reads only that Event. `cacheKey` is a content hash of
`[voice, params, version, voices]` (`:106-111`) and freeze state is filesystem
-keyed off it, so an EventList-built instance shares frozen renders with the
Part route.

## The real problem: three drifted playback paths

Playing a SynthVVST is implemented three times, and they disagree.

| | `play` (`:270`) | factory bus block (`:404-427`) |
|---|---|---|
| frozen take | **no branch** — always `In.ar(vst.bus)`, never `PlayBuf` | `PlayBuf` of `frozenBuffers` |
| channels | **1** (`:278`, `:290`) | **2** (`:424`, `:426`) |
| multi | `.sum` to mono inside | array of stereo pairs, caller mixes |
| `func` role | filter on the bus signal, default `I.d` | caller's `music` returns a Synth |

So a frozen take played through `play` listens to a dead VST bus, and every take
played through it loses its right channel. This is not a refactor for tidiness —
it is a bug fix that happens to also unblock the EventList route.

## The change — DONE

Lifted onto the class; `P.synthVVST` now calls it.

```supercollider
source { |tail=1| }              /* the graph: frozen buffers or live VST bus, stereo */
prTransport { |playing| }        /* setTransportPos(0) on start only */
prPerform { |makeSynth, tail=1| }/* ready-gate, transport, cleanup — the one lifecycle */
play { |func tail=1| }           /* keeps its filter contract; delegates to prPerform */
```

`P.synthVVST`'s music wrapper collapsed from 30 lines to
`sv.prPerform({ music.(p, b, e) }, tail)`, and its `resources[\bus]` became
`{ sv.source(tail).value }`. `music` keeps its `(p, b, e)` signature and still
returns the Synth, so existing songs are untouched.

Fixed by construction: no frozen branch in `play`; 1-channel reads; reader synth
built before the transport started. Fixed explicitly: the Cmd-. deadlock, and
`play` before `build` (now builds rather than dying on `nil.wait`).

## Call sites after

```supercollider
~an = SynthVVST(\an, (
    lyrics:    "霓 虹 灯 照 亮 我 的 脸",
    midinote:  [...],                    /* same size as dur */
    dur:       [...],                    /* flat numeric array */
    pitchTake: 1,
    language:  \mandarin,                /* see invariant 5 */
    phoneset:  \xsampa
), version: 2).build;

/* sv: on the event, NOT ~an in the closure — Event.play does this.use, so
   currentEnvironment inside func IS the event and ~an reads nil there.
   Carrying it also makes the list the registry of what's in the arrangement. */
e.add(chorusBeat, (sv: ~an, func: {
    ~sv.play({ |sig| sig => Mix.ar(_) => Pan2.ar(_, 0) / 4 })
}));
```

## Invariants to preserve

1. **Cmd-. deadlocks a frozen take — FIXED 2026-08-30 in `build`.**
   `*doOnCmdPeriod` (`:305`) clears `ready` on every cached item. On the next
   `build` a frozen take passes neither guard: the rebuild guard (`:168-176`)
   requires `isFrozen.not`, and the frozen cache-hit re-arm (`:181`) requires
   `frozenBuffers.isNil`. It falls through to `^this` (`:198`) with `ready`
   false and nothing scheduled to signal it, so the `ready.wait` at `:275`/`:287`
   hung forever. `build` now re-arms on ANY frozen cache hit whose Condition is
   down, not only when the buffers were missing.
   *Still not covered — OPEN:* a server reboot leaves `frozenBuffers` non-nil but
   holding dead Buffers, so neither guard fires and the re-arm signals ready over
   invalid buffers. Decide whether to validate or to nil them on reboot.
2. `params.dur` stays a flat numeric array — `params.dur.sum + tail` drives the
   cleanup fork (`:273`, `:384`).
3. `dur`, `midinote` and `lyrics` must agree in size; `makeNotes` sizes from `dur`.
4. `ready` gating stays. Dropping it leaves a VST rendering with nothing listening.
   `prPerform` now calls `build` when `ready` is nil rather than dying on `nil.wait`.
5. **Language wants the lowercase symbol plus a `phoneset`.** `\language` routes
   to `setLanguage([[language, phoneset]])` (`SynthV.sc:759`), which writes
   `languageOverride` and `phonesetOverride`. With no `phoneset` key the second
   is nil; and `setLanguage` clears the override only when it matches the DB
   native value, which is the lowercase string `"mandarin"`
   (`SynthV.sc:85`) — so `\Mandarin` sets a spurious override. `Not_Good_Enough
   .scd:4` has the canonical form: `[language: \mandarin, phoneset: \xsampa]`.

## Cache-key fragility across routes — test first

`P.synthVVST` (`:355`) unwraps `Pseq` to `.list` before building its params
Event, and `calcCacheKey` hashes `asCompileString` — which distinguishes `2`
from `2.0` and `Pseq` from `Array`. Hand-written EventList params must therefore
match the Part route's **types**, not just its values, or the same take gets a
different hex directory and re-renders from scratch. That would defeat the point
of porting existing songs, so verify a hand-written params Event reproduces the
Part route's `cacheKey` before doing any of the above.

## Out of scope

- **Tempo.** A SynthVVST take is fixed audio, so the list's `tempoMap` does not
  reach inside it — same wall as `\seg`. Making it follow would mean routing the
  frozen wav through the `\audioItem` tempo-follow path
  (`prIsAudioFollow` → `AudioItem.tempoFollowActions`), which needs the
  `\audioItem` event type to honour an explicit `~path` (today it always derives
  one from name/take, `AudioItem.sc:60-72`). Separate piece of work.
- Decoupling `P()` itself from `Song`.
- Making the SynthV *render* list-driven rather than section-driven.

## Resolved

- *Does `play` belong on the class or a `SynthVVSTPlayer`?* On the class.
  `cache`, `ready`, `frozenBuffers` and `cleanup` are all instance state; a
  separate player would need every one by reference, and the frozen × multi
  matrix is small enough for one method.
- *Should the graph accessor cache its Function?* No — rebuild per call.
  `frozenBuffers` is nil'd by `unfreeze` (`:103`) and dies on server reboot, so
  a cached Function closes over stale Buffers.
