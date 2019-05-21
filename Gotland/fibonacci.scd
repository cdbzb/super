

(
~fibs={|num|
	var fibs=Array.newClear(num);
	var neww=3,old=2;
	fibs.do({|item index| fibs[index]=old;old=neww;neww=neww+fibs[index]});
	fibs;
};
)
~fibs.(20);

}
	SynthDef(\cloud, { arg fr=100, amp=1, num=8; var out;  
		fr = Lag.kr(fr,60);
		Out.ar(0,{
			Mix.arFill(8, //number of harmonics
			    { arg x  ; var sig, frq;
				frq=fr;
				//sig = FSinOsc.ar( frq*x ,0,0.01/(x+1) * LFNoise1.kr(18*LFNoise1.kr));//.distort;
				x=~fibs.(20).at(x);
				sig = FSinOsc.ar( frq*x ,0,0.01 * LFNoise1.kr(18*LFNoise1.kr)).distort;
				//sig = sig+SinOsc.ar( frq ,0,0.01 * LFNoise1.kr(18*LFNoise1.kr)).distort;
				sig = Pan2.ar(sig, LFNoise1.kr(1));
				sig= sig * EnvGen.kr(Env.linen(6,2,99),doneAction: 2);
				//sig=BHiShelf.ar(sig,1200,db: -10);
				sig*amp;
			})
		})}).add;

( //sparkle
	{
		~chord=NodeProxy.audio;
		~chord.source={SinOsc.ar([400,450,500,480,360]*0.5,0,0.007)};
		~chord.play(fadeTime:10);
		9.wait;
		//(\instrument: \cloud, \fr: 90).play;
		//9.wait;
		(\instrument: \cloud, \fr: [300,360], \amp: 0.1).play;
		6.wait;
		(\instrument: \cloud, \fr: [240,240*1.2], \amp: 0.17).play;
	}.fork;
)

~fibs.(8);
(
		(\instrument: \cloud, \fr: [40,45,48],\amp:0.2).play;
		(\instrument: \cloud, \fr: ~fibs.(8)*2,\amp:0.2).play;
		(\instrument: \cloud, \fr: ~fibs.(8)*30,\amp:0.2).play;
		(\instrument: \cloud, \fr: ~fibs.(8)*5,\amp:0.2).play;
		(\instrument: \cloud, \fr: [1,2,3,4,5,6,7,8],\amp:0.2).play;
		(\instrument: \cloud, \fr: [1,2,3,4,5,6,8]*4,\amp:0.2).play;
		(\instrument: \cloud, \fr: [1,2,3,4,5,6,8]*3,\amp:0.2).play;
		(\instrument: \cloud, \fr: [1,2,3,4,5,6,8]*4*1.2,\amp:0.2).play; //nice
		(\instrument: \cloud, \fr: [360,360*1.2], \amp: 0.17).play;
		(\instrument: \cloud, \fr: [270,270*1.2], \amp: 0.07).play;
		(\instrument: \cloud, \fr: [180,180*1.2], \amp: 0.07).play;
		s.meter;
	}.fork
)
(//alternate this and the one below for dreaminess
	[

		(\instrument: \cloud, \fr: [1,2,3,4,5,6,7,8],\amp:0.2),
		(\instrument: \cloud, \fr: [1,2,3,4,5,6,8]*4,\amp:0.2),
		(\instrument: \cloud, \fr: [1,2,3,4,5,6,8]*3,\amp:0.2),
		(\instrument: \cloud, \fr: [1,2,3,4,5,6,8]*4*1.2,\amp:0.2) //nice
	].choose.play;
)
(
	[

		(\instrument: \cloud, \fr: [4,5,6,7,8],\amp:0.2),
		(\instrument: \cloud, \fr: [4,5,6,7,8,9,10]*2,\amp:0.2),
		(\instrument: \cloud, \fr: [4,5,6,8,9,10]*3,\amp:0.2),
		(\instrument: \cloud, \fr: [4,5,6,8,9,10]*2*1.2,\amp:0.2) //nice
	].choose.play;
)
