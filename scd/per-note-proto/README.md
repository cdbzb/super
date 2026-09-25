# Per-note tempo follow prototype (2026-09-25)

Runtime-only prototype for `onset-gated-tempo-follow.md` (results in its "Prototype
results"). No class edits. Load in order in a live sclang whose `EventList.current` holds
the `vibes-test-1201` take-0 event with `followTrack: \marks`:

```supercollider
["pn-proto", "pn-proto-b", "pn-proto-scale", "pn-proto-lead"].do { |f|
	("~/tank/super/scd/per-note-proto/" ++ f ++ ".scd").standardizePath.load };
~pnLead = 0.05;
~pnPlay.(\oneSynth);   // or \perNote, \grid; optional 2nd arg = from beat
```

`~pnBeatScale` (default 2) stretches marks v3 beats. `vibes0-starts.txt` = note starts from
the ByteDance transcription (`~/tank/piano-transcribe/transcribe.py`).
