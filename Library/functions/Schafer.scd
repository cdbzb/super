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

~playNumbers={ |wait=0.1 amp=0.9|
	Routine.new({
	       8.do { |x|
			{PlayBuf.ar(1,~numberBuffers[x], rate:0.5 )*amp}.play(s,~speakers[x]);
			(~numberBuffers[x].numFrames/44000).wait;
			wait.wait;
	        };
}).play};

~playNumbersAtOnce={
	~numberBuffers.do({|item index| 
		{PlayBuf.ar(item.numChannels,item,rate:0.5)}.play(s,~speakers[index])
})};

 ~prepAlexa={  SayBuf.prepare((voice: \Samantha,lang: \en, text:"the time now, is 4:45",bufAction:{|b| ~buf=b}));
	~buf.loadToFloatArray(action: {|array| ~alexa=Buffer.sendCollection(s,array)});
};

~makeSpace= { |channels=2|
	var space=();
	space.add(\bus->Bus.audio(s,channels));
	space.add(\node->NodeProxy.audio(s,2));
	space.node.source={In.ar(space.bus)};
	space;
};

~setBusIR={|dict ir  slot=3|
	dict.node[slot]= \filter->{ |in| PartConv.ar(in,4096,ir)};
};

~walkFromTo={|stepNumber=0 from=2 to=7 time=15 fadeIn=0.5 fadeOut=0.2|
	var vol=[2.5,0.2].at(stepNumber);
	var steps= [~carpetsteps,~footsteps[2]].at(stepNumber);
	{
	var line=Line.kr(0,1,dur:time);
	var env=EnvGen.kr(Env.linen(fadeIn,time-(fadeIn+fadeOut),fadeOut));
	//var steps=[~carpetsteps,~footsteps[2]].at(i_stepNumber);
	steps=PlayBuf.ar(1,steps,loop:1)*env*vol;
	Out.ar(from,steps*(1-line));
	Out.ar(to,steps*line);
}.play};
