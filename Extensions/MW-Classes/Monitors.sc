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
	*ambi { |i| 
		^(
			FoaDecode.ar(i,decoder) 
			=> {|i| i[speakerOrder]}
		)
	}
	*az { | i angle=0 width=1 | ^PanAz.ar(5,i,angle,width)[speakerOrder] }
	*stereo {
		decoder = FoaDecoderKernel.newUHJ();
		channels = 2;
		speakerOrder = #[0,1]
	}
}
