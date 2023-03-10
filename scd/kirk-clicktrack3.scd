(SynthDef (\clk,{ Out.ar([0,1],Impulse.ar(0)) }).add;
Library.at(\functions,\clicktrack).value;
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
