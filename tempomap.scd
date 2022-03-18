a=Order.newFromIndices([100,200],[5,10])
a.at(1.5)
TempoMap.newFromIndices([70,80],[3])
(
~test = {|points bars| 
	var beats =
	points.differentiate
	.collect{|i x|
		i/bars[x] ! bars[x]
	}.flat.integrate;
	var tempi = 
	beats.differentiate;
	( tempi:tempi,beats:[0]++beats )
}
)
~test.([3,15,20],[1,5,4])
[1,2,4,7][1..].collect(|)
[1,3,4,7].differentiate[1..]
