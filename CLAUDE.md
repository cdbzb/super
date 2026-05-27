# SuperCollider Project Context (`~/tank/super`)

This is the root of Michael's SuperCollider work. Yoeminrak (Korean shaman song system), Trek (MW utility classes), Mandarin, and various song/etude/sketch folders live here.

## SuperCollider Documentation
- Online docs: https://docs.supercollider.online
- Local class library: inside the SuperCollider.app bundle (`/Applications/SuperCollider.app/Contents/Resources/SCClassLibrary/`)
- sclang config (determines loaded paths): `/Users/michael/Library/Application Support/SuperCollider/sclang_conf.yaml`
- Project-level sclang config also at: `/Users/michael/tank/super/sclang_conf.yaml`

## Class File Locations

### Yoeminrak music system
- Main class: `Yoeminrak/Yoeminrak.sc`
- Event types: `Yoeminrak/eventTypes/`
- Songs: `Yoeminrak/songs/` — the source of the tangled file in here is `~/home/org_roam_files/yoeminrak-tangleDoc-12-25.org`; edit the org file, not the tangled `.sc`.
- Ornaments: `Yoeminrak/ornaments/`

### MW extension classes (`Trek/MW-Classes/`)
- `myClasses.sc` — defines `.q` on SequenceableCollection: `Pseq(this.asList, repeats)`
- `degreesFreq.sc` — `.df(root, octave, scale)` = degrees→cps; `.dm` = degrees→midi; `.dr` = degrees→midiratio. Defined on Object (delegates to element-wise via plusArray)
- `plusArray.sc` — defines `degreescps`/`degreesmidi`/`degreesmidiratio` on SequenceableCollection (element-wise collect); also Pseq extensions
- `PolyGate.sc` — defines `.dq` (Dseq demand UGen wrapper)
- `plusPseq.sc` — Pseq `.at` extension
- `plusTempoClock.sc` — TempoClock extensions
- `MicroKeys.sc` — MicroKeys class for MIDI

Also check `Trek/MW-classes/` (lowercase c) — duplicate location for some files.

### Active Quarks (from sclang_conf.yaml)
All in `/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/` unless noted:
`miSCellaneous_lib`, `MathLib`, `FPLib`, `Modality-toolkit`, `VectorSpace`, `Ctk`, `JITLibExtensions`,
`wslib`, `BatLib`, `MathLib`, `Vowel`, `Bjorklund`, `panola`, `JSONlib`, `TuningLib`, `Strang`,
`Notator`, `Smart`, `Log`, `API`, `Singleton`, `Collapse`, `Deferred`, `Cluster`, `atk-sc3`,
`AmbiVerbSC`, `ReaCollider`, `ScoreClock`, `SFPlayer`, `Hilbert`, `KDTree`, `XML`, `FileLog`,
`fxpatterns`, `faust`, `Graphical-Module`, `scel`, `SignalBox`, `Require`, `Barrier`, `scparco`,
`OfflineProcess`, `WindowViewRecall`, `outputfx`, `matrixarray`, `UnitTest2`, `ZArchive`,
`SpeakersCorner`, `AmbIEM`, `AllGui`, `ExtraWindows`, `MP3`, `Automation`, `Freesound`,
`FreeAfter`, `SynthDefPool`, `ddwPlug`, `Scintillator` (from `~/.local/share/`),
`/Users/michael/tank/super/Trek` (MW-Classes), `/Users/michael/tank/super/Yoeminrak`

## Key SC Method Conventions (Yoeminrak/Trek)
- `.q` → `Pseq(array, 1)` — iterate once through array
- `.q(n)` → `Pseq(array, n)` — iterate n times
- `.p` → create Pattern (without playing)
- `.pp` → `Pbind(*array)` and play
- `.ppm` → `.pp` in mono mode
- `.df(\scale)` → array of degrees to frequencies (e.g. `[1,2,3].df(\c)`)
- `.dm(\scale)` → degrees to MIDI notes
- `=>` → pipe operator (passes left as arg to right function)
- `T(array, strum, curve)` → Tuple3 for chord with strum/envelope

## Yoeminrak Architecture
- `Yoeminrak.song` — Event/dictionary of song Lists, keyed by Symbol (e.g. `\twelve`)
- `Yoeminrak.env` — persistent Environment; `~key` reads/writes it after `.push`
- `Yoeminrak.secDur` — Array of section durations (differentiated from `sections`)
- `Yoeminrak.sections` — Array of section timestamps
- `Yoeminrak.env[\currentInstance]` — current playing string synth instance
- `Yoeminrak.env[\addMeSong]` / `[\addMeSection]` — set before `\addMe` events
- `\addMe` event type: adds events to song list; `newType:` sets the stored event type
- `\cyc` event type: plays a song by key; `\cycs` sequences multiple songs
- `extra:` function on events — called during playback by `stringEventType.scd` line 76 (`~extra !? _.()`)

## Running SuperCollider code

- sclang: `/Applications/SuperCollider.app/Contents/MacOS/sclang`
- For any automated test that touches the audio server, use the `sclang-attach` skill — it handles attaching as a real client to the user's running scsynth (which is the only way `SynthDef.send` / `Buffer.alloc` / synths actually function).
- Write multi-line SC code to `/tmp/*.scd` and `.load` it — never pipe multi-line code directly into sclang (the REPL parses line by line).
- Never send `s.quit` or `s.boot` from a tool-spawned sclang — user owns the server. Exit with `0.exit;`.
- Before killing any `sclang` process, verify it belongs to Claude (not the user's interactive session).
