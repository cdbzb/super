# Retune — project notes

Started 2026-06-23. Working branch: `guide-track-features`.

Goal: a formant-preserving, Melodyne-style pitch-correction system for recorded vocals,
built on the cepstral vocoder engine and integrated into the Trek class library so it mirrors
the `MIDIItem` / `MIDIItemPlayer` immutable-item + filtered-player split. Detect notes →
edit the note model non-destructively → resynthesise with formants preserved.

Sibling project: `quantize-tempomap-project.md` (tempo-map / quantize machinery). They meet at
§2c (quantizing a *vocal* = time-warping audio, which wants that project's maps) and fully merge
at §2d, where a reference-tune *alignment* IS one of that project's tempo maps.

---

## 1. Where things stand (as of 2026-06-23)

### Architecture (`Trek/MW-Classes/Retune.sc`)
Mirrors `MIDIItem`: an immutable analysis item + non-destructive filtered players, on a shared
base that subclasses `AbstractMidiEvents`.

- **`AbstractRetune`** (`:12`) — base. `notes` == `midiEvents`; `doesNotUnderstand` forwards
  collection ops onto a deep copy wrapped in a new `RetunePlayer` (immutable filter pattern,
  same as MIDI). `gui` (`:21`), `fromNote`/`from` (`:157`), `save` (`:175`), and the stable-key
  helpers (`prKeyMatch` `:142`, `prSelectKeys` `:146`, `prNotesForKey`, `prKeyStr`).
- **`RetuneItem`** (`:195`) — immutable per-take analysis: the note model + the retained
  per-frame arrays (`smoothed`, `conf`) + identity (`name`, `num`, `voice` buffer). Entry point
  `aTake.retune` (`AudioItem.sc` Take). Load-or-analyse on construction; analysis is saved.
- **`RetunePlayer`** (`:352`) — filtered, renderable views. Filters return NEW players:
  `transpose` (`:371`), `move` (`:375`, key-based), `set`, `bypass`, `snapToScale` (`:387`).
  Renders a 4-channel curve and plays.

### Detection / segmentation (`Trek/MW-Classes/vocoders.sc`)
- **`*trackPitchOffline`** (`:315`) — FluidPitch.kr in an NRT render (OfflineProcess) → a
  `[pitch(MIDI), confidence]` curve at 64-sample control frames. `windowSize 2048` keeps low
  notes confident (1024 starved them → unvoiced; see §1 bug history). Spawns its own scsynth,
  leaves the live server untouched.
- **`RetuneItem.prBuildModel`** (`Retune.sc:305`) — voiced gate (`conf > 0.4`), octave-fold
  (`*prOctaveFold` vocoders `:411`), median smooth, segment (`*prSegment` `:441`), drop
  sub-`minNoteMs` blips. Emits one note Event per segment with a **stable `\key`** (birth key
  = position; see below). `*tuneCurve` (`:351`) is the standalone (non-item) path.

### Resynthesis engines (`vocoders.sc`) — all read the 4-ch tuned curve [measured, measuredCenter, targetCenter, confidence]
- **`\autotuneNotes`** (`:139`) — pitch-adaptive **cepstral** lifter: `PV_MagDiv` (flatten) →
  `PV_BinShift` (transpose) → `PV_MagMul` (re-impose formants). Corrects the note CENTER
  (constant per note), preserves/scales vibrato (`modAmt`). `RetunePlayer.play`.
- **`\autotuneNotesTrue`** (`:189`) — true-envelope cascade (`Vi = lifter(max(|X|, V{i-1}))`),
  cleaner formant/pitch separation on high notes. `playTrue`.
- **`\autotuneRB`** (`:241`) — **RubberBand** transposition (native formant preservation, no
  cepstral chain). Time and pitch are independent here — the hook for §2a/§2c. `playRB`.
- **`\retunePreview`** (`:275`) — single-segment audition (gui click / `playNote`).

### Editing + versioning
- **gui** (`Retune.sc:21`) — piano-roll editor. Double-click split, right-click merge, drag a
  note's right edge to move a boundary, click to audition, "save split-take" button. Now drives
  navigation through **`PianoRollNav`** (`Trek/MW-Classes/PianoRollNav.sc`): `h/l` scroll,
  `H/L` zoom (left-anchored ×1.2/×0.8), `J/K` octave pitch-scroll, `0` reset, `?` help. Verified
  headless (transforms, zoom/scroll clamping, key dispatch).
- **Structural edits** (`splitAt` `:411`, `merge` `:423`, `moveBoundary` `:434`) re-segment
  from the retained per-frame data via `prNoteForSpan`.
- **Split-takes** — `save` (`:175`) appends an immutable version under
  `~/tank/SC_audiofiles/_retune/<name>_<num>/<n>.retune`; most recent loads by default.
  `reanalyze` (`:280`) re-renders and appends a fresh take (recovers notes a stale/older
  analysis missed). Legacy pre-key takes migrate to `key = position` on load (`prLoad` `:253`).
- **Stable fractional keys** (built 2026-06-23) — references survive edits. Split keeps the left
  key, right = `(k + nextKey)/2`; merge keeps the lower key; integer `N` addresses the whole
  original note `[N, N+1)`. `fromNote`/`playNote`/`move`/`set`/`bypass` are key-based. Verified
  on real take data incl. the migration path.

### Recent fixes (this session)
- Low note after a large downward leap was missing → it was a **stale saved take**, not octave
  fold (octfold shift 0); fresh re-analysis found it (MIDI 46, conf 0.92). Added `reanalyze`.
- `windowSize 1024 → 2048` default in `trackPitchOffline` (low-pitch confidence).
- **Curve-buffer leak fixed.** Every `play*` allocated a fresh 4-ch curve via
  `Buffer.loadCollection` and never freed it (`render`'s `curve !? _.free` is a no-op on a fresh
  `fromNote` player). Over a session the leaked curves churned the allocator until one landed on
  the 1-ch voice buffer's bufnum → "Buffer UGen channel mismatch: expected 1, yet buffer has 4
  channels". Fix: `prPlay` captures the curve and frees it on `synth.onFree`, so each curve lives
  exactly as long as its synth. Verified on the live server via a second (attached) client.

---

## 2. Requested next steps (2026-06-23)

### 2a. Playback rate control  ← agreed FIRST STEP
"No control over the rate of playback yet — exposing it might suggest ideas."

All three engines already take a `rate` arg, but it behaves very differently per engine:

- **Cepstral (`\autotuneNotes`/`Notes True`)** drive a `Phasor.ar(rate * BufRateScale…)` — `rate`
  **resamples** the buffer, so it changes speed AND pitch together. Worse, the per-frame
  correction reads `measured` from the curve at `frame = pos/analysisHop`, but that stored
  `measured` is the *un-resampled* pitch, so at `rate ≠ 1` the correction target is computed
  against the wrong pitch → mistuned. Cepstral `rate ≠ 1` is currently incorrect for tuning.
- **RubberBand (`\autotuneRB`)** decouples cleanly: `rate` (time-stretch) and `pitchShift`
  (= the tuning ratio) are independent inputs. The parallel curve `Phasor` advances at the same
  `rate`, so curve sync holds; `pitchShift` is derived from the stored (original-pitch)
  `measured`, so tuning stays correct at any rate. **This is where rate control belongs first.**

Status: **done 2026-06-23.** `rate` is a first-class named arg on `RetunePlayer`/`RetuneItem`
`play`/`playTrue`/`playRB`; every other SynthDef control rides a real-keyword pass-through via
SC's `...kwargs` capture (PR #6339): `playRB(rate: 0.5, formant: 1, amp: 0.3)`. `playRB(rate: 0.5)`
= half speed, same pitch.
- **Decision honoured:** cepstral `play`/`playTrue` clamp `rate ≠ 1` to 1 with a warning
  (`prCepstralRate`, `Retune.sc`); only `playRB` time-stretches. A later cepstral fix would scale
  `measured`/`target` by `rate`, or move to a PV time-stretch (independent hop) — deferred.
- Windowed playback (`startPos`/`playDur`) is rate-independent (Phasor end is a buffer
  *position*), so `fromNote(...).playRB(rate: 0.5)` works.
- **Follow-on — rate `Env` (deferred).** Allow an `Env` for `rate`: accel/rit/rubato gestures,
  and the hand-authored precursor to §2c's time-warp. Design fork to settle when built: Env over
  **output/wall-clock time** (trivial — `EnvGen.ar` → `rate`) vs over **source position** (what
  quantize needs; nonlinear, since position is the integral of rate). Needs RB `rate` to be
  per-block modulatable (`pitchShift` already is — verify against the plugin at build).
- Ideas this unlocks: transport / scrub bar, loop region, play-from-cursor, and the variable-rate
  primitive §2c needs.

### 2b. gui parity with MIDIItem — 92-note scroll + visible piano-roll keys
"Copy the same 92-note scroll so the windows are more similar. I'd also like to see the piano-roll
notes." (i.e. render the keyboard so notes sit on visible key rows, like `MIDIItem.gui`.)

Two parts, both pointing at code reuse:

1. **Vertical model.** Retune currently auto-fits `[loNote, hiNote]` to the vocal range.
   MIDIItem uses a fixed `noteRange = 92` (MIDI 36–127) with `startMidiNote` octave scroll
   (`MIDI-Item2.sc:417/450`). `PianoRollNav` already has the pitch window + `pitchUp/Down`;
   generalise it with a configurable `noteRange` (default 92) and octave-scroll clamping so both
   guis share one model. **Tension:** 92 notes in Retune's 460 px view = ~5 px/row (MIDIItem
   uses a 1600 px view inside an 800 px window). Decision needed: enlarge the Retune view to
   match, or keep `noteRange` configurable (default 92, narrower default for vocals).
2. **Piano-roll keys** ("see the notes"). Draw black-key row shading + C/octave labels like
   MIDIItem's `isBlackKey` / `midiNoteToName` (`:453/:457`). Extract this into `PianoRollNav`
   (e.g. `drawKeyboard(pen)`) so **both** guis render identical keys.
3. **Migrate `MIDIItem.gui` onto `PianoRollNav` too** — once the vertical model + keyboard draw
   live in the shared class, both guis want the same code. This is the natural moment for true
   single-source (it was deferred when adding zoom to avoid risking the working MIDI gui).

### 2c. Quantize methods from MIDIItem (rate's natural sequel)
"I'd like the same quantize methods available from MIDIItem."

The wrinkle: MIDIItem `quantize` (`:670`) warps **symbolic note timestamps**. For a vocal, the
notes are tied to **real audio**, so quantizing onsets to a grid means **time-warping the audio**
so onsets land on the grid — i.e. variable-rate playback. Two layers:

1. **Symbolic layer (cheap).** Retune notes already subclass `AbstractMidiEvents` and carry
   `timestamp`/`dur`/`sustain`, so `quantize`/`from`/`fromBeat`/tempomap could be reused on the
   note *model*. On its own this only moves the model, desyncing it from the audio curve — but
   it produces the target grid.
2. **Audio layer (the real work).** Drive a **time-varying RB `rate`** from the resulting tempo
   map so audio onsets follow the quantized grid. RubberBand's `rate` is a per-block-modulatable
   input (its `pitchShift` already varies every block via the tuning ratio, so `rate` can be
   driven the same way) → feed it a warp curve baked from `MIDIItemTempoMap` (`env`/`invEnv`,
   `.curve`) in `quantize-tempomap-project.md`.
   Because the curve `Phasor` reads by SOURCE position, curve sync survives the varying rate.
   §2a (variable RB rate) is the prerequisite primitive.

Open decisions:
- **Anchors / "what's a beat?"** — user-selected onsets (MIDIItem gui `e`/`E` extrapolate/DP
  tracker) vs. every detected note onset. The selection machinery lives on MIDIItem; sharing it
  into the Retune gui is large — start with "each note onset → nearest grid position."
- This is where the two projects formally connect; keep the tempo-map work in its own doc and
  consume it here.

### 2d. Reference-guided tuning — `tuneTo(reference)` (blue-sky, designed 2026-06-24)
"Provide a target tune (pitches + durations) and have the tuner adjust the notes to it." =
score-guided correction (Melodyne's *follow a reference*, Auto-Tune graph mode with a MIDI guide).
It reuses nearly everything already built and is where this project and the tempo-map project
fully merge.

**Key insight — an alignment IS a tempo map.** `MIDIItemTempoMap` (`MIDI-Item2.sc:1562`) already
holds `env` (performedTime→idealBeat) and `invEnv` (idealBeat→performedTime) over matched anchors
— exactly a score↔audio warp. A reference tune is a beat-domain pitch sequence; "align audio to
it" = find, per detected note, which reference beat it sits at = that anchor set. So:
- once the warp exists, tuning is trivial: per detected note, `env.at(onset)` → beat → read the
  reference pitch at that beat → set the note's target.
- discovering the warp from pitch content yields the *same* anchor set. So **reference alignment
  is a tempo-map estimator** — and one alignment produces BOTH the per-note pitch targets AND the
  tempo map.

**Why durations matter** (Michael's instinct, confirmed). Pitch-only reference is ambiguous on
repeated pitches and breaks under over/under-segmentation. Durations give the beat axis →
alignment matches in 2D (pitch AND time), disambiguates repeats, and is *what lets the alignment
emit a tempo map at all*. Without durations there is no beat axis to warp onto.

**Correction mechanics (cheap).** The 4-ch curve is `[measured, measuredCenter, targetCenter,
confidence]`. "Tune note N to pitch P" = set `targetCenter` across N's frames to P — which
`RetunePlayer.set` already does, key-based. So `tuneTo` = **align → set-per-note**; all the new
work is in the alignment. Two freebies:
- *Expression preserved* — engines retune `measured→target` but ride `(measured − measuredCenter)`
  on top, so snapping the center keeps vibrato/scoops.
- *Octave errors fixed for free* — match in pitch-class (mod 12) so an octave slip can't break the
  alignment; apply the correction in absolute pitch from the reference → the reference repairs
  detection octave glitches (the latent `*prOctaveFold` issue, §5).

**Two amount axes, one warp — "moving onsets is worth preserving" (2026-06-24).** Pitch-snap and
time-snap are independent knobs (Melodyne's separate pitch/time handles): tune pitch with onsets
frozen, warp onsets with pitch untouched, or both. The time axis is just `amount = 0` by default,
not absent. The architectural consequence, even for the pitch-only first build: **the warp is a
first-class, persisted artifact** (store anchors + reference on the take-version alongside the
curve), NOT a throwaway intermediate — else moving onsets later means re-aligning. Onset-warp then
reuses §2c (variable RB `rate` from the warp's local slope); it could ride as a **5th curve
channel** so one buffer drives pitch+time (pitch-only = that channel pinned at 1.0).
- *Downstream consequence to track* (defer; doesn't bite the pitch-first build): warping onsets
  moves note boundaries in AUDIO time, so the note model/gui eventually read in grid-time.

**Two ways to get the correspondence:**
1. **Anchored (build first).** Reuse the existing selection / beat-tracker machinery (MIDIItem gui
   `e`/`E`, `MIDIBeatTracker`) to get the warp, then read reference pitch per beat → `set` targets.
   Mostly wiring on proven machinery; gives a working `tuneTo` fast and proves the target-from-map
   plumbing.
2. **Content DTW (the new hard piece).** DTW between the detected pitch contour and the reference
   contour, allowing insertions/deletions (extra detected note = breath/ornament; reference note
   with no detection = gap). Its edit operations ARE the fractional-key split/merge (two segs → one
   ref note = merge; one seg over two ref notes = split). Output = the same anchor set → a tempo
   map. Today tempo is guessed from onset salience alone (pitch-blind, Ellis DP); a reference makes
   it joint pitch+rhythm — far better constrained.

**Failure modes + escape hatch.** No auto-pass is perfect (repeats, ornaments, breaths, rests).
The manual override already exists: the selection-pin gui + fractional split/merge. Promise "good
first pass + gui correction," the Melodyne reality.

**Reference input — don't require a full MIDIItem.** What the alignment consumes is just
`(pitches, beatOnsets)`. So `tuneTo` reduces ANY reference to that pair and accepts either a
MIDIItem or the raw spec. A MIDIItem is the convenient carrier (brings its own tempomap/quantize/
gui); the spec is the compact authoring form.

**First brick — `asMIDIItem`.** Authoring a MIDIItem by hand is non-trivial; want
`[midinote: [5,6,7], dur: "q e e".beats].asMIDIItem`.
- *Already exists*: `String.beats` (`plusParser.sc:57` — parses `"q e e"`→`[1,0.5,0.5]`, supports
  `e*4` multipliers, grace `g`, `h/w/t`; `tempomap` already calls it) and per-token `String.asBeats`
  (`plusString.sc:27`); `MIDIItem.newFrom(midiEvents)` (`MIDI-Item2.sc:730`) builds an item from a
  raw event list.
- *Built 2026-06-24* (`MIDI-Item2.sc` bottom: `+ Event` core + `+ SequenceableCollection` keyword-
  array entry). Per note i emit a paired noteOn/noteOff with `onset = dur.integrate.drop(-1)
  .addFirst(0)`; `dur` accepts an Array, a scalar, or a rhythm String (auto-`.beats`); `amp`
  optional. **Format gotcha (learned the hard way):** the events must be the RAW recorded form
  `type: \mk` (noteOn) / `\mkOff` (noteOff), NOT `\midi`. `makeNotesFromMidiEvents` does
  `on ++ array.reject{type == \mk}` — it pairs offs into each noteOn's `sustain` and rejects the
  raw `\mk` copies; with `\midi` the noteOns survive the reject and **double** (persisted real
  items with `\midi` actually double through this path too). And it does NOT route through
  `MIDIItem.newFrom` — that names items after the `UniqueID` *class* (not `.next`), so repeated
  builds alias/overwrite in `MIDIItem.all`; instead it constructs `MIDIItem("ref_"++UniqueID.next)`.
  Verified headless: `player.notes` → clean `[60,62,64]` @ onsets `[0,1,1.5]`, sustains
  `[1,0.5,0.5]`, bounds `[0,2]`, rhythm-string + scalar forms, and two builds stay distinct.
- *Timebase caveat*: these timestamps are in BEATS (a reference is a score, not a performance) —
  exactly what the alignment wants. But MIDIItem gui/playback assume seconds, so to see/hear the
  reference you interpret beats at a nominal tempo.

**Persist.** `tuneTo` saves the alignment (anchors + reference) onto the take-version next to the
curve, so it is re-editable and the onset-warp can be applied/un-applied independently of the
pitch correction.

---

## 2e. `moveNote` / `asTune` / anchors — the time-move axis (designed 2026-07-02, NOT built)

Request: `aTake.retune.moveNote(index, startDelta, endDelta)` to move individual notes, plus (a)
MIDIItem/Retune **filter parity**, (b) a rename — "Retune" bakes in the *purpose*; the object is
really "consider this audio as a monophonic tune," so **`asTune`**, and (c) **anchor points** for
audio that is not a tune (transient/manual), all cohering with quantize/tempomaps.

**`moveNote` IS the frozen-onset axis (§2d/§9), and it forces the deferred decision.** Today a note's
`timestamp`/`dur` does two jobs at once: **source position** (`render` reads `frame = timestamp*sr/aHop`
from the retained arrays; `prPlay` windows the buffer at `playStart`) AND **output position** (one
Phasor sweeps the buffer at constant rate, so they're identical). "Onsets are frozen" is exactly that
identity. `moveNote` breaks it: the note's **audio stays put in the take** but **sounds at a shifted
time / stretched duration**. So a note needs two spans:
- `srcStart, srcDur` — fixed, from the recording (what today's `timestamp`/`dur` really are).
- `timestamp, dur` (OUTPUT) — editable; `rate = srcDur/outputDur`, `delay = outputStart`.
That difference IS a src↔output warp — i.e. a `MIDIItemTempoMap`. `moveNote` edits it locally; §2c
`quantize` produces it from a grid; §2d alignment produces it from a reference. **Same object, three
sources.** This is the "plays well with quantize/tempomaps" ask: they're not adjacent features, they
are the same warp.

**The renderer already exists.** `AudioItem.tempoFollowActions` (`AudioItem.sc:143`) already schedules
ONE `\audioItemTempoFollowRB` synth **per segment**, each with its own `rate`, `startPos`, `delay`,
off a tempo map. That is precisely the render a warped Tune needs. So:
```
Tune note model ──▶ warp (src↔output, == MIDIItemTempoMap) ──▶ per-segment RB (tempoFollow-style)
```
Falls out cleanly: per-note `rate ≠ 1` is **RB-only** (cepstral resamples/mistunes at rate≠1, §2a/§5),
so a moved note renders on `\autotuneRB`; an unmoved Tune can still use the cepstral chain. Gaps =
silence, overlaps = both play (crossfade) — Melodyne-like "slip" mode; "ripple" (neighbours follow) is
a later mode.

**Naming.** `RetuneItem→Tune`, `RetunePlayer→TunePlayer`, `AbstractRetune→AbstractTune`; `aTake.asTune`
primary; **`retune` kept as an alias** (`^this.asTune`) — reads well for the pitch-fix path, keeps
back-compat + saved-take headers. `retune` conceptually = a Tune with `snapToScale`/`tuneTo` applied,
not a separate class.

**Anchors for non-tune audio — same spine, drop the pitch.** A note is one kind of anchor (pitch+time);
a bare anchor is time-only. Anchors come from note onsets (Tune), transient detection, or manual GUI
placement — all feed the *same* src↔output warp and the *same* per-segment renderer. `aTake.asClip`
(or `.warp`/`.anchors`) → transient/manual anchors, no pitch, but full quantize/moveNote/tempomap.
Follow-on, but designing `moveNote` on the *warp* (not on pitch) now is what makes `asClip` free later.

**Class hierarchy — subclass the ANALYSIS side, not `AudioItem` (decided 2026-07-02).** Q raised: any
AudioItem should carry warp markers whether or not it has pitch (needed to record audio *fragments* in
reference to an `EventList` tempomap); only some can be analysed/retuned — so `AudioTune : AudioItem`?
Decision: **no.** The is-a ("a tune IS a warpable clip that also has pitch") is real but belongs one
layer UP from the recorder. `AudioItem` is the recording slot (takes, `Recorder`, arm); `Take` is one
buffer; warp/pitch are *non-destructive versioned views over a take's buffer* (exactly how `RetuneItem`
saves `.retune` archives under `_retune/`). Subclassing `AudioItem`→`AudioTune` collapses three layers:
(a) item≠take — take 0 and take 3 have different transients, so warp is per-buffer; (b) pitchedness is
*discovered by analysis*, not declarable at construction; (c) it re-entangles recorder + analysis. So:
```
AbstractMidiEvents
 └─ AbstractWarp        anchors (src<->output) + moveNote/quantize/warpTo + per-segment RB render
     ├─ ClipItem / ClipPlayer      bare warp anchors (transient/manual); no pitch    <- Take.asClip
     └─ AbstractTune : AbstractWarp    + pitch note model + snapToScale/tuneTo/bypass
         └─ TuneItem / TunePlayer      anchors ARE note onsets; + per-frame pitch/conf <- Take.asTune (retune alias)
```
An anchor is the primitive `(srcTime->outTime)` point; a note = anchor pair + pitch + span semantics.
Every `AudioItem`/`Take` gets markers via `.asClip`; only pitched material also answers `.asTune`.

**Take vs Clip — keep both, distinct roles (2026-07-02).** Same relationship as `Take`<->`RetuneItem`:
`Take` = raw buffer + recording identity (`: AudioItem`, knows the takes dir/num), recorder-side;
`ClipItem` = one *versioned* warp view that *references* the take's buffer (`voice = take.buffer`),
analysis-side. 1 take -> many clip versions (like split-takes), so they can't be one object; folding
warp onto `Take` would drag recorder machinery into the analysis object (the `AudioItem`-subclass smell,
one level down). A take with no markers needs no Clip — it plays straight (today's behaviour); Clip is
the opt-in warp layer. (Open sub-q: do `ClipItem` and `TuneItem` stay separate classes, or one
`WarpItem` with optional pitch? Subclass is cleaner since pitched adds methods meaningless without
pitch — but revisit if the archive schemas want to converge; see versioning.)

**EventList integration is ~80% built.** `AudioItem.tempoFollowActions` (`AudioItem.sc:143`) already
warps a take to an `EventList` tempomap, but with a UNIFORM src<->beat map
(`srcOffset = sourceBeatDur ? baseWallDelta`). Markers generalize that to an *anchor map* interpolating
`(srcTime<->beat)` through pinned points; `ClipItem` emits the `srcOffset`/tempomap that
`tempoFollowActions` already consumes — per-segment RB render unchanged. This is the fragment workflow:
record against the list tempomap (record-start beat is already `ev[\when]`), stamp anchors
(transient/manual), warp back onto the grid. Ableton's model exactly.

**Versioning — OPEN (discussing 2026-07-02).** Questions on the table, not yet decided:
- *One version axis or two?* §2d/§2e want the onset-warp applied/un-applied independently of pitch
  correction — but that can be a RENDER choice (honour src-vs-output), not separate files. Leaning:
  ONE linear append-only history per take (snapshot = anchors + warp + pitch), extend the existing
  split-take schema with `srcStart`/`srcDur` (birth = identity) rather than fork a second history.
- *One archive, two lenses?* A Tune archive is a SUPERSET of a Clip archive (adds pitch + per-frame
  arrays). Want `asClip` on a take that has Tune versions to read the same anchors (ignore pitch), so a
  unified dir + a `kind` field beats separate `_retune`/`_clip` trees that silently diverge.
- *Anchor stability.* Bare anchors need the fractional-key trick too, so an EventList reference
  ("beat 3 pins to anchor k") survives adding/removing other anchors.
- *Reference-to-version.* An EventList `\audioItemTempoFollow` event must name a version (default
  latest); append-only numbering already gives stable ids.
- *Migration.* Existing `.retune` archives must keep loading (add `srcStart`/`srcDur` defaults + a
  `kind: \tune` marker on load, like the current key migration).

**Filter parity — lift symbolic filters to the shared base.** MIDIItem's `from`/`fromNote`/`fromBeat`,
`quantize`, `filter`/`filterNotes`/`filterNotesKey`, `set`/`setParams`, `removeNote`, `warpTo`, `trim`,
`notesStraddling` are pure note-model ops; Tune notes already subclass `AbstractMidiEvents`, so they
belong on the shared base — both players inherit them. The *filter* is shared; only the *realization*
differs (MIDIItem replays symbolic timestamps; Tune warps audio to them). Retune-only (`snapToScale`,
`tuneTo`, `bypass`) stays Tune-side.

**Open forks (asked 2026-07-02, awaiting Michael; recommended defaults in bold):**
1. Rename appetite: full `Retune*→Tune*` + `retune` alias / **add `asTune` alias only** / rename later.
2. `moveNote` API: **`moveNote(key, startDelta, endDelta)` in seconds, key-based** (like `move`/`set`,
   survives split/merge) / `index`+seconds (as written, but positions renumber) / key+beats (needs the
   tempomap layer up front).
3. Render: **per-segment RB now** (reuse `tempoFollowActions`; ships fast; RB-only) / unified 5th-channel
   variable-rate Phasor (§2d; one synth, serves cepstral+quantize, but bigger and blocks `moveNote`).

**Additive build plan (each step reversible, testable headless for the model part):**
1. Add `srcStart`/`srcDur` to the note Event (birth = current `timestamp`/`dur`); make `render`/`prPlay`
   read the SOURCE span, output span drives scheduling. No behaviour change while output==source.
2. `moveNote` symbolic filter (new `TunePlayer`, key-based) sets output `timestamp`/`dur` → per-note rate.
3. Per-segment RB playback method (`playWarp`, or teach `playRB` to honour per-note rates) reusing the
   `\audioItemTempoFollowRB` scheduling; leave existing `play`/`playRB` paths untouched.
4. Lift the symbolic MIDIItem filters onto `AbstractMidiEvents`; wire `quantize` on the Tune → warp.
5. (later) `asClip` transient/manual anchors; `asTune` rename; gui drag = `moveNote`.

---

## 3. Reuse opportunities
- **`PianoRollNav`** (done) — viewport + zoom/scroll/pitch + pixel transforms, shared.
- **Keyboard-draw helper** in `PianoRollNav` (§2b.2) — both guis draw the same keys.
- **Migrate `MIDIItem.gui` onto `PianoRollNav`** (§2b.3) — single source for navigation.
- **`AbstractMidiEvents` quantize/from/fromBeat/tempomap** — retune notes are already
  subclasses; the symbolic layer of §2c is mostly wiring, not new machinery.
- **Variable-rate RB primitive** — shared by §2a (manual rate) and §2c (tempo-map-driven rate).
- **`String.beats`/`asBeats` + `MIDIItem` construction** — `asMIDIItem` (§2d, done) is a thin
  bridge over existing rhythm parsing + `makeNotesFromMidiEvents`; only the spec→events glue is new.
- **`MIDIItemTempoMap` as the alignment** (§2d) — a reference warp IS a tempo map; reuse
  `env`/`invEnv`/`.curve`. The variable-rate RB primitive then moves onsets off it.
- **Selection-pin gui + fractional split/merge** — the manual-correction escape hatch for
  alignment failures (§2d), not new machinery.
- **`RetunePlayer.set`** — per-note absolute target-set is the entire correction step of `tuneTo`.

---

## 4. Suggested milestones
1. ~~**Playback rate control** via the RB engine (decoupled time/pitch); first-class `rate` arg;
   document the cepstral caveat.~~ (§2a) — **done 2026-06-23** (named `rate` + `...kwargs`
   pass-through; cepstral clamps to 1). Follow-on: rate `Env` (wall-clock first).
2. **gui parity**: configurable `noteRange`/92-note scroll + `drawKeyboard` in `PianoRollNav`;
   then migrate `MIDIItem.gui` onto it. (§2b, §3)
3. **Symbolic quantize** on the note model (reuse `AbstractMidiEvents`/MIDIItem machinery). (§2c.1)
4. **Audio time-warp**: tempo-map-driven variable RB `rate` (consume `quantize-tempomap-project`). (§2c.2)
5. (stretch) selection/extrapolate tempo tooling inside the Retune gui.

**Reference-guided tuning (§2d), designed 2026-06-24:**
6. ~~**`asMIDIItem`**~~ — compact spec → MIDIItem (`[midinote:…, dur:"q e e".beats]`). **Done
   2026-06-24** (`MIDI-Item2.sc`, `+ Event` / `+ SequenceableCollection`; verified headless). (§2d)
7. ~~**`tuneTo` (pitch-only) v0**~~ — **Done 2026-06-24** (`Retune.sc`: `RetunePlayer.tuneTo` +
   `RetuneItem.tuneTo`). Reduces a reference (MIDIItem or spec) to `(refPitch, refBeat)`;
   **normalized-time nearest-match** alignment (simpler than the selection/beat-tracker warp —
   graceful on count mismatch); target = reference pitch-class at the octave nearest the sung
   center, blended from `measuredCenter` by `amount` (1=full, 0=off); records `(refMidi, refBeat)`
   on each note so the warp anchors ride the note model. Verified headless. Onsets frozen.
   Deferred: selection/beat-tracker + DTW alignment (§8), disk-persisted warp, onset-warp (§9). (§2d)
8. **Content-DTW alignment** — automatic anchors, insert/delete driving fractional split/merge;
   pitch-class match / absolute correct. Output = a tempo map. (§2d)
9. **Onset-warp axis** — time-snap `amount` via §2c's variable RB `rate` off the persisted warp
   (optional 5th curve channel). (§2d, §2c.2)

**Time-move / anchors / rename (§2e), designed 2026-07-02 (NOT built):**
11. **`srcStart`/`srcDur` split** — decouple source span from output span on the note Event;
    `render`/`prPlay` read source, output span schedules. No behaviour change while equal. (§2e.1)
12. **`moveNote`** — key-based symbolic filter setting output `timestamp`/`dur` → per-note RB `rate`;
    the concrete instance of milestone 9's onset-warp. (§2e.2)
13. **Per-segment RB playback** (`playWarp`) — reuse `AudioItem.tempoFollowActions` scheduling; leave
    existing `play`/`playRB` untouched. (§2e.3)
14. **Filter parity** — lift symbolic MIDIItem filters onto `AbstractMidiEvents`; wire Tune `quantize`
    → warp. (§2e, §2c.1)
15. **`asTune` rename + `asClip` anchors** — `Retune*→Tune*` (retune alias); transient/manual
    anchor clips share the warp+render; gui drag = `moveNote`. (§2e)

**Engine quality (2026-06-24):**
10. **Adopt RubberBand R3 ("Finer") engine** — quality upgrade for `\autotuneRB`. R3 (RubberBand
    v3) has cleaner transients / less phasiness / better formants on monophonic vocal, and ships
    `R3LiveShifter`, a real-time pitch-shifter purpose-built for our case (shift + formant, no
    time-stretch). Both machines are M-series arm64, so the arm64-only R3 `.scx` runs on both —
    no arch blocker. NOT a blind copy: dropping the R3 quark in produced **metallic distortion**
    (see §5), which is misconfiguration, not R3 being worse. The task: (a) put the *identical* R3
    quark (`.scx` + `.sc`) on both machines; (b) dial in the R3-only options the SynthDef currently
    leaves at 0 (`pitchMode`, `window`, `channelMode`, `transients`, `detector`, `phase`) and
    verify the `engine` integer actually selects Finer/LiveShifter (mapping never confirmed);
    (c) measure R3's latency and set `look`/`dryLatency` for it (ours were tuned for R2); (d) A/B
    vs R2 and, if it wins, switch both. R3 quark backed up on the mini at `~/RubberBand.r3-bak`.

---

## 5. Known issues / backlog
- [ ] **RubberBand quark/engine differs across machines** (investigated 2026-06-24). `\autotuneRB`
  (`vocoders.sc:241`) passes `transients, detector, phase, engine` by keyword. Two installs found:
  - **MacBook** (M4): `RubberBand.scx` 817 KB **universal** (x86_64+arm64), R2 engine; `.sc` `*ar`
    has 9 inputs (no `engine`/etc.) → those kwargs are **silently dropped**, so only `formant` is
    live. md5 `.scx` `d2125328…`, `.sc` `f3d2adeb…`.
  - **mac mini** (M-series): `.scx` 393 KB **arm64-only**, **R3** engine (`R3Stretcher`/
    `R3LiveShifter` symbols); `.sc` `*ar` has 16 inputs incl. `engine, pitchMode, window, …`.
  Our default `engine=1` is a no-op on R2 (MacBook) but selects an engine on R3 (mini) → the mini
  produced **metallic distortion**. Root cause: engine/quark difference + unconfigured R3 options +
  R2-tuned latency, NOT sample rate (both servers at 48 kHz). **Resolved for now by standardizing
  both on R2**: copied the MacBook's universal R2 quark (both files) to the mini; mini's R3 saved at
  `~/RubberBand.r3-bak` (kept OUTSIDE Extensions — a `.sc` left under Extensions triggers
  "Duplicate Class Found"). Proper R3 adoption is milestone 10.
  - **Cross-machine gotcha:** keep the RubberBand quark identical on all machines; `engine`/
    `transients`/`detector`/`phase` are silently ignored on the R2 quark but active on R3, so the
    same SynthDef sounds different per machine.
- [ ] **Cepstral `rate ≠ 1` mistunes** (§2a) — output lands `12·log2(rate)` semitones off.
  Keep `rate ≠ 1` on the RB engine until a cepstral compensation / PV time-stretch lands.
- [ ] **Octave-fold can fold a genuine large downward leap up an octave** (`*prOctaveFold`).
  It didn't bite the 2026-06-23 missing-note case (octfold shift was 0 there) but it's latent —
  it can't tell a sustained leap from an octave glitch. Real fix: gate on duration (glitches are
  short) or only fold near-octave residuals.
- [ ] **`reanalyze` needs a recompile to call.** The 2026-06-23 stale-take fix was applied
  inline in the live session (appended split-take 4); the method (`Retune.sc:280`) is on disk but
  not yet compiled into Michael's session.

---

## 6. Testing notes
- **Pure-language tests run headless** — the note model, stable keys, nav math, and segmentation
  are all language-side. A stock `sclang <file>.scd` loads the Trek classes AND reads a real
  `.retune` take from disk (no server), which is how stable keys + nav math were verified this
  session. Use flat top-level statements (paren-blocks hang under `sclang file.scd`).
- **Audio engines need the server.** `trackPitchOffline` renders NRT in its own scsynth, so it
  doesn't disturb the live one.
- **Recompile caveat (important).** Recompiling the live scnvim session re-runs Michael's startup
  and **reboots scsynth** — recompile AT MOST once per change, warn first, and prefer handing him
  a one-line check (memory `feedback_scnvim_recompile_reboots`). To test the NEW classes without
  recompiling his session, spawn a tool-owned sclang and multi-client it to the running scsynth
  (skill `sclang-attach`); to introspect his live `~r`/take state, drive his session over the
  scnvim socket (eval/`send`, no recompile).

---

## 7. Key files
- `Trek/MW-Classes/Retune.sc` — `AbstractRetune`/`RetuneItem`/`RetunePlayer`, `gui`, stable keys,
  split-takes, `reanalyze`, structural edits.
- `Trek/MW-Classes/vocoders.sc` — engines (`\autotuneNotes`/`NotesTrue`/`RB`, `\retunePreview`),
  `*trackPitchOffline`, segmentation (`*prSegment`/`*prOctaveFold`/`*tuneCurve`).
- `Trek/MW-Classes/PianoRollNav.sc` — shared viewport / zoom / scroll / pixel transforms.
- `Trek/MW-Classes/AudioItem.sc` — `Take.retune` entry, take/buffer source.
- `Trek/MW-Classes/MIDI-Item2.sc` — `MIDIItem.gui` (92-note model `:417/:450`, `isBlackKey`
  `:453`), `quantize` `:670`, `from`/`fromNote`/`fromBeat`, `newFrom` `:730` (raw-events ctor for
  `asMIDIItem`), `MIDIItemTempoMap` `:1562` (the §2d warp).
- `Trek/MW-Classes/plusParser.sc` — `String.beats` rhythm-string parser (`"q e e"`→beats; §2d).
- `Trek/MW-Classes/plusString.sc` — `String.asBeats` (per-token note value).
- `quantize-tempomap-project.md` — tempo-map / quantize machinery consumed by §2c **and §2d**
  (the reference alignment is one of its maps).
