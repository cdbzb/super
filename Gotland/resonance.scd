
~waves=Buffer.read(s,"/Users/michael/tank/THE FUTURE/SC-bounces/Hayburn.wav");
		~ocean=NodeProxy.audio(s,2).play;
		~ocean.stop;
		~ocean.play;
		~ocean.source={PlayBuf.ar(~waves.numChannels,~waves,loop:1)*10};		
		~ocean[1]=\filterIn-> {|in time=0.8| DynKlank.ar(`[[410,500,205, 146, 150, 290, 303],[0.5,0.4,0.3,0.2,0.3,0.3]*0.5,time!6],in )*0.08};
		~ocean.set(\time1,0.0);
		~ocean[1].set(\time,0);
		~ocean[1]=nil;
		~klank=NodeProxy.audio(s,2).play;
		~klank.source= {|time=0.8 bottom=410| DynKlank.ar(`[[bottom,1450,205, 146, 150, 290, 303],[0.0,0.1,0.3,0.2,0.3,0.3]*0.5,time!6],~ocean )*0.08};
		~klank.source= {|time=0.8 bottom=300| DynKlank.ar(`[[bottom,400,450,360,600,500],[0.1,0.1,0.3,0.2,0.3,0.3]*0.5,time!6],~ocean )*0.08};
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
		a[4].set(\fr,60);
		~cloudchord.([300,400,450,360,600,500],0.008);
