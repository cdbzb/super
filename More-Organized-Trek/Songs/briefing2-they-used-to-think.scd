( 
	//~synthsLoaded.isNil.if{"/Users/michael/tank/super/song-Synthdefs.scd".load};
	Song(\theyUsed,[]).current;

	~moonChord="e- f a c#" => ~panNotes.(_);
	~marsChords=[0,2].collect{|root| [ freq:	[ [1,4,6].dup++[1,3,5] .dup ].flatten.degreescps(root:root).q ].p }.q;

	SynthDef( \sawzz,
		{Saw.ar(\freq.kr(400,\port.kr(0.5)),0.1)
		* Env.asr(0.1,1,2).kr(2,gate:\gate.kr(1))
		* \amp.kr(0.1)
		=>(CombN.ar(_,1)+Gain.ar(_,3))
		=>Out.ar(\out.kr(0),_)}
	).add;

	Song.resources=();
	Stills.new.current;
	{
		["they used to think if man could ","f3 f g g a a b "].addLine; //0
		P.still(\kirkUsed, timecode: 2314.1.seconds, music: { |p b e|
			 e.still.( 
				wait: b.sum,
				text: ["",""],
			)
		});
		P.still(\kirk, timecode: 2314.seconds, music: { |p b e|
			e.still.( 
				wait: b.sum,
				text: ["they used to think","if man could"],
				fade:3
			).sequenceText2(
				b.sum, [ 
				["",""],
				],
			)
		});
		( Song.synthVTracks = EventWithDefault(
			\default, {
				{|i|
					DWGReverbC1C3.ar(i,mix:0.1)
					/8
				}
			}
		);
	);
P.synthVs(role: \kirk, take: [ \lead, \doub ],
		pbind: Song.enlarge2(2),
		params: {|p b| [
		lyrics: "they used to think if man could fly he'd have wings but he did fly",

		pitchTake: [ 1, 3 ],
		pitchExpression: 1.4,
		legato: [ [1,1,1,0.6,1,1,0.9] ],
		tension: Env([0,1],b.sum),
		loudness: Env([0,6] -6,b.sum)
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
	P(\pedalNote, syl:0, music: { |p b e|
		(
			// instrument: \stringyy,
			instrument: \sawSynthSustain,
			freq: [-1,1].df(\f,[ 2, 3,4 ]),
			amp: 0.01,
			dur: b.sum + e.bNext.sum,
			att: 1,
			sus: b.sum - 1,
			rel: e.bNext
		).play
	});
	Song.synthVLyric = Order.new; 
}.();
// P.tune(\think);
["fly, he`d have wings, but he","b3 a g c#4 b3 c#4"].addLine; //1
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["fly, he'd have wings","but he" ],
	)
});
P(\line, music: { |p b e|
	[
		instrument: \wash,
		freq: [1,2].df(\b).q,
		dur: b.parse([3, 3]).q,
		out: [0,1].q
	].pp
});
// P.tune(\wings);
["did fly (boom boom)", "e4 d a3 f#"].addLine; //2
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["did","fly"],
	)
});

P.synthV(\ninezero, take:\lead, 
	filter: (midinote: [3,3,3,3].dm(\d)), 
	params: {|p b| [
		lyrics: "did fly r r",
		vpcalMode:\Opera,
		pitchTake:1,
		pitchExpression: 1.5,
		legato:[1,2]
	]}, music:{|p b e|
		{
			e.playbuf
			/8
		// => p.synthVTracks.at(e.key).()
		}.play
	}
);

	P.tune(_ <> (instrument: \harp, amp:0.02));
	P(\chord,start:'did fly',music: {|p b e|
		[
			//		dur:~tu.secDur[2..3].q,
			dur:p.secDur[e.start..(e.start+2)].q,
			freq:[[2,5,7],[1,4,6],[1,3,5]].df(\g,3).q,
			amp:0.04,
		].pp 
	});
	P(\wowowow,start:'did fly',syl:1, lag:0.15, music: {|p b e| 
		{
			var notes = [11,6,3].degreescps;
			var durs = [0]++(p.durs[e.start].list[2..3]).integrate;// + ~tu.durs[2].list[2] ;
			{a=Synth(\sawzz,[\freq,notes[0],\amp,0.1]).dur(4)}.sched(durs[0]);
			[1,2].do{|i| {a.set(\freq,notes[i])}.sched(durs[i])}
		}.play
	});

	// P.tune('did fly');
	P(\cymbal, music: { |p b e|
		(instrument: \cymbalsDS, amp:0.02).play
	});
	["(boom) he discovered he ","c d4 c b3 a b"].addLine;//3
	P.synthV(role: \kirk, take: \lead, params: {|p b| [
		lyrics: "r he discovered + + he ",
		legato: [1, 1, 1, 1, 1]
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});

	P.tune(_ <>(instrument:\harp, amp:0.02));
	P(\boomBass,start:\discovered,music:(note:0,octave:3,amp:0.5,dur:Song.secDur[3]));
	["had to.. do you wish that the first","c4 b3 g#3 e b g# a b"].addLine;//4
	P.tune();
	P.synthV(role: \kirk, take: \lead, prepend: true, params: {|p b| [
		lyrics: "had to do you wish that the first",
		legato: [1, 0.8, 1, 1, 1, 1, 1, 1 ],
		pitchTake: 2
		// lag:[0.1,0.1]/2
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
	P.double(role:\kirk, take: \lead, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
	P(\wowowow,start:\first,syl:1,music: {|p b e|
		[
			freq: [15,13,7].df(\e,4,\mixolydian).q,
			dur:p.parse(e.start,[1,1,3],2).q,
			instrument: \sawzz

		].ppm
	}
);
P(\bass,start:\first,music: {|p b e|
	( 
		freq:[5].df(\c,2),
		amp:0.5,
		dur:p.parse(e.start,[4]),
	).play
});
P(\bass,start:\first,syl:3,music:{|p b e| 
	[ 
		freq:[5,6,2].df(\e,2,\mixolydian).q,
		amp:0.5,
		dur: (p.parse(4,[[1,1,1,2/3],1/3],4) + ([0]++p.parse(5,[1,2]))).q ,
	].pp 
});
["Apollo mission hadn`t reached the","c#4 f# c# e d# b-3 a- b- b"].addLine;//5
P.still(\kirkPoint, timecode: 2317.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.synthV(role: \kirk, take: \lead,
	// prepend: true,
	params: {|p b| [
	lyrics: "apollo + + mission + hadn't + reached the",
	language:\english,
	phoneset: \arpabet,
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \kirk, take:\lead, params: {|p b| [
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});

["moon... or that we hadnt  ","c#4 b3 a g a b  "].addLine;//6
P.synthV(role: \kirk, take:\lead, prepend: true, params: {|p b| [
	lyrics: "moon or that we hadn't + ",
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \kirk, params: {|p b| [
	
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\baas,start:\moon,music:(
	freq:[1].dm('e-',3),
	dur: Song.secDur[6],
	amp:0.5,
));
P(\ooh, start:\moon,music: {
	{ 
		var effect = Effect.bus(FreeVerb.ar(_,0.6,0.9));
		var choir=Synths(\ooh,
			\freq,~moonChord.midicps,
			\blend,0,
			\out,effect
		);
		fork{
			s.latency.wait;
			{choir.set(\blend,1,\lag,0.5)}.sched(1);
			choir.synths.do{|i|{ { i.set(\blend,1) }.sched(4.2.rand) }.value};
			fork{7.do{choir.set(\blend,[0,0,0,1].scramble) ;rrand(0.6,1.2).wait}};
			{choir.release(4)}.sched(1);
		}
	}.value
});
["gone on to" , "d4 e- b3"].addLine; //7
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "gone on to",
	pitchTake: 1,
	timbreExpression: 1.5,
	paramTension: 0.5,
	pitchExpression: 1.4,
	paramBreathiness: 0.5,
	paramToneShift: 250


] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \kirk, take: \lead, params: {|p b| [
	
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\bass,start:'gone on', music: {|p b e|
	[
		amp:0.5,
		freq:[3,3.5,1].df(\b,2,\minor).q,
		dur: p.parse(e.start,[[1,1/3],2/3,1]).q,
	].pp
});
//~recorder.(Song,7,2)
["Mars, and then to the nearest","a4 g4 g e f g e"].addLine;//8
Song.setTempoMap(\nearest,"qe e e x x e e");
P(\tamb, music: { |p b e|
	{
	var levels = [5,1,2,1] /5 => _.dq(inf);
	var durs =  
	1/4 ! 15
	+ ( [1, -1] /80 => _.dup(8) ) //swing amt
	=> _.flat 
	=> _.warpTo(e.tempoMap.quantizeDft(0.3))
	=> _.dq();
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
	* EnvGen.cutoff(b.parse([4]).unbubble,3)
	=> DWGReverbC1C3.ar(_,mix:0.05)
	/6
	=> Pan2.ar(_,0.75)

}.play;
});
P(\drumz, music: { |p b e|
	var amp = 0.1;
	[
		"qe e qe e", \bd_808, \amp, amp,
		"q qq q ",\sn_808,
		\amp,amp  ,
		\rest, [\r, 1, 1, 1, 1].q,
		\lag,[0, 0.04,0 ].q
		
	].dmx2(4, e.tempoMap.quantizeDft(0.0))
	=> Ppar(_) => _.play
});

P(\cymbal, music: { |p b e|
	(
		instrument: \cymbalsDS,
		amp:0.02
	).play
});
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "mars and the to the nearest +" ,
	pitchTake: 0,
	timbreExpression: 1.5,
	paramTension: 0.5,
	pitchExpression: 1.4,
	paramBreathiness: 0.5,
	paramToneShift: 250,
	paramLoudness: 3
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \kirk, take:\lead, params: {|p b| [
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,1)
	}.play
});
Song.quarters8=Song.parse(\Mars,[2/3,[1/3,1],3,2]);
P(\ooh,start:'Mars',music:{|p b e|
	( 
		instrument:\ooh,
		freq: [5,11,13].df(\f),
		blend:1,
		amp:0.01,
		dur:p.parse(8,[[1,1]]) ,
	).play 
});
P(\middleVoice, start:'Mars',music:(note:0,dur:2,instrument:\sawzz,));
P(\bass,start:'Mars',music: {|p b e|
	[ 
		amp:0.5,
		freq: [11,7,7].df(\f,2).q ,
		dur: p.parse(e.start,[1,1,1]).q,
	].pp 
});
P(\bass,start:'Mars',music:[ 
	amp:[0.5,0.4,0.1,0.5,0.5,0.1,0.1,0.5,0.5].q,
	freq:[4,4,4,2,3,3,3,3,2].df(octave:3,).q,
	//	freq:[4,4,4,3,3,3,2].df(octave:3,).q,
	dur:
	//	( Song.parse(8,[1/3,2/3,1,1,3,1])++1 ).q
	Song.quarters8.collect(0.5*_.dup).flatten.q ++ [1].q
	,
].p);
P(\guitar,start:'Mars',music: {|p b e|
	Pmono(\pluckDVerb, 
		\blend,[-1,-1,-1,-1,1].q,
		\amp,0.02,
		\freq, [[11,14],[11,13],[5,12]].collect{|i| i!2}.flatten.df(octave:3).q ,
		\octave,2,
		\out,[0,1],
		\smooth,Pwhite(0.2,0.3,inf),
		\del,Pwhite(0.5,1,inf),
		\dur,Song.quarters8.q++ ( p.parse(e.start,[1]).q +0) ,
		\coef,Pbrown(0.1,0.9,0.03),
		\lag,Pwhite(-0.01,0.01)
		//\lag,[0,1]

	).play
});
["star (boom boom) ","b4"].addLine;//9
P(\cymbal, music: { |p b e|
	(
		instrument: \cymbalsDS,
		amp:0.02,
		out:1
	).play
});
P.synthV(\ninezero, take: 1,
	pbind: {|p b| [dur: b* 3 => _.q, midinote: 1.dm(\b,5)].p},
	params: {|p b| [
	lyrics: "mars",
] }, music:{|p b e|
	{
		e.playbuf
		/6
		=> FreeVerb.ar(_,1,1)
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(role: \kirk, take: \lead,
	pbind: {|p b| [dur: b* 3 => _.q, midinote: 1.dm(\b,5)].p},
	params: {|p b| [
	lyrics: "star" ,
	pitchTake: 1,

] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \kirk, take:\lead, 
	pbind: {|p b| [dur: b* 3 => _.q, midinote: 1.dm(\b,5)].p},
	params: {|p b| [
	
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,1)
	}.play
});
P.tune();
P(\highchord,start:'star',music:( 
	instrument: \stringyy,
	freq: [1,3].df(\a,6),
	dur: 1
));
[ "thats like saying you ",[3,1,4,3,4].dm(\b) ].addLine; //10
P.still(\kirkTwoHands, timecode: 2326.1.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});

P.tune(\saying);
P.synthV(role: \kirk, take:\lead, filter: (midinote: _ - 12),  params: {|p b| [
	lyrics: "thats like saying + you",
	pitchExpression: 1,
	pitchTake:1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role:\kirk, take: \lead, params: {|p b| [
	
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\bassnote,start:'saying',music:{|p b e|
	[ 
		freq:[7,11,12,13,13.5,14.5,15.5].df(\e,3,scale:\harmonicMinor).q,
		dur:b.parse([2,3]).q 
		++ e.bNext.parse([4,5]).q
		++ e.bNext(2).parse([5,2,2]).q
		=> _.postln
		,
		instrument:\stringyy,
		out: [0,2].q(inf),
		amp:0.3
	].pp
});
[ "wish that you still operated with", [5,3,4,5].dm(\B)++[4,1,2,3,4].dm(\d) ].addLine;
P.still(\clear, timecode:0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	).sequenceText2(
			b.parse([4]), [ 
			["operated","with"],
			],
	)
});
P.synthV(role: \kirk, take:\lead, prepend:true, params: {|p b| [
	lyrics: "wish that you still operated + + + with",
	pitchTake: 1,
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \kirk, take: \lead, params: {|p b| [
	
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
[ "scalpels and sewed your patients up with",[3,2,1,2,3,4.5,2].dm(\e)++[11,6].dm(root:0) ].addLine;//12
P.still(\clear,timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["scalpels and sewed your","patients up with"],
	)
});
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "scalpels + and sowed your patients + up with",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \kirk,take: \lead, params: {|p b| [
	
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\sewed,start:'scalpels',syl:4,music:
	{|p b e|
		[ 
			attack:3,
			depth:0,
			freq:[5,11,11].df(\a,3).q,
			port:1.1,
			dur:p.parse(e.start,[4],5).q ++ e.bNext.parse([1,3]).q,
		].pm(\tri).play
	}
);
//Song.sewed12.p;Song.pbind[12].play
P(\patience,start:'scalpels',syl:5,music: {|p b e|
	[ 
		pan:1,
		amp:0.1,
		instrument: \sawzz,
		freq:[2,1,1].df(\d,5).q,
		dur:p.parse(e.start,[2,1],5).q++[1].q
	].pp
});
[ "cat-gut like your great great great great", [4,3,4,5].dm(\d,scale:\minor) ++[3,4,2,3].dm(\B,scale:\harmonicMinor) ].addLine; //13
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["cat-gut like your","great great"],
	).sequenceText2(
			b.parse([6]), [ 
			["great","great"],
			],
	)
});
P.synthV(role: \kirk,take: \lead, params: {|p b| [
	lyrics: "cat gut like your great great great great",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role:\kirk, take: \lead, params: {|p b| [
	
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\lick,start:'cat-gut',syl:3,music:{|p b e|
	[ 
		freq: [11,12,7,11,4].df(\b,3,\harmonicMinor).q,
		dur:p.parse(e.start,[1,1,1,1],4).q++[p.secDur[e.start+1]].q,
		out: 0,
		//	port:1,
	].pm(\sawzz).play }
);
P(\bassnote,start:'cat-gut',music:{|p b e|
	( 
		freq:[ 11,5 ].df(\d,2),
		dur:p.parse(e.start,[4])
	).play 
});
SynthDef( \harpsichord, { Pulse.ar(\freq.kr(300),0.25,\amp.kr(0.1))* Env.perc().kr(2,gate:1) => Out.ar(\out.kr(0),_)} ).add; 
P(\harpsichord,start:'cat-gut',syl:3,music: {|p b e|
	[
		drive:0,
		decaytime:50,
		strum:0.03,
		dur: p.parse(e.start,[1,1,1,1],4).q++[Song.secDur[e.start + 1]].q,
		//				amp:0.02,
		//				detune: [-3,10],
		//				instrument: \harpsichord,
		instrument:\pluckDVerb,
		coef:0.1,
		//		drive:0.1,
		freq:[[5,11,13],[5,12,14],[5,7,12],[5,11,13],[4,6.66,13]].df(\b,3,\harmonicMinor).q * [1,2],
	].pp
});
P(\lickharmony,start:'cat-gut',syl:3,music: {|p b e| [ 
	\freq, [13,14,12,13,7].df(\b,3,\minor).q,
	dur:p.parse(e.start,[1,1,1,1],4).q++[p.secDur[e.start+1]].q,
	\out,1,
	//	port:1,
].pm(\sawzz).play } 
	);
	[ 'grandfather used to',[4,3,2,2,1].dm(root:\A) ].addLine;//14
	P.still(\clear, timecode: 0.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["grandfather","used to"],
		)
	});
	P.synthV(role: \kirk, take: \lead, params: {|p b| [
		lyrics: " grandfather + + used to",
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
	P.double(role: \kirk,take: \lead, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
	P(\highchord,start:'grandfather', music:( 
		instrument:\stringyy,
		freq: [1,4].df(\e,5),
		dur: Song.secDur[14],
	));
	P(\chord,start:'grandfather',music:( 
		strum:0.06,
		freq:[5,11].df(\a,1) *.x [1,2],
		dur:Song.secDur[14],
		amp:0.2
	));
	P(\bell,start:'grandfather',syl:2,music:( 
		freq: [5,11].df(\e,5),
		amp:0.02,
		strum: 0.07,
		dur:2,
	));

	// Song.addGuides("xxx");

	//~im2=Song(\ImInControl2,[])//.current; //{{{
	//			["I'm (boom) in (boom) con-","g4 a-3 g4 a-3  f4"].addLine;,//0
	['(boom) Im (boom) in (boom) con',"a-3 a-4 a-3 a-4 a-3 a-4"].addLine;//correction

P.still(\kirkCommand,syl:0, timecode: 2348.25.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
	Song.setTempoMap(\Im,"q q q  E E E");
	P(\hat, music: { |p b e|
		[
			dur: 0.5.dup(8).asBeats.warpTo( e.tempoMap.quantizeDft(0.0) ) * [1, 1, 1, 1, 1, 1, 0.8, 1] =>_.q,
			instrument: \hihat,
			amp: 0.04
		].pp
	});
	P.synthVs(\an, take: [ \bg1, \bg2 ],
		
		params: {|p b| [
		filter: [ (midinote: -5.dm('a-')!6), ( midinote: -7.dm('a-')!6 ) ],
		lyrics: "r i'm r in r kun",
		pitchTake: [ 1,2 ]
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			/2
		}.play
	});
	P.tune();
	P.synthVs(role: \kirk,
		pbind: Song.enlarge(1),
		take:[ \lead, \double ],  params: {|p b| [
		lyrics: "r I'm r in r control +",
		pitchTake: [ 1, 3 ]
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
	SynthDef(\argybargy,{|freq=400 width=10 out=1| //{{{
		Gendy1.ar(minfreq:freq-width,maxfreq:freq+width)
		=>( CombN.ar(_,0.4,0.11,2)+Gain.ar(_,0 ) )
		* Env.asr(0.05,1,\rel.kr(1.5)).kr(2,gate:\gate.kr(1))
		* \amp.kr(0.1)
		=>Out.ar(out,_)
	}).add;

	P(\aaaiii,start:'Im',syl:0,music: { //{{{
		{ 
			var envelope = Env.linen(0.1,2.5,1.5).kr(2);
			var blend = Line.kr(dur:3,);
			var cord = [1,3,5,7].df('a-');
			Formants.ar(cord, vowel:Vowel().blend(Vowel(\i,\bass),blend).brightenLin(3,0))
			* 0.02 * envelope
			=> Splay.ar(_)
		}.play;
	});//}}}
	~bassnotes0=Song.parse('Im',[[1,1],[1,1],[1,1]])++Song.parse(1,[1]);
	~chords0=Song.parse('Im',[[1,1],[1,1],1],1) ++Song.parse(1,[1]);

	SynthDef(\timpany,{
		MembraneCircle.ar( PinkNoise.ar(0.1) * Env.perc().ar(0,gate:\tgate.tr(1)),\tension.kr(0.01),\loss.kr(0.9999) )
		=>LeakDC.ar(_)
		* Env.cutoff(5).kr(2,gate:\gate.kr(1))
		* \amp.kr(0.1)
		=>Out.ar(\out.kr(1),_)
	}).add;
	P(\timpany0,start:'Im',music:Pmono(*[
		\timpany,
		amp:0.3,
		tgate:1,
		//		instrument:\timpany,
		dur:~bassnotes0.q,
		loss:0.99995,
		//		out:[0,1].q(2),
		tension:0.01*6/5/[1 , 2 ],
	]));
	P(\bassnotes0,start:'Im',music: [amp:0.7,instrument:\default,dur:~bassnotes0.q,legato:[1,1,1,2].q,degree:[0,0,0,3].q,root:-4,octave:[3]].p);
	P(\chords0,start:'Im',syl:0,music:[amp:0.05,legato:[1,1,1,2].q,degree:[1,3,5,7]-1,root:-4,dur:~chords0.q].p);
	//}}}
	//// 1 & 2 (from ~im above)//// {{{
	/*
	all {:x,
		x<-~im.resources.keys, var y=~im.resources.at(x),
		x.asString.contains("voc").not, //mute vocals
		y.class==Part, y.start>=1,
		::	y.parent=~im2;
		~im2.resources.add(x->y);
		x.postln
	};
	//~im2.addGuides(".xxxx|.xxxx|xx");
	*/
	//}}}
	//// 3 ////  
	SynthDef(\pulseBass,{ //{{{
		Pulse.ar(\freq.kr(400,0.3),0.3)=>Mix.ar(_)//=>MoogLadder.ar(_,800,1)//=>MoogFF.ar(_,1900,0.5) 
		//=>CombN.ar(_)//++Gain.ar(_)
		//=>FreeVerb.ar(_,1,1)
		* Env.adsr(0.01,0.05,0.6,\rel.kr(0.5)).kr(0,gate:\gate.kr(0)) 
		* \amp.kr(0.03)
		=>RLPF.ar(_,\freq.kr*62,2)
		=>Out.ar(\out.kr(1),_)
	}).add;

	//}}}
	["trol, I can order this (boom) but I'm","f4 e- f g- f d- f#3 c4 d- "].addLine;//1
	P.synthV(role: \kirk, take:\lead,
		prepend: true,
		lag: [0.2,0],
		params: {|p b| [
		lyrics: "troll, I can order + this r but I'm ",
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
	P.double(role: \kirk, take: \lead,
		prepend: true,
		params: {|p b| [
			
		] }, music:{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
			}.play
		});
	P(\order1,start:'trol,',syl:2,music:{|p d| //{{{
		[
			amp:0.03,
			out:1,
			instrument:\argybargy,
			legato:Pseries(3.5,-0.4,inf),
			midinote:(p.tune[Song.section('trol')].list[3..6]).q,
			dur:Pfin(4,d.q)
		].pp
	});
	//}}}
	SynthDef(\sawzz2,{ //{{{
		Saw.ar(\freq.kr(400,0.5)+( Rand(-4,4.0!2)++[0] ),\amp.kr(0.1))
		//Saw.ar(\freq.kr(400,0.5)+Rand(4.0!3),\amp.kr(0.1))
		=>MoogFF.ar(_,\cutoff.kr(800,\fLag.kr(1)),\res.kr(3))
		* Env.asr(\att.kr(0.2),1,3).kr(2,gate:\gate.kr(1))
		=> Splay.ar(_)
		=>Out.ar(\out.kr(0),_)
	}).add;
	//}}}
	P(\boom1,'trol,',5,music:(//{{{
		out:0,
		att:0.9,
		\cutoff:2222,
		res:1.6,
		instrument:\sawzz2,
		amp:0.5,
		degree:0,
		root:6,
		dur:1,
		octave:[4,3],
		amp:0.3)
	);//}}}
	//2
	["not be- cause","e d c"].addLine; //2
	P.synthV(role:\kirk,take:\lead,  params: {|p b| [
		lyrics: "not because +",
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
	P.double(role:\kirk,take:\lead, params: {|p b| [
		] }, music:{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
			}.play
		});
	P(\harpy2,'be-',music://{{{
		{|p m| p.postln;
			{
				var b={var c = Bus.audio(s,1); {In.ar(c,1)+CombL.ar(In.ar(c,1),1,\del.kr(0.5)+SinOsc.kr(0.1,pi,0.02),6)}.play(s,1);c}.value;
				[
					degree:Prand(Arpeggio([1,3,5,7],9),23)-1,
					amp:0.03,
					root:5,
					out:b.index,
					octave:5,
					dur:Pwhite(0.02,0.03)*3,
					legato:5
				].pp
			}.value
		}
	);

	//}}}
	//~im.addGuides("xxx");
	P(\waaah2,start:'not', lag:(-0.30), music:{//{{{
		{
			Synths(\sawzz2,\out,1,\cutoff,1600,\freq,[(1-13),(6-13),1,3,5,7].degreescps(root:5,octave:4)).dur(5)
			.map(\cutoff,{
				var b = Bus.control(s);
				//{Env([0000,1400,600],[1,2,3]).kr(2,gate:1)=>Out.kr(b.index,_)}.play;
				{Env([0000,1400,600],[1,0,2]).kr(2,gate:1)=>Out.kr(b.index,_)}.play;
				b
			}.value);
		}.value
	};
);
["Doctor McCoy (boom) is ", "g#3 a f# g# f#2 g#3"].addLine; //3
Song.setTempoMap(\Doctor,"e x x e x x");
P.synthV(role: \kirk, take:\lead, params: {|p b| [
	lyrics: "doctor + mcCoy + r is",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\hat, music: { |p b e|
	[
		dur:0.25.dup(8).warpTo( e.tempoMap.quantize(0.5) ).q,
		amp: [2,1].q(inf)/40,
		instrument: \hihat,
		rel: 0.1
	].pp
});
P.double(role: \kirk, take:\lead, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
/*
//{{{ ~im parts
//Item(\testVoc2).arm;
//~im.voc2=Part(0,music:{{Item(\testVoc2).recIfArmed(s,0)}.value});
//~im.voc1slwww=Part(0,music:{{Item(\testVoc).recIfArmed(s,0,0.5)}.value});
~im.voc1=Part(0,music:{{Item(\testVoc).recIfArmed(s,1)}.value});
//~im.vocdelay=Part(0,1,music:{{Item(\testVoc).recIfArmed(s,2)}.value});
~im.voc2=Part(1,0,0,{{Item(\order).recIfArmed(s,1)}.value});
~im.voc3=Part(1,0,0,{{Item(\order2).recIfArmed(s,1)}.value});
~im.voc4=Part(1,0,0,{{Item(\order3).recIfArmed(s,2)}.value});
//~im.chords.play
*/

//~im2.chords.play
//}}}
//~im.cursor_(0).play;}}}
// version with alternate first line{{{

//~im2=Song((~im.key++2).asSymbol,~im.song).setupDurs;

//~im2.durs=~im.durs; // do this first time only!!
//}}}
//// 0 //// {{{
P(\drMcoyBass3,start:'Doctor',music:{|p b e| fork{
	var a=Synth(\pulseBass,[freq:40,gate:0,amp:0.1]);
	var b=p.durs[e.start].asStream;
	s.latency.wait;
	a.set(*[freq:[2].degreescps(root:6,octave:2),gate:1]).dur(0.4); b.nextN(2).sum.wait;
	a.set(*[freq:[1].degreescps(root:6,octave:2),gate:1]); b.next.wait;
	a.set(*[freq:[2].degreescps(root:6,octave:2)]).dur(0.3); b.next.wait;
	a.set(*[freq:[1].degreescps(root:6,octave:2),gate:1]).dur(0.2); (b.nextN(2).sum-0.1).wait;
	a.set(*[freq:[5].degreescps(root:6,octave:1),gate:1]).dur(2);
	//a.set(*[freq:[9].degreescps(root:6,octave:2)]).dur(0.3);
}});//}}}
//P(\keys3,start:'right',syl:1,music:{Synths(\sawzz2,\att,1.5,\freq,[1,3,5,8].degreescps(root:1,scale:\minor)).dur(3) });
["(boom) right in pointing out (boom) the e-nor--","c#3 c#4 d# c# c b-3 d#2 c4 a3 a-"].addLine; //4
P.synthVs(role: \kirk, take:[ \lead, \double ],
	pbind: Song.enlarge(11),
	params: {|p b| [
	lyrics: "r right in pointing + out r the enormous + - + danger - + potential + + in any +",
	pitchTake: [ 1, 3 ]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\guide4,start:'right',music:
	Pcollect({|i|(i.midinote>50).if{i}{Rest(i.dur)}},Song.pbind['right'])
);
P(\keysLow4,start:'right',syl:0,music:{ |p b e|
	Synth(\sawzz2,[\freq,[1].degreescps(octave:4,root:1,scale:\major)])
	.dur( b.parse([5],1).sum)
});
P(\bass4,start:'right',
	//		lag:-0.08,
	music:{|p b e| [octave:[3,4]!3++[3], note:[1,0,4,3].q, dur:b.parse([1,[1,1],[1,1,1],3]).q ].p });

	P(\lowBass4,start:'right',music:{ |p b e|
		var a = 
		a=Synths(\portBass,\attack,1,\release,5,\amp,0.02,\freq,[1,11].degreescps(octave:2,root:1)).dur(5);

		{\now.postln; a.set(\freq,[1,11].degreescps(octave:2))}
		.sched( p.durs['right'].list[0]+0.1)
	});
	P(\lowBass4answer,start:'right',syl:2,music:{ |p b e|
		var a = Synths(\portBass,\out,0,\attack,0.6,\release,5,\amp,0.01,\freq,[4,14].df(\b,octave:3)).dur(2);
		{a.set(\freq,[3,13].df(\b,octave:3))}.sched(b.parse([3],2)+0.2)
	});//}}}
	["-mous da-(__) -nger potential in any","f4 c# b3 f#4 d# a-3 b a# g# a# b"].addLine;//5
	P(\bass5,start:'-mous',music:(octave:[3,4]-1,note:5,dur:2));
	P(\bass5ii,start:'-mous',syl:2,music:(octave:[3,4],note:-3,dur:2));
	P(\bass5iii,start:'-mous',syl:5,music:(amp:0.2,octave:[3,4],note:-6,dur:2));

	//[\key,[\bass5,\bass5ii,\bass5iii],\start,5,\syl,[0,2,5],\music,[(octave:[3,4]-1,note:5,dur:2),(octave:[3,4],note:-3,dur:2),(amp:0.2,octave:[3,4],note:-6,dur:2) ]].flopEvents

	P(\guide5,start:'-mous',music:Pbindf(Song.pbind['-mous'],\ctranspose,12,\amp,[0.15,0.05].q(inf)));
	P(\chord5,start:'-mous',music:(strum:0.03,amp:0.1,degree:[0,2,7,9],octave:4,root:5,dur:1,scale:Scale.minor));
	P(\lowBass5,start:'-mous',music:(instrument:\sawzz2,amp:0.3,note:5,octave:[2,3]));
	//P(\lowBass4=(start:'right',music:{var a ,instrument:\sawzz2,amp:0.3,note:0,octave:[2,3])});
	P(\passing5,start:'-mous',music:{ |p b e| [instrument:\tri,out:1,octave:[5,4],note:[0,1,2,3].q,dur:b.parse([1,1,1,[1,1,1]]).q].pp });
	P(\passing5b ,start:'-mous',music:{ |p b e|
		[
			out:0,
			instrument:\tri,
			amp:0.2,
			octave:[5],
			note:[Rest(),1,-1,-3].q,
			dur:b.parse([1,1,1,[1,1,1]]).q
		].pp
	});
	P(\chord5II ,start:'-mous',syl:5,music:{|p b e| (out:0,instrument:\tri,note:[6,11,13],dur:1) });
	P(\chord5III ,start:'-mous',syl:2,music:(out:1,instrument:\tri,note:[3,6,9],dur:1));//}}}
	["(boom) (boom) con-- tact with ","c2 c2 c4 c4 d"].addLine;//6
	P.synthV(role: \kirk, take:\lead, params: {|p b| [
		lyrics: "r r contact + with",
		pitchTake: 2,
		pitchExpression: 1.3
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
	P.double(role: \kirk, params: {|p b| [
			
		] }, music:{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
			}.play
		});
	P(\bompbomp6,start:'con--',music: { |p b e| [
		amp:0.3,
		instrument:\pulseBBass2,
		note:[0,0,Rest(),2].q,amp:0.3,
		octave:3,
		dur:b.parse([1,1,[1,1/2],[1/2,1]]).q
	].pp }
);//}}}
P(\snares6,start:'con--',music: { |p b e|
	[
		instrument:\snare,
		dur:[p.durs['con--'].list.sum/4].q(4)
	].pp 
});
// drums6
P(\snares6,start:'con--',music: { |p b e| [instrument:[\snare,\snare,Rest(),Rest()].q,dur:b.parse([1,1,[1,1/2],[1/2,1]]).q].pp });
P(\contactBeep,start:'con--',music:{ |p b e|
	[
		octave:8,
		dur:
		b.parse([2/3,2/3,1/4,1/2])
		.q
	].pp
});
//P(\hat6,start:'con--',music: [instrument:\hihat,pan:0.5,dur:~im2.durs[6].list[0..1].sum/4,degree:Pseq([0],8)].p);
P(\slide6,start:'con--',syl:2,lag:0.2,music:{ |p b e|
	[
		amp:0.02,
		root:4,
		degree:Pseries(30,-1,38),
		dur:Pwhite(0.01,0.012)*1.85,
		instrument:\mda,
		vel:60
	].pp
});
P(\slide6echo,start:'con--',syl:2,lag:0.55,music:{ |p b e| [amp:0.005,root:4,degree:Pseries(30,-1,38),dur:Pwhite(0.01,0.012)*1.85,instrument:\mda,vel:60].pp });//}}}
///// 7 /////{{{
["life and intelligence so fan-","g4 d g f# e d e f#"].addLine;//7
P.synthV(\ninezero, take:\harmony,
	filter: (midinote: [3, 3, 3, 2, 2,2].dm(\g)), 
	params: {|p b| [
	lyrics: "life and intelligence + + + r r",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		/2
		=> Pan2.ar(_,0.8)
	}.play
});
P.double(\ninezero, take: \harmony, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0.8)
		}.play
	});
P.synthV(role: \kirk, take:\lead, params: {|p b| [
	lyrics: "life and intelligence + + + so fan",
	pitchTake: 1,
	pitchExpression: 1.25
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \kirk, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
P(\crash7,start:\life,music:(instrument:\cymbalsDS,dur:5,amp:0.02));
P(\keys7,start:\life ,music: { |p b e|
	[
		freq:[[3,11],5,[3,11],[2,7],5,[2,7]].degreescps(root:7).q,
		dur: b.parse([1,1,1,[1,1],[1,1/2],[1/2,1]]).q
	].pp
});
P(\bass7,start:\life,music: { |p b e|
	[
		instrument:\pulseBBass2,
		amp:0.3,
		degree:[1,1,5,5].q-1,
		octave:[3,4],
		root:7,
		dur:b.parse([[1,1],1,[1,1,1,1/2],[1/2,1]]).q
	].pp
});
["(trill) --tas --tic --ly ad-- va -- --nced as","e3 g#4 f# e d b- c5 b-4 a "].addLine;//8
P.synthV(role:\kirk, take:\lead, params: {|p b| [
	lyrics: " r tasticly + + advanced + - - as",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role:\kirk, take:\lead, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
P(\klTrill,start:\trill,music:{{StkClarinet.ar(441/480*[1,3].degreescps(root:4,octave:5)*Pulse.kr(LFBrownNoise2.kr([0.5,0.51],mul:0.5,add:6)).range(1,2.midiratio),breathpressure:20,vibgain:10,vibfreq:64)*0.04}.play(s,2).dur(1) });
//~im2.pbind[7].play;
P(\bass8,start:'(trill)',music:{ |p b e| [note:[Rest(),8,6,4,2,0,-1].q,octave:3,dur: b.parse([1,1,1,1,1,[1,1,1,1]]).q++[2].q ].pp });

P(\lick8,start:'(trill)',syl:4,music: { |p b e|
	[
		out:3,
		freq:
		([0,10]+.x[6,5,3,2,1])

		.degreescps(root:3,octave:4).q,dur:
		p.parse(e.start,[1,1,1,1],5).q++([1].q)

	].pp
});
["this, but I must point out that the possi","b-4 a g# a b d f# g# a b"].addLine;//9
P.still(\kirkDocile, timecode: 
	// 2400.seconds
	//2417.seconds //james brown
	2413.4.seconds// smiling

	, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.synthV(role:\kirk, take:\lead, params: {|p b| [
	lyrics: "this but I must point out that the posee +",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role:\kirk, take: \lead, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
P(\chord9,start:'this,',music:(strum:0.07,freq:[2,4,5,7].degreescps(root:4)));
P(\chord9,start:'this,',music:(dur: 2,strum:0.05,freq:[5,12,14,17,23].degreescps(root:-1)));
P(\chord9b,start:'this,',syl:0,music:(strum:0.07,freq:[3,5,6.5,10].degreescps(root:-1)));
P(\bass9,start:'this,',music:(note:6,octave:[2]+1,amp:0.1,dur:4));
//P(\bass9b,start:'this,',syl:0,music:(note:-1,octave:[3,2]+1,amp:0.2,dur:4));
P(\bass9c,start:'this,',syl:4,music:(note:4,octave:[3,2],amp:0.2,dur:4));

P(\tritones9, start:'this,', music:{ |p b e|
	[ instrument:\stringyy, note:( [-2,-3,-4]+.t[0,6] ).q , dur: b.parse([1,1!4,1]).q].pp 
});

P(\bend9,start:'this,',music: {| p b e| 
	{
		var env= Env.new([2.5,2.5,2,2,1.5,1.5].degreescps(octave:7),[1.5,1,5.5,2.5,3]).kr(gate:1);
		Saw.ar(env*[1,2],0.1)=>FreeVerb.ar(_,1,0.9)*0.2 
		* Env.linen(4,1,5).kr(2,gate:1)
	}.play}
);

//P(\voiceleading9, start:'this,', music: (//{{{
//		[
//			[
//				octave:[4,5],
//				amp:0.1,
//				dur: b.parse([1,1!4,1]).q,
//				instrument:\stringyy,note:[4,3,2].q
//			].p
//			,
//			[
//				amp:0.2,dur:b.parse([1,1!4,1]).q,out:2,instrument:\stringyy,note:1+[13].q
//			].p
//		]=>Ppar(_)
//	)); //}}}

//}}}
//// 10 ////{{{
["-bilities,the potential, for knowledge and ad-","c#5 a4 e a c#5 d b4 d5 d b4 e5 d"].addLine;//10/
P.synthV(role:\kirk, take:\lead, prepend:true, params: {|p b| [
	lyrics: "bilities + +  the potential + + for knowledge + and ad",
	pitchExpression: 0.5
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role:\kirk, take:\lead, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
P(\bass10,start:'-bilities,the',music:{ |p b e|
	(
		note:-3,
		octave:[3,2],
		amp:0.2,
		dur:b.parse([1!9])
	).play
});

P(\bass10b,start:'-bilities,the',syl:7,music: { |p b e|
	[
		note:[ -4,-7,-6,-8,  // -8+12 
		].q,
		legato:(0.96!3 ++ 1).q,
		octave:4,amp:0.2,
		dur: ( 
			b.parse([1!3,1],8)++ p.parse(e.start+1, [1!6 ,1!5]) 
		) .q 
].pp 
});
P(\pad10,start:'-bilities,the',music:(instrument:\stringyy,freq:[1,5,13].degreescps(root:-3,octave:3),dur:2));

P(\pad10b,start:'-bilities,the',syl:4,music:( instrument:\stringyy,freq:[5,11,13].degreescps(scale:\minor,root:-1,octave:3),dur:2 ));

P(\figure10,start:'-bilities,the',syl:4,music: { |p b e|
	[instrument:\tri,pan:1,freq:[14,12,6,12,14].degreescps(root:-3).q,dur:p.parse('bilities',[1,0.33!3,1].flatten,5).q].pp
});
["vancement is equally great... ","c#5 b4 g# a c#5 d e g f# e d "].addLine;//11
P.synthV(role:\kirk,take: \lead, take:\lead, params: {|p b| [
	lyrics: "vancement + is equally + + great - - - -",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role:\kirk,take: \lead, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});

P(\bass11,start:'vancement', syl:7, lag: Song.parse('vancement',[0.5],8)[0] + 0.05, music:{|p b e|
	(dur:2,octave:4,out:1,note:4).play;(dur:2,octave:5,out:1,note:4,instrument:\stringyy).play
});
[" (rest) risk, risk is our business (ba -- by)","c3 c5 c c c c# g#4 f# e"].addLine; //12
P.still(\kirkRisk,syl:0, timecode: 2404.1.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.synthV(role:\kirk,take:\lead,
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: "r risk risk is our business  + baby +",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role:\kirk,take:\lead, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});

//~im2.guide12=( start:\risk, syl:0, music:~im2.guide12.music=>Pdrop(1,_));
// TODO make this 
/*
Song.section( \boom)
Song.durs
Song.section[\boom]
*/
P(\bass12, start:\risk,syl:0,music: { |p b e| [
	freq:
	(
		[3,3,2,2,1] 
		.degreescps(root:4,octave:4)
		*.t [0.5,1,2]
	) .q,
	dur:
	b.parse([3/4,1/4, [1,1,1/3],2/3 ,1],1)
	.q 
].pp });
P.synthVs(\mo, take: [ \bg1, \bg2 ], params: {|p b| [
	filter: [ (midinote: 1.dm('a-')), (midinote: -5.dm('a-')) ], 
	lyrics: "r risk risk is our business + r r",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\cords12, start:\risk,syl:0,music: { |p b e| [
	// freq:[1,2] *.x [13,13,13,13,14,11,6.5,5.5].degreescps(root:-4,octave:5).q
	freq:([5,11].degreescps(root:-4)!5).q,
	dur:p.parse(e.start,1!5,1).q
].pp } ); 
~justTheTune.('risk',_.drop(1),syl:0);
P(\cymbal12,start:\risk,syl:0,music:(instrument:\cymbalsDS,att:0,amp:0.01));
//}}}


[" (boom) thats what a starship is all a-" , "g3 f4 g a d5 c b4 c5 d "].addLine;//13
P.synthVs(role: \kirk, take: [ \lead, \double ],
	pbind: Song.enlarge(8),
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: "r thats what a starship + is all about + that's r why we're aboard + her",
	pitchTake: [ 1, 3 ]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\bass13, start:'starship', music:(degree:4, octave: [2, 3 ], instrument:\stringyy, dur: Song.secDur['starship']) );
["bout,that`s (boom) why we`re a- board her","f#4 g5 f4 f5 e d  c b4"].addLine; //14
P.synthV(role: \kirk, take:\lead,
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: "bout that's r why we're aboard + her",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \kirk, take: \lead, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
P(\bass14, start:'bout,that`s', music:{ |p b e| [degree:[ Rest(),3,4 ].q, octave: [2, 3 ], instrument:\stringyy, dur: b.parse([ 1!2, 1!4, 1!2 ]).q].pp } );
["(boom) you can diss-- e-- -- --nt without","c3 b-3 c4 d e f e d e "].addLine; //15
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "r you can dissent + - - without +",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \kirk, take: \lead, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
P(\bass15, start:'diss', music:(degree:0, octave: [4, 3 ], instrument:\stringyy, dur: Song.secDur['starship']) );

["prejudice (boom) do I","d4 c a3 a2 a3 b"].addLine; //16
Song.preroll_(1);
P.synthV(role:\kirk, take: \lead,
	prepend: true,
	params: {|p b| [
	lyrics: "role: \kirkprejudice + + r do I",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role:\kirk, take: \lead,
	prepend: true,
	params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
// P.tune(\prejudice);

P(\bass16,start:'prejudice',syl:2,music:{ | p b e | 
	[ 
		octave: [3,4],
		degree: 5,
		instrument: \stringyy,
		dur: p.parse(e.start,[[ 1,1,1 ]],3) + Song.secDur[\negative] => _.unbubble => _.q(1)  
	].pp ;
	(
		instrument: \harp,
		coef:0.5,
		freq: [-11].df(\a,tuning: \sept),
		amp:0.02
	).play
});

SynthDef(\keychord,{
	Pulse.ar(\freq.kr(400))
	* Env.cutoff(2.5).kr(2,gate:\gate.kr(1))
	* 0.015
	=>Out.ar(\out.kr(1),_)
}).add;

["hear a negative voice?","c#4 d b3 g e e4"].addLine; //17
P.synthV(role: \kirk,
	prepend: true,
	take: \lead, params: {|p b| [
	lyrics: "hear a negative + + voice",
	legato: [1, 1, 1, 1, 1, 0.8, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \kirk,take: \lead, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
P.tune(\hear);

["engineer stand by to be aboard three receptacles","d4 c# d d5 c# g4 f# e g f# e c# d"].addLine; //18
P.synthV(role: \kirk, take:\lead, params: {|p b| [
	lyrics: "engineer + + stand by to beam up three receptacles + + +",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
// P.double(role: \kirk, params: {|p b| [
// 		
// 	] }, music:{|p b e|
// 		{
// 			e.playbuf
// 			=> p.synthVTracks.at(e.key).()
// 		}.play
// 	});
P(\cords18,start:'engineer',syl:9,music:{ |p b e| [
	instrument: \keychord,
	dur: ( p.parse(e.start,[[1,1],1],10) + [0,1]).q,
	rel: [1,2].q,
	freq: [[1,3,5],[1,4,6]].degreescps(root:-3).q
].pp });

P(\bendybase18,start:'engineer',syl:9,music:{ |p b e|
	(
		instrument:\bendbase,
		octave: 3,
		note:  -3 ,
		dur: p.parse(e.start,[[1,1],1],10).q
	).play
});//}}}
SynthDef(\bendbase,{ //{{{
	var dur = Song.parse(\engineer,[[1,1],1],10);
	var env = Env.new([1,1,2].degreescps(root:-3,octave:3),Song.parse(\engineer,[[1,1],1],10));
	Saw.ar(EnvGen.ar(env)+[0,0.5],\amp.kr(0.1))
	=>MoogFF.ar(_,\cutoff.kr(4000,2))
	* Env.linen(dur[0],dur[1],3,curve:\sin) .kr(doneAction:0)
	=>TwoTube.ar(_,0.05,0.85,1400,600)
	=>Out.ar(\out.kr(0),_)
	* Env.linen(dur[0],dur[1],3+13,curve:\sin) .kr(doneAction:2)
}).add; //}}}
// P.tune(\engineer);
P(\baas18,start:'engineer',music:{ |p b e| 
	var pat = [
		octave: [2,3],
		dur: b.parse([[1,1,0.5],[0.5,1,1,1,1,1,1,1],[1,1],1]).q,
		note: [Rest(),2,-3,-1].q
	].p;
	[\stringyy,\basepluck].do({|i| pat <> [instrument: i].p => _.play})

});//}}}

//(instrument:\basepluck,note:0,octave:3).play;
SynthDef(\basepluck,{
	Pulse.ar(\freq.kr(400),\width.kr(0.2))
	* Env.perc(0,2.5,\amp.kr(0.1),curve:3).kr(2)
	=>MoogFF.ar(_,4000,2)
	=>Pan2.ar(_,0)
	=>Out.ar(\out.ir(0),_)
}).add;


P(\run18,start:'engineer',music:{ |p b e|
	[
		instrument: \stringyy,
		freq: [Rest()].q++[ 11,7,6,5,4,3,2,4,3 ].degreescps(root:2,octave:4) .q,
		dur: b.parse([[1,1,1],1,1/3,1/3,1/3,1,1,1]) .q,
		pan: -1
	].pp });

	"vocals with Xuan as Kirk nice - there are also some with Kevin".postln

)
