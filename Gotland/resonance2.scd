
~waves=Buffer.read(s,"/Users/michael/tank/THE FUTURE/SC-bounces/Hayburn.wav");
~dry={PlayBuf.ar(~waves.numChannels,~waves)*5*EnvGen.kr(Env.asr(10))}.play;
~dry.release(30);
~dry.free;
~klank.play(vol:1);
~klank.play(vol:0,fadeTime:30);
~klank.fadeTime=10;
~klank.xset(\time,0.8)
~klankBus.fadeTime=200;
~klankBus[0]=100;
~klankBus.source=~tones;
~tones=[400,450,420,500,560,600];
~tones=~tones/2;
~chd=~tones.do({|item| {SinOsc.ar(item,0,0.001*EnvGen.kr(Env.asr(20)))!2}.play});
~klankBus[1];
~dry.free;
~klank.get(\time);
~klank.set(\time,0.2);
s.stopRecording;
( //ending-test
	{
	//s.prepareForRecord("/Users/michael/tank/THE FUTURE/SC-Bounces/ending-test.wav");
	//s.sync;
	//s.record;
		~dry={PlayBuf.ar(~waves.numChannels,~waves)*5*EnvGen.kr(Env.asr(10))}.play;
		//~tones=[400,450,420,500,560,600];
		~tones=[400,450,500,560,600];
		~tones=~tones/2;
		10.wait;
		~chd=~tones.do({|item| {SinOsc.ar(item,0,0.001*EnvGen.kr(Env.linen(40,10,30,)))!2}.play});

		~klank.play(vol:0.2,fadeTime:40);
		30.wait;
		~dry.release(46);
		~klank.play(vol:0,fadeTime:46);
		10.wait;
	}.fork

)

(
	{
		s.prepareForRecord("/Users/michael/tank/THE FUTURE/SC-Bounces/resonance1.wav",2);
		s.sync;
		s.record(duration:420);
	}.fork
)
s.stopRecording;

~klank.get(\time);
~klank.set(\time,0.01);
~klank.fadeTime=20;
~klank.xset(\time,0.001)
~klank.xset(\time,0.2);
~klank.release(30);
~klankBus.sources;
~klankBus=[200,250,275,300,175,333]/2;
~klankBus.put(2,250);


(
	{
		s.prepareForRecord("/Users/michael/tank/THE FUTURE/SC-Bounces/resonance5.wav",2);
		s.sync;
		s.record(duration:320);
	}.fork
)
s.stopRecording;
(//little composition

	{
//~cloudchord.([200,250,275,300],amp:0.1);
//30.wait;
//~dry={PlayBuf.ar(~waves.numChannels,~waves)*5*EnvGen.kr(Env.asr(10))}.play;
//a=~playme.([200,250,275,300]*2,len:120,vol:0.3);
//	~fol={|vol=2|PlayBuf.ar(~foley.numChannels,~foley,rate:(48/44.1),startPos:~voSections[2])*vol }.play;
	2.do{(
		~klank.play(vol:0.3); //??
		~klank.set(\time,0.01);
		~klankBus.fadeTime=60;
		~klaNkBus.put(2,250);
		//~klank.play;
		5.wait;
		~klank.xset(\time,0.2);
		~klankBus.source=[200,250,275,300,175,333]*rrand(0.95,1.05);
		30.wait;

		~klankBus.source=[400,300,360,600,500];
		//~klankBus.fadeTime=100;
		//~klankBus.put(2,550);
		60.wait;
		~klank.release(20);30.wait;
	)};
	}.fork
)
a;
		~klank.get(\fadeTime);


NodeProxy
		~ocean=NodeProxy.audio(s,2).play;
		~ocean.source={PlayBuf.ar(~waves.numChannels,~waves,loop:1)*10};		
		~ocean.stop;
		~ocean.play;
		~ocean[1]=\filterIn-> {|in time=0.8| DynKlank.ar(`[[410,500,205, 146, 150, 290, 303],[0.5,0.4,0.3,0.2,0.3,0.3]*0.5,time!6],in )*0.08};
		~ocean.set(\time1,0.0);
		~ocean[1].set(\time,0);
		~ocean[1]=nil;
		~klank=NodeProxy.audio(s,2).play;
		~klank.source= {|time=0.8 bottom=410| DynKlank.ar(`[[bottom,1450,205, 146, 150, 290, 303],[0.0,0.1,0.3,0.2,0.3,0.3]*0.5,time!6],~ocean )*0.08};
		~klank.source= {|time=0.8 bottom=300| DynKlank.ar(`[[bottom,400,450,360,600,500],[0.1,0.1,0.3,0.2,0.3,0.3]*0.5,time!6],~ocean )*0.08};
		~klank.source= {|time=0.8 bottom=300| DynKlank.ar(`[~klankBus,[0.1,0.1,0.3,0.2,0.3,0.3]*0.5,time!6],~ocean )*0.08};
		~klankBus=NodeProxy.control(s,8);
		~klankBus.source=[400,300,360,600,500];
		~klankBus.source=[SinOsc.kr(0.02)*100,+300];
		~klankBus.source=[800,450,360,610,510];
		~klankBus.fadeTime=20;
		~klank.source= {|freqs=#[300,350,400,460,500,575] time=0.8 bottom=300| DynKlank.ar(`[freqs ,[0.1,0.1,0.3,0.2,0.3,0.3]*0.5,time!6],~ocean )*0.08};
		~klank.xset(\freqs,[200,350,100,460,500,575]);
		~slowSin=NodeProxy.control(s,6);
		Array
		~klank.set(\time,0.001);
		~klank.set(\time,0.1);
		~klank.set(\time,0.5);
		~klank.set(\bottom,100);
		~klank.set(\bottom,300);
		~klank.set(\bottom,1000);
		~klank.lag(\time,30);
		~klank.lag(\bottom,500);
		~klank.clear;
		~klank.play;
~
		~ocean.set(\wet1,0.0);
		~ocean[1].set(\time,0.71);
		~ocean[1]=\filter-> {|in time=0.3| Klank.ar(`[[410,500,205, 146, 150, 290, 303],[0.5,0.4,0.3,0.2,0.3,0.3],(EnvGen.kr(Env.triangle(10)))!6],in )*0.08};
		~ocean[1].set(\time,4.1);
		~ocean.fadeTime=20;
		~ocean.fadeTime=0;
		~ocean[1]=nil;


		a=~playme.([300,400,450,360,660,500],vol:0.1,len:100);
		a[0].set(\fr,260);
		a[4].set(\fr,6000);
		~cloudchord.([300,400,450,360,600,500],0.008);
		c=~cloudchord.([300,400,450,360,600,500],0.08);
		5.do({|i|a[i].free});


~membrane=NodeProxy.audio(s,2).play;
~membrane.source={|tensionn=0.008| MembraneCircle.ar(~ocean, tension: tensionn, loss: 0.99999, mul: 0.3, add: 0)};
~membrane.source={|tensionn=0.008 los=0.99999| MembraneHexagon.ar(~ocean, tension: tensionn, loss: los, mul: 0.2, add: 0)};
~membrane.fadeTime=90;
~membrane.fadeTime=10;
~membrane.xset(\tensionn,0.219);
~membrane.xset(\tensionn,0.019);
~membrane.xset(\tensionn,0.001);
~membrane.xset(\tensionn,0.009);
~membrane.set(\tensionn,0.008);
~membrane.xset(\tensionn,0.007);
~membrane.xset(\tensionn,0.004);


~ocean.play(vol:1.0);
~ocean.stop;
~membrane.xset(\los,0.99); // dry
~membrane.xset(\los,0.999); // gets wierd
~membrane.xset(\los,0.9999,\tensionn,0.0081); //
~membrane.xset(\los,0.9999,\tensionn,0.015); //
~membrane.xset(\los,0.9999,\tensionn,0.019); //
~membrane.xset(\los,0.99999); //singing
(
	~membrane.lag(\tensionn,140);
	~membrane.lag(\los,40);
	~membrane.set(\tensionn,0.008);
	~membrane.set(\tensionn,0.0075);
	~membrane.set(\los,0.99999);
	~membrane.set(\los,0.9999); 
	~membrane.set(\tensionn,0.0075);
	~membrane.set(\los,0.999); 
	~membrane.set(\los,0.99); 
	~membrane.set(\tensionn,0.0070);
);
~membrane.get(\los);
~membrane.play(fadeTI
~membrane.stop;
		s.prepareForRecord("/Users/michael/tank/THE FUTURE/REFS/membrane0.008-99999.wav",2);
		s.sync;
		s.record(duration:300);


