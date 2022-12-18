( //line 159 
/* [Small chamber]
(There are a group of boxes on the wall, containing spheres. Only two are alight.) */
Song.songs.at(\smallChamber).isNil.not.if{try{  Song.smallChamber.resources.do(_.free)  }};
Song(\smallChamber,[]).current;
Song.currentSong.resources.infrastructure=FunctionList([ {
	//~synthsLoaded.isNil.if{"/Users/michael/tank/super/song-Synthdefs.scd".load};
} ]);
Song.chamber.isNil.if{"/Users/michael/tank/super/More-Organized-Trek/chamber_rewrite.scd".load};
//Song.smallChamber.next_(\chamber);
//Song.smallChamber.chain;
//Song.smallChamber.current;

///////how to use stills
//	~stills.isNil.if{~stills=Stills("/Users/michael/tank/Trek/video for stills etc/media/return to tomorrow.mov")}; //{{{
//	~stills.set('kirk-face',(38*60+2.81));
//				SystemClock.sched(4,{{~stills.preview('kirk-face',wait:0.51,fade:2,monitor:0,text:['Sargon here','' ])}.defer});

[ "/*KIRK:*/ Even for us, a half million years is almost too long to wait. (chord)", [ 5,6,4,7 ,5,11,12,6.5,13 ,12,11,12 ,14.5,15,14.5,14.5 ,11.5 ].dm('a') ].addLine;
P.synthV(\genbu,\wait,
	range:[0,15], params: {|p b| [
		// lyrics: "even +  for as a half million + years is alost  too long to wait",
		lyrics: "i ven fo as a haf mi ryan yiryz iz or mosyt tsu lang tsu weit",
		phonemes:[ "i","v e n","f o","a s","","h a f","","","y i r y z","i z","","","","","","" ],
		legato: [1, 1, 0.8, 0.9,1, 0.8, 1, 0.90, 0.8, 1, 1, 1, 1, 0.85, 1, 1, 1]
	]}, filter: (
		midinote: _ - 24
	), music: {|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\lineB,music:{
	var effect=Effect(FreeVerb.ar(_,0.8,1),out:2);
	[
		legato:[1.1,0.8,1,0.9,1].q,
		amp:0.05,
		//				instrument:\sawSynthSustain,
		lagTime:2,
		out:effect.bus.index,
		freq:[2,1,5,4,6].df('d',octave: 5).q,
		dur:Song.parse(0,[2,3,2,5,4],).q,
	].ppma(\sawSynthSustain)
}
);
P(\lineA,start:\almost,music:{ |p b e| 
	[
		instrument:\sawSynthSustain,
		amp:0.07,
		out:3,
		freq:[1,3,4,6,7].df('e',octave: 5).q,
		dur:Song.parse(0,[3,2,3,4,4],).q,
		legato:[1,1,0.9,1,1].q,
	].ppma
});
// P(\tuneWas00gt,start:\almost,music:Song.currentSong.pbind[0]=>Pmul(\freq,1/2, _)=>_.fin(16));
P(\chords,music:{|p b e|
	[
		amp:0.06,
		freq:[[5,11,13],[5,11,13],[5,7,13]].df('b',octave: 4).q,
		dur:
		Song.parse(0,[2,2,1],11)+[0,0,2]
		=>_.q,
	].p 
});
P(\experiment,music:{ |p b e|
	{
		SinOsc.ar([300,500],0,0.002)
		* Env.perc(( Song.parse(0,[4],12)!2 ).flatten+3,1).kr(2,gate:1)
	}.play
});
["Two others still survive. Henoch (boom) and Thalassa.", [6,5,4,3,2,4].dm('d',scale:\diminished) ++[5,5,5,5,5,4,3].dm('c#') ].addLine; 
Song.synthVTracks = EventWithDefault.new(
	\default, {|i|
		DWGReverbC1C3.ar(_, len:2000, c1:1, c3:10, mix:0.15, coefs:nil, perm:nil)
		/5
	}
);
P.synthV(\genbu,\survive,range:[0,5],
	filter: ( midinote: _ - 12 ),
	params: {|p b| [
		lyrics: "tsu a zaz stiru sa vaiv",
		phonemes: ["","","","s t i r y","",""],
		legato: [1, 1, 0.8, 0.8, 1, 0.76]
	]}, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	}
);
P.synthV(\genbu, \survive,syl:5, take: 2, range: [6,7],
	filter: ( midinote: _ - 12 ),
	params: {|p b| [
		lyrics: "he nak ",
	]}, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(\genbu, \survive,syl:8, take: 3, range:[9,12],
		filter: ( midinote: _ - 12 ),
params: {|p b| [
	lyrics: "and se ra sa",
	// legato: [0.9,1,1,1]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\baseFirstHalf2,start:\Two,music: {|p b e|
	[
		midinote: Song.currentSong.tune[1].list[0..4]++[1].dm('c')=>_.q 
		//				-12 
		,
		instrument:\sawSynth,
		rel:3,
		dur:Song.durs[1],
		amp:0.01
	].p
});
P(\baseFirstHalf1,start:\Two,music:Song.currentSong.pbind[1].fin(6)
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
P(\tune,start:\Two,music:Song.currentSong.pbind[1]
		=>Pbindf(_,\amp,
				( 1!8++[ 0 ]++( 1!5 ) )
				.flatten
				.q*0.1
		)
);
P(\graphics,start:\Two,music:
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
P(\graphics,start:\Two, music:
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
P(\graphics,start:\Two, music:
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
P(\graphics,start:\Two, music:
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
//MUTEDP(\dyad,start:\Two,music:[
		//MUTEDamp:0.005,
		//MUTEDinstrument:\sawSynthSustain,
		//MUTEDfreq:[Rest()].q++[5,11].df('c#',octave: 6),
		//MUTEDdur:Song.parse(1,[11,2],).q,
		//MUTEDeffect:{Effect(FreeVerb.ar(_,0.8,0.8),out:3).bus.index},
		//MUTEDout:Pkey(\effect),
//MUTED].p
//MUTED);
P(\hannoBoom,start:\Two,music:[
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
P.tune();
Song.setTempoMap('my Thalassa',"e e e e ex x e ee e q e e Q Q Q");
P.synthV(\genbu, 'my Thalassa',syl:0, filter: (midinote: _-12),range:[1,15],
	params: {|p b| [
	lyrics: "za la sa mai za la sa aim prizd yu sa vaived uis mi",
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\snare, music: { |p b e|
	[
		"q|q qq qq qq q",\snare,\amp,[0].q(1) ++ [0.1].q(inf),
		"q | e eq e eq e eq e eq ",\kick3,\amp,[0].q(1) ++ [0.1].q(inf),
		"q qqqq",\cymbalsDS,\amp,[\r,0.01].q,
		//"q x x x x x x x x x x x x x x x x x x x ",\hat_808,\amp,[0].q++[0.1,0.05].q(inf),
		
	].dmx2(8,e.tempoMap).collect(_.play)
});
P.synthV(\genbu, 'my Thalassa',syl:0, take: \double, filter: (midinote: _-12),range:[1,15],
	//filter: ( onset: _+10000.rand ),
	params: {|p b| [
	lag:  {0.1.rand}!14,
	lyrics: "za la sa mai Tha la sa aim prizd yu sa vaived uis mi",
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		*[0.5,1.2]
	}.play
});
P(\chord2,start:'I`m',music:[
		instrument:\stringyy,
		effect:{Effect(Phaser1.ar(_,0.5,1/6,0.9)).bus.index},

		out:Pkey(\effect),
		freq:[Rest()].q++[[1,4],[2,5],[1,5]].df('c#',octave: 5).q,
		dur:Song.parse(2,[2,4,3,3]).q,
].p
);
//MUTEDP(\bomp2,start:'I`m',music:[
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
// P(\tune2, syl:0, music:Song.currentSong.pbind[2] .drop(1));
P(\baseline2,start:'I`m',syl:1,music:[
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
["pleased you survived with me.","r"].addLine; 
["Forgive me. It has been so very long. ","r"];

[" When the struggle came which devastated your planet ","r"].addLine;/*SPOCK:*/

[" Only the best minds were chosen to survive.","5 6 7 11 7 5 6 4 2 1 -7".dm(\e,6,\phrygian)].addLine;/*KIRK:*/
// P.tune(\Oly);
P.synthV(\genbu, filter:(midinote:_-24), params: {|p b| [
	lyrics: "on li ze best mainds wa cho zen tsu sa vaiv" ,
	legato: [1, 1, 1,  1,    1,    1,  1,  1,  0.8,  1, 0.8]
	
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P('chords',start:\Only,music: {|p b e|
	[
		freq:[\r , [1,3,5,7], [1,4,6,8]].df(\c).q,
	strum:0.03,
	out: Effect.bus({|i| PitchShift.ar(i,0.2,2) + i => EchoNone.ar(_,decaytime:4)},out:3),
	dur: b.parse([3,3,1,]).q,
	amp:0.04
].p.play
});
P('spaceBass',start:\Only,syl: 7,music: {|p b e|
	[
		freq: [\r,[-17,-7],[-1,1]].df(\d,4,\harmonicMinor).q,
		instrument:\stringyy,
		dur:b.drop(1).parse([0.5,[0.5,1],1]).q,
		attack:1.5,

	].ppm
});
["Thalassa,(boom boom boom) my wife, as you may have guessed. ","-5 3 2 -1, -17 -16 3 6  5 3 1.5 2 3".dm(\e,6)].addLine;
P.synthV(\genbu,\wife,
	take:\low,filter:(midinote:_-24),
	// filter:(midinote:_-12),
	params: {|p b| [
	lyrics: "tha,        la,   sa,    r,  r,  r,  mai, waif,      az,    yu, mei, hav,     gesyd",
	phonemes: ["",       "",   "",    "", "", "", "",  "w a i f", "a z", "", "",  "h a v", "" ],
	tension: Env.step([0, -0.1, -0.05, 0,  0,  0,  0,   -0.2, -0.1, -0.5, 0],     b[..10]),
	legato: [1,          1,    1,     1,  1,  1,  1,   1,         1,     1,  1,   1,       0.8]
] }, music:{|p b e|
	{
		e.playbuf
		// => PitchShift.ar(_, windowSize:0.2, pitchRatio:0.5, pitchDispersion:0.0, timeDispersion:0.0, mul:1.0, add:0.0)
		=> p.synthVTracks.at(e.key).()
	}.play
});

P.tune(\wife,_ <> [instrument:\wash,amp:0.03,out:Effect.bus(DWGReverbC1C3.ar(_,len:3000)),
// rest:[\r,\r,\r,0,0,0].q
].p );
P.tune('my wife',_ <> [amp:0.03,out:Effect.bus(DWGReverbC1C3.ar(_,len:3000)), rest:[\r,\r,\r,0,0,0].q ].p );

["and Henoch, from the other side. ","4 3 1 -5 -6.5 -7 -5 -3.5".dm('f#',6,\minor)].addLine;
P.synthV(\genbu, filter:(midinote: _-24), params: {|p b| [
	lyrics: "and, he nok fran za a za said",
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.tune('Henoch,');

//["Realising our mistake, we attempted to perpetuate both sides. ","r"].addLine;
//["We built this chamber here in order to preserve our essence in this fashion. ","r"].addLine;

//[" Fascinating. ","r"].addLine;/*SPOCK:*/

//[" We knew the seed that we had planted on other planets would take root,","r"].addLine;/*KIRK:*/
//["that one day you would build vessels as we did, and one day you would come here. ","r"].addLine;

[" These others, they were stored differently than you,","1 3 -7 5 3 4 7 6 4 5 1".dm(\a,\mixolydian)].addLine;/*SPOCK:*/
P.tune(\These);
["but it was your task to remain in the receptacle out there ","6 7 5 11 3 7 11".dm('f#') ++ "3 5 6 7 11 5 4".dm('a-') ++ "15 16".dm(\c)].addLine;
P.tune(\but);

["(boom) and search the heavens with my mind, ",[\r,5,5,5,5,5,5,5,5].dm(\b)].addLine;/*KIRK:*/
P(\line, music: { |p b e|
	{
		var freq = "r 5 4 3 4 3 2 3 4".df(\b).dq.demand(b);
		Pulse.ar( freq.lag2, 0.4 ) ++ VarSaw.ar(freq,0.4)
		* 0.03
		=> {|i|  CombC.ar(i,0.3,0.3,5) + i }
		* Env([1,1,0],[b.sum - b.last,b.last+1]).kr(2,gate:1)
		//=>Mix.ar(_)
		
	}.play
});
P.synthV(\genbu, \heavens, filter:(midinote: _ -12), params: {|p b| [
	lyrics: "r,    and, shiach, za, he, venz, wiz,     mai, maind",
	phonemes: ["", "",  "",     "", "", "v e n z",   "w i z", "",  ""],
	legato: [1,    1,   1,      1,  1,  0.95,    1,       1,   0.90]

] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
//P.tune(\search);

Song.setTempoMap(\search,"e e e e e e e e q");
//P.tune(\search,Pset(\dur, 0.5! 9 =>_.warpTo(Song.tempoMap[\search]) =>_.q ,_));
P.tune('search ');
P('tune',start:\search,music: {|p b e|
	[
		freq:[\r, 1,1,1,1,1,1,1,1].df('f#').q,
		dur: 0.5 !8 => _.warpTo(e.tempoMap
		//.quantizeDft
		) => _.postln =>_.q
	].pp
});

P('crash',start:\search,music: {|p b e|
	(instrument:\cymbalsDS, amp:0.01).play
});
P( 'chords',
	resources:(
		synth: {
			SinOsc.ar(\freq.kr(400,0))
			* Env.perc(attackTime:0.01, releaseTime:8.0, level:1.0, curve:-4.0).kr(2)
			*0.05
			* SinOsc.kr(2.2)
			=> _.tanh
			=> Pan2.ar(_,\pan.kr(0))
		}.asDefName 
	),music: {|p b e|
		[
			freq:[ \r, [1,3].df(\b),[1,3].df(\a),[3,11].df(\e) ].q,
			dur: (0.5 * [1,3,4,1]).warpTo(e.tempoMap
				//.quantizeDft
			).q,
			instrument:e.synth,
			pan:[-1,1],
			 out: 1,


		].pp
	});
P('bass',start:\search,music: {|p b e|
	[
		freq:[5,4,1].dupEach(3).df(\e,[ 2 ]).q * [1,2, 3,6,7,14] => _.poll,
		amp:[1,1] * [1,2,3,6,7,17].reciprocal /10,
		//dur:b.parse([1,2,1,1,2,1,1]).warpTo(e.tempoMap.quantizeDft).q,
		dur: (0.5 * [1,2,1,1,2,1,1] ).warpTo(e.tempoMap
		//quantizeDft
		).q,
		out: Effect.bus({ |i| i => Amplitude.kr(_) * 50 *  CrossoverDistortion.ar(i) *0.1 + i => LPF.ar(_,4000) },inputChannels:6)
	].pp
});
//["probing, waiting, probing. ","5 4 3 2 6 5.5".dm(\c,6)].addLine;
["probing, (boom boom) waiting, (boom) probing. ","5 4 -1 -2 3 2 -4 6 5.5".dm(\c,6)].addLine;
P.synthV(\genbu, filter:(midinote: _-12), params: {|p b| [
	lyrics: "pro, bing, r, r, we, ting, r, pro, bing",
	lag: [0.1,      0,    0, 0, 0,  0,    0, 0,   0],
	legato:[1, 1, 1, 1, 1, 1, 1, 1, 0.85]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
//Song.setTempoMap(\probing," QQ Qqq QQ Qq QQ Qq q".asBeats);
P('chords',start:\probing,music: {|p b e|
	[
		freq:[ [11,13,15,1].df([\g]), [1,11,13,15].df(\f), [3,5,11,13].df(\c,6),[2,4,7,12].df(\c,6),[1,3,5,11].df(\a,6,\harmonicMinor),[-7,3,5,7].df(\a,6,\harmonicMinor)].q /2,
		dur: b.parse([1,3,1,2,1,1]).q,
		strum: [1,1/3]/20=>_.q(3),
		lag: {~strum * (-1)},
		amp:0.04,
		out: Effect.bus({|i| SineShaper.ar(i*2,[ 0.2,0.1 ]) => DWGReverbC1C3.ar(_,mix:0.2) /3},inputChannels:4,out:(0..3))

	].ppm(\default)
});
P('bass',start:\probing,music: {|p b e|
	[
		freq: " 3 -7 1 3 4 ".df(\d,[2,3,4],\dorian).q,
		//dur: "qq q qqq q qq".asBeats => _.warpTo(e.tempoMap) => _.q,
		dur: b.parse([2,1,3,1,2]).q

		//out: Effect.bus({ |i| i => Amplitude.kr(_) * 50 *  CrossoverDistortion.ar(i,smooth:0.9) *0.1 + i => LPF.ar(_,4000) },inputChannels:6)
	].pp
});
P.tune(\probing,);
["And then one day my mind","1 4 4 5 3 6".dm('f#')].addLine;
P.synthV(\genbu, filter: (midinote: _ - 12),  params: {|p b| [
	lyrics: "and zen won dei mai maind",
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.tune('day my');
P.tune('day my ', { |i| Pmul(\freq,0.5,i) =>Pbindf(_,\instrument,\sawSynthSustain,\out,Effect.bus( { |i| DWGReverbC1C3.ar(i,mix:0.3) => Phaser2.ar(_,rate:0.2)} /2 ))});
["touched your vessel and brought you here. ","11 5 4 3 2 1 -7 -6.5".dm(\e)].addLine;
P.synthV(\genbu, filter: (midinote: _ - 12),  params: {|p b| [
	lyrics: "tatsed yor ve sser and brat yu hir",
	phonemes["t a u ch t","y u r","","s e r","","","","h i e r"]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
Song.setTempoMap(\touched,"q e eQ Q Q q e q".asBeats);
P.tune(\touched);
P(\chords,music: { |p b e|
	[
		freq:[ [1,3,5].df(\a),[1,3,5].df(\e) ].q,
		dur: "qq qq".asBeats.warpTo(e.tempoMap).q,
		instrument:\visual_pad,
		out:2,
		amp:0.2
	].pp
});
P(\powerChord,start:\touched,music: { |p b e|
	[
		freq:[ -1, -5, 1, -5, 2, 5 ].clump(3).df(\a,3).q,
		dur: "qq qq".asBeats.warpTo(e.tempoMap).q,
		out:Effect.bus({ |i|  SineShaper.ar(i,0.15,5) => FreeVerb.ar(_,1,1) })
	].pp
});
P(\bass,start:\touched,music: { |p b e|	
	[
		freq: "1 3 5 7  3 2.5 2".df(\a,3).q,
		dur: "q q q q q e q".asBeats.warpTo(e.tempoMap).q
	].pp
});
["/*MULHALL:*/ So you could steal our bodies from us? ",[6,7,11,12,7,13.5,11,7,5].dm('c',scale:\minor)].addLine;
( SynthDef(\pinn,{
	var freq = \freq.kr(300);
	SinOsc.ar(freq)
	* \amp.kr(0.1)
	* Env.adsr(\att.kr(0.05),\dec.kr(0.1),\sus.kr(0.1),\rel.kr(3)).kr(2,gate:\gate.kr(1))
	=> Pan2.ar(_, freq.cpsmidi mod: 12 / 6 -1)
	=> Out.ar(\out.kr(0),_)
}).add;
);
P.tune(_ <> [
	instrument:\pinn
].p);
[" To steal? To take them from you?","1,7,3,11,8,7,6".dm(\e,\diminished)].addLine;/*KIRK:*/
P.tune();
["No, no, my children,","13 13 12 12 11 ".dm(\d)].addLine;
P.tune();
[" you misunderstand.","3 2 3 4 3".dm(\a)].addLine; 
P.tune();
["We mean only that you should","1 2 1 2 1 2 3".dm(\d,6)].addLine;
P.tune();
[" (boom) lend us your bodies for a short time. ","-11 3 2 1 -7 -6 -5.5 -6 -5.5 -3".dm(\g,6)].addLine;
P.tune();
[" And destroy them","-7,-5,3,-7".dm(\g,\mixolydian)].addLine;
P.tune();
[" just as you're burning that one up now.","1 -7 -6 -7 1 3 4 1 5 ".dm(\g,\mixolydian)].addLine;/*MCCOY:*/
Song.setTempoMap(\burning,"e e e x e e x e ee");
P(\click, music: { |p b e|
[
	dur:"e q q q q".asBeats.warpTo(e.tempoMap).q,
	instrument: \bd_808
].pp
});
P.tune();
//[ "Heartbeat's two hundred and sixty two, Spock.","r" ].addLine;
//["Entire metabolic rate correspondingly high. ","r"].addLine;
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
["/*KIRK:*/(boom) I will return your captain to you before the body limit has been reached. ",[-1,1,2,3,4,3,5,3,2,1,4,5,6,7,6,5,6,5,4,3].dm('c',scale:\mixolydian)].addLine;
P.synthV(\genbu, filter:(midinote: _-12), params: {|p b| [
	lyrics: "r,   ai, wil, ri, taan, yur, kap, ten, tu, yu,   bi, fo, za, ba, di, li, mit, haz,     bin, richt, ",
	phonemes:["", "", "",  "", "",   "",  "",  "",  "", "",   "", "", "", "", "", "", "",  "h a z", ""  ],
	legato: [1,   1,  1,   1,  1,    0.7, 1,   1,   1,  0.95, 1,  1,  1,  1,  1,  1,  1,   0.9,       1  ],
	tension: Env([-0.5,-0.5],3),
	breathiness: Env([0.3,0.3],3),
	voicing: Env([0.6,0.6],3),

	loudness: Env([6,6],3)
] }, music:{|p b e|
	{
		e.playbuf
		=> Phaser2.ar(_,rate:0.1)
		=> p.synthVTracks.at(e.key).()
	}.play
});
a = Item(\eyeWillReturn);
P(\IWillReturnVocal,music: { |p b e|
	{0.2 * PlayBuf.ar(1,a.buffer.bufnum, rate:[0.99,1.012]) => FreeVerb.ar(_, mix:0.33, room:0.5, damp:0.5, mul:1.0, add:0.0)
	=> DelayN.ar(_,0.2)
}
// .play
;
	Item(\eyeWillReturn).refresh.play(
		rate: [1,1.01],
		//amp: 0.1,
		amp:0,
		out: Effect.bus( {|i|
				[
					FreeVerb.ar(i,1,1)
					=> HPF.ar(_,300)
					=>.first DetectSilence.ar(_,doneAction:2)
					,
					i
					=> HPF.ar(_,300)
					* 0.9
				]
			}
			//out:1,
			//,inputChannels:2
		)
	)
});
P(\figure,start:\limit,syl:0,music:
	{|p b e|
		[
			legato:2.2,
			freq:[ 3,5,11, 1,4,6,11, 2,5,7,11 ].df('c',octave: 6).q
			++ [1,3,5,11, 2,4,6,11, 2,5,7,12].df('f',octave: 6).q
			,
			amp:0.5 * 0.1,
			dur:
			b.drop(1).parse([1,1,1, 1/3,1/3,1/3,1, 1,1,1,0.5, 0.5,1,1,1, 1/3,1/3,1/3,1, 1,1,1,1,]).q
			,
			out: Effect.bus({|i| Phaser1.ar(i,rate:3,fb:0.6) }),
		].pp
	}
);
P(\double,start:\limit,music:{
		Item(\eyeWillReturnDouble).play(
				//amp: 0.1,
				amp:0.0,
				out: Effect(
						{|i|
								HPF.ar(i,200)
						}
				).bus.index

		)
}
);
P(\bass,start:\limit,music: {|p b e|
	[
		freq:
		//[\r,5,11,11,12,12,13,13,12,11,7,11,7,6,4].df('f',octave: 2) .q ,
		[5,5,11,11,12,12,13,13,12,11,7,11,7,6,4].df('f',octave: 2) .q ,
		dur:b.parse([
			3,
			1,1,
			1,3,
			0.5, [0.5,1,1],
			1,1,1,1,1,1,1,1
		]).q,
		//amp:1
	].pp
	}
);
//P(\tune,start:\limit,music:Song.currentSong.pbind[\limit]);
// P.tune(_ <> [amp:p{\r.yield;loop{0.1.yield}}].p);
["/*SPOCK:*/ Our bodies, Sargon, for what purpose? ", [5,7,5,4,3,2,1,5,3].dm('d',scale:\diminished)].addLine;
P(\tune,start:\purpose,music:Song.currentSong.pbind[\purpose]=>Pbindf(_,\instrument,\stringyy,\amp,0.3)
);
["/*KIRK:*/ (boom) To build. To build humanoid robots. We ",[5,5,11,5,11,7,6,4,6,5,6].dm('e-',scale:\mixolydian)].addLine;
P.synthV(\genbu,range:[0,9], filter: (midinote: _-12),params: {|p b| [
	lyrics: "r,   tu,  bild,        tu, bild,      hyu, ma, noid, ro,   batz",
	legato: [1,   0.9, 1,           1,  0.9,       1,   1,  1,    0.9, 0.5],
	lag: [0,      0,   0,           0,  0,         0,   0,  0,    0,    0],
	phonemes:["", "",  "b i r d y", "", "b i d y", "",  "", "",   "",   "b a t s "]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		// * Env([1,1,0],[b[0..(b.size-2)].sum,0.01]).kr(2,gate:1)
	}.play
});
P(\shaker,syl:1,start:\humanoid,music: {|p b e|		
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
P( \baseline,syl:1,start:\humanoid,music:
[
		freq:[11,11,4,4,11].df('e-',octave: 3).q,
		dur:
		Song.parse(\humanoid,[2,1,2,1,2],2)
		//Song.durs[ 15 ].list
		.q,
].p
);
P(\tune,start:\humanoid,syl:0,music:
		Song.currentSong.pbind[\humaniod]=>_.drop(1)
);
P(\boom,start:\humanoid,music:
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
						dur: Song.parse(\humanoid,[[1,1,1,1,1,1,1,1,1,1/2],[1/2,1]]) .q,
				].p
);
["need your bodies long enough to have the use of your ",[11,6,5,4,7,6,2,1,2,3,4,5,3].dm('g',scale:\mixolydian)].addLine;
P.synthV(\genbu,lag: -1 * Song.durs[P.calcStart(nil)].list.last,take: \longer, filter:(midinote: _-12),
 pbind: {|p b | var e = P.calcStart(nil).postln; [
	 midinote:p.tune[e-1].list.last.bubble ++ p.tune[e].list => _.q,
	 dur: p.durs[e-1].list.last.bubble ++ p.durs[e].list => _.q
 ].p.postln} ,
params: {|p b| [
	lyrics: "wi, nid, ya, ba, diz,     lang, i,  nef, tu,      hav,     ze,    us,      af,     ya",
	phonemes:["","", "", "", "d i z", "",   "", "n a f f",  "t s u", "h a v", "z a", "y u z", "a v ", "y u r y"],
	legato:[1,1,    1,  1,  0.75,    1,    1,  1,   1,       1,       1,     1,       1,      1,          ]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(\genbu, filter:(midinote: _-12), params: {|p b| [
	lyrics: "nid, ya, ba, diz,     lang, i,  nef, tu,      hav,     ze,    us,      af,     ya",
	phonemes:["", "", "", "d i z", "",   "", "n a f f",  "t s u", "h a v", "z a", "y u z", "a v ", "y u r y"],
	legato:[1,    1,  1,  0.75,    1,    1,  1,   1,       1,       1,     1,       1,      1,          ]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});

Song.setTempoMap(\need,"qqq e q q q e e e e e Q Q Q ");

P('click',start:\need,music: {|p b e|
	[
		dur:1!8 => _.warpTo(e.tempoMap.quantizeDft) => _.q,
		instrument: \hihat,
		amp:0.03
	].pp
});
P.tune(\need);
P(\cymbal,start:\need,music:
	(
		instrument:\cymbalsDS,
		amp:0.015,
		out:Effect({|i|i.tanh=>Phaser1.ar(_,0.9,0.2,0.7)*0.4},out:[1,3]).bus.index,
	)
);
P(\baselineC,start:\need,syl:5,music:
	[
		instrument:\stringyy,
		freq:[1,2,3,4].df('d',octave: 3).q,
		dur:Song.parse(\need,[4,3],6).q
		++ Song.parse(\hands,[2,2]).q
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
			)
		]) 
	}
);
( SynthDef(\pulseBase,{
	var freq=\freq.kr(300);
	Pulse.ar([freq/2, freq ],\width.kr(0.3),\amp.kr(0.1))
	* Env.adsr(0.01,0.2,\sustain.kr(1),\release.kr(2)).kr(2,gate:\gate.kr(1))
	=> Out.ar(\out.kr(0),_)
}).add;
);
P(\lick,syl:1,music:{ //SynthDef(\)
		var freq=\freq.kr(400);
		40.collect{ 
			|i| SinOsc.ar(freq*i,0.04) 
			* Env.adsr([((30-i)/90),0.1.rand],0.2,1.0.rand,2.0.rand+2.5).kr(2,gate:\gate.kr(1)) / (i+5)
			* 0.01
		}
		=> Mix.ar(_).tanh
		=> EchoNone.ar(_,0.5,0.3,3)
	}.asSynthDef(name:\dingy).add;
	{ |p b e|
		[
			instrument:\dingy,
			pan:-1,
			freq:[12,11,4].df(octave:6).q ++[14,13,6].df('c',octave: 5 ).q,
			out: [[0,3]].q(3)++[[2,1]].q(3) ,
			//		out: [[0,3]].q(2)++[99]++[[2,1]].q(2)++[99] , //rest hack
			dur:Song.parse(\need,[1,1/2, 1/2,1,1,1,1],2).q,
			dur: b.drop(1).parse([1,1/2, 1/2,1,1,1,1]).q,
			legato:2
		].pp
	}
);
P(\bassline,start:\need,music:
	{|p b e|
		[
			width:0.5,
			sustain:0.6,
			amp:0.05,
			instrument:\pulseBase,
			freq:[11,7].dupEach ++ [6,4,3,2] => _.df('c',octave: 3) => _.q,
			dur: "qe e qe e q q q q".asBeats.warpTo(e.tempoMap.quantizeDft).q
		].pp
	}
);
P(\chords,start:\need,music: {|p b e|
		[
			freq:[[11,11,13],[11,11,13],[7,12,13],[7,12,13],[6,11,13],[6,11,13]].df('c').q,	
			out:1,
			//dur:Song.parse(\need,[1/3,1/3,1/3,[1,1/2],[1/2,1]],).q,
			dur: "q q q q qq".asBeats.warpTo(e.tempoMap.quantizeDft).q
		].pp
	}
);
( SynthDef(\whaFingers, {
	Formants.ar(
		\freq.kr(300,\freqLag.kr(1)),
		Vowel(\a).blend(Vowel(\u), Line.kr(0,1,\length.kr(3),doneAction:0))
		* Env.asr(1,1,\release.kr(1)).kr(2,gate:\gate.kr(1))
	)
	* \amp.kr(0.03)
	=> Out.ar( \out.ir(3) ,_)
} ).add;
);
["hands, your fingers. ",[6,5,4,3].dm('g')].addLine;
P.synthV(\genbu,filter:(midinote: _-12), params: {|p b| [
	lyrics: "hanz yu fin gaz",
	phonemes: ["h a n z ","y u r y","","g a z"],
	legato:[ 0.8, 1, 1, 1 ]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\harmony,start:\hands,music: {|p b e|
				Ppar([
						[
								freq:[6,5].df('c',octave: [5 ]).q,
								out:Effect.bus({|i| 
										EchoNone.ar(i,1,0.8,4) 
										=>.first DetectSilence.ar(_,doneAction:2)
								},out:2 ),
								amp:0.005*1/2,
								dur:Song.parse(\hands,[2,2],).q,
								release:1,
						].pm( \whaFingers),
						[
								out:
								Effect.bus({|i| EchoNone.ar(i,1,0.4,1) 
								=>.first DetectSilence.ar(_,doneAction:2)
						},out:2 )
								,
								amp:0.001*1/2,
								freq:[3,2].df('c',octave: 4).q,
								dur:Song.parse(\hands,[3,1],).q,
								release:1,
						].pm( \whaFingers)
						,
				]).play
		}
);
P(\tune,start:\hands,music:Song.currentSong.pbind[\hands]);
\intend.post;~intend= Song.sections.postln;
["/*SPOCK:*/ Then you intend to construct mechanical ",[3,4,2,3,4,5,6,7,6,5,4].dm('e',scale:\mixolydian)].addLine;
P(\tune,start:\intend,music:Song.currentSong.pbind[~intend]
);
P(\dyad,syl:5,music: { | p b e |
		[
			freq:[5,1,4,[3,5],2,1].df('a',octave: 4).q,
			instrument:\sawSynth,
			amp:0.06,
			dur: b.drop(1).parse([2/3,1/3,1,1,1,1]).q
		].pp
	}
);
P(\bass,start:\intend,music:
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
P(\intoThemBass,start:\move,syl:4,music:
	Song.currentSong.pbind[\move]
	=>Pdrop(5,_)
	=>Pfin(3,_)
	=>Pmul(\freq,1/2,_)
	=>Pbindf(_,\instrument,\pulseBase,\amp,0.02)
);
P(\tune,start:\move,music:Song.currentSong.pbind[~intend+1]
);
P(\bass,start:\move,music:
	[
		freq:[1,1,1,1,2,2,2,2].df('d',octave: 3).q++[3].df('a-',octave: 2).q,
		dur:
		Song.parse(\move,
				(1/3)!6++((1/2)!2) => _.flatten ++ 2
				,)
		.q,
	].p
);
P(\stringyBass,start:\move,syl:6,music:
	[
			freq:[11,7,6.5].df('b-',octave: 2).q,
			instrument:\stringyy,
			dur:Song.parse(\move,[2/3,[1/3,1],1],7).q,
	].p
);
["turn our bodies to us. ",[1,2,3,4,3,5].dm('g',octave: 5)].addLine;
P(\tune,start:'to us',music:Song.currentSong.pbind[~intend+2]
);
P(\bassnote,start:'to us',music:
	(
		freq: [1].df('g',octave: 3),
		dur:Song.parse('to us',[5],),
	)
);
//if args have no numbers, append the section # ?
P(\chord,start:'to us',syl:3,music:
	{
		[ 
			freq:[7,11,13,15].df('g',octave: 3),
			effect:Effect({|i|FreeVerb.ar(i,0.7,0.8) =>.first DetectSilence.ar(_,doneAction:2)},inputChannels:2),
			out:Pfunc({|e|e.effect.bus.index}),
			strum:0.07,
			dur:Song.currentSong.secDur['to us']-0.5,
		].p.fin(1).play
	}
);
["/*MULHALL*/We have engineers, technicians, ",[11,7,11,5,3,5,5,4].dm('f#',scale:\mixolydian)].addLine;
P(\traps, music: { |p b e|
		var div=[3,4].choose;
		[
			dur: "xxxx".asDrumPat(8,reps:12)
			* (b.parse([8]).sum/div*2),
			instrument: \hihat,

			effect:Effect({
					|i| Phaser1.ar(i,0.4,1/5,0.2) 
			//		=> Pan2.ar(_,SinOsc.kr(0.1)) 
					=>.first DetectSilence.ar(_,doneAction:2)
			}),
			out:Pfunc({|e|e.effect.bus.index})
		].p
		//make this into a func ie ||+
		=> {|i| Ppar([i,
			[
				note:Pwhite(10,50),
				instrument:
				\snare
//				\sn
				,amp:0.05,
				dur: "..x.".asDrumPat(8,reps:12)
				* (b.parse([8]).sum/div*2),
			].p
		]) => Pfindur(b.sum + e.bNext.sum,_) => _.play}
	}
);
P(\pedal,start:\technicians,music:
		(instrument:\stringyy,freq:[1,11].df('f#',octave: 2),dur:4,)
		);

//idea: what about auto picking the start from context? ie Song.sections?
P(\tune,start:\technicians,music:
	{
	    Song.currentSong.pbind[\technicians] => Pbindf(_,
			\effect, {Effect(FreeVerb.ar(_,0.9,0.9)).bus.index},
			\out,Pkey(\effect)
	    ) => _.play
	}
);

["why can't they (just) build your robots for you?", [7,6,7,4,2,4,4,3,2,1].dm('f#',scale:\mixolydian)].addLine;
P(\tune,start:\why,music:Song.currentSong.pbind[~intend+4]
	=>Pbindf(_,\effect,
		{Effect(FreeVerb.ar(_,0.9,0.9)).bus.index},
		\out,Pkey(\effect))
);
["/*KIRK:*/ No. Our methods, our skill --s are (boom) ",[12, 12,12,11,7,13,7,11 ,6, ].dm('c')].addLine;
P(\tune,start:\skill,music:Song.currentSong.pbind[~intend+5]
);
P(\chords,start:\skill,music:
		[
				freq:[
						[5,6.5],
						[5,6.5], [4,6],
						[5,7],[5,11],
						[6,11]
				].df('c',octave:4).q,
				dur:Song.parse(\skill,[1, 1,3, 2,1, 1],).q,
				instrument:\sawSynthSustain,
				amp:0.06
		].p
);
["far , far beyond your abilities. It is. ",[14, 14,13,13,14,13,12,7,3, 5.5,5.5,5.5].dm('c')].addLine;
P(\tune,start:\far,music:Song.currentSong.pbind[~intend+6]
);

Song.lick=Array.series(4,0,2).collect(_+[11,12,7.5,11].dm('c#',octave:5,scale:\diminished )).flatten ;
["time dum dum dum dum dum etc ",Song.lick].addLine;
//(They help him back to Sargon's sphere.)
P(\lick,music:Song.currentSong.pbind[\dum]
	=>{
		|i|
		Ppar([i,
			i=>Pbindf(_,\instrument,\stringyy,\amp,0.3)
			=>Pmul(\freq,1/2,_)

		]);
	}

);
)



