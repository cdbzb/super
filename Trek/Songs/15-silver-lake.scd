// NOTE about Cepstral Vocoders!!!
// ~vocoderPattern uses SynthDef \busVersion
// ~vocoderPattern is in Library/functions

// [Laboratory]

(
s.waitForBoot{
	Song(\silverLake,[]).current;
//Song.currentSong.infrastructure={
//FunctionList.new.array_([
//	~synthsLoaded.isNil.if{"/Users/michael/tank/super/song-Synthdefs.scd".load},
//]).value
//}.inEnvir;

[ "Sargon and Thalassa are working...","r",[6]].addLine;
Require("./boilerplate.scd");
P.still(\hands, timecode: 3309.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
[1,3,5,1,4,6,5,4].df(\g).q(2)=>[dur:0.5,freq:_,legato:1]=>_.p => _.fin(13) => {|i| P(\lick,start:\working,music:{|p b e| i.play})};
P(\bass, music: { |p b e|
	var verb = Effect.bus({|i| FreeVerb.ar(i,1,1)  },inputChannels:2);
	var clean = Effect.bus({|i| SineShaper.ar(i,0.2) },);
	[
		freq: [1, 1, 4, 5].df(\g,[3,4]).q(2),
		dur:  [3,1] / 2 => _.dup(3) ++ 1.5 => _.flat =>_.q ,
		out: [ clean,clean,clean,clean,clean,clean,verb ].q
	].pp
});
[ "when their hands touch.","r",4 ].addLine; 
P.still(\touch, timecode: 3310.13.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.tune(\touch);
P(\arpeggio,\touch,music: {
	[7,6,4.5,3,2,1] => {|i| [i,(-1)*i]} => _.flat => {|i| 
		[ 
			freq:i.df(\d,scale:\dorian,octave:6).q,
			dur:1/2/3,
			legato:3.05,
			out:Effect({ |i| 
				EchoNone.ar(i,0.5,{0.5.rand}!4,18)
				=>FreeVerb.ar(_,0.9,0.9) 
				=>Resonator.ar(_,SinOsc.ar(0.01).range(1400,1000),damping:0.2) 
				* 0.3
			},inputChannels:4,out:[0,1,2,3]).bus.index
		].pp;
		(
			instrument:\stringyy,
			freq:[1,3,4.5,7].df(\d,scale:\dorian),
			dur:6
		).play
	}
});
//~chordIdea = [ [-1,3,4.5,7], [-3.5,2,5,7] ].df(\d,scale:\minor).q => {|i| [freq:i,legato:1,dur:2.5].p};
["/*MULHALL:*/ Sargon, I remember a day long a- ",[2,1, 3,2,-6,1,-7,-7,-6,-5].dm(\d,scale:\dorian,octave:6)].addLine;
P.still(\twoShot, timecode: 
	// 3319 //looks like smiling
	3320.2
	.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["Sargon",""],
		fade: e.bNext[0]
	).sequenceText2(
			b.parse([2]), [ 
			["I remember a day","long ago"],
			],
	)
});
Song.synthVTracks=EventWithDefault();
Song.synthVTracks.aiko = { |preGain=1 ratio=2 amp = (1/8) len=2000 mix=( 0.1 /2 )  |
	{ |i|
		i.() * preGain
		=> SoftKneeCompressor.rms(_,  thresh:-10, ratio: ratio, knee:6, attack:0, release:0.05, makeUp:0, rms:40) 
		* amp
		=> DWGReverbC1C3.ar(_,len:len,mix:mix)
		=>.first DetectSilence.ar(_,doneAction:2)
	}
};
Song.synthVTracks.default = Song.synthVTracks.aiko;
P.synthV(\aiko, 
	pbind: Song.enlarge(1),
 	params:{|p b| [
	lyrics: "sar gon ai re mem ber a dai long a go" ,
	legato:[1,  0.5, 1, 1, 1,  1,  1,  1,  1, 1, 2] ,
	lag:[0.15,0,0,0,0,0,0,0,0,0,0],
	phonemes: ["","","","","m e m","","","","","@","k o"],
	tension: Env([-0.4,-0.4],[2])

] },music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\bassnote,start:'long a',music: { |p b e|
	b.postln;
	b.sum.postln;
	(
		instrument:\sawSynthSustain,
		freq:[11,21].df(\d,octave:3),
		att:9,
		dur:3,
		rel: b.sum
	).play
});
Song.stringyyTuneLow = {|start| P.tune(start,  Pbindf(_,\instrument,\stringyy,\freq,Pfunc({|e| e.midinote-12=>_.midicps})))};
Song.stringyyTuneLow.('long a');
["go. (ta da da boom da) We ", [3, 5,5,5,-4,4].dm(\e)++[3].dm(\a)].addLine;
P.still(\clear,syl:5, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum + e.bNext.sum + p.durs[e.start+2].list[0],
		text: ["",""],
		fade: p.durs[e.start + 2].list[1..2].sum
	)
});
P.still(\clear,syl:5,lag:0.1, timecode: 0.seconds, music: { |p b e|
	 e.still.(
		wait: b.sum + e.bNext.sum + p.durs[e.start + 2][0],
		text: ["we sat","beside a"]
	).sequenceText2(
			b.drop(1).parse([7]), [ 
			["silver","lake"],
			],
	)
}
);
P.synthV(\aiko, 
	pbind: Song.enlarge2(1),
	params:[ lyrics: "r r r r r r wi sat bi sa id  a si i il ver lek" ,
		phonemes: ["", "", "", "", "", "", "w i", "s a th", "p i\\", "s a ", ":\\i t", "a ", "s i\\", "i\\", "l", "w a \\r`", "l e :\\i kh"],
		legato: [1,    1,  1,  1,  1,  1,  1,  1,  1,  1,      1,     1,    1,     1,   1,     1,                2],
		paramTension: -0.4
	],music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	}
);
P.tune('go.', {|i| Pbindf(i,\amp,[0.1,\r,\r,\r,\r,\r,0.1].q,\legato,[5,1,1,1,1,1,1].q,\instrument,\stringyy,\freq,Pfunc({|e| e.midinote -12 => _.midicps}))});
P(\bass,start:'go.',music:{|p b e|
	[
		freq:[ [1,11], [4,14] ].df(\e,4).q,
		dur:b.parse([4,3]).q,
		legato:[0.5,1] * 0.9 => _.q,
		instrument:\foo,
		amp:0.05
	].pp
});
P(\chords,'go.',syl:0,music: {|p b e|
	[
		freq:
		[3,5].df(\e)!3++\r++[[1,3].df(\a)]
		=>_.q
		,
		instrument:\sparkTriangle,
		legato:0.1,
		dur:b[1..6].q
	].pp
});
["sat beside a si -- lve --r ",[1,-7,-6,-7,-5,3,4,1,3].dm(\d,octave:6)].addLine;
// P.still(\lookingOut,syl:1, timecode: 3322.seconds, music: { |p b e|
// 	 e.still.( 
// 		wait: b.sum,
// 		fadeIn:b[..5].sum,
// 		text: ["",""],
// 	)
// });
// P.synthV(\aiko,
// 	params:{|p b| [
// 		lyrics:"sat bi sa id  a si i il ver" ,
// 		phonemes:["","","s a ","i t","a ","s i","i","j l","v e \r`"],
//
// 		tension:Env([-0.4,-0.4,-0.4],[b.sum]),
// 	] },music:{|p b e|
// 		{
// 			e.playbuf
// 			=> p.synthVTracks.at(e.key).()
// 		}.play
// 	}
// );
SynthDef(\foo,{ |freq|
	var b = Song.durs[\sat].list;
	[
	Pulse.ar(freq,0.4,0.08) ,

		Gendy2.ar(minfreq:freq*0.995,maxfreq:1.005*freq) * 0.03
	]

	//* Env.asr(1,1,8).kr(2,gate:\gate.kr(1))
	* 6
	* \amp.kr(0.1)
	* Env([0.1, 1, 0.5, 0.7, 0],b.parse([0.1,0.9,[ 4,1 ],4,1] )).kr(2,gate:\gate.kr(1))
	=> RLPF.ar(_, XLine.kr(1000,8000,b.sum), 1/2)
	=> Out.ar(0,_)
}).add;
P(\bass,start:'sat',lag:-0.05,music:{|p b e|
	[
		freq: [\r, [3,13].df(\e,4),[1,11 ].df(\g,4)].q /2,
		dur:b.parse([ 2/3, [1/3,4 ], 4]).q,
	].pm(\foo).play;
});
Song.stringyyTuneLow.(\sat);
["lake. (boom boom) The air (boom boom) was scented with the ",[11,-7,2,3,6].dm('f#',scale:\mixolydian)++[-7,2,3,5,4,3,4].dm(\g,scale:\mixolydian)].addLine;
/*
P.still(\closeUp, syl:2, timecode: 3326.6.seconds, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum,
		text: ["the air","was scented with the"],
		fade: e.bNext.sum
	).sequenceText2(
			b.drop(1).sum.bubble, [ 
			["",""],
			],
	)
}); */
P.still(\clear,syl:2, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum,
		text: ["the air","was scented with the"],
		// fade: b.drop(1)[0]
	)
});
P.synthV(\aiko,
	pbind: Song.enlarge(6),
	params:{|p b|
		[
	lyrics:"r r r the eir r r was sen ted with the fla werz af ar pla net" ,
	tension:Env([-0.4,-0.4,-0.4],[b.sum]),
	// phonemes:["","","","t @","e r\\`","","","w A ts","s e n th","i\\ t","w i\\ s","t @"],
	phonemes:["","","","","e \\i r\\`","","","w A ts","s e n th","i\\ t","w i\\ s","t @","f l AU","a r \\` ts","a w","AU a r\\`","ph l a","n e th th "],
	legato:[1,1,1,1,2.5, 1,1,1,1,1,1,1]
	++ ([20,18,19,20,20,20]/20),
	voicing: Env([0.4,0.7,1,0.5,1],[ b.sum ] ++ p.durs[p.section(\scented)+1].list.parse([2,1,2,1]) => _.flat),
	loudness: Env(
		// [-1,1,1,0,1,0] + [3,3,3,2,2,1] 
		[0, 6,1,2,2,3,2]
		++ [1,2,1,0,1,0] => _.flat,
		b.parse([3,2,3,1,1,1,1,1]) ++ p.durs[p.section(\scented)+1].list => _.flat
	),
] },music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	}
);
P(\bass,start:\lake,music:{|p b e|
	(freq:[3,13].df(\d,octave:3),dur:b[0..3].sum).play
});
P.tune('scented',{|e| Pbindf(e,\legato,2,\instrument,\stringyy,\amp,0.2,\release,3,\attack,0.05,\freq,Pfunc({|e| e.midinote.midicps/2}))});
P.tune('scented ',{|e| Pbindf(e,\legato,2,\amp,0.05,\release,3,\attack,0.05,\freq,Pfunc({|e| e.midinote.midicps/[1, 2 ]}))});

P('phrase',start:\lake,syl:0,music: {|p b e|
	var amp = 0.06;
	[
		freq:[ -7,2,3,6 ].df('f#',\mixolydian).q,
		instrument:\wash,
		dur:b.drop(1).q,
		out: Effect(_ * [0.01,1]).bus.index,
		amp: amp
	].pp;
	[
		freq:[\r,\r,\r,\r, -7,2,3,5 ].df('g',\mixolydian).q,
		instrument:\wash,
		dur:b.drop(1).q,
		out: Effect(_ * [1,0.01]).bus.index,
		amp: amp
	].pp;
});
["flowers of our planet. ",[1,-7,1].dm(\g,scale:\mixolydian)++[6,5,4,3,6,5,4,3].dm(\d)+12].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["flowers","of"],
	).sequenceText2(
			b.parse([3,4]), [ 
			["our","planet"],
			["",""]
			],
	)
});
Song.durs[\flowers].list.do(_.postln);

P(\planet,start:\flowers,syl:2,music: { |p b e |
	~quarters = b.drop(1).asArray++[1,1];~quarters=~quarters.parseBeats([1,3,1,3,1,3,1,1,2]/2);
	~vars = (); ~pbinds = ();
	~vars.bass = [6,5,4,11].dup.flat;
	~vars.inner = [6,5,-6,1, 4,3,-5,-7, 6,5,-6,3, 4, 3,-5,1/*3*/].reject({|i x| x % 4 == 0 or: (x % 4 == 1)}).clump(2);
	~vars.arp = [\r] 
	++ [ ~vars.bass.df(\d,octave:3) , ~vars.inner.df(\d,octave:5)].flop.flat; 
	~pbinds.arpLow=[
		freq:~vars.arp.q,
		dur: [1].q ++ [1,1,2].q(4) / 2,
		//amp: [\r].q++[\r,1,2].q(4) /10,
		//amp:0.2,
		out:1,
		instrument:\sparkTriangle,
		//amp:0.01
	].p;
	~pbinds.tune=[6,5, 4,3].dup.flat=>_.df(\d)=>{|i| 
		[
			dur:[1,3].q(4)/2,
			freq:i.q,
			instrument:\sawSynthSustain
		].p
	};
	~pbinds.rh = [6,5,-6,1, 4,3,-5,-7, 6,5,-6,3, 4, 3,-5,1/*3*/].df(\d)
	=>{|i| [dur:0.5,freq:i.q].p};
	~pbinds.bass = [
		dur:[1].q++[4].q(inf) / 2,
		freq:[\r,6,5,4,11].df(\d,octave:[2,3]).q,
		instrument:\stringyy,amp:0.5
	].p;
	//TODO PUT in a Ppar and clock to durs
	~pbinds.asKeyValuePairs.select{|i x| x.odd} 
	=> Ppar(_) 
	=> _.play(~quarters.asTempoClock);
	'b '.post;b.postln
});
P.synthV( role: \desc,
	pbind: {|p b|
		[
			midinote: [0] ++ ~vars.inner.flat.dm(\d,6) ,
			dur: b.parse([[1,1,1,1,1/3],
			1/3,[1/3,1,1/3],
			1/3,[1/3,1,1/3],
			1/3,[1/3,1,1/3],
		])
		
		].p
	},
	take:\lead, params: {|p b| [
		lyrics: "r  aaa - - - - - - - ",
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			* Env([0,0,1],b.parse([[1,1,1,1,1/3],2/3])).kr(0,gate:1) 
			// *3
			=> SineShaper.ar(_ ,0.2)
			=> p.synthVTracks.at(e.key).()
			*2
		}.play
	});
P.synthV(role: \thalassa,take:\lead,params: {|p b| [
	lyrics: "fla werz af ar pla net r r r r r",
	phonemes:["","","","a z`","ph l a","n e t","","","","",""],
	legato: [19,18,19,20,20,20]/20,
	lag: [0] ++ Array.fill(10,rrand(-0.07,0.07)),
	//tension: Env([0,0,0,0,1,1],b),
	loudness: Env([1,2,1,0,1,0],b)
] },music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			//=> Pan2.ar(_,1)
			* [0,1]
			*0.2
		}//.play

	}
);
P.tune(\flowers,Pbindf(_,\instrument,\stringyy,\amp,0.2,\freq,Pfunc({|e| e.midinote.midicps/2})));
Song.quarters[\planet]= Song.parseBeats(\planet,[1.5,1.5,0.5,0.5,1.5,0.5,1.5,0.5,1.5,0.5,1.5]);
//Song.quarters[\planet]

P(\arpeggio,start: \flowers,music:{|p b e|
	[1,2,3,5,7,11,7].dm('a-')
	=> {|i| [
		instrument:\sparkTriangle,
		amp:0.014,
		midinote:i.q,
		ctranspose:[0,-12],
		dur:1/2,
		out:Effect.bus(_ * Env([1,1,0],[1,4]).kr(2,gate:1)),
		legato:2.1
	].p
	.play(clock:Song.quarters[\planet].asTempoClock)
}});
//Song.quarters[\planet]
P(\ride,\flowers, //syl:3, 
	music:{|p b e|
		[
			//instrument:\claves_808,
			instrument:\openhihat_808,
			dur: Rest(1)!4++{  1!7  }.value => _.q,
			out:Effect(EchoNone.ar(_,0.2,0.1,6),out:3).bus.index
		].p.play(clock: Song.quarters[\planet] .asTempoClock)
	});
P.tune(\flowers,Pbindf(_,\instrument,\stringyy,\freq,Pfunc({|e| e.midinote.midicps/2})));
P(\bass,start:\flowers,music:{|p b e|
		var effect=Effect(DWGReverbC1C3.ar(_,len:2000,c1:1,c3:10,mix:1),inputChannels:2);
		(freq:[1,-1].df('a-',octave:[3,4]),rel:5,dur:2,out:effect.bus.index).play
	});
P(\chord,start:\flowers,music:{|p b e|
		(
			freq:[1,3,5,7].df('a-'),
			strum:0.05,
			out: Effect.bus( _ => EchoNone.ar(_,0.5,0.43,6) * [0.1,1] /2 )
		).play
	});

	["/*KIRK:*/ I remember. You held my han-- -- -- -- -- -- -- -- -- -- -- -- -- d like ",[4,3,3,2].dm(\c)++[-4,-5,-6,-7,1,-7,-6,-7,1,2,3,2,1,2,3, 4,5].dm(\g)].addLine;
P.still(\close, timecode: 3327.5.seconds, music: { |p b e|
		 e.still.( 
			wait: b.parse([5]).unbubble,
			fade: b[5..21].sum +1,
			text: ["I","remember"],
		).sequenceText2(
				b.parse([5,12]), [ 
				["you held","my hand"],
				["",""]
				],
		)
	});
P.still(\clear, timecode: 0.seconds,syl:19, music: { |p b e|
		 e.still.( 
			wait: b.drop(1).sum + e.bNext.sum,
			text: ["like","this"],
		)
});
P.synthV(role: \sargon,
	params:{|p b| [
		lyrics: "ai re mem ba yu held mai ha - - - - - - - - - - - and laik " ,
		legato: [1, 1, 1, 0.75, 1, 1,1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.9, 1, ],
		phonemes: ["","r i","m e m","b a","","","","","","","","","","","","","","","",],
		// tension: Env([0.4,0.4],2),
		paramTension:-0.1,
		// paramVoicing: 0
	] },filter:{|e|
		e.midinote = e.midinote - 
		//(0!4 ++ 12.dup(e.midinote.size-4))
		(0!e.midinote.size => _.dropLast() ++ 
		12
		//7
	)
},music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		* 4.5.dbamp
	}.play
}
	);
P.tune('I remember.',  { |i| Pmul(\freq,0.5,i) <> (instrument:\twang,amp:0.05)});
P('tune',start:\held,music: {|p b e|
		[
			midinote: Song.tune[Song.section(\held)].list 
			=> {|i| i ++ i.last} 
			//+.t [0,-12] 
			=> _.q,
			dur: b ++ b.last => _.q ,
			instrument: \harp,
			amp: 0.015

		].pp
	});
	//P.tune('I remember.',{|i| Pmul(\freq,0.5,i) });
P(\bass,'I remember.',music: {|p b e|
		[
			freq:[[4,14],[3,13], [15, 5 ] ,-5].df(\c,octave:3).q,
			instrument:\sawSynth,
			rel:2.5,
			dur:b.q,
			legato:1,
			amp:[1,1,1,2].q/10

		].pp
	});
P(\chords,'I remember.',music: {|p b e|
		[
			freq:[ [6,11], [5,11], [5,7]].df(\c).q,
			instrument:\sparkTriangle,
			dur: b.parse([1,1,2]).q,
			amp:0.05
		].pp
	});
P(\doubling,'I remember.',syl:12,music: {|p b e|
		[
			freq:[7,11,7,6,7,11,12,13].df(\g,octave:4).q,
			dur:b.q,
			instrument: 
			// \ooh//
			\visual_aaa
			//visual_vowel
			,
			amp: 0.2,
			out: 3
		].ppm
	});
	P.synthV(\an, take: \lead, 
		pbind: Song.enlarge(1),
		filter: (midinote: [0,0,0,0,0,0,0,0,0,0,0,0,0,7,11,7,6,7,11,12,13,12.5].dm(\g,octave:4)), 
		params: {|p b| [
		lyrics: "r r r r r r r r r r r r r ah - - - - - - like this ",
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> {|i| CombN.ar(i,0.3,0.25) / 3 + i}
			=> { |i| Out.ar(2, i /8)}
			// => p.synthVTracks.at(e.key).()
		}.play
	});
	["this.  (He kisses it, as Spock comes in.) ",[5,4,4,3,3 ].dm(\c,octave:6)].addLine;
P.still(\kissHand, timecode: 3335.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["like","this"],
		)
	});
P.synthV(\genbu, params: {|p b| [
		lyrics: "this r r r r" ,
	] },
	filter:{|e| e.midinote = e.midinote -12},
	music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
P.tune(\this);
P.tune('this', 
		{ |i| Pmul(\freq,[1],i) <> [
			instrument:\sawSynthSustain,
			lagTime:0.01,
			amp:0.04,
			att: [1,0,0.1,0,0.1].q,
			legato: [1,0.5,1,0.3,1].q
		].pma(\sawSynthSustain)
	}

);
P(\chords,start:'kisses',music: {|p b e|
	b.postln;
	a = VoiceLeading([
		[3,\_,2 ,\_,\_,],
		//[1,\_,-7,\_,\_,]
		[1,\_,-7.5,\_,-7,]
	],b.asArray
	).df('b-',scale:\mixolydian,octave:5)
	.pbinds.do {|i| i <> [
		instrument:\trem2,
		scale:1,
		legato:1,
		rel:3,
		amp:0.05

	].pm(\trem2) => _.play } 
});
P(\door,syl:2, music: { |p b e|
	
	Synth(\door, [\amp, 0.1]);
});

P.still(\henochEnters,syl:3, timecode: 3335.26.seconds, music: { |p b e|
	 e.still.( 

		 fadeIn:b.drop(1)[0],
		 wait: b.drop(1).sum,
		 text: ["",""],
		 fade: 1
	);
	{
		Dust.ar(40)
		=> FreeVerb.ar(_,0.8,1)
		=> Convolution.ar( Gendy1.arWidth(freq: (100..105)), _ )
		* Env([0, 1, 0],[1,b.drop(1)] ).kr()
		/15
	}.play
});
["I think it is best not to remember so well. (boom) ",[3,2,3,1,-5,2,1,-7,-6,-7,-5,-2.5,-4.5].dm(\d)].addLine;
P.still(\disappointedSargon, timecode: 3342.3.seconds, music: { |p b e|
	 e.still.( 
		 fadeIn:0.5,
		wait: b.sum,
		text: ["I think ","it is best"],
	).sequenceText2(
			b.parse([5]), [ 
			["not to remember","so well"],
			],
	);
	// static

});
P.synthV(\genbu, params: {|p b| [
	lyrics: "ai think it is best not to re mem ba so well r" ,
	legato: [1, 1, 1, 1, 0.8, 1, 1, 1, 1, 1, 1, 1,1, ],
	phonemes: ["a i","s i N k","i t","i z","b e s t","n a t","t u","r i","m e m","b a r","s o w","w e l"]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P('arrangement',start:\think,music: {|p b e|
	[
		freq: [\r,11, 5, 4, 2.5].df(\d,3).q,
		dur: b.parse([ 1, 3, 4, 3, 2 ]).q,
		instrument: \sawSynth

	].pp;
	[
		instrument:\wash,
		freq: [\r,2,1,\r,-6,-5].df(\d).q,
		dur: b.parse([1,2,1,4,2,1]).q,
		legato: [1,1,1,0.1,1,1].q


	].pma(\wash).play;
	[
		freq:[\r,5, \r,12].df(\d).q,
		dur:b.parse([1,3,4,3]).q,
		legato:5,
		instrument:\wash
	].pp;
	[
		freq:[\r,5,12,\r,2.5].df(\d,[4,5],tuning:\pythagorean).q,
		legato:[4,4,4,4,1].q,
		dur: b.parse([4,1,1,5,1]).q
	].pp
});
Song.bassSoundTwoDays = (instrument:\stringyy,amp:0.35,attack:0.1);
P('bassNote',start:\think, syl:11, music: {|p b e|
	[dur: b[0].q,freq:1.df('a-',4)].p <> p.bassSoundTwoDays => _.postln => _.play
});
["/*SPOCK:*/ In two days, you'll have your own hands, Thalassa. ",[3,2,4,3,4,3,3,2,4,1,-7].dm('a-')].addLine;
P.still(\closeHenoch, timecode: 3345.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
Song.durs['two days'].list[10]=(1.33);
P.synthV(role: \henoch,
	// take:nil ,
	params: {|p b| [
	lyrics: "in two days youll have your own hands Tha la ssa" ,
	pitchTake:1,
	vocalMode: \Belt
]},filter:{|e| e.midinote = e.midinote -12}, music:{|p b e|
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

//P.tune('two days');
//~twoDaysQuarters= Song.durs['two days'].list.asArray.parseBeats([0.5,0.5,1,1/3,1/3,1/3,3/4,(1/4+(3/4)), 1/4,3/4,(1/4+1)]);
//Song.durs['two days'].list.postcs
P(\bass,start:'two days',syl:1,music:{|p b e|
	var quarters = b.drop(1).asArray.parseBeats([1,1/3,1/3,1/3,2/3,(1/3+(3/4)), 1/4,3/4,(1/4+1)]);


	[dur:1,freq: [-4,-6,-5].df('a-',octave:[  4 ]).q]
	=>_.p
	<> p.bassSoundTwoDays
	=> Pmul(\dur,2,_)
	=>_.trace=>_.play(quarters.asTempoClock)
});
["(intro)" ,"r",[ (104/60).reciprocal*16 ]].addLine;
//Song.durs['intro'] = Song.durs['intro'].list*0.98=>_.q;
//Song.introClock=TempoClock.new(104/60 * 0.98);
( // Hands setup
	Song.handsSynth = { [
		instrument:\sawSynthEnv,
		lofreq: 1270,
		hifreq:2500,
		out: Effect(HPF.ar(_,250),inputChannels:2).bus.index
	].p };
	Song.handsKeys = (intro: 'b-', bridge: \d, reprise: \g, outro:\g);
	Song.handsKeys = (intro: 'b-', bridge: \g, reprise: 'b-', outro:\g);
	Song.handsKeys = (intro: 'b-', bridge: \g, reprise: 'f', outro:\g);
	Song.handsKeys = (intro: 'b-', bridge: \g, reprise: 'c', outro:\a);
	// Song.handsKeys = (intro: 'b-', bridge: \d, reprise: 'b-', outro:\g);
	Song.introClock=TempoClock.new(104/60);
	Song.handsBassArray = [
		amp:0.2,
		out:0,
		dur:0.5,
		rel:0.2,
		trigger:1,
	];
	Song.handsBassLick1 = [1,1,7,1] ++ 1.dup(4) ++ 4.dup(7) ++ 3;
	p = Song;
	Song.handsBassConstructor = { |key=( Song.handsKeys.intro ), start = 'intro'|
		P(\bass,start:start,music: {|p b e|
			p.handsBassLick1
			=>_.df(key,2,\mixolydian)
			=>{|i| 
				[

					freq:i.q(2),
				].pma(
					//		\sawSynthTrigger
					\sawSynthSustain
				) <> p.handsBassArray.p =>_.play(clock:p.introClock) };
			}
		);
	};
);
Song.handsBassConstructor.('b-', 'intro');
P(\808,start:'intro',music: {|p b e|
	\intro.post;t.postln;
	[
		"x.x...x.x.x...x.".asDrumPat(4,4)=>[instrument:\kick_gentle,dur:_,amp:0.5]=>_.p  ,
		"xxxxxxxxxxxxxxxx".asDrumPat(4,4)=>[amp:0.08,instrument:\hat_808,dur:_]=>_.p,
		"....x.......x...".asDrumPat(4,4)=>[amp:0.10,instrument:\sn_808,dur:_]=>_.p ,
	] => Ppar(_) => _.play(clock:Song.introClock)

});
P(\lick,start:'intro',music: {|p b e|
	p.handsSynth.()
	<>
	[
		freq: [\r,5,4,6,\r,5,4,4].df('b-').q * [0.5,1],
		dur: [2,1,1,4,2,1,1,4].q ,
		rawLegato: [1,1,1,1,0.8, 1,1,1,0.8]=>_.flat=>_.q,
		detune: [0, 0.1,0.201 ],
		//amp:0.25,
		legato: Pfunc({|e| (e.rawLegato==1).if{1}{0.6}}),
		//out:Effect({|i| MoogFF.ar(i,1500)=>FreeVerb.ar(_,0.5,0.9) }).bus.index


	].p
	//=>_.pma(\sawSynthSustain)
	//=> _.p
	=>_.trace =>_.play (clock:Song.introClock)
});
["Mechanically efficient and ",[\r,2, 1, 2,  4, 3,\r].dm('e-'),"qq Q Q Q qe eqe e".asBeats*60/104].addLine;
Song.setTempoMap(\efficient,"qq Q Q Q qe eqe e");
Song.handsBassConstructor.('b-', \efficient);
P.synthVs(role: \henoch, take: [\lead, \double], params: {|p b| [
	//lyrics: "r me ka ni kli i fi shent" ,
	lyrics: "r mechanically + + + efficient + + ",
	vocalMode: \Belt,
	pitchTake: [3,1]
]}, pbind:{ |p b| 
	[
		dur: "qe e e e e e qe e".asBeats .warpTo(p.tempoMap[\efficient]).q,
		midinote: "2,  2, 2, 2, 1, 2, 4, 3".dm('e-')
	].p 
}, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		* 2
	}.play
});
P(\808,start:'efficient',music: {|p b e|
	\intro.post;t.postln;
	[
		"x.x...x.x.x...x.".asDrumPat(4,4)=>[instrument:\kick_gentle,dur:_,amp:0.5]=>_.p  ,
		"xxxxxxxxxxxxxxxx".asDrumPat(4,4)=>[amp:0.08,instrument:\hat_808,dur:_]=>_.p,
		"....x.......x...".asDrumPat(4,4)=>[amp:0.10,instrument:\sn_808,dur:_]=>_.p ,
	] => Ppar(_) => _.play(clock:Song.introClock)

});
P(\keys,syl:0,start:\efficient,music: { |p b e|
	var lick1=VoiceLeading(
		[
			[2, 1, 2,  4, 3, \r,\r],
			[\r,\_,\_, 1,\_, \r,\r],
			[-5,\_,\_,-4,-3, \r,-2]
		] ,  
		"Q Q Q qe eqe eqe e".asBeats
	).df('e-',[5,6]).p//ma

	//tune3

	++ VoiceLeading(
		[
			[2, 1, 2, -6, -5, \r,\r],
			[-5,\_,\_, -4, -3, \r,-2]
		],
		"Q Q Q qe eqe eqe e".asBeats
	).df('e-',[5,6]).p//ma
	=> Pn(_,1) => _.fin(26);
	p.handsSynth.()<>lick1<> [ detune: [0, 0.1,0.201 ] ].p=>_.play(clock:Song.introClock) ;

} );
["quite human-looking. ","\r 2 1 2 -6 -5 \r","qq Q Q Q qe eqe e".asBeats*60/104].addLine;
Song.setTempoMap('quite',"qq Q Q Q qe eqe e");
P.synthVs(role: \henoch, take:[\lead, \double], params: {|p b| [
	//lyrics: "r and qwait hu man lu king" ,
	lyrics:" r and quite human + looking +",
	pitchTake:[1, 3],
	legato: [[1, 1, 1, 1, 0.8, 1, 1, ]],
] },pbind:{ |p b| [
	dur: "qe e Q Q Q qe e".asBeats.warpTo(p.tempoMap[\quite]).q,
	midinote: "2,  2, 2, 1, 2, -6, -5".dm('e-')
].p },
music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		*2
	}.play
});
["(boom boom) Android (boom boom) robot hands, of course. ","-1 -1 11 7 12 7 6 11 6 5 7 5 4".dm(Song.handsKeys.bridge,4,\mixolydian),"q q q q qq q q qq q q qqq e e".asBeats*60/104].addLine;
P.still(\sss, timecode: 3353.6.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.synthVs(\feng, take: [ \bg1, \bg2], params: {|p b| [
	lyrics: "r r android + hands r r r r r r r r",
	legato: [[1, 1, 1, 1, 4, 1, 1, 1, 1, 1, 1, 1, 1, ]],
	pitchTake: [ 1,2 ]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.synthVs(\feng, take: [ \bg3, \bg4], params: {|p b| [
	lyrics: "r r r r r android + hands  r r r r r",
	pitchTake: [ 1,2 ],
	paramGender: 0.2,
	legato: [[1, 1, 1, 1, 1, 1, 1, 4, 1, 1, 1, 1, 1, ]],
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.synthVs(\feng, take: [ \bg4, \bg5], params: {|p b| [
	lyrics: "r r r r r r r r android + hands   r r",
	pitchTake: [ 1,2 ],
	paramGender: 0.4,
	legato: [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 4, 1, 1, ]],
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.synthVs(role: \henoch, take: [\lead, \double], params: {|p b| [
	lyrics: "r r r r r r r r robot + hands of course",
	legato: [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.8, 1, 2  ]],
	pitchTake: [1, 3]
] },pbind: {|p b|
	[
		midinote: [0,0,0,0,0,0,0,0, 4, 3, 1, -5, -4].dm(\g).q,
		dur: b
	].p
}, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P('bass',music: {|p b e|
	[
		freq: [1, 1, \r ].df(p.handsKeys.bridge,2).dup(4).flat.q,
		dur: "q q h".asBeats.dup(4).flat .q,
		instrument: \bl,
		out: Effect(EchoNone.ar(_,0.3,"e".asBeats*60/104,4) /5, out: [0,1]).bus.index,
		amp: 0.4

	].p.play(clock:p.introClock);

	[
		freq: [1, 1, \r ].df(p.handsKeys.bridge,2).dup(4).flat.q,
		dur: "q q h".asBeats.dup(4).flat .q,
		instrument: \sawSynth,
	].p.play(clock:p.introClock);

});

P(\808,start:'course',music: {|p b e|
	[
		"x.x...x.x.x...x.".asDrumPat(4,4)=>[instrument:\kick_gentle,dur:_,amp:0.5]=>_.p  ,
		"xxxxxxxxxxxxxxxx".asDrumPat(4,4)=>[amp:0.08,instrument:\hat_808,dur:_]=>_.p,
		"....x.......x...".asDrumPat(4,4)=>[amp:0.10,instrument:\sn_808,dur:_]=>_.p ,
	] => Ppar(_) => _.play(clock:Song.introClock)

});
// P.tune(\course, _ <> [instrument:\sawSynth,amp:0.15].p);
["Hands without feeling. ",[\r, 5,4,5,7,6,\r,\r,5,4,5,2,1].dm(Song.handsKeys.reprise,\mixolydian),"qq Q Q Q qe eqe e".asBeats.dup.flat* 60/104].addLine;
// Song.durs.filter(\without, _ * [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.5]);
P.synthV(role: \henoch, params: {|p b| [
	lyrics: "r hands without + feeling + r r hands without + feeling + r",
	vocalMode:\Solid
] }, music:{|p b e|
	{
		e.playbuf => p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(\mo,take:\bg, take: nil, params: {|p b| [
	lyrics: "r hands without + feeling + r r hands without + feeling + r",
] }, filter:{|e| e.midinote = e.midinote -12}, music:{|p b e|
	{
		e.playbuf 
		// => p.synthVTracks.at(e.key).()
		/2.5
	}.play
});
P('cymbal',start:\Hands,music: {|p b e|
	(instrument:\cymbalsDSStereo,amp:0.004).play;
	(instrument:\cymbal_808,amp:5,pan:-1).play
});
P(\keys,syl:0,music: { |p b e|
	var lick1=VoiceLeading(
		[
			[2, 1, 2,  4, 3, \r,\r],
			[\r,\_,\_, 1,\_, \r,\r],
			[-5,\_,\_,-4,-3, \r,-2]
		] ,  
		"Q Q Q qe eqe eqe e".asBeats
	).df(p.handsKeys.reprise.asNum - 7 ,[6]).p//ma

	//tune3

	++ VoiceLeading(
		[
			[2, 1, 2, -6, -5, \r,\r],
			[-5,\_,\_, -4, -3, \r,-2]
		],
		"Q Q Q qe eqe eqe e".asBeats
	).df(p.handsKeys.reprise.asNum - 7 ,[6]).p//ma
	=> Pn(_,1) => _.fin(26);
	p.handsSynth.()<>lick1<> [ detune: [0, 0.1,0.201 ] ].p=>_.play(clock:Song.introClock) ;

} );
P.tune(\Hands);
Song.handsBassConstructor.(Song.handsKeys.reprise,\Hands);
P(\808,start:'Hands',music: {|p b e|
	\Hands.post;t.postln;
	[
		"x.x...x.x.x...x.".asDrumPat(4,4)=>[instrument:\kick_gentle,dur:_,amp:0.5]=>_.p  ,
		"xxxxxxxxxxxxxxxx".asDrumPat(4,4)=>[amp:0.08,instrument:\hat_808,dur:_]=>_.p,
		"....x.......x...".asDrumPat(4,4)=>[amp:0.10,instrument:\sn_808,dur:_]=>_.p ,
	] => Ppar(_) => _.play(clock:Song.introClock)

});
P(\lick,start:'Hands',music: {|p b e|
	[
		freq: [\r,5,4,6,\r,5,4,4].df(p.handsKeys.reprise).q * [0.5,1],
		dur: [2,1,1,4,2,1,1,4].q ,
		rawLegato: [1,1,1,1,0.8, 1,1,1,0.8]=>_.flat=>_.q,
		detune: [0, 0.1,0.201 ],
		//amp:0.25,
		legato: Pfunc({|e| (e.rawLegato==1).if{1}{0.6}}),
		//out:Effect({|i| MoogFF.ar(i,1500)=>FreeVerb.ar(_,0.5,0.9) }).bus.index


	].p
	<> p.handsSynth.()
	//=>_.pma(\sawSynthSustain)
	//=> _.p
	//=>_.play (clock:Song.introClock)
});
["Enjoy the taste of life while you can. ","1 11 7 6 5 4 13.5 14 13.5 12 13.5 16".dm(Song.handsKeys.outro,4,\dorian)].addLine;
P.still(\henoch, timecode: 3356.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text:["",""],
	).sequenceText2(
			b.parse([1,8]), [ 
				["enjoy the taste","of life"],
				["while you","can"]
			],
	)
});
P.synthVs(role: \henoch, take: [nil, \lead], params: {|p b| [
	lyrics: " r enjoy + the taste of life - - while you can",
	pitchTake: [1, 3],
	filter: [(midinote: _ - 12), (midinote: _ )], 
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
// P.synthV(\mo, take: nil, params: {|p b| [
// 	lyrics: " r enjoy + the taste of life - - while you can",
// 	pitchTake: 1
// ] }, music:{|p b e|
// 	{
// 		e.playbuf
// 		/3
// 		// => p.synthVTracks.at(e.key).()
// 	}.play
// });
P.tune(\Enjoy);
Song.setTempoMap(\Enjoy,"QQ Q QQ Q Q Q q e e e e e");
P('click',start:\Enjoy,music: {|p b e|
	1!10 => _.warpTo(e.tempoMap.quantize()) => _.q => [
		instrument: \hihat,
		pan: Pseries(-0.9,0.23,inf),
		dur: _,
		amp: Pgeom(0.1,0.8,15),
		out: Effect( { |i| i + (Line.kr(0.2,1, b.sum)* TwoTube.ar(i,0.8,0.999,1111,1234) ) }, inputChannels:2 ).bus.index
	] => _.pp
});
P('bass',start:\Enjoy,music: {|p b e|
	(
		instrument: \sawSynth,
		freq: 1.df( p.handsKeys.outro,[3,2]),
		out: Effect(EchoNone.ar(
			_,
			0.3,
			( 60/104/2 ),
			11	
		),inputChannels:2).bus.index
	).play
});
P('chord',start:\Enjoy,music: {|p b e|
	[
		freq: [ \r,[1,3,5,7].df(\g),[1,5,11,13,15,17,21,25].df(\e,4,\minor) ].q,
		strum: 0.06,
		dur: b.parse([6,5,1]).q
	].p.play
});

P('chord2',start:\Enjoy,music: {|p b e|
	[

		freq:	[\r,[5,7,15,16],[4,6,11,13.5],[2, 11, 12, 14, 16, 21]].df(p.handsKeys.outro,2).q,
		dur:3,
		//strum: 0.05,offset:-0.05,
		instrument:\wash,
		amp:0.05,
		dur:b.parse([2,4,5,1]).q
	].p.play
});

["/*KIRK:*/ (boom But.. boom) our minds will have survived. ",[-2,2,-3,3,7,6,5,3,2.5].dm(\f)].addLine;
P.still(\sargonClose, timecode: 3401.7.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""]
	).sequenceText2(
			b.parse([1]), [ 
				["but our minds","will have survived"],
			],
	)
});
P.synthV(role: \sargon, take: nil, params: {|p b| [
	lyrics: "r but r out minds will have survived",
	filter: (midinote: _ - 12), 
	phonemes: ["","b a t", "","a u r", "m a e i n d z", "w i r" ,"h a v","s a r","v a e i v d"],
	// pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
//Song.durs[\survived] = Song.durs[\survived].list.put(8,Song.durs[\survived].list[8]*1.5) => _.q;
P('bass',start:\But,music: {|p b e|
	[
		freq: [2,3].df(\f,[2,3]).q,
		dur:b.parse([2,1]).q,
		instrument:\sawSynth, amp:0.05
	].pp
});
P(\mindChords,syl:3,lag:-0.26, start:\survived, music: { |p b e|
	var strumTime = 0.4;
	var chord = [-21,-11,-15,-1,1,3,5,7].df(\f,tuning:\sept7);
	chord => {|i| 
		(
			amp:0.02,
			freq:i,
			strum:0.06,
			lag:-0.06,
			dur:2,
			instrument:\sawSynthSustain,
			out:[0,1,2,3,4]
			//out:Effect(Phaser2.ar(_,rate:0.2,fb:-0.9),inputChannels:4,out:[0,1,2,3]).bus.index
		).play
	};
	chord => { |i|
		{ 
			i.postln;
			Saw.ar(i,0.07) 
			=> RLPF.ar(_,i*5)
			* XFade2.kr(
				1, 
				Gendy1.kr(minfreq:{0.1.rrand(0.5)}!i.size,maxfreq:7,mul:1),
				Line.kr(-0.9,1,b.sum),
				XLine.ar(1,0.001,b.sum+4)
			)
			=> DelayN.ar(_,strumTime,i.collect{|j x| x*strumTime/(i.size)})
			=> SplayAz.ar(5,_)
			=> PitchShift.ar(_,pitchRatio:[1,2])
		}.play 
	}
});
P(\cymbal, syl: 3, music: { |p b e|
	(
		instrument: \cymbalsDSStereo,
		amp: 0.003 ,
		// out:Effect.bus({|i| i * Env.perc(0.5,3).kr(2,gate:1) },inputChannels:2)
	).play
});
P(\bassNote,start:\survived,syl:7,music:{
	[
		freq:[[1,11,-1]].df('a-',octave:2).q(1),
		dur:3,
		out:Effect(FreeVerb.ar(_,0.8,1),out:[0,1]).bus.index,
		release:4
	].pp
});
P(\extra,syl:7,start:\survived,music:{|p b e|
	[
		freq: [-1,[-4,-5]].df('a-').q,
		amp:0.025,
		dur:[b[1]/2,b[1]/2].q,
		legato:[3,2].q
	].pp
}
);
["And as androids, we can move among the people who do live ",[1,-5,1,-7,1,2].dm('b-')++[7,5,3,5,7,11,7,7,6].dm(\d)].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["and as androids","we can move"],
	).sequenceText2(
			b.parse([8,8]), [ 
			["among the people","who do live"],
			],
	)
});
P(\cymbal, syl: 5, music: { |p b e|
	(
		instrument: \cymbalsDSStereo,
		amp: 0.002 ! 3,
		// out:Effect.bus({|i| i * Env.perc(0.5,3).kr(2,gate:1) },inputChannels:2)
	).play
});
P(\bassnotes, music: { |p b e|
[
	instrument: \harp,
	freq: [\r,1,1,1].df('b-',3).q,
	dur: b.parse([0.5,[0.5,1],2,1]).q,
	coef: [ 0.8,0.7,0.75 ].q,
	mask: [\r,1,1].q,
	out: [0,1,0].q

].pp
});
P.synthV(role: \sargon, take: \lead, params: {|p b| [
	lyrics: "And as androids +, we can move among + the people + who do live ",
	filter: (midinote: _ - 12), 
	phonemes: ["a n d", "a z", "a n d", "r o i d z","w i", "k a n", "m u v", "e m"," a N", "z e", "p i"," p e r", "h u", "d u", "r i v"],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\moveChord,start:\move,syl:5,music:{ |p b e|
	[
		freq:[ [-1,1,3,5,7,13,17].df(\d),[-2,2,5,7,15].df(\d),[-2,2,4.5,7,14.5].df(\d) ].q,
		instrument:\sawSynthSustain,
		att:[ 4.5, 1.3,1.5 ].q,
		legato:[1.0,1.1,1.1].q,
		amp:0.03,
		// lagTime:0,
		lag:[0,-0.04,-0.04].q, //make proportional
		legato: [0.99,1,1].q,
		
		//dur:[b[0..2].sum,b[3..6].sum,b[7..8].sum].q
		dur:b.parse([4,[1,1,1,1],[1,0.5]]).q
	].pma.play
});
["tea -- ching them (ba da da da da), ",[3,4,3,1,-5,-4,-3,-4,-5].dm(\b)].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["teaching","them"],
	)
});
P.synthVs(\an, take: [\bg1, \bg2], params: {|p b| [
	lyrics: "r r r r bah da da da da",
	filter: [
		(midinote: _ - [0,0,0,0,3,3,4,3,3]),
		(midinote: _ - [0,0,0,0,3,3,4,3,3] + 12),
	], 
	pitchTake: [1,3]
] }, music:{|p b e|
	{
		e.playbuf
		=> HPF.ar(_,200)
		=> HighShelf.ar(_,5000,1,8)
		/20
		=>DWGReverbC1C3.ar(_,mix:0.2)
		=> Out.ar(2,_)
		// => p.synthVTracks.at(e.key).()

	}.play
});
P.synthVs(\kevin, take: [\bg1, \bg2], params: {|p b| [
	lyrics: "r r r r bah da da da da",
	pitchTake: [1,3],
	filter: [(midinote: _ - 12),(midinote: _)], 
] }, music:{|p b e|
	{
		e.playbuf
		// => BPF.ar(_, 800, 0.5)
		=> HPF.ar(_,200)
		=> HighShelf.ar(_,5000,1,8)
		// => p.synthVTracks.at(e.key).()
		/20 
		=>DWGReverbC1C3.ar(_,mix:0.2)
		=> Out.ar(2,_)
		// /4
	}.play
});
P.synthVs(\feng, take: [\lead, \double], params: {|p b| [
	// lyrics: "teaching - + them bah da da da da",
	lyrics: "teaching - + them r r r r r",
	legato: [[1,1,1,2 ]],
	pitchTake: [1, 3],
	// vocalMode:\Opera
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(role: \sargon, take: \lead, params: {|p b| [
	lyrics: "teaching - + them r r r r r",
	phonemes: ["t i","i","ch i n g", "z e m" ],
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P('pad',start:\tea,music: {|p b e|
	[
		[
			freq: [\r,4, 3, 1, -5].df(\b,[4,5]).q ++ [4,3].df(\a).q,
			instrument: \stringyy,
			dur: "q h h h h q q q".asBeats.warpTo(e.tempoMap).q ++ e.bNext.parse([3,2]).q,
			amp: Pseg([0.1,0.1,0],[b.sum-0.5,e.bNext[0..5].sum])
		].pm(\stringyy) ,
		[
			instrument:\stringyy, 
			freq:[ \r,[4,5] ].df(\b,[4]).q ++ [ [4,5] ].df(\a,[4]).q,
			legato:[3,1],
			dur: "q hhhh".asBeats.warpTo(e.tempoMap).q ++ e.bNext.parse([2]).q
		].p,

	] => Ppar(_)
	=> _.play
});


P(\cymbal,syl:0, music: { |p b e|
	(
		instrument: \cymbalsDS,
		amp: 0.015
	).play
});
Song.setTempoMap('tea', "x qex q q q q q q q ");
P('click',start:\tea,music: {|p b e|
	1!8 => _.push(1, 0.7)
	=> _.warpTo(e.tempoMap) //		.quantizeWindow()
	++ e.bNext[0..2]
	=> _.flat
	=> _.q => [
		amp: [0,0.1].q(8) * 0.6,
		instrument: \hihat,
		dur: _,
		out: Effect(DWGReverbC1C3.ar(_)).bus.index
	] => _.pp
});
Song.teachingBass = [
	amp: 0.3,
	dur:3,
	release:4
].p;

P.tune('tea -- ching');
P(\bassnote,start:'tea -- ching',syl:0,music:{|p b e|
	//b[0].postln;
	Song.teachingBass 
	<> [
		freq:[[1,11,-1]].df('b',octave:2).q,
		lag: b[0]/2 + 0.025,
		out:Effect( { |i|  HPF.ar(i,85) => FreeVerb.ar(_,0.8,1,mul: Env.linen(0,b.sum-(b[0]/2)).kr(2,gate:1))},out:[0,1]).bus.index,
	].p
	=> _.play
});
["helping them (boom) not to make the errors we -- did. (pain) ",[4,3,1,-7,1,2,3,1,4,5,5,6,5,-7.5].dm(\a,scale:\mixolydian)].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["helping","them"],
	).sequenceText2(
			b.parse([4,10]), [ 
			["not to make", "the errors we did"]
			],
	)
});
P.synthV(role: \sargon, take: \lead, params: {|p b| [
	lyrics: "helping + them r not to meik ze errors + we - did r",
	phonemes: ["","","","","","","","", "e r", "a r z","w i","","",""],
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.synthVs( \feng, take: [\backup, \bg2], params: {|p b| [
	lyrics: "helping + them r not to make the errors + we - did r",
	// phonemes: ["","","","","","","","", "e r", "a r z","w i","","",""],
	pitchTake: [1,3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).(mix:0.05)
		* -3.dbamp
	}.play
});
P('cymbal',start:\helping,music: {|p b e|
	(
		instrument: \cymbalsDS,
		out: Effect (PitchShift.ar(_,pitchRatio:[ 0.5,0.4 ] / 8)).bus.index
	).play
});
P('bass',start:\helping,music: {|p b e|
	[
		freq:[[-7,7,-17]].df('b',2,\mixolydian).q,
		amp: 0.5,
		out:Effect(FreeVerb.ar(_,0.8,1),out:[0,1]).bus.index,
	].p
	<> Song.teachingBass
	=> _.play
});
Song.durs[\pain].list.put(13,4); //'pain' length
P.still(\thalassaWhat,syl:12, timecode: 3417.1.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
	)
});
P.tune('helping', _ <> [rests:[1,1,1,\r,1,1,1,1,1,1,1,1,1].q].p);
P('bass',start:\helping,music: {|p b e|
	[
		freq: [\r,\r,\r, -7,\r,[1, 11 ] ].df(\a, [ 3 ],\mixolydian).q,
		dur:b.parse([1,1,1,4,[ 4,0.5 ],2]).q

	].p.play
});
//Song.durs[\helping].list.postln
P(\answer,start:'helping',syl:2,music:{|p b e|
	[
		instrument:\stringyy,
		amp:0.2,
		freq:[-7,1,2,-5].df(\a,scale:\mixolydian).q / 1 ,
		dur:b.drop(1).parse([1,1,1,7]).q,

	].pp
});
P(\doubling,start:'helping',syl:2,music: {|p b e|
	\b.post;b.postln;
	[
		midinote:p.tune.at(p.section('helping')).list[3..].q-12,
		ctranspose: 0!9++3 => _.flat => _.q,
		dur:b.drop(1).q,
		instrument:\sparkTriangle,
		out:[0,1]

	].pp

});
P(\pain,start:'helping', syl:12,music: {| p, b, e|
	(
		instrument:\stringyy,
		mix:0.3,
		width: [6,6,6,20,1],
		freq: [-11,1,-1,21,21.3].df('a-',octave:3),
		amp:0.2,
		dur:3

	).play;
	{[ Dust.ar(30) , Crackle.ar(2,mul:0.09) ] 
	* Env.linen(0,b.sum,3).kr(2,gate:1)
}.play
});
/* P.still(\pain,syl:12, timecode: 3412.2.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
}); */
["/*MULHALL:*/ What is it, Sargon? ",[1,5,4,1,-7].dm(\c)].addLine;
//fixme
P.still(\withMouthOpenT, timecode: 3417.8.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["what is it","Sargon?"],
	)
});
P.synthV(role: \thalassa, take: \lead, params: {|p b| [
	lyrics: "wat iz it sa gan?",
	phonemes: ["what".xsampa.unbubble,"is".xsampa.unbubble,"it".xsampa.unbubble,"","gone".xsampa.unbubble] , // make .xsama work on arrays
	lag: [0.1,0.05,0,0,0],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		* 2.dbamp
	}.play
});
["/*KIRK:*/ Nothing. Our next injection will renovate me. (boom) ",[1,1].dm('e-')++[2,3,1,3,-7,1,2,1,-7,-5,-3].dm('d',scale:\mixolydian,)].addLine;

P.still(\nothing, timecode: 3421.4.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["nothing",""],

	).sequenceText2(
			b.parse([2,6,4]), [ 
			["our next","injection will"],
			["renovate","me"],
			["",""]
			],
	)
});
// P.still(\twoAgain, timecode: 3422.5.seconds, music: { |p b e|
// 	 e.still.( 
// 		wait: b.sum,
// 		text: ["nothing",""],
// 	).sequenceText2(
// 			b.parse([2]), [ 
// 			["our next injection","will renovate me"],
// 			],
// 	)
// });
P.synthV(role: \sargon, take: \lead, params: {|p b| [
	lyrics: "Nothing. + our next injection + + will renovate + + me r",
	phonemes: ["n a","s i N","a u a r","n e k s t", "i n","j e k t","sh a n","w i l","r e n","o","v e i t", "m i" ],
	legato: [1,0.5,  1,1,1,1,1,1,1,1,1,1],
	// filter: (midinote: _ - 13), 
	filter: (midinote: _ - 1), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> Pan2.ar(_,0)
		/4
		// => p.synthVTracks.at(e.key).(3.dbamp)
	}.play
});
Song.resources.renovateKey='e-';
Song.resources.renovateKey='b-';
Song.resources.renovateKey='d';
// ~justTheTune.('renovate',({|i| i.fin(12)=> Pmul(\freq,midiratio(-13),_) //'e- to b-' }));
P(\dyad,start:'renovate',music:{|p b e|
	[
		freq:
		[-5,-7]!2=>_.unbubble ++ [-17.5,-7.5] 
		=>_.df(p.renovateKey,octave:4,scale:\mixolydian )=>_.q,
		dur:b.parse([1,2,5]).q,
		instrument:\stringyy,
		amp:0.25,
	].pp
}
);
P(\chord,start:'renovate',lag:-1.5,syl:7,music:{|p b e|
	( 
		freq:[-5,-7,1,3].df(p.renovateKey,scale:\mixolydian) * midiratio(-1) ,
		instrument:\sawSynthSustain,
		att:7,
		dur:4,
		rel:4,
		amp:0.05,
	).play
}
);
P(\baseNote,start:'renovate',syl:11,music:{|p b e|
	( 
		instrument:\stringyy, 
		attack:2,
		dur:4,
		freq:[1,11].df(p.renovateKey,octave:2 ) * midiratio(5),
		amp:0.25,
	).play;
	[ instrument: \harp,
		freq: [ 4,24 ].df(\d,2),
		amp: 0.02,
		out: Effect.bus(FreeVerb.ar(_,0.5,[ 1,0.8 ]), inputChannels:2,out:[0,1])
	].p.fin(1).play
}
);
P.tune( { |i|  i <> [ instrument: \sawSynthSustain, att:2, amp:0.02 ].pm => Pmul (\freq, (-1).midiratio,_) => Pfin(12,_)} );
["Do not be concerned.",[3,4,2,3,-7].dm('d',octave:5,scale:\minor )].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["do not be","concerned"],
	)
});
P.still(\ThalassaClose, syl:2, timecode: 3427.5.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum + 3,
		text: ["",""],
		fadeIn: b.sum,
		fade: b.sum
	)
});
P.synthV(role: \sargon, take: \lead, params: {|p b| [
	lyrics: "du not bi kan sand",
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).(2.dbamp)
		=> Pan2.ar(_,0)
		=> {|i| CombN.ar(i, 0.3,0.26,6) /4 + i}
		/3
	}.play
});

P.tune('be concerned', { |i| i <> [instrument:\wash,amp:[ 0.02, 0.01 ],out:[0,1].q(inf)].p => Pmul(\freq,[2, 0.5 ],_)});
}
) 
