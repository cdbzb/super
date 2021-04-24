( //SETUP
~duration = {|from to| to.asFloat.asSeconds - from.asFloat.asSeconds};

~dotted = 	{ | dur |
	{ 
		Dust.ar(50) 
		=>Decay.ar(_,0.0001)
		=>TwoTube.ar(_,loss:0.8,d1length:rrand(20,30))
		=>MoogFF.ar(_,LFBrownNoise1.kr(2).range(4700,6000))
		=>Pan2.ar(_,0.5,0.7)
	}.play(s,0) .dur(dur)
};
~drawLine = {| start end | Reaper.sched(start, {~dotted.value(~duration.(start, end) )})};
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

~drawCircle = { |when, length, panL=(-1), panR=1|
	Reaper.sched(when,
		{
			{
				var index = Line.kr(0,2*pi,length,doneAction:2);
				Dust.ar(150)=>Decay.ar(_,0.02)=>OnePole.ar(_)
				* WhiteNoise.ar(1)=> 
				MoogFF.ar(_,[index.cos,index.sin]*300+500)
		=> {|i| i[0]=>Pan2.ar(_,panL)+i[1]=>Pan2.ar(_,panR)}
			}.play
		}
	)
	
};

)

(
Reaper.play(21,26);
Reaper.sched(23.52,{(note:(1,1.3..4),dur:3).play});
)

( // 318
var dustin = 318f:7;
Reaper.play(301,322);
//"~/tank/ROSY/sc/dustin.wav".record(1,2,Reaper.lastPlayLength)

Synths(\default,\freq,[1,3,5,7].df(\c),\amp,0.01).dur(5,9);
//house appear
~drawLine.(301+(13/24),303+(11/24));
~drawCircle.(303+(11/24),1+(19/24));
Reaper.sched(305+(6/24),{
	~bg= Synths(\stringyy,\freq,[300,575],\amp,0.10)
});
Reaper.sched(309+(3/24),{
	Synth(\default,[\freq,999]).dur(3)
});
Reaper.sched(312+(10/24),{
	Synth(\default,[\freq,999*15/16]).dur(3)
});
~drawLine.(309+(3/24),309+(17/24));
Reaper.sched(dustin,{
	Synths(\sparkTriangle,
		\freq,[1,3,5,7].df(\c),
		\amp,0.003
	)
});
// DUSTIN 318.07
	
)


( ///// FOUR houses
Reaper.play(429.5,446);
//"~/tank/ROSY/sc/Four.wav".record(1,2,Reaper.lastPlayLength)
Reaper.sched(430+(8/24),{
	{SinOsc.ar([ 300,400,500,600 ],0,0.02)=>Splay.ar(_)
	* Env.linen(0,1,9).kr(2,gate:1)
}.play
});
4.do{~drawLine.(433,434)};
Reaper.sched(434,{ {
	SinOsc.ar([ 300,400,500,600 ]*2+2,0,0.008) =>Splay.ar(_)
	* Env.linen(0,1,9).kr(2,gate:1)
}.play });
Reaper.sched(436,{(freq:750,dur:2,amp:0.05).play});
Reaper.sched(437+(8/24),{(freq:900,dur:2,amp:0.05).play});
~drawLine.(434.5,436)
)

(  ///Both Houses
//"~/tank/ROSY/sc/both.wav".record(1,2,Reaper.lastPlayLength)
var region = [1430,1450];
var width;
//Reaper.play(*region);
//extended section
Reaper.play(*(region+[-10,5]));
Reaper.sched( 1421f:9 ,{
	{SinOsc.ar(500,0,0.01)=>Pan2.ar(_,-1*width)}.play.dur(5,2)
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
	{[1,3,5,6].df(\c,octave:7)=>{|i|Synths(\default,\freq,i).dur(1,5)}});
Reaper.sched(1437+(6/24),
	{[1,3,5,6].df(\b,octave:6)=>{|i|Synths(\default,\freq,i).dur(1,5)}});
Reaper.sched(1441+(5/24),
	{[1,3,5,6].df(\a,octave:6)=>{|i|Synths(\default,\freq,i).dur(1,5)}});
)

(//Noir

//"~/tank/ROSY/sc/noir.wav".record(1,2,Reaper.lastPlayLength)
Reaper.play(1801+(2/24),1820);
~drawLine.(1802+(2/24),1803+(13/24));
Reaper.sched(1803+(14/24),{ (note:[1,4],octave:7,dur:7+(10/24),amp:0.01).play })
//1811+(1/24) -- OFF
)

(//suit

//"~/tank/ROSY/sc/suit.wav".record(1,2,Reaper.lastPlayLength)
Reaper.play(1121,1145);
Reaper.sched(1122,{
	~strings=Synths(\stringyy,
		\freq,[1,3,5,7].df(),
		\amp,0.00,
		\freqLag,2.0+(0.2.rand!4),
		\ampLag,18
	);
	fork{0.1.wait;~strings.set(\amp,0.05)}
});
Reaper.sched(1122,{ {
	SinOsc.ar([400,450,500,525],0,0.008)
	=>Splay.ar(_)
	* Env.linen(0,2,4).kr
}.play });
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
Reaper.sched(1135,{{
	SinOsc.ar([810,400]*16/15,0,0.004)
	=> Mix.ar(_) => Pan2.ar(_,0.3)
	* Env.linen(0.5,2,4).kr(2,gate:1)
	* 0
}.play});
Reaper.sched(1140,{
	~strings.set(\freq,[1,3,5,7].df(\b,octave:4))
})

)
( //suit2
Reaper.play(1141,1230);
~strings=Synths(\stringyy,\freq,[1,3,5,7].df(),\amp,0.05);
//"~/tank/ROSY/sc/suit2.wav".record(1,2,Reaper.lastPlayLength)
~drawLine.(1142,1143f:4);
~drawLine.(1143f:5,1143f:17);
~drawLine.(1150f:14,1151f:02);
Reaper.sched(1151f:02,{(note:9,octave:6,dur:5).play});
	//Reaper.play(1150,1230);
//"~/tank/ROSY/sc/suit3.wav".record(1,2,Reaper.lastPlayLength)
~drawLine.(1150f:14,1151f:02);
Reaper.sched(1151f:02,{(note:9,octave:6,dur:5).play});
~drawLine.(1152f:5,1152f:11);
~drawLine.(1152f:13,1152f:22);
Reaper.sched(1152f:23,{(note:9+7,octave:6,dur:5).play});
~drawLine.(1156f:17,1158f:13);
//Residence
//~drawLine.(1158f:17,1159f:19)
Reaper.sched(1158f:17,
	{
		{
			| lengthIn = 1.2, dur=5, lengthOut=3 |
			//var env = Line.kr(1.0,0,length);
			var env =  Env([1,0,0,1],[ lengthIn, dur, lengthOut ],curve:\sin).kr(2,gate:1);
			var saws = Saw.ar([1,3,5,11,12,13,16,22,24].df('e-',tuning:\pythagorean)+(LFBrownNoise1.kr(1)!7*8),0.01)=>Mix.ar(_);
			FFT(LocalBuf(1024),saws)
			//=> PV_BrickWall(_,SinOsc.ar(1).range(0.0,0.1))
			//=>PV_RandComb  (_,SinOsc.ar(0.2).unipolar)
			=>PV_RandComb  (_,env)
			=> IFFT(_)
			=> Splay.ar(_,spread:0.2,center:-0.6)
		}.play
	}
);
Reaper.sched(1207f:23,{~strings.release(2)});
Reaper.sched(1207f:23,{
	{
		SinOsc.ar([1,3,4,6].df(\a)+(LFBrownNoise2.kr(1)!4),0,0.005)
		+ PinkNoise.ar(0.02)
		=> MoogFF.ar(_,LFBrownNoise2.kr(0.5).range(600,2000))
		* Env.linen(0,1,8).kr(2,gate:1)
	}.play
});

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
