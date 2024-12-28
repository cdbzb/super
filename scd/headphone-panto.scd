Quarks.install("https://github.com/SimonDeplat/Graphical-Module")
(
~encoder = FoaDecoderKernel.newListen(1004);
~encoder = FoaDecoderKernel.newCIPIC(48);

fork{
	0.5.wait;
	SynthDef(\encode, {
		// In.ar(0, 5)[0, 4, 1, 3, 2] 
		[In.ar(0, 1), In.ar(2, 1), In.ar(4, 1), In.ar(3, 1), In.ar(1, 1)]
		=> FoaEncode.ar(_, FoaEncoderMatrix.newPanto(5, \flat))
		// => FoaRotate.ar(_, LFSaw.ar(0.05).range(0, 2pi))
		=> FoaDecode.ar(_, ~encoder)
		=> Out.ar(0, _)
	}).add;
	0.5.wait;
	Synth(\encode, addAction:\addToTail);
	0.5.wait;
	// Monitors.stopFoldDown
	// [out: (0..4).q(inf),freq: (1..5).df(\c).q(inf), dur: 0.6, pan:-1].pp
	// [out: [1, 3].q(inf),freq: (1..5).df(\c).q(inf), dur: 0.6, pan:-1].pp
}
)
Trek.load(1)
(out:4).play
Song.play
(out:0, pan: -1).play
[ out:[ 4, 1 ].q(inf), pan: -1 ].p.play
s.meter
(out:2, pan: -1).play
(out:1).play
s.plotTree

a = Synth(\vsti, )
SynthDef(\monitorFX, {
	In.ar(0, 5)
	=> VSTPlugin.ar(_, 2)
	=>Out.ar(0, _)
}).add
(
a = Synth(\monitorFX, addAction:\addToTail);
b= VSTPluginController(a);
b.open("Virtuoso.vst3");
	// [out: (0..4).q(inf),freq: (1..5).df(\c).q(inf), dur: 0.6, pan:-1].pp
)
b.gui
b.editor
s.plotTree
b.editor
