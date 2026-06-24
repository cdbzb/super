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
- *Missing*: `asMIDIItem`. ~15 lines, pure-language, on `Event`/`Array` (the keyword-array literal
  is `.asEvent`). Per note i emit `(midicmd:\noteOn, midinote: m[i], timestamp: onset[i], vel:64)`
  + `(midicmd:\noteOff, midinote: m[i], timestamp: onset[i]+dur[i])` with
  `onset = dur.integrate.drop(-1).addFirst(0)`, then `MIDIItem.newFrom`. Pairing-by-`midinote` is
  safe for a monophonic reference (adjacent same-pitch notes don't overlap).
- *Timebase caveat*: these timestamps are in BEATS (a reference is a score, not a performance) —
  exactly what the alignment wants. But MIDIItem gui/playback assume seconds, so to see/hear the
  reference you interpret beats at a nominal tempo.

**Persist.** `tuneTo` saves the alignment (anchors + reference) onto the take-version next to the
curve, so it is re-editable and the onset-warp can be applied/un-applied independently of the
pitch correction.

---

## 3. Reuse opportunities
- **`PianoRollNav`** (done) — viewport + zoom/scroll/pitch + pixel transforms, shared.
- **Keyboard-draw helper** in `PianoRollNav` (§2b.2) — both guis draw the same keys.
- **Migrate `MIDIItem.gui` onto `PianoRollNav`** (§2b.3) — single source for navigation.
- **`AbstractMidiEvents` quantize/from/fromBeat/tempomap** — retune notes are already
  subclasses; the symbolic layer of §2c is mostly wiring, not new machinery.
- **Variable-rate RB primitive** — shared by §2a (manual rate) and §2c (tempo-map-driven rate).
- **`String.beats`/`asBeats` + `MIDIItem.newFrom`** — `asMIDIItem` (§2d) is a thin bridge over
  existing rhythm parsing + item construction; only the spec→events glue is new.
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
6. **`asMIDIItem`** — compact spec → MIDIItem (`[midinote:…, dur:"q e e".beats]`). Pure-language
   first brick; independently useful. (§2d)
7. **Anchored `tuneTo` (pitch-only)** — reduce any reference to `(pitches, beatOnsets)`; reuse
   selection/beat-tracker for the warp; **persist** it; `set` targets per matched note. (§2d)
8. **Content-DTW alignment** — automatic anchors, insert/delete driving fractional split/merge;
   pitch-class match / absolute correct. Output = a tempo map. (§2d)
9. **Onset-warp axis** — time-snap `amount` via §2c's variable RB `rate` off the persisted warp
   (optional 5th curve channel). (§2d, §2c.2)

---

## 5. Known issues / backlog
- [ ] **RubberBand quark mismatch.** `\autotuneRB` (`vocoders.sc:241`) passes `transients`,
  `detector`, `phase`, `engine` to `RubberBand.ar`, but the installed quark
  (`~/Library/Application Support/SuperCollider/Extensions/RubberBand/Classes/RubberBand.sc`)
  only accepts `numChannels, bufnum, rate, pitchShift, trig, startPos, loop, doneAction, formant`.
  The four extra kwargs are silently ignored (runtime warnings) → no R3/"Finer" engine, transient
  or phase control today; only `formant` preservation is live. Decide: upgrade the quark to a
  build exposing `engine`, or drop the dead args.
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
