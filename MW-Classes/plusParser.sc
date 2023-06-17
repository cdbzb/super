Parsers : ParserFactory{
	*degrees { 
		^ParserFactory.makeSepBy(
			Choice([
				StrParser(","),
				ParserFactory.makeWs
			])
		).(ParserFactory.makeFloatParser); 
	}

	*floatArray {
		^SequenceOf( List[
			StrParser("[") ,
			Parsers.degrees,
			StrParser("]") ,
		]).map(_[1]);
	}
	*numOrArray {
		^Choice(
			List[
				ParserFactory.makeFloatParser,
				Parsers.floatArray
			]
		)
	}
}

+String {
	prs{|parser|
		^Parsers.perform(parser).run(this).result
	}
}

/*
Parsers.numOrArray.run("[2,3]").result;
numOrArray.run("2").result 
"[2,3]".prs(\numOrArray)
Parsers.makeFloatParser.run("3.4").result
*/

