
(
	{
		SplayAz.ar(8,
			[
				PlayBuf.ar(1,~marketPhrases[0].bufnum),
				PlayBuf.ar(~marketPhrases[1].numChannels,~marketPhrases[1]),
				PlayBuf.ar(~marketPhrases[2].numChannels,~marketPhrases[2]),
			],
			width:0.05,center:1
		)
	//}.plot;
	}.play(s,~speakers[0])
)


(
	{ SplayAz.ar(  8, [ 	Mix.ar(PlayBuf.ar(2,~marketPhrases[1])),
				Mix.ar(PlayBuf.ar(2,~marketPhrases[2])),
				Mix.ar(PlayBuf.ar(2,~marketPhrases[0]))
			], spread:0.05,center:0.875)
	}.play(s,~speakers);
	
)
{PinkNoise.ar(0.05)}.play(s,~speakers[0]);

~phoneWalker=NodeProxy.audio(s,1);
~phoneWalker.source= {PlayBuf.ar(~holdMusic[2].numChannels,~holdMusic[2],loop:1)*0.25 };

~circlewalkers=NodeProxy.audio(s,7).play(~speakers);
~circlewalkers.sour,be


		~phoneWalker=[NodeProxy.audio(s,1).play(~speakers[5]), NodeProxy.audio(s,1).play(~speakers[2])];
		{PlayBuf.ar(~dialing[0].numChannels,~dialing[0],startPos:58000)*3 }.play(s,~speakers[5]);
		5.wait;
		{PlayBuf.ar(~dialing[0].numChannels,~dialing[2])*2 }.play(s,~speakers[5]);//ring
		7.wait;
		~phoneWalker[0].source={PlayBuf.ar(~holdMusic[2].numChannels,~holdMusic[2],loop:1)*0.25 };
		//25.wait;
		3.wait;

		{PlayBuf.ar(1,~dialing[0],startPos:58000)*3 }.play(s,~speakers[2]);
		5.wait;	
		{PlayBuf.ar(~dialing[0].numChannels,~dialing[2])*2 }.play(s,~speakers[2]);//ring
		7.wait;
		~phoneWalker[1].source={PlayBuf.ar(~holdMusic[2].numChannels,~holdMusic[4],loop:1)*0.07 };
		5.wait;



		(
		)
	~sayings=Dictionary.new;
(
	~prepPhraseToLib={ |text="you have arrived",lang=\en|
	(~sayings==nil).if({~sayings=Dictionary.new});
	SayBuf.prepare((lang: lang, text:text, bufAction:{|b| b.loadToFloatArray(action: {|array| ~sayings.add(text->Buffer.sendCollection(s,array))})}))};
	~prepPhraseToLib.("poopoo");
	{1.wait;{PlayBuf.ar(1,~sayings.at("poopoo"))}.play(s,~speakers[2]) }.fork;
)
~sayings;
		()
			~prepPhraseToBuff.("cat food");
			Dictionary
			(
				{
					~prepAlexa.(); 0.3.wait;
					{PlayBuf.ar(~alexa.numChannels,~alexa,rate:0.47 )}.play(s,1);
				}.fork
			)



			(
				{
					5.do( {
						a=["cat","dog","turkey"].choose;
						~prepPhraseToBuff.(a++" food");0.3.wait;
						{PlayBuf.ar(~buff.numChannels,~buff,rate:0.48)}.play(s,1);
						2.wait;

					})
				}.fork;
				)
		

(
	~playText={|text="default"pause=0.3|
		{~prepPhraseToBuff.(text);pause.wait;
		{PlayBuf.ar(~buff.numChannels,~buff,rate:0.48)}.play(s,1);
	}.fork;
};
)
		)
			
		)

		Buffer
		~buff;
		~buff.free;

		{PlayBuf.ar(~buff.numChannels,~buff,rate:0.48) }.play(s,~speakers[2])
		~buff;

		a={PinkNoise.ar(0.05)!8}.play(s,~speakers);


		(
			{
				~prepPhraseToBuff.("but bnut ubut nbut but but ubut u. lolo lopapa lop lods a . lolo lopapa lop lods a ");
				1.5.wait;
				{var spk=rand(7);spk.postln;ReplaceOut.ar(~speakers[spk],PlayBuf.ar(~buff.numChannels,~buff,doneAction:2,rate:0.47))}.play
			}.fork
		)
		a.free;


a;
`a;
a=`~gps;
~gps=5;
a;
		~gps;
		~speakers;
		s;
		{PlayBuf.ar(~gps.numChannels,~gps ,rate:0.47,doneAction:2)}.play(s,~speakers[4]);
		a={PinkNoise.ar(0.005)}.play(s,~speakers[4]);
		a.free;




~niceParty.(0.3,1);
~niceParty.(0.1,2);
~niceParty.(0.1,3);

~ce.push(s.boot, p);
"abcde".do { |k| p[k.asSymbol].ar };
m = ProxyMixer(p, 8);
n.parent.alwaysOnTop_(true); // show mixer in front of IDE
)

p.do(_.play(0));
m.object_(nil);
m.object_(p);

// if you have JITLibExtensions installed, try ProxyMeter to see the proxy levels:
if (\ProxyMeter.asClass.notNil) { ProxyMeter.addMixer(m); };


"abcdefghijk".do { |k| p[k.asSymbol].ar };

"lmnopqrtuvw".do { |k| p[k.asSymbol].kr };

"abcdefghijk".do { |k, i|
    p[k.asSymbol].playN(vol: 0.8 - (0.1 * i) );
    p[k.asSymbol].source = {
        VarSaw.ar((i + 1 * 100) + [-1, 1])
        * LFSaw.ar((i + 1 * 0.25));
    };
};)niceParty.(0.1);
~partyPauser.pause;~jumpinessTask.pause;~crowd.do({|m| m.set(\vol,0)});
~fu.(~ice);
~fu.(~chairs);
~partyPauser.resume;~jumpinessTask.resume;
~niceParty.set(\sound,0);
~partyPauser.pause;~jumpinessTask.pause;
~partyPauser;
Task
(
	{
		~beeep={ReplaceOut.ar(~speakers[0],{PinkNoise.ar(0.01)}!8)}.play(s,addAction:\addToTail);
		1.6.wait;
		~beeep.free;
	}.fork
)




this.postln;
this.inspect;
(

	a=[];
	this.codeDump={|code|a=a.add(code)};
	3+3;
	a;
	a[1];

		
)
a[2];

-> 	this.codeDump={|code|a=a.add(code)};


p=ProxySpace.push(s.boot,p);

"abcdef".do{|k| p[ k.asSymbol ].ar};

m=ProxyMixer(p,8);
Platform.ideName;
Platform.userHomeDir;
m=ProxyMixer=ProxyMixer
w=Window.new.alwaysOnTop_(true)
w.front;

o=SoundFileView(w,Rect(0,100,900,100));
o.elasticMode=true;
f=SoundFile.new;
f.openRead("/Users/michael/tank/SchaferHouse/SOUND/APPLIANCES/Air Dryer Industrial.wav");
o.soundfile=f;
o.read(0,f.numFrames);
o.drawsWaveForm=true;
o.inspect;
o.timeCursorOn=true
o.timeCursorPosition;
o.bounds_(Rect(0,100,900,200));

thisProcess.nowExecutingPath;

"a b c | d".replace("| ", "");

Pbind
Panola
String.

d=[1,3,5,7,9,8,5,4,3,2,1, \rest];
(
	b=Pbind(
		\degree , Pseq([\rest],4)++Pseq(d,inf),
		\dur , 0.3
	).play;
	c=Pbind(
		\degree , Pseq(d,inf)+12,
		\dur , 0.3,
		//\octave, 1
	).play;
)
a;
s.reboot;
