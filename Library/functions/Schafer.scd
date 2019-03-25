~makeNodes={ |channels=2 |
	var d=();
	var dry = NodeProxy(s,\audio,channels);
	var wet = NodeProxy(s,\audio,channels);
	wet.source=dry;
	d.add(\wet->wet);
	d.add(\dry->dry);
};
~setIR={|dict buffer gain=1|
	dict.wet.source = {PartConv.ar(dict.dry,4096,buffer)*gain}
};
~bypass={|dict|
	dict.wet.source=dict.dry};
	
~names={|collection| collection.collect({|item index| PathName.new(item.path).fileName}) };

if(~numberBuffers==nil,{~numberBuffers=Array.newClear(8)});

~makeNumberBuffers={|lang=\en|
	var voices=Say.findVoice(lang: lang);
	    8.do { |index|
		        SayBuf.prepare((voice: voices, lang: \en, text:index.asString,
			bufAction: { |b| ~numberBuffers[index]=b };
		    ));
	};
};

~playNumbers={ |wait=0.1|
	Routine.new({
	       8.do { |x|
			{PlayBuf.ar(1,~numberBuffers[x], rate:0.5 )}.play(s,~speakers[x]);
			(~numberBuffers[x].numFrames/44000).wait;
			wait.wait;
	        };
}).play};

~playNumbersAtOnce={
	~numberBuffers.do({|item index| 
		{PlayBuf.ar(item.numChannels,item,rate:0.5)}.play(s,~speakers[index])
})};

