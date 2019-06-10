(
	{
		~waves=Buffer.read(s,"/Users/michael/tank/THE FUTURE/SC-bounces/Hayburn.wav");
		~waves_3m=Buffer.read(s,"/Users/michael/tank/THE FUTURE/SC-bounces/3m-stereo\ bounce.wav");
		s.sync;

		~membraneInput=NodeProxy.audio(s,2);
		~membraneInput.fadeTime=5;
		~membraneInput.source={PlayBuf.ar(~waves.numChannels,~waves,loop:1)*10};		

		~membrane=NodeProxy.audio(s,2);
		~membrane.fadeTime=5;
		~membrane.source={|tensionn=0.008 los=0.99999| MembraneHexagon.ar(~membraneInput, tension: tensionn, loss: los, mul: 0.2, add: 0)};

		//~membrane.source={|tensionn=0.008 los=0.99999| MembraneHexagon.ar(~membraneInput, tension: tensionn+LFNoise1.kr(0.1,0.0002), loss: los, mul: 0.2, add: 0)};//some wobbling, nice!
		//~membrane.source={|tensionn=0.008 los=0.99999| MembraneHexagon.ar(~membraneInput, tension: tensionn+LFNoise1.kr(0.1,0.0001), loss: los, mul: 0.2, add: 0)};//some wobbling, nice!

		///set lags
		~membrane.lag(\tensionn,140);
		~membrane.lag(\los,40);


		/// SET OUTPUT BUS
		~membrane.play(~out.index+4);
	}.fork
)
