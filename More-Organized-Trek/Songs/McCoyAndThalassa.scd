(
s.waitForBoot{
	Song('MandT',[]).current;

	"/Users/michael/tank/super/More-Organized-Trek/Songs/boilerplate.scd".load;

	[ "MULHALL: Doctor. ",[3,1].dm(\c) ].addLine;
P.tune('MULHALL: D');
	[ "MCCOY: Yes? ","r" ].addLine;
	[ "MULHALL: Would you like to save your Captain Kirk? ","r" ].addLine;
	[ "MCCOY: But you said that was impossible. ","r" ].addLine;
	[ "MULHALL: We have many powers Sargon did not permit us to use. ","r" ].addLine;
	[ "He thought them too tempting to us. ","r" ].addLine;
	[ "This body pleases me. ","r" ].addLine;
	[ "I intend to keep it. ","r" ].addLine;
	[ "MCCOY: I see. And Henoch intends to keep Spock's body, of course. ","r" ].addLine;
	[ "MULHALL: Henoch's plans are his own affair. ","r" ].addLine;
	[ "I wish only to exist in peace as a living woman. ",[3, 6, 5, 6, 4.5, 5, 3, 7, 11, 7, 7, 4, 5, 5, 6, 5, 1, 2, 1].dm('f#') ].addLine;
	Song.synthVTracks=EventWithDefault();
	Song.synthVTracks.aiko = { |preGain=1 ratio=2 amp = (1/8) len=2000 mix=0.1 |
	{ |i|
		i.() * preGain
		=> SoftKneeCompressor.rms(_,  thresh:-10, ratio: ratio, knee:6, attack:0, release:0.05, makeUp:0, rms:40) 
		* amp
		=> DWGReverbC1C3.ar(_,len:len,mix:mix)
		=>.first DetectSilence.ar(_,doneAction:2)
	}
};
	Song.synthVTracks.default = Song.synthVTracks.aiko;
	Song.quarters[\exist] = Song.parseBeats(\exist,[
		1,
		2,1/2, 1/2, 1/2,1/2,
		1, 1/2, 3/2, 1, 
		4+4/3,2/3,2/3+2,	
		//5/2, 1, 5/2, 
		1/2,1, 1/2, 1/4, 3/4, 1
	]);
P.synthV(role: \thalassa, params: {|p b| [
		lyrics: "ai wish on li tu ex i - ist in pis as a li ving wu man",
		phonemes: [ "a :\\i", "w i\\ s`", "@U n"," l i", "th u", "e k ts"," i\\ ","i\\","i\\ s th", "i\\ n", "ph i s", "a ts", "@", "l i\\ ","i\\","w i\\ N g", "w U "," U ","m @ n" ]
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key.postln).postln.(1).postln
		}.play
	});
P(\click,start:\exist,music:{|p b e| 
		//[dur:1].p.play(TempoClock.newFromQuarters(p.quarters[e.start]))
	});
	//P.tune(\exist);
	
P(\piano,start:\exist,syl:12,music:{|p b e| 
		[
			freq: 
		[[2,5],3,2].df(_) => [\b,\e].collect(_) => _.flatten
			=> _.q,
			dur: b.drop(1).q,
			legato: [[1,3],1,1, [1,9],1,1].q,
			instrument:\twang
		].pp;
	});
P(\test,start:\exist,syl:0,lag:-3/100,music:{|p b e| 
		(
			freq: [-4,1,3, 5].df('e-', scale: \minor),
			strum: 3/100,
			dur: b.drop(1)[(0..4)].sum
		).play	
	});
P(\bass,start:\exist,music:{|p b e| 
		[
			freq: [\r, 3, 13, 5, 3, 2, 12, 2, 5, 5, -5, 4, 4, 5, 1, -7 ].df('e', octave:3).q,
			instrument:\sawSynth,
			//dur: b.parse([1,5,4, 2, ]).q
			dur: [1/2,
				0.75, 0.75, 0.25, 0.25,
				1, 0.5, 0.5,
				0.75, 0.25, 1, 1/2, 1/2, 1, 1, 1].q*2
		].p.play(clock:TempoClock.newFromQuarters(p.quarters[\exist]));
	});
	[ "MCCOY: If you're asking my approval ",[3, 4, 5, 4, 3, 5, 11, 7].dm(\f,4,\harmonicMinor) ].addLine;
P.tune(\approval);
P.synthV(role: \mccoy, take:\lead, params: {|p b| [
		lyrics: "if your asking + my approval + +",
		pitchTake: 1
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
	[ "MULHALL: I require only your silence", [7,11,12,7,11,12,12.5,2.5].dm(\c) ].addLine; 
	// Song.durs[\silence] = Song.durs[\silence].list + [0,0,0,0,0,0,0,0.5] => _.q;
	// Song.durs[\silence] = Song.durs[\silence].list - [0,0,0,0,0,0,0,0.1] => _.q;
P.synthV(role: \thalassa, params: {|p b| [
		lyrics: "ai ri kwair on li your sai lence" ,
		legato: [1, 1, 1, 1, 1, 1, 1, 0.8]
	] }, music: {|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
//P.tune(\require);
		Song.pulse = {
		Pulse.ar(\freq.kr(300),0.4)
			* \amp.kr(0.1)
			=> Out.ar(\out.kr(0),_)
		}.asDefName;
		Song.impulseBass = { |dur=2|
			var freq;
			Impulse.ar(freq = \freq.kr(300))
			=> OnePole.ar(_, coef:0.5, mul:1.0, add:0.0)
			=> Phaser1.ar(_, depth:0.5, rate:1, fb:0.3, cfb:0.1, rot:1.5707963267949)
			+ VarSaw.ar(freq,0,0.9,0.2)
			* \amp.kr(0.1)
			* Env.linen([0,1,1,0],[0.05,dur,4]).kr(0,gate:\gate.kr(1))
			=> Out.ar(\out.kr(0),_)
		}.asDefName;
	P(\bass,start:\require,music:{|p b e| 
		[
			freq: [7,6,5,4.5,3,4.5].df(\c,[4]).q,
			dur: b.q,
			instrument: p.pulse,
			amp:0.02
		]//.ppm
		;
		[

			freq: [7,6,5,4.5, ].df(\c,[3]).q,
			dur: b.parse([1,1,1,3,1]) + [0,0,0,0,2]=>_.q,
			legato: [1,1,1,0.9,6].q,
			instrument: Song.impulseBass,
			amp:0.07

		].pma.trace.play;
		(
			freq:[-2.5, 2.5 ].df(\c,3),
			instrument: p.impulseBass,
			lag: b.parse([6]),
			dur:0.1
		).play
	});
	[ "Only you and I will know that Doctor Mulhall has not returned to her body. ",[1,2,3,1,4.5,2,-6].dm('e-') ++ [2,3,1,4.5,2].dm(\c) ++ [1,2,3,4].dm(\e,scale: \whole) ++ [11,7,6,7,5,12,4.5].dm(\b,4) ].addLine;
P.tune(\returned,_<> [instrument:\wash,amp:0.03].p);
P(\bassnote,syl:20, music: { |p b e|
		[
			freq:[2,-2 /*,14.5*/,-6].df(\b,3),
			dur: [ 2 ].q
		].pp
	});
P(\bassDyad1,start:\returned,music:{|p b e| 
		MegaBind(
			[
				[\r, \r, 1,  \_, 2,  \_, \_, \r, \r, \r, \r, \r, \r].df('e-'),
				[\r, \r, \r, \r, \r, \r, \r,  \r, 1,  \_, 2, \_].df('e'),
			],
			b,
			[pan:[-1,1]],
			{|i|
				VarSaw.ar( i.freqSeq/[2,3,4],0,0.8 )
				* Env.asr(0.1,1,4).kr(gate:i.gateSeq)
				=> Pan2.ar(_,i.pan)
			},
			{|i|
				Splay.ar(Mix.ar(i)) / 19
			}
		).play
	});
P(\strum,start:\returned,syl:3,music:{|p b e| 
		(
			freq:[5,7,11,13].df(\f,scale:\mixolydian)/2,strum:0.07,amp:0.16,out:
			Effect( { 
				|i| 
				//FreeVerb.ar(i,1,1) 
				i
				=> FoaEncode.ar(_,~encoders.omni) * 1.5 
				=> AmbiVerbSC.ar(_,mix:0.5,size:"Magna Auditorium")
				=> FoaTransform.ar(_, 'press', pi/4, -pi/2)
				=> Monitors.decode(_)
			} ,inputChannels:2).bus.index
		).play
	});
P(\strum2,start:\returned,syl:9,music:{|p b e| 
		(
			freq:[5,7,11,13].df(\e,scale:\mixolydian)/2,strum:0.07,amp:0.16,out:
			Effect( { 
				|i| 
				i
				//FreeVerb.ar(i,1,1) 
				=> FoaEncode.ar(_,~encoders.omni) * 1.5 
				=> AmbiVerbSC.ar(_,mix:0.5,size:"Magna Auditorium")
				=> FoaTransform.ar(_, 'press', pi/4, pi/2)
				=> Monitors.decode(_)
			} ,inputChannels:2).bus.index
		).play
	});
P.synthV(role: \thalassa, params: {|p b| [
		lyrics: 
		"on li yu an ai will no that dak ter mul hall haz nat ri tu - - urned to her ba di"
		,
		legato: 
		[ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,1,1, 0.5 ]
		,
	] },filter:{|e|
		e.midinote = e.midinote -12
	},music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).(2)
		}.play
	});
	[ "Isn't that worth your captain's life? ",[3,2,4,2,3,1,2,5].dm(\a,5,\minor) ].addLine;
	// Song.durs[\worth] = Song.durs[\worth].list + [0,0,0,0,0,0,0,0.2]  => _.q
	// "jaw".xsampa
P.synthV(role: \thalassa, 
		pbind: Song.enlarge(2),

		filter: (midinote: _ - [12,12,12,12,12,12,12,12,0,0]), 
		params: {|p b| [
		lyrics:"iz nt that wurth yor kap tinz laif" ,
		phonemes: ["j s"," i :n th ", "t a th", "w a r\\` s", "j o ", "kh a ph"," th @ n ts", "l a :\\i f", "t A kh", "th a r\`" ],
		legato: [1,1,0.9,1,1,1,1,0.8, 1, 0.8],
		paramTension:0.2,
		tension: Env([0,0.2],b.sum)
	] },music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).(Line.kr(2.5,2,b.sum))
			// * 2
		}.play
	});
P.tune(\life);
P(\bass,start:\life,music:{|p b e| 
		[
			freq: "11 7 5 7 11 6 4 -6.5".df(\a, 3, \harmonicMinor).q,
			dur: b.q
		].pp
	});
	//[ "Doctor, we can take what we wish. ",[11, 5, 3, 5, 12, 11, 7, 6].dm(\e,4) ].addLine; //?????
	[ "Doctor, we can take what we wish--. ",[4.5, 3, 6, 6, 6, 5, 6, 6, 7].dm(\a,4) ].addLine; //?????
// Song.durs['wish--']	= Song.durs['wish--'].list.dropLast ++ ( Song.durs['wish--'].list.last * 0.75 ) => _.q
	Song.wishVocalTwoSections = VocalRPP('wish--',\wish);
P(\trem, music: { |p b e|
	
		{
			Gendy2.ar(minfreq:[ 21 ].df('b-')- { 20.rrand(10) }!5 ,maxfreq:1.df('b-')+20)
			/200
			// * Line.kr(0,1,b.parse([4]).unbubble)
			=> Splay.ar(_)
			+
			Impulse.ar(0)
			=> FreeVerb.ar(_,1,1)
			=> Splay.ar(_)
		}.play
		
	});
P.synthV(role: \thalassa, params: {|p b| [
		lyrics:"r r wi kan taik wat wi wi ish" ,
		paramTension:0.2,
		legato:[1,0.9,1,1,0.9,1,1,1,0.7]
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).(2)
			// => Phaser2.ar(_,rate:0.2)
		}.play
	});
P.synthV(\cheng, take: \lead, params: {|p b| [
		lyrics: "r r we can take what we wish -",
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
P(\wish,start:'wish--',lag:-1,music:{|p b e| 
		//{Song.wishVocalTwoSections.buffer.bufnum => PlayBuf.ar(2,_ ) *0.1}.play
	});
P.tune('we can take');
P(\bass,start:'we can take',music:{|p b e| 
		[
			//freq: [\r, 1, 1, -4].df(\b,3).q,
			freq: [1, -7, -5, 1, -4].df(\b,[ 2,3 ],\mixolydian).q,
			dur: b.parse([3,1,2, 1,2]).q
		].pp
		
	});
P(\chords,start:'we can take',music:{|p b e| 
		var fs=[-6,1,3,6].df(\a);
		var a = [-5,1,3,5].df(\a);
		[
			freq: [\r,\r,fs,fs,fs,a,fs,fs,[-7,7].df(\a)].q,
			dur: b.q,
			instrument:\sawSynthSustain,
			amp:0.03
		].pp;
	});
P(\bass,start:'we can take what we wish',music:{|p b e| 
	[
		freq: [11, 7, 6, 5, 4].df(\e).q /4 + 2,
		dur: b.parse([4,1,1,1,1]).q,
		width: [2,2,2,2,2]/2 
	].pma(\default).play
	});
	[ "Neither you, this ship, nor worlds have the power to stop us." ,[5, 5, 6, 5, 6, 5].dm('c#',5,\minor) ++ [7, 6, 11, 7, 6, 5, 4 ].dm(\c,5,\mixolydian) ++ [7, 11, 7, 7, 6].dm(\d,5,\mixolydian) ].addLine;
P.synthV(role: \thalassa, params: {|p b| [
		lyrics: "ni ther you this ship nor wo orlds have the pa wer to sta a ap  us as" ,
		phonemes: ["n i","t a r\\`","j u","t i s","s` i ph","n a r\\`","w a r\\`","l t ts","x a w","t @","ph AU"," a r\\`","th u","s th A","A","A ph","A",""],
		legato: [1, 1, 0.9, 1, 0.9, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
		// tens1ion: Env([1,1],[3])
		paramTension: 0.1,
		loudness: Env([-1,-1,3,0,3,-2,6,5,0,0,0,0,0,0,0,0,0]/3,b+0.1)

	
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).(2)
		}.play
	});
P.synthV(\feng, take:\lead, params: {|p b| [
		lyrics: "Neither + you, this ship, nor worlds - have the power + to stop - - us.",
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
P.double(\feng, take: \lead, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
P.tune(\worlds, { |i| Pmul(\freq,0.5,i) => Pbindf(_,\instrument,\sawSynthSustain,\amp,0.05,out:3) } );
	// Song.worldsVocal=VocalRPP(\worlds,\lead);
	// Song.encoders.spread=FoaEncoderKernel.newDiffuse;
	// P(\vocal,lag:-1.0,start:\worlds,music:{|p b e| 
	// 	{
	// PlayBuf.ar(2, p.worldsVocal.buffer.bufnum )
	// 			* 0.8
	// 			=> Phaser2.ar(_,fb:0.9,rate:0.15)
	// 		=> FoaEncode.ar(_,Song.encoders.spread)
	// 		=> FoaDecode.ar(_,Monitors.decoder)
	// 	}//.play
	// });
P(\figure,start:\worlds,music:{|p b e| 
		[
			freq: [\r, 1, -5, \r, 1, -5].df('c#').q,
			dur: b.parse([2,0.5,0.5,1,0.5,0.5]).q,
			instrument:\harp,
			out:Effect(_ * 0.2, out:[2,1]).bus.index
		].pp
		
	});
P(\chords,start:\worlds,music:{|p b e| 
		var you = [-11,-5,1,3].df('f#', scale: \minor),
		ship = [1,3,5,7].df(\c,scale:\diminished),
		worlds = [-1,1,3,5,7].df(\c,scale:\mixolydian)
		;
		[
			freq: [\r,you,\r, ship,\r, worlds].q,
			dur: b.parse([2,1,1,1,1,4]).q,
			instrument:\stringyy,
			mix:[\r,0.5,\r, 0.5,\r, 1].q /2, amp: [\r,0.2,\r,0.2,\r,0.3].q,
			width:[\r, 7, \r, 10, \r, 12].q * 2,
			out: [
				\r,0,\r, 0,\r, Effect(
			Phaser2.ar(_,rate:0.2,fb:(-0.9))
				).bus.index
			].q,
			release:1,
			legato:0.97
		].pp;
	});
P(\crash,start:\worlds,music:{|p b e| 
		[ amp:[0.04,0.03]/2,
			instrument:\cymbalsDS,
		out:Effect(Phaser2.ar(_,fb:0.95,rate:0.13)).bus.index,
			dur:b.parse([2,2,2,1]).q,
			freq:[\r,1,1,1,1].q
		].pp
	});
P(\bassNotes,start:\worlds,music:{|p b e| 
		[
			//freq: [1, 1, 4, 1, 2, 1, -7, 2, 3,  1.5, 4.5].df('c#',[3,4]).q,
			freq: [\r, 1, 2, -7, 2, 3,  1.5, 4.5].df('c#',[3,4]).q,
			dur: b.parse([2,2, 2, 3, 1, 3, [1,1,1,0.5],[0.5,1]]).q
		].pp
	});
	// ????????
	[ "MCCOY: Neither Jim nor I can trade a body we don't own",[1, 2, 3, 1, 4, 2, 3, 4, 5, 4, 3, 2, 6].dm(\g,4,scale:\lydian)].addLine;
P.synthV(role: \mccoy, take:\lead, params: {|p b| [
		lyrics: " Neither + Jim nor I can trade a body + we don't own",
		pitchTake: 1
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
P.tune(\trade);
P(\bassline,start:\trade,music:{|p b e| 
		[
			freq: [\r, 1, 2, 1.5, -7, -6].df(\g).q / 4,
			dur: b.parse([2, 2,2,  2, 4,1]).q,
			instrument:\wash,
			out: [0,1].q(inf),
			att:0.5
		].pp;
	});
	[ "It happens to belong to a young woman. ",[-5, 1, -7, 1, 2, 3, 1, -7, -6, 4, 3, 2].dm(\f) ].addLine;
P.synthV(role: \mccoy, take:\lead, params: {|p b| [
		lyrics: "It happens + to belong + to a r young woman +",
		pitchTake: 1
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
P(\chords,start:\happens,music:{|p b e| 
		[
			freq: [\r, [1,5,1], [-4], [-5, 2, 4] ].df(\f).q / [1,2],
			dur: b.parse([1,7,2,2 ]).q,
			instrument:\wash
		].pp;
	});
P.tune(\happens);

	[ "MULHALL: Who you hardly know. Almost a stranger to you. (boom) ",[3, 1, 5, 4, 3.5].dm(\b,5,\whole) ++ [-7, 1, 2, 2.5, -7, -6, -4.5, -2.5].dm(\c,6) ].addLine;
P.synthV(role: \thalassa, take:\lead, params: {|p b| [
		lyrics: "Who you hardly + know. Almost + a stranger + to you r  ",
		legato: [1,        1,     1,           1,        0.5,    1,       1,          1,   1,                        1,         1,      1],
		phonemes: [ "x u", "j u", "x A r\\` ", " t l i", "n @U", "o l m", " @U s th", "@", "s t r\\` e :\\i n ts` ", " a r\\`", "th u", "j u"  ],
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
// add a beat with e flat in the bass here
P.tune(\hardly);
P(\chord,start:\hardly,music:{|p b e| 
		[
			freq: [[1,3,5].df(\b,4,\whole),[1,3,5].df('a-',4,\whole), \r, [-5].df(\g),[-17,-7,12,14].df(\e,3)].q,
			dur:b.parse([4,1,3,2,2]).q,
			instrument: \stringyy,
			amp:0.2,
			legato:1
		].pp
	});
P(\boom,start:\hardly,syl:11,music:{|p b e| 
		(
			freq: 1.df('e-',[2,3]),
			amp:0.4,
			instrument:\stringyy,
			attack:0.01,
			out: Effect( FreeVerb.ar(_,1,1),out:3 ).bus.index
		).play
	});
	Song.encoders.put(\quad,FoaEncoderMatrix.newQuad);
P(\chords,start:\hardly,music:{|p b e| 
		MegaBind(
				[
					[\r, 3, \_, \_, 4, 3, 4, 5, -7, \_, \_, \_, -5.5 ].df(\g)
				],
				b,
				[],
				{|i x|
					Gendy2.arWidth(
						ampdist: 1,
						durdist: 1,
						adparam: 1.0,
						ddparam: 1.0,
						freq: i.freqSeq / [1,2],
						width: 1.015,
						ampscale: 0.25,
						durscale: 0.5,
						initCPs: [2,3,4],
						knum: nil,
						a: 1.17,
						c: 1.31,
							mul:[1,1.3,1]
						)
					* Env.asr().kr(gate:i.gateSeq)
					* 0.05
						//=> FoaEncode.ar(_,~encoders.omni)
						//=> FoaPress.ar(_,pi/4,pi*x/2,pi/2)
				},
				{|i|

					Splay.ar(i)
					=> FreeVerb.ar(_,0.5,0.8)
						//i
						
			//			=>  AmbiVerbSC.ar(_,0.5,lowRT:1,highRT:3)
					//=> Monitors.decode(_)
				}
			).play
	});
	[ "MCCOY: I will not peddle flesh. I'm a physician. ",[11, 11, 11, 7, 7, 6 ].dm(\g,scale:\mixolydian) ++ [5, 5.5, 7, 11, 1].dm('a-',scale:\mixolydian)].addLine;
P.synthV(role: \mccoy, take:\lead, params: {|p b| [
		lyrics: " I will not peddle + flesh. I'm a physician. + + ",
		filter: (midinote: _ - 12), 
		legato: [1, 1, 0.7, 1, 1, 0.6, 1, 1, 1, 1, 1],
		pitchTake: 1
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
P.tune(\peddle);
P(\bass,start:\peddle,music:{|p b e| 
		[
			freq: [5,5,5,5,5,11,].df(\c,3).q ++ [5,1].df('a-',3).q,
			dur: b.parse([1, 1, 1, 1, 1, 1, 3, 2]).q,
			instrument: \sawSynth
		].pp;
	});
P(\chords,start:\peddle,music:{|p b e| 
		[
			freq: [5,7,12,15] ! 3 ++ [5,7,12,14].dup ++ [[5,11,13]] => _.df(\c,[3,4]) => _.q,
			dur: b.q
		].pp
	});
	Song.physicianKey = 'b-';
	//Song.physicianKey = 'g';
	[ "MULHALL: A physician? ",[1, 1, 11, 1].dm(Song.physicianKey) ].addLine;
P.synthV(role: \thalassa, take: \lead, params: {|p b| [
		lyrics: "a physician + +",
		phonemes: ["@","f @","ts i\\","s` @ n`"],
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
P(\chord,start:'physician?',syl:1,music:{|p b e| 
		(
		freq: [1,3,5,7,11].df(p.physicianKey,4,\diminished)
		).play
	});
P.tune('physician?');
	[ "In contrast to what we are, you are a ", [-7, 1, 2, 3, 4.5, 5, 2, 6, 7 ,4].dm(\g,scale:\mixolydian) ].addLine;
P.synthV(role: \thalassa, take: \lead, params: {|p b| [
		lyrics: "In contrast to what we are, you are a ",
		phonemes:["i \\n","kh A n","t r\\` a s th","th u", "w A th","w i", "A r\\`", "j u", "A r\\`", "@"],

		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
P.tune(                \contrast,
                { |i| Pmul(\freq,[0.5,1,2.01],i) => Pbindf(
                		_,
			*[
                                \instrument:\stringyy,
                                \amp:[ 0.2,0.2,0.1 ]/4 *.x [4,5,6,7,8,9,7,8,9,4]/10 => _.q,
					\out: Effect({|i| Monitors.az(i,[0,2/3,4/3])}).bus.index,
                                \release, 4,
					\legato: 1,
					\mix: 0.1
                        ]
                	)} );
	
	["prancing, savage, monkey ",[-1, -1, 3, 1, -4, -4, 4, 1, -7, -7, -7, -7, -7, -7, 2, 1 ].dm(\g, scale:\mixolydian)].addLine;
	Song.quarters[\prancing] = Song.parseBeats(\prancing,[1,1,1,1, 1,1,1,1, 1,1,1,1, 1,1,1.5,0.5]).quantize(0.5)  ;
P.synthV(\cheng, take:\lead, params: {|p b| [
		lyrics: "r r stupid + r r  prancing + r r r r r r  monkey +",
		filter: ( dur: { |i| "q q q q q q q q q q q q q q qe x".asBeats.warpTo(p.quarters[\prancing]) } ), 
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
P.double(\cheng, params: {|p b| [
			
		filter: ( dur: { |i| i.asArray.warpTo(p.quarters[\prancing]) * 2} ), 
		] }, music:{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
			}.play
		});
P.synthV(role: \thalassa, take:\lead, params: {|p b| [
		lyrics: "r r stupid + r r  prancing + r r r r r r  monkey +",
		pitchTake: 1,
		phonemes: [ "","","s th u"," ph @ t", "","","ph r\\` a n s","i N",  "","","","","","","m A N"," kh i" ],
		filter: ( dur: { |i| "q q q q q q q q q q q q q q qe x".asBeats.warpTo(p.quarters[\prancing]) } ), 
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
P(\test,start:\prancing,music:{|p b e| 
		[
			instrument:\bd_808,
			dur: 1!15 ++ [0.99] => _.warpTo(p.quarters[e.start]) => _.q,
			//Song.quarters[\prancing].size
		].pp
	});
	//P.tune(\prancing);
P(\bass,start:\prancing,music:{|p b e| 
		b = b.asArray.quantizeWindow();
		[
			freq:[\r,\r,3,1,\r,\r,4,1,\r,\r,\r,\r,\r,\r,2,1].df(\g).q,
			dur:1!14 ++ 1.5 ++ 0.49  => _.warpTo(p.quarters[e.start]) => _.q,
			instrument:\wash,
			att:0.5


		].pp;
		[
			freq: [1,1,1,1,4,4,4,4,7,7,7,7,7,7,7,7].df(\g, scale:\mixolydian ).q/8,
			instrument:\yowbass,
			legato: 0.1,
			dur:1!15 ++ [0.99] => _.warpTo(p.quarters[e.start]) => _.q,
			legato: [1,1,1,0.5].q(inf),
			release: [0, 1.5, 1.5, 0].q(inf),
			//out:Effect(CombC.ar(_,b[0]/2),out:[2,3]).bus.index 
			lag:Pkey(\dur)/2
		].pp	;
		[
			freq: [1,1,1,1,4,4,4,4,7,7,7,7,7,7,7,7].df(\g, scale:\mixolydian ).q/8,
			instrument:\sawSynth,
			dur:1!15 ++ [0.99] => _.warpTo(p.quarters[e.start]) => _.q,
			out: Effect(CrossoverDistortion.ar(_,smooth:0.98) ).bus.index
		].pp	;
		[
			dur: 1/4 ! (4*16-1) ++ [0.24] => _.warpTo(p.quarters[e.start]) => _.q,
			instrument:\hihat,
			ffreq: Pwhite(2000,6000,inf),
			amp: Pwhite(0.1,0.03,inf) * 3,
			out: Effect(
				{ |i|
					i => FoaEncode.ar(_,~encoders.omni)
					=> FoaTransform.ar(_, 'press', LFNoise1.kr(5).range(pi,2pi), LFNoise1.kr(3.33).range(pi, 2pi),LFNoise1.kr(pi,2pi))
					=> FoaDecode.ar(_,Monitors.decoder)
				},
				inputChannels:5,
				//out:(0..4)
			).bus.index.postln
		].pp;
		[
			instrument:\bd_808,
			dur:b.q
		].p;
		[
			instrument:\sn_808,
			dur:b.q
		].p;
		[
			instrument:\openhihat_808,
			dur:b.q,
			lag:b.q/2,
			amp:2
		].p;
	});
	
	[ "(r) You dare defy one you should be on your knees wo -- rshipping? ",[-1,1, 1.5, 1, -6.5].dm(\c) ++ [1, 3, 4, 5, 3, 5, 6].dm(\d,scale: \whole) ++ [3,4,3,-5].dm(\b) ].addLine;
P.synthV(role: \thalassa, take: \lead, params: {|p b| [
		lyrics: "r you dare defy + one you should be on your knees worshipping - + +",
		// "you dare defy one you shouldd be on your knees worshipping".xsampa.cs
		phonemes: [ "","j u", "t e r\\`", "t i"," f a :\\i", "w A n", "j u", "s` U t`", "p i", "A n", "j o r\\`", "n i ts", "w a ","a r\\`", "s` i\\ ph`","ph i N"],
		// filter: (midinote: _+ 12), 
		legato: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
		pitchTake: 1,
		paramTension: 1,
		pitchExpression: 1.5
	] }, music:{|p b e|
		{
			e.playbuf
			* Env([2,2,1],b.parse([4,3])).kr(0)
			=> p.synthVTracks.at(e.key).()
		}.play
	});
P.double(role:\thalassa, take: \lead,

		filter: (midinote: _ + 12), 
		params: {|p b| [
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			*[0,1] /2
		}.play
	});
P.tune(\defy, {|i| Pset(\out,Effect(CrossoverDistortion.ar(_,drive:0.9,smooth:0.1) * 0.04).bus.index,i) => Pmul(\freq,[1,1.33]!5 => _.q ++ [1].q(inf),_)});
P.tune(\knees,{|i| Pfin(6,i) => Pmul(\freq,[4/3,4/3,4/3,4/3,4/3,1].q/2,_) => Pset(\legato,[1,1,1,1,1,6].q,_) => Pset(\out, Effect(FreeVerb.ar(_,1,1).distort * 2,out:1).bus.index,_)});
P(\bassline,start:\defy,syl:7,music:{|p b e| 
		var knees = 6.df(\d,scale:\whole);
		var be = 5.df(\d,scale:\whole);
		[
			freq: [\r, knees].q /[4]*5/6,
			dur: b.drop(1).parse([3,2]).q,
			amp:0.3,
			out:Effect({|i| Line.kr(0,1,4) * CrossoverDistortion.ar(i,smooth:0.98) => TwoTube.ar(_,  0.01, 0.98, 999, 2101)}).bus.index
		].pp
		
	});
P(\bass,start:\defy, syl: 12, music:{|p b e| 
		(lag:b[0]/2,freq:[-21,-11].df(\b),out:Effect(PlateReverb.ar(_,mix:0.8)).bus.index).play
	});
P(\crash,start:\defy, syl:12, music:{|p b e| 
		(
			instrument:\cymbalsDS,
			out:Effect({|i|
					i 
					=> CrossoverDistortion.ar(_,smooth:0.93)
					=> FoaEncode.ar(_,~encoders.spread)
					=> FoaTransform.ar(_, 'press', LFNoise1.kr(5).range(pi,2pi), LFNoise1.kr(3.33).range(pi, 2pi),LFNoise1.kr(pi,2pi))
					=> FoaDecode.ar(_,Monitors.decoder)
					* Env.linen(1,  sustainTime: 1.0,  releaseTime: 3.0,  level: 1.0,  curve: \lin).kr(2)

		}).bus.index,
		lag:b[0]/2
	).play
	});
	[ "I could destroy you with a single thought. ", [1, 2, 3, -8, -7, -8, 1, 2, -4].dm(\f, scale: \diminished) ++ [7].dm(\c,scale:\mixolydian) ].addLine;
P.synthV(role: \thalassa, take: \lead, params: {|p b| [
		lyrics: "I could destroy + you with a single + thought. ",
		phonemes: [ "a :\\i", "kh U t", "t i\\"," s t r\\` o :\\i", "j u", "w i\\ s", "@", "s i\\ N"," k @ l", "s o th th" ],
		legato: [1, 1, 1, 1, 1, 1, 1, 1, 1, 0.9],
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
P.tune(\single);
P(\bassnote,start:\single, syl:2, music:{|p b e| 
		(
			instrument:\sawSynthSustain,
			att:4,
			rel:4,
			freq: [-21,-11].df('a-'),
			out:Effect(RLPF.ar(_,XLine.kr(5000,50,3),0.2)).bus.index

		).play
	});
P(\strum,lag: -0.26, start:\single,syl:8,music:{|p b e| 
		(

			freq: [-21,-11,1,3,5,7].df(\c,scale:\mixolydian),
			strum: 0.06,
			out: Effect(
				{|i|
					EchoNone.ar(i,0.2,0.2) 
					*0.2
					=> PlateReverb.ar(_,mix:1)
					* Env.linen(0,1,b[0] + 5).kr(2)
				}
			).bus.index
		).play
	});

	[ "(McCoy is suddenly writhing in pain as he is surrounded by flames.) ","r",[11] ].addLine;
P(\swoop,start:\writhing,music:{|p b e| 
		//change chord here
		//var chord = [1, 3, 2, 7, 12].df(\e); 
		var chord = Array.fill(5,{rrand(400,800)});
		//var onsets = [0,0.666, 1.321] +.x [0,0,1,2,0.5 ] /3  => _.integrate ;
		var onsets = {0.6.rand}!8;
		//var onsets = 0!8;
		p.fireGroup = Group.new;

		{var register = [1.25,1.5,1.666].choose;
		{
			var a, freq, trig;
			a = Dseq([Dshuf( chord, 3)], inf) * 1.rrand(3);
			trig = XLine.kr(1000.rand,0.1.rand,10) => Impulse.ar(_);
			freq = Demand.ar(trig, 0, a);
			[ Saw,Pulse,LFTri,SinOsc ].choose.ar(freq/register) * 0.01 *.t [[0,1],[1,0],[0.6,0.6]].choose
			* Env.linen(0,5,12).kr(2)
			=> FoaEncode.ar(_,FoaEncoderMatrix.newOmni)
			=> FoaTransform.ar(_, 'push',pi/2,0.rrand(2*pi))
			* 3
			=> Monitors.decode(_)

		}.play(p.fireGroup)}.sched(onsets);
		( 
			freq:[1,3,5,11].df(\f,scale:\minor,octave:3),
			out:Effect({|i| 
			PlateReverb.ar(i,mix:0.8)
					//=> CrossoverDistortion.ar(_,smooth:0.98)
				=> HPF.ar(_, Env([30,30,6000],[b.sum,6]).kr(2,gate:1))
			}).bus.index,
			amp:0.2
		).play
		
	});
P(\fire2,start:\writhing,music:{|p b e| 
			    3.do { {
		    Sieve1.ar(
			    LocalBuf.newFrom([60] ++ {1-exprand(0.0001,0.9)}!10.rand ++ (0!19.rand)++( { rrand(0.01,0.99) }!12.rand ) ),  gap: [0,1,2,3,4,5],  alternate: [2, 5 ],  mul: 1.0,  add: 0.0)
			    => { |i| [i, SinOsc.ar(i * 1000,0,0.1) ]} 
			    * Env.linen(3,[3,4,5],[2,6,9]).kr(gate:1)
			    /50
			    
			    //=> Disintegrator.ar(_)
		    }.play(p.fireGroup)
	    }    
	});
	[ "MULHALL: Stop! (the flames are gone) ~Sargon was right.~ ",[1].dm(\e) ].addLine;
P(\muteFire,start:\Stop,music:{|p b e| 
		p.fireGroup.release(0.1)
	});
P.tune(\Stop);
	[ "The temptations (boom boom) in a living body are too great. ",[-6, -6, 3, 2, 1, -6, -7, -5, 5, 3, 2, 1, -7, -5, 4  ].dm(\c) ].addLine;
P.tune(\temptations);
P.synthV(role: \thalassa, take: \lead, params: {|p b| [
		lyrics: "the temptations + + r r in a living + body + are too great",
		phonemes:["t @","th e m","th e :\\i ","s` @ n ts","","","i \\n","@","l i\\","w i\\ N","p A"," t i" ,"A r\\`","th u","k r\\` e :\\i th"],
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).(2)
		}.play
	});
P(\pedalTone,start:\temptations,music:{|p b e| 
		(
			instrument:\stringyy,
			freq:[1].df(\e),
			dur:b.sum
		).play
	});
P(\chord,start:\temptations,music:{|p b e| 
		[
			freq: [\r,[4,6,11,13].df(\c), [5,7,11,13].df(\c), [4.5,5,7,12].df(\c), [2,6,11,14].df(\c) ].q,
			dur: b.parse([2,4,4,4,1]).q,
			instrument:\wash
		].pp
	});
	[ "Forgive me. ",[5,4,3].dm(\c,octave:6) ].addLine;
P.synthV(role: \thalassa, take: \lead, params: {|p b| [
		lyrics: "forgive + mi" ,
		filter: (midinote: _ - 12), 
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).(2)
		}.play
	});
P.tune(\Forgive);
P(\bassnote,start:\Forgive,syl:0,music:{|p b e| 
		(
			freq:[-1,-11].df(\c),
			out:Effect(
				{ |i| 
				PlateReverb.ar(i,mix:0.8)
					* Env.linen(0,1,6).kr(2) 
				} 
			).bus.index
		).play
		
	});
	[ "SARGON [OC]: I am pleased, my beloved. It is good you have found the truth (yourself) ",[1, 1, 1, -7, -7, -7, -6, 1, 2, 3, 4, 3, 2, 1].dm('f#') ].addLine;
P(\chords,start:\truth,music:{|p b e| 
		MegaBind(
				[
					[1,  1,  1,  -7,  -7,  -7,  -6,  1,  2,  3,  4,  3,  2,  1],

					[-1, -1, -1, -17, -17, -17, -16, -1, -2, -3, -4, -3, -2, -1],
					[-4, -4, -4, -4, -4, -2,    -2, -2,  -2, -5, -5, -5, -5, -11 ] -10		

				].df('f#'),
				b,
				[
					percScale:[0.15,0.2,0]
				],
				{|i x|
					Gendy1.arWidth(freq:i.freqSeq)
					+ Gendy2.arWidth(freq:i.freqSeq)
					* (
						Env.asr().kr(2,gate:i.gateSeq)
						+ ( Env.perc(0.1).kr(gate:(i.gateSeq * i.trigSeq)) * i.percScale )
					)
				*0.1
					=> Mix.ar(_)
					=> FoaEncode.ar(_,Song.encoders.omni)
					=> FoaPress.ar(_,pi/2,-pi/2*x,0)
				},
				{|i|
					//Splay.ar(i)
					Mix.ar(i)
					=> Monitors.decode(_)
					* 0.5
				}
				
			).play(s, p.carrierBus)
		
});
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
		lyrics: "I am pleased, my be love ed   It is good you found the truth ",
		filter: (midinote: _ - 12), 
		pitchTake: 1
	] }, music:{|p b e|
		p.vocodeTune.(p,b,e,e.rpp)
	});
	[ "MULHALL: Sargon? Where are you? I thought you destroyed by Henoch. ",[3, 1, 5, 7, 4.5].dm('b-') ++ [7, 5, 6, 7, 13, 13, 15, 14.5].dm(\g, scale:\mixolydian ) ].addLine;
P.synthV(role: \thalassa, take: \lead, params: {|p b| [
		lyrics: "Sargon? + Where are you? I thought you destroyed + by Henoch. + ",
		filter: (midinote: _ - 12), 
		phonemes: ["S A r\\`","k o n","w e r\\`", "A r\\`","j u","a :\\i","s o th","j u ","t i\\ s","t r\\` o :\\i t","p a :\\i","S A r\\`","k o n"],
/*
"Sargon? + Where are you? I thought you destroyed + by Henoch. + ".xsampa
-> [ nil, nil, w e r\`, A r\`, j u, a :\i, s o th, j u, t i\ s t r\` o :\i t, nil, p a :\i, nil, nil, nil ]
*/


		legato: [1, 0.9, 1,1,0.9,  1,1,1,1,1,1,1,1 ],
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play

	});
	[ "SARGON: I have power even Henoch does not suspect, beloved. ",[-7, 1, 5, 3, 1, 2, 4, 3, 4, 3, 2, 1 ].dm('e-') ].addLine;
P(\chords,start:\suspect,music:{|p b e| 
		MegaBind(
			[
				[-7, 1,  5, 3,  1,  2,  4, 3,  4, 3, 2, 1 ],
				[-7, 1,  5, 3,  1,  2,  4, 3,  4, 3, 2, 1 ].octaveDown,
				[\r, \_, 14, \_, \_, \_, 6, \_, 6, 5, 4, 3 ]

			].df('e-'),
			b,
			[
				percScale:[
					0.15,
					0.2,
					[ 0,1,0.5,0,0,0]
				]

			],
			{|i x|

				x.postln;
				case{ x < 2 }{
					Gendy1.arWidth(freq:i.freqSeq)
					+ Gendy2.arWidth(freq:i.freqSeq * [1,1.25,1.5,2])
					* (
						Env.asr().kr(0,gate:i.gateSeq)
						+ ( Env.perc(0.1).kr(gate:(i.gateSeq * i.trigSeq)) * i.percScale )
					)
					*0.08
					=> Mix.ar(_)
					=> FoaEncode.ar(_,Song.encoders.spread)
					=> FoaPress.ar(_,pi/2/2,-pi/2,0)
					=> AmbiVerbSC.ar(_,mix:0.2,lowRT:1)
				}{ x == 2 }{
					Saw.ar(i.freqSeq /.t [4,8] * Array.fill(4,{rrand(0.99,1.01)})) 
					* [0.5,1]
					* 0.3
					=> Mix.ar(_)
					* (
						Env.asr(0.2).kr(0,gate:i.gateSeq)
						+ (
							Env.perc(0.6,1).kr(gate:(i.gateSeq * i.trigSeq))
							* (i.percScale.dq.demand(i.dur))
						
					))
					=> FoaEncode.ar(_,Song.encoders.omni)
					=> FoaPress.ar(_,Line.kr(pi/2-0.1,pi/4,b.sum),pi/2,0)
				}{1==1}{SinOsc.ar()}
			},
			{|i|
				//Splay.ar(i)
				Mix.ar(i)
				*0.2
				=> Monitors.decode(_)
			},
			release:5

		).play(p.carrierBus);

	});
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
		lyrics: "I have power + even + Henoch + does not suspect + ",
		filter: (midinote: _ - 12), 
		pitchTake: 1
	] }, music:{|p b e|
			p.vocodeTune.(p,b,e,e.rpp)

});
	[ "MULHALL: Yec. Yes, I see. I understand. ",[4, 4, 3].dm(\f) ++ [4, 3, 6 ,4, 3].dm(\g) ].addLine;
P.tune(\understand);
P.synthV(role: \thalassa, take: \lead, params: {|p b| [
		lyrics: "yes yes i see I understand" ,
		phonemes: ["j e s","j e s","a :\\i","s i","a :\\i","A n","t a r\\`","s th a n t"],
		legato: [0.8, 0.8, 1, 0.8, 1, 1, 1, 1, ],
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play

});
P(\tune,start:\understand,music:{|p b e| 
		MegaBind(
				[
					[5,4,\r,5,\_,\r,\r,5.5],
					[3,2,\r,3,\_,\r,\r,3  ]
				].df(\c),
				b,
				[

				],
				{|i|
				Pulse.ar( i.freqSeq, SinOsc.kr(1).range(0.1,0.5), 0.1)
					* Env.asr().kr(2,gate:i.gateSeq)
					=> PlateReverb.ar(_, mix:0.5)
					=> Pan2.ar(_,SinOsc.ar(LFBrownNoise2.kr(1).range(0.5,1.5)))
					=> FoaEncode.ar(_,Song.encoders.omni)
					=> FoaTransform.ar(_, 'press',pi/4,SinOsc.ar(0.2).range(-pi,pi))
				},
				{|i|
					//Splay.ar(i)
					Mix.ar(i)
					=> Monitors.decode(_)
					* 0.3

				}
			).play
	});
	//[ "Just as we would have placed our consciousness within robots, ","r" ].addLine;
	[ "Sargon has placed his (consciousness) into (your vessel) the Enterprise. ", [13,11,5,14,13,13,12,7,5,6,4,12,11].dm('c#') ].addLine;
P.synthV(role: \thalassa, take: \lead, params: {|p b| [
		lyrics: "Sargon + has placed his (consciousness) into (your vessel) the Enterprise. ",
		phonemes: ["s A r\\`","k o n", "x a tx", "ph l e :\\i s th", "x i\\ ts","k A n","s` A th","n e s","i\\ n","th u","j o r\\`","w e s"," s @ l"],
		pitchTake: 1

	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play

	});
P(\chords,start:\Enterprise,music:{|p b e| 
		[
			freq: [[1,5,11],[4,6,11],[1,5,11],[-5,5,7]].df('c#',octave:3).q * [2],
			dur: b.parse([3,1,1,3]).q
		].pp
		
	});
P(\chords2,start:\Enterprise,syl: 8,music:{|p b e| 
		MegaBind(
				[
					[6, 4, \_, 3],
					[-5,\_,-1, \_]
				].df('c#'),
				b.drop(1),
				[],
				{|i|
					VarSaw.ar( i.freqSeq / [1], 0.2)
					* Env.asr(2).kr(2,gate:i.gateSeq)
				},
				{|i|
					Mix.ar(i)
					* 0.1
					/ 2
				}
			).play
	});
	[ "CHAPEL: Doctor. ",[11,1].dm(\e) ].addLine;
P.synthV(role: \chapel, take: \lead, params: {|p b| [
		lyrics: "Doctor! +",
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play

	});
P(\chord,start:'CHAPEL: Doctor.',music:{|p b e| 

		(
			freq:[1,3,5,11].df(\e,scale:\whole),
			instrument:\stringyy,
			amp:0.05
		).play

	});
	[ "MULHALL: Doctor, leave us. Sargon has a pla--n. We have much work to do. (boom)",[-5, -5, 1, -1,  5, 4, 3, 2, 3,4, 2,3,4.5, 4.5, 5.5, 3,-7, -6 ].dm(\f) ].addLine;
P.synthV(role: \thalassa, take: \lead, params: {|p b| [
	lyrics: "Doctor + leave us. Sargon + has a plan -. We have much work - to do. r",
	phonemes: ["t a kh", "th a r\\`", "l i w", "A s","S a r\\`","k o n","x a ts", "@", "ph l  ","a n","w i", "x a w", "m A ts h","w a r\\` kh","","th u","t u" ],
	legato: [1, 1, 1, 0.5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});


P(\bassnote,syl:3,start:\work,music:{|p b e| 
		[
			freq:[1,2].df(\f,octave:4).q,
			dur:b.drop(1).parse([5,5]).q,
			att:3.5,
			amp:0.04
		].pm(\sawSynthSustain).play
	});
P(\chords,start:\work,syl:3,music:{|p b e| 
		[
			freq: [5,5,5,5,5].df('f').q,
			dur:b.drop(1).parse([1,1,1,2,1]).q
		].pp;
	});
P(\endChord,syl:16,start:\work,music:{|p b e| 
		(
			freq: [-1,1,3,5].df(\d,octave:4),
			dur:b[1]
		).play;
		(
			instrument:\cymbalsDS,
			amp:0.03
		).play;
	});

	//[McCoy's office]
	["(McCoy leaves the room, and the door shuts and locks behind him. The ship shakes as he activates his desk monitor.) MCCOY: This is Sickbay. Get me ","r"].addLine;

	["(The door opens, and Chapel walks out, staring blankly ahead.) MCCOY: Nurse Chapel, what in the devil?","r"].addLine;
	["","r"].addLine;
	["//[Sickbay]","r"].addLine;
	["(He goes back into the ward.) MCCOY: Jim? Are you all right? ","r"].addLine;
	["KIRK: Yes, I'm fine, Bones. ","r"].addLine;
	["MCCOY: Thalassa? ","r"].addLine;
	["MULHALL: She is now with Sargon, Doctor. ","r"].addLine;
	["I`m Ann Mulhall, back in my own body. ",[-5, 3, 3, 2, 3, 2, 3, 4, 3, 2].dm(\g), ].addLine; // a= Song.durs['back in my'].list
P.tune('own body');
P.synthV(\feng, take: \lead, 
	pbind:{|p b|
		[
			dur: Song.durs['back in my'],
			midinote: Song.tune[Song.section('back in my')]
		].p
	},
params: {|p b| [
	lyrics:"I'm Ann Mulhall + back in my own body +",
		// lyrics: "aim jain mul hal bak in mai on ba dy" ,
		//lag: [0,0,0,0,-0.06,0,0,0,-0.05,-0.05],
		lag:[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ],
		legato: [1,1,1,0.9, 1,1,1,1,1,1],
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf 
			// => FreeVerb.ar(_,0.5,[0.8,0.9])
			=> p.synthVTracks.at(e.key).()
		}.play
	});
P.double(\feng, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
	Song.quarters['own body']=Song.parseBeats('own body',[2,2,2,2,1,1, 1, 1, 2, 2]);
P(\bass,start:'own body',music:{|p b e| 
		Synth(\cymbalsDS,[out:Effect(_*Line.kr(1,0,5)).bus.index,amp:0.01]);
		[instrument:\hihat,dur:1!15=>_.warpTo(Song.quarters['own body'].quantizeWindow)=>_.q].pp;
		MegaBind(
			[
				[11, 3, 4, 7, 11, 4.5, 7]
			].df(\g, octave:3),
			[3,1,3,1,3,1,3]=>_.warpTo(p.quarters[e.start]);
			,
			[],
			{|i|
				Saw.ar( i.freqSeq,  0.1 )
				+
				Saw.ar( i.freqSeq/2.01,  0.1 )

				* 
				(
					Env.asr().kr(gate:i.gateSeq)
					+
					Env.perc().kr(0,gate:i.trigSeq, levelScale: 0.1)
					/2
				)
			},
			{|i|
				Mix.ar(i) /18
				=> EchoNone.ar(_,0.3,[ b.sum/8,b.sum/6 ],2) 
			}
		).play;
		[dur:"..x...xx..x...xx".asDrumPat(1),instrument:\sn_808].p.play(TempoClock.newFromQuarters(p.quarters[e.start]));
		[dur:"x...x...x...x...".asDrumPat(1),instrument:\bd_808].p.play(TempoClock.newFromQuarters(p.quarters[e.start]))

	});
P(\answer,start:'own body',syl:7,music:{|p b e| 
		MegaBind(
			[
				[3, 2, 3, 4].df(\b)
			],
			[1,1,1,1]/2 => _.warpTo(p.quarters[e.start][[5,6,7]]) 
			* 2,
			[],
			{|i|
				LFTri.ar( i.freqSeq ) 
				* Env.asr().kr(gate:i.gateSeq)
			},
			{|i|
				Mix.ar(i) /30 
				=> EchoNone.ar(_,0.2,0.2,5)
				=> Pan2.ar(_,SinOsc.kr(0.7))
		//		=> CrossoverDistortion.ar(_).wet(0.09) / 3
				* Env.linen(0,2,3).kr(2,gate:1)
			}
		).play
	});
	["(Then we see the three blackened and broken spheres.) ",[1,2].dm(\f),[3,3]].addLine;
P(\clang,start:'broken',music:{|p b e| 
		(
			[
				freq: [\f,\g,\a].collect{|i| [-21,-11].df(i)} => _.q,
				out: Effect( { |i| PlateReverb.ar(i)  * Env.linen(0,b.sum,4).kr(gate:1)}).bus.index,
				dur: b ++ [1] => _.q
			].pp
			
		)
	});
	["MCCOY: Jim, the receptacles. Spock's consciousness was in one of them. ",[3,2,1,5,4,3].dm(\g) ++ [2, 5, 4, 3, 1].dm('a-',scale:\whole) ++ [11, 6, 4, 2].dm(\f,scale:\minor)].addLine;
P.tune(\receptacles);
	["KIRK: (boom) It was necessary. ",[-2, 5, 5, 11, 5, 3, 1].dm(\c,scale:\minor)].addLine;
P.tune(\necessary);
	["MCCOY: What are you talking about? There is no Spock to return to his body. (boom) You've ",[-7, -7, 1, 2, 3, 2, -6, -7,  2, 1, 5, 6, 5, 4, 3, 4, 5, 5, 4].dm(\d, scale:\mixolydian) ++ [-5, 5].dm('b-',octave:4)].addLine;
P.tune(\talking);
P(\dyad,start:\talking,music:{|p b e| 
		[
			freq:[\r, [3,5],\r, [1,3, 6],\r, [2,6] ].df(\d, scale:\mixolydian).q,
			instrument: \sparkTriangle,
			dur: b.parse([4,3,4,3, 3,2]).q,
			amp: 0.03,
			out: Effect({|i| 
				FoaEncode.ar(i,Song.encoders.omni) 
				=> FoaPush.ar(_,0.8,-pi/4)
				=> FoaDecode.ar(_,Monitors.decoder)}
			).bus.index
		].pp
	});
P(\bass,start:\talking,music:{|p b e| 
		[
			freq: [-7, 3, 1, 2, 2.5].df(\d,scale:\mixolydian, octave:[3,4]).q,
			dur: b.parse([4, 7, 6, 2]).q,
			instrument:\stringyy,
			release:2,
			legato:1,
			amp:0.25

		].pp
	
	});
	["killed a loyal officer,(boom) your (boom) best friend. ",[11,5,11,12,13,12,11,7].dm('b-',octave:4) ++ [-1,5,-4,6,7].dm(\a,scale:\mixolydian, octave:4)].addLine;
P(\bassMirror,start:\loyal,music:{|p b e| 
		[
			freq: [1, -7, -6, -7, 1].df('b-', octave:[3,4]).q,
			dur: b.parse([3, 1, 1, 1, 2]).q,
			instrument:\sawSynthSustain,
			amp:0.07,
			lagTime:0.1
		].pm(\sawSynthSustain).play
		
	});
P.tune(\loyal);
P(\bass2,start:\loyal,syl:7,music:{|p b e| 
		[
			freq: [2,\r, 5,\r, 1].df(\g,octave:3).q ,
			dur:b.drop(1) ++ [ p.durs[e.start+1].list[0] ] => _.q,
			instrument:\sawSynth
		].pp
		
	});
P(\chord,start:\loyal,syl:11,lag:-0.05, music:{|p b e| 
		(
			strum:0.06,
			freq: [1,3,5,11].df(\g,scale:\minor)
		).play
	});
	["KIRK: (boom ba boom ba) Bones, prepare a hypo. The fastest, deadliest poison to Vulcans. ",[-5, -5, -5, -5, 5, 5, 5, 5, 11, 5, 12,  ].dm(\b,octave:4) ++ [12,13,12,5, 13,14,13,6, 14,15,14,5,11,7].dm(\c)].addLine;
P.tune(\prepare);
P(\lick,start:\fastest,syl:10,music:{|p b e| 
		[
			freq: [\f,'f#',\g].collect( [2,4,7].df(_) ) => _.flat => _.q / 2,
			dur: b.drop(1).q
		].pp
	});
	["(boom boom) Spock's consciousness is-- gone. We must kill his body, the thing in it.",[-1, -3, 3, 4, 4, 4, 3, 2, 2].dm(\a) ++ [2, 3, 6, 7, 11, 5, 11, 12, 11, 5].dm(\e)].addLine;
P(\figure,start:'kill his body',music:{|p b e| 
		[
			freq: [1, 3, 5, 1, 4, 6, 11, 3, -7].df(\a).q / [1,2],
			dur: b.parse([1, 1, 0.5, 0.5, 1, 1, 1, 2, 1, 1]).q,
			instrument:\sawSynth,
		].pp
		
	});
P(\bass,start:'kill his body',syl:12,music:{|p b e| 
		[
			freq: [1, 11, 1].df(\e).q /[ 4],
			dur: b.drop(1).parse([ [1, 1/2],[1/2, 1], 1 ]).q,
		].pma(\default).play;
	});
P(\chords,start:'kill his body',syl:1,music:{|p b e| 
		
		[
			freq:[[1, 5],[1, 5],[1, 5],[1, 5],[1, 5],[-7,4.5]].df(\a).q,
			dur:b.drop(1).parse([1,1,1,1,2,1]).postln.q
		].pp
	});
P.tune('kill his body',_.drop(2),syl:1);
P(\guiro,start:'kill his body',syl:11,music:{|p b e| 
		//FIXME!!!!!
		
			{Shakers.ar(19, 1, 1, 1, 32, 60, Env([0,0.5],1,\sin).kr(0,1))}.play
		
	});
P(\chords2,start:'kill his body',syl:12,music:{|p b e| 
	[
		freq: [
			[1,3,5,11],
			[1,3,5,11],
			[2,4,6,12],
			[1,3,5,11],
		].df(\e,scale:\minor).q,
		dur: b.drop(1).parse([2,1,1,2]).q,
		strum: [5, 0.5, 2, 1]/100 => _.q
	].pp

	
});
};
)
