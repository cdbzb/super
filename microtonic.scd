(

[
	instrument:\Tonic,
	noiseatt:0,
	freq: [50,150].q(inf),
	xfade: [0,1,1].q(inf),

	xfade: [ 0, Prand( [ [1].q,[0.5].q(2) ],inf ) ].q(inf),
	noiseatt:Pwrand([0,0.05,0.1],[9,1,1]/11,inf),
	ffreq:500,
	dur: Pwrand([1,2,4]/8,[2,2,2]/6,inf),
	dur: 0.2,
].pp
)
