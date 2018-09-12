(SynthDef (\clk,{ Out.ar([0,1],Impulse.ar(0)) }).add;
~kirk1=Dictionary.new;
~kirk1.put(\notes,List[
	\someone,[ Pseq ([8,5,7,8,5,7,8]) ,	Pseq([3, 3, 2])/4++Pseq([3/4 , ((1/4)+(1/3)), 1/3, 1/3 ]) ] ,
	\ceeded,[ Pseq([9.9,4.9,6,5.9]) ,	 Pseq([2,2,1,1])/3 ] ,
	\ourDist,[ Pseq([\r,11,9,7,8,9,8]) ,	Pseq([1, 1, 0.5, 0.5, 0.5, 0.25, 0.25]) ] ,
	\activated,[ Pseq([6,6,6,6,5,5])-8 ,	 Pseq([1, 2, 1, 2, 1, 1])/4 ] ,
	\activate2,[ Pseq([8,7,5,2.9,4,5,4]) ,	 Pseq([1,1,1,1,1,1/2,1/2])/2 ]  ,
	\given,[ Pseq([6,5,4,6,7,6,5,7]),		Pseq([1, 1, 1, 1, 1, 1, 1, 1])/2 ],
	\follow,[ Pseq([8.1,6,\r,7,8.1,8.1,10,8.1,6]),	Pseq([3,1,2,2,6,2,2,1,1])/4]
]);

~kirk1.put(\tempi,List[
	\someone,	[[84,75],[3,1]] , 
	\ceeded,	75,
	\ourDist,	90,
	\activated,	90,
	\activate2,	[[105,97],[2,1]],//120,
	\given,		90,
	\follow,	[[60,45],[4,1]]
]);


~playBoth.(~kirk1);
)
( //here first
m=MultiLevelIdentityDictionary.new;
~playBoth={|dict| ~parseNotes.(dict[\notes]);~playme.(dict[\tempi]);};
~parseNotes={|list| 
	list.pairsDo({|item data index|
	m.put(item,\degree,data[0]-1);
	m.put(item,\dur,data[1]);
})};
~length={|a| var x = a.asStream; x.all.sum};
~interpretTempo={|list| var temp, dur;
		list.pairsDo({ |name item|
			if(item.isNumber,
				{ m.put(name,\tempo,\temp,item/60); m.put(name,\tempo,\dur,~length.(m[name,\dur])); postln({item/60})},
				{ m.put(name,\tempo,\temp,item[0]/60); m.put(name,\tempo,\dur,item[1])}
			) })};
~playme={|list| var degrees, durs,temp,dur, tempo; 
	t=TempoClock(s);
	~interpretTempo.(list);
	list.pairsDo({|section| 
		degrees=degrees++m[section,\degree];
		durs=durs++m[section,\dur];
		temp=temp++m[section,\tempo,\temp];
		dur=dur++m[section,\tempo,\dur]
	});
	tempo=Pstep(temp.flatten,dur.flatten);
	Ppar([
Pbind(	\instrument, \default,
	\degree, degrees,
	\dur, durs,
	//\tempo, tempo,
	\func, Pfunc({(t.tempo*60).postln})),
Pbind(	\instrument, \clk,
	\dur, 1,
	\tempo, tempo	)
	]).play(t)
};
)
