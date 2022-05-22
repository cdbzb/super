(
~points = [[ 1,1 ],[ 2,2 ],[ 3,6 ],[0.001,0.001]];

~makeCurve = { | points |
	var binomials = points.collect{|i| Polynomial.newFrom([ i[0]*(-1), 1 ])};
	var expandTheOthers = {|element| binomials.reject{|i| i == element}};
	var polynomials = points.size.collect { |i|
		Polynomial.expandBinomialFactors( expandTheOthers.(binomials[i]))
	};
	var coefficients = polynomials.collect{|i x| 
		i.eval(points[x][0])/points[x][1] => _.reciprocal
	};
	polynomials * coefficients => _.sum 
};

~makeCurve.(~points).eval(3)

)

(
~durs = [0.6,0.83,1,0.5] => _.integrate + [1,2,3,4];
~beats = [0.5,1,1,0.5] => _.integrate;

~points = ~durs.collect{|i x| [~beats[x], i]};
~makeCurve.(~points).eval(1);
~beats.collect(~makeCurve.(~points).eval(_)).differentiate - 1
)
