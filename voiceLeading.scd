(
~lines=[
	[0,\_,3,5],
	[5, 6,7,8],
	[7, 6,\_,4.5],
	[1,\_,\_,9],
	//[1,\_,\_,\_],
	[12,\_,2,\_]
];
~durs=[1.2,1.3,1.4,2];

~dursArray={ |lines| 
	var indices=lines.collect{
		|line| line.collect{
			|i x| (i==\_).if{-1}{x}
		}.reject{|i| i == (-1)};
	};
	indices.collect { |a| 
		var padded=(a++(~lines[0].size));
		a.size.collect{
			|i| var delta=padded[i+1]-a[i]; 
			(delta>1).if{
				delta.collect{ |j| j+i }
			}{
				[a[i]]
			} 
		}.collect{|i x|i.sum({|i| ~durs[i] })}
	} 
};
~dursArray.(~lines)
)
//maybe like so....
//[type:\linePlayer,lines:~line,line:1]

(
[
	[freq:~lines[0].reject{|i|i==\_}.df('d').q,dur:~dursArray.(~lines)[0].q].pm('defaultPorto.clean'),
	[freq:~lines[2].reject{|i|i==\_}.df('d').q,dur:~dursArray.(~lines)[2].q].pm('defaultPorto'),
	[freq:~lines[1].reject{|i|i==\_}.df('d').q,dur:~dursArray.(~lines)[1].q].pm('defaultPorto.noisy1'),
	[freq:~lines[3].reject{|i|i==\_}.df('d').q,dur:~dursArray.(~lines)[3].q].pm('defaultPorto'),
	//[freq:~lines[4].reject{|i|i==\_}.df('d').q,dur:~dursArray.(~lines)[4].q].pm('defaultPorto.noisy1'),
]=>Ppar(_,6)	=>_.play
)
(
SynthDef(\defaultPorto,{
	var freq=\freq.kr(400,0.5)-5;

	Gendy4.ar(4,1,1,1,freq-19,freq+19,\ampScale.kr(0.1),\durScale.kr(0.1),Rand(11)+1)
	+ Saw.ar(freq,0.05)
	* Env.asr(0.2,1,3).kr(2,gate:\gate.kr(1))
	* 0.1
	=> BMoog.ar(_,1800,0.2,2.1)
	=>FreeVerb.ar(_,0.4,1)
	=> Out.ar(Rand(4),_)
},variants:(
	noisy1: [\ampScale,1.0,\durScale,1.5],
	clean: [\ampScale,0.5,\durScale,5.5]
 )).add

)
(
a=VoiceLeading([
	[1, 3 ,5  ,\r],
	[6, \_,6.5,\r],
	[\r, \r,\r,11],
],
[1,1.2,1.5,2]
	)	
a.df('d');
)
(
b=Monitor.new.play(2,2,0,2);
[freq:a.lines(0),dur:a.durs(0),instrument:'defaultPorto',out:1].pp;
[freq:a.lines(1),dur:a.durs(1),instrument:'defaultPorto.clean'].pp;
[freq:a.lines(2),dur:a.durs(2),out:1].pp;
)
a.lines(0)

a.makeDurationsArray
a.durs.at( 1 )
a.durs(1)
a.durs_([2,2,2])
//a better approach ?
//voice leading event type
//simply doesn't play if any key (or maybe just freq) is \_
(key:\_,dur:1,play:{currentEnvironment.values.includes(\_).postln}).play
// cool idea but no because, sadly, durs won't work for normal pbinds
