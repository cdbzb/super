
~freqs={Array.fill(3,{rrand(300,4000)})};

//execute each of these a bunch

a={Klank.ar( ``[[~freqs.(),~freqs.()],[0.5,0.3,0.1],[0.1,0.1,0.1]],	Impulse.ar(2.0.rand, 0, 0.1) )}.play;
a={Klank.ar( ``[~freqs.(),[0.5,0.3,0.1],[0.5,0.4,0.3]],	Impulse.ar(2.0.rand, 0, 0.1) )}.play;
a={Klank.ar( ``[~freqs.(),[0.5,0.3,0.1],[0.5,0.4,0.3]], Dust.ar(1, 0.1) )}.play;
a={Klank.ar( ``[~freqs.(),[0.5,0.3,0.1],[0.5,0.4,0.3]], PinkNoise.ar(0.02, 0.07) )}.play;

a.release;


