
//~freqs={Array.fill(3,{rrand(300,4000)})};
(
	~freqs={a=Array.exprand(3,300,4000)};
	~gains= {a.collect{|item index| (1-(item/8000))*rrand(0.5,1)}};
	~times= {a.collect{|item index| (1-(item/8000))*rrand(0.15,0.9)}};
)

//execute each of these a bunch

//b={Klank.ar( ``[[~freqs.(),~freqs.()],[0.5,0.3,0.1],[0.1,0.1,0.1]],	Impulse.ar(2.0.rand, 0, 0.1) )}.play;
b={Out.ar([0,1],Klank.ar( ``[~freqs.(),~gains.(),~times.()],	Impulse.ar(2.0.rand, 0, 0.1) ))}.play;
(
	b={Out.ar([0,1],Klank.ar( ``[~freqs.(),~gains.(),~times.()],	
	LPF.ar(Impulse.ar(2.0.rand, 0, 0.1),1500 )
))}.play;
)
b={Out.ar([0,1],Klank.ar( ``[~freqs.(),~gains.(),~times.()], Dust.ar(8, 0.5) ))}.play;
b={Klank.ar( ``[~freqs.(),~gains.(),~times.()], PinkNoise.ar(0.01, 0.007) )}.play;

a.release;

d={Klank.ar( `[~freqs.(),~gains.(),~times.()], PinkNoise.ar(0.01, 0.007) )};
e=NodeProxy.new;
f=d.();
e.source={Pan2.ar(d.(),-1)};
e.play;
e.fadeTime=5;

