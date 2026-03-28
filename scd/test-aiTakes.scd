// Test AI takes: activeTakeId per note
// 0 = default rendering, 1+ = AI variation takes

// --- Build all variants ---
(
var params = (
	lyrics: "hello world how are you doing today friend",
	midinote: [60, 62, 64, 65, 67, 65, 64, 62],
	dur: [1, 1, 0.5, 0.5, 1, 1, 0.5, 0.5],
	lag: 0.15.dup(8),
);

// default (all notes take 0)
~default = SynthVVST(\xuan2, params: params);
~default.build;

// all notes use take 1
~take1 = SynthVVST(\xuan2, params: params.copy.put(\aiTakes, 1));
~take1.build;

// all notes use take 2
~take2 = SynthVVST(\xuan2, params: params.copy.put(\aiTakes, 2));
~take2.build;

// per-note: default for first 4, take 1 for last 4
~mixed = SynthVVST(\xuan2, params: params.copy.put(\aiTakes, [0,0,0,0,1,1,1,1]));
~mixed.build;

// short array with clipAt: take 0 for note 1, take 2 for notes 2-8
~short = SynthVVST(\xuan2, params: params.copy.put(\aiTakes, [0, 2]));
~short.build;
)

// --- A/B test ---
~default.play;
~take1.play;
~take2.play;
~mixed.play;
~take1.play;
~short.play;

// cleanup
SynthVVST.freeAll;
