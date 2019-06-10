(
	SynthDef (\sinLag, {|freq=400 ftime=1000 amp=0.005 atime=16 acurve=0  pan=0 ptime=10 fadein=52 fcurve=0| 
		var fr=VarLag.kr(freq,ftime,warp:\exp);
		var pn=VarLag.kr(pan,ptime);
		var vl =VarLag.kr(amp,atime,acurve);
		var env =EnvGen.kr(Env.triangle(fadein));
		Out.ar(0,Pan2.ar(SinOsc.ar(fr,0,vl*env),pn));
	}

	).add;
)

a=Synth(\sinLag,[\freq,400,\fadein,99]);
b=Synth(\sinLag,[\freq,500,\fadein,99]);
~toneArray=Array.newClear(5);
~enter={|voice freq=300 fade=99 amp=0.005| ~toneArray[voice]=Synth(\sinLag,[\freq,freq,\fadein,fade,\vol,amp])};
~enter.(1,400,59,0.002);
~enter.(5.rand,400+(20*3.rand),59,0.002);
~enter.(0,420,59,0.002);
~enter.(0,400,59,0.002);
~enter.(0,400,59,0.002);
~toneArray[1].get(\freq,{|i|i.postln});

~toneArray[1].set(\freq);
~enter.(2,440,79);
~enter.(3,640,79);
~enter.(4,550,50);
~toneArray[1].set(\freq,100,\ftime,1000); ~toneArray[1].set(\amp,0);
~toneArray[3].set(\freq,1000,\ftime,1000); ~toneArray[3].set(\amp,0);
~toneArray[3].set(\freq,100,\ftime,100); ~toneArray[3].set(\amp,0);
~toneArray[4].set(\freq,100,\ftime,100); ~toneArray[4].set(\amp,0);
(
	{
		~enter.(0,440,80);
		24.wait;
		~enter.(1,500,80); 
		~enter.(2,400,80); 
		~enter.(4,460,80); 
		~enter.(4,460,80); 
		~toneArray[0].set(\freq,100,\ftime,100,\amp,0);
		~toneArray[2].set(\freq,100,\ftime,100,\amp,0);
		~toneArray[1].set(\freq,100,\ftime,1000,\amp,0,\atime,32);
		~toneArray[3].set(\freq,100,\ftime,1000,\amp,0,\atime,90);
		~toneArray[1].get(\freq ,{|i| ~enter.(3,i*1.540)});
		~toneArray[2].get(\freq ,{|i| ~enter.(3,i*1.2)});

	}.fork
)

Synth


a=~tri.(300,99);

a.set(\)
a.set(\amp,0.00);
a.set(\freq,200,\amp,0,\ftime,1000);
b=Synth(\sinLag,[\freq,400,\flag,20,\amp,0.01]);
a.set(\freq,3000,\amp,0,\atime,5,\ftime,100);
a.set(\freq,400,\amp,0.1,\atime,5);
a.set(\freq,300);
a.set(\amp,0.01);
b.set(\amp,0.01);
{(PlayBuf.ar(~waves_3m.numChannels,~waves_3m,rate:(48/44)))}.play
{(PlayBuf.ar(~waves.numChannels,~waves,rate:(48/44))*10)}.play
a.set(\ftime,20);

Env.asr(99,1,10).plot;
~waves_3m;
s.sampleRate;

