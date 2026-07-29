// AudioItem.prPinLine — pinning a measured latency into startup.scd must leave
// the file PARSEABLE.
//
// The bug: a startup.scd that is one `( var ...; ... )` block is sclang's
// whole-program form (the cmdlinecode grammar), so NOTHING may follow the
// closing paren — not a statement, not even a `;`. prPinLine appended
// `AudioItem.roundTripLatency = ...;` after it, which made the whole file
//   ERROR: syntax error, unexpected CLASSNAME, expecting end of file
// and sclang then ran none of the startup file at all. The fix puts the pin
// inside the block. Pure language, no server.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/audioitem-latency-pin-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var pin = { |text, name = "roundTripLatency", value = 0.1|
	AudioItem.prPinLine(text.split(Char.nl), name, value, "260729_120000").join(Char.nl)
};
var parses = { |text| text.compile.notNil };
var occurrences = { |text, needle|
	text.split(Char.nl).count { |l| l.contains(needle) }
};
var block = "(\nvar files = 1;\no = files;\n)";
var flat = "Server.local.options.numOutputBusChannels = 8;\n";
var out, real, realPath;

"== AudioItem latency-pin tests ==".postln;

// -- 1. the grammar fact this whole fix turns on ---------------------------
assert.(parses.(block), "a `( var ...; ... )` block parses on its own");
assert.(parses.(block ++ "\nAudioItem.roundTripLatency = 0.1;").not,
	"appending a statement after that block does NOT parse");
assert.(parses.(block ++ ";").not,
	"and neither does a semicolon — it is a whole-program form, not an expression");

// -- 2. the pin goes inside the block --------------------------------------
out = pin.(block);
assert.(parses.(out), "pinned file parses");
assert.(out.contains("AudioItem.roundTripLatency = 0.1;"), "the pinned line is there");
assert.(out.split(Char.nl).last.stripWhiteSpace == ")",
	"the block's closing paren is still last — the pin went inside it");

// -- 3. a flat statement file still gets an appended line ------------------
out = pin.(flat);
assert.(parses.(out), "flat statement file parses after pinning");
assert.(out.split(Char.nl).reject { |l| l.stripWhiteSpace.isEmpty }.last
	.contains("AudioItem.roundTripLatency"),
	"on a flat file the pin is appended at the end");

// -- 4. idempotent, and it updates the value -------------------------------
out = pin.(pin.(block), value: 0.2);
assert.(parses.(out), "pinning twice still parses");
assert.(occurrences.(out, "AudioItem.roundTripLatency") == 1, "exactly one pin line");
assert.(out.contains("0.2"), "second pin wrote the new value");
assert.(out.contains("0.1;").not, "second pin dropped the old value");

// -- 5. an existing pin stranded OUTSIDE the block is moved inside ----------
// This is the real repair case: the file on disk already carries a pin that the
// old code appended after the `)`, so the file does not parse until it moves.
out = pin.(block ++ "\nAudioItem.roundTripLatency = 0.05; // loopback-measured old",
	value: 0.3);
assert.(parses.(out), "a stranded pin is relocated and the file parses again");
assert.(occurrences.(out, "AudioItem.roundTripLatency") == 1, "no duplicate left behind");
assert.(out.split(Char.nl).last.stripWhiteSpace == ")", "it now lives inside the block");

// -- 6. two different pins coexist -----------------------------------------
out = pin.(pin.(block), "outputLatency", 0.01);
assert.(parses.(out), "roundTripLatency and outputLatency together parse");
assert.(occurrences.(out, "AudioItem.roundTripLatency") == 1, "round trip pin kept");
assert.(occurrences.(out, "AudioItem.outputLatency") == 1, "output latency pin added");

// -- 7. degenerate inputs don't throw --------------------------------------
assert.(pin.("").contains("AudioItem.roundTripLatency"), "empty file just gets the line");
assert.(pin.("// only a comment\n").contains("AudioItem.roundTripLatency"),
	"comment-only file just gets the line");
assert.(parses.(pin.("(\nvar files = 1;\no = files;\n) // trailing note")),
	"a trailing inline comment after the paren does not break the detection");

// -- 8. end to end on the real startup.scd (read only, never written) ------
realPath = Platform.userConfigDir +/+ "startup.scd";
File.exists(realPath).if {
	real = File.readAllString(realPath);
	("  (real startup.scd parses as-is: " ++ parses.(real) ++ ")").postln;
	assert.(parses.(pin.(real, value: 0.098083333333333)),
		"the real startup.scd parses after pinning");
} {
	("  (no startup.scd at " ++ realPath ++ " — skipping the end-to-end check)").postln;
};

(h[\report].() == 0).if { 0.exit } { 1.exit };
)
