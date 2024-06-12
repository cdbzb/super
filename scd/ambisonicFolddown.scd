~decoder = FoaDecoderKernel.newSpherical;
~decoder = FoaDecoderKernel.newCIPIC;
~encoder = FoaEncoderMatrix.newOmni;
~encoder = FoaEncoderMatrix.newPanto(5,orientation: \flat);
(
{
	In.ar(0,5)[ [0, 4, 2, 3, 1] ]//[Monitors.speakerOrder]
	=> FoaEncode.ar(_, ~encoder)
	// => FoaTransform.ar(_, 'push', angle, azim)
	=> FoaDecode.ar(_, ~decoder)
	=> ReplaceOut.ar(0,_)
}.play
)
(out:4, pan:-1).play
Trek.load(5)
{
	Saw.ar(333, 0.1)
	=> Monitors.az(_, LFSaw.kr(0.1))
}.play
Trek


s.meter

Trek.playAll
Trek.prepare
Monitors.stopFoldDown
s.plotTree
[ out: Pwhite(0,4), pan:-1 ].p.play

