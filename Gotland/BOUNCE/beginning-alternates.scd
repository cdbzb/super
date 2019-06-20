
	(\instrument: \fibs_less, \fr: [4,4.5,5,6,8,9,10]*2*1.2,\amp:0.2).play;
	~prepme={|num| s.prepareForRecord("/Users/michael/tank/THE FUTURE/SC-bounces/sparser-fib-tops"++num.asString++".aif")};

	(
		{
			5.do{ |i|
				~prepme.(i);
				s.sync;
				s.record(duration:90);
				a=(\instrument: \fibs_less, \fr: [4,4.5,5,6,8,9,10]*2*1.2,\amp:0.2).play;
				91.wait;
				a.free;
				1.wait;
			}
		}.fork
	)
	(\instrument: \fibs, \fr: [4,6,9,10]*2*1.2,\amp:0.2).play;
	(\instrument: \fibs_less, \fr: [4,9,10]*2*1.2,\amp:0.9).play;
	(\instrument: \fibs, \fr: [4,9,10]*2*1.2,\amp:0.9).play;
	(\instrument: \fibs, \fr: [5,9,10]*2*1.2,\amp:0.2).play;
	(\instrument: \fibs, \fr: [5,8,10]*2*1.2,\amp:0.2).play;
	(\instrument: \fibs, \fr: [4,6]*2*1.2,\amp:0.8).play;
	(\instrument: \fibs, \fr: [4,6]*2,\amp:0.8).play;
	s.boot;
	(\instrument: \cloud_staggered,\fr: [240,288,300,360], amp:0.5).play


	(
		SynthDef(\fibs_less, { arg fr=100, amp=1, num=8, bus=0; var out;  
			fr = Lag.kr(fr,60);
			Out.ar(bus,{
				Mix.arFill(8, //number of harmonics
					{ arg x  ; var sig, frq;
						frq=fr;
						x=~fibs.(20).at(x);
						sig = FSinOsc.ar( frq*x ,0,0.01 * LFNoise1.kr(18*LFNoise1.kr)).distort;
						sig = Pan2.ar(sig, LFNoise1.kr(1));
						//sig= sig * EnvGen.kr(Env.linen(6,2,99),doneAction: 2);
						sig*amp*IRand(0,1);
					})
				})}).add;
			)


