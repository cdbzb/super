Monitors {  //setup monitoring for Trek piece
	classvar <>decoder,k=0.5,<channels=5;
	//classvar <>speakerOrder=#[0,2,4,3,1]; //for Trek
	classvar <>speakerOrder=#[0,4,1,3,2]; //for Trek
	classvar <>deviceChannels;
	classvar <>foldDown;
	*initClass {
		Class.initClassTree(StageLimiter);
		foldDown=[nil,nil,nil];
		decoder = FoaDecoderMatrix.newPanto(5,'flat','dual');
		deviceChannels = Dictionary.newFrom(
			[
				"MacBook Pro Speakers",2,
				"Pro Ag",2,
				"BlackHole 2ch",2,
				"External Headphones",2,
				"ZoomAudioD",2,
				"BoseAg",2
			]
		);
		StartUp.add{ 
			// this belongs in startup.scd
			// Server.local.options.numOutputBusChannels = 5;
			Server.default.boot;
			// Server.default.waitForBoot{
			// }
		};
		ServerTree.add ({ 
			var channels = deviceChannels.at(Server.default.options.outDevice);
			(channels == 2).if{
				fork{
					{ StageLimiter.activeSynth.isRunning }.try.notNil.if{ StageLimiter.deactivate; };
					StageLimiter.activate;
					Monitors.stereo;
					// ServerTree.remove(StageLimiter.lmFunc); StageLimiter.activate;
					Server.default.sync;
					{
						// foldDown[0]=Monitor.new => _.play(2,2,0,2,target:RootNode(Server.default));
						foldDown[0]=Monitor.new => _.play(2,2,0,2,target:StageLimiter.activeSynth.nodeID, addAction:\addBefore);
						foldDown[1]=Monitor.new => _.play(4,1,0,1,target:StageLimiter.activeSynth.nodeID, addAction:\addBefore, volume: -6.dbamp);
						foldDown[2]=Monitor.new => _.play(4,1,1,1,target:StageLimiter.activeSynth.nodeID, addAction:\addBefore, volume: -6.dbamp);
						// {In.ar(0,2) * -4.8.dbamp => ReplaceOut.ar(0,_)}.play(target:StageLimiter.activeSynth.nodeID, addAction:\addBefore)
					}.defer(0.2)
				}
			}{
				{ StageLimiter.activeSynth.isRunning }.try.notNil.if{ StageLimiter.deactivate; };
				StageLimiter.activate
			}
		});
	}
	*stopFoldDown{
		foldDown.do(_.stop)
	}
	*startFoldDown{
		foldDown.do(_.play)
	}
	*pentagon {
		decoder = FoaDecoderMatrix.newPanto(5,'flat','dual');
		speakerOrder=#[0,4,1,3,2]
	}

	*decode { |i| 
		^(
			FoaDecode.ar(i,decoder) 
			=> {|i| i[speakerOrder]}
		)
	}

	//deprecated!
	*ambi { |i| 
		^(
			FoaDecode.ar(i,decoder) 
			=> {|i| i[speakerOrder]}
		)
	}

	*az { | i angle=0 width=1 | ^PanAz.ar(5,i,angle,width)[speakerOrder] }
	*stereo {
		decoder =FoaDecoderMatrix.newStereo();
		channels = 2;
		speakerOrder = #[0,1]
	}
	*epos {
		var o =Server.default.options;
		o.inDevice_("EPOS PC 8 USB");
		o.outDevice_("EPOS PC 8 USB");
		Server.default.reboot
	}
	*blackHole16 {
		var o =Server.default.options;
		o.inDevice_("BlackHole 16ch");
		o.outDevice_("BlackHole 16ch");
		Server.default.reboot
	}
	*blackHole {
		var o =Server.default.options;
		o.inDevice_("BlackHole 2ch");
		o.outDevice_("BlackHole 2ch");
		Server.default.reboot
	}

	*rme{
		var o =Server.default.options;
		o.inDevice_("Digiface USB (23953833)");
		o.outDevice_("Digiface USB (23953833)");
		Server.default.reboot
	}
	*macbook{
		var o =Server.default.options;
		o.inDevice_("MacBook Pro Microphone");
		o.outDevice_("MacBook Pro Speakers");
		Server.default.reboot
	}
	*headphones{
		var o =Server.default.options;
		o.inDevice_("MacBook Pro Microphone");
		o.outDevice_("External Headphones");
		Server.default.reboot
	}
	*bose{

		var o =Server.default.options;
		o.inDevice_("BoseAg");
		o.outDevice_("BoseAg");
		Server.default.reboot
	}
	*airpods {
		var o =Server.default.options;
		o.inDevice_("Pro Ag");
		o.outDevice_("Pro Ag");
		Server.default.reboot
	}
	*zoom {
		var o =Server.default.options;
		o.inDevice_("ZoomAudioD");
		o.outDevice_("ZoomAudioD");
		Server.default.reboot
	}

}
