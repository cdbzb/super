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

( // 11 numbers
~numberString={|num=6| var wrd; num.do({wrd=wrd++rand(10).asString++' '});wrd++',';};

	{
		{PlayBuf.ar(~confirmation.numChannels,~confirmation,rate:0.48)*0.5}.play(s,~speakers[2]);
		2.wait;
		5.do({
			SayBuf.prepare((voice: \Samantha,lang: \en, text:~numberString.(11), bufAction:{|b| ~buff=b}));
			0.1.wait;
			~buff.loadToFloatArray(action: {|array| ~numberz=Buffer.sendCollection(s,array)});
			0.1.wait;
			{PlayBuf.ar(~numberz.numChannels,~numberz,rate:0.48)*0.5}.play(s,~speakers[rand(7)]);
			rrand(2,4).wait;
		});
		1.wait;
		a={PlayBuf.ar(1,~edm)*0.5 }.play(s,~speakers[3]);
		5.wait;
		{PlayBuf.ar(1,~doors[3])*2}.play(s,~speakers[3]); 
		0.2.wait;
		a.free;
	}.fork
)

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

