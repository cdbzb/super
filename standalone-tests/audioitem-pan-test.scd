// \audioItem pan: channels follow the take (mono on out unless numChannels:);
// the event's OWN pan: is a mono-to-stereo Pan2 convenience; on more than one
// channel it warns and is ignored. Event's default parent carries pan: 0, so
// "not asked" must be read from the event's own keys (AudioItem.ownPan).
//
// Pure language: graphs built, never sent.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/audioitem-pan-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var width = { |k, pan|
	SynthDef(\zzzItemPan, {
		var sig = (k == 1).if { SinOsc.ar } { SinOsc.ar(Array.series(k, 100, 50)) };
		Out.ar(0, AudioItem.panned(sig, pan.value))
	}).asSynthDesc.outputData[0][\numChannels]
};
var defOut = { |name| SynthDescLib.global[name] !? { |d| d.outputData[0][\numChannels] } };
var parent = Event.default.parent;

"== AudioItem pan tests ==".postln;

// ------------------------------------------------------------ ownPan
assert.(AudioItem.ownPan((type: \audioItem, item: \x).parent_(parent)).isNil,
	"no pan: key -> nil, though the default parent answers 0");
assert.(AudioItem.ownPan((type: \audioItem, item: \x, pan: 0).parent_(parent)) == 0,
	"pan: 0 given -> 0 (centre is asked for)");
assert.(AudioItem.ownPan((type: \audioItem, pan: -0.5).copy) == -0.5, "survives copy");

// ------------------------------------------------------------ panned
assert.(width.(1, nil) == 1, "mono, no pan: mono (channel 0)");
assert.(width.(2, nil) == 2, "stereo take, no pan: as recorded");
assert.(width.(1, 0) == 2, "mono, pan: 0 -> Pan2 centre");
assert.(width.(1, 1) == 2, "mono, pan: 1 -> Pan2");
assert.(width.(1, { SinOsc.kr(0.2) }) == 2, "a UGen pan works");
assert.(width.(2, 0.5) == 2, "stereo take, pan: -> ignored (warns)");
assert.(width.(3, 0.5) == 3, "three channels, pan: -> ignored");

// ------------------------------------------------------------ slice SynthDefs
assert.(defOut.(\audioItemTempoFollowRB) == 2, "slices with pan: -> stereo def");
assert.(defOut.(\audioItemTempoFollowRBMono) == 1, "slices without pan: -> mono def");

h[\report].();
0.exit;
)
