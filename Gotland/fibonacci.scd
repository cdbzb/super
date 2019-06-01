

(
~fibs={|num|
	var fibs=Array.newClear(num);
	var neww=3,old=2;
	fibs.do({|item index| fibs[index]=old;old=neww;neww=neww+fibs[index]});
	fibs;
};
)
~fibs.(20);
(

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

( //sparkle
	{
		~chord=NodeProxy.audio;
		~chord.source={SinOsc.ar([400,450,500,480,360]*0.5,0,0.007)};
		~chord.play(fadeTime:10);
		9.wait;
		//(\instrument: \fibs, \fr: 90).play;
		//9.wait;
		(\instrument: \clouds, \fr: [300,360], \amp: 0.1).play;
		6.wait;
		(\instrument: \clouds, \fr: [240,240*1.2], \amp: 0.17).play;
		9.wait;
		~chord.stop;
	}.fork;
)

~fibs.(8);
(
		(\instrument: \fibs, \fr: [40,45,48],\amp:0.2).play;
		(\instrument: \fibs, \fr: ~fibs.(8)*2,\amp:0.2).play;
		(\instrument: \fibs, \fr: ~fibs.(8)*30,\amp:0.2).play;
		(\instrument: \fibs, \fr: ~fibs.(8)*5,\amp:0.2).play;
		(\instrument: \fibs, \fr: [1,2,3,4,5,6,7,8],\amp:0.2).play;
		(\instrument: \fibs, \fr: [1,2,3,4,5,6,8]*4,\amp:0.2).play;
		(\instrument: \fibs, \fr: [1,2,3,4,5,6,8]*3,\amp:0.2).play;
		(\instrument: \fibs, \fr: [1,2,3,4,5,6,8]*4*1.2,\amp:0.2).play; //nice
		(\instrument: \fibs, \fr: [360,360*1.2], \amp: 0.17).play;
		(\instrument: \fibs, \fr: [270,270*1.2], \amp: 0.07).play;
		(\instrument: \fibs, \fr: [180,180*1.2], \amp: 0.07).play;
		s.meter;
	}.fork
)
(//alternate this and the one below for dreaminess
	[

		(\instrument: \fibs, \fr: [1,2,3,4,5,6,7,8],\amp:0.2),
		(\instrument: \fibs, \fr: [1,2,3,4,5,6,8]*4,\amp:0.2),
		(\instrument: \fibs, \fr: [1,2,3,4,5,6,8]*3,\amp:0.2),
		(\instrument: \fibs, \fr: [1,2,3,4,5,6,8]*4*1.2,\amp:0.2) //nice
	].choose.play;
)
(
	[
		(\instrument: \fibs, \fr: [4,5,6,7,8],\amp:0.2),
		(\instrument: \fibs, \fr: [4,5,6,7,8,9,10]*2,\amp:0.2),
		(\instrument: \fibs, \fr: [4,5,6,8,9,10]*3,\amp:0.2),
		(\instrument: \fibs, \fr: [4,5,6,8,9,10]*2*1.2,\amp:0.2) //nice
	].choose.play;
)

(
	~rands=Array.newClear(20).collect({linrand(20)});
	~rands=~rands.collect({linrand(20)});

)

(
	~random=NodeProxy.audio;
	~random.fadeTime=6;
	~random.source={|freq=40 num=20| var sig= Mix.arFill(20, { SinOsc.ar(ExpRand(100,4000),0,0.003);	});sig;  }
	~random.source={|freq=40 num=20| var sig= Mix.arFill(19, { SinOsc.ar(LinRand(100,4000),0,0.003);	});sig;  }
	~random.source={|freq=40 num=20| var sig= Mix.arFill(20, { SinOsc.ar(LinRand(100,4000),0,0.003);	});sig;  }
	~random.source={|freq=40 num=20| var sig= Mix.arFill(20, { SinOsc.ar(LinRand(200,2000)*LFNoise1.ar(18*LFNoise1.ar*LFNoise1.ar),0,0.003)*LFNoise1.kr(18*LFNoise1.kr).distort;});sig; }
	~random.play(1,fadeTime:8);
	~random.stop;
	~random.play;
)

(
	SynthDef(\random,{|freq=40 num=20|
		var sig= Mix.arFill(20, {
			SinOsc.ar(LinRand(100,4000),0,0.01);	
		});
		Out.ar(1,sig);
	}).add;
Synth.new(\random);
)
{Saw.ar(110).rand }.plot;
~random.();
a=ExpRand(10);
Synth.new(\random,[\freq,10]);

x= all {: x, x<-(10..30), x.isPrime};
x.do{|i| SinOsc.ar(i,0,0.1)}.play;
a={Mix.ar(SinOsc.ar(x*x,0,0.005*EnvGen.kr(Env.asr(5,1,10))))}.play(s,1);
a={Mix.ar(SinOsc.ar(x*x*1.25,0,0.005*EnvGen.kr(Env.asr(5,1,10))))}.play(s,1);
a={Mix.ar(SinOsc.ar(x*x*1.2,0,0.005*EnvGen.kr(Env.asr(5,1,10))))}.play(s,1);
a={Mix.ar(SinOsc.ar(x*x*1.25*1.2,0,0.005*EnvGen.kr(Env.asr(5,1,10))))}.play(s,1);
a={Mix.ar(SinOsc.ar(x*24*1.2,0,0.005*EnvGen.kr(Env.asr(5,1,10))))}.play(s,1);
b={Mix.ar(SinOsc.ar(x*30*1.2,0,0.005*EnvGen.kr(Env.asr(5,1,10))))}.play(s,1);
b={Mix.ar(SinOsc.ar(x*30,0,0.005*EnvGen.kr(Env.asr(5,1,10))))}.play(s,1);
a.release;
b.release;
	(\instrument: \cloud, \fr: x*20.rand,\amp:0.2).play;
	(\instrument: \cloud, \fr: x*x,\amp:0.2).play;//shimmer
	(\instrument: \fibs, \fr: x*x,\amp:0.2).play;
	(\instrument: \fibs, \fr: x*12,\amp:0.2).play;
	(\instrument: \fibs, \fr: x*x*0.2,\amp:0.2).play;//shimmer
	(\instrument: \fibs, \fr: x*x*0.4,\amp:0.2).play;//shimmer
	(\instrument: \fibs, \fr: x*9*1.2,\amp:0.2).play;
	(\instrument: \fibs, \fr: x*9*1.25,\amp:0.2).play;//not bad
	///// make one inst for fibs and one for just harmonics whatever
	// choose ranges of prime harmonics on related roots
	// reafir picking up burbling of sea
b={Mix.ar(SinOsc.ar(x*75,0,0.005*EnvGen.kr(Env.asr(5,1,10))))}.play(s,1);
[x,x].allTuples.do{y=};
Array
b={Mix.ar(SinOsc.ar(x*75*1.2,0,0.0005*EnvGen.kr(Env.asr(5,1,10))))}.play(s,1);
{Mix.ar(SinOsc.ar(x*60,0,0.005))}.play(s,1);
x.do{|i| i.postln;};
{SinOsc.ar(300,0,0.01)}.play;
{PinkNoise.ar(0.01)}.play;
x
s.plotTree;
s.reboot;
(
SynthDef(\primes,{|freq=40 num=20|








		var sig= Mix.arFill(20, {
			SinOsc.ar(LinRand(100,4000),0,0.01);	
		});
		Out.ar(1,sig);
	}).add;

)

(
	x.do({|item| (\instrument: \cloud, \fr: x*item,\amp:0.1).play});

)

~fewPrimes=all {:x,x<-(100..360),x.isPrime};

(
	2.do{
		var nn,uu,tt=~fewPrimes.choose;
		tt=tt*[5,6,7,8,9]*0.3;//*0.2;
		uu=tt*1.2;
		nn=LFNoise1.kr(18*LFNoise1.kr(1));
		{Mix.ar(SinOsc.ar(tt,0,0.01*LFNoise1.kr(18*LFNoise1.kr)))}.play(s,1);
		//{Mix.ar(SinOsc.ar(uu,0,0.001))}.play(s,1);
	}
)

3*[3,5,7];
