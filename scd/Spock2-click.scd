Library.at(\functions,\clicktrack).value;
Library.postTree;

(
	~spock2=Dictionary.new;
	~spock2.put(\notes, List[
		\classM, [ Pseq([10,7,13,10,7,4.1]), Pseq([0.5],6)] , 
		\closeToEarth, [ Pseq([8.1,5.1,11.1,8.1,5.1,2.1]), Pseq([0.5],6) ],
		\withTwo, [Pseq([9.1, 6.1, 11, 9, 9.1, 6.1,11, 9.1, 11]), Pseq([0.5],3)++(Pseq([0.5,0.25,0.25],2))],
		\veryIm, [Pseq([11.1, 4.1, 4.1,4.1]), Pseq([0.5],4)]
	]);

	~spock2.put(\tempi,List[
		\classM , [[80,80],[2,1]],
	       \closeToEarth, 80,	
	       \withTwo,80,
	       \veryIm, [[70,60],[1,1]]
       ]);
~playBoth.(~spock2);
)

