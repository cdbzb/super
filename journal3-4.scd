(
a=[
	{Saw.ar(900.rand+\offset.kr,0.2)} ,
	FreeVerb.ar(_,1,1) ,
	Pan2.ar(_,[Pulse,SinOsc].choose.kr(\lfoSpeed.kr(2))) ,
	{|i| i * Env.linen(1,10,9).kr(2,gate:\gate.kr(1))}
];
{
	4.do{
		var b=
		{a.reduce('=>')}
		=>_.asSynthDef=>_.play=>_.mapLfo(\offset,{LFBrownNoise2.kr(0.5).unipolar*400});
		{a.reduce('=>')}.play=>{|i|
			fork{
				i.postln;i.isPlaying.postln;
				while(
					{(i.isPlaying)==true},{0.01.wait;\waiting.postln}
				);
				\map.postln;
				i.mapLfo(\offset,{LFBrownNoise2.kr(0.5).unipolar*400})
			}
		}
		=>Node.basicNew() .mapLfo(\offset,{LFBrownNoise2.kr(0.5).unipolar*400});
		

		{b.mapLfo(\lfoSpeed,{LFBrownNoise2.kr(0.5).unipolar*10})}.sched(0.1);
	};
	[10,5,19].choose
}.sched(0)
)

{a=>b=>c}.play
'Control Structures'.help
a=Synth(\default)=> {|i|NodeWatcher.register(i);i}=>_.isRunning
.isRunning
a.isRunning
(
		{a.reduce('=>')}.play=>{|i|
				i.mapLfo(\offset,{LFBrownNoise2.kr(0.5).unipolar*400})
			}
)
s.latency_(1)
a={Saw.ar(400,0.1)=>Out.ar(0,_)}=>LocalDef(_)
Synth(a.asSymbol)
a=LocalDef({Saw.ar(400,0.1)})
LocalDef.dictionary
{Saw.ar(400,0.1)=>Out.ar(0,_)}.playL;(note:9).play
LocalDef({Saw.ar(400)})
{Saw.ar(400)}.cs=={Saw.ar(400)}.cs
Function
(instrument:{Saw.ar(400,0.02)=>Out.ar(1,_)}).play;(note:8,pan:1).play
{Saw.ar(400)=>Out.ar(1,_)}.playL
SynthDescLib.at(\lll)
SynthDef
(note:1,dur:100).play.id[0] =>{|i|Node.basicNew(nodeID:i)}=>_.mapLfo(\freq,{SinOsc.kr(1)*800})
SynthDef(\ppp)
(note:1,dur:100).play.id[0] =>{|i|Node.basicNew(nodeID:i)}=>_.map(\freq,800)
Node.basicNew(nodeID:1012).set(\freq,999)


(
a= Array.iota(2,3,5)
a[1,1,1].size
a.shape
a[1][1][2]
Array.fill([2,3,5],{|i j k| [i,k,j].join})
{|i j k| i+j+k} ! [2,3,4]
a=Array.iota(2,3)
b=[100,200,300]
a+.2 b
[1,3,4,5] +.1 [0,5]  => _.q => {|i|[midinote:i].pp}
)
a=Array.iota(4,5)
a.slice(nil,(1..3))
a.slice((1..2),[0])
[1,3,4,5]+++[0,5]+++9!4

note => 

[[[1,3,5,5],0.1!4,[400,500,400,300]],[[2,3,4],0.2!3,[900,800,700]]].slice( nil,1 )
[[]].flopDeep()

(
a=[
	\note:[
		[10,3,5,8].q,
		[1,2,5,7].q,
		[19,3,5,2].q,
		[1,2,9,9].q
	],\amp:[
		[9,8,6,2].q/100, 
		[2,3,3,2].q/100,
		[1,2,2,9].q/100,
		[3,6,3,3].q/100

	],\out:[
		[0!4,0!4,1!4,1!4]
	],\instrument,[
		\default,\sawSynthSustain,\sparkTriangle,\stringyy
	]].flop.collect(_.pp);


	//.collect(_.pp)
)
//location = [x,y,z]
//trasformations!
// for example 2d space -> dur and amp
 ~expr={|amount| var dur=1-amount;var amp=amount*2/20; (note:12.rand,dur:dur,amp:amp).play}
 ~expr.(0.1)
 b=Pbrown().asStream;
 fork{100.do(~expr.)}
// parameters: freq,amp,x,y,z,cutoff 
([
	dm:[1,3,5,1,4,6,5   ].q,
	v2:[1,    1,-5      ].q,
	dur:[1!6++2].flat.q,
	finish:{~freq=~dm.df()}
].pp)

(
a=VoiceLeading(
	[
	[1,3,5,1,4,6,5,\_],
	[1,\_,-7,1,-4,\_,\_,-7],
	[[3,5,1],\_,\_,\_,[4,6,1],\_,\_,\_]+10
],1!9
	).dm.pm(\sawSynthSustain).list.collect({|i x|Pbindf(i,
		\instrument,[\sawSynthSustain,\stringyy,\stringyy][x],
		\amp,[0.1,0.3,0.1][x])})
		=>Ppar(_,4)=>_.play


//	=>Pset(\amp,0.1,_)=>Pn(_,4)=>_.play
)
"/Users/michael/tank/super/SynthDefLibrary/*".pathMatch.do(_.load)
s.options.memSize= 8192 * 16;
s.reboot
(


SynthDef(\sf,{SinOsc.ar(rrand(300,3000)) => Out.ar(0,_)}).add(keepDef:false,completionMsg:[ \s_new,\sf,1001,0,1 ]);
Synth(\sf)
Pdef(\tkk,[degree:[1,3,5,4].q(inf)].p).quant_(4)
Pdef(\tkk).play
Pdef(\tkk,[dev: Pfunc {thisThread.clock.beats.postln},degree:[1,3,2,3].q(inf)].p)
(note:1).play
'LFO'.help
(
fork{
	a=FlowVar();
}
)
)
(
SynthDef(\wagg,{
	var a=Phasor.ar(1,(\freq.kr(400)*2*pi/s.sampleRate),0,2*pi);
	//var b=cos(a);
	var c=sin(a**SinOsc.kr(\num.kr(1)).range(-1,3)+a*2*SinOsc.kr(\num2.kr(3),mul:2));
	c/3 
	=> LPF.ar(_,5000) 
	=> Mix.ar(_)!2  
	* Env.linen(Rand(3,8),Rand(8,12,Rand(0,5))).kr(2,gate:1) 
	=>Out.ar(0,_) 
	}).add;
)
[dur:2,instrument:\wagg,freq:Pwhite(100,1000),\num1:Prand([1/3,1,2,3,5,20],inf),\num2:Prand([2,0.2,4],inf)].pp

[ freq:Pwhite(1,800),instrument:\wagg,\num:100.reciprocal,\num2:77.reciprocal,dur:[1,1,1,1,30].q(inf)/3].pp



(
a=[Array.iota(5,4),[\default,\wagg,\default,\default],(100+Array.iota(5,4))];
4.do{|i|  
var b=a.slice(nil,i);
[note:b[0].q(inf)+i,instrument:b[1],num2:b[2].q(inf)/1000,num:b[0].q(inf)].pp
}
)

(
SynthDef ( \wagg2,{
	//Sweep.ar(1,1)*[900, 1000 ]
	LFBrownNoise2.ar(LFBrownNoise2.kr(0.5).range(0.1,2))*1000000
	//=> ln(_)
	=> {|i|
	sin(i**1.5)*0.001
	*
	cos(log(i*800))}
	*0.0000001
	=>Mix.ar(_)
	=> EarlyRef.ar(_,[1,1,1],[{2.rand}!2,{3.rand}!2,4])
	////=>DWGReverbC1C3.ar(_,500,mix:0.1)
	=> Out.ar(0,_)
}).play
)
Synth(\wagg2); Synth(\wagg2);


(
[
	"e x x x xx x",\hihat,
	"q q",\kick2,
	"hx",\cymbalsDS
].pairsDo({|i j| [dur:i.asBeats.q(inf),instrument:j,finish:{(~instrument==\cymbalsDS).if{ ~amp=0.01 }{~amp=0.1}}].pp})
)
"/Users/michael/tank/super/SynthDefLibrary/*".pathMatch.do (_.load)
