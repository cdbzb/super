(
	~times=~times=0.125!7;
	~arclengths=[0, 30, 45,90,130,230, 290,360,400]; //in degrees
	~levels=Array.newClear(7);
	~levels=~arclengths/180; //must range from 0 to 2
	~panEnv=Env.new(~levels,~times,loopNode:0 ,releaseNode:6 );
	~panEnv.plot;
)

(
	~levels=Array.series(9,0,0.285714);
	~levels.put(8,0);
	~arclengths=[0, 15, 60,100,180,250, 300,360,360]; //in degrees
	~times=~arclengths*2/360;
	~ttimes= Array.newClear(~times.size);
       	(~arclengths.size-1).do({|index| 
		~ttimes.put(index, ~times[index+1]-~times[index])});
	~ttimes.put(~ttimes.size-1,0);
	~panEnv=Env.new(~levels,~ttimes,loopNode:0 );
	~panEnv.plot;
	~panEnv.at(0);
	~levels.size;
	~levels;
	~times.size;
	~times;
)

(
	{
		//do with a gate instead
		var cycleLength = 10;
		//var in = PinkNoise.ar(0.05);
		var in = {PlayBuf.ar(1,~helicopter[3],rate:0.9)  };
		var gate=Impulse.ar(1/cycleLength);
		var env=EnvGen.kr(~panEnv, timeScale:(cycleLength/2),gate:gate);
		//pan=~panEnv.at(pan);
		(PanAz.ar(7,in,env,orientation:0,width:2));
	}.play(s,~speakers[0]);
)
(
	{
		//do with a gate instead
		var cycleLength = 17;
		var in =BrownNoise.ar(0.02);
		var gate=Impulse.ar(1/cycleLength);
		var env=EnvGen.kr(~panEnv, timeScale:(cycleLength/2),gate:gate);
		//pan=~panEnv.at(pan);
		(PanAz.ar(7,in,env,orientation:0,width:2));
	}.play(s,~speakers[0]);
)

~speakers;
o.free;
{WhiteNoise.ar(0.05)}.play(s,~speakers[4]);



