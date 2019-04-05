(
	if(~numberBuffers==nil,{~numberBuffers=Array.newClear(8)});
	~makeNumberBuffers={|lang=\en|
		var voices=Say.findVoice(lang: lang);
		    8.do { |index|
			        SayBuf.prepare((voice: voices, lang: \en, text:(index+1).asString,
				bufAction: { |b| ~numberBuffers[index]=b };
			    ));
		};
	};

	~moveNumberBuffersToRemote={
		8.do({	|i|
			var buf=~numberBuffers[i];
			buf.loadToFloatArray(action:
				{|array| 
				~numberBuffers[i]=Buffer.sendCollection(s,array)});
			
		});
	};

	~playNumbers={Routine.new({
		       8.do { |x|
				{PlayBuf.ar(1,~numberBuffers[x], rate:0.5 )}.play(s,~speakers[x]);
				(~numberBuffers[x].numFrames/44000).wait;
				0.8.wait;
		        };
	}).play
};

	~playNumbersAtOnce={
		~numberBuffers.do({|item index| 
			{PlayBuf.ar(item.numChannels,item,rate:0.5)}.play(s,~speakers[index])
	})};

	 ~prepAlexa={  SayBuf.prepare((voice: \Samantha,lang: \en, text:"the time now, is 4:45",bufAction:{|b| ~buf=b}));
		~buf.loadToFloatArray(action: {|array| ~alexa=Buffer.sendCollection(s,array)});
	};
);
