(
	"/Users/michael/tank/super/Trek/Songs/11-Xtreme1.scd".load;
["/*SPOCK*/ -boom- This is an excellent body, Doctor." ,"1 -7 1 2 6 7 6 5 5 6 4 1 -7".dm(\f,\mixolydian)].addLine;
Song.setTempoMap(\excellent,"e e e x x | ex x e x ex | ee ee ee ee");
P.still(\henochExcellent, timecode: 
	// 2828.1
	2821.1
	.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["this is an excellent","body Doctor"],
	)
});
Song.synthVTracks.ninezero = {|mix = 0.1| {|i| DWGReverbC1C3.ar(i, mix: mix) / 2.5}};
P.synthV(role: \henoch, take: \lead,
	pbind: Song.enlarge(11),
	params: {|p b| [
	lyrics: " r This is an excellent - + + body - + Doctor + I seem to have received + the best of the three",
	legato: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.6, 1, 0.6, 1, 1, 1,1, 1, 1, 1, 1 ],
	pitchTake: 1,
	paramTension: -0.25,
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P(\click, music: { |p b e|
	[
		dur: "q q q q q q q q".asBeats.warpTo(e.tempoMap.quantizeDft(0.2)).q,
		instrument: \hihat, pan: 0.5
	].pp
});
P(\bassNote, music: { |p b e|
	(
		freq: 1.df(\f,[4,3]),
		instrument: \sawSynth,
		out: [0,2]
	).play
});
P(\clav, music: { |p b e|
	[
		freq: [7, 11, 5,  4,  2].df(\f,3,\mixolydian).q,
		dur: "e e qqq qq qq".asBeats.warpTo( e.tempoMap ).q,
		out: Effect.bus({|i| SineShaper.ar(i, 0.2) * 1.35 },)
	].pp
});
["I seem to have received the best of the three. ","1 -5 -7 1 2 -6 1 4 3 2 1".dm(\e)].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["I seem to have received","the best of the three"],
	)
});
Song.setTempoMap(P.calcStart(),"e Q E Q E e e q e e q");
P.tune();
P(\cymbal,syl:9, music: { |p b e|
	(
		instrument: \cymbalsDS, 
		att:0.2, 
		amp:0.02
	).play
});
P(\click, music: { |p b e|
	[
		dur: "e q q e q q q q".asBeats.warpTo( e.tempoMap ).q,
		rest: [\r, 1, 1, 1, 1, 1, 1].q,
		instrument: \hihat
	].pp
});
P(\bassNote, music: { |p b e|
	[
		freq: [\r, -5, -6].df(\e,4).q,
		dur: b.parse([1,4]) ++ 0.5 => _.flat => _.q,
		instrument: \sawSynthSustain,
		out: Effect.bus({|i| Pan2.ar(i,-1) },)

	].ppm;
	[
		freq: [\r, 2, 1].df(\e).q,
		dur: b.parse([4, 2,1]).q,
		instrument: \sawSynthSustain,
		out: Effect.bus({|i| Pan2.ar(i,1) },)
	].ppm
});
["-boom- Strength, -boom- hearing, -boom eyesight + all","-1 4 2 4 3 -7 2 1 6".dm('e-',\mixolydian)].addLine;
P.still(\clear,syl:0, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum + e.bNext.sum,
		text: ["strength","hearing"],
	).sequenceText2(
			b.parse([4,1,2,1]) + [0,0,0,e.bNext.sum], [ 
			["",""],
			["eyesight", ""],
			["all far above","your human norms"]
			],
	)
});
Song.setTempoMap(\Strength,"q q Q Q Q Q Q Q q ");
P(\bassline, music: { |p b e|
	[
		freq: [1, 2, -7, -7.5].df('e-',3,\mixolydian).q,
		dur: b.parse([2, 3, 3, 1]).q,
		// mask: [\r, 1, 1, 1].q,
		amp: [2, 2, 2, 1]/20 => _.q,
		instrument: [\default, \default, \default,  \sawSynthSustain].q,
		legato: [1, 1, 1, 4, ].q,
	].pp
});
P(\tamb, music: { |p b e|
	{
		var levels = [5,1,2,1] /5 => _.dq(inf);
		var durs =  
		1/4 ! 21
		+ ( [1, -1] /50 => _.dup(8) )
		=> _.flat 
		=> _.warpTo(
			e.tempoMap.quantizeDft(0.5)
		)
		=> _.dq();
		var triggers = TDuty.kr( durs, 0,1,gapFirst:0 );
		var energy = EnvGen.ar( Env.linen(0, 0.00, 0.015), triggers, doneAction:0   ) 
		* Demand.kr(triggers,0,levels 
			// * 40
			// *8
		);
		Shakers.ar(3, energy:energy   , decay: 1).tanh
		=> Pan2.ar(_, 0.8)
		* Env([0,0,1],b.parse([7])).kr(0,gate:1)
}.play;

});
P.synthVs(role: \henoch, take: [ \lead, \double ], params: {|p b| [
	lyrics: "r strength r hearing + r eyesight + all",
	paramTension: -0.25,
	// legato: [ [1, 1, 1, 1, 1, 1, 1, 0.7, 0.7 ] ],
	pitchTake: [ 1, 3 ]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> {|i| i + 
			(

				Env([1,1,0],b.parse([1, 2, 2])).kr(gate:1) * i
				=> CombN.ar(_,0.5,0.4, 3)
			)
		}
	}.play

});
[" far above your human norms. "," 7 6 3 6 7 11 4".dm(\d,\dorian)].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 /* e.still.( 
		wait: b.sum,
		text: ["far above","your human norms"],
	) */
});
Song.setTempoMap(\norms,"Q E Q E Q E q");
P(\tamb, music: { |p b e|
	{
		var levels = [5,1,2,1] /5 => _.dq(inf);
		var durs =  
		1/4 ! 21
		+ ( [1, -1] /50 => _.dup(8) )
		=> _.flat 
		=> _.warpTo(e.tempoMap
			.quantizeDft(0.5)
		)
		=> _.dq();
		var triggers = TDuty.kr( durs, 0,1,gapFirst:0 );
		var energy = EnvGen.ar( Env.linen(0, 0.00, 0.015), triggers, doneAction:0   ) 
		* Demand.kr(triggers,0,levels 
			// * 40
			// *8
		);
		Shakers.ar(3, energy:energy   , decay: 1).tanh
		=> Pan2.ar(_, 0.8)
}//.play;
});
P(\hat, music: { |p b e|
	var tm = e.tempoMap.quantizeDft(0.3);
	[
		dur: "x*16".beats.warpTo( tm ).q,
		instrument: \hihat,
		amp: [3,1].q(inf)/30,
		out: Effect.bus({|i| Phaser2.ar(i,rate:0.2) },)
	].pp;
	[
		dur: "e eq e eq".asBeats.warpTo( tm ).q,
		// instrument: \bd_808,
		instrument: \kick_gentle, pitch: 1.df(\d,3),
		tone: 45,
		vol:0.05
	].pp;
	[
		dur: "q qq q".asBeats.warpTo( tm ).q,
		rests: [\r, 1, 1, 1].q,
		instrument: \sn_808, amp:0.05
	].pp
});
P.synthVs(role: \henoch, take: [ \lead, \double ], params: {|p b| [
	lyrics: "far above + your human + norms. ",
	paramTension: -0.25,
	pitchTake: [ 1, 3 ]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P(\bass, music: { |p b e|
	[
		dur:"e e e e e e e".asBeats.warpTo( e.tempoMap ).q,
		freq: " 7 6 3 6 7 11 4".df(\d,3,\dorian).q,
		instrument: \sawSynth
	].pp
});
P.tune();
["Im surprised the Vulcans never conquered your race. "," 4 5 -7 3 1 -7 1 2 5 4 6 2 ".dm(\f, \harmonicMinor)].addLine;
P.still(\wide, timecode: 2826.5.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["I'm surprised the vulcans","never conquered your race"]
	)
});
P.synthVs(role: \henoch, take: [ \lead, \double ], params: {|p b| [
	lyrics: "I'm surprised + the Vulcans + never + conquered + your race. ",
	pitchTake: [ 1, 3 ],
	vocalMode: \Muted,
	paramTension: -0.3,
	// filter: (midinote: _ - 12), 
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P(\bass, music: { |p b e|
	[
		// freq: [3, 4, 3, 2.5].df(\c,3).q,
		// freq: [3, 4, 2.5].df(\c,3).q,
		freq: [3, 1, 4, 2.5].df(\c,3).q,
		// dur:b.parse([4,1, 5, 2]).q,
		dur:b.parse([2, 2, 4, 3]).q,
		instrument:\default,
		amp:0.1
	].ppm;
{
		var durs = b.parse([2,2,4,2 ]);// .postln;
		var trig = TDuty.ar(durs.dropLast().dq, gapFirst:0   ) => OnePole.ar(_);
		var freqs = [3,1,  4, 12.5].df(\c,3);

		Gendy4.ar(minfreq: freqs.dq.demand(durs), maxfreq: freqs.dq.demand(durs) + 0.05)
		* (Decay.ar(trig => HPF.ar(_,1)))
		=> FreeVerb.ar(_,0.1,1)
		=> Pan2.ar(_)
		=> LPF.ar(_,1000)
		/5
		// /3
		// * Env.perc().kr(0,gate:trig)
	}.play

});
	//get this from reaper (HOOK) "/Users/michael/Trek/Vulcan's worship peace/Vulcan's worship peace.RPP" => {|i| ( "open "+i ).unixCmd }
["/*MCCOY*/ Vulcans worship peace above a-- ll, Henoch. ",[5,5,4,4,3, 2,1,2,3, -6,-5].dm('d')].addLine;
P.still(\mccoyspx, timecode: 2834.5.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["Vulcan's worship peace","above all, Henoch"],
	)
});
	Song.setTempoMap(\worship,"e e e e qqq e e e eq q q");
	Trek.initClass;
P.synthVs(role: \mccoy, take: [\lead, \double], params: {|p b| [
		lyrics: "vulcans + worship + peace above + all - Henock +",
		pitchTake: [1,3],
		vocalMode: \Light
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
P.synthV(\feng, take: \harmony,
		pbind:{|p b|
			[

				dur: "e e e e qeeq qeeq e e e e e ".asBeats.warpTo(Song.tempoMap[\worship]) 
				+ [0,0,0,0,0,0,0,0,0,0,1] =>_.q(2),
				midinote: "6 6 6 6 5 r 6 6 6 6 5 ".dm(\d).q
			].p
		},
		// filter: (midinote: "6 6 6 6 5".dm(\d)), 
		params: {|p b| [
			lyrics: "vulcans  + worship + peace r vulcans + worship + peace",
			pitchTake: 2,
			vocalMode: \Airy,
			paramBreathiness: 0.5,
			loudness: Env([0,0,-20],[b.sum/2,b.sum/2 +2])
		] }, music:{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
				=> Pan2.ar(_,-1)
			}.play
});
P.double(\feng, take: \harmony, params: {|p b| [

		] }, music:{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
				=> Pan2.ar(_,1)
			}.play
});
		// ~justTheTune.('worship');
~quarters[\worship] = Song.parseBeats('worship',"e e e e qqq e e e eq q q".asBeats);
//Song.tempoMap[\worship]=Song.tempoMap[\worship].quantize;
P(\harmonyPart,start:'worship',music:{|p b e|
			[
				freq:[2,2,2,2,1].df('a',octave:5 ).q,
				dur:b.parse([1,1,1,1,1]).q,
			].pp
});
P('key',start:\worship,music: {|p b e|
			[
				freq: [\r,3,1, 3, 2, 2, 1, 2, 3, 2, 1].df(\d,octave:6).q,
				dur: [4,2,1,1,2,1,1, 1,1,1,1]/2 =>_.warpTo(e.tempoMap) =>_.q,
				out: 
				Effect.bus({|i| CombC.ar(i,1,b[0]) * 0.5 + i})
			].pp
});
P(\bass,start:'worship',music:{|p b e|
			[
				freq:[4,4,5,5,11,11,5,5,5,6,7].df('d',octave:3 ).q(2),
				dur: "e e e e qe e e q e qe e".asBeats.warpTo(e.tempoMap).q(2),
				instrument: \sawSynth
			].p => _.fin(15) => _.play
});
		P('drum',start:\worship,music: {|p b e|
			var volScale = 0.7;
			[
				dur:0.5.dup(20).warpTo(e.tempoMap).q ,
				rest:[1,1,\r,1,1,\r,\r,\r].q(inf),
				//instrument:\bd_808,
				instrument:\kick_gentle,
				vol:0.15 * volScale
			].pp;
			[
				dur:1.dup(16).warpTo(e.tempoMap).q,
				rest:[\r,1].q(8),
				instrument:\sn_808,
				amp:0.08  * volScale
			].pp;
			[
				dur:0.5.dup(19).warpTo(e.tempoMap).q,
				instrument:\hihat,
				ffreq:[4400,6600].q(inf),
				amp:[\r,\r,\r,\r].q++[0.1,0.07].q(inf) /3

			].pp;
			[ instrument:\cymbalsDS,amp:0.01,rest:[\r,1].q,dur:[2,1].warpTo(e.tempoMap).q ].p.play
});
P(\pianoWorship,start:'worship',music:{|p b e|
			[
				freq:[-6,-6, -5,1,3,2,-5].df('d',octave:5 ).q,
				pan:3/4,
				dur:~quarters['worship']
				//		.quantizeWindow
				.parse("e eqe e e e e e".asBeats).q
			].pp

});
		//["/*SPOCK*/ Yes, of course, Just as we do, Doctor. ",[7,5,4,5,7,12,11,5,3].dm('e',octave:5 )].addLine;
["/*SPOCK*/ (boom) Yes, (boom) of course, Just as we do, Doctor. ",[-7,7,-7,5,4,5,7,12,11,5,3].dm('e',octave:5 )].addLine;
		P.still(\clear,syl:0, timecode: 0.seconds, music: { |p b e|
			 e.still.( 
				wait: b.drop(1).sum,
				text: ["Yes","of course"],
			).sequenceText2(
					b.drop(1).parse([4]), [ 
					["just as we do","doctor"],
					],
			)
		});
P(\bonk, music: { |p b e|
	{
		var durs = b.parse([2,2, 3, 4 ]) ++ e.bnext[0] => _.flat;// .postln;
		var trig = TDuty.ar(durs.dropLast().dq, gapFirst:0   ) => OnePole.ar(_);
		var freqs = [7, 7, 4, 3, 2  ].df(\e,2);

		Gendy4.ar(minfreq: freqs.dq.demand(durs), maxfreq: freqs.dq.demand(durs) + 0.05)
		* (Decay.ar(trig => HPF.ar(_,1)))
		=> FreeVerb.ar(_,0.1,1)
		=> Pan2.ar(_)
		=> LPF.ar(_,1000)
		/2
		// /3
		// * Env.perc().kr(0,gate:trig)
	}.play
});
P.synthV(role: \henoch, take:\lead,
			filter: (midinote: _ - 12), 
			params: {|p b| [
			lyrics: "r yes r of course, just as we do Doctor +",
			legato: [1, 0.6, 1, 0.6, 1, 1, 1, 1, 1, 1],
			pitchTake: 1
		] }, music:{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
			}.play
});
P.double(role: \henoch, params: {|p b| [
				
			] }, music:{|p b e|
				{
					e.playbuf
					=> p.synthVTracks.at(e.key).()
				}.play
	});
P(\ofCourseBass,start:'of course',music:{|p b e|
			[
				freq:[\r,4,3,2].df('e',octave:[2, 3 ]).q,
				dur:b.parse([4,3,4])++[3] =>_.q,
				instrument:\stringyy,
				amp:0.2,
				wet:0.2,


			].pp
});
["Thalassa-collapses nurse sargon-wobbles doctor? ","11 1.5 4 11 7".dm(\c)].addLine;
// Song.durs.filter( _*2 );
P.still(\collapseNurse, timecode: 2839.2.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	).sequenceText2(
			b.parse([1]), [ 
			["Nurse!",""],
			],
	)
});
P.still(\transition,syl:0, lag:0.5, timecode: 2842.2.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.still(\sargonWobbleDoctor,syl:1,lag:0.5, timecode: 2845.7.seconds, music: { |p b e|
	//  e.still.( 
	// 	wait: b.sum,
	// 	text: ["",""],
	// ).sequenceText2(
	// 		b.drop(1).parse([1]), [ 
	// 		["","Doctor!"],
	// 		],
	// )
});
P.still(\kirkLieDown,syl:1, timecode: 2850.6.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P(\collapseTremolo,start:'collapses',music:{|p b e|
			//////////
			//idea delays without interpolation in the four channels
			//////////
			
			// ~syn1.expression(127,0);
			// ~syn1.expression(127,1);
			// ~syn1.patch(\violins,\trem,1);
			// ~syn1.patch(\violas,\trem,0);
			// ~syn1.syn.set(\out, (Effect(FreeVerb.ar(_,0.8,0.8)).bus.index) );
			// (
			// 	type:\synful,
			// 	instance:~syn1,
			// 	freq:[-7,2,4,6].df(\e,scale:\minor,octave:4),
			// 	amp:1,
			// 	dur:b.sum,
			//
			// 	//		instrument:\trem,
			//
			// ).play;

			[

				freq:[ [-7,2,4,6].df(\e,scale:\minor,octave:4) , [-7,2,4,6].df('e-',4,scale:\minor) ] =>_.q,
				instrument: \trem2,
				freqLag:2,
				rate:[ 4,5,6,7 ] *2,
				size:1,
				dur:b.parse([1,1]).q,
				rel:7
			].ppm
});
P(\tympanyCollapse,start:'collapses',music:{|p b e|
			(freq:[-2,2].df(\e,octave:3,),instrument:\membrane).play
});
		// irregular harp glissandi
P.synthV(role: \mccoy, take: \lead, params: {|p b| [
	lyrics: "r nurse r r r ",
	// lag:[ 0.1 ],
	legato:[0.4],
	// pitchExpression:1,
	paramTension: 1,
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play;

});
P.tune();
P(\bassnote, music: { |p b e|
	[
	instrument: \harp,
	freq: [\r,1].df('c#',3).q,
	dur:b.q,
	out: Effect.bus( DWGReverbC1C3.ar(_) /5, out:2 )
].pp
});
P(\chord, music: { |p b e|
	(
		lag: b.parse([2]).unbubble,
		freq: [-1, -3, 5.5, 1, 3].df(\f, 4),
		att:3,
		dur: b.sum,
		// instrument: \sawSynthSustain,
		instrument: \trem2,
		amp:0.05
	).play;
	(
		lag: b.parse([2]).unbubble,
		freq: [1].df(\f,3),
		amp: 0.1
	).play
});
P.synthV(role: \chapel, take: \lead, params: {|p b| [
	lyrics: "r r r doctor +",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
["/*MCCOY*/ Henoch, you'd better get back to bed too. ","7 4 11 7 6 4 5 6 7 12".dm(\e)].addLine;
P.still(\kirkInBed, timecode: 2852.6.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["Henoch, you'd better","get back to bed too"],
	)
});
P.synthV(role: \mccoy, take: \lead, params: {|p b| [
	filter: (midinote: _ - 12), 
	lyrics: "Henoch + you'd better + get back to bed too. ",
	legato: [1, 0.8, 1, 1, 0.7, 1, 1, 1, 1, 1, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P(\bass, music: { |p b e|
	[
		freq: [4.5, 5, 4.5, 3, 1, -6].df(\a,3).q,
		dur: b.parse([2, 1, 1, 1, 4, 1]).q,
		legato: 1,
		out: Effect.bus({|i|  FreeVerb.ar(i, 0.1, [0.9,1]) => SineShaper.ar(_, 0.2, 4) /5  * [0.1,0.9]  },),
		instrument: \sparkTriangle
	].pp
});
P(\bassnote, music: { |p b e|
	[ 
		freq: [ 1, 6 ].df(\a,3).q,
		amp:0.4,
		dur: b.parse([9,1]).q,
		instrument: \sawSynthSustain, amp:0.1,
		att: 0.3
	].ppm;
	( 
		lag: b[0..1].sum,
		instrument: \harp,
		freq: 5.df(\a,3),

	).play
});
(		/// Unnecessary drums
	Song.kpat=([1,1,0,1]!4).flatten;
	Song.spat2=([0,0,0,0,1,0,0,0.6]!4).flatten;
	Song.tk=();
	Song.tk.add(\kick->Pbind(*[
		instrument:\kick2,
		amp:Pseq(Song.kpat,3)/6,
		dur:0.5	,
		out:[0,1]
	]));

	Song.tk.add(\snare->
		Pbind(*[
			instrument:\snare,
			amp:
			Pseq(Song.spat2.flatten,3)/7
			,
			dur:0.25,
			out:[0,1]
		]);
	);
	( Song.tk.add(\hat->
		Pbind(*[
			instrument:\hihat,
			dur:Pwrand([1/4,Pseq([1/16],4)],[0.95,0.05],inf),
			//offset:-0.35,
			att:Pwhite(0,0.01),
			pan:0.4,
			amp:0.04])
		);
	);
	//;
	//h[1]=\filterIn->{|in| Klank.ar(`[[1100,1200,2500],nil,0.04],in)};h.set(\wet1,0.5);
	//h
	//.play;

	//	synths	{{{3
	~octaveWrap={|i a=7| (i>a).if({i-8},i)};

	( Song.tk.add( \pulse-> //		{{{4
		Pbind(*[
			instrument:\pulse,
			degree:Pseq(([\r,1,5,1,\r,0,5,0,\r,1,5,1]++[\r,1,6,1]).flatten,3)-1,
			dur:0.5,
			root:4,
			sustain:2,
			octave:6,
			amp:0.17
		]);
	);
);
( Song.tk.add(\saw-> //	Unnecessary bass	
	Pbind(*[
		instrument:\sawSynth,
		att:0.05,
		rel:5,
		degree:Pseq(
			[1,3,0,3,7,3,7,4].collect{|i|~octaveWrap.(i,6)}-1
			,4
		),
		//degree:Pseq([[1,3],5,[2,0],5,[1,-1],5,[1,-1],6]-1,4),
		root:4,
		octave:6,
	]);
);
);
);
["that will be unnecessary Doctor"," d# e f# d# g# f# e d# d# c#"].addLine;//
P.still(\respond, timecode: 2854.1.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.still(\clear, timecode: 0.seconds,lag:0.01, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["that will be","unnecessary, Doctor"],
	)
});
P.synthVs(role: \henoch, take: [ \lead, \double ], params: {|p b| [
	lyrics: "that will be unnecessary + + + + Doctor +",
	pitchTake: [ 1, 3 ]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.tune(\unnecessary);
P(\descant,start:'unnecessary',music: {|p b e|
	[
		instrument:\sawSynth,
		degree:Pseq([\r,8,7,6,5,5,4.1])-1,
		att:0.7,
		root:4,
		dur:Pseq( [Song.durTill(Song.section( 'unnecessary' ),3)]++Song.durs['unnecessary'].list [4..9]++[0.5,2]),
		dur: b.parse([4,1,1,1,1,1,1]).q,
	].pp
});
P(\unnecBass,start:'unnecessary',music: //		{{{
	{|p b e|
		[
			instrument:\sawSynth,
			degree:Pseq([5,2])-1,
			rel:4,
			dur: b.parse([8,2]).q,
			//dur:Pseq([2.3,1]),
			root:4,
			octave:3
		].pp
	}
);
["(four bar intro)" , "r",[16]].addLine;
P(\note, music: { |p b e|
	(amp: 0.04, freq: [-1,-11].df(\e ),dur: b.sum).play
});
Song.vulcanBodyTempo = 1.2;
Song.tk.asPairs.pairsDo{|name pattern| Song.tk.put(name, Song.tk.at(name) => Pmul(\dur,Song.vulcanBodyTempo.reciprocal,_))}; //scale pattern
Song.durs['four bar intro']=Pseq([1,1,1.5,0.25,0.25+0.5, 0.5,0.5,0.25,0.25+0.5,0.5,0.5,0.5]);
Song.durs.scale('four bar intro',Song.vulcanBodyTempo.reciprocal);
P(\leadIn,start:'four bar intro',music: { |p b e|
	Pfindur(8/p.vulcanBodyTempo,
		Ppar([
			//Pseq([Song.pbind[1]],4).play;
			Song.tk.at(\snare),
			Song.tk.at(\kick),
			Song.tk.at(\pulse),
			Song.tk.at(\saw),
			Song.tk.at(\hat)
		])
	).play
}); 
["r this Vulcan body is adapted to the","r b b g# f# e f# g# f# e d# e"].addLine;//1
P.synthV(role:\henoch, take: \lead, params: {|p b| [
	lyrics: "r this vulcan + body + is adapted + + to the",
	pitchTake: 1,
	vocalMode: \Muted //Overdrive, Solid
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(\ninezero, take: \lead, params: {|p b| [

] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.still( \clear, start: 'adapted to', timecode:0 ,syl:0,lag:0.01, music: { |p b e|
	e.still.value(
		wait: b.drop(1).sum,
		text: ["this Vulcan body",""]
	);
	fork{
		b[1..4].sum.wait;
		defer{
			e.still.setText(["this Vulcan body","is adapted to the"])
		}
	}

});
P.still(\spockClose,syl:0, timecode: 
// 3055.seconds //mouth closed
3047.2.seconds
, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum,
		text: ["",""],
	)
});
/* P.still(\angrySpock, timecode: 2820.seconds, music: { |p b e|  //spock behind Chapel
	e.still.( 
		wait: b.sum,
		text: ["",""],
	)
}); */
Song.durs['is adapted']=Pseq([1,1,1.5,0.25,0.25+0.5, 0.5,0.5,0.25,0.25+0.5,0.5,0.5,0.5]);
Song.durs.scale('is adapted',Song.vulcanBodyTempo.reciprocal);
//	Song.durs[1]=Pseq((Song.durs[1].list!2).flatten	);
P(\bass1,start:'adapted to',music: {
	var notes=[1,3,6,4].collect{|i| i!4}.flatten;
	[
		degree:Pseq(notes,4)-1,
		dur:0.5/Song.vulcanBodyTempo,
		root:4,
		amp: 0.5,
		octave:2,
		trig:Pseq(1!16),
		out: Effect(
			{|i| i + CombN.ar( i, 1, 0.25/Song.vulcanBodyTempo,2,mul:( 0.8*0.8 ) )/2
			=> Phaser1.ar(_,  depth: 0.5,  rate: 0.2,  fb: 0.3,  cfb: 0.1,  rot: 1.5707963267949)
		}
	).bus.index
].pm(\bl).play;
});
P.tune('is adapted',{|i|i=>Pbindf(_,\amp,0.3,\instrument,\stringyy)});
P(\leadInB,start:'adapted to',music: 
	Pfindur(8,
		Ppar([
			//Pseq([Song.pbind[1]],4).play;
			Song.tk.at(\snare),
			Song.tk.at(\kick),
			Song.tk.at(\pulse),
			Song.tk.at(\saw),
			Song.tk.at(\hat)
		])
	)
); 
["r r higher metabolism"," f#3 f# a5 g# b a g# f# e "].addLine;//2
P.synthV(role: \henoch, take:\lead,
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: "r r higher + metabolism + + + ",
	pitchTake: 1,
	vocalMode: \Muted
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \henoch, params: {|p b| [

] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.still( \clear , start:\higher , timecode:0, syl:1, music: { |p b e|
	e.still.value(
		wait: b.drop(1).sum ,
		text:["higher","metabolism"]
	);
});
P(\bass3,start:'higher metabolism',music: 
	{|p b e|
		[
			degree: [ 2,2,1,1 ]-1 => _.q,
			//dur: [ Song.durs['higher metabolism'].list[0] ,Song.durs['higher metabolism'].list[1..4].sum  , Song.durs['higher metabolism'].list[5..6].sum,1].q ,
			dur: b.parse( [1,4,2] ) ++ [1] => _.q,
			root:4,
			octave:2,
			out: Effect.bus({|i| 
				i + CombN.ar( i, 1, 0.25/Song.vulcanBodyTempo,2,mul:( 0.8*0.8 ) )/2
				=> Phaser1.ar(_,  depth: 0.5,  rate: 0.2,  fb: 0.3,  cfb: 0.1,  rot: 1.5707963267949)
			}),
			trig:1
		].pm(\bl).play
}); 
P.tune('higher metabolism',{|i| Pbindf(i,\instrument,\stringyy,\amp,0.3,\mix,1.0,\release,2)=>_.drop(2) },syl:1);

P(\metabolism,start:'higher metabolism',music: 
	//t=TempoClock.new.tempo_( 1.2 );
	//u=TempoClock.new.tempo_( t.tempo*0.666 );

	Pfindur(4,//12,
		par([
			//a.[0]=Pmono(\bl,\degree,2-1,\dur,0.5,\root,4,\octave,2,\trig,1);
			//				Song.pbind['higher metabolism'],
			Song.tk.at(\hat),
			Pbindf(Song.tk.at(\pulse), \degree,Pseq([\r,-2,4,-2],1),\dur,0.662 ),//.play
			Pbindf(Song.tk.at(\saw), \degree,Pseq([-1,4,-1,3]) ),//( ,\dur,0.331),
			Song.tk.at(\snare),
		])
	);
	//Song.tk.at(\hat).play(u)
);
["it won't work, Sargon!","d#5 b4 g5 d# b4"].addLine;//3
P.still(\mccoyToKirk, timecode: 2900.8.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["it won't work,","Sargon"],
	)
});
P.synthV(role: \mccoy, take:\lead,
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: "it won't work sar gone",
	legato: [0.7,0.7,0.7, 1,0.7],
	pitchTake: 1,
	tension: Env([0.5,1,0.5],b.parse([3,2])),
	loudness: Env([-1,4,0],b.parse([3,2])),
	paramToneShift: 0.5,
	vocalMode: \Open,
	pitchExpression:1.5
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \mccoy, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
P(\workChord,syl:1,start:'work, Sargon',music:{|p d|

	var a=Scale.new((0..8),pitchesPerOctave:9);

	//b=Effect(FreeVerb.ar(_,0.9,1),out:1).bus.index;
	var b=Effect({|i|PlateReverb.ar(i,0.8,mix:Line.kr(0.5,1,30),decayTime:0.7*Gendy1.kr(minfreq:1/10,maxfreq:2).unipolar)[0]},inputChannels:2).bus.index;
	var length = 2;
	[
		degree:
		Ptuple([
			( 40..57 ).q(inf) + 5.rand
			,( 40..56 ).q(inf) + 5.rand, (40..60).q(inf) ])
			,
			root:[0,3,6]-1,scale:a,dur:0.05,legato:1,
			out:b+Pwhite(0,1)
		] .p
		=>Pfindur(length+0.5,_)
		=>_.play;
		[dur:0.3,root:-1,scale:a,out:b,amp:Pseries(0.1,-0.01),degree:( 0..9 ).q(inf),legato:[3,0.5,0.5].q(inf)*2.2].p
		=>Pfindur(length+0.3,_)
		=>_.play;
		(strum:0.04,degree:[0,2,4]-1,scale:Scale.whole,root:9,dur:length).play;
		(release:5,type:\tuningGong,amp:0.02,freq:1.dm('g')).play
	}
);
P(\baseNoteWork,syl:1,start:'work, Sargon',music:{|p b|
	(
		freq:[1 ,11 ].df('g',octave:2 ),
		instrument:\sawSynthSustain,
	).play;
	(freq:[1,3,5,11,13,15].df('g',scale:\whole),strum:0.05).play
}
);
["(boom) you have to get out before you","f4 f5 d- e- f a f g a"].addLine;//4
P.still(\clear,syl:0, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["you have to get out","before you kill them"],
	)
});
P.synthV(role: \mccoy, take: \lead,
	filter: (midinote: _ - (12 * [ 1, 1, 1, 1, 1, 1, 1, 1,1, 0, 0 ])), 
	pbind: Song.enlarge(2),
	params: {|p b| [
	lyrics: "r you have to get out before + you kill them!",
	pitchTake: 1,
	paramTension: 1.25,
	paramToneShift: 0.5,
	vocalMode: \Open,
	pitchExpression:1.5
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \mccoy, take: \lead, params: {|p b| [
	
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.tune('get out',(_.drop(1)),syl:0);
P(\baseNoteOut,syl:4,start:'get out',music:{|p b|
	(
		freq:[1 ,11 ].df('a',octave:2 ),
		instrument:\sawSynthSustain,
	).play;
	(freq:[1,3,5,11,13,15].df('g',scale:\whole),strum:0.05).play;
	(release:5,type:\tuningGong,amp:0.02,freq:1.dm('a')).play

}
);
P(\outChord,syl:4,start:'get out',music:{|p d|
	//b=Effect(FreeVerb.ar(_,0.9,1),out:1).bus.index;
	var a=Scale.new((0..8),pitchesPerOctave:9);
	var b=Effect({|i|PlateReverb.ar(i,0.8,mix:Line.kr(0.5,1,30),decayTime:0.7*Gendy1.kr(minfreq:1/10,maxfreq:2).unipolar)[0]},
	out:2,
	inputChannels:2).bus.index;
	var length = 2;

	[
		degree:
		Ptuple([
			( 40..57 ).q(inf) + 5.rand
			,( 40..56 ).q(inf) + 5.rand, (40..60).q(inf) ])
			,
			root:[0,3,6]+2,scale:a,dur:0.05,legato:1,
			//			out:b+Pwhite(0,1)
		] .p
		=>Pfindur(length+0.5,_)
		=>_.play;
		[dur:0.3,root:2,scale:a,out:b,amp:Pseries(0.1,-0.01),degree:( 0..9 ).q(inf),legato:[3,0.5,0.5].q(inf)*2.2].p
		=>Pfindur(length+0.3,_)
		=>_.play;
		//(out:2,strum:0.04,degree:[0,2,4]+2,scale:Scale.whole,root:9,dur:length).play
	}
);
["kill them! /*SARGON*/  we will transfer at once un-",[11,7,5,6,7,5,7,7,7].dm('c')].addLine;//5
P.still(\kirkCloseBed,syl:1, timecode: 2906.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum + e.bNext.sum,
		// fade: e.bNext.sum,
		text: ["",""],
	)
});
P.still(\clear,syl:1,lag:0.01, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: e.bAll.parse([26]).unbubble,
		text: ["we will transfer","at once"],
	).sequenceText2(
			// b.drop(1).parse([6]) ++ (b.last + e.bNext.sum) , [
				e.bAll.drop(1).parse([6, 9, 1]),[
			["until you can", "administer the"],
			["",""],
			["metabolic reduction","injection"]
			],
	)		
});
P.synthV(role: \sargon,take: \lead,
	filter: (midinote: _ -12), 
	pbind: Song.enlarge(8),
	params: {|p b| [
		lyrics: "r r we will transfer + at once until + you can administer + + + the",
		phonemes: ["","", "w i", "w i r", "ch w a n s"," f a r",  "a t", "w a n s", "e n"," t i r",  "y u", "k a n", "e d"," m i n"," i s"," t a r", "z e" ],
		legato: [1, 1, 1, 1, 1, 1,  1, 0.6, 1, 1, 1, 1, 1, 1, 1, ],
		// pitchTake: [1, 3],
		// vocalMode: \Muted
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P('bass',start:\kill,music: {|p b e|
	[
		freq: [\r,5,5].df(\c,[2,3,4]).q,
		dur: b.parse([5,[1,1,0.5],[0.5,1]]).q,
		out:[1,4],
		instrument: \pulse,amp:0.25

	].pp;
	[
		freq:[\r,7,7].df(\c,[3,4,5]).q,
		dur:b.parse([4,3,3]).q,
		out:Effect.bus(TwoTube.ar(_,loss:0.99,d1length:992) * 0.4,inputChannels:2,out:[2,3]),
		instrument:\twang

	].pp
});
["til you can administer the ",[7,6,5,4,7,11,6,5].dm('d')].addLine;//6
["(boom) metabolic reduction injection... a ",[11,15,14,15,12,14,12,11,14.5,11,7.5, 7].dm('a-',octave:4,scale:\mixolydian )].addLine;//7
P.synthV(role: \sargon, take: \lead,
	filter: (midinote: _ - 12), 
	take:\lead, params: {|p b| [
	lyrics: "r metabolic + + + reduction + + injection + + r",
	phonemes: ["","","","","","r i","d a k"," sh e n","i n","j e k","sh e n", ],
	pitchTake: 1,
	vocalMode: \Muted
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
/* P.double(role: \henoch, take: \lead,
	filter: (midinote: _ - 12), 
	params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
}); */
P.synthV(role: \mccoy, take: \lead,
	pbind: Song.enlarge(1),
	params: {|p b| [
	lyrics: "r r r r r r r r r r r a what? ",
	filter: (midinote: _ - 12), 

	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).( 0.03 )
	}.play
});
P.tune('injection',Pbindf(_,\legato,1.5,\out,Effect(PlateReverb.ar(_,decayTime:0.4,mix:0.6)).bus.index));
P(\baseNoteMetabolic,start:'injection',music:{|p b|
	var length=b[0..(b.size-1)].sum;
	var freq=[1,11].df('a-',octave:2 );
	{Saw.ar(freq + {3.0.rand} dup: 4 ) * Env.perc(0.4,length).kr(2,gate:1)*0.07 }.play;
	(instrument:\stringyy,freq:freq,dur:length,\wet:0,\amp:0.3).play;
}
);
["what? I'll prepare the formula Sargon",[14, 13,14,15,13,14,13,12,11,3].dm('b',octave:4)].addLine;//8
P.still(\twoShot, timecode: 2911.3.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["a","what?"],
	)
});
P.still(\spockSpeaking,syl:0, timecode: 2912.2.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["I'll prepare the formula","Sargon"],
	)
});
P.synthVs(role:\henoch, take: [\lead, \double], params: {|p b| [
	lyrics: "r I'll prepare + the formula + + sar gone",
	legato: [[1, 1, 1, 1, 1, 1, 1, 0.7, 1, 1, ]],
	filter: (midinote: _ - 12), 
	vocalMode: \Muted,
	pitchTake: [1,3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\whatChord,start:'prepare the formula',music:{|p b|
	(
		midinote:[1,3,5,7].dm('f#',octave:4,scale:\mixolydian),
		strum:0.05,
		out:(0..3),
	).play
}
);
["Henoch, your condition",[4.5,1,3,4.5,6.5,5.5].dm('e',scale:\minor)].addLine;//9
P.still(\kirkClose, timecode: 2916.2.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["Henoch,","your condition?"],
	)
});
// P.tune('your condition');
P.synthV(\genbu, take:\lead,
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: "He nak,  yo kan di shan",
	legato:[ 1,0.75, 1, 1, 1, 1 ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(\genbu, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
P(\baselineCondition,start:'your condition',music:{|p b|
	[
		freq:[ [1,11],[2,12] ].df('g',octave:3 ).q,
		instrument:\stringyy,
		out:(0..3),
		dur:
		//		[ b[0..4].sum , b[5..6].sum].q(1),
		Song.parse('your condition',[[1,1,1,1,2/3],[1/3,1]]).q,
	].pp
}
);
["r I can continue in this body for for several hours","d3 f#4 d f# e c# d e d g3 e2 e4 d c#  b3 a"].addLine;//10
P.still(\spock, timecode: 2918.1.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["I can continue,","in this body"],
	).sequenceText2(
			b.parse([9]), [ 
			["for several","hours"],
			],
	)
});
~continueQuarters = Song.parseBeats('several hours',[1/4,1/4,1/4,1/4,1/4,1/4,1/4,1/4,1/2,1/2]);
P.synthV(role: \henoch, take:\lead, params: {|p b| [
	lyrics: "r I can continue + + in this body + r for sev ral  hours +",
	pitchTake: 1,
	vocalMode: \Muted
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \henoch, take: \lead, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
P(\continueSnare,start:'continue',music:
	{
		var a="....x..x".asDrumPat(4).list * ~continueQuarters.stutter(8) => _.q;
		var b="x.x...x.".asDrumPat(4).list * ~continueQuarters.stutter(8) => _.q;
		[instrument:\snare,dur:a,amp:0.03].p.fin(8).play;
		[instrument:\kick,dur:b].p.fin(4).play;
	}
);
P(\reedHours,start:'several hours',music:{ |p b|
	(instrument:\reedy,freq: 1.df('a') ).play
}
);
P(\baselineHours,start:'several hours',music:{|p b|
	[
		freq:[ 11,7,4,2,3,4,5 ].df('d',octave:3).q,
		dur:Song.parse('several hours',[4,4,2,2,1,1,1,1]).q,
	].pp
}
);
["fortunate (dum dum dum dum) we will vacate at once...",[14,12,7,5,6,7, 1,11,12,13,11,13,13].dm('g',octave:4,scale:\mixolydian,)].addLine;//11
P.still(\kirkCloseFortunate, timecode: 2926.3.seconds, music: { |p b e|
	var fade = b[1..4].sum;
	 e.still.( 
		wait: b.parse([3]).unbubble,
		fade: fade,
		text: ["fortunate",""],
	)
});
P.still(\clear,syl:6, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["we will vacate","at once"],
	)
});
Song.durs.filter( _ * [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.5] );
P(\oncePadd,syl:12, music: { |p b e|
	(
		instrument: \wash,
		dur: b.drop(1) + e.bNext.sum,
		freq: 7.df(\c)
	).play
});
P.synthV(role: \sargon, take:\lead,
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: "fo tsu net r r r r wi wil vei keit at uans",
	phonemes: ["","","","","","","","","","","","","w a n s",],
	legato: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.6, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\lick, music: { |p b e|
	[
		instrument: \sawSynthSustain,
		midinote: p.tune[e.start],
		dur: p.durs[e.start].list * [1, 1, 1, 1, 1, 1, 4] => _.q,
		rest: [\r, \r, \r, 1, 1, 1, 1].q
	].ppm
});
P.tune( _ <> [
	instrument: \harp,
	rest: [\r, \r, \r, 1, 1, 1, 1].q,
	out: Effect.bus({|i| i => Pan2.ar(_,-0.4, 0.8) => FreeVerb2.ar(*_)   },)
].p

);
P(\baseNoteFortunate,start:'fortunate',syl:5,music:{ |p b|
	(instrument:\sawSynthSustain,freq:[1,11].df('g',octave:2),att:0.6,dur:b[6..].sum).play
}
);
P(\reedChordFortunate,lag:-0.15,start:'fortunate',music:{ |p b|
	(freq:[1,3,5,7].df('d',scale:\minor),out:{4.rand}!4, instrument:\reedy,sustain:1,release:4,amp:0.08 ).play 
}
);
["transform-k transform-c","7 5".dm(\c)].addLine;
Song.durs.filter( _ *  1.5);
P.still(\transformKirk, timecode: 2932.seconds, music: { |p b e|
	 e.still.( 
		wait: b[0] -0.5,
		text: ["",""],
		fade:1.5
	)
});
P.still(\transformThal, timecode: 2935.seconds, music: { |p b e|
	 e.still.( 
		wait: b[1],
		fadeIn:b[1],
		fade:2,
		text: ["",""],
	)
});
P(\fadeUp, music: { |p b e|
	{
		var freq = 7.df(\c);
		Saw.ar( freq )
		* Env.triangle(b.sum + 0.5).kr(2,gate:1)
		/10
	}.play
});
P(\transform, music: { |p b e|
	var pan = [-1,1].q(inf).asStream;
	var freqs = [7, -7].df(\c,7).q(inf).asStream;
	var transform = { |pan freq |
		{ 
		var nyquist = s.sampleRate / 2;
		SinOsc.ar(
			XLine.kr(nyquist + freq, nyquist +(pan * 10000) + 7000 + (100,200..1000)
			, b[0] * [2,3,4,5])
			* Env.linen(0,b[0],3).kr(2,gate:1)
			/2
		)
		* Env.linen(0,b[0]/2,3).kr(2,gate:1)
		+(
			 Gendy2.arWidth(freq: freq, mul: Env.perc(1,4).kr(2,gate:1)/5)
			=> Pan2.ar(_,pan)
		)
		/10
		=> Splay.ar(_,0.5 * (-1 * pan),0.5 * pan)
	}	};
	fork{
		transform.(pan: pan.next, freq: freqs.next ).play;
		// b[0].wait;
		// transform.(pan: pan.next, freq: freqs.next).play;
	}
});
// ["/*SPOCK*/ This woman will assist me. (boom boom)",[11,5,6,7,5,11,5, 2,2].dm('c')].addLine;
["/*SPOCK*/(boom) This woman will assist me. (boom boom)",[1,11,5,6,7,5,11,5, 2,2].dm('c')].addLine;
P.still(\henochAndMccoy,  
	timecode: 2943.seconds ,
	music: { |p b e|
	 e.still.( 
		 fadeIn: b[0],
		wait: b.sum,
		text: ["",""],
	).sequenceText2(
			b.parse([1]), [ 
				["this woman","will assist me"]
			],
	)
});
P.synthV(role: \henoch,
	filter: (midinote: _ - 12), 
	take: \lead, params: {|p b| [
	lyrics: "r this woman + will assist + me r r",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \henoch, take: \lead, params: {|p b| [
	
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\bass,start:'woman',music:{ |p b|
	[
		instrument:\sawSynthSustain,
		freq:[1,2,2,3].df('c',octave:[ 2,4 ],scale:\minor).q,
		amp:[0.1,0.01],
		att:[0.9,0,0,0].q,
		dur:b.parse([8,1,1]).q
	].pp;
}
);
P(\strings, music: { |p b e|
	(
		instrument: \stringyy,
		freq: [2, 4.5] df: \f
	).play
});
P(\bells, music: { |p b e|
	[
		instrument: \harp,
		freq: [[-1, 5, -11  ], [-7, 7 ], [1, 11 ]].df(\c,\minor).q,
		dur: [b.sum, e.bNext.sum, 1].q,
		out: Effect.bus({|i|  FreeVerb.ar(i,0.5,[ 1, 0.9 ]) },inputChannels:2),
		coef:0.4,
		amp: 0.02
	].pp
});
P(\descant, music: { |p b e|
	[
		freq: [11, 7, 11, 6.5, 5].df(\c,6).q,
		dur: e.bAll.parse([4, 2, 3, 1, 1]).q,
		att:5,
		amp:0.01,
		instrument: \sparkTriangle,
		depth:0.005,
		out: Effect.bus({|i| i=> Pan2.ar(_,0.8) => {|i| i + CombN.ar(i, 0.35, 0.3) /3} },)
	].ppm
});
["(to Chapel) (boom) /*You will*/ take me to your",[1,11,7,6,5].dm('e-')].addLine;
P.still(\toChapel, timecode: 2944.6.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.still(\clear,syl:0, timecode: 0.seconds,lag:0.01, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum + e.bNext.sum,
		text: ["take me","to your"],
	).sequenceText2(
				e.bAll.drop(1).parse([4, 1]), [
				["",""],
			["pharmacology","laboratory"],
			],
	)
});
P(\pad, music: { |p b e|
	(
		instrument: \stringyy,
		freq: [3,5] df: 'e-',
		dur: b.sum
	).play;
	[
		freq: [\r, 11, 7, 6, 5].df('e-',[4,6] ).q,
		dur: b.q,
		amp: 0.05,
		out: Effect.bus({|i| FreeVerb.ar(i) },),
	].pp
});
P(\chord,syl:0, music: { |p b e|
	[
		freq: [3, 5]  df: 'e-',
		dur: b.drop(1).parse([1, 1, 1, 1]).q,
		instrument: \defaultPiano,
	].pp
});
P.synthVs(role: \henoch, take: [ \lead, \double ],
	filter: (midinote: _ - 12), 
	pbind: Song.enlarge(10),
	params: {|p b| [
	lyrics: "r take me to your r pharmacology + + + + laboratory + + + ",
	pitchTake: [ 1, 3 ],
	legato: [ [1, 0.6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,1.25 ] ],
	vocalMode: \Muted
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\baseNoteTake,start:'take me',music:{|p b|
	[
		instrument:\sawSynthSustain,
		freq:[[ 3, 13 ],13].df('c',octave:2,scale:\minor).q,
		dur:p.parse('take me',[[1,1,2/5 -0.1 ],[3/5 +0.1,1,1]]).q,
	].pp
}
);
["(boom) pharmacology laboratory. ",[1,11,7,11,5,7,4,5,4,3].dm('f',scale:\mixolydian)].addLine;
P(\chord,music: { |p b e|
	[
		freq: [-22,2]  df: 'e-',
		strum: 0.03,
		dur: b.drop(1)[0].q,
		instrument: \defaultPiano,
		out: Effect.bus({|i| i => BPF.ar(i, 900) => SineShaper.ar(_, 0.03, 1) },)
	].pp;
	( instrument: \cymbalsDS, amp: 0.01 ).play
}, syl:nil);
P(\middlevoice, music: { |p b e|
	[
		freq: [\r,5, 5, 5, 5, 5, 1, 1, 1, 1, -4] df:.4 \f perform: \q,
		instrument: \sawSynth, amp:0.03,
		dur: b ++ 1 => _.q
	].pp
});
P.tune('logy lab',{|i| i.drop(1) => Pmul(\freq,0.501,_) <> [instrument:\wash, freqLag:0.01].pm }, syl:0);
P.tune('logy labo',{|i| i.drop(1) => Pmul(\freq,0.501,_) <> [instrument:\harp, freqLag:0.01, out:Effect.bus({|i| CrossoverDistortion.ar(i ,smooth:0.9) / 10 => {|i| i+ CombN.ar(i,0.3,0.3)} * EnvGen.cutoff(Song.durs['phar'].list.sum,1) },)].pm }, syl:0);
P.tune('pharmacology',{|i|i.drop(6) <> [instrument: \visual_pad, amp: [1, 1.3, 1.3, 1.3].q, rel:2, legato:[1, 1, 1, 1,1].q].pma => Pmul(\freq,[1,2],_)},syl:5);
P(\soundEffectPharmacology,lag:0.26,start:'pharmacology',music:{|p b|
	(type:\tuneUp,freq:1.df('c',octave:4),amp:0.01).play
}
);
P(\basedNotePharmacology,start:'pharmacology',music:{|p b|
	(instrument:\sawSynthSustain,\freq:[1].df('f',octave:2 )).play;
}
);
["(They leave.) ","r",[4]].addLine;
P.still(\leaving, timecode: 2949.1.seconds, music: { |p b e|
	 e.still.( 
		 wait:0,
		fade: b.sum,
		text: ["",""],
	)
});
P(\door,start:'They leave',music:{|p b|
	var line= Line.kr(0,1,b.sum);

	// {WhiteNoise.ar(0.03)}.play.dur(b.sum);
	Synth(\door, [\len:2,\amp,0.03]);
	(
		instrument:\stringyy,freq:[1,11].df('b-',octave:2 ),
		amp:0.4,
		dur:b.sum,
		out: Effect.bus({|i| i => Pan2.ar(_, Line.kr(-1, 0.9, b.sum, doneAction:0)) },)
	).play;
	[
		freq:[7,11,7,6,5,4,3,2].df('b-',octave:4, ).q,
		dur:b.sum/8,
		legato:2,
		instrument: \visual_pad,
		amp:1,
		rel: [1, 4, 2, 2, 2, 2, 2, 2].q,
		legato:[1, 0.9,0.9,0.9,0.9,0.9,0.9,0.9,0.9].q
	].pma => Pmul(\freq,[1,2],_) => _.play
}
);
// idea  do the doors with  additive synthesis
["/*KIRK*/ (frown) Bones, what?, it was", [7,17,14,15,15].dm('c',octave:3)].addLine;
// Song.durs.filter( _ + [0,1,0, 0, 0] );
P(\frown, music: { |p b e|
	(
		instrument: \trem2,
		size:0.8,
		rel: 5,
		amp: 0.03,
		freq: [1,2,3].df(\e),
		out: Effect.bus({|i| i * Env.triangle(3).kr(2,gate:1) },)
	).play;
});
P.still(\kirkAndBones, timecode: 2954.666.seconds, music: { |p b e|
	 e.still.( 
		wait: b[0..2].sum,
		text: ["",""]
	).sequenceText2(
			b.parse([1]), [ 
			["Bones..","what?"],
			],
	)
});

P.still(\mccoyClose,syl:2, timecode: 2958.166.seconds, music: { |p b e|
	 e.still.(  
		wait: b.drop(1).sum + e.bNext[0..1].sum,
		text: ["it was","close, Jim!"],
	)
});
P.synthV(role: \kirk, take:\lead, params: {|p b| [
	lyrics: "r Bones, what r r",
	// legato: [1, 0.3,0.4],
	legato: [1 ,0.4, 1],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
/* P.double(role: \kirk, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
}); */
	Trek.cast.mccoy = \jun;
	Trek.presets.put(\mccoy,\jun,[ paramGender: 0.1, paramTension: 0.75 ]);
P.synthVs(role: \mccoy, take:[ \lead, \double],
	pbind: [Song.enlarge(2),Song.enlarge(2)],
	params: {|p b| [
	lyrics: "r r r it was close Jim!",
	pitchTake: [ 1, 3 ],
	vocalMode: \Dark, //Power Dark Chest
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.tune('frown',{|i| i.drop(1)},syl:0);
P(\frownFrown,start:'frown',music:{|p b|

	var function={|freq out| {
		Array.fill(30,{freq.pareto(3)})
		=>{|j| var i = \freq.kr(j,8);
		FSinOsc.ar(i,0,24*i.reciprocal**2
			*Env.linen(1.5,10, 4.rand).kr(2)
			// *10
		)
	}
	=>Mix.ar(_)
	* EnvGen.cutoff(b.sum,0.5)
	}.play(s,out) };
	function.(300,0);
	function.(900,3);
	function.(1900,1);
	function.(1800,2);
	function.(5800,4);
}
);
["/*MCCOY*/ close, Jim. You both barely got back a -- ",[13,5,6,12,11,7,11,12,7].dm('c',octave:4,scale:\melodicMinor )].addLine;
P(\closeSizzle, music: { |p b e|
	{

	var function={|freq out| {
		Array.fill(30,{freq.pareto(3)})
		=>{|j| var i = \freq.kr(j,8);
		FSinOsc.ar(i,0,24*i.reciprocal**2
			*Env.linen(0,0.5, b[..2].sum).kr(2)
			* 9
		)
	}
	=>Mix.ar(_)
	* EnvGen.cutoff(b.sum,0.5)
	}.play(s,out) };
	function.(3000,0);
	function.(3000,1);
	}.()
});
P.still(\clear,syl:1, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum + e.bNext.sum,
		text: ["you both","barely got back alive"],
	).sequenceText2(
			b.drop(1).sum + e.bNext[0] => _.bubble ++ e.bNext[1..11].sum , [ 
			["unless the formula works","we can't risk it again"],
			],
	)
});
P.synthVs(role: \mccoy, take: [ \lead, \double ],
	filter: (midinote: _ - (12 * [0,0,0,0,0,0,0,0,0,1])), 
	pbind: [Song.enlarge(1),Song.enlarge(1)],
	params: {|p b| [
	lyrics: "r r you both barely + got back alive +",
	pitchTake: [ 1, 3 ]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.tune('barely',{|i| i.drop(2) => Pmul(\freq,[1/2,1],_) =>Pbindf(_,\instrument,\stringyy,\mix,0.1)},syl:1);
P(\barelyRead8,start:'barely',lag:0.1,syl:2,music:{|p b|
	(
		instrument:\reedy,
		freq:[1,3,11,13].df('f',octave:4),
		//lag:0.1,
		sustain:b.drop(1)[..5] - 0.5,
		out:{4.rand}!4,
		release:2,
		amp:0.04,
		// out:Effect.bus({|i| i * EnvGen.cutoff(b.drop(1)[..5].sum, 0.3) },inputChannels:4,)
	).play 
});
P(\firstChord,start:'barely',music:{|p b|
	(
		freq:[1,3,5,11].df('c',scale:\minor),
		strum:0.05,
	).play;
	(att:0.8,instrument:\sawSynth,rel:3,freq:[1,11].df('c',octave:2 )).play
});
["live. Unless the formula works, we can't risk it again.", [11.5,11,5,3,11,7,6,7].dm('e-') ++ [5,5,11,5,3,1].dm('f#',scale:\minor) ].addLine;
P.synthVs(role: \mccoy, take: [ \lead, \double ],
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: "r unless + the formula + + works, we can't risk it again +",
	legato: [ [ 1,1,1,1,1,1,1,0.7,  1,1,1,1,1,1 ] ],
	pitchTake: [ 1, 3 ],
	pitchExpression: 1.1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.tune('risk it ',{|i| i.drop(1) => Pbindf(_,\instrument,\sawSynth,)=>Pmul(\freq,0.5,_)},syl:0);
P(\reedPedalRisk,start:'risk it',music:{|p b|

	[release:5,sustain:1,amp:0.01!2,out:3, freqLag:1,instrument:\reedy,
		freq:[ \r,[6, 11 ],[5,11],[5.5,7] ].df('b-',3).q,
		dur:p.parse('risk it',[4,3,3,4])+[0,0,0,5]=>_.q ].pm(\reedy).play
	}
);
//MUTEDP(\dingRisk,start:'risk it',syl:0,music: {|p b|
//MUTED{Array.fill(50,{500.pareto(2)})=>FSinOsc.ar(_,0,0.01* Env.perc(0,3).kr(2,gate:1))=>Mix.ar(_)}.play
//MUTED}
//MUTED);
P(\highChords,start:'risk it',music:{|p b|
	[
		freq: [[5,11,13].df('e',tuning:\sept1),[5,11,13].df('e-',tuning:\sept1),[11,13,15].df('b-',octave:4,tuning:\sept1),[3,5,11].df('f#',scale:\minor,tuning:\sept1)] .q,
		amp:0.06,
		dur:p.parse('risk it',[1,6,3,4]).q,
		freqLag:1,
		width:40,
		mix:0,

	].pm(\stringyy)
	.play
});


 )
