
(
	SynthDef(\cloud_staggered, { arg fr=100, amp=1; var out;  
		fr = Lag.kr(fr,60);
		Out.ar(0,{
			Mix.arFill(20, //number of harmonics
				{ arg x  ; var sig, frq;
					frq=fr;
					//sig = FSinOsc.ar( frq*x ,0,0.01/(x+1) * LFNoise1.kr(18*LFNoise1.kr));//.distort;
					sig = FSinOsc.ar( frq*(x+1) ,0,0.01 * LFNoise1.kr(18*LFNoise1.kr));//.distort;
					//sig = sig+SinOsc.ar( frq ,0,0.01 * LFNoise1.kr(18*LFNoise1.kr));//.distort;
					sig= sig * EnvGen.kr(Env([0,0,1,0],[Rand(4,50),Rand(10),99]),doneAction:2)*LinRand(0,1,-10);
					sig = Pan2.ar(sig, LFNoise1.kr(1));
					//sig= sig * EnvGen.kr(Env.linen(Rand(6,12),2,99),doneAction: 2);
					//sig=BHiShelf.ar(sig,1200,db: -10);
					sig*amp;
				})
			})}).add;

		)

		(
			Synth.new(\cloud_staggered,[\fr,[240*1.2]]);
			Synth.new(\cloud_staggered,[\fr,[240]]);
			Synth.new(\cloud_staggered,[\fr,[300]]);
			Synth.new(\cloud_staggered,[\fr,[360]]);
		)
