// Test: do AI take seeds in the SVP affect VST rendering?
// Build two SynthVVSTs with identical params, one with aiTakes enabled.
// A/B them to hear if the seeds change the output.

(
var params = (
	lyrics: "hello world how are you doing today friend",
	midinote: [60, 62, 64, 65, 67, 65, 64, 62],
	dur: [1, 1, 0.5, 0.5, 1, 1, 0.5, 0.5],
	lag: 0.15.dup(8),
);

~noAI = SynthVVST(\xuan2, params: params);
~noAI.build;

~withAI = SynthVVST(\xuan2, params: params.copy.put(\aiTakes, 99999));
~withAI.build;
)

// play without AI takes (default, activeTakeId: 0)
~noAI.play;

// play with AI takes (activeTakeId: 1, random seeds from seed 99999)
~withAI.play;

// if they sound different, the seeds work!
// if identical, the VST ignores pre-written seeds and we'd need to trigger generation via the controller.

// cleanup
SynthVVST.freeAll;
