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
	MoogFF.ar( _, env * 4000 + 200,1)
	//=> CombC.ar(_,0.500,[0.6, 0.450 ],9)
} 
}.play;
{
	var dur = Impulse.kr(3);
		[1,1,1,1,1,1,2,3,4,4,4,4,4,4,5,6].df(\e,octave:3).dq(inf).duty(1/3) 
		=> { |i| Saw.ar(i * [0.99,1,1.013],0.1)/1.5  } 
		* Env.perc().kr(0,gate:dur)
		*  [1,0.9,1,1].dq(inf).duty(1/3)
		=> Pan2.ar(_,0)
		=> Splay.ar(_,0.5)
		
}.play
)
(
	{
		4.collect{
			Dbrown(300,800,5,inf).duty(Dwhite(0.01,0.5,inf)) =>
			Lag.kr(_,0.5)
			=> { |i| Saw.ar(i * [0.95,1] ,0.1) }  => Mix.ar(_)
			=> MoogFF.ar(_,
				Dbrown(400,6600,5000,inf).duty(Dwhite(0.05,1,inf)) 
				//=> Lag.kr(_,0.5)
				, 3
			)
		}
		=> Splay.ar(_)
		* Env.linen(1,20,10).kr(2,gate:1)
	}.play
)
(
{
	[1,3,5,4,3,4,2,3] +.t [0,2] =>_.df(\e)=>_.dq(inf)
	=>_.duty([1,0.7]/3=>_.dq(inf)) 
	=> { |i|Saw.ar(i ,0.1) } => Splay.ar(_)
	* Env.triangle(1.3/3).kr(0,gate:TDuty.kr(1.7/3+Dwhite(-0.1,0.1,inf)))
	//* DemandEnvGen.kr([0,1].dq(inf),Dwhite(1,1.6,inf),gate:Impulse.ar(1.7/3)-0.5)
}.play	
)
(
{
	var dur = [3,2,2,3,1,2,3,3]; 
	var length = Env.linen(0,dur.sum,8).kr(2,gate:1);
	var vibrato = SinOsc.kr( 
		Drand([5,7.0],inf).duty(dur.dq).lag(0.1), 0, //rate
		Dwhite(0,3).duty(dur.dq) ** 2 		     //width
	) * 4;
	var freq = ( [300,400,500,670,600,400,555,500]*[1,1.2,1.25,1.5].choose ).dq.duty(dur.dq);
	var amp= Env( [0.1,0.2,0.1],dur.parse([3,4,1]) ).kr(0,gate:1);

	var cutoff =  Env([600,5000,400,500]+500,dur.parse([2,2,2,2])).kr(0,gate:1);
	Impulse.ar(freq.lag(1)+ vibrato + [0,SinOsc.ar(0.6),LFBrownNoise1.kr(1).range(-2,2)],amp) 
	=> MoogFF.ar(
		_, 
		cutoff,
		2.5
	) 
		=>Splay.ar(_)
		*length
		=>EchoNone.ar(_,0.400,0.222,4)
}.play;
{
      var dur = [3,2,2,3,1,2,3,3]; 
      var length = Env.linen(0,dur.sum,8).kr(2,gate:1);
	var freq = [300, 400,  600].dq.duty(dur.parse([2,3,2]).dq(inf));
	var width= [0.1,0.2,0.5].dq.duty(dur.parse([2,3,2]).dq(inf));
	Pulse.ar(freq,width,0.5)
	=>Mix.ar(_)
	=>Pan2.ar(_,[ -1,1 ].dq.duty(dur.dq),0.05)
	* length
}.play	;
)
(
{ 
	var freq = [1,3,5,4,3,4,2,3].df(\c,octave:rrand(3,7)).dq(inf).duty([0.7,0.1,0.5]*[1,2,5].choose =>_.dq(inf)); 
	//freq=400;
	Gendy1.arWidth(
		freq:freq.lag(0.05),
		width: Line.kr(1.015,1.02,20)
	) 
	+ Gendy2.arWidth(
		freq:freq.lag(0.05),
		width:1.2
	) 
	*  Env.linen(4,0.1,4).kr(0,gate:1) 
	=> Splay.ar(_) 
	=> PlateReverb.ar(_,10,mix:0.5) 
	* Env.linen(0,12,4).kr(2,1) *0.1 
	=> LeakDC.ar(_)}.play
)

( // cool sizzle chord


var chord = { 
	|freqScale|
	{
		[WhiteNoise.ar(0.1),Saw.ar(LFBrownNoise1.ar(1).range(300,600),0.1),Gendy1.arWidth(freq:40)*0.1]
		=> SelectXFocus.ar( Env([0,2,10,0],[3,3,20]).kr(0,gate:1),_,2,true)
		=> { |i|Impulse.ar(i * 1009 + ([200,400,500,250]* freqScale),0,0.1) } 
		=> EchoNone.ar(_,0.4,0.3,4).distort
		* Env.linen(1,28,6).kr(2,gate:1)
	}.play
};
[
	freqScale:[1,2,2.2,3,4,3.1].q(3),
	dur:Pwhite(0.1,8),
	play:Pfunc{|e| chord.(e.freqScale).value}
].pp;
)
(
{
	[200,[333, 250,900 ],300,400].dq(inf).demand(Dwhite(0.1,0.3,inf))
	=> SinOsc.ar(_,0,0.1)
	=> Splay.ar(_)
	* Env.perc().kr(0, TDuty.kr(Dseries(0.01,0.01,100),doneAction:2))

}.play
)


(
var
dur = [1,3,2,3,4,2,3]/5.rand,
freq = [1,[2, 3 ],5,[ 6,11 ],5,3,4,7,6,5,4,3,5,4,4,2]+6.rand =>_.df(\e)
;
{
	var pitch = Env.step(freq,dur.wrapExtend(freq.size)).kr(2,gate:1);
	var modEnv = Env([0,5,7,5,200,3,4],dur,curve:\step).kr(0,gate:1);
	var mod = SinOsc.kr(modEnv,0,3);
	var width = Dwhite(0.1,0.3).duty(dur.wrapExtend(freq.size).dq);
	var pulse = Pulse.ar( pitch * [1,rrand(0.999,1.01)] + mod,width)
	* Env.perc(attackTime: 0.01,  releaseTime: [8,0.5].dq(inf).duty(dur.wrapExtend(freq.size).dq),  level: 1.0,  curve: -4.0).kr(0,gate:dur.wrapExtend(freq.size).tduty(10))
	* 0.04
	* Env([1,1,1.5,1],dur.parse([3,1,1])).kr(0,gate:1)
	=> EchoCubic.ar(_,0.3,SinOsc.ar(0.02).range(0.2,0.3));
	  SelectX.ar((pitch[0] > 450) => _.lag(4),[pulse*2=>MoogFF.ar(_,1000,3),pulse])

}.play

)
(
a= VoiceLeading(
	[
		[1, 3,  5,  4, 3, 4,  2, 3],
		[1, \_, \_, 6, 5, \_, 4, \_] * -1 -10
	],
	Array.fill(8,{ 8.rand/8 })
).df(\e);
{
	2.collect
	{ |i|
		Saw.ar(a.demand[i],0.1)
		* Env.perc(
			[0.1, 0.2][i],
			[8,   0.2].dq(inf).duty(a.durationArray[i].dq)
		).kr(0,gate: a.durationArray[i].dropLast.tduty)
	
	} => MoogFF.ar(_,LFBrownNoise1.ar(1).exprange(1900,4000),2) *3
	=>DWGReverbC1C3.ar(_,mix:0.5)
	* Env.linen(0,a.durationArray[ 0 ].sum,6).kr(2,gate:1)

}.play;
)
(
a= VoiceLeading(
	[
		[1,  3,  [11, 13, 5 ], \r, \r, 4,   2, 3],
		[\r, \r, \r,  6,  5,   \_, [6,11, 4 ],  \_] + 10,
		[1,  \_, 2,   \_, 5,   \r, 2,  \_] * -1
	],
[1,2,2,2,2,2,2,2]/14
).df(\e);
{ var b;
	var saw = Saw.ar(
			a.demand.lag(0.1*[ 0,1,1,0,1,0,1,1 ].dq.demand(a.dur.dq))
			+ SinOsc.ar( Dwhite(3,7,inf).demand(a.dur.dq.tduty))
		,0.1 * Env.adsr(0.001,0.3,0.5,3).kr(0,gate:a.gate)
	);
		saw => Splay.ar(_) 
}.play
)

(
a=VoiceLeading(
		[
			[1, 3,  5,  3, \r,  \r,  6,  5,  4],
			[-1, \_, -17, -16, -15, -14, \r, \r, -17 ] 
		],
		[1,1,1,0.5,0.5,1,1,1,1]/2		
).df(\e,tuning:\sept7);
//not passing tuning grrr

{|offset out| { 
	Pulse.ar(
		a.demand + offset //array of levels demanded by durs
		.lag([ 0.6,0,0,0,0.5,0,0,0 ].dq.demand(a.dur.dq))
		+ [1,-0.8] 
		+ SinOsc.kr(Dwhite(2,70).demand(a.dur),0,5), 
		LFBrownNoise1.kr({2.0.rand}!2).range(0.1,0.5), 
		Env.asr(0.05,0.1,2).kr(0,gate:a.gate) // array of gates for rests
	) 
	*  ( 0.5 + 2.collect{ |i| 
		Env.asr(0.01,3.1,0.1)
		.kr(
			0,
			// Tduty OR phrase gate
			gate: a.everyNoteTrigger[i] * a.gate[i])
		} *2 )
		=> Splay.ar(_)
		=> EchoNone.ar(_,0.4,0.333,4) 
	}.play(s,out) } =>  {|i| [offset:Pwhite(0,1000),\out:Pseries(0,1),play:{ i.value(~offset,~out) },\amp:[0].q(3),dur:8].pp}
)
