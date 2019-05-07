(   /////////////// must be run on local server
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

	~playOneNumber={var num=rand(7);
		{  PlayBuf.ar(1,~numberBuffers[num],rate:0.5) }.play(s,~speakers[num])		;
	};

	 ~yourConfirmation={  SayBuf.prepare((voice: \Samantha,lang: \en, text:"your confirmation number is", bufAction:{|b| ~buff=b}));
		~buff.loadToFloatArray(action: {|array| ~confirmation=Buffer.sendCollection(s,array)});

	};
);

~makeNumberBuffers.();
~yourConfirmation.();
~moveNumberBuffersToRemote.();
~playOneNumber.();
({30.do({~playOneNumber.();rand(15).wait})}.fork);
({30.do({~playOneNumber.();linrand(0.1,1).wait})}.fork);
s=Server.local;
~playFiveNumbers={Routine.new({5.do({~playOneNumber.();0.5.wait})}).play};
s.boot;
~playFiveNumbers.();
(
	{
		{PlayBuf.ar(~confirmation.numChannels,~confirmation,rate:0.5)}.play(s,~speakers[2]);
		2.wait;
		5.do({
		~playFiveNumbers.();
		rrand(5,7).wait;
		})
	}.fork
)

~yourConfirmation.();
~confirmation.();
s;
~alexa;
{PlayBuf.ar(~alexa.numChannels,~alexa,rate: 0.5)}.play(s,~speakers[0]);

~prepAlexa.();
s;
s=Server.local;


