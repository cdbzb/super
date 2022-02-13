Monitors {
	classvar <>decoder,k=0.9,<channels=5;
	classvar <>order=#[0,1,3,4,2]; //for Trek
	*initClass {
		decoder = FoaDecoderMatrix.newPanto(5,'flat',k);
	}
	*ambi { |i| 
		^FoaDecode.ar(i,decoder) => {|i| i[[order]]}
	}
	*az { | i angle=0 width=1 | ^PanAz.ar(5,i,angle,width)[[order]] }
}
