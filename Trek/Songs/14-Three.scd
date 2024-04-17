(
{
	//Song.dursFile_("/Users/michael/tank/super/theExtreme_Sep18");
	var strum1,strum2,piano;

	//re-connect if vst exists
	// try{ ( Song.currentSong == \three ).not.if{ 
	// 	strum1 = Song.strum1;
	// 	strum2 = Song.strum2;
	// 	piano = Song.piano;
	// } };

	Song( \three, [] ).current;

	Song.resources.condition=Condition.new;

	// initialize if none
	// strum1.isNil.if{Song.strum1=AAS_Strum()}{Song.strum1=strum1}; 
	// strum2.isNil.if{Song.strum2=AAS_Strum()}{Song.strum2=strum2};
	Trek.strum;
	Trek.pf;
	// piano.isNil.if{Song.piano = PF()};

	Song.resources.vstis = [Song.strum1, Song.strum2, Song.piano];

	Song.resources.infrastructure=FunctionList.new([
		{
			fork {
				// try{ Song.strum1.condition.wait{Song.strum1.controller.loaded} };
				// try{ Song.strum2.condition.wait{Song.strum2.controller.loaded} };
				// try{ Song.piano.condition.wait{Song.piano.controller.loaded} };
				Song.resources.condition.test_(true).signal;

				Song.strum1.syn.run(true);
				Song.strum2.syn.run(true);
				Song.strum1.setPlayMode(\strum);
				Song.allNotesOff;
				0.05.wait;
			}

		}
	]);

	( Song.synthVTracks = EventWithDefault(
		\default, {
			{|i|
				i
				=>BPeakEQ.ar(in:i, freq:1200.0, rq:2.reciprocal, db:5, mul:1.0, add:0.0)
				=> FreeVerb.ar(_,0.1,1)
				/5
			}
		}
	)

);

//Song.strum1.node[1]=\filter->{|in|PlateReverb.ar(in,mix:0.5)};
//Song.strum1.node[2]=\filter->{|in|Phaser2.ar(in,rate:0.1,mix:0.5).distort(0.95)};
//Song.strum1.node.play(vol:1)
// Stills.new("/Users/michael/tank/Trek/video for stills etc/media/return to tomorrow.mov").current;
~stills = Stills.new.current;
["r three alien minds","d3 f5 f e e e"].addLine; //0Captain Kirk
Song.setTempoMap(\minds,"q q ex xe e q");
P(\drums, music: { |p b e|
	[
		instrument: \bd_808,
		instrument: \kick_gentle, vol:0.15,
		// dur:b.parse([2, 3, 1]).q,
		dur:" e eq e eq e e".asBeats.warpTo( e.tempoMap.quantizeDft ++ p.tempoMap[e.start + 1].quantizeDft ).q,
		// dur:" e q e e q e e ".asBeats.warpTo( e.tempoMap.quantizeDft ++ p.tempoMap[e.start + 1].quantizeDft ++ p.tempoMap[e.start + 2]].quantizeDft ).q,
		amp: 0.2, vol: 0.15
	].pp;
	[
		instrument: \snare,
		instrument: \hihat,
		dur: "q qq qq q".asBeats.warpTo( e.tempoMap.quantizeDft ++ p.tempoMap[e.start + 1].quantizeDft ).q,
		rests: MuteFirst(),

	].pp
});
P.still(\space, timecode: 3244.seconds, music: { |p b e|
	e.still.( 
		wait: b.sum,
		text: ["",""],
		fade: e.bNext.sum
	).sequenceText2(
		b.parse([1,5]), [ 
			["three","alien minds"],
			["",""],
		],
	)
});
( Trek.presets.put(\mccoy,\an, [
	vocalMode: \Power,
	paramGender: 0.15,
	paramToneShift: 150,
	paramTension: -0.1
]
		);
		Trek.presets.put(\mccoy,\jun,[

			vocalMode: \Soul,
			paramGender: 0.25,
			paramToneShift: 150,
			paramTension: 0.1
		]);
		Trek.cast.mccoy = \an;
		// Trek.cast.mccoy = \xuan;
		// Trek.cast.mccoy = \jun;
	);
	P.synthVs( role: \mccoy , take:[ \lead, \double ],
	pbind:  Song.enlarge2(3),
	params: {|p b| [
		lyrics: "r three alien + + minds now inhabit + + the bodies + of Captain + Kirk",
		legato: [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.7, ]],
		pitchTake: [ 1, 3 ],
		paramToneShift: 300,
		pitchExpression: 1.5,
		filter: (midinote: _ - 12), 
		// vocalMode: \Passionate
	] }, music:{ 
		var pan = [-1,1] * 0.5;
		pan.collect{|pan| {|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
				=> Pan2.ar(_,pan)
			}.play 
		}}
	}.()
);
//
~bass0quarters=Song.parse(0,[ [1,1],[1,1,1],1 ]);
Song.strum1Fx={ |b|
	var e = Effect( { |i|  
		PlateReverb.ar(i,mix:0.5,decayTime:0.5)  
		=> Phaser2.ar(_,rate:0.1).distort(0.95) *0.3 
		* Env.linen(0,b.sum,3).kr(2,gate:1)
	},inputChannels:2 );
	//e.synth.run(false);
	e
};

Song.strum1Fx0= Song.strum1Fx.(Song.durs[0].list.sum + 5);
P.still(\enterprise, timecode: 3246.9.seconds, music: { |p b e|
	e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P(\guit0,start:\minds,music: { |p b e|
	var out = Song.strum1Fx0.synth.run(true);
	p.strum1.syn.run(true);p.strum2.syn.run(true);
	[
		legato:0.95,
		midinote: [ [2,4],1,-5 ].dm().q,
		dur: ~bass0quarters + [0,0,3] => _.q ,
	].p 
	+=
	[
		switch:[\down,\down,\up].q(2) ++ [\down].q,
		dur:Pseq( 
			~bass0quarters[0]*[2,1,1]/4 ++ (~bass0quarters[1]*[1.9,1,1.1]/4)//moved with bass
			,3 
		),
		amp:Pseq([4,3,3]/10,3),
	].p 
	<> (out: p.strum1Fx.(b).bus.index, type:\strum, instance:p.strum1)
	=> _.play
});
P(\lick,start:0,music:[ 
	degree:Pseq([6,5,7]-1),
	dur:Pseq(~bass0quarters),//Pseq([2,2,4]),
	instrument:\sawSynth,
	att:1,
	rel:4,
	amp:0.05].p
);
P(\bass0,start:0,music: {
	[
		degree:Pseq([2,2,1,1,1,-2])-1,
		dur: Pseq(
			[~bass0quarters[0]*[3,1]/4 , ~bass0quarters[1]*[1,1.4,1.6]/4, 2].flatten
			//		[~bass0quarters[0]*[3,1]/4 , ~bass0quarters[1]*[1,2,1]/4, 2].flatten
		),
		octave:4
	].pp
}
	); 
	["now inhabit the bodies of", "d5 c b4 a g f g a"].addLine;  //1
	Song.setTempoMap(\inhabit,"e x e x e e e e");
	Song.tomFx = {Effect.bus({|i| DWGReverbC1C3.ar(i, mix: 0.15) / 2.5 }, out: 2)};
	P(\drums, music: { |p b e|
		[
			instrument: [\r, \MT_808, \LT_808].q,
			freq: [0, 120, 80].q,
			dur: "exexe ee e".asBeats.warpTo( e.tempoMap ).q,
			out: p.tomFx.()

		].pp
	});
	Song.setTempoMap(\inhab,"e x e x e e e e");
	P.still(\clear, timecode: 0.seconds, music: { |p b e|
		e.still.( 
			wait: b.sum,
			text: ["now inhabit","the bodies of"],
		)
	});
	P.still(\wide, timecode: 3303.5.seconds, music: { |p b e|
		e.still.( 
			wait: b.sum,
			text: ["",""],
		)
	});
	//Song.gfx1.synth.run(false);
	P(\guit1,start:1,music: { |p b e|
		var out = Song.strum1Fx.(Song.durs[1].list.sum+5);
		Song.strum1.setPlayMode(\strum);
		[
			degree: [5,[4,6,8],[3,5,8],[2,4],[2.1,4.1,6,8],[3,6,7],[3,5,7]].q - 1,
			octave: 4,
			dur: p.parse(1,[5,2,1]).q
			++ p.parse(2,[3,5,1,1]).q,
			legato: 0.96,
		].p
		+=
		[
			dur: p.parse(1, [1,1,2,1,2,1])
			++ p.parse(2, [1,1,1,5,1,1])
			=> _.q,
			switch: [\down,\up,\down].q(2)
			++ [\up,\four,\three,\down].q
			++ [\down,\five].q
			,
			amp:[0.2,0.01,0.2].q(2)
			++ [0.2,0.1,0.1,0.2].q
			++ [0.2,0.1].q
		].p 
		<> (\out:
			out.bus.index
			//p.strum1Fx.(b ++ [5])
			, type:\strum, instance:p.strum1) 
			=> _.play
		});
		P(\connectorBass,start:1,music: //		
			{
				[
					degree:Pseq([Rest(),3,2,1,1.1,2,3,4,4-7,0,7,0])-1,
					dur:Pseq(Song.parse(1,[[1,1,1,1,1],[1,1],1])++Song.parse(2,[[1,1,1],[1,1,1,1,1],1,1])++
					Song.parse(3,[[1,1],1,[1,1],1,1])),
					octave:3, root:2, scale:Scale.dorian
				].pp
			}
		); 
		["Captain Kirk,science officer Spock and", "b c5 f4 c5 d c b4 a a g"].addLine;  //2
		Song.setTempoMap(\science,"e e ee e e E E E ex x e e ee e e");
		P(\drums, music: { |p b e|
			[
				instrument: \kick_gentle,
				dur: "qq qq q".asBeats.warpTo( e.tempoMap ).q,
				amp: 0.2, vol: 0.15
			].pp
		});
		P.still(\clear, timecode: 0.seconds, music: { |p b e|
			e.still.( 
				wait: b.sum,
				text: ["captain","kirk"],
			).sequenceText2(
				b.parse([3, 7]), [ 
					["science officer","Spock and"],
				],
			)
		});
		P.synthVs(role: \mccoy, take:[ \lead, \double ],
		filter: (midinote: _ - 12), 
		pbind: Song.enlarge(5),
		params: {|p b| [
			lyrics: "r r r science +  officer + + Spock and doctor + jane Mulhall +",
			legato: [ [1, 1, 1,   1, 1, 1, 1, 1, 0.6,   1, 1, 1, 1, 1, 0.85] ],
			pitchTake: [ 1, 3 ]
		] }, music:{ 
			var pan = [-1,1]*0.5;
			pan.collect{|pan| {|p b e|
				{
					e.playbuf
					=> p.synthVTracks.at(e.key).()
					=> Pan2.ar(_,pan)
				}.play 
			}}
		}.()
	);
	P(\chords,start:2,syl:2,music:{|p b e|

		Song.piano.controller.synth.set(\out,
			Effect(SineShaper.ar(_, limit:0.03, mul:3.0, add:0) * [0.8,0.2], inputChannels:2).bus.index
		);

		[
			type:\vst_midi,
			//note:[6,[4,-1],5].q,
			freq: [4.5, [-7, 3], [4], [3,5]].df(octave:4).q,
			legato: [1, [2, 1],  1,	  1 ].q,
			dur: p.parse(2,[[1,1,1,1,1],[1,1]],3)++[ e.bNext.parse([3]), 2 ] => _.flat => _.q,
			vst:p.piano.controller ,
			amp:0.2,
			octave:4,
			legato:1,
		].pp 
	}
);
["Doctor Jane Mulhall. As -- ","b c5 d d c c f"].addLine; //3
P.still(\clear1, timecode: 0.seconds, music: { |p b e|
	e.still.( 
		wait: b.parse([5]).unbubble + e.bNext.sum,
		text: ["doctor Jane","Mulhall"],
		// onTop: true
	).sequenceText2(
			b.parse([5]), [ 
			["",""],
			],
			
		)
});
Song.preroll_(1);
P.still(\mccoy, timecode: 3251.3.seconds,lag: -1, syl: 4, music: { |p b e|
	e.still.( 
		fadeIn: 1,
		wait: b.drop(1).sum + e.bNext.sum,
		text: ["",""],
		fade: 2
	)
});
	P.still(\clear, timecode: 1.seconds, syl:4, music: { |p b e|
		e.still.( 
			wait: b.drop(1).sum + e.bNext.sum + p.durs[e.start+2].list.sum => _.postln,
			text: ["as planned","the construction"],
		).sequenceText2(
			b.drop(1).sum + e.bNext [0..4].sum 
			// + p.durs[e.start + 2].list.sum 
			=> _.bubble => _.postln,
			// 2,
			[ 
				["of android robots","is underway"],
			],
		)
	});
	P.synthV(\ninezero, take: \bg,
		pbind: Song.enlarge(1),
		params: {|p b| [
			filter: (midinote: 1.dm(\c)), 
			lyrics: "r r r r r as - planned ",
			pitchTake: 1
		] }, music:{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
			}.play
		});
		P.synthVs(role: \mccoy, take:[ \lead, \double ],
		filter: (midinote: _ - 12), 
		pbind: Song.enlarge2(6),
		params: {|p b| [
			lyrics: "r r r r r as - planned the construction + + of android + robots + is underway + + ",
			legato: [ [1,1,1,1,1, 1,1,0.75, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ] ],
			lag: [[0,0,0,0,0, 0,0,0, 0.3, 0,0,0,0,0,0,0,0,0,0 ]],
			paramTension: 0.4,
			pitchTake: [ 1, 3 ]
		] }, music:[-0.5,0.5].collect{|pan| {|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
				=> Pan2.ar(_,pan)
				* 2.dbamp

			}.play
		} });
		P(\playMode,start:3,syl:4,music:  //////////////FFFFFFFIIIIIIIIXXXXXXXX
			{
				(
					type:\vst_set,
					instance:Song.strum2,
					params:['Play Mode: Play Mode','Effect 1: On'],
					'Play Mode: Play Mode':0,'Effect 1: On':0
				)//.play
			}
		);
		P(\slide,start:3,syl:4,music: { |p b e|
			Song.strum1.setPlayMode(\pick);
			[
				type:\strum,
				note:Pseries(0,1,6)+[0,4],
				//amp:1,
				dur:Pseq([(1.1*0.882),0.1,0.1,0.1,0.1,1]*0.68),
				//dur:[b[0..1].sum]++((b[2]/7)!4)++2=>_.flat=>_.q,
				legato:Pseq([1.5,1.5,1.5,1.5,0.9,2]),
				instance:Song.strum1,
				out:Effect( { |i| 
					var env = Env.linen(0.5,b.drop(1).sum+3,1).kr(2,gate:1);
					SmoothClipQ.ar(i*(env*5+1),lo:-1+( env*0.9 ),hi:1-( env*0.9 )) 
					*0.6
				} ).bus.index
			].pp;
		}) ;  
		P(\strum24,start:3,syl:4,
			music: { Pmono(
				//\degree,Pseq([5,5,5,5,4,4,4,4,8,8,8,8,6,6,6,6],inf)+[0,5]-21,
				\pluckD,
				\degree,Pseq([ [1,3,5],[1,4,6] ])-1,
				\amp,0.025,
				\out,[0,1],
				\smooth,Pwhite(0.2,0.3,inf),
				\del,Pwhite(0.5,1,inf),
				\dur,Pseq(
					Song.parse(3,[ [1,1] ]) ++2
				)
				,
				\coef,0.1,//Pbrown(0.1,0.9,0.03),
				\lag,Pwhite(-0.01,0.01)
			).play; }
		);
		["Planned the con- struc- tion of an- droid","f5 c d c a4 c5 g f"].addLine; //4
		Song.setTempoMap('con-',"q ex x E E E e e ");
		P(\drum, music: { |p b e|
			[
				dur: "e ee e qe e qe e qe e ".asBeats.warpTo( e.tempoMap ++ p.tempoMap[e.start + 1] ++ p.tempoMap[e.start + 2] ).q,
				instrument: \kick_gentle,
				amp: 0.2, vol: 0.15
			].pp;
			[
				instrument: \sn_808,
				dur: "q qq qq qq q".asBeats.warpTo( e.tempoMap ++ p.tempoMap[e.start + 1] ++ p.tempoMap[e.start + 2] ).q,
				rest: MuteFirst()
			].pp;
			[
				instrument: \hihat,
				dur: "q*8".beats.warpTo( e.tempoMap ++ p.tempoMap[e.start + 1] ++ p.tempoMap[e.start + 2] ).q
			].pp
		});
		~quarters4=Song.parse(4,[1,2,3,2]);
		P(\bass4,start:4,music: {|p b e|
			[
				dur:Pseq( 
					[
						~quarters4[0]+(~quarters4[1]*0.5),
						~quarters4[1]*0.5,
						~quarters4[2]+(~quarters4[3]*0.5),
						~quarters4[3]*0.5
					].flatten,   2
				),
				amp:0.5,
				degree:Pseq([4,3,2,2,5-7,5-7,5-7]-1),
				octave:3
			].pp
		}
	);
	P(\guit4,start:4,music: //		
		{ //do these with an event instead??
			var roots=[
				//lag:0.19,
				note:[-7,[2,5],-5].q,
				type:\strum,
				instance:Song.strum2,
				dur:Pseq([2,2,4]*~quarters4.sum/4),
				legato:0.94
			].p;
			var strums=[

				type:\strum, switch:Pseq([Rest(),\down,\up])++Pseq([\down,\down,[Rest(),\up].choose],3),
				instance:Song.strum2,
				dur:[2,1,1]/2 => _.q(4) * ~quarters4.sum/4,
				amp:0.05
			].p;

			Song.strum2.setPlayMode(\strum);
			Ppar([roots,strums]).play;
		}

	);
	["ro- bots is un- der- way","e5 d c d  e g4"].addLine; //5
	Song.setTempoMap('un- der',"e ee e x x eee");
	["All is pro- cee- ding as ex- pect- ed and as pro- mised (ba- by)","f g a c5 d b-4 c5 d e- b-4 d5 e- d b-4 c5 d"].addLine; //6
	Song.setTempoMap(\mised,"e e e e e e e e e e e e e e e e");
	P(\drums, music: { |p b e|
		[
			instrument: \LT_808,
			freq: [120, 120, 80, 80].q,
			dur: b.q,
			out: p.tomFx.()
		].pp;
		[
			instrument: \kick_gentle,
			dur: "qq e eq e eq e eq".asBeats.warpTo( e.tempoMap ).q,
			amp: 0.2, vol: 0.15
		].pp;
		[
			instrument: \sn_808,
			dur: "qqq qq qq qq".asBeats.warpTo( e.tempoMap ).q,
			rest: MuteFirst()

		].pp;
		[
			instrument: \cymbalsDS,
			amp: 0.03,
			att: 0.05,
			dur: "qq q".asBeats.warpTo( e.tempoMap ).q,
			rest: MuteFirst()
		].pp
	});
	P.synthVs(\jun, take: [ \bg1, \bg2], params: {|p b| [
		lyrics: "everything's + + proceeding + + as expected + + and as promised + r r  ",
		//+ + as expected + + and as promised + baby +",
		filter: 
		[
			[3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 3, 4, 4, 4],
			[1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 1, 1, 1, 1]
		].dm('f',5).collect{|i| ( midinote: i) },
		pitchTake: [ 1, 3 ],
		vocalMode: \Soul
	] }, music:{|p b e|
		{
			e.playbuf
			// => p.synthVTracks.at(e.key).()
			=> BPF.ar(_,2000,0.4) /3
			=> {|i| CombN.ar(i, 0.4,0.4) * [0.1,0.9] + i}
		}.play
	});
	P.still(\closer, timecode: 3255.seconds, music: { |p b e|
		e.still.( 
			wait: b.sum,
			text: ["everything's","proceeding"],
		).sequenceText2(
			b.parse([6]), [ 
				["as expected","and as promised"],

			],
		)
	});
	~quarters6= Song.parse(6,1!4!4);
	q=0.9; ~gr=0.2; 
	P.synthVs(role: \mccoy, take:[ \lead, \double ],
	filter: (midinote: _ - 12), 
	params: {|p b| [
		lyrics: "everything's + + proceeding + + as expected + + and as promised + baby +",
		pitchTake: [1, 3],
		pitchExpression:1.29,
		paramTension:0.25,
		paramBreathiness: -0.2
	] }, music:[-0.5,0.5].collect{|pan| {|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			=> Pan2.ar(_,pan)
			* Env([4,2],[b.parse([8,4])]).kr(gate:1).dbamp
		}.play
	} });
	P(\strum2h5,start:6,music: {|p b e|
		var out;
		p.strum2.setPlayMode(\pick);
		p.strum2.controller.synth.set(\out,
			out = Effect( { |i| 
				SmoothClipQ.ar(i*8,lo:-0.1,hi:0.1) 
				*0.5
			}).bus.index);
			[
				degree:Pseq([1,2,3,5,4]-1),
				//dur:Pseq(1!4++[4]/2),
				dur: Pseq(Song.durs[6].list[0..3]++Song.durs[6].list[4..7].sum),
				legato:0.95,
				root:5,
				octave:3,
				type:\strum,instance:p.strum2,

			].p += 

			[ 
				degree:Pseq([1,2,3,5,5.1,6]-1),
				//dur:Pseq([1,1,1, (1-~gr),~gr,4 ]/2*0.98),
				dur:Pseq(Song.durs[6].list[0..2]++[Song.durs[6].list[3]-~gr,~gr,3.5]),
				legato:Pseq([q,q,q,1.4,1.4,1]),
				root:5,
				octave:3,
				type:\strum,
				instance:Song.strum2,
			].p
			<> (out:out) =>_.play; 
		}); 
		P(\strum2h6II,start:6,syl:7,music: {|p b e|
			[ 
				degree:Pseq([[4, 6.1, 2 ],4]-1),
				dur: Pseq(~quarters6[2..3]) ,
				legato:0.96,
				root:5,
				octave:3,
				type:\strum,instance:Song.strum2,

			].pp; }
		); 
		P(\strum2h5Strum,start:6,syl:5,music:{|p b e|
			p.strum2.setPlayMode(\strum);
			[ //		
				//var b2s=[
				type:\strum,
				instance:Song.strum2,
				switch:Pseq([\down, \up, \down,],3),
				//dur:Pseq([1,1,2]/2,3),
				dur:Pseq(Song.durs[6].list[6..7]++Song.durs[6].list[8..9].sum,3),
			].pp;

		}); 
		P(\guit6,start:6,music: {
		}
	);
	P(\bass6,start:6,music:
		{
			[
				degree:Pseq([Rest(),1,4,1,2]-1),
				root:10,
				octave:2,
				amp:0.4,
				dur:Pseq( Song.parse(6, 1!4!4))
			].pp
		}
	);
	P(\saw6,start:6,music:
		{
			[ 
				degree:Pseq([Rest(),1,4,1]-1),
				//dur:Pseq([5,4,4,2 ,3])/2,
				dur:Pseq( Song.parse( 6, [1!5,1!4,1!4,1!2])++[3]) ,
				//type:\vsti,
				//controller:p.controller
				instrument:\sawSynth,
				rel:3,att:0.2,
				//amp:0.35,
				amp:0.1,
				root:5,octave:[4,5]
			].pp;
		}
	);
	P(\pf6,start:6,syl:7,music:
		{
			[
				degree:Pseq([2,4,6,6.1,1,4,5,6])-1,
				root:5,
				instrument:\default,
				instrument:\defaultPiano,
				octave:[6,5],
				//dur:0.5,
				dur:Pseq(Song.durs[6].list[8..]),
				legato:3,
				amp:0.075,
				out: [2,3]
			].pp;
		}
	);
	["I can see no rea- son for con-","e-5 d c b-4 g b- c5 d"].addLine; //7
	P.still(\clear, timecode: 0.seconds, music: { |p b e|
		e.still.( 
			wait: b.sum + e.bNext[0],
			text: ["I can see no","reason for"],
		).sequenceText2(
			b.parse([7]), [ 
				["concern...",""],
			],
		)
	});
	P.synthVs(role: \mccoy, take:[ \lead, \double ],
	filter: (midinote: _ - 12), 
	pbind: Song.enlarge(1),
	params: {|p b| [
		lyrics: "I can see no reason +  for concern + ",
		pitchTake: [ 1, 3 ]
	] }, music:[-0.5,0.5].collect{|pan| {|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			=> Pan2.ar(_, pan)
		}.play
	} });
	["cern. And yet, I am filled with fore- bo- ding...", "d5 c b4 a b c5 e4 a g f#"].addLine; //8
	P.still(\wide, timecode: 3302.seconds, syl:0,  music: { |p b e|
		e.still.( 
			wait: b.sum,
			text: ["and","yet"],
			fade: e.bNext.sum
		).sequenceText2(
			b.drop(1).parse([2]), [ 
				["I am filled","with foreboding"],
			],
		)
	});
	P.synthV(role: \mccoy, take: \lead,
		filter: (midinote: _ - 12), 
		params: {|p b| [
			lyrics: "r and yet I am filled with foreboding + +",
			vocalMode: \Soft,
			paramTension: 0.3,
			pitchTake: 1
		] }, music:{|p b e|
			{
				e.playbuf
				// => p.synthVTracks.at(e.key).()
				=> Pan2.ar(_)
				/3.2
			}.play
		});
		SynthDef(\avsd, 
			{
				|freq=400 att=0.05 |
				var fenv= Env.perc(att,8.5).kr(gate:1);
				var env= Env.perc(att*2.2,8.5).kr(gate:1);
				var tail= Env.perc(att*2.2,11).kr(2,gate:1);
				var freqs= freq*rrand(0.99,1.01!2);//
				var sig= SawDPW.ar(freqs) * \sawAmt.kr(0.05);
				sig=Formants.ar(freqs/2,Vowel())+sig*\amp.kr(0.05);
				sig=MoogVCF.ar(sig,fenv*1500+(freq),0.9);
				sig=PlateReverb.ar(sig,mix:0.2);
				Out.ar(\out.ir(0),sig*env);
			},[0.3]
		).add; 
		SynthDef(\tritri,{
			|freq=400 gate=1|
			var sig=DPW3Tri.ar(freq,\amp.kr(0.1));
			var env= Env.asr(\att.kr(0.1),\sus.kr(1),\rel.kr(2)).kr(2,gate:gate);
			Out.ar(\out.ir(0),sig*env);

		}).add; 
		P(\pauseAAS, music: { |p b e|
			p.strum1.syn.run(false);
			p.strum2.syn.run(false);
		});
		P(\forboding8,start:8,music: {|p b e|
			var keyAmp = 0.dbamp;
			Ppar([
				[
					degree:Pseq([\r,[0,2,5],[-1,1.1]]-1),
					root:2,
					scale:Scale.mixolydian,
					octave:[4,5],
					instrument:\tritri,
					att:0.2,
					rel:3,
					amp:0.07 * keyAmp,
					out:2,
					dur:Pseq(Song.parse(8,[1!3,1!5,1!2])),
				].p,
				Pmono(
					*[
						\avsd,
						degree:Pseq([ [1,3],[0,2],[6-7,1.1]]-1),//thicken chord?
						//degree:Pseq([ [1,3],[0,2],[5-7,1]]-1),
						att:2,
						scale:Scale.mixolydian,
						dur:Pseq(Song.parse(8,[1!3,1!5,1!2])),
						root:2,
						out: 1,
						amp:0.05 * keyAmp * -5.dbamp,
					]
				).trace,
				Song.pbind[8],
				[ //bass
					degree:Pseq([[1,1-7],6-7,7-7,[6-7,1.1],5-7-7]-1),
					//degree:Pseq([1,6-7,7-7,[5-7,1]]-1),
					root:2,
					octave:4,
					dur:Pseq(Song.parse(8,[[1,1],1,1!5,1!2]))++Pseq([8]),
					scale:Scale.mixolydian,
					out: 3
				].p,

				[ //final chord

					instrument:\avsd,att:8,amp:0.018 * 2,degree:Pseq([\r,[5,7,9,11.1]-1]),dur:Pseq([8,12]),octave:4,root:2
				].p
			]).play
		}
	);
}.()
)




