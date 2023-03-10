
(~sections.do({|item index|
	~a.add({item.at(\a)}.value);
});
~a.asArray;
)


(

	~someone= [  [8,5,7,8,5,7,8] ,	[3, 3, 2]/4++[3/4 , ((1/4)+(1/3)), 1/3, 1/3 ] ]; 
	~ceeded=[ [9.9,5,6.9,6] ,	 [2,2,1,1]/3 ]; //2
	~ourDist=[[\r,11,9,7,8,9,8] ,	[1, 1, 0.5, 0.5, 0.5, 0.25, 0.25] ]; //4
	~activated=[ [6,6,6,6,5,5]-8 ,	 [1, 2, 1, 2, 1, 1]/4 ]; //2
	~activate2=[ [8,7,5,2.9,4,5,4] ,[1,1,1,1,1,1/2,1/2]/2 ]; // 3 
	~given=[ [6,5,4,6,7,6,5,7],	[1, 1, 1, 1, 1, 1, 1, 1]/2 ];
	~follow=[ [8.1,6,\r,7,8.1,8.1,10,8.1,6],[3,1,2,2,6,2,2,1,1]/4];
)

~someone.asName;


~toDict={ |input| Dictionary.newFrom([\degree, input[0], \dur,input[1]],\tempo,nil)};
~someone=~toDict.(~someone);
Dictionary
(
~kirk1=List[
	~someone,	[[84,75],[3,1]] , 
	~ceeded,	75,
	~ourDist,	90,
	~activated,	90,
	~activate2,	[[105,97],[2,1]],//120,
	~given,		90,
	~follow,	[[60,45],[4,1]]
];
)


Library
(
~kirk1.pairsDo({ |dict tempo index| 
	//dict=~toDict.(dict);
	//dict.add(\tempo -> tempo );
	dict.postln; });
)

~someone[\tempo];
~someone;

//~tempoMap={ var temp, dur; 
//		tempi.do({|item index| 
//		ss	if(item.isNumber,
//				{ temp = temp++item; dur=dur++~lengths.at(index);},
//				{ temp= temp++item[0]; dur=dur++item[1]}
//			);
//		});
//	Pstep(temp.flatten,dur.flatten);
//}.value;
~length={| array| array.sum;}
~tempoMap={|dict| Pstep(   )dict.at}

(
Pbind(	\instrument, \default,
	\dur,Pseq(~someone[\dur]),
	\degree,Pseq(~someone[\degree])).play
)

m=MultiLevelIdentityDictionary.new;
m.put(\kirk,\freq,[1,2,3];)
m.put(\kirk,\dur,[3,4,5];);
m.at(\kirk,\dur);

