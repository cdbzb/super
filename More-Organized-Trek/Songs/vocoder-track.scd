
VocalRPP(\depart,\newTest).recordSection(Song.carrierBus.index)


(
//Synth('cepstral-vocoder-bus',[\carrier,16,\modulator,17,\amp,0.3,\ffrsize,1024*32]);
Synth('soundInMorphNoise',[\out,4,\carrier,16,\modulator,17,\amp,0.3]);
Synth('vocoder32bands-bus',[\carrier,16,\modulator,17,\amp,0.1,\out,4]);
Reaper.stop; Reaper.go(0); Reaper.play
)

a=VocalRPP(\depart,\newTest)
a.buffer.play
Song.sargonModulator.(\voxDepart,dur:3);
Song.voxDepart
s.options.dump
().play
