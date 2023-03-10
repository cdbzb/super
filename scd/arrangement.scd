EnvGen

[[ [1,3,5,11],[1,4,6,11],[2,5,7,15] ].flop,[\violin,\viola,\cello,\bass]].flop.do({|i | i[0].post;" ".post;i[1].postln})

y=~synful3.()
y.shuffle
(
a=(
	lines:[ 
		[[21, 11 ],     12, 11, [7,13,15,17],\_,\_],
		(-1)*[5,      \_, 3,  2,3 ,1],
		(-1)*[1, 4,  3,  5,\_,\_]
	], 
	durs:[1 ,1 ,1, 1,1,1],
	patches:[\violas, \clarinet,\basses]
)
=>{|i|
	a = VoiceLeading(i.lines,i.durs).df();
	a.lines.collect({|j x| 
		y.patch(i.patches[x],\arco,x);
		a[x]
		++[type:\vst_midi,vst:y.controller,chan:x]
		++[legato:0.99,amp:0.8]
		=>_.p})
		=> Ppar(_,2) =>_.play
	};
	y.setOut(Effect({|i| FreeVerb.ar(i,0.7,0.7) => {|i|[i/8,BitCrusher.ar(i,32,40000)]}=>Mix.ar(_)=>MoogVCF2.ar(_,SinOsc.ar(0.2).range(600,3000),0.5) },inputChannels:2).bus.index)
)
