( 
	//SETUP

~duration = {|from to| to.asFloat.asSeconds - from.asFloat.asSeconds};

~dotted = 	{ | dur, pan=0, amp=0.7|
	{ 
		Dust.ar(50) 
		=>Decay.ar(_,0.0001)
		=>TwoTube.ar(_,loss:0.8,d1length:rrand(20,30))
		=>MoogFF.ar(_,LFBrownNoise1.kr(2).range(4700,6000))
		=>Pan2.ar(_,pan,amp)
	}.play(s,0) .dur(dur)
};
~drawLine = {| start end pan=0 amp=0.7 | Reaper.sched(start, {~dotted.value(~duration.(start, end),pan,amp )})};
~record = { | name, length |
	g = Group.after(1);
	b = Buffer.alloc(s, 65536, 2);
	b.write("~/tank/Maura-PCS/SC".standardizePath +/+ name.asString, "wav", "int24", 0, 0, true);
	// create the diskout node; making sure it comes after the source
	d = Synth.tail(g, "diskout2", [\bufnum, b]);
	fork{ 
		length.wait ;
		d.free; 
	b.close;
	b.free;
	};
};

~circle = { | length, panL, panR | 
	{
		var index = Line.kr(0, 2*pi,length,doneAction:2);
		[index.sin,index.cos]
	}
};

~drawCircle = { |when, length, panL=(-1), panR=1, amp=1|
	Reaper.sched(when,
		{
			{
				var index = Line.kr(0,2*pi,length,doneAction:2);
				Dust.ar(150)=>Decay.ar(_,0.02)=>OnePole.ar(_)
				* WhiteNoise.ar(1)=> 
				MoogFF.ar(_,[index.cos,index.sin]*300+500)
		=> {|i| i[0]=>Pan2.ar(_,panL)+i[1]=>Pan2.ar(_,panR)}
		* amp
			}.play
		}
	)
	
};

		~blueJayWay = { |time=0, fadeIn=0,sustain=1, release=8, amp=0.1|
			Reaper.sched( time,
				{
					{
						SinOsc.ar([1,3,4,6].df(\a)+(LFBrownNoise2.kr(1)!4)/2,0,0.003)
						+ PinkNoise.ar(0.02)
						=> MoogFF.ar(_,LFBrownNoise2.kr(0.5).range(600,2000))
						* Env.linen(fadeIn,sustain,release).kr(2,gate:1)
						* amp * 10
					}.play
				}
			)
		}
);

(
Reaper.play(21,32);
Reaper.sched(23.52,{ 
	(type:\tuningGong,freq:1.df(),group:0).play 
});
//"~/tank/ROSY/sc/JessBond.wav".record(1,2,Reaper.lastPlayLength)
)

(
Reaper.play(14,18);
"~/tank/ROSY/sc/lonecircle.wav".version.record(1,2,Reaper.lastPlayLength);
//~drawCircle.(15f:19,17-( 15f:19 ),amp:0.2)
~drawLine.(15f:19,17);
)


( // 318
	var yohaiFace = 253f:19;
	var blueJayWay = 257f:03;
var dustin = 318f:7;
var genesis = 328f:02;
var million = [322f:23,323f:12];

Reaper.play(250,456);
"~/tank/ROSY/sc/dustin.wav".version.record(1,2,Reaper.lastPlayLength);

Reaper.sched(yohaiFace,{
	var synths = Synths(\sawSynthSustain,
		//[
		\freq,[1,5].df('e-',octave:3),
		\amp,0.02,
		\att,0.5

		//]
	).dur(1,6);
	fork{
		2.0.wait; 
		synths.synths[0].set(\freq, 2.df('e-',octave:3)) ;
		2.0.wait;
		synths.synths[1].set(\freq, 6.df('e-',octave:3)) 
	}
});

~blueJayWay.(blueJayWay,sustain:1,release:8,amp:0.2);
//Reaper.sched(blueJayWay,{ 
//		{
//		SinOsc.ar([1,3,4,6].df(\a)+(LFBrownNoise2.kr(1)!4)/2,0,0.003)
//		+ PinkNoise.ar(0.02)
//		=> MoogFF.ar(_,LFBrownNoise2.kr(0.5).range(600,2000))
//		* Env.linen(0,1,8).kr(2,gate:1)
//	}.play
//
//});


Reaper.sched(304f:1,{Synths(\default,\freq,[1,3,5,7].df(\c),\amp,0.01).dur(5,9);});
~drawLine.(301f:14,303+(11/24));
~drawCircle.(303+(11/24),1+(19/24),amp:0.2);
Reaper.sched(305+(6/24),{
	//~bg= Synths(\stringyy,\freq,[300,575],\amp,0.08).dur(3,8)
	~bg= Synths(\stringyy,\freq,[3,6,12].df(\c,tuning:\pythagorean),\amp,0.07).dur(4,40)
});
Reaper.sched(309+(3/24),{
	Synth(\default,[\freq,999,\out,Effect({|i|i*Line.kr(0,1,3)},out:[0,1]).bus.index]).dur(2,2)
});
Reaper.sched(312f:10 
	- s.latency,
	{
		var licklength = dustin-(312f:10);
		//Synth(\default,[\freq,999*12/16]).dur(1,6)
		[
			freq:[12/16,9/8,1,8/9].q*(1.df(\b,octave:6)),
			//dur:2.5
			dur:licklength/3,
			legato:1.2,
			amp:0.04,
			pan:Pseries(-0.5,0.2,4)
		].pp
	}
);
~drawLine.(309+(3/24),309+(17/24));
Reaper.sched(dustin,{
	Synths(\sparkTriangle,
		\freq,[1,3,5,7].df(\f),
		\out,[0,1],
		\amp,0.003,
		\pan,[-0.8,-0.2,0.2,0.8]
	).dur(3,3)
});
Reaper.sched(319f:17,{
	Synths(\sparkTriangle,
		\freq,[6,11,12].df(\f),
		\out,[0,1],
		\amp,0.003,
		\pan,[-0.8,-0.2,0.2,0.8]
	).dur(2,3)
});
~drawLine.(*million);
Reaper.sched(million[0]-0.2,{
	(type:\tuneUp,freq:640,amp:0.1,out:Effect(LPF.ar(_,700),out:1).bus).play

});
Reaper.sched(genesis,{
	Synth(\sawSynthSustain,[
		\freq,300,
		\amp,0.02,

	]).dur(1,6);
	(type:\tuneUp,freq:440,amp:0.1,out:Effect(LPF.ar(_,700),out:1).bus).play
});
~blueJayWay.(335f:6,sustain:2f:9,release:0.05);
~drawLine.(341f:4,342);
Reaper.sched(342, //house appear 
	{
		{ | lengthIn = 1.6, dur=15, lengthOut=8 |
			//var env =  Env([1,0,0,1],[ lengthIn, dur, lengthOut ],curve:\sin).kr(2,gate:1);
			var envIn = Env([1,0,0],[ lengthIn, dur + lengthOut ],curve:\sin).kr(2,gate:1);
			var envOut = Env([0.001,0,1],[ lengthIn + dur, lengthOut ],curve:\lin).kr(2,gate:1);
			var saws = Saw.ar(
				[1,3,5,11,12,13,16,22,24].df('e-',tuning:\pythagorean)
				+( LFBrownNoise1.kr(0.6!7) *7) ,0.01)
				=>Mix.ar(_);
			FFT(LocalBuf(2048),saws)
			=> PV_RandComb (_,envIn)
			=> PV_BrickWall(_,envOut*(-1))
			=> IFFT(_)
			=> Splay.ar(_,spread:0.4,center:-0.4)
			* Env([1,1,0.6,0.3,0.3],[3,1,5,2]).kr(0,gate:1)
		}.play
	}
);
//30 million
Reaper.sched(352f:1,
{
	(type:\tuningGong,freq:1.df('f'),channels:[0,1],amp:[0.01],sustain:1,time:4).play
}
);
//pigtail
~drawLine.(357f:23,400);
Reaper.sched(400,{
	Synth(\default,[\freq,666,\amp,0.06]).dur(0.1,3)
});
Reaper.sched(404f:2,{ //RS Lending
	Synth(\sawSynthSustain,[
		\freq,450,
		\amp,0.02,

	]).dur(1,6);
	(type:\tuneUp,freq:440,amp:0.1,out:Effect(LPF.ar(_,700),out:1).bus).play
});
~drawLine.(411f:19,412f:14);
~drawLine.(413f:16,414f:3);
Reaper.sched(414f:4,{
	(type:\tuningGong,amp:0.007,channels:[0,1],sustain:1,time:4).play;
	(note:1,dur:3).play
});
~drawLine.(416f:12,417f:1);
Reaper.sched(417f:2,{
	(type:\tuningGong,amp:0.007,channels:[0,1],sustain:1,time:4).play;
	(note:8,dur:3).play
});

 //)
 //( ///// FOUR houses
//Reaper.play(420.5,456);
~blueJayWay.(420f:21,sustain:2,release:1,amp:0.2);
//"~/tank/ROSY/sc/Four.wav".record(1,2,Reaper.lastPlayLength)
Reaper.sched(422f:21 ,{
	~four = Synths(\stringyy,\freq,[300,400,500,600]/2,\amp,0.05).dur(2,20)
}
);
Reaper.sched(430+(8/24),{
	~four.release(1);
	{SinOsc.ar([ 300,400,500,600 ],0,0.01)=>Splay.ar(_)
	* Env.linen(0.1	,1,9).kr(2,gate:1)
}.play
});
4.do{~drawLine.(433,434)};
Reaper.sched(434,{ {
	SinOsc.ar([ 300,400,500,600 ]*2+2,0,0.008) =>Splay.ar(_)
	* Env.linen(0,1,9).kr(2,gate:1)
}.play });
Reaper.sched(436-s.latency,{(freq:750,dur:2,amp:0.05).play});
Reaper.sched(437-s.latency+(8/24),{(freq:900,dur:2,amp:0.05).play});
~drawLine.(434.5,436);

//fly away!
Reaper.sched(438f:15,{
	{
		PinkNoise.ar(0.1)
		=> MoogFF.ar(_,
			LFBrownNoise2.kr([4,5,6,7,6,8]+20).range(800,4000)
		)
		* Env.perc(1,3).kr(0,gate:1)
		=> EchoCubic.ar(_,1,LFBrownNoise2.kr(1).range(0.5,0.9))
		=> Splay.ar(_)
		* 2

	}.play
});
)

(  ///Both Houses
var region = [1430,1450];
var width=0.7;
//Reaper.play(*region);
//extended section
Reaper.play(*(region+[-10,5]));
"~/tank/ROSY/sc/both.wav".version.record(1,2,Reaper.lastPlayLength);
Reaper.sched( 1421f:9 ,{
	{SinOsc.ar(500,0,0.01)=>Pan2.ar(_,(-1)*width)}.play.dur(5,2)
});
Reaper.sched( 1426f:8 ,{
	{SinOsc.ar(675,0,0.01)=>Pan2.ar(_,width)}.play.dur(1431f:3-(1426f:8),2)
});
Reaper.sched(1431f:3,{ 
	{
		SinOsc.ar([500+LFBrownNoise1.ar(15,mul:4),675+LFBrownNoise1.ar(15,mul:4)],0,0.01)
		=>Splay.ar(_,width)
		* Env.linen(0,1,10).kr(2,gate:1)
		//s.latency_(2)
	}.play 
});
~drawLine.(1431+(10/24),1432+(18/24));
Reaper.sched(1432+(19/24),
	{[1,3,5,6].df(\c,octave:7)=>{|i|Synths(\default,\amp,0.2,\freq,i,\out,Effect({|i|Zita.ar(i,i,mix:0.9) },out:[0,1]).bus.index).dur(1,5)}}
);                                                                
Reaper.sched(1437+(6/24),                                         
	{[1,3,5,6].df(\b,octave:6)=>{|i|Synths(\default,\amp,0.2,\freq,i,\out,Effect({|i|Zita.ar(i,i,mix:0.9) },out:[0,1]).bus.index).dur(1,5)}});
Reaper.sched(1441+(5/24),                                         
	{[1,3,5,6].df(\a,octave:6)=>{|i|Synths(\default,\amp,0.2,\freq,i,\out,Effect({|i|Zita.ar(i,i,mix:0.9) },out:[0,1]).bus.index).dur(1,5)}});
)

(//Noir

Reaper.play(1801+(2/24),1820);
//"~/tank/ROSY/sc/noir.wav".record(1,2,Reaper.lastPlayLength);
~drawLine.(1802+(2/24),1803+(13/24));
Reaper.sched(1803+(14/24),{ (note:[1,4],octave:7,dur:7+(10/24),amp:0.01).play })
//1811+(1/24) -- OFF
)

(//suit

//Reaper.play(1112,1155);
Reaper.play(1112,1230);
"~/tank/ROSY/sc/suit.wav".version.record(1,2,Reaper.lastPlayLength);
//Reaper.sched(1122,{
//	~strings=Synths(\stringyy,
//		\freq,[1,3,5,7].df(),
//		\amp,0.00,
//		\freqLag,2.0+(0.2.rand!4),
//		\ampLag,18
//	);
//	fork{0.1.wait;~strings.set(\amp,0.05)}
//});

//Reaper.sched(1122,{ {
Reaper.sched(1117,{ {
	SinOsc.ar(
	//	[400,450,500,525]
		[1,3,5,7].df()
		,0,0.008)
	=>Splay.ar(_)
	* Env.linen(1,4,4).kr
}.play });
Reaper.sched(1122, {
//	Synths(\sawSynthSustain,\freq,[1,3,5,7].df(),\att,0,\amp,0.01,\rel,10).dur(4,19)
{
	SinOsc.ar(
	//	[1,3,5,7].df()
		[400,450,500,525]
	)
	* Env.linen(0,4,19).kr(2,gate:1)
	* 0.01
}.play
});
Reaper.sched(1126,{ {
	SinOsc.ar([600,605],0,0.008)
	=>Splay.ar(_)
	* Env.linen(0,2,4).kr
}.play });
Reaper.sched(1131f:1,{{
	SinOsc.ar([910,900],0,0.005)
	=> Mix.ar(_) => Pan2.ar(_,-0.5)
	* Env.linen(0,2,4).kr(2,gate:1)
}.play});
Reaper.sched(1135,{
	{
	SinOsc.ar([455,450,675]*16/15,0,0.004)
	=> Mix.ar(_) => Pan2.ar(_,0.3)
	* Env.linen(0.5,2,4).kr(2,gate:1)
	* 1
}.play;
Reaper.sched( 1135,
//(freq:[1,3,5,7].df()*4/5,instrument:\stringyy,attack:5,dur:6,amp:0.05).play
~strings=Synths(\stringyy,\freqLag,1,\freq,[1,3,5,7].df(\a,octave:4),\attack,5,\dur,6,\amp,0.05)
)
});
Reaper.sched(1140,{
	~strings.set(\freq,[1,3,5,7].df(\b,octave:4))
});


 //suit2
//Reaper.play(1140,1230);
//Reaper.play(1150,1230);
//"~/tank/ROSY/sc/suit2.wav".version.record(1,2,Reaper.lastPlayLength);
//Reaper.sched( 1143f:17,
//	{
//		~strings=Synths(\stringyy,\freq,[1,3,5,7].df(\b,octave:4),\amp,0.05);
//	}
//);
~drawLine.(1142,1143f:4);
~drawLine.(1143f:5,1143f:17);
~drawLine.(1150f:14,1151f:02);
//Reaper.sched(1151f:02,{(note:9-1,octave:6,dur:5).play});
	//Reaper.play(1150,1230);
//"~/tank/ROSY/sc/suit3.wav".record(1,2,Reaper.lastPlayLength)
~drawLine.(1150f:14,1151f:02);
Reaper.sched(1151f:04 -s.latency,{(note:9-1,octave:6,dur:5,rel:5,amp:0.03).play});
~drawLine.(1152f:5,1152f:11);
~drawLine.(1152f:13,1152f:22);
Reaper.sched(1152f:23,{(note:9+7-1,octave:6,dur:5,amp:0.05).play});
Reaper.sched( 1151f:04 -s.latency,{
	(type:\tuneUp,freq:400,amp:0.1,out:Effect(LPF.ar(_,500),out:1).bus).play
});
~drawLine.(1156f:17,1158f:13);
//Residence
//~drawLine.(1158f:17,1159f:19)
Reaper.sched(1158f:17, {    //house appear
		{
			| lengthIn = 1.2, dur=5, lengthOut=3 |
			//var env = Line.kr(1.0,0,length);
			var env =  Env([1,0,0,1],[ lengthIn, dur, lengthOut ],curve:\sin).kr(2,gate:1);
			var saws = Saw.ar([1,3,5,11,12,13,16,22,24].df('e',tuning:\pythagorean)+(LFBrownNoise1.kr(1)!7*8),0.01)=>Mix.ar(_);
			FFT(LocalBuf(1024),saws)
			//=> PV_BrickWall(_,SinOsc.ar(1).range(0.0,0.1))
			//=>PV_RandComb  (_,SinOsc.ar(0.2).unipolar)
			=>PV_RandComb  (_,env)
			=> IFFT(_)
			=> Splay.ar(_,spread:0.2,center:-0.6)
			* 0.8
		}.play
});
Reaper.sched(1207f:23,{~strings.release(2)});
Reaper.sched(1207f:23,{
	{
		SinOsc.ar([1,3,4,6].df('f#')+(LFBrownNoise2.kr(1)!4),0,0.005)
		+ PinkNoise.ar(0.02)
		=> MoogFF.ar(_,LFBrownNoise2.kr(0.5).range(600,2000))
		* Env.linen(0,1,8).kr(2,gate:1)
	}.play
});

~drawLine.(1213f:10,1213f:19)
)

(
Reaper.play(1000,1010);
~drawCircle.(1001,1)
)

(
~houseFade={
	| lengthIn = 4, dur=2, lengthOut=3 |
	//var env = Line.kr(1.0,0,length);
	var env =  Env([1,0,0,1],[ lengthIn, dur, lengthOut ],curve:\sin).kr(2,gate:1);
	var saws = Saw.ar([1,3,5,11,12,13,16].df(\c,tuning:\pythagorean)+(LFBrownNoise1.kr(1)!7*8),0.05)=>Mix.ar(_);
	FFT(LocalBuf(1024),saws)
	//=> PV_BrickWall(_,SinOsc.ar(1).range(0.0,0.1))
	//=>PV_RandComb  (_,SinOsc.ar(0.2).unipolar)
	=>PV_RandComb  (_,env)
	=> IFFT(_)
	=> Splay.ar(_,spread:0.2,center:-0.6)
}.play
)

