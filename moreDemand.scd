(
fork{
	4.do{
		{
			var vol = [0.01,0.3,3].dq(inf) => Demand.kr(Impulse.kr(1),1,_);
			var env = Env.perc(0.01,1,1,level:vol).kr(0,gate:TDuty.kr([1,0.3].dq(inf)));
			var freq= [ [400,500,800,600,300].dq(inf),1,0 ].duty;
			SinOsc.ar(freq*[0.5,0.666,0.75,1,1.25,1.5].choose)*env
			=>Pan2.ar(_,[0,1,-1].choose) /10
			=> _.distort => DWGReverbC1C3.ar(_,400,mix:0.05) => _.distort
		}.play;
		1.0.wait
	}
}
)
(

{ 
	var dur = [0.2,1,0.3,0.5,0.1].dq(inf);
	var freq = [
		[1,2,3,5,12,5,3,2].df(tuning:\sept7) + Rand(-12,24) / [ 1,2,4 ].choose => _.dq(inf),
		dur,
		1
	].duty;
	Saw.ar(freq,0.1) 
	=> MoogFF.ar(
		_,
	Demand.ar( Dust.ar(300),1,[1000,800,8000,200,400,600,7000].dq(inf))
		=> Lag.ar(_,LFBrownNoise1.kr(1).unipolar), 
		SinOsc.ar(0.2).range(1,3) 
	)
	=> {|i| [i, CombC.ar(i,0.4,LFBrownNoise2.kr(0.11).range(0.1,0.4),5)]}
}.play
)
(
{
	Dswitch1.new([SinOsc.ar(300,0,0.1),Pulse.ar(333,0.1,0.1)],  [0,1].dq(inf))
	=> Demand.ar( Impulse.ar(1),0,_)
	//=> Demand.ar( Impulse.ar(SinOsc.ar(0.1).range(0.5,250)),1,_)
}.play
)

(
{ 

	SinOsc.ar(Demand.kr(Impulse.kr(1),1,[[100,120,130,550*10/9,150,876].dq(inf),[710,222,225,229,550].dq(inf),0,0.1])) 
	=> CombC.ar(_,1,LFBrownNoise2.kr(0.1).range(0.800,0.900),10)
}.play
)
(

	{
		var freq = DemandEnvGen.ar([0.1,1].dq(inf),[1,0.1,0.5].dq(inf),gate:1,timeScale:0.004);
		//var freq = 1;
		SinOsc.ar(300+freq,0,freq)
		//=> MoogFF.ar(_, LFBrownNoise2(0.1).range(800,8000),2)
	}.play



)

(
(
	freq: [1,3,5,4,3,4,2,3],
	dur: [2,1,1,2,1,1,1]
)
=> {|e| 
	[ e.freq.dq,e.dur.dq ].duty
	=> SinOsc.ar(_,0,0.1)
}.play
)
( //simple typing

{
	[ 
		[1.9, 3, 5, 4, 3, 4, 2, 3].dq(inf) * 100, //freq
		[2,   1, 1, 2, 1, 1, 1].dq(inf) /2,
		1
	].duty => SinOsc.ar(_,0,0.1) 
}.play
)
(

8.do{ {
	var dur = [2,1,1,3,0.1,0.1,0.1]/4 * rrand(3.0,5);
	var freq = [ 
		[1.66, 3.33, 5, 4, 3, 4, 2].dq(inf) * 100 * rrand(3,5) / 3, 
		dur.dq(inf),
		1
	].duty;
	var amp = DemandEnvGen.kr (
		[0,1,0].dq(1),
		dur.parse([ 3,4 ]).dq(1),
		doneAction:2
	);
	Saw.ar(freq/2,0.1) 
	=> MoogFF.ar(_,amp*2000+00,3) 
	=> Pan2.ar(_,[-1,0,1].choose)
}.play
 }
 )
 (
8.do{ { 
	var dur = [2,1,1,3,0.1,0.1,0.1]/4 * rrand(3.0,5);
	{
		|freq amp|
		Saw.ar(freq/2,0.1) 
		=> MoogFF.ar(_,amp*2000+00,3) 
		=> Pan2.ar(_,[-1,0,1].choose)
	}.(
		freq: [ 
			[1.66, 3.33, 5, 4, 3, 4, 2].dq(inf) * 100 * rrand(3,5) / 3, 
			dur.dq(inf),
			1
		].duty,
		amp: Env([0,1,0],dur.parse([3,4])).kr(2,gate:1)
	)
}.play
 }
 )


 (
	 //var voices = 4.collect{|i| 4.collect{ |j| ( j==i ).if{1}{0}}};
	 var voices = Array.fill2D(10,10,{|i j| ( i==j ).if{1}{-1}});
	 {
		 {
			 |gate release|
			 //var freq = { 400.rand }!4;
			 var freq = [1,2,3,1,4,3,2,1,1,-7].df(\e);
			 Pulse.ar(freq,0.2,0.1) * Env.perc(0.01,release).kr(0,gate:gate)
			 => Splay.ar(_)
			 => FreeVerb.ar(_,0.4,1)
			 => Phaser2.ar(_,rate:Line.kr(0.01,0.5,3))
			 * Env.linen(0,10,10).kr(2,gate:1)
		 }.(
			 gate: TDuty.kr([ 1,1,1,1,1,1,1,1,2,2 ].dq(inf)/4,0,voices.dq(inf)),
			 release: [ Dseries(1,4,inf),0.11,1 ].duty
		 )
	 }.play

 )
 
 /*
Voicer(b);=> { var triggers = Array.fill2D(b.size,b.size,{|i j| i==j.if{1}{-1}}); Tduty.kr(b,0,triggers.dq) }
*/
(
var durs = [1,2,1,1,2,1,3,2]/3;
{
	{ | gate=1 tune |
		[
			Saw.ar(tune +.t [0,1,3.31],0.1)
			* Env.perc().kr(0,gate:gate)
			=> Splay.ar(_,SinOsc.ar(30).unipolar)
	=> {|i| [i ++ EchoNone.ar(i,0.300,0.300,4)/2]} //=>Splay.ar(_);

		]

	}.(

		tune: [1,3,5,1,4,6,5,4].df(\e,scale:\major,tuning:\sept7),
		gate: TDuty.fromDurs(durs,inf) - 0.5
	)
}.play;
{
	TDuty.kr([2,1,3,2].dq(inf)/3,1,1) => { |i| var env = Env.perc(0.01,0.5).kr(0,gate:i); env * WhiteNoise.ar(0.1) =>
	MoogFF.ar(_,env*4000+200,1)
	//=> CombC.ar(_,0.500,[0.6, 0.450 ],9)
} 
}.play;
{
	TDuty.kr(1/3,1,1) 
	=> { |i| 
		[[1,1,1,1,1,1,2,3,4,4,4,4,4,4,5,6].df(\e,octave:3).dq(inf), 1/3,0].duty 
		=> { |i| Saw.ar(i * [0.99,1,1.013],0.1)/2  } 
		* Env.perc().kr(0,gate:i)
		=> Pan2.ar(_,0)
		=> Splay.ar(_,0.5)
		
		}
}.play
)
