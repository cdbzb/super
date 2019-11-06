~xtreme.lyrics[1]
~xtreme.durs[1].list.asArray.size
~quarters[1]=~xtreme.parse(1,[1,1],[1,0.5],[0.5,1,1,1]);

~test="a- li- en mind will make the --";
String

(////yaaay! now make into a method  in ~funs
	a=
	~test.split(Char.space)
	.collect{|i|i.asSymbol};
	a.collect{|i x| (i=='--').if{ a[x-1]++'--' }{i}};
	
	//.detectIndex{|i|i=="the"}
	
)
a[1]
~parseT.([\a,\en,[\mind,0.5],$])
$s
Char

~swing={|pair ratio| var offset = percent*pair[1];pair+[offset,offset*(-1)]   }

// for stretching more than a pair
////////////////////
// convert deltas to points
// move points
// convert back


