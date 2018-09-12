SynthDef (\clk,{ Out.ar([0,1],Impulse.ar(0)) }).add;
SynthDef (\mute,{Out.ar(0,0)}).add;

( //helper functions 
~concatRow={|array,row| var x; 
	array.do({|item index| x=x++array[index][row]});
	x;
};
~length={|a| var x=a[1].asStream; x.all.sum};
)

(
~someone=[ Pseq ([8,5,7,8,5,7,8]) ,	Pseq([3, 3, 2])/4++Pseq([3/4 , ((1/4)+(1/3)), 1/3, 1/3 ]) ]; 
~ceeded=[ Pseq([9.9,5,6.9,6]) , 	Pseq([2,2,1,1])/3 ]; //2
~ourDist=[ Pseq([\r,11,9,7,8,9,8]) ,	Pseq([1, 1, 0.5, 0.5, 0.5, 0.25, 0.25]) ]; //4
~activated=[ Pseq([6,6,6,6,5,5])-8 , 	Pseq([1, 2, 1, 2, 1, 1])/4 ]; //2
~activate2=[ Pseq([8,7,5,2.9,4,5,4]) , 	Pseq([1,1,1,1,1,1/2,1/2])/2 ]; // 3 
~given=[ Pseq([6,5,4,6,7,6,5,7]),		Pseq([1, 1, 1, 1, 1, 1, 1, 1])/2 ];
~follow=[ Pseq([8.1,6,\r,7,8.1,8.1,10,8.1,6]),	Pseq([3,1,2,2,6,2,2,1,1])/4];

~length.(~follow);
~kirk1=List[
	~someone,	[[84,75],[3,1]] , 
	~ceeded,	75,
	~ourDist,	90,
	~activated,	90,
	~activate2,	[[105,97],[2,1]],//120,
	~given,		90,
	~follow,	[[60,45],[4,1]]
];

~playme.(~kirk1);

)
(
~playme={ |playlist| //takes a playlist and plays tune and clicktrack
var tempi=playlist.copySeries(1,3);
var sections=playlist.copySeries(0,2);
~degrees=~concatRow.(sections,0);
~durs=~concatRow.(sections,1);
~lengths=sections.collect({|item,index| ~length.(item)});
~tempoMap={ var temp, dur; 
		tempi.do({|item index| 
			if(item.isNumber,
				{ temp = temp++item; dur=dur++~lengths.at(index);},
				{ temp= temp++item[0]; dur=dur++item[1]}
			);
		});
	Pstep(temp.flatten,dur.flatten);
}.value;

	t=TempoClock(s);
	Ppar([
		Pbind(	\instrument, \default,
			\degree, ~degrees-1,
			\dur, ~durs,
			\root,Pstep([0,-1, 0, 0, 0,0,0],[4,2, 4,2,3,40,6])
			//\tempo, 0.36
	),
		Pbind(	\instrument, \clk,
			\tempo, ~tempoMap/60,
			\dur, 1,
			\func, Pfunc({(t.tempo*60).postln})
			 )
		 ]).play(t)
}
)



///////////pseadocode

(

a=List[
	\someone,[ Pseq ([8,5,7,8,5,7,8]) ,	Pseq([3, 3, 2])/4++Pseq([3/4 , ((1/4)+(1/3)), 1/3, 1/3 ]) ] ,
	\ceeded,[ Pseq([9.9,5,6.9,6]) ,	 Pseq([2,2,1,1])/3 ] ,
	\ourDist,[ Pseq([\r,11,9,7,8,9,8]) ,	Pseq([1, 1, 0.5, 0.5, 0.5, 0.25, 0.25]) ] ,
	\activated,[ Pseq([6,6,6,6,5,5])-8 ,	 Pseq([1, 2, 1, 2, 1, 1])/4 ] ,
	\activate2,[ Pseq([8,7,5,2.9,4,5,4]) ,	 Pseq([1,1,1,1,1,1/2,1/2])/2 ]  ,
	\given,[ Pseq([6,5,4,6,7,6,5,7]),		Pseq([1, 1, 1, 1, 1, 1, 1, 1])/2 ],
	\follow,[ Pseq([8.1,6,\r,7,8.1,8.1,10,8.1,6]),	Pseq([3,1,2,2,6,2,2,1,1])/4]
];

m=MultiLevelIdentityDictionary.new;

a.pairsDo({|item data index|
	m.put(item,\degree,data[0]-1);
	m.put(item,\dur,data[1]);
});

~kirk1=List[
	\someone,	[[84,75],[3,1]] , 
	\ceeded,	75,
	\ourDist,	90,
	\activated,	90,
	\activate2,	[[105,97],[2,1]],//120,
	\given,		90,
	\follow,	[[60,45],[4,1]]
];
)
~playme.(~kirk1);
~length.(m[\ourDist,\dur]);
(
~length={|a| var x = a.asStream; x.all.sum};
~interpretTempo={|name item| var temp, dur;
			if(item.isNumber,
				{ temp = item/60; dur=~length.(m[name,\dur]);},
				{ temp= item[0]/60; dur=item[1]}
			);
	Pstep(temp,dur);
		};

~playme={|list| var degrees, durs,tempi; 
	t=TempoClock(s);
	list.pairsDo({|item data|
		m.put(item,\tempo,~interpretTempo.(item, data))
	});
	list.pairsDo({|section| 
		degrees=degrees++m[section,\degree];
		durs=durs++m[section,\dur];
		tempi=tempi++m[section,\tempo];
	});
	postln("tempo "+ tempi);
Pbind(	\instrument, \default,
	\degree, degrees,
	//\dur,0.2,
	\dur, durs,
	\tempo, tempi,
	\func, Pfunc({(t.tempo*60).postln})
).play(t)
};
)



 
