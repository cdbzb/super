// Minimal test: trace VSTI/SV condition signaling
(
var path, sv, synthV;
path = "/private/tmp/" ++ UniqueID.next.asString.padLeft(13, "0");

// Build a minimal SynthV project to get an .fxp
synthV = SynthV.newVST(\ninezero2, \default, nil, nil, 2);
synthV.makeNotes(3);
synthV.setDatabase(\ninezero2);
synthV.set((
	lyrics: ["la", "la", "la"],
	pitch: [60, 62, 64],
	dur: [1, 1, 1]
));
synthV.writeProjectVST(path ++ ".svp");
synthV.writeFxp(path);

"--- Creating SV instance ---".postln;
sv = SV(path ++ ".fxp");

"--- SV created, condition: %".format(sv.condition).postln;

fork {
	"--- Waiting on condition... ---".postln;
	sv.condition.wait;
	"--- Condition signaled! controller: % ---".format(sv.controller).postln;
	"--- isOpen: % ---".format(sv.controller.isOpen).postln;
	"--- bus: % ---".format(sv.bus).postln;

	// Try to play
	sv.controller.setTransportPos(0);
	sv.controller.setPlaying(true);
	"--- Transport started ---".postln;

	3.wait;
	sv.controller.setPlaying(false);
	"--- Done ---".postln;
};
)
