(
~makeDurs= { |string|
	var dict= [$q,1,$x,1/4,$e,1/2,$h,2,$w,4,$Q,2/3,$E,1/3,$X,1/6]
	.collect({
		|i|(i.class==Char).if{
			i.ascii
		}{
			i
		}
	}) => Dictionary.newFrom(_);
	string.split(Char.space).ascii
	.collect(
		_.collect({|i| dict.at(i) ? 0})
	).collect(_.sum)
};
~makeDurs.("q| q| q|ex x|xe x|q q")
)
