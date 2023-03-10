
(//setup
b = Buffer.read(s, "/Users/michael/tank/super/samples/La_Mer_clean.aif");
z = Item("keep this body");
)
z.buffer.play
z.buffer.bufnum
z.play
Synth(\vocoder16bands,[\carrier,z.buffer.bufnum,\modulator,b.bufnum,\freq,100,])
Synth(\vocoder16bands,[\modulator,z.buffer.bufnum,\carrier,b.bufnum,\freq,100,\release,10])
Synth(\soundInMorphNoise,[\modulator,z.buffer.bufnum,\carrier,b.bufnum,\freq,100,\release,10])
Synth(\soundInMorph,[\modulator,z.buffer.bufnum,\carrier,b.bufnum,\freq,100,\release,10])



