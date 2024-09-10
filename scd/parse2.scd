(
var degrees= ParserFactory.makeSepBy(
	Choice([
		StrParser(","),
		ParserFactory.makeWs
	])
).(ParserFactory.makeFloatParser);

var floatArray = SequenceOf( List[
	StrParser("[") ,
	degrees,
	StrParser("]") ,
]).map(_[1]);

var numOrArray = Choice( List[
	ParserFactory.makeFloatParser,
	floatArray
	]
);
numOrArray.run("[2,3]").result;
numOrArray.run("2").result

)

