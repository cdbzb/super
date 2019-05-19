		~waves=Buffer.read(s,"/Users/michael/tank/THE FUTURE/SC-bounces/Hayburn.wav");
(//little composition
		~ocean=NodeProxy.audio(s,2).play;
		~ocean.source={PlayBuf.ar(~waves.numChannels,~waves,loop:1)*10};		
		~ocean.stop;

	//setup
		~klankBus=NodeProxy.control(s,8);
~klankBus.fadeTime=200;
		~klank=NodeProxy.audio(s,2).play;
		~klank.source= {|time=0.8 bottom=300| DynKlank.ar(`[~klankBus,[0.1,0.1,0.3,0.2,0.3,0.3]*0.5,time!6],~ocean )*0.08};

	//play

)
(
	{
	5.do{(
		~klank.play(vol:0.3,fadeTime:20); //??
		~klank.set(\time,0.01);
		~klankBus.fadeTime=60;
		~klankBus.put(2,250);
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

///////Membrane


~membrane=NodeProxy.audio(s,2).play;
~membrane.source={|tensionn=0.008 los=0.99999| MembraneHexagon.ar(~ocean, tension: tensionn, loss: los, mul: 0.2, add: 0)};
~membrane.fadeTime=90;
~membrane.fadeTime=10;
~membrane.xset(\tensionn,0.219); //xset has same effect as lag?
~membrane.xset(\tensionn,0.019);
~membrane.xset(\tensionn,0.001);
~membrane.xset(\tensionn,0.009);
~membrane.set(\tensionn,0.008);
~membrane.xset(\tensionn,0.007);
~membrane.xset(\tensionn,0.004);

~test=NodeProxy.audio;
~test.source={|freq=300|SinOsc.ar(freq,0,0.1)};
~test.play;
~test.xset(\freq,200);
~test.fadeTime=20;


~ocean.play(vol:1.0);
~ocean.stop;
~membrane.xset(\los,0.99); // dry
~membrane.xset(\los,0.999); // gets wierd
~membrane.xset(\los,0.9999,\tensionn,0.0081); //
~membrane.xset(\los,0.9999,\tensionn,0.015); //
~membrane.xset(\los,0.9999,\tensionn,0.019); //
~membrane.xset(\los,0.99999); //singing
( // make tension and los change slowly
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

( ////chord wave: --setup
	SynthDef(\triangle,{ |freq len=300 vol=0.05|
		var env=EnvGen.kr(Env.triangle(len));
		var sig = SinOsc.ar(freq,0,env*vol);
		Out.ar(0,sig!2);
	},[1136,0,16]).add; //long lags

~tri={|freq len=300 vol=0.005| Synth.new(\triangle,[\freq,freq,\vol, vol,\len,len])};

//~chords=[[440,360,400,564,604], [360,400,450,850,950], [400,1248,660,1]];
~chords=[[440,500,400,564,604]];
~chord=[440,500,400,564,604];

	~playme={ |chord=#[360,460,520,660] len=300 pause=25 vol=1|
		var notes=Array.newClear(chord.size);
		Routine.new({ 
			chord.do({|item index| 
				index.postln;notes[index].postln;
				notes[index]=~tri.(item,len);
				pause.wait;
			});
		}).play;
		notes;
	};
)
(

	{
		//var notes=~playme.(~chord,len:90,pause:15);
		3.do({
			var notes=~playme.(~chords.choose,len:90,pause:15);
			45.wait;
			3.do({
				{notes[2].set(\freq,600);3.wait;notes[2].set(\vol,0);16.wait;notes[2].free;notes[2]=~tri.(~chord[2])}.fork;
				15.wait;
				{notes[1].set(\freq,500);3.wait;notes[1].set(\vol,0);16.wait;notes[1].free;notes[1]=~tri.(~chord[1])}.fork;
				15.wait;
				{notes[3].set(\freq,10);3.wait;notes[3].set(\vol,0);16.wait;notes[3].free;notes[3]=~tri.(~chord[3])}.fork;
				15.wait;
				{notes[0].set(\freq,1000);3.wait;notes[0].set(\vol,0);16.wait;notes[0].free;notes[0]=~tri.(~chord[0])}.fork;
				15.wait;
			});
			//50.wait; //?????????
		});
	}.fork
)



