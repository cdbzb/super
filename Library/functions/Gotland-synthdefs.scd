(
~fibs={|num|
	var fibs=Array.newClear(num);
	var neww=3,old=2;
	fibs.do({|item index| fibs[index]=old;old=neww;neww=neww+fibs[index]});
	fibs;
};

	SynthDef(\fibs, { arg fr=100, amp=1, num=8; var out;  
		fr = Lag.kr(fr,60);
		Out.ar(1,{
			Mix.arFill(8, //number of harmonics
			    { arg x  ; var sig, frq;
				frq=fr;
				x=~fibs.(20).at(x);
				sig = FSinOsc.ar( frq*x ,0,0.01 * LFNoise1.kr(18*LFNoise1.kr)).distort;
				sig = Pan2.ar(sig, LFNoise1.kr(1));
				sig= sig * EnvGen.kr(Env.linen(6,2,99),doneAction: 2);
				sig*amp;
			})
		})}).add;
	
//original demo idea
	SynthDef(\cloud, { arg fr=100, amp=1; var out;  
		fr = Lag.kr(fr,60);
		Out.ar(0,{
			Mix.arFill(20, //number of harmonics
			    { arg x  ; var sig, frq;
				frq=fr;
				//sig = FSinOsc.ar( frq*x ,0,0.01/(x+1) * LFNoise1.kr(18*LFNoise1.kr));//.distort;
				sig = FSinOsc.ar( frq*x ,0,0.01 * LFNoise1.kr(18*LFNoise1.kr));//.distort;
				sig = sig+SinOsc.ar( frq ,0,0.01 * LFNoise1.kr(18*LFNoise1.kr));//.distort;
				sig = Pan2.ar(sig, LFNoise1.kr(1));
				sig= sig * EnvGen.kr(Env.linen(6,2,99),doneAction: 2);
				//sig=BHiShelf.ar(sig,1200,db: -10);
				sig*amp;
			})
		})}).add;
)
