( //Cheap philip glass knock off
a = Items(\directory).list;

a.add(\mouth,\test,\otherOne);

[type:\items,items:a,index:2,rate:Prand( [[3,2], [2,3] ],inf ),out:0,loop:[0,1],dur:[ 0.6 ].q(inf),amp:1,].pp;
)

(
b = [type:\items,items:a,index:2,rate:Prand( [[3,2], [2,3] ],inf )*Pkey(\interval),out:0,loop:[0,1],dur:[ 0.6 ].q(inf),amp:1,].p;

Pdef(\wibble,b);

[type:\phrase, legato:1, instrument:\wibble,dur:Pwhite(1,3)*3,interval:[1,5/6].q(6)].p.trace.play

)

(
a=Item('directory/test');

{
	6.do{
		a.play
		.set(   \out,
			Effect({|i| TwoTube.ar(i,d1length:SinOsc.ar(0.02).range(300,888))},out:[0,1].choose).bus.index
		).map( \rate,
			Effect.lfo({SinOsc.kr(0.5.rand).unipolar}).bus.index
		);
		rrand(3,8).wait;
	}
}.fork
	)
(
4.do{ |i|
	a.play(loop:1).map(\rate,Effect.lfo( {SinOsc.ar((10**i*2).rand)} ).bus.index)
}
)
	
	a.play(loop:0,out:[0,1,[0,1]].choose).map(\rate,{SinOsc.ar((10*2).rand)}.lfo); s.plotTree
	a.play(loop:0,out:[0,1,[0,1]].choose).map(\rate,{Line.kr(0,1,5,doneAction:2);SinOsc.ar((10*2).rand)}.lfo); s.plotTree

	/////////////////
	[note:Pwhite(0,9,inf),legato:2,freq:Effect.lfo({SinOsc.kr(0.2).range(800,900)}).pfunc].pp;

(
Pdef(\pp,{ [
	note:Pwhite(0,10,9),
	pan:{Env.triangle(5,2).kr() -1}.lfoAsMap(9),
	//ctranspose:Ptime().collect({|t| sin(t)*6}),
	legato:Pwhite(1,4.0),
	mod:{SinOsc.kr([0.2],pi.rand).range(0.2,1)}.lfoAsMap(dur:9),
	dur:Pwhite(0.1,1,inf),
	finish:{~amp=~mod}].p });
)
Pdef(\pp).play;s.plotTree
.play
(
[
	type:\phrase,
	out:FreeVerb.ar(_,1,1).asBusNumber(0,2),
	instrument:\pp,
	dec:[9].q(6),
	dur:Prand([0,2,8],inf),
	legato:9,root:[0,7,2].q(18)
].pp; 
//s.plotTree
)

'LFO'.hel9
s.plotTree
'recursive_phrasing'.help
(
{
	var i=( 0..3 ).q(inf).asStream;
	var j=Pwhite(0,10,6).asStream;
	{
		Synth(\default,[\out,{|i|FreeVerb.ar(i,0.9,1)=> DetectSilenceDry.ar(_,doneAction:2)}.asBusNumber(0,2)]).mapLfo(\freq,{LFBrownNoise2.kr(i.next+1).range(1300.rand,[1900,600, 1800 ].choose)}).mapLfo(\pan,{Pulse.kr([3,2])}).dur(10);j.next
	}.sched(0)
}.sched([0,30])
)
a=Routine{Synth(\default)}
a.next

a.map(\out,2)
a.map(\out,Effect(FreeVerb.ar(_,1,1)).bus.index)
a=(:1..5)*2
a.next
(:[1,3,5])
(:1..5)
(1..5:)
a.map.(\out,1)
a.release(3)
s.plotTree
a=Effect.lfo({Saw.kr(2)})
a.synth.free
a.free

