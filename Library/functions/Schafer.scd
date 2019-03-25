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
