// Effect input-bus width: today the bus is the function's OUTPUT width, so a
// mono-output effect fed by a stereo writer spills channel 1 into the next bus.
// Effect.wideBuses widens narrow buses to max(inputChannels, outputs, 2);
// Effect.logNarrow records each narrow Effect once (narrowReport).
//
// Pure language: Effect.busChannels only — no server, no synth.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/effect-bus-width-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var reverb = { |i| FreeVerb.ar(i, 0.5, 1) }, panned = { |i| Pan2.ar(i, 0.3) };

"== Effect bus width tests ==".postln;
Effect.wideBuses = false; Effect.logNarrow = false; Effect.clearNarrowLog;

// ------------------------------------------------------------ default: unchanged
assert.(Effect.busChannels(reverb, 1, 1) == 1, "default: mono effect keeps a 1-channel bus");
assert.(Effect.busChannels(panned, 1, 2) == 2, "default: stereo output, 2 channels");
assert.(Effect.busChannels(reverb, 2, 1) == 1, "default: wider input than output is left as is");
assert.(Effect.busChannels(nil, 4, 4) == 4, "default: 4 in 4 out untouched");

// ------------------------------------------------------------ wideBuses
Effect.wideBuses = true;
assert.(Effect.busChannels(reverb, 1, 1) == 2, "wide: mono effect gets 2 channels (no stereo spill)");
assert.(Effect.busChannels(reverb, 3, 1) == 3, "wide: inputChannels wider than output: bus covers the input");
assert.(Effect.busChannels(panned, 1, 2) == 2, "wide: already stereo, unchanged");
assert.(Effect.busChannels(nil, 2, 5) == 5, "wide: wide output unchanged");
assert.(Effect.busChannels(nil, 4, 2) == 4, "wide: 4 in 2 out covers the 4");
Effect.wideBuses = false;

// ------------------------------------------------------------ logNarrow
Effect.logNarrow = true;
3.do { Effect.busChannels(reverb, 1, 1) };
Effect.busChannels(panned, 1, 2);
Effect.busChannels({ |i| HPF.ar(i, 200) }, 2, 1);
assert.(Effect.narrowLog.size == 2, "log: one entry per narrow function, wide ones not logged");
assert.(Effect.narrowLog.values.collect(_[\count]).asArray.sort == [1, 3], "log: repeats counted");
assert.(Effect.narrowLog.keys.any { |k| k.contains("FreeVerb") }, "log: keyed by the function's source");
assert.(Effect.narrowReport === Effect.narrowLog, "narrowReport answers the log");
Effect.clearNarrowLog;
assert.(Effect.narrowLog.isNil, "clearNarrowLog");
Effect.logNarrow = false;

h[\report].();
0.exit;
)
