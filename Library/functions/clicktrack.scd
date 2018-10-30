Library.put(\functions,\clicktrack,
	{
m=MultiLevelIdentityDictionary.new;
~playBoth={|dict| ~parseNotes.(dict[\notes]);~playme.(dict[\tempi]);};
~parseNotes={|list| 
	list.pairsDo({|item data index|
	m.put(item,\degree,data[0]-1);
	m.put(item,\dur,data[1]);
})};
~length={|a| var x = a.asStream; x.all.sum};
~interpretTempo={|list| var temp, dur;
		list.pairsDo({ |name item|
			if(item.isNumber,
				{ m.put(name,\tempo,\temp,item/60); m.put(name,\tempo,\dur,~length.(m[name,\dur])); postln({item/60})},
				{ m.put(name,\tempo,\temp,item[0]/60); m.put(name,\tempo,\dur,item[1])}
			) })};
~playme={|list| var degrees, durs,temp,dur, tempo; 
	t=TempoClock(s);
	~interpretTempo.(list);
	list.pairsDo({|section| 
		degrees=degrees++m[section,\degree];
		durs=durs++m[section,\dur];
		temp=temp++m[section,\tempo,\temp];
		dur=dur++m[section,\tempo,\dur]
	});
	tempo=Pstep(temp.flatten,dur.flatten);
	Ppar([
Pbind(	\instrument, \default,
	\degree, degrees,
	\dur, durs,
	//\tempo, tempo,
	\func, Pfunc({(t.tempo*60).postln})),
Pbind(	\instrument, \clk,
	\dur, 1,
	\tempo, tempo	)
	]).play(t)
}});

"Startup File Loaded".postln;

