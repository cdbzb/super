// AmpSim channels: the output follows the signal (mono in, mono out on channel
// 0; k model channels, k out) and is spread only when asked — pan: / numChannels:
// place it on 2 outputs (Pan2 / Balance2 / Splay) or n > 2 (PanAz / SplayAz).
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
		Out.ar(0, AmpSim.place(sig, pan.value, n))   // pan: a value, or a Function built in the graph
	}).asSynthDesc.outputData[0][\numChannels]
};
var uses = { |k, pan, n, cls|
	SynthDef(\zzzAmpPlace, {
		var sig = (k == 1).if { SinOsc.ar } { SinOsc.ar(Array.series(k, 100, 50)) };
		Out.ar(0, AmpSim.place(sig, pan.value, n))   // pan: a value, or a Function built in the graph
	}).children.any(_.isKindOf(cls))
};

"== AmpSim channel tests ==".postln;

// ------------------------------------------------------------ nothing asked: as produced
assert.(width.(1, nil, nil) == 1, "mono model, no pan: mono (channel 0)");
assert.(width.(2, nil, nil) == 2, "two models: two channels");
assert.(width.(4, nil, nil) == 4, "four models: four channels");

// ------------------------------------------------------------ 2 outputs
assert.(width.(1, 0.3, nil) == 2 and: { uses.(1, 0.3, nil, Pan2) }, "pan: on one model -> Pan2, 2 channels");
assert.(width.(2, -0.5, nil) == 2 and: { uses.(2, -0.5, nil, Balance2) }, "pan: on two models -> Balance2");
assert.(width.(3, 0, nil) == 2, "pan: on three models -> Splay to 2");
assert.(width.(1, nil, 2) == 2 and: { uses.(1, nil, 2, Pan2) }, "numChannels: 2 alone -> Pan2 at 0");

// ------------------------------------------------------------ beyond 2
assert.(width.(1, 0.4, 5) == 5 and: { uses.(1, 0.4, 5, PanAz) }, "one model on 5 outputs -> PanAz");
assert.(width.(1, nil, 8) == 8, "numChannels: 8 alone -> 8 channels");
assert.(width.(3, 0.2, 4) == 4, "three models on 4 outputs -> SplayAz");
assert.(width.(2, 0, 6) == 6, "two models on 6 outputs");

// ------------------------------------------------------------ down to 1
assert.(width.(1, 0, 1) == 1, "one model on 1 output: itself");
assert.(width.(3, nil, 1) == 1, "three models on 1 output: summed");

// ------------------------------------------------------------ UGen pan
assert.(width.(1, { SinOsc.kr(0.1) }, 5) == 5, "a UGen pan works");

// ------------------------------------------------------------ AmpSim.fx carries the new keys
assert.(AmpSim.fx("JoyoExtremeMetal", inputChannels: 1).source == "AmpSim.fx(\"JoyoExtremeMetal\")",
	"fx: inputChannels defaults to 1 (mono), left out of the source");
assert.(AmpSim.fx("JoyoExtremeMetal", inputChannels: 2).source.contains("inputChannels: 2"),
	"fx: a stereo input is spelled out");
assert.(AmpSim.fx("JoyoExtremeMetal", pan: 0.3, numChannels: 5).source.contains("pan: 0.3, numChannels: 5"),
	"fx: pan / numChannels are part of its identity");

// ------------------------------------------------------------ the Ndef form matches
// (its graph function inside a plain SynthDef + Out, as Ndef wraps it; input nil reads \in)
assert.(SynthDef(\zzzAmpNdef, { Out.ar(0, AmpSim.prNdefFunc(\zzzAmp).value) }).asSynthDesc.outputData[0][\numChannels] == 1,
	"Ndef form: mono by default");
assert.(SynthDef(\zzzAmpNdef, { Out.ar(0, AmpSim.prNdefFunc(\zzzAmp, nil, 2).value) }).asSynthDesc.outputData[0][\numChannels] == 2,
	"Ndef form: inputChannels: 2 -> two models, stereo");
assert.(SynthDef(\zzzAmpNdef, { Out.ar(0, AmpSim.prNdefFunc(\zzzAmp, pan: 0.2).value) }).asSynthDesc.outputData[0][\numChannels] == 2,
	"Ndef form: pan: -> 2 channels");
assert.(SynthDef(\zzzAmpNdef, { Out.ar(0, AmpSim.prNdefFunc(\zzzAmp, numChannels: 5).value) }).asSynthDesc.outputData[0][\numChannels] == 5,
	"Ndef form: numChannels: 5 -> PanAz to 5");

h[\report].();
0.exit;
)
