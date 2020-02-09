"~/tank/super/More-Organized-Trek/Songs/Sickbay-song.scd".standardizePath.load;
~sickBay.addGuides("..x....x")
~sickBay.cursor_(0).play
~sickBay.guide8.play
(
	~sickBay.iWantedToBe=(start:7,music://{{{
		[
			(instrument:\cymbalsDS,out:2,att:0.001,amp:0.03)
			=>Pfin(1,_),
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
			[
				out:2,
				degree:[1,1,0,0,4-7].q-1,
				dur:~sickBay.parse(7,[1,1,[1,1,1],1,[1,1,1]]).q,
				octave:[2,3,4]].p,
		]=>Ppar(_)=>Pset(\root,1,_)
		//_.play;s.meter
	);

	{ //Dan Stowall Cymbals
		var lodriver, locutoffenv, hidriver, hicutoffenv, freqs, res, thwack;
		locutoffenv = EnvGen.ar(Env.perc(0.5, 5)) * 20000 + 10;
		lodriver = LPF.ar(WhiteNoise.ar(0.1), locutoffenv);
		hicutoffenv = (EnvGen.ar(Env.perc(1, 3))).range(10000,1);
		hidriver = HPF.ar(WhiteNoise.ar(0.1), hicutoffenv)
			* EnvGen.ar(Env.perc(1, 1, 0.25));
		thwack = EnvGen.ar(Env.perc(\att.kr(0.001),0.0001,1));
		freqs  = {exprand(300, 20000)}.dup(30);
		res	= Ringz.ar(lodriver + hidriver + thwack, freqs).mean;
		((res * 1) + (lodriver * 2) + thwack).dup * \amp.kr(0.1)
		=> ( Out.ar(\out.ir,_) <! DetectSilence.ar(_,doneAction:2))
	}=>SynthDef(\cymbalsDS,_)=>_.add;
);//}}}
 ~sickBay.error=(start:8,music://{{{
	[
		~sickBay.pbind[8],

		(degree:[4,9]-1,octave:3,instrument:\error)=>Pfin(1,_),
		[degree:[\r,5,12].q-1,octave:2,
		//legato:[2,1,1].q,
		dur: ~sickBay.parse(8,[[1,1],[1,1,1,2/3],[1/3,1]]).q ].p
	]=>Ppar(_)
	//=>_.play
	);

	{
		Saw.ar(\freq.kr(90)*Rand(0.995,1.005!3),0.1)
		=>MoogFF.ar(_,LFBrownNoise2.kr(LFBrownNoise2.kr(1!2).range(0.7,1.3)).range(800,6400))
		* Env.perc(1,7).kr(2,gate:\gate.kr(1))
		=>Out.ar(\out.ir(0),_)
	}=>SynthDef(\error,_)=>_.add;

//}}}
	~sickBay.bassnote9=(start:9,music://{{{
		(instrument:\error,degree:3-1,dur:2,octave:3)// .play
	);//}}}
      ~sickBay.dontBeConcerned9=(start:9,music: //{{{
			[
				[
					degree:[6,5,4,3,2].q-1,
					root:2,
					octave:5,
					dur: 
					//~sickBay.durs[9].list[0..4]
					(~sickBay.durs[9].list[0..3].mean!5)
					.q++[2].q,
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

	SynthDef(\delay,{
		In.ar(\in.kr(0,1))
		=>(Phaser1.ar(_,rate:0.2,mul:1.5) ++ CombL.ar(_,1,~sickBay.durs[9].list[0..1].sum,3,mul:0.22))
		=>Mix.ar(_)
		=>Out.ar(\out.ir(0),_)}).add;

		//~sickBay.dontBeConcerned9.play;
 //}}}
 ~sickBay.arpeggio10=(start:10,lag:-0.1,music: //{{{
	[
		degree:
		Arpeggio(([6,8,9,11.1]),19).q //.scramble .q(1)
		,
		//root:9,
		octave:3,
		pan:Pwhite(-1,1),
		dur:Pwhite(0.01,0.02)*2,
		amp:Pwhite(0.05,0.1)*0.5,
		sustain:2 
	].p
	//.play;
);  //}}}
~sickBay.bassnote10=(start:10,music: //{{{
	(note:4,octave:[3,4],instrument:\error)//.play
	
);//}}}
)

(
	{|gate=1| 
		var freq=\freq.kr(400,0.05);
	var width=\width.kr(6);
	//var gate=\gate.kr(0);

	Gendy2.ar(minfreq:freq-width,maxfreq:freq+width)
	=>Mix.ar(_) *0.5
	+Gendy1.ar(minfreq:freq-width,maxfreq:freq+width) 
	* 0.1
	=>
	(PlateReverb.ar(_,10) ++ (_*0.5))
	=>
	Mix.ar(_)
	* Env.asr(0.5,1,8).kr(2,gate:gate)
	=>Out.ar(\out.kr(0),_)
}
=>SynthDef(\stringyy,_)
=>_.add;

	a=(instrument:\stringyy,type:\on,out:2).play;
b=(type:\set,id:a[\id]);
(
	[
		[
			//(note:1,out:1)
			[root:-1,scale:Scale.minor,octave:4,degree:[1,5,10,5].q(1)-1,parent:b].p
			,
			[root:-2,scale:Scale.major,octave:4,degree:[1,5,12].q(1)-1,parent:b].p
			,
			((type:\off,id:a[\id])=>Pfin(1,_))
		].q
		,
		[
			(dur:4,degree:Arpeggio(([1,3,5]-1),10),strum:0.05,sustain:1,out:0,root:-1,scale:Scale.minor)
			,
			(lag:-0.1,degree:Arpeggio(([1,3,5]-1),10),strum:0.05,out:0,root:-2,sustain:1,scale:Scale.major)
		].q
	]=>Ppar(_,2)
	=>_.trace=>_.play;


		SynthDef(\strang_pos,{|gate=1,pos=0.2,amp=0.5 c3=30 c1=1|
			var env = Env.new([0,1, 1, 0],[0.001,0.006, 0.0005],[5,-5, -8]);
			var down = env.kr(gate:gate-pos)*PinkNoise.ar(20)*amp;
			var speed = (gate - Delay2.kr(gate)).abs*5;
			//var down = env.kr(gate:gate-pos)*LFClipNoise.ar(2000)*amp;
			var up = env.kr(gate:pos-gate)*LFClipNoise.ar(2000)*amp;
			var inp= (up+down)*speed;
			var sig = DWGPlucked2.ar(freq:\freq.kr(400,0.01),  amp:speed*amp,  gate: 1,  pos: 0.14,  c1: c1,  c3:c3 ,  inp: inp,  release: 0.1,  mistune: 1.008,  mp: 0.55,  gc: 0.01);
			Out.ar(\out.kr(1),sig*0.05)
		}).play;

	}.fork;

	~modes1=#[90, 140, 185, 211, 250, 363, 427];
	~modes2=[ 103,188,202,223,231,262,315,385,481,749 ];

	SynthDef(\sbrd,{| out=0 array=#[90, 140, 185, 211, 250, 363, 427]|
		var in = In.ar(out);
		var sig = DWGSoundBoard.ar(inp: in,  c1: 20,  c3: 20,  mix: 0.8,  d1:array[0],  d2:array[1],  d3:array[2],  d4:array[3],  d5:array[4],  d6:array[5],  d7:array[6],  d8:array@@7);
		ReplaceOut.ar(out,sig)
	}).add


)
	//make a purty harp!!
	(
		d=Bus.control;
		a=Arpeggio([0,2,4],16).collect{|i|Synth(\strang_pos,[\c1,1.3,\c3,180,\out,0,\amp,0.1,\freq,(48+i).midicps,\pos,i*0.1+0.2])};
		a.do{|i|i.map(\gate,d)};
		{SinOsc.kr(0.1)*3=>Out.kr(d,_)}.play(addAction:\addToHead)
		{SinOsc.kr(1)=>Out.kr(d,_)}.play(addAction:\addToHead)
		{SinOsc.kr(10)=>Out.kr(d,_)}.play(addAction:\addToHead)
		Synth(\sbrd,[\out,[0,1],addAction:\addToTail])
	)
	{WhiteNoise.ar(5000)}.play




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
	) //}}}
	///junx
	(//cool metallic low siren{{{
		a={Saw.ar(_,_).(
			//freq
			//SinOsc.kr(9.reciprocal).range(100,110)
			LFBrownNoise2.ar( 5.reciprocal
			).range(100,120)
			//amp
			,SinOsc.kr(10) *0.2
		)
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
) //}}}
( { //how to split sigs{{{
		Saw.ar(400,0.05)=>
		(FreeVerb.ar(_,1,1)++(HPF.ar(_,1800)))
		=>MoogFF.ar(_,
			freq:SinOsc.kr([0.2,1]).range(300,3900)
		)
		//=>Mix.ar(_)
	}
	.play
) //}}}
