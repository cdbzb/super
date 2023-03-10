(
	a=NodeProxy.audio(s,2);
	a.source={Saw.ar([400,440,450,700]+LFNoise2.kr(1,200),0.05)!2};
	a.play;
	a[1]=\filter->{|in| PlateReverb.ar(in)}
	a[2]=\filter->{|in| Phaser2.ar(in,0.5,0.01)!2};
)
