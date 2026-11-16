// AmpSim channels: the output follows the signal (mono in, mono out on channel
// 0; k model channels, k out). pan: is only a mono-to-stereo Pan2 convenience;
// on more than one channel it warns and is ignored (other placement: post:).
//
// Pure language: AmpSim.place inside SynthDef graphs (built, never sent) and
// AmpSim.fx's printed source (an FxBus is lazy — nothing starts).
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/ampsim-channels-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var width = { |k, pan, n|
	// output channel count of a graph placing k model channels
	SynthDef(\zzzAmpPlace, {
		var sig = (k == 1).if { SinOsc.ar } { SinOsc.ar(Array.series(k, 100, 50)) };
		Out.ar(0, AmpSim.place(sig, pan.value))   // pan: a value, or a Function built in the graph
	}).asSynthDesc.outputData[0][\numChannels]
};
var uses = { |k, pan, n, cls|
	SynthDef(\zzzAmpPlace, {
		var sig = (k == 1).if { SinOsc.ar } { SinOsc.ar(Array.series(k, 100, 50)) };
		Out.ar(0, AmpSim.place(sig, pan.value))   // pan: a value, or a Function built in the graph
	}).children.any(_.isKindOf(cls))
};

"== AmpSim channel tests ==".postln;

// ------------------------------------------------------------ nothing asked: as produced
assert.(width.(1, nil, nil) == 1, "mono model, no pan: mono (channel 0)");
assert.(width.(2, nil, nil) == 2, "two models: two channels");
assert.(width.(4, nil, nil) == 4, "four models: four channels");

// ------------------------------------------------------------ pan: mono only
assert.(width.(1, 0.3, nil) == 2 and: { uses.(1, 0.3, nil, Pan2) }, "pan: on one model -> Pan2, 2 channels");
assert.(width.(1, 0, nil) == 2, "pan: 0 -> still Pan2 (centre)");
assert.(width.(2, -0.5, nil) == 2 and: { uses.(2, -0.5, nil, Pan2).not and: { uses.(2, -0.5, nil, Balance2).not } },
	"pan: on two models -> ignored, two channels as produced");
assert.(width.(3, 0, nil) == 3, "pan: on three models -> ignored, three channels");
assert.(width.(1, { SinOsc.kr(0.1) }, nil) == 2, "a UGen pan works");

// ------------------------------------------------------------ AmpSim.fx carries the new keys
assert.(AmpSim.fx("JoyoExtremeMetal", inputChannels: 1).source == "AmpSim.fx(\"JoyoExtremeMetal\")",
	"fx: inputChannels defaults to 1 (mono), left out of the source");
assert.(AmpSim.fx("JoyoExtremeMetal", inputChannels: 2).source.contains("inputChannels: 2"),
	"fx: a stereo input is spelled out");
assert.(AmpSim.fx("JoyoExtremeMetal", pan: 0.3).source == "AmpSim.fx(\"JoyoExtremeMetal\", pan: 0.3)",
	"fx: pan is part of its identity");

// ------------------------------------------------------------ the Ndef form matches
// (its graph function inside a plain SynthDef + Out, as Ndef wraps it; input nil reads \in)
assert.(SynthDef(\zzzAmpNdef, { Out.ar(0, AmpSim.prNdefFunc(\zzzAmp).value) }).asSynthDesc.outputData[0][\numChannels] == 1,
	"Ndef form: mono by default");
assert.(SynthDef(\zzzAmpNdef, { Out.ar(0, AmpSim.prNdefFunc(\zzzAmp, nil, 2).value) }).asSynthDesc.outputData[0][\numChannels] == 2,
	"Ndef form: inputChannels: 2 -> two models, stereo");
assert.(SynthDef(\zzzAmpNdef, { Out.ar(0, AmpSim.prNdefFunc(\zzzAmp, pan: 0.2).value) }).asSynthDesc.outputData[0][\numChannels] == 2,
	"Ndef form: pan: -> 2 channels");
assert.(SynthDef(\zzzAmpNdef, { Out.ar(0, AmpSim.prNdefFunc(\zzzAmp, nil, 2, pan: 0.2).value) }).asSynthDesc.outputData[0][\numChannels] == 2,
	"Ndef form: pan: on two models -> ignored, still 2");

h[\report].();
0.exit;
)
