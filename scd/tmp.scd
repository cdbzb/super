
(
	Ppar[
)
(
		b=[
			type:\vsti,controller:~g.controller,
			degree:Pseq([5,[4,6,8],[3,5,8],[2,4],[2.1,4.1,6,8],[3,6,7],[3,5,7]]-1),
			octave:4,
			dur:Pseq(
				~three.parse(1,[[1,1,1,1,1],[1,1],1])
				++
				~three.parse(2,[[1,1,1],[1,1,1,1,1],1,1])
			),
			legato:0.96,
			'Play Mode: Play Mode':0.6,
			lag:0.18
		].p;

		v=[
			type:\vsti,controller:~g.controller,
			lag:0.17,
			degree:Pseq([7,8])-1,
			octave:4,
			legato:0.97,
			dur:Pseq(
				~three.parse(2,[1,[1,1,1,1]])
			),
		].p;

		a=[
			type:\strum,controller:~g.controller,
			dur:
			Pseq(
				~three.parse(1,[1,1,[1,1],1,[1,1],1])
				++ 
				~three.parse(2,[1,1,1,[1,1,1,1,1],1,1])
			)
			,
			//dur:~three.durs[1],
			switch:Pseq([\down,\up,\down],2)
			++
			Pseq([\up,\four,\three,\down])
			++
			Pseq([\down,\five])
			,
			amp:Pseq([0.2,0.01,0.2],2)
			++
			Pseq([0.2,0.1,0.1,0.2],1)
			++
			Pseq([0.2,0.1])
			,
			lag:0.2
		].p;
		//~g.node[1]=nil;

Ptpar([0.2,a,0.2,b,0.2+~three.durs[1].list.sum,v,
0.2,Pseq(~three.pbind[1..2])
]).play
)
(

)
