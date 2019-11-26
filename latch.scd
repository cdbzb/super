(
	{
		PlateReverb.ar(
		Saw.ar(
			(Latch.kr
				(SinOsc.kr(100)+SinOsc.kr(250),Impulse.kr([7,3]))*30+40).round().midicps
				,0.1),
				mix:0.3)

	}.play
)
s.boot;


(//raygun Also try Saw and diff rates
	var base=300, rate=10;
	5.do{|i|var phase=pi*i/2.5;
		{SinOsc.ar(SinOsc.kr(rate,phase,base,add:base*2),0,0.1)}.play(s,1)
	}
)

(
	var base=300, rate=20;
	5.do{|i|var phase=pi*i/2;
		{Saw.ar(LFTri.kr(rate,phase).linexp(-1,1,base,base*2),0.1)}.play(s,1)
	}
)

a.play([\phase,1]);
4.do{|i|a.play([\phase,(i)/4])}
a(2).play
a.()
Function

{SinOsc.ar(110.rand)}.plot
{SinOsc.ar(300,0,SinOsc.kr(0.3,0,pi,0.1)).tan*0.5}.play(s,1)
(
{
    var x, y, distance, velocity, pitchRatio, amplitude, motorSound;
    // object travels 200 meters in 6 secs (=120kph) passing 10 meters
    // from the listener
    x = 10;
    y = LFSaw.kr(1/6, 0, 100);
    distance = hypot(x, y);
    amplitude = 40 / distance.squared;
    motorSound = RLPF.ar(FSinOsc.ar(200, 0, LFPulse.ar(31.3, 0, 0.4)), 400, 0.3);
    DelayL.ar(motorSound, 110/344, distance/344, amplitude)
}.play(s,1)
)

"*p"
(
{
    var x, y, distance, velocity, pitchRatio, amplitude, motorSound,
            azimuth, panValue;
    // object travels 200 meters in 6 secs (=120kph) passing 10 meters
    // from the listener
    x = 5;
    y = LFSaw.kr(1/8, 0, 100);
    distance = hypot(x, y);
    amplitude = 40 / distance.squared;
    motorSound = RLPF.ar(FSinOsc.ar([360,280], 0, LFPulse.ar(31.3, 0, 0.4)), 400, 0.3);
	motorSound=Mix.ar(motorSound);
    azimuth = atan2(y, x); // azimuth in radians
    panValue = (azimuth / 0.5pi).clip2(1); // make a value for Pan2 from azimuth
    Pan2.ar(DelayL.ar(motorSound, 110/344, distance/344), panValue, amplitude)
}.play)

~doppler={|in x y maxDistance=110| 
	var distance=hypot(x,y);
	var amplitude=40/distance.squared;
	var azimuth=atan2(x,y);
	var pan = (azimuth/0.5pi).clip2(1);
	var speedOfSound = 344 //m/s
    Pan2.ar(DelayL.ar(in,maxDistance/speedOfSound, distance/speedOfSound), panValue, amplitude)
}

(//funky
	Ndef(\aa,{Saw.ar([360,280],pi).tanh}).play;
	///try a ndef playing a pattern in place of the LFSin here
	Ndef(\aa)[1]=\filter->{|in|OnePole.ar(in,SinOsc.ar(5.1).tan.range(-1,1)	)};
	//wait before this one
	Ndef(\aa)[2]=\filter->{|in|OnePole.ar(in,SinOsc.ar(5.1,0.5)	)};
	//then this 
	Ndef(\aa)[3]=\filter->{|in|CombC.ar(in/10,1,5.1.reciprocal*3.5,6)*0.1}
)
a=[amp:0.5,degree:Pwhite(0,10,inf),dur:5.1.reciprocal/4,octave:3].p
a.play
a.stop
a.free
