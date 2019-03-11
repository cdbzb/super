~speakers=1!8;
	~ambiStreet= Buffer.read(path: "/Users/michael/tank/SchaferHouse/Freesound/139023__lossius__agotnes-terminal-b-format.flac");
		~bypass.(~traffic);
		~traffic.wet.source={Res}
		~traffic=~makeNodes.();
		~traffic.wet.play(fadeTime:10);
		~traffic.dry.source={FoaDecode.ar(PlayBuf.ar(4,~ambiStreet,loop:1)*1,~decoder)};
		~longVerb=Library.at(\functions,\prep).("/Users/michael/tank/IR/Saane/Factory_Hall/Factory_Hall.wav");
		~traffic.wet.fadeTime=20;
		~traffic.wet.source={Streson.ar(~traffic.dry,[0.006,0.005,0.007])};
		~traffic.wet.source={Klank.ar(`[[200,300,400, 240, 260, 390, 403],[1,0.8,0.6,0.5,0.4,0.3],0.3!6],~traffic.dry)*0.08};
		~bypass.(~traffic);
		~setIR.(~traffic,~longVerb,0.4);
		(
			~traffic.wet.source={ 
				TwoTube.ar(~traffic.dry,d1length:[100,400,5500],d2length:[220,3000,350],loss:0.97)}
			)
		~traffic.wet.source={Resonz.ar(~traffic.dry,200)};

		~traffic.wet.source={|in| PartConv.ar(in,4096,)}
		~traffic.wet.stop(15);

		a={SinOsc.ar([300,350,220,550,600,480],0,0.15)*LFTri.ar(0.04)}.play
		a.free;
		(
			Routine.new({
				10.do({
			a={SinOsc.ar([300,350,220,550,600,480],0,0.15)*LFTri.ar(0.03)}.play;
			40.wait;
			a.release(10);
			35.wait
			});
			}).play;
		~traffic=~makeNodes.();
		~traffic.wet.fadeTime=10;
		~traffic.wet.play(fadeTime:10);
		~traffic.dry.source={FoaDecode.ar(PlayBuf.ar(4,~ambiStreet,loop:1)*1,~decoder)};
			Routine.new({
				3.do({

					20.wait;
		~traffic.wet.source={Klank.ar(`[[200,300,400, 240, 260, 390, 403],[1,0.8,0.6,0.5,0.4,0.3],0.3!6],~traffic.dry)*0.08};
					20.wait;
					~setIR.(~traffic,~longVerb);
					20.wait;
~traffic.wet.source={ TwoTube.ar(~traffic.dry,d1length:[100,800,5500],d2length:[220,3000,350],loss:0.97)};
		10.wait;
					~bypass.(~traffic);
					10.wait;
				});

			}).play
		)
		s.plotTree;
		c;
