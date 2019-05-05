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

(
	~times=~times=0.125!7;
	~arclengths=[0, 30, 45,90,130,230, 290,360]; //in degrees
	~levels=Array.newClear(8);
	~levels=~arclengths/180;
	e=Env.new(~levels,~times);
	e.plot;
)

s.sampleRate;
s.reboot;
b=Env.new(~levels,~times).plot;
b.plot;
Buffer
//put envelope from these into buffer?

//walk past right wall triple
{Out.ar(~speakers[1],PanX.ar(3,~footsteps[1], Line.kr(-1,2,10)))}.play;
