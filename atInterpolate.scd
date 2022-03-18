(
a=[1, 1.4, 1.3, 1.2, 2.24, 1.15, 1];

~atInterpolate = {|array index| 
	array.integrate.at(index.floor-1) + 
	((index-index.floor) * (array[index.floor])) 
};
~atInterpolate2 = {|array rhythm|
	 rhythm.integrate.collect{|i| ~atInterpolate.(array,i)}.differentiate
	};
b=~atInterpolate2.(a,[1,2.5,0.5,0.5,0.5,0.25,0.25,0.25,0.25]);
[dur:a.q,freq:300].pp;
[dur:b.q].pp

)

