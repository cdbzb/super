Parsers : ParserFactory{
	*degrees { 
		^ParserFactory.makeSepBy(
			Choice([
				StrParser(","),
				ParserFactory.makeWsOne
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
	prs {|parser|
		^Parsers.perform(parser).run(this).result
	}
	dm2 {
		^Parsers.makeSepBy(Parsers.makeWsOne).(
			SequenceOf([
				Parsers.degrees,
				Many( // /foo/3/a
					SequenceOf([ // /foo
						StrParser("/"),
						Choice([
							Parsers.numOrArray.map({ |i| \octave -> i }),
							RegexParser("[a-zA-Z\#\-]+").map({ |i|
								(i.size > 3).if{
									\scale -> i.asSymbol
								}{

									\root -> i.asSymbol
								}
							}),
						])
					]).map{|i| i[1] } //strip '/'
				)
			]).map{|i| i[0].performWithEnvir( \dm, i[1].asEvent  )}
		).map({|i| i.flatten})
		.run( this )
		.result;
	}
	beats {
		var noteNameParser = RegexParser("[exqEXQhHwWtTg]") => Many(_) => _.map({|i| i.collect({|j| j.asString.asBeats}).flat.sum});
		var multipleNote = SequenceOf([ noteNameParser, StrParser("\*"), Parsers.makeIntegerParser ]).map({|i| i[0].dup( i[2] )});
		var notesOrMultiples = Choice([ multipleNote, noteNameParser, ]);
		^Parsers.makeSepBy(
			Parsers.makeWsOne
		).( notesOrMultiples ).map{|i| i.flat}
		.run(this)
		.result
	}
}

/*
Parsers.numOrArray.run("[2,3]").result;
numOrArray.run("2").result 
"[2,3]".prs(\numOrArray)
Parsers.makeFloatParser.run("3.4").result
*/

