(
	if(~numberBuffers==nil,{~numberBuffers=Array.newClear(8)});
	~makeNumberBuffers={|lang=\en|
		var voices=Say.findVoice(lang: lang);
		    8.do { |index|
			        SayBuf.prepare((voice: voices, lang: \en, text:index.asString,
				bufAction: { |b| ~numberBuffers[index]=b };
			    ));
		};
	};

	~playNumbers={Routine.new({
		       8.do { |x|
				{PlayBuf.ar(1,~numberBuffers[x], rate:0.5 )}.play(s,~speakers[x]);
				(~numberBuffers[x].numFrames/44000).wait;
				0.1.wait;
		        };
	}).play};

	~playNumbersAtOnce={
		~numberBuffers.do({|item index| 
			{PlayBuf.ar(item.numChannels,item,rate:0.5)}.play(s,~speakers[index])
	})};
)
~makeNumberBuffers.(\fr);
~playNumbers.();
~numberBuffers;
~playNumbersAtOnce.play;

~speakers=1!8;

