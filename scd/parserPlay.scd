
(
// both separators and values can be more complex parsers as well
    ParserFactory.makeSepBy(Choice([StrParser(","), ParserFactory.makeWs]))
    .( Choice (ParserFactory.makeFloatParser, RegexParser("[a-z]")))    .run
     ( "45,-89.23 56.7,d 90.09" )

    .result.postcs;
)
(

var float = ParserFactory.makeFloatParser;

var degrees= ParserFactory.makeSepBy(
	Choice([
		StrParser(","),
		ParserFactory.makeWs
	])
).(float);

var phrase = SequenceOf([
	degrees, 
	RegexParser("\/[a-z]+") => Many( _ ) =>_.map({|i| i.collect{|j| j.drop(1).asSymbol}})
]);
var whole = ParserFactory.makeSepBy(ParserFactory.makeWs).(
	phrase.map({|i| i[0].perform(*i[1])})
).map({|i| i.flat});
whole.run("1 2 3 /dm/d/minor 4 5 6 /dm/f").result

)
