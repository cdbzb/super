(
	   { |gate=1 out=0 freq = 400| //bar synthdef
		   var in=PinkNoise.ar(1);
		   var sig=Pluck.ar(in: in,  gate: gate,  maxdelaytime: 0.02,  delaytime: 1/freq,  decaytime: \decaytime.kr(10),  coef: \coef.kr(0.5),  mul: 0.7,  add: 0);
		   sig = sig * \amp.kr(0.1) * 10;
		   sig = LeakDC.ar(sig);
		   sig = sig * Env.asr.kr(2,gate:gate);
		   Out.ar(out,sig);
		   DetectSilence.ar(sig,doneAction:2);
	   } => SynthDef(\bar, _) => _.add;

   p = ();
   ( //verse
	   e = EventList(\verse, \default).current.clear;
	   ( //tempoMap
		   m = AnchorMap([-1,100], [-1.015, 1.015 * 100 ], \beat, \sec)
		   // .ritardSpan(0, 2, w:0.4, q:2.5, pinEntry: true)
		   ;
		   m = m.setSlope(m.spanSlope(1.99,2), 2, 100); //continue slope after rit
		   e.tempoMap = m;
	   );

	   \hat.add(0, [
		   instrument: \hat_808,
		   dur: 0.5,
		   amp: 0.05

	   ].p.fin(14));
	   \shortBass.addPattern(0, [
		   midinote: [ 11, 7, 4, 5, 5, 5, 5  ]
		   .collect{|i| {i.dm(~tonic ? \c, 3)}}
		   // .dm( \c, 3)
		   .dupEach  => _.q,
		   dur: "x xxx".beats.q(inf),
		   instrument: [\harp, \sawSynth ], 
		   coef:0.8, amp:[0.03, 0.1],
		   // out: EffectNarrow.bus({|i| i + DelayN.ar(
		   //  i, 
		   //  e.secPerBeatAt(0,1) * 0.25,
		   //  e.secPerBeatAt(0,1) * 0.25,
		   // )}),
		   rel:0, att:0.1
	   ].p.fin(16 * 2));
	   \voxA.add(0,
		   sv: a = SynthVVST(\an2, [
			   midinote: [1, 3, -7, 1, 2, 3, 2].dm(~tonic ? \c),
			   dur: "q q q q q Q E qq".beats / 2 
			   => _.mapSpansFrom(0, {|x| e.beatToWall(x, e.tempoEnv)}),
			   lyrics: " 霓 虹 灯 照 亮 我 的 脸",
			   pitchTake: 1,
			   vmSoft: Env([65,65], [0, 10]),
			   language: \mandarin,
		   ]).build,
		   func: { ~sv.play({|i|  i /4 => _[0]}, tail:4) }
	   );
	   p.sixteenthBassFunc = { |freq dur|
		   {
			   var f = freq.poll.asArray;
			   var duty = f.collect { |fc| Duty.kr(dur.(), 0, fc, doneAction: 0) };
			   VarSaw.ar(duty.flat * [0.993, 1.0015] *.x [2, 2], pi/2, 0.7)
			   * Env.perc(0.005, 0.3).kr(0, gate: TDuty.kr(dur.(), 0, 1, doneAction: 2))
			   => RLPF.ar(_, 800 + SinOsc.ar(0.31).range(0, 300))
			   /20
		   }
	   };
	   \sixteenthsBass.add(0, 
		   durs: { |x| (0.25 ! 28).mapSpansFrom(0, ~secsFor) },
		   func: {
			   var tonic = ~tonic ? \c;
			   s.bind{
				   p[\sixteenthBassFunc].(
					   freq: { [1, -7, -4, [-4,-5], [-4,-5], [-4,-5], [-4,-5]].df(tonic, 3).dupEach(4).dq },
					   dur:  { { ~durs.dq } }
				   ).play
			   }
		   }
	   );

	   \click.addPattern(7, 
		   [
			   instrument: \hat_808,
			   dur: 0.5,
			   amp: 0.05
		   ].p.fin(16);
	   );
	   \claves.addPattern(7, [
		   instrument: \claves_808,
		   dur: "x e e e e e e e e e e".beats.q,
		   rests: MuteFirst(),
		   amp: 0.02
	   ].p.fin(16)
   );
   \shortBass.addPattern(7, [
	   midinote: [ 11, 6.5, 4, 2, 2  ]
	   .collect{|i| {i.dm(~tonic ? \c, 3)}}
	   // .dm(\c, 3)
	   .dupEach.q,
	   dur: "x xxx".beats.q(inf),
	   instrument: [\harp, \sawSynth ], 
	   coef:0.8, amp:[0.03, 0.1],
	   rel:0, att:0.1
   ].p);
   \voxB.add(7,
	   sv: SynthVVST(\an2, 
		   [
			   midinote: [3, 5, 2, 3, 4, 6, -7, -7].dm(~tonic ? \c),
			   dur: "e e e e e E X q".beats 
			   => _.mapSpansFrom(7, {|x| e.beatToWall(x, e.tempoEnv)}),
			   lyrics: "手 机 屏 幕 又 暗 又 冷",
			   vmSoft: Env([60,60], [0, 10]),
			   pitchTake: 1, 
			   language: \mandarin
		   ]
	   ).build
	   ,func:{ ~sv.play({|i| i /4 => _[0] }) }
   );
   \sixteenthsBass.add(7, durs: { (0.25 ! 28).mapSpansFrom(0, ~secsFor) },
   func: {
	   var tonic = ~tonic ? \c;
	   s.bind{
		   p[\sixteenthBassFunc].(
			   freq: {[1, -6.5, -4, -2, -2].df(tonic, 3).dupEach(4).dq},
			   dur: {{~durs.dq}},
		   ).play
	   }
   }
);

\shortBass.add(12, [
	midinote: [ 11, 7, 6, 5, 4.5, 2, -7, -7, 3, 13  ]
	.collect{|i| {i.dm(
		~tonic ? \c, [2,3]) + 3}}
	// .dm(\c, [2,3])
	.dupEach  => _.q,
	dur: "x xxx".beats.q(inf),
	instrument: [\harp, \sawSynth ], 
	coef:0.8, amp:[0.03, 0.1] ,
	rel:0, att:0.1,
].p );

\bass.addPattern( 12,
	[
		midinote: [ 11, 7, 6, 5, 4.5, 2, -7, -7, 3, 13  ].collect{|e| 
			{ e.dm(~tonic ? \c, [2]) + 3 }
		}
		// .dm(\c, [2]) + 3
		=> _.dupEach(4) => _.q,
		dur: 1/4,
		// amp:Pfunc{{Pseries(0.15,0.001,100) * ~bassAmp.debug("PPP") ? 1}},
		amp:Pseries(0.15, 0.001, 100).collect{|a| {a * (~bassAmp ? 1)}},
		legato: 0.7
	].p
);
e.add(12,instrument:\cymbalsDS, amp:0.01, att:0.1);
\voxC.add( 12,
	sv:  
	{
		b = SynthVVST(\an2,
			[
				// midinote: "-1 5 2 3 1/f 7.5 3 4 5 11 1 3 4/b/minor/4 4 3 -5/d".dm2,
				midinote: ([-1, 5, 2, 3, 1].dm(~tonic ? \c) + 3) ++ ([7.5, 3, 4, 5, 11, 1, 3, 4].dm(~tonic ? \c, \minor) - 3) ++ ([4, 3, -5].dm(~tonic ? \c)) => _.flat ,
				dur: "e x xe x xe x xe x xe x xe x xeqqe e x xe".beats
				=> _.mapSpansFrom(12, {|x| e.beatToWall(x, e.tempoEnv)}),
				lyrics: "r 万 家 灯 火 像 星 星	但 我 依 然 感 觉 好 孤 寂 ",
				pitchTake: 1,
				vmSoft: Env([60,10], [0, 5]),
				language: \mandarin
			]
		).build
	}
	,
	func: {
		~sv.play( 
			{|i| CombN.ar(i, 0.4, 0.4)/3 + i => _.[0] /5}
			// I.d
		)
		// => p.synthVTracks.at(e.key).()
	}
);

e.preview_(true);
);

   ( //chorus
	g = EventList(\chorus, \default).current.clear;
	g.tempoMap = e.tempoMap;
	   ~lines = VoiceLeading(
		   [
			   [1,  \_, 4, \_, 5, 4.5, 4,  3,  2 ],
			   [-5, \_, 1, 2,  3, \_,  -6, -5, \_ ]
		   ],
		   [2, 2, 2, 2, 1, 1, 2, 2, 2, 2]
	   ).dm(\c);
	   \bg.add(0,
		   sv: 2.collect{|voice| 
			   b= SynthVVST(\mo2,
				   [

					   midinote: ~lines.voice(voice).line,
					   dur: ~lines.voice(voice).durs
					   => _.mapSpansFrom(0, {|x| g.beatToWall(x, g.tempoEnv)})
					   ,

					   lyrics: "ooh - - -",
					   pitchTake: [ 1, 3 ], 
					   language: \English,
				   ]
			   ).build },
			   func:{
				   ~sv.do{|e| 
					   e.play(
						   {|i| i => BPF.ar(_, 1200, 0.3) /2 }
					   )
				   } 
			   }
		   );
		   // g.preview_(true);
		   \keys.add(0,
			   newType:\mi2,
			   mk: MicroKeys(\stringyy).synth_(\stringyy, [mix:0, release: 1])
			   .add(\quiet, {|e| e.vel.notNil.if{e.vel = e.vel / 5}; e}, \addBefore, \synth),
			   player: MIDIItem("_250116_165156").take(9)
			   .filter({|e| e.collect{|i| i.timestamp_( i.timestamp * 
				   // Song.tempo * 
				   1.02 //fusge factor why??
			   )}})
			   ,//.gui
			   followTrack:true
		   );
		   \bassFigure.add(0,
			   [
				   midinote: [ 
					   60, //\r,
					   60, 62, 64, 59,
					   57, 60, 62, 64, 60, 
					   53, 60, 62, 64, 60, 
					   50, 60, 62, 64, 50,//60, 
					   55, 59, 60, 62, 59,// 53,
					   // 53, 60, 62, 64, 60, 
					   53, 57, 59, 60, 57,
					   50, 60, 62, 64, 60,
					   55, 59, 60, 64, 55, 
					   // 48 
				   ].q - 24,
				   legato: [
					   0.8,
					   [1, 1, 1, 1, 0.8].q(8)
				   ].q,
				   dur: "qq e e e e".beats.dup(10) / 2 =>_.flat => _.q,
				   out: EffectNarrow.bus({|i| i.tanh ! 2 => {|i| CrossoverDistortion.ar(i, smooth: 0.995)/3 + i} },),
				   instrument: \sawSynthSustain,
				   pulse: 0.5,
				   out: 3
			   ].pma
		   );
		   // bass figure idea
		   // g.addItem( MIDIItem("bassFigure_250116_161952").take(18), at:0, mk:MicroKeys(\harp),);
		   \altVox.add(
			   when: 0,
			   newType: \audioItem,
			   item: "neon2_nil_pitch_lead",
			   finish: { ~out = EffectNarrow.bus({|i| Pan2.ar(i, 0) }) },
			   take: 0,
			   numChannels: 1,
			   amp: 1/3
		   );
		   g.add(0, name:\vox, sv:
			   SynthVVST( \an2, [
				   dur: [ 0.968550166, 0.981686875, 0.931762042, 0.402953125, 0.31382825, 0.352575917, 0.927995083, 0.915147292, 0.822114291, 0.177609834, 0.661958125, 0.831168875, 1.395617541, 0.484949792, 0.258637125, 0.752724667, 0.245841166, 1.136198042, 1.001960917, 0.991963666, 1 ] 
				   /
				   0.97
				   => _.mapSpansFrom(0, {|x| g.beatToWall(x, g.tempoEnv)})
				   // *
				   // e.secPerBeatAt(0)

				   // *1.015
				   // /0.97
				   ,
				   midinote: 
				   [\r, 64, 67, 72, 74, 72, 69, 65, 72, 76, 77, 76, 76, 79, 77, 76, 74, 72, 67, 65, 64 ],
				   lyrics: "r 滑 动 屏- - - 幕 寻 找 共 - - 鸣 数 据 海 洋 中 迷 失 自 己",
				   pitchTake: [ 1, 3 ],
				   language: \mandarin,
				   singers:2
			   ]
		   ).build,
		   func: { ~sv.play({|i|  i /4 => Splay.ar(_)  }, tail:1) }
	   );
	   \bassline.addPattern(0,
		   [
			   freq: [11, 7, 6, 5, 4, 3, 2, 1, -7, -7, 4, 3, 2, 2, 5, 5].df(\c, [3,3]).dupEach(4).q,
			   dur: 1/4,
			   instrument: [
				   \bar , \sawSynth],
				   coef: 0.15, amp:[0.01, 0.04],
				   // rest: [1, \r].q(inf),
				   rel:0.1,
				   legato: 0.6,
			   ].p
		   );
		   p.swing=0.1;
		   \tamb.add(newType: \func, func: { |ev|
			   s.bind{
				   {
					   var levels = [3,1,2,1] /3 => _.dq(inf);
					   var durs =  
					   1/8 ! 16 
					   // / 2 
					   // => _.mapSpansFrom(0, {|x| g.beatToWall(x, g.tempoEnv)})
					   => _.mapSpansFrom(0, {|x| ev[\secsFor].(x)})
					   // + ( [1, -1] /80 => _.dup(8) ) //swing amt
					   + ([1, -1] * p.swing)
					   => _.flat 
					   // => _.warpTo(e.tempoMap.quantizeWindow(0.3))
					   => _.dq(8 
						   // * 2
					   );
					   var triggers = TDuty.kr( durs, 0,1,gapFirst:0 );
					   var energy = EnvGen.ar( Env.linen(0, 0.00, 0.015), triggers, doneAction:0   ) 
					   * Demand.kr(triggers,0,levels 
						   // * 40
						   // *8
					   );
					   Shakers.ar(3, energy:energy   , decay: 1).tanh

					   // /5
					   * 2
					   => Pan2.ar(_, 0.8)
					   // * EnvGen.cutoff(b.parse([4]).unbubble,3)
					   => DWGReverbC1C3.ar(_,mix:0.05)
					   /12
					   => Pan2.ar(_,0.75)
					   => Out.ar(1, _)

				   }.play
			   }
			   }
	   );
	   \hat.addPattern(0,
		   [
			   instrument: \hat_808, 
			   dur: "x x e x x e  x x x x x x e".beats.q(8) / 2,
			   pan:0.5,
			   amp: 0.05
		   ].p
	   );
	   \cymbals.add( instrument: \cymbalsDS, amp:0.02);
	   \drums.addPattern(0,
		   [
			   inst: [0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1].q(4),
			   mask: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, \r, 1, 1].q(4),
			   instrument: Pfunc({|e| [\bd_808, \JWSnare][e.inst]}),
			   decay: 12,
			   accent: 
			   [1, 1, 0.5, 1, 1, 1]
			   ++ [1, 1, 0.5, 1, 0.5, 1, 1]
			   =>_ .q(inf),
			   amp: Pfunc({|e| [0.14, 0.15][e.inst] * e.accent}),
			   dur: [1, 0.75 
				   // + p.swing
				   , 0.25
				   // - p.swing
				   , 0.5, 0.5, 1]

			   ++ [1, 0.75 + 0.03, 0.25-0.03, 0.25, 0.25,  0.5, 1]
			   /2

			   =>_
			   .q(inf),
			   // transientFreq: [0, 200, 200, 0, 0, 200].q(inf),
			   // resonanceLength: 0.0905, 
			   // resonanceFreq: 86,
		   ].p;
	   )
		   // g.play
	   );

   EventList(\verseBass, \eventList).clear.add( section:\verseBass, with:(bassAmp:1), eventList:\verse);

   // f.add(section:\verse, eventList:\verseBass, dur: 22);

   ( //verse2 
	   h =EventList.sequenced(\verse2, \default).current.clear;
	   // h.tempoMap=EventList(\verse).tempoMap;
		 h.add(section:\verse2, eventList:\verseBass, dur: 22);
		 \cymbal.add( instrument:\cymbalsDS, amp:0.02);
		 \mw.add( 3, newType:\audioItem, item:"_260903_113412",start: 
			 EventList(\verse).secPerBeatAt(25) * 3, out:{ EffectNarrow.bus({|i| CombN.ar(i, 0.4, 0.4)/2  + i },)}, amp:1, record:false);
		 \mwDbl.add( 3, newType:\audioItem,item:"double_260903_113412",start: 0, out:{ EffectNarrow.bus({|i| CombN.ar(i, 0.4, 0.4)/2  + i => Pan2.ar(_,1) },)}, amp:0.3, record:true);
   );
   ( // chorusFlatFive
	   EventList(\chorusFlatFive, \default).current.clear;
	   \bassline.addPattern(0, [
		freq: [11, 5, 6.5, 5, 4, 2.5, 2, 1, -7, -7, 4, 3, 2, 2, 5, 5].df(\c,[3, 3]).dupEach(4).q,
		dur: 1/4,
		instrument: [
			\bar , \sawSynth],
		coef: 0.15, amp:[0.01, 0.04],
		// rest: [1, \r].q(inf),
		rel:0.1,
		legato: 0.6,
	].p
	   );

		   \keys.add(0,
			   newType:\mi2,
			   mk: MicroKeys(\stringyy).synth_(\stringyy, [mix:0, release: 1])
			   .add(\quiet, {|e| e.vel.notNil.if{e.vel = e.vel / 5}; e}, \addBefore, \synth),
			   player: MIDIItem("_250116_165156").take(9)
			   .filter({|e| e.collect{|i| i.timestamp_( i.timestamp * 
				   // Song.tempo * 
				   1.02 //fusge factor why??
			   )}})
			   	
		.filterNotes({|n x|var count=0; n.collect {|e| (e.midinote==6.dm(\c) and: (count == 0)).if{e.midinote_(6.dm(\c, 5,\minor));count = count + 1; e}{e}} })
			   ,//.gui
			   followTrack:true
		   );

   );
   ( // verseD
	   d = EventList(\verseDVox, \default).current.clear;
	   d.tempoMap=e.tempoMap;

	   \vox.add(0,
		   sv: {
			   SynthVVST(\mo2,[
				   midinote: [1, 3, -7, 1, 2, 3, 2].dm(~tonic ? \c),
				   dur: "q q q q q Q E qq".beats / 2  
				   => _.mapSpansFrom(0, ~secsFor)
				   ,

				   lyrics: "像 素 心 碎 成 玻 璃",
				   pitchTake: 1,
				   language: \mandarin
			   ]).build
		   }, func:{ |i|
			   ~sv.play( {|i| CombN.ar(i, 0.4, 0.4)/3 + i / 5})
		   }
	   );

	   \vox.add(7,sv: {
		   SynthVVST(\mo2,[
			   midinote: [3, 5, 2, 3, 4, 6, -7, -7].dm(~tonic ? \c),
			   dur: "q q q q q Q E qq".beats / 2 
			   => _.mapSpansFrom(0, ~secsFor)
			   ,

			   lyrics: "耳 机 里 只 有 回 声",
			   pitchTake: 1,
			   language: \mandarin,
		   ]).build
	   },
	   func:{|i|
		   ~sv.play( {|i| CombN.ar(i, 0.4, 0.4)/3 + i / 5})
	   }
   );

   \vox.add(12,sv: {
	   SynthVVST(\mo2,[
		   midinote: ([-1, 5, 2, 3, 1].dm(\d) + 3) ++ ([7.5, 3, 4, 5, 11, 1, 3, 4, 3, 1.5, -7.5].dm(\d, \minor) - 3)  => _.flat ,
		   // dur: "e x xe x xe x xe x xe x xe x xeqqe  e x xe".beats * Song.tempo
		   dur: "e x xe x xe x xe x xe x xe x xqq  qq qq qq q ".beats 
		   => _.mapSpansFrom(0, ~secsFor)
		   ,

		   lyrics: "r 高 楼 电 梯 上 下 行   人 群 中 没 有 - - -" //姓 - 名"
		   ,
		   pitchTake: 1,
		   language: \Mandarin
	   ]).build
   }, func:{|i| ~sv.play( {|i| CombN.ar(i, 0.4, 0.4)/3 + i / 5}) }
);
// d.play
   );
   ( // bridge
	   v = EventList(\bridge, \default).current.clear;
	   \chords.addPattern(0, 
		   [
			   freq: [
				   [3, 5, 11].df(\e, \minor),
				   [5, 11, 13].df('b-', 4)
			   ].q,
			   dur: 2,
			   instrument: \sawSynthSustain,
			   coef: 0.2,
			   amp: 0.04
		   ].pm;

	   );
	   \chords.addPattern(4,
		   [
			   freq: [
				   [5, 11, 13].df('a-'),
				   [5, 11, 13].df(\g,~bridgeChordQuality ? \minor, 4)
			   ].q,
			   // lag: 4 * Song.tempo,
			   dur: 2,
			   instrument: \stringyy,
		   ].pm
	   );
	   \vox.add(7, sv:
		   SynthVVST(\mo2,
			   [
				   midinote:  [4, 3, -5].dm(\c),
				   dur: "e x xe".beats,
				   lyrics: " 姓 - 名",
				   pitchTake: 1,
				   language: \mandarin
			   ]
		   ).build, 
		   func: { ~sv.play({|i|  
			   i => {|i| CombN.ar(i, 0.4, 0.4)/3 + i}
			   /5
		   }, tail:1) }
	   );

	   // v.play(7)
   );
   ( //full song sequence
	   f = EventList.sequenced(\song, \eventList).clear;
	   f.tempoMap = e.tempoMap.fromBeat(0,22) ++ e.tempoMap;

	   f.section(\verse2, with:(tonic:\c));

	   f.section(\chorusFlatFive,comment:\keysAndSixteenths, followTrack: true);
	   f.add(name: \drumsAndBg, eventList:\chorus, solo:[\drums,\cymbal, \tamb, \bg]);
	   f.add(eventList:\verse2, solo:[\mw]);

	   f.section(\chorus, mute:[\altVox, \hat], followTrack: true, dur:16);

	   f.section(\chorus,section:\foo,
		   // solo:[\altVox],
		   mute:[\cymbals,\vox, \hat], 
		   followTrack:true);

	   //add verse in D but mute an and add mo
	   f.section(\verse, section:\shortVerseInD, with:(tonic:\d), mute:[\vox],dur:18 );
	   f.add(0, eventList:\verseDVox, with:(tonic:\d) );

	   f.section(\bridge,followTrack:true);
	   f.add(eventList:\chorusFlatFive,mute:[\chord, \an, \cymbals,\vox, \hat],followTrack:true );
	   f.add(eventList:\chorus, solo:[\bg, \drums, \hat, \tamb]);
	   f.add(16, eventList:\chorus,mute:[\cymbals, ], followTrack:true);
   );
   
// AudioItem("_260903_113412").record
   f.preview_(true)
   )