(//little composition
		~ocean=NodeProxy.audio(s,2);
		~ocean.source={PlayBuf.ar(2,~waves,loop:1)*10};		
		~klankBus=NodeProxy.control(s,8);
		//~klankBus.fadeTime=200;
		~klankBus.fadeTime=60;
		~klank=NodeProxy.audio(s,2);
		~klank.source= {|time=0.8 bottom=300| DynKlank.ar(`[~klankBus,[0.1,0.1,0.3,0.2,0.3,0.3]*0.5,time!6],~ocean )*0.08};



	//play
	~klankRoutine=Task{
		SystemClock.seconds.postln;
	5.do{(
		~klank.initMonitor;
		~klank.monitor.outs_([[0,~out.index+2],[1,~out.index+3]]);
		~klank.playN(vol:0.3,fadeTime:20); //??
		~klank.set(\time,0.01);
		~klankBus.source.postln;
		~klankBus.put(2,250);
		~klankBus.source.postln;
		5.wait;
		~klank.lag(\time,20); 
		~klank.set(\time,0.2);
		"4".postln;
		~klankBus.source.postln;
		~klankBus.source=[200,250,275,300,175,333]*rrand(0.95,1.05);
		~klankBus.source.postln;

		30.wait;
		~klankBus.source=[400,300,360,600,500,550]; //added 550
		~klankBus.source.postln;
		60.wait;
		~klank.stop(25);
		30.wait;
		20.rand.wait;
		SystemClock.seconds.postln;
	)};
	}
)
