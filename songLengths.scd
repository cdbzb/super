(
var names = [
	\visual,
	\rescue,
	\transporter,
	\chamber1,
	\panel1,
	\panel2,
	\smallChamber,
	\chamber,
	\briefing,
	\theyUsed,
	\song,
	'this formnula',
	\three,
	\silverLake,
	\chapelForgets,
	\thousand,
	\sickBay,
	\medical,
	\laboratory,
	'MandT',
	\ending
];
var lengths = names.collect({ |i |  Object.readArchive(  Song.dursFolder +/+ i ) 
.values.collect( { |i| i.list} )
}).collect{|i| i.flat.reject{|i| i.isNil}.sum.asInteger};

"Long".postln;
lengths.do({|i x| ( i.sum > 240 ).if{names[x].asString + i => _.postln} });
"Short".postln;
lengths.do({|i x| ( i.sum <= 240 ).if{names[x].asString + i => _.postln} })
)

Object.readArchive(Song.dursFolder+/+\theyUsed).values.collect( { |i| i.list} ).collect{|i| i.flat.reject{|i| i.isNil}.sum.asInteger}.sum

Song.durs[\Forgive].list
a=Song.durs
Song.hasDursButNotLyricsToDurs
