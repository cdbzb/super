(
~points = [[ 1,1 ],[ 2,2 ],[ 3,6 ]];

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

~makeCurve.(~points).eval(0)

)

(
~durs = [0.6,0.93,1,0.5] ;
~beats = [0.5,1,1,0.5];
~points = [~beats,~durs].collect{|i| [0] ++ i => _.integrate => _.drop(1)}.flop;
~beats2 = ( 0.25!16 ) => _.integrate;
~beats2 =  "e e x x e x x e".asBeats => _.integrate;
p = ~points.collect( { |i| ~makeCurve.(~points).eval(i[0]) } ).differentiate;
b = ~beats2.collect( { |i| ~makeCurve.(~points).eval(i) } ).differentiate
)
(
[dur: p.q].pp;
[dur: b.q, freq: 555].pp
)

(
~makeCurve2 = { | beats durs | // returns a Polynomial - call .eval to evaluate
	var points = [beats,durs].collect{|i| [0] ++ i => _.integrate => _.drop(1)}.flop;
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
~evalCurve = {| beats polynomial |
	beats = beats.integrate;
	beats.collect{|i| polynomial.eval(i)}.differentiate;
}
)
(
m = TempoMap([1,1,1,1.1],[1,1.1,1.2,1]);
m.mapBeats([1,1,1])
)
