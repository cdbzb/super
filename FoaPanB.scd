a = FoaEncoderMatrix.newOmni;
(
{

	Impulse.ar(3)
	=> FoaEncode.ar(_,a)
	=> FoaTransform.ar(_, 'press',MouseX.kr(pi,-pi),MouseY.kr(0,pi/2))
	//=> FoaPanB.ar(_,MouseX.kr(pi,-pi),MouseY.kr(0,pi/2))
	//=> Monitors.ambi(_) 
	=> FoaDecode.ar(_,Monitors.decoder)
	=> LeakDC.ar(_)
	//=> {|i| i[[0,1,3,4,2]]}
	=> {|i| i[[0,1,3,4,2]]}
}.play
)
(out:2,pan:-1).play
[ out:Monitors.speakerOrder[Monitors.speakerOrder].q,pan:-1 ,legato:0.4,freq:555].p.play
s.meter
Monitors.speakerOrder
