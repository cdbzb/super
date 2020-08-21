( //line 159 
/*[Small chamber]

(There are a group of boxes on the wall, containing spheres. Only two are alight.) */
Song.smallChamber.isNil.not.if{ Song.smallChamber.resources.do(_.free) };
Song(\smallChamber,[]).current;
Song.currentSong.resources.infrastructure=FunctionList([ {
			~synthsLoaded.isNil.if{"/Users/michael/tank/super/song-Synthdefs.scd".load};
	} ]);

///////how to use stills
//	~stills.isNil.if{~stills=Stills("/Users/michael/tank/Trek/video for stills etc/media/return to tomorrow.mov")}; //{{{
//	~stills.set('kirk-face',(38*60+2.81));
//				SystemClock.sched(4,{{~stills.preview('kirk-face',wait:0.51,fade:2,monitor:0,text:['Sargon here','' ])}.defer});

[ "/*KIRK:*/ Even for us, a half million years is almost too long to wait. (chord)", 
		[
				5,6,4,7 ,5,11,12,6.5,13 
				//		,11,7,11 
				,12,11,12 
				,14.5,15,14.5,14.5
				,11.5
		] .dm('a',octave: 5)
].addLine; //0
P(\lineB,start:0,music:{
				fork{ 				
						var effect=Effect(FreeVerb.ar(_,0.8,1),out:2);
						s.sync;
						[
								legato:[1.1,0.8,1,0.9,1].q,
								amp:0.05,
								//				instrument:\sawSynthSustain,
								lagTime:2,
								out:effect.bus.index,
								freq:[2,1,5,4,6].df('d',octave: 5).q,
								dur:Song.parse(0,[2,3,2,5,4],).q,
						]=>PmonoArtic(\sawSynthSustain,*_)=>_.trace=>_.play
				}
}
);
P(\lineA,start:0,music:[
//				instrument:\sawSynthSustain,
				amp:0.07,
				out:3,
				freq:[1,3,4,6,7].df('e',octave: 5).q,
				dur:Song.parse(0,[3,2,3,4,4],).q,
				legato:[1,1,0.9,1,1].q,
		]=>PmonoArtic(\sawSynthSustain,*_)
);
P(\tuneWas00gt,start:0,music:Song.currentSong.pbind[0]=>Pmul(\freq,1/2, _)=>_.fin(16)
		);
P(\chords0,start:0,syl:11,music:[
				amp:0.06,
				freq:[[5,11,13],[5,11,13],[5,7,13]].df('b',octave: 4).q,
				dur:
				Song.parse(0,[2,2,1],11)+[0,0,2]
				=>_.q,
		].p
);
P(\experiment0,start:0,syl:11,music:{{
				SinOsc.ar([300,500],0,0.002)
				* Env.perc(( Song.parse(0,[4],12)!2 ).flatten+3,1).kr(2,gate:1)
		}.play}
);
["Two others still survive. Henoch (boom) and Thalassa.",
		[6,5,4,3,2,4].dm('d',scale:\diminished)
++[5,5,5,5,5,4,3].dm('c#')
].addLine; //1
P(\baseFirstHalf2,start:1,music:
		[
				midinote: Song.currentSong.tune[1].list[0..4]++[1].dm('c')=>_.q 
//				-12 
				,
				instrument:\sawSynth,
				rel:3,
				dur:Song.durs[1],
				amp:0.01
		].p
);
P(\baseFirstHalf1,start:1,music:Song.currentSong.pbind[1].fin(6)
		=>Pbindf(_,
				\instrument,
				\stringyy,\amp,0.1,
				\out,2
		)
		=>Pmul(\freq,1/2,_)
		=>Pmul(
				\freq,
				1!5++(-4).midiratio => _.q,
				_
		)
);
P(\tune1,start:1,music:Song.currentSong.pbind[1]
		=>Pbindf(_,\amp,
				( 1!8++[ 0 ]++( 1!5 ) )
				.flatten
				.q*0.1
		)
);
P(\graphics1,start:1,music:
		{
				{
						w = Window("globes", Window.centerRect(520,105), border:false)
						.background_(Color.clear)
						.front
						.drawFunc={ Pen.use {
								Pen.fillColor=Color.red;
								5.do{|i|Pen.fillOval(Rect(i*105,0,100,100))}
								//																																																																Pen.fillOval(Rect(0,0,100,100))
						} };
						{ defer{w.close} }.sched(5);
						fork{
								5.do{
										[
												pulse:Prand([0,1],inf),
												dur:0.10,
//												freq:rrand(200,1000),
												note:rrand(10,35),
												out:Prand([0,1,2,3],inf)
										].pm(\pulsar).finDur(5).play;
										0.1.rand.wait;
								};
						}
				}.defer
		}
);
P(\graphics1,start:1, music:
		{
				{
						a={
								var circles = ();
								var screenWidth = Window.screenBounds.width;
								var bounds = Rect.new(0, 300,screenWidth,screenWidth/5);
								circles.dead = Color.gray;
								circles.henoch = Color.grey;
								circles.thalassa = Color.grey;
								circles.window = Window.new('aa ', bounds, false, false)
								.background_(Color.clear);
								circles.view = UserView.new(circles.window,circles.window.view.bounds)
								.animate_(true)
								.frameRate_(20)
								.drawFunc={ Pen.use {
										var colors=[\dead,\henoch,\dead,\thalassa,\dead];
										5.do{|i|
												Pen.fillColor=circles.at(colors[i].asSymbol);
												Pen.fillOval( Rect.new(i*bounds.width/5,0,bounds.width/5,bounds.width/5))
										}
								}};
								circles;
						}.value;
						fork{
								var  steps=190, length=4.5;
								var env = [ Env([0,0,1],[3,1]).asStream, Env([0,0,1],[1,1]).asStream ]
								;
								//																																var  env = Env.linen(1,2,1).asStream;
								b=Synth(\default,[
										\pan,-1,
										\freq,300,
										\att,5,
										\out:Effect.new(FreeVerb.ar(_,0.7,1)).bus.index
								]);
								c=Synth(\default,[
										\att,5,
										\out,Effect.new(FreeVerb.ar(_,0.6,1),out:1).bus.index,
										\pan,-1,
										\freq,500
								]);
								// to sink window and audio
								{ a.window.front }.defer
//								( s.latency )
;
								////																																2.wait;
								steps.do{
										|i| 
										var e=env.collect(_.next);
										var color = Color.grey.blend(Color.green,e[0])  ;
										var color2 = Color.grey.blend(Color.red,e[1])  ;
										b.set(\freq,(e[1]*200+300));
										c.set(\freq,500-(200*e[0]));
										defer{ a.henoch= color2;a.thalassa= color } ;
										( length/steps ).wait
								};
								{a.window.fade(1)}.defer(1);
								//																																{ a.window.fade(1); }.defer;
								1.wait;
								b.release(1);c.release(1)
						}
				}.defer
		}
);
P(\graphics1,start:1, music:
		{
				{
						var a={
								var circles = ();
								var screenWidth = Window.screenBounds.width;
								var bounds = Rect.new(0, 300,screenWidth,screenWidth/5);
								circles.dead = Color.gray;
								circles.henoch = Color.grey;
								circles.thalassa = Color.grey;
								circles.window = Window.new('aa ', bounds, false, false)
								.background_(Color.clear);
								circles.view = UserView.new(circles.window,circles.window.view.bounds)
								.animate_(true)
								.frameRate_(20)
								.drawFunc={ 
										var colors=[\dead,\henoch,\dead,\thalassa,\dead];
										5.do{|i|
												Pen.fillColor=circles.at(colors[i].asSymbol);
												Pen.fillOval( Rect.new(i*bounds.width/5,0,bounds.width/5,bounds.width/5))
										}
								};
								circles;
						}.value;
						fork{
								var  steps=190, length=Song.secDur[1];
								var env = [ Env([0,0,1,1],
										Song.parse(1,[8,2,2])
										).asStream, Env([0,0,1],
										Song.parse(1,[11,2])//+[0.15,-0.2]
								).asStream ]
								;
								var b=Synth(\default,[
										\amp,0.03,
										\pan,-1,
										\freq,300,
										\out:Effect.new(FreeVerb.ar(_,0.7,1)).bus.index
								]);
								var c=Synth(\default,[
										\amp,0.06,
										\out,Effect.new(FreeVerb.ar(_,0.6,1),out:1).bus.index,
										\pan,-1,
										\freq,500
								]);
								// to sink window and audio
								{ a.window.front }.defer ( s.latency );
								////																																2.wait;
								steps.do{
										|i| 
										var e=env.collect(_.next);
										var color = Color.grey.blend(Color.green,e[0])  ;
										var color2 = Color.grey.blend(Color.red,e[1])  ;
//										e.postln;
										b.set(\freq,(e[1]*200+300));
										c.set(\freq,500-(200*e[0]));
										defer{ a.henoch= color2;a.thalassa= color } ;
										( length/steps ).wait
								};
								{a.window.fade(1)}.defer(1);
								//																																{ a.window.fade(1); }.defer;
								1.wait;
								b.release(1);c.release(1)
						}
				}.defer
		}
);
P(\graphics1,start:1, music:
		{
				{
						var pitches = [500,300,300,500];
						var a={
								var circles = ();
								var screenWidth = Window.screenBounds.width;
								var bounds = Rect.new(0, 300,screenWidth,screenWidth/5);
								circles.dead = Color.gray;
								circles.henoch = Color.grey;
								circles.thalassa = Color.grey;
								circles.window = Window.new('aa ', bounds, false, false)
								.background_(Color.clear);
								circles.view = UserView.new(circles.window,circles.window.view.bounds)
								.animate_(true)
								.frameRate_(20)
								.drawFunc={ 
										var colors=[\dead,\henoch,\dead,\thalassa,\dead];
										5.do{|i|
												Pen.fillColor=circles.at(colors[i].asSymbol);
												Pen.fillOval( Rect.new(i*bounds.width/5,0,bounds.width/5,bounds.width/5))
										}
								};
								circles;
						}.value;
						fork{
								var  steps=190, length=Song.secDur[1];
								var b,c;
								var env = [ Env([0,0,1,1],
										Song.parse(1,[8,2,2])
										).asStream, Env([0,0,1],
										Song.parse(1,[11,2])//+[0.15,-0.2]
								).asStream ]
								;
								s.bind{
										b=Synth(\default,[
												\amp,0.03,
												\pan,-1,
												\freq,300,
												\out:Effect.new(FreeVerb.ar(_,0.7,1)).bus.index
										]);
										c=Synth(\default,[
												\amp,0.06,
												\out,Effect.new(FreeVerb.ar(_,0.6,1),out:1).bus.index,
												\pan,-1,
												\freq,500
										]);
								};
								// to sync window and audio
								{ a.window.front }.defer ( s.latency );
								steps.do{
										|i| 
										var e=env.collect(_.next);
										var color = Color.grey.blend(Color.green,e[0])  ;
										var color2 = Color.grey.blend(Color.red,e[1])  ;
										[b,c].do{
												|i x|
												var initialPitch=pitches[x*2];
												var delta=pitches[x*2+1]-pitches[x*2];
												i.set(\freq, e[x]*delta+initialPitch)
										};
										defer{ a.henoch= color2;a.thalassa= color } ;
										( length/steps ).wait
								};
								{a.window.fade(1)}.defer(1);
								1.wait;
								b.release(1);c.release(1)
						}
				}.defer
		}
);
//MUTEDP(\dyad1,start:1,music:[
		//MUTEDamp:0.005,
		//MUTEDinstrument:\sawSynthSustain,
		//MUTEDfreq:[Rest()].q++[5,11].df('c#',octave: 6),
		//MUTEDdur:Song.parse(1,[11,2],).q,
		//MUTEDeffect:{Effect(FreeVerb.ar(_,0.8,0.8),out:3).bus.index},
		//MUTEDout:Pkey(\effect),
//MUTED].p
//MUTED);
P(\hannoBoom1,start:1,music:[
		freq:[Rest()].q++[5,6].df('c#',octave: 2).q,
		dur:
		Song.parse(1,[8,5])
		++
		Song.parse(2,[2])
		=>_.q,
//		legato:0.5/Pkey(\dur),
legato:3,
].p

);
["(boom) Thalassa, my Thalassa. I`m ",[1,  11,7,6,14,13,13,12,11,15,13,15,14,13,11].dm('c#')].addLine; //2
P(\chord2,start:2,music:[
		instrument:\stringyy,
		effect:{Effect(Phaser1.ar(_,0.5,1/6,0.9)).bus.index},

		out:Pkey(\effect),
		freq:[Rest()].q++[[1,4],[2,5],[1,5]].df('c#',octave: 5).q,
		dur:Song.parse(2,[2,4,3,3]).q,
].p
);
//MUTEDP(\bomp2,start:2,music:[
		//MUTEDnote:1,
		//MUTEDoctave:[4, 3 ],
		//MUTEDrel:8,
		//MUTEDatt:0.2,
		//MUTEDdur:2,
		//MUTEDinstrument:\sawSynth,
		//MUTEDeffect:{ Effect(FreeVerb.ar(_,1,1),out:2).bus.index},
		//MUTEDout:Pkey(\effect),
		//MUTEDamp:0.02,
//MUTED].p.fin
//MUTED);
P(\tune2,start:2,
		syl:0,
		music:Song.currentSong.pbind[2]
		.drop(1)
);
P(\baseline2,start:2,syl:1,music:[
		amp:0.2,
		dur:Song.parse(2,[
				1,1,2/3,[1/3,1],
				1,1/2,1/2,1,
				1/2,1/2,1,1,
				2/3,[1/3,1/3],2/3,1
		],2).q,

		freq:[4,4,4,4,5,5,5,5,11,11,11,11,6,6,6,6].df('c#',octave:2 ).q,
		gate2: [1!12++(0!4)].flatten .q,
		pulse:1,
].pm(\pulsar)
);
		["pleased you survived with me.","r"].addLine; //3
["Forgive me. It has been so very long. ","r"]; //4

["/*SPOCK:*/ When the struggle came which devastated your planet ","r"].addLine;
["/*KIRK:*/ Only the best minds were chosen to survive. Thalassa, my wife, as you may have guessed. Henoch, from the other side. Realising our mistake, we attempted to perpetuate both sides. We built this chamber here in order to preserve our essence in this fashion. ","r"].addLine;
["/*SPOCK:*/ Fascinating. ","r"].addLine;
["/*KIRK:*/ We knew the seed that we had planted on other planets would take root, that one day you would build vessels as we did, and one day you would come here. ","r"].addLine;
["/*SPOCK:*/ These others, they were stored differently than you, but it was your task to remain in the receptacle out there ","r"].addLine;
["/*KIRK:*/ and search the heavens with my mind, probing, waiting, probing. And then one day my mind touched your vessel and brought you here. ","r"].addLine;
["/*MULHALL:*/ So you could steal our bodies from us? ",[6,7,11,12,7,13.5,11,7,5].dm('c',scale:\minor)].addLine;
["/*KIRK:*/ To steal? To take them from you? No, no, my children, you misunderstand. We mean only that you should lend us your bodies for a short time. ","r"].addLine;
["/*MCCOY:*/ And destroy them, just as you're burning that one up now. Heartbeat's two hundred and sixty two, Spock. Entire metabolic rate correspondingly high. ","r"].addLine;
( SynthDef(\pulsar,{
				var pulse = Env.perc(0.05,1).kr(0,gate:\pulse.tr(0));
				var envelope = Env.asr(0,1,5).kr(0,gate:\gate.kr(1));
				envelope = Env.asr(0,1,6,curve:\sine).kr(2,gate:\gate2.kr(1));
				Saw.ar(\freq.kr(300),\amp.kr(0.1))
				=>MoogFF.ar(_,pulse*1000+1000,2)
				* envelope *2
				=> _.tanh /2.3
				=> Out.ar(\out.kr(0),_)
		}).add;
);
~section= Song.sections.postln;
["/*KIRK:*/ I will return your captain to you before the body limit has been reached. ",[1,2,3,4,3,5,3,2,1,4,5,6,7,6,5,6,5,4,3,2].dm('c',scale:\mixolydian)].addLine;
P(\IWillReturnVocal,start:~section,music:
		{
				Item(\eyeWillReturn).play(
						rate: [1,1.01],
						amp: 0.1,
						out: Effect(
								{|i|
										[
												FreeVerb.ar(i,1,1)
												=> HPF.ar(_,300)
												=> DetectSilenceDry.ar(_,doneAction:2)
												,
												i
												=> HPF.ar(_,300)
												* 0.9
										]
								}
								//out:1,
								//,inputChannels:2
						).bus.index
				)
		}
//}
);
P(\figure++~section=>_.asSymbol,start:~section,music:[
		legato:2.2,
		freq:[ 3,5,11, 1,4,6,11, 2,5,7,11 ].df('c',octave: 6).q
		++ [1,3,5,11, 2,4,6,11, 2,5,7,12].df('f',octave: 6).q
		,
		amp:0.5 * 0.1,
		dur:
		Song.parse(~section,[1,1,1, 1/3,1/3,1/3,1, 1,1,1,0.5, 0.5,1,1,1, 1/3,1/3,1/3,1, 1,1,1,1,]).q
		,
		effect:{ Effect({|i| Phaser1.ar(i,rate:3,fb:0.6) => DetectSilenceDry.ar(_,doneAction:2,time:1) }).bus.index },
		out:Pkey(\effect),
].p
);
P(\double++~section=>_.asSymbol,start:~section,music:{
		Item(\eyeWillReturnDouble).play(
				amp: 0.1,
				out: Effect(
						{|i|
								HPF.ar(i,200)
						}
				).bus.index

		)
}
);
P(\bass++~section=>_.asSymbol,start:~section,syl:1,music:[
		freq:
		[5,11,11,12,12,13,13,12,11,7,11,7,6,4].df('f',octave: 2) .q ,
		dur: Song.parse(~section,[
				1,1,
				1,3,
				0.5, [0.5,1,1],
				1,1,1,1,1,1,1,1
		],2).q,
].p
);
P(\tune,start:~section,music:Song.currentSong.pbind[~section]
);
( // timing adjustment
		Song.currentSong.durs[13]=( 
				Song.currentSong.durs[13].list
				.put(18,0.55)
				.asArray 
		).q;
		'before adjustment'.postln
);
["/*SPOCK:*/ Our bodies, Sargon, for what purpose? ", [5,7,5,4,3,2,1,5,3].dm('d',scale:\diminished)].addLine;
P(\tune,start:~section+1,music:Song.currentSong.pbind[~section+1]=>Pbindf(_,\instrument,\stringyy,\amp,0.3)
);
["/*KIRK:*/ (boom) To build. To build humanoid robots. We ",[5,5,11,5,11,7,6,4,6,5,6].dm('e-',scale:\mixolydian)].addLine;
P(\shaker++(~section+2),syl:1,start:~section+2,music:
		{		
				{ 
						StkShakers.ar(0,LFSaw.kr(8).range(-10,128),95) 
//						* Env.linen(0,2,8,curve:\exp).kr(2,gate:1)
* Env.perc(0,10).kr(2)
						=> Phaser1.ar(_,0.5,1/6)
						* 0.1
						=> FreeVerb.ar(_, Env([0,0,1],[2,8]).kr(0),0.9)
				}.play
		}
);
P( \baseline++(~section+2),syl:1,start:~section+2,music:
[
		freq:[11,11,4,4,11].df('e-',octave: 3).q,
		dur:
		Song.parse(~section+2,[2,1,2,1,2],2)
		//Song.durs[ 15 ].list
		.q,
].p
);
P(\tune++(~section+2)=>_.asSymbol,start:~section+2,syl:0,music:
		Song.currentSong.pbind[~section+2]=>_.drop(1)
);
P(\boom++(~section+2)=>_.asSymbol,start:~section+2,music:
				{
						//								Impulse.ar([1].dm('b-',octave: 3))
						Impulse.ar( \freq.kr(300),\amp.kr(0.1) )
						* Env.perc(0,1).kr(2)
						=>MoogFF.ar(_,4500,1.5)
//						=>Out.ar(\out.kr(0),_)
				}.asSynthDef(name:\blok).add;
				 [
						 out:[3,2].q,
						instrument: \blok ,
						//out:3,
						freq: [5,11].df('b-',octave: 2).q,
						amp:0.3,
						dur: Song.parse(~section+2,[[1,1,1,1,1,1,1,1,1,1/2],[1/2,1]]) .q,
				].p
);
["need your bodies long enough to have the use of your ",[11,6,5,4,7,6,2,1,2,3,4,5,3].dm('g',scale:\mixolydian)].addLine;
P(\cymbal++(~section+3)=>_.asSymbol,start:~section+3,music:
	(
			instrument:\cymbalsDS,
			amp:0.015,
			out:Effect({|i|i.tanh=>Phaser1.ar(_,0.9,0.2,0.7)*0.4},out:[1,3]).bus.index,
	)
);
P(\tune++(~section+3)=>_.asSymbol,start:~section+3,music:Song.currentSong.pbind[~section+3]
);
P(\baselineC++(~section+3),start:~section+3,syl:5,music:[
		instrument:\stringyy,
		freq:[1,2,3,4].df('d',octave: 3).q,
		dur:Song.parse(~section+3,[4,3],6).q
		++ Song.parse(~section+4,[2,2]).q
		,
].p
=>{
		|i| 
		Ppar([
				i,
				i=>Pbindf(i,
						\instrument,\default,
						\out,2,
						\amp,0.05
				)]) }
);
P(\baseline++(~section+3)=>_.asSymbol,syl:2,start:~section+3,music:
		{
				var freq=\freq.kr(300);
				Pulse.ar([freq/2, freq ],\width.kr(0.3),\amp.kr(0.1))
				* Env.adsr(0.01,0.2,\sustain.kr(1),\release.kr(2)).kr(2,gate:\gate.kr(1))
		}.asSynthDef(name:\pulseBase).add;
		~pulseamp=0.05;
		[
				instrument:\pulseBase,
				sustain:0.6,
				amp:~pulseamp,
				freq:[ Rest() ].q++[4,3,2,3].df('c',octave: 3).q,
				dur:Song.parse(~section+3,[1/2,[1/2,1],2,3],4).q,
		].p
);
P(\lick++(~section+3)=>_.asSymbol,start:~section+3,syl:1,music:
{ //SynthDef(\)
		var freq=\freq.kr(400);
		40.collect{ 
				|i| SinOsc.ar(freq*i,0.04) 
				* Env.adsr([((30-i)/90),0.1.rand],0.2,1.0.rand,2.0.rand+2.5).kr(2,gate:\gate.kr(1)) / (i+5)
				* 0.01
		}
		=> Mix.ar(_).tanh
		=> EchoNone.ar(_,0.5,0.3,3)
}.asSynthDef(name:\dingy).add;
[
		instrument:\dingy,
		pan:-1,
		freq:[12,11,4].df(octave:6).q ++[14,13,6].df('c',octave: 5 ).q,
		out: [[0,3]].q(3)++[[2,1]].q(3) ,
//		out: [[0,3]].q(2)++[99]++[[2,1]].q(2)++[99] , //rest hack
		dur:Song.parse(~section+3,[1,1/2, 1/2,1,1,1,1],2).q,
		legato:2
].p
);
P(\baselineA++(~section+3),start:~section+3,music:[
		width:0.5,
		sustain:0.6,
		amp:~pulseamp,
		instrument:\pulseBase,
		freq:[11,7,6].collect{|i|[i,i]}.flatten =>_.df('c',octave: 3)=>_.q,
		dur:
		Song.parse(~section+3,[2/3,[1/3,1,1/2],[1/2,1]])*.x[3/4,1/4]
		=>_.q=>_.fin(5),
].p
);
P(\chords++(~section+3)=>_.asSymbol,start:~section+3,music:
		[
				freq:[[11,11,13],[11,11,13],[7,12,13],[7,12,13],[6,11,13],[6,11,13]].df('c').q,	
				out:1,
				dur:Song.parse(~section+3,[1/3,1/3,1/3,[1,1/2],[1/2,1]],).q,
		].p
);
["hands, your fingers. ",[6,5,4,3].dm('g')].addLine;
P(\harmony++(~section+4)=>_.asSymbol,start:~section+4,music:
SynthDef(\whaFingers, {
		Formants.ar(
				\freq.kr(300,\freqLag.kr(1)),
				Vowel(\a).blend(Vowel(\u), Line.kr(0,1,\length.kr(3),doneAction:0))
				* Env.asr(1,1,\release.kr(1)).kr(2,gate:\gate.kr(1))
		)
		* \amp.kr(0.03)
		=> Out.ar( \out.ir(3) ,_)
} ).add;
		Ppar([
				[
						freq:[6,5].df('c',octave: [5 ]).q,
						out:{Effect({|i| EchoNone.ar(i,1,0.8,4) => DetectSilenceDry.ar(_,doneAction:2)},out:2 ).bus.index},
						amp:0.005*1/2,
						dur:Song.parse(~section+4,[2,2],).q,
						release:1,
				].pm( \whaFingers),
				[
						out:{Effect({|i| EchoNone.ar(i,1,0.4,1) => DetectSilenceDry.ar(_,doneAction:2)},out:2 ).bus.index},
						amp:0.001*1/2,
						freq:[3,2].df('c',octave: 4).q,
						dur:Song.parse(~section+4,[3,1],).q,
						release:1,
				].pm( \whaFingers)
		,
		])
);
P(~tune++(~section+4)=>_.asSymbol,start:~section+4,music:Song.currentSong.pbind[~section+4]
);
\intend.post;~intend= Song.sections.postln;
["/*SPOCK:*/ Then you intend to construct mechanical ",[3,4,2,3,4,5,6,7,6,5,4].dm('e',scale:\mixolydian)].addLine;

P(\tune++~intend=>_.asSymbol,start:~intend,music:Song.currentSong.pbind[~intend]
);
P(\dyad++~intend=>_.asSymbol,syl:5,start:~intend,music:
		[
				freq:[5,1,4,[3,5],2,1].df('a',octave: 4).q,
				instrument:\sawSynth,
				amp:0.06,
				dur:Song.parse(~intend,[2/3,1/3,1,1,1,1],6).q,
		].p
);
P(\bass++~intend=>_.asSymbol,start:~intend,music:
		[
				freq:[4.5,3,4.5, 7,11,7,6,5, 
//					4
				].df('d',octave:3).q,
				dur:Song.parse(~intend,[2,1,3, 1,1,1,1,1]).q++1,
				amp:0.04
//				instrument:\pulseBase,
		].pm(\pulseBase)
);
["bodies, move your minds into them, and then re - ",
		[13,12,7,15].dm('d',octave: 5,scale:\mixolydian)
		++[13,11,7,5].dm('e-',octave: 5,scale:\mixolydian)
		++ [6,7,4].dm('c',octave: 5)
].addLine;
P(\intoThemBass++( ~intend+1 ),start:~intend+1,syl:4,music:
	Song.currentSong.pbind[~intend+1]
	=>Pdrop(5,_)
	=>Pfin(3,_)
	=>Pmul(\freq,1/2,_)
	=>Pbindf(_,\instrument,\pulseBase,\amp,0.02)
);
P(\tune++(~intend+1),start:~intend+1,music:Song.currentSong.pbind[~intend+1]
);
P(\bass++(~intend+1)=>_.asSymbol,start:~intend+1,music:
	[
		freq:[1,1,1,1,2,2,2,2].df('d',octave: 3).q++[3].df('a-',octave: 2).q,
		dur:
		Song.parse(~intend+1,
				(1/3)!6++((1/2)!2) => _.flatten ++ 2
				,)
		.q,
	].p
);
P(\stringyBass++(~intend+1),start:~intend+1,syl:6,music:
	[
			freq:[11,7,6.5].df('b-',octave: 2).q,
			instrument:\stringyy,
			dur:Song.parse(~intend+1,[2/3,[1/3,1],1],7).q,
	].p
);
["turn our bodies to us. ",[1,2,3,4,3,5].dm('g',octave: 5)].addLine;
P(\tune++(~intend+2),start:~intend+2,music:Song.currentSong.pbind[~intend+2]
);
P(\bassnote++(~intend+2),start:~intend+2,music:
	(
		freq: [1].df('g',octave: 3),
		dur:Song.parse(~intend+2,[5],),
	)
);
//if args have no numbers, append the section # ?
P(\chord++(~intend+2),start:~intend+2,syl:3,music:
	{
		[ 
			freq:[7,11,13,15].df('g',octave: 3),
			effect:Effect({|i|FreeVerb.ar(i,0.7,0.8) => DetectSilenceDry.ar(_,doneAction:2)},inputChannels:2),
			out:Pfunc({|e|e.effect.bus.index}),
			strum:0.07,
			dur:Song.currentSong.secDur[~intend+2]-0.5,
		].p.fin(1).play
	}
);
["/*MULHALL*/We have engineers, technicians, ",[11,7,11,5,3,5,5,4].dm('f#',scale:\mixolydian)].addLine;
P(\traps,start:~intend+3,music:
	//~fx=Effect(Phaser1.ar(_,0.4,1/5,0.3));
	{
		~div=[3,4].choose;
		[
			dur: "xxxx".asDrumPat(8,reps:12)
			* (Song.parse(~intend,[8],).sum/~div*2),
			instrument: \hihat,

			effect:Effect({
					|i| Phaser1.ar(i,0.4,1/5,0.2) 
			//		=> Pan2.ar(_,SinOsc.kr(0.1)) 
					=> DetectSilenceDry.ar(_,doneAction:2)
			}),
			//out:Pkey(\effect),
			//out:~fx.bus.index
			out:Pfunc({|e|e.effect.bus.index})
		].p
		//make this into a func ie ||+
		=> {|i| Ppar([i,
			[
				note:Pwhite(10,50),
				instrument:
//				\snare
				\sn
				,amp:0.05,
				dur: "..x.".asDrumPat(8,reps:12)
				* (Song.parse(~intend,[8],).sum/~div*2),
			].p
		]).play}
	}
);
P(\pedal++( ~intend+3 )=>_.asSymbol,start:~intend+3,music:
		(instrument:\stringyy,freq:[1,11].df('f#',octave: 2),dur:4,)
);

//idea: what about auto picking the start from context? ie Song.sections?
P(\tune++(~intend+3),start:~intend+3,music:
	{
	    Song.currentSong.pbind[~intend+3] => Pbindf(_,
			\effect, {Effect(FreeVerb.ar(_,0.9,0.9)).bus.index},
			\out,Pkey(\effect)
	    ) => _.play
	}
);

["why can't they (just) build your robots for you?", [7,6,7,4,2,4,4,3,2,1].dm('f#',scale:\mixolydian)].addLine;

P(\tune++(~intend+4),start:~intend+4,music:Song.currentSong.pbind[~intend+4]
	=>Pbindf(_,\effect,
		{Effect(FreeVerb.ar(_,0.9,0.9)).bus.index},
		\out,Pkey(\effect))
);
["/*KIRK:*/ No. Our methods, our skill --s are (boom) ",[12, 12,12,11,7,13,7,11 ,6, ].dm('c')].addLine;
P(\tune++(~intend+5),start:~intend+5,music:Song.currentSong.pbind[~intend+5]
);
P(\chords++(~intend+5),start:~intend+5,music:
		[
				freq:[
						[5,6.5],
						[5,6.5], [4,6],
						[5,7],[5,11],
						[6,11]
				].df('c',octave:4).q,
				dur:Song.parse(~intend+5,[1, 1,3, 2,1, 1],).q,
				instrument:\sawSynthSustain,
				amp:0.06
		].p
);
["far , far beyond your abilities. It is. ",[14, 14,13,13,14,13,12,7,3, 5.5,5.5,5.5].dm('c')].addLine;
P(\tune++(~intend+6),start:~intend+6,music:Song.currentSong.pbind[~intend+6]
);

~lick=Array.series(4,0,2).collect(_+[11,12,7.5,11].dm('c#',octave:5,scale:\diminished )).flatten ;
["time dum dum dum dum dum etc ",~lick].addLine;
P(\lick++(~intend+7),start:~intend+7,music:Song.currentSong.pbind[~intend+7]=>{|i|
	Ppar([i,
		i=>Pbindf(_,\instrument,\stringyy,\amp,0.3)
		=>Pmul(\freq,1/2,_)
	
}
);

//(They help him back to Sargon's sphere.)
)


(
SynthDef(\vocalFry ,{
		Impulse.ar(\freq.kr(200,\freqLag.kr(0.5)))
		* \amp.kr(0.1)
		* Env.asr(0.1,1,0.1).kr(2,gate:\gate.kr(1))
		=> Out.ar(\out.kr(0),_)	
}).add;
)
(
		//:call scnvim#sclang#send("Song.current.cursor_(13)")
		Song.play;
		~carrier.isNil.if{~carrier=Bus.audio};
		Song.currentSong.pbind[13]=>Pbindf(_,\legato,1,\instrument,\vocalFry,\out,~carrier.index)
		=>Pmul(\freq,[1/4, 1/2 ],_)
		=>_.play;
		{
				Vocoder.ar(
						In.ar( ~carrier.index ),
						Item(\eyeWillReturn).playbuf*2,
						10,
						q: 0.2

				)
//				*1/4
		}.play;
		Item(\eyeWillReturn).play(out:1,amp:0.05)
)
