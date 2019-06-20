		(

			~loss=[0.99999,0.9999,0.999,0.99];
			~out=Bus.new(numChannels:10);
			~duckEdit20=Buffer.read(s, "/Users/michael/tank/THE FUTURE/SC-bounces/Duck edit 20m.wav");
			{ s.prepareForRecord("/Users/michael/tank/THE FUTURE/SC-bounces/duckEditBranes.aif",numChannels:10);
			s.sync;
			s.record(duration:1801);
			{
				var sig=PlayBuf.ar(2,~duckEdit20,loop:1);
				4.do{|i|
					Out.ar(~out.index+(2*i),
						MembraneHexagon.ar(sig,tension:0.008,loss:~loss[i])
					)};
					Out.ar(~out.index+8,sig);
			}.play;
		}.fork
		)
		s.boot;
		~out.scope;
