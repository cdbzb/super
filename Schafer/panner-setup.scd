//smoothening
(
	{
		var in= PinkNoise.ar(0.1);
		var pan = LFSaw.kr(0.5);
		var width = Line.kr(0,8,90,doneAction: 2); //start end dur
		PanAz.ar(8,in,pan,width);
	}.play
	s.meter;
)

~arclengths=[30,20,45,90,15,20,35,30]; //in degrees
//put envelope from these into buffer?

//walk past right wall triple
{Out.ar(~speakers[1],PanX.ar(3,~footsteps[1], Line.kr(-1,2,10)))}.play;
