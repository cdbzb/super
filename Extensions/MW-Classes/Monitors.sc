Monitors {
	classvar <>decoder,k=0.5,<channels=5;
	//classvar <>speakerOrder=#[0,2,4,3,1]; //for Trek
	classvar <>speakerOrder=#[0,4,1,3,2]; //for Trek
	*initClass {
		decoder = FoaDecoderMatrix.newPanto(5,'flat','dual');
		StartUp.add ({ 
			(Server.default.options.outDevice == "MacBook Pro Speakers").if{
				Server.default.waitForBoot{
					Monitors.stereo;
					Monitor.new => _.play(0,5,0,2,target:RootNode(Server.default));
				};
				CmdPeriod.add({ Monitor.new => _.play(0,5,0,2)})
			}
		});
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
	* epos {
		var o =Server.default.options;
		o.inDevice_("EPOS PC 8 USB");
		o.outDevice_("EPOS PC 8 USB");
		Server.default.reboot
	}
}
