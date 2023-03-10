(
	~route={|pattern symbol|
		var pBus=Bus.audio(s,2).index;
		Ppar([
			(instrument:symbol.asSymbol,dur:10,in:pBus),
			pattern=>Pset(\out,pBus,_)
		])
	}
)

a.route(\vbb).play
s.latency=1
n=NodeProxy.audio(s,2).source_(a).play;
s.makeWindow;
a.effect(\vbb,out:1).play
a.play
Synth(\vbb)
(a effect: \vbb).play
a.effect(\bvv).play
a=[degree:[1,3,5,4,4,6,5,4].q].p;
~route.(a,\vbb).play
(a=>~route.(_\vbb)).play
a route: \vbb
a=Synth(\vbb)
Node
a.get(\out,_.postln)
(instrument:\vbb,in:3).play
SynthDescLib.at(\vbb)
a=>
b={|in|FreeVerb.ar(in)};
b={|in|{In.ar(in)=>FreeVerb.ar(_,1,1)}}
c={|fn| {|in|fn}}
d=In.ar(_)=>FreeVerb.ar(_,1,1)
c.(d).dump
(//verbs
	SynthDef(\vbb,{|out=0|
		In.ar(\in.ir(3))
		=>FreeVerb.ar(_,1,1)
		* Env.cutoff(5).kr(2,gate:\gate.kr(1))
		=>Out.ar(out,_)
	}
).add;
SynthDef(\bvv,{|out=0|
	In.ar(\in.ir(3))
	=>Phaser2.ar(_,fb:0.6)
	=>Out.ar(out,_)
}).add;
)

//Idea this would be good for Thalassa "Husband" number
///hmmm sawbl a little 'soft' in the lower registers
[1,3,4,6].q=>[degree:_,dur:Pwhite(0.1,5),instrument:\sawbl,out:Pwhite(1,3)]=>_.p=>Pset(\octave,5,_)=>Pn(_,5)=>_.play
(instrument:\sawblASR,note:1,dur:1,out:2).play

(// little piece
	fork{
		var root = [0,3,3].choose;
		m=SystemClock.seconds;
		SynthDef(\sawblASR,{|freq width|
			Gendy1.ar(minfreq:freq-width,maxfreq:freq+width)  * 0.3 *
			Env.asr(\att.kr(1),\amp.kr(0.5),\rel.kr(8)).kr(2,gate:\gate.kr(1)) =>
			Out.ar(\out.kr(0),_)
		}).add;
		SynthDef(\sawbl,{|freq width|
			Gendy1.ar(minfreq:freq-width,maxfreq:freq+width)  * 0.3 *
			Env.linen(1,5,8).kr(2,gate:\gate.kr(1)) =>
			Out.ar(\out.kr(0),_)
		}).add;

		s.sync; (SystemClock.seconds-m).postln;

		9.do{
			a=[1,9,8,5,6,5,4,2].q 
			=> [degree:_,instrument:[\default,\sawbl].choose,width:Pwhite(0,3.0),root:root]=>_.p;
			a => Pset(\out,(b=Bus.audio(s,1)),_) => _.play;
			a =>Pbindf(_,\tempo,[1/2,1/3,3/2,4/3].choose,\amp,0.05) => _.play;
			Synth(\vbb,[\in,b.index,\out:[0,1].choose])
			;3.0.rand.wait;
		}
	}
)

( ~split={|function function2 function3|
		function2.(function)+function3.(function)
	};
	~spli2={|function array|
		//array.accumulate.....
	}
)

////loud!!!!!!
{~split.(Saw.ar(700+Gendy1.kr(0.1,0.5,100,add:100,mul:0.01),0.1),FreeVerb.ar(_,1,1),HPF.ar(_,9800))=>LeakDC.ar(_)*0.5!2}.play(s,0)
s.meter
( //rooobot{{{

	{ 	~split.(Gendy4.ar(minfreq:70,maxfreq:66)=>MoogFF.ar(_,390+LFBrownNoise1.kr(1,mul:200)),
			PlateReverb.ar(_),
			CombC.ar(_,2,Gendy1.kr(minfreq:10.reciprocal,maxfreq:0.5).range(0.1,2))
		)
	}.play(s,1)
)//}}}
(//racket
	{
		Saw.ar([80,110,120],0.1)=>Mix.ar(_)=>HPF.ar(_,1000+LFBrownNoise2.ar(0.5,mul:200))=>
		//LPF.ar(_,4000)=>
		(
			(_*0.01)
			+
			FreeVerb.ar(_,1,1))=>
			Phaser2.ar(_,0.5,0.1)=>
			(( _*0.2 )+CombC.ar(_,1,LFBrownNoise1.ar(4.rand+1).range(0.1,1),3))=>
			(( _*0.2 )+CombC.ar(_,1,LFBrownNoise1.ar(0.4).range(0.1,1),3))
	}
	.play(s,1)
)

(// Husband
	[6,5,2].q -1 + [0,4] =>
	[
		width:[ 3,5,6 ],
		out:[2,3],
		tempo:1.35,
		degree:_,
		root:(-1),
		instrument:\sawblASR,
		dur:[1,1,1].q*4,
		rel:2,
		amp:0.35,
		octave:[2,3,4]
	]=>_.p
	=>Pn(_,2)
	=>_.play;

	[degree:[\r,1,0,\r,5,4,4,3,2,4,3,2].q-1,octave:6,sustain:1.5,amp:0.25,instrument:\sawblASR,dur:[1,1/2,1/2,1/2,1/4,1/4,1/2,1/4,1/4,1,1/2,1/2].q*2,out:2,root:(-1)].p=>Pn(_,2)=>_.play;
	[lag:0.75,degree:[\r,1,0,\r,5,4,4,3,2,4,3,2].q-1,octave:6,sustain:1.5,instrument:\default,dur:[1,1/2,1/2,1/2,1/4,1/4,1/2,1/4,1/4,1,1/2,1/2].q*2,out:3,root:(-1)].p=>Pn(_,2)=>_.play;

	[6,5,2].q(2) -1 + [0,4] => [octave:2,rate:[2.1,0.1],legato:1.01,instrument:\trem2,scale:Scale.major,root:(-1),dur:4,degree:_]=>_.p=>_.play;
)
Synth(\trem2,[\out,2])
(instrument:\trem2,out:2,scale:Scale.major,degree:1,out:2).play

( SynthDef(\trem2,{| rate=12 freq=499 scale=1 gate=1 out=0| //		{{{
		//var force =LFBrownNoise1.kr(1).range(-0.20,8.8);
		var force=0.9;
		//var scale=SinOsc.ar(0.01).range(0.2,1.2);
		//var vel=1;
		var vel=SinOsc.kr(rate+LFBrownNoise1.kr(1)).range(0,1);//rate
		//var pos=0.2;
		var pos = LFBrownNoise1.kr(2).range(0.3,0.2);
		var env = Env.asr(0,1,0.5).kr(2,gate:gate);
		var sig = DWGBowed.ar(
			freq: freq,// + LFBrownNoise0.kr(2).range(0,10),  
			velb: vel,  
			force: force,  
			gate: 1,  
			pos: pos,  
			release: 0.5,  
			c1: 5,  //inverse of DC decaytime
			c3: 30, // hi freq decay 
			//impZ: 0.55*LFBrownNoise1.kr(0.5).range(0.02,1),  
			fB: 2 //inharmonicity
		); 
		sig= DWGSoundBoard.ar(sig,  c1: 20,  c3: 100,  mix: 0.8,  d1: 199*scale,  d2: 211*scale,  d3: 223*scale,  d4: 227*scale,  d5: 229*scale,  d6: 233*scale,  d7: 239*scale,  d8: 241*scale);
		sig=HPF.ar(sig,300)*0.05;
		//sig =PlateReverb.ar(sig,mix:0.8);
		Out.ar(2, Splay.ar(sig*env));
	}).add; //}}}
)

( SynthDef(\gendy_test,{|out=2|
		Gendy1.ar(\ampdist.kr(1),\durdist.kr(1),\adpar.kr(1),\ddpar.kr(1),\minfreq.kr(300),\maxfreq.kr(330),\ascale.kr(0.5),\dscale.kr(0.5),\initC.kr(12))
		=>
		Out.ar(out,_)
	}).add
)

a=Synth(\gendy_test,[\out,2])
a.contr
a.autogui
SynthDefAutogui(\gendy_test)
SynthDef
'autogui'.help
Quarks.gui
(
	Ndef(\test).play(2);
	Ndef(\test).clear;
	Ndef(\test,{ Gendy1.ar(\ampdist.kr(1),\durdist.kr(1),\adpar.kr(1),\ddpar.kr(1),\minfreq.kr(300),\maxfreq.kr(330),SinOsc.ar(0.2!4),SinOsc.ar(0.3),\initC.kr(9!2))=>Splay.ar(_)});
	Ndef(\test,{ Gendy1.ar(\ampdist.kr(1!5),\durdist.kr(1),\adpar.kr(1),\ddpar.kr(1),\minfreq.kr(300),\maxfreq.kr(310),\ascale.kr(0.5),\dscale.kr(0.5),\initC.kr(12))
	 => Splay.ar(_)
	 => PlateReverb.ar(_,0.4,0.5,0.6,1,0.5)
});

////fancy one 
	Ndef(\test,{
		var width=LFBrownNoise1.kr(1!2).range(5,30);//!gives the voice #
		var freq=LFBrownNoise0.kr([LFBrownNoise1.kr(0.2).range(0.1,0.6),LFBrownNoise1.kr(0.2).range(0.2,0.7)]).range(100,400)=>Lag.kr(_,1);
		Gendy1.ar(\ampdist.kr(1!5),\durdist.kr(1),\adpar.kr(1),\ddpar.kr(1),freq*[1,2,3,4],(freq+10)*[1,2,3,4],SinOsc.kr(0.1).range(0.8,0.95),\dscale.kr(0.9),\initC.kr(12))
		=> Splay.ar(_)
		=> PlateReverb.ar(_,0.4,0.5,0.6,1,0.5)
		=>Gain.ar(_,-10)
}).play(2);

	Ndef(\test).play(out:2);
	Ndef(\test).gui
)

