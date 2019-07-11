
~names.(~ice);
{ PlayBuf.ar(1,~ice[19]) }.play(s,~speakers[2]);

//4-EDM
//5,6,7-Market Phrases
(
	~noiseFu={ | bufs reps=200 rateMin=0.1 rateMax=2.5 amp=0.2 ampVar=1 density=1 group |
		var indices=Array.series(bufs.size);
		indices = Pxrand(indices,inf).asStream;
		{
			reps.do{ |i|
				var rate = (i>8).if({rrand(rateMin,rateMax)},{rrand(0.9,1.1)});
				var num=indices.next; 
				(num==7).if{rate=1}; //don't speed up market phrase if it happens
				//(num==4).if{rate==1}; //don't speed up edm if it happens
				(i<25).if{(num==4).if{num=indices.next}}; //no EDM before 10th item
				{PlayBuf.ar(4,bufs[num],rate:rate,doneAction:2)*(rrand( amp*ampVar , amp/ampVar)) }
					.play(group,~speakersz.index+(8.rand));
				([1.0.rand,1.0.rand,0.2,2].choose*1/density).wait;
				i.postln;
				num.postln;
			}
		}.fork;
	};
)

		~fu_play={~fu_monitor.playN(~speakers.scramble.wrapExtend(12),1,~speakersz.index+(0..11))};
		~fu_play.();
		~speakers.scramble.wrapExtend(12);
~speakersz.free;
~speakersz=Bus.audio(s,12);
~speakersz.index;
s.options.numOutputBusChannels;
s.options.numOutputBusChannels=18;
Server.

( //// noise-fu loop
	{
		var group=Group.new;
		~fu_play.();
		5.do{|i| 
			s.prepareForRecord("/Users/michael/tank/SchaferHouse/new-noise-fu"++i.asString++".aif",numChannels:8);
			s.sync;
			s.record(bus:~speakers[0],duration:240);
			s.sync;
			~noiseFu.(~ice,group:group);
		//~fu.(~ice,136,density:2,amp:0.33,ampVar:1.1);
			250.wait;
			group.freeAll();
			1.wait;
		}
	}.fork;
)
