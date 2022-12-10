(
"/Users/michael/tank/super/More-Organized-Trek/Songs/briefing-room.scd".load;
a=RecIn(\test679,\engineering,0, fftSize:4096,hop:0.25,window:1)
)
a=RecOnsets(\test, \engineering)
a.armed_(true).record
a.armed_(false)
{ [1,1,3,3,3,4,4,4,2].df.dq.demand(a.list) => SinOsc.ar(_,0,0.1) * EnvGen.ar(Env.perc,a.playback)}.play
{ a.play => Decay.ar(_,0.2) * WhiteNoise.ar(mul:1.0)}.play
