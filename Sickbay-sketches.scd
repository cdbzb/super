"~/tank/super/More-Organized-Trek/Songs/Sickbay-song.scd".standardizePath.load;
~sickBay.cursor_(2).play;
~sickBay.pbind[8].play;
~sickBay.pbind[9].play;

~sickBay.iWantedToBe.play
(
	~sickBay.iWantedToBe=(start:7,music://{{{
		[
			(instrument:\cymbalsDS,out:2,att:0.001,amp:0.03)
			=>Pfin(1,_),
			//[amp:[0.13,0.09].q(inf),degree:([1,3,5]!4++[[0,1,3,5]]).q-1,out:2,sustain:0.3!4++[2]].p,

			[
				amp:[0.13,0.09].q(inf),
				degree:([1,3,5]!4++[[0,4,5]]).q-1,
				out:1,
				sustain: 0.3!4++[2]=>Pseq(_),
				dur:
				~sickBay.iWantedEighths=~sickBay.parse(7,[2/3,[1/3,1],[1,1],[1,1],1,[1,1],[1,1]]);
				~sickBay.iWantedEighths.q
			].p
			,
			[out:2,degree:[1,1,0,0,4-7].q-1,dur:~sickBay.parse(7,[1,1,[1,1,1],1,[1,1,1]]).q
			,octave:[2,3,4]].p,
		]=>Ppar(_)=>Pset(\root,1,_)
		//_.play;s.meter
	);


	{
		var lodriver, locutoffenv, hidriver, hicutoffenv, freqs, res, thwack;
		locutoffenv = EnvGen.ar(Env.perc(0.5, 5)) * 20000 + 10;
		lodriver = LPF.ar(WhiteNoise.ar(0.1), locutoffenv);
		hicutoffenv = 10001 - (EnvGen.ar(Env.perc(1, 3)) * 10000);
		hidriver = HPF.ar(WhiteNoise.ar(0.1), hicutoffenv);
		hidriver = hidriver * EnvGen.ar(Env.perc(1, 1, 0.25));
		thwack = EnvGen.ar(Env.perc(\att.kr(0.001),0.0001,1));
		freqs  = {exprand(300, 20000)}.dup(30);
		res	= Ringz.ar(lodriver + hidriver + thwack, freqs).mean;
		((res * 1) + (lodriver * 2) + thwack).dup * \amp.kr(0.1)
		=> ( Out.ar(\out.ir,_) <! DetectSilence.ar(_,doneAction:2))
	}=>SynthDef(\cymbalsDS,_)=>_.add;
);//}}}
)
( ~sickBay.error=(start:8,music:
	[
		~sickBay.pbind[8],
		(degree:[4,9]-1)=>Pfin(1,_),
		[degree:[\r,5,12].q-1,octave:2,
		//legato:[2,1,1].q,
		dur: ~sickBay.parse(8,[[1,1],[1,1,1,2/3],[1/3,1]]).q ].p
	]=>Ppar(_)
	//=>_.play
	)
)
(
	SynthDef(\delay,{
		In.ar(\in.kr(0,1))
		=>(Phaser1.ar(_,rate:0.2) ++ CombL.ar(_,1,~sickBay.durs[9].list[0..1].sum,3,mul:0.22))
		=>Mix.ar(_)
		=>Out.ar(\out.ir(0),_)}).add;
	~sickBay.dontBeConcerned9=(start:9,music:
		[
			[
				degree:[6,5,4,3,2].q-1,
				root:2,
				octave:5,
				dur: ~sickBay.durs[9].list[0..4].q++[2].q,
				legato:[1,1,1,1,2].q,
				out:33,
				amp:0.03,
				//s.plotTreeL
				//out: ~sickBay.delayBus9=Bus.audio(s,1)
			].p
			,
			(instrument:\delay,dur:10,in:33,addAction:\addToTail)=>Pfin(1,_), 
			~sickBay.pbind[9]=>Padd(\midinote,12,_)
		] =>Ppar(_)
	);
	~sickBay.dontBeConcerned9.play
)
~sickBay.cursor_(6).play

(//some stills{{{
	~stills.set('sargonWhatIsIt',2285.76)
	~stills.set('nothingOfImportance',2287.18)
	~stills.preview('sargonWhatIsIt')
	~stills.preview('nothingOfImportance')
	~stills.preview('sargonsFormula')
///////markers
	Reaper.go(38*60+2.81) //waiting
	Reaper.go(
		38*60+8.58
	)//Sargon what's wrong??
	Reaper.go(37*60+54.30)//door open

)//}}}
( //	some \wash examples	{{{
	///fire a bunch of the first one a second apart
(instrument:\wash,degree:[1,3,5,7]-1,octave:[3,4],pan:0,out:2,att:6,rel:8,amp:0.2).play;
(instrument:\wash,degree:[1,3,5,7]-2,octave:[3,4],pan:0,out:2,att:6,rel:4,amp:0.2).play
)
(//gesture   
	{
		b=(instrument:\wash,degree:[1,3,5,7]-2,pan:0,out:2,att:8,rel:6,amp:0.1).play;
		a=(instrument:\wash,degree:[1,3,5,7]-2,pan:0,out:2,att:6,rel:4,amp:0.2).play;
		3.wait;
		(type:\set,id:a[\id],degree:[1,2,6,9]-2,pan:0,out:2,att:6,rel:4,amp:0.2).play;
		3.wait;

		(type:\set,id:b[\id],degree:[1,3,5,7]-4,pan:0,out:2,att:6,rel:4,amp:0.2).play;
		2.5.wait;
		(type:\set,id:b[\id],degree:[1,3,4,6]-4,pan:0,out:2,att:6,rel:4,amp:0.2).play;
	}.fork
)//}}}
( //ideas for functions to route and replace Pfx{{{
	~routeFun={ |pattern function out=0|
		var privateBus=Bus.audio.index;
		privateBus.postln;
		function.play(privateBus,out);
		pattern=>Pset(\out,privateBus,_)
	};
	~route={ |pattern out=0|
		var privateBus=Bus.audio.index;
		privateBus.postln;
		{In.ar(privateBus)=>PlateReverb.ar(_,1)=>Out.ar(out,_)}.play;
		pattern=>Pset(\out,privateBus,_)
	};
	a=[degree:[1,3,5,3,4,6,5,4].q].p;
	//~route.(a,1).play;
	//b={|in out| In.ar(in)=>FreeVerb.ar(_,1,0.9)=>Out.ar(out,_)};
	~route.(a,1).play
)//}}}
//oldskool{{{
	4.do{{Saw.ar(400+LFNoise0.kr(5).range(-300,400))=>(PlateReverb.ar(_)+(RHPF.ar(_,900+SinOsc.kr(8,mul:100),9)))=>MoogFF.ar(_,LFBrownNoise1.kr(3).range(400,5000),rq:19).distort=>Out.ar([0,2],_)}.play}
//}}}
(// something spacey... {{{
	{
		10.do{
			6.do{{ Env.triangle(18.rand).kr(2,gate:1)* Saw.ar((2*rrand(25,45)).midicps,0.1)=>MoogFF.ar(_,SinOsc.ar(0.3.rand).range(800,1900))}.play(s,1) };
			6.wait;
		}
	}.fork
)}}}
[note:[1,2,3].q].p.drop(0).play
Song.songs
~sickBay.play
~sickBay.at(4)
~sickBay.whatsWrong4.play
~sickBay.at(5)
Song.current=Song.sickBay
~sickBay.cursor_(4).play
Song.play
Song.songs
Song.sickBay
\Operators.help
1 2 3
\nAry.help
a=b.linexp(0,1,40,2000)
b=0.9
a.value
(//cool metallic low siren
	a={Saw.ar(_,_).(
		//freq
		//SinOsc.kr(9.reciprocal).range(100,110)
		LFBrownNoise2.ar( 5.reciprocal
		).range(100,120)
		//amp
		,SinOsc.kr(10) *0.2
	)
	\FunctionList.help
	//hmmm multi channel expansion with??
	=>(_.pipe(
		MoogFF.ar(_,3900),
		CombC.ar(_,2,SinOsc.ar(15.reciprocal,3).range(0.5,1.9),6),
		HPF.ar(_,SinOsc.kr(3).range(500,2000))++Disintegrator.ar(_),
		Mix.ar(_),
		FreeVerb.ar(_,1,1),
		PanAz.ar(4,_,LFSaw.kr(14.reciprocal))
	))
	};
	fork{2.do{a.play;6.wait;}}
)
a=(_+_)
a.(2,3)
2=>a
a.(2)
a={|a b| a+b}
'function composition'.help
a=FunctionList((_+1),(_+2))
a.value
a
'FunctionList'.help
a = nil;
a = a.addFunc { |x="", y=""|Â "this % is an % example\n".postf(x, y); 1 };
a.postln;
a = a.addFunc { |x="", y=""| "there is no % that is %\n".postf(x, y); 2 };
a.value;
a.value("text", "extraordinary well written")
a=(_+2).addFunc(_+3)
a.addFunc({9.rand})
a.value(5)
({ //how to split sigs
	Saw.ar(400,0.05)=>
	(FreeVerb.ar(_,1,1)++(LPF.ar(_,1800)))
	//=>Mix.ar(_)
}.play)
3.pipe(a)
a.valueArray(["x", "y"]);


