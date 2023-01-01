

//Briefing Room
(
s.waitForBoot { 
	Song(\briefing,[]).current;

[ "SCOTT: You're going to what?","r" ].addLine;
[ "Are they all right in the head, Doctor? ","r" ].addLine;
[ "MCCOY: No comment. ","r" ].addLine;
[ "KIRK: A simple transference. Their minds and ours. ","r" ].addLine;
[ "MCCOY: Quite simple. Happens every day. ","r" ].addLine;
[ "KIRK: Scotty, I need your approval, too. Since you'll","r" ].addLine;
[ "work with them, furnishing them all they need to make the android robots. ","r" ].addLine;
[ "You won't be working with them, you'll be working with us, our bodies.","r" ].addLine;
[ "They'll be inside us, and we'll be ...","r" ].addLine;
[ "MCCOY: It all seems rather indecent to me. ","r" ].addLine;
[ "MULHALL: I'm not so certain of that, Doctor. It is scientifically fascinating. ","r" ].addLine;
[ "SPOCK: (boom) Once inside their mechanical bodies, engineer, they can leave this planet,"," -1 1 2 3 2 3 4 3 2 3 1 -5 -6 -5 5 4 3 2 4 3 ".dm('a-', octave:4)].addLine; 
P.tune();
Song.setTempoMap(\mechanical,"q e e q e e q e e e e e e ee e e Q E Q E ");
P(\click, music: { |p b e|
	[
		instrument: \hihat,
		dur: 1!32 warpTo: e.tempoMap => _.q
	]
	//.pp
});
Song.mechanicalBass = {
	|i|
	Pulse.ar(i.freqSeq / [1,2] * SinOsc.ar(4).range(0.999,1.001),0.1,0.1) 
	* [0.3,1]
	=> Mix.ar(_)
	* Env.asr().kr(2,gate: i.gateSeq)
	+ Env.perc().kr(0,gate:i.gateSeq * i.trigSeq)
	=> MoogVCF.ar(_, fco:i.freqSeq*15 * i.gateSeq=>_.lag2(0.5), res:0.2, mul:1, add:0)
	=> {|i| [i,Silent.ar(numChannels:1),Silent.ar(numChannels:1),0.2 * DWGReverbC1C3.ar(i, len:2000, c1:1, c3:10, mix:1, coefs:nil, perm:nil, doprime:0)]}
	/ 2
};
P(\bass, music: { |p b e|
	MegaBind(
		[
			[1, 5, 1, 5, 1, 6, 1, 5, 1, -7, -6.5  ]
		].df('a-',3)
		,
		"e eq e eq e eq e eq qq qE Q".asBeats.warpTo(e.tempoMap),
		[ ],
		p.mechanicalBass
		,
		{|i|  Mix.ar(i)}
	).play
});
[" travel back with us.","3 4 4 5 3 2 1".dm(\c) ].addLine;
P.tune();
P(\bass, music: { |p b e|
	MegaBind(
		[
			[6, 3]
		].df('a-',2)
		,
		b.parse([ [ 3, 0.33 ],4 ]),
		[ ],
		p.mechanicalBass,
		{|i|  Mix.ar(i)}
	).play
});
[ "With their knowledge, mankind could leap ahead ten thousand years. ","r" ].addLine;
[ "KIRK: Bones, they'll show us medical advances,","r" ].addLine;
[ "miracles you never dreamed possible.","r" ].addLine;
[ "Scotty, engineering advances.","r" ].addLine;
P.tune(\engineering);
P('test2',start:\engineering,music: {|p b e|
	{
		a = RecEnv(\test2,\engineering)//.arm
		.playbuf.()
		* Gendy1.arWidth(freq:445)
	}.play
});
//P(\test,start:\engineering,music:{|p b e| 
//	fork{
//		20.do( { {
//			RecEnv("20220515_092223", length:4, durs:[1,1,1,1]/0.5.rand)
//			.playbuf.().lag(0.1)  * [Pulse, Saw ].choose.ar(400 * 12.rand.midiratio * [1,2.5,4.5,1.135,6,12])
//			=> SoftKneeCompressor.ar(_,thresh:-50,ratio:1/10,makeUp:0)
//			* Env([1,1,0],[ 4,8 ]).kr(2,gate:1)
//		}.play;
//		3.wait }
//		)
//	}
//});
[ "Vessels this size with engines the size of walnuts. ","r" ].addLine;
[ "SCOTT: Ach! You're joking. ","r" ].addLine;
[ "SPOCK: No, he's not. ","r" ].addLine;
[ "MCCOY: They're giants, and we're insects beside them. "," -5 3 2 1 3 4 3 1 3 2".dm(\d) ].addLine;
P.tune();
[ "They could destroy us without meaning to. ","r" ].addLine;
[ "And all he wants is the body of our captain and our second in command, too. Coincidence? ","r" ].addLine;
[ "KIRK: They selected us as the most compatible bodies. ","1 2 3 4 5 4 3 7 11 6 5 4 6 5".dm(\d,5,\mixolydian) ].addLine;
//// add a boom before "Most"
P.tune(\selected);
P(\bass,start:\selected,music:{|p b e| 
	[
		freq: [1, 5, -7, -5, -6, -6.5, -4, 2, ].df(\d,[3,4]).q,
		dur: b.parse([ 2/3, [1/3,1], 2, 1, 2, 2, 3, 2  ]).q
	].pp
	
});
P(\chords,start:\selected,syl:6,music:{|p b e| 
	[		
		midinote: 
		[ 
			"3 5 11".dm(\c), "2 5 7".dm(\c),"1 3 6".dm(\d)  ].q
		,
		dur: b.drop(1).parse([2,3,2]).q, 
	out: Effect(FreeVerb.ar(_,0.6,[0.9, 1 ])).bus.index,
	strum:0.054
].pp
});

[ "MCCOY:(boom boom boom boom) What's your attitude on that, Doctor? ", [ -1, -1, -17, -17, -5, 3, -7, 1, -7, -5, 3, 2, 1 ].dm(\a,5,\mixolydian) ].addLine;

P(\bass,start:\attitude,music:{|p b e| 
	MegaBind(
			[
				[11, 11, 7, 7, 11, 1].df(\a,3,\mixolydian)
			],
			b.parse([1,1,1,1,5,4]),
			[],
			{|i|
				Pulse.ar( i.freqSeq * [1,2.01,3.0201] /4 )
				* (
					Env.asr().kr(gate:i.gateSeq)
					//+ Env.perc().kr(0,gate:(i.trigSeq*i.gateSeq))
				)
				=>MoogFF.ar(_,Env.perc(0.01,0.5).kr(0,gate:(i.trigSeq*i.gateSeq))*4000+1000,0.4)
				* 0.06
			},
			{|i|
				Splay.ar(i) 
				*2
				=> FreeVerb.ar(_,0.3,1)
				=> _.tanh
				/2
			}
		).play
});

P.tune(\attitude,_ <> [rest:[\,\,\,\,1,1,1,1,1,1,1,1,1].q].p);
// ["MULHALL: Well, if we all agree, I'm willing to host Thalassa's mind.","r"].addLine;
//[" ( boom x 7 ) I'm a scientist.  ( boom x 7 ) and I'm","3 4 6 5 7 3 4 11 12 13 14 13 5 3 4 6 5 7 3 4 5 15  ".dm(\b)].addLine;g
[" ( boom x 7 ) I'm a scientist.  ( boom x 7 ) and I'm","3 4 6 5 7 3 4 11 7 11 12 11 3 3 4 6 5 7 3 4 5 15  ".dm(\b)].addLine;

Song.synthVTracks=EventWithDefault(
	\default, {
		{
			|i|
			var early = 0.5;
			var dryAmount = 1;
			EarlyRef.ar(i, source:[2,3,2], receiver:[0,0,0], roomsize:[4,5,6], hw:0.2, b:0.97, n:0, p:0, allp_lens:nil, allp_c:0.7)

			=> DWGReverbC1C3.ar(_, len:2000, c1:1, c3:10, mix:1-early,)
			+ ( i * dryAmount )
			/ 6 
			=> HPF.ar(_,100)
			=> DCompressor.ar(_, sidechainIn:0, sidechain:0, ratio:4, threshold:-40, attack:0.1, release:100.1, makeup:0.5, automakeup:1)
		}
	}
);
Song.setQuarters(\scientist,"q q q q qqqq q q q e e ee e eqq q q q q qqqq q q q q".asBeats);
P.synthV(\feng,  filter: (midinote: _ - 12),  params: {|p b| [
	lyrics: "r r r r r r r I'm a sigh - entist + r r r r r r r and I'm",
	vocalMode: \Opera
] }, music:{|p b e|
	{
		e.playbuf
		  => p.synthVTracks.at(e.key.postln).()
	}.play
});
P.double(\feng, filter: (midinote: _ - 12), music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}
	// .play
});
//P.click(\scientist);
// P.tune(\scientist, _ <> [rest:[\,\,\,\,\,\,\,1,1,1,1,1,1,\,\,\,\,\,\,\,1,1].q].p);
P(\jank,start:\scientist,music:{|p b e| 
	
	[
		freq: [\r,7, 11, 7].df(\b,[2,3]).q,
		dur: "qqqq qqqqqqqq qqqqqqqq qqqq".asBeats.warpTo(p.quarters[e.start]).q ,
		amp:0.4,
		coef:0.8,
		del:0.7,
		smooth:0.25,
		instrument:\pluckDEnvPan,
		pan: Prand([-1,1],inf),
		legato: 0.125,
		release:1.3,
		out: Effect(
			{ |i| CombN.ar(i,1,(p.quarters[e.start].list.mean),4)
			      + i
			      *0.1*0.4
		      } ,
		      inputChannels:2
		).bus.index
	].pp
});
P(\lead,start:\scientist,music:{ |p b e|
MegaBind(
		[
			[3,  4,  6,  5,  7,  \r, \r, \r, \r, \r] .dup(2).flat,
			[\r, \r, \r, \r, \r, 3,  4,  6,  5,  11].dup(2).flat
		].df(\b,3),
		p.quarters[e.start].list.parse([1,1,1,1,4].dup(3).flat),
		[ 
			lag: { 0.5.dup(8)
			.put(0,0)
			.dq }
		],
		{|i|
		Saw.ar( i.freqSeq.lag( i.lag.demand(i.dur)) ,0.1 )	
		*( Env.asr(0.1, 1, 2).kr(0,gate: i.gateSeq)
		   + Env.perc(0.01, 0.23).kr(0,gate: i.trigSeq * i.gateSeq)
		)
		=> ( CombC.ar(_,1,
			//envelope of delay mod
			Env([0, 0, 1, 1], i.dur.parse([4],2)).kr(gate:1)
			* SinOsc.kr(2).range(-0.002,0.002)+0.2,
			10
		) *0.4  + MulAdd(_,0.8)
	)},
		{|i|
			Splay.ar(i).distort
			// => Mix.ar(_) 
			=> Pan2.ar(_,0)
		}
	).play
});
[" willing I'm willin I'm willing I'm", "14 13 11 13 12 5 14 13 11".dm(\b)].addLine;
P(\cymbal, music: { |p b e|
	(
		instrument: \cymbalsDS,
		amp:0.06

	).play
});
P.synthV(\feng, prepend:true, filter: (midinote: _ - 12),  params: {|p b| [
	lyrics: "willing + I'm willing + I'm willing + I'm ",
	lag: [0.06,0,0,0,0,0,0,0,0],
	legato:[1,0.9,1,1,0.9,1,1,0.9,1],
	vocalMode: "Opera"
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}//.play
});
P.double(\feng, prepend:true, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}
	.play
});


//Song.durs['willin ']=Song.durs['willin '].list * 0.9 => _.q;
Song.setQuarters('willin ', "qe eqe e qe eqe e qe eqe e ");
//Song.vocalWill=VocalRPP(\willin,\vocal1);
//P('vocal',start:\willin,rpp:VocalRPP(\willin,\vocal1),lag:-1,music: {|p b e|
//)
P('vocal',start:\willin,rpp:VocalRPP(\willin,\vocal1),lag:-1,music: {|p b e|
	e.rpp.buffer.() =>
	{ |i|
		{
			PlayBuf.ar(numChannels:2, bufnum:i.bufnum, rate:1.0, trigger:1.0, startPos:0.0, loop:0.0, doneAction:0)
			* Env([0,0,1,1],[0.8,0.1,10]).kr(2,gate:1)
			=> HPF.ar(_,200)
			=> SoftKneeCompressor.rms(_, control:nil, thresh:-5, ratio:8, knee:6, attack:0, release:0.05, makeUp:0, rms:40)
			=> BPeakEQ.ar(_, freq:1200.0, rq:1.0, db:16.0, mul:1.0, add:0.0)
			=> SineShaper.ar(_,0.2,2)
			=> BHiShelf.ar(_, freq:1800.0, rs:1.0, db:6.0, mul:1.0, add:0.0)
			=> DWGReverbC1C3_16.ar(_, len:2000, c1:1, c3:10, mix:0.15, coefs:nil, perm:nil, doprime:0)
			//=> Decimator.ar(_, rate:44100.0, bits:6, mul:1.0, add:0)
			* [0.5,0.3]
			*[0.3,1] /1.4 //make room for feng!!
			/4.5
		}
		.play
	} 
});
P(\cymbal,start:'willin ',music:{|p b e| 
(instrument:\cymbal,amp:1,length:4).play	
});
//P.click('willin ');
P.tune('willin ', _ <> [instrument:\stringyy,amp:0.7].p);

( Song.willingDrum={| length = 12 p b e out |
	var subdivisions = (snare: 4, kick:2);
	out.isNil.if{out = Song.willingBus};
	Ppar( [
		[
			instrument:\kick,
			amp:0.5,
			dur:"x0x0|x0x0|xx0x|xxxx".asDrumPat(subdivisions.kick,inf),
		].p,
		Pfxb(
			Pbind(*[
				instrument:\snare,
				dur:"0000x000|0000x000|0000x00x|0000x00x".asDrumPat(subdivisions.snare,inf),
				amp:0.40
			]),
			\dst
		),

		[
			instrument:\hihat,
			amp:Pseq([0.1,0.2],inf)*Pwhite(1,1.2,inf),
			dur:"xxxx".asDrumPat(8,inf)
		].p
	] ) => Pfindur(length,_) 
	=> Pset(\out,out,_)
	=>_.play(e.quarters.list  => _.asTempoClock)
};
Song.willingBus=Bus.audio;
);
P(\drums,start:'willin ',music:{|p b e| 
	fork{
		{In.ar(p.willingBus)}.play.dur(b.sum);
		//0.01.wait;
		Song.willingDrum.(12, p, b, e )
	}
});
P(\bass,start:'willin ',music:{|p b e| 
	[

					root:-1,
					degree: 8.dup(8)++2.1.dup(4)++5.dup(4)=>_.flatten=>_.q(inf)-1,
					octave:2,
					out:[0,1],
					smooth:Pwhite(0.2,0.3,inf),
					del:Pwhite(0.5,1,inf),
					dur:0.25,
					coef:Pbrown(0.1,0.9,0.03),
					lag:Pwhite(-0.01,0.01),
					dur: 0.5,
					amp:0.05
	].pm(\pluckD).fin(24).play(TempoClock.newFromQuarters(p.quarters[e.start]))
});
P(\bassDouble, music: { |p b e|
	
	[

					root:-1,
					// amp: 0.06,
					dur: 0.5,
					degree: 8.dup(8)++2.1.dup(4)++5.dup(4)=>_.flatten=>_.q(inf)-1,
					octave:2,
					out:[0,1],
					instrument: \sawSynth
	].p.fin(24).play(TempoClock.newFromQuarters(p.quarters[e.start]))
});
P(\oldArr,start:\willing,music:{|p b e| 
	
	//b=Pdef(\m,Pfxb(a,\phaserr,\fb,-0.99));
	c=Pseq([a,b],inf);

				// 'guitar-ish' //		

				//~synthsLoaded ?? {"~/tank/super/song-Synthdefs.scd".standardizePath.load};

			

				[
					degree:[3,4,6,5,7,3,4,6,5,8].q-1,
					root:-1,
					dur: [1.dup(4)++4].flatten.q(12)/4,
					octave:4,
					amp:0.3
				].p
				=> Pdef (\lick,_);

				//.play;

				Pdef(\boodoo,Pbind(*[
					//instrument:\sawSynth,
					att:0,
					degree:Pseq([1,2,3,5,4,2,1],inf)-1,
					dur:Pseq([1,1,1,1,8,8,12]/4,inf),
					root:7,
					octave:2,
					amp:0.6
				])).quant([16,7])
				;
				Pdef(\boodoo);//.play;
				//t=TempoClock.new.tempo_(88.bpm).permanent_(true);
				//t.tempo_(45.bpm);

				//p=PF.new;
				t=(Song.quarters[\scientist].list/2 =>_.asTempoClock);
				//t.tempo
				Ptpar([ //		
					0,Pdef(\m),
					//2,Pdef(\lick),
					0,Pdef(\q),
					0,c,
					0,Pdef(\f),
					0,Pwrand([Pdef(\a),(note:Rest,dur:8)],[0.7,0.3],inf), //guitar
					//Pseq([(note:Rest,dur:7+16),Pdef(\boodoo)]),
				]
			)
			//.play(t)

});
["willing la laaa la", " 13 12 11 7 6".dm(\b,5)].addLine;
Song.setQuarters('la laaa', "qe eqe e qe qq");
P.synthV(\feng, filter: (midinote: _ - 12),  params: {|p b| [
	lyrics: "willing + I'm willing +",
	vocalMode: \Opera
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(\feng, filter:(midinote:_), music:{ |p b e| 
	{
		e.playbuf
	}.play
});
P(\drums,start:'la laaa',music:{|p b e| 
	fork{
		{In.ar(p.willingBus)}.play.dur(b.sum);
		p.willingDrum.(8, p, b, e)
	}
});
P(\setClock,start:'la laaa',music:{|p b e| 
});
P.click('la laaa');
P.tune('la laaa');
P(\bass,start:'la laaa la',music:{|p b e| 
	[

		freq: [-2.5,-2.5,-2.5,-2.5,-5,-5,-5,-5, -6, -6, -6, -6, -6, -6, -6, -6].df('b',2).q,
					outs:[0,1],
					smooth:Pwhite(0.2,0.3,inf),
					del:Pwhite(0.5,1,inf),
					dur:0.25,
					coef:Pbrown(0.1,0.9,0.03),
					lag:Pwhite(-0.01,0.01),
					dur: 0.5,
					amp:0.05
	].pm(\pluckD).fin(24).play(TempoClock.newFromQuarters(p.quarters[e.start]))
});
Song.mindKey = 'e-';
["to host Thalassa's mind",[4,3,5,4,3,7, 2, 3, 4,5, 6].dm( Song.mindKey, 6, \mixolydian)].addLine;
P.synthV(\feng, params: {|p b| [
	lyrics: "to host thalassas + + mind",
	vocalMode: \Opera
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(\feng, filter: (midinote:_-12), music: {|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
}
);
// Song.durs['to host']= Song.durs['to host'].list.dropLast(1).q;
Song.setQuarters('to host',"E Q E Q E Qqe e e x x ".asBeats);
P.tune('to host', _.fin(6));
P(\lick,start:'to host',syl:5,music:{|p b e| 
	[
		freq: [2,3,4,5,6].df(p.mindKey, [5,6]).q,
		dur: b.drop(1) ++ 1 =>_.q,
		amp:0.4,
		instrument:\stringyy
	].pp
});
P(\drumFade,start:'to host',music:{|p b e| 
	{In.ar(p.willingBus) * XLine.kr(1,0.001,b.sum)}.play.dur(b.sum);
	p.willingDrum.(3, p, b, e)
});
P(\chords,start:'to host',music:{|p b e| 
	[
		freq: [\r, [-6,1],-2, [-15, 2, 4, 7], [-11, 1, 3, 6]  ].df(p.mindKey, 5, \mixolydian).q,
		dur: b.parse([1,2,2,5,1]).q,
		instrument:\sawSynthSustain,
		strum:[0,0,0,0.05, 0.05].q,
		legato:[1,1,1,1,4].q

	].pp;
});

Song.opportunityKey='b';
["The opportunity is an extraordinary one ","-1 3.5 3.5 3.5 3.5 2 2 1 2 3 5 4.5 2 1 -7.5".dm(Song.opportunityKey,6,\minor)].addLine;//p14
P.synthV(\feng, filter: (midinote: _ - 12),  params: {|p b| [
	lyrics: "r the opportunity + + + + is an extrordinary + + + + one",
	vocalMode: \Opera
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\chords,start:\extraordinary,syl:0,music:{|p b e| 
	MegaBind(
			[
				[1, 1, 1, 1, -7, -7],
				[-5, -5, -5, -5, [-4.5,-5].choose.dup ].flat
			].df(p.opportunityKey),
			b.drop(1),
			[],
			{|i|
				Saw.ar( i.freqSeq  ) 
				* 
				(
					Env.perc().kr(gate: i.trigSeq)
					+ Env.asr().kr(gate:i.gateSeq)
				)
			},
			{|i|
				Splay.ar(i)
				*0.1
			}
		).play
});
P(\chord,start:\extraordinary,syl:13,music:{|p b e| 
	(
		freq: [-5,1,3].df(p.opportunityKey,4) * (-5).midiratio,
		instrument:\sawSynthSustain,
		dur:b.parse([6]),
		att:0.5
	).play
});
P.tune(\extraordinary, _.drop(1),syl:0);
//P.click(\extraordinary);
Song.setQuarters(\extraordinary, "e x xe x xe x xqe x xe x xe x xe x xe");
//Song.setQuarters(\extraordinary,"e x xe x xe xqe xe xe xe xe".asBeats)	;
P.click(\extraordinary);
P(\bass,start:\extraordinary,music:{|p b e| 
	[
		freq: [ 11, 7, 6.5, 6].df(p.opportunityKey, [ 3,4 ]).q,
	dur: e.quarters.list.parse([2,2,2,2]) 
		+ [ 0,0,0, p.durs[e.start +1].list.parse([5])] => _.q,
		legato: [1,1,1,1].q,
		instrument: \sawSynthSustain
	].pp
});
[" for experimentation, observation. ","2 3 4 5 -6 1 1 -7 5 5 4 3 3 2  1".dm('f#',6)].addLine;//p14ngyy
P.synthV(\feng,filter: (midinote: _ - 12),  params: {|p b| [
	lyrics: "for experimentation + + + + + - obser + - vation + - -",
	vocalMode: \Opera
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\bass,start:\experimentation,music:{|p b e| 
	[
		freq: [\r, 12, 15, 12].df(p.opportunityKey,2).q,
		dur: b.parse([5,6, [1,1,0.5], [0.5,1]]).q,
		instrument:\sawSynthSustain
	].pp;	
});
P.tune(\experimentation);
["SCOTT: A starship engine the size of a walnut? Thats impossible! "," 2 3 1 -7 -6 -5.5 4 3 4 5 -7".dm(\a) ++ "5 5 11 5 1".dm('a-',5)].addLine;
Song.impossibleCurve=TempoMap("e e e E E E e x x e e qe e E E E q".asBeats,Song.durs[\impossible].list);
P.tune(\impossible);
P(\chord,start:\impossible,syl:0,music:{|p b e| 
	(
		freq:[1,3,5.5,7].df(\f),
		instrument:\stringyy
	).play
});
P(\bass,start:\impossible,music:{|p b e| 
	[
		freq: [\r] ++ "5 -5 4  3 -3 2".df(\a,3) ++ "5 1".df('a-',3) =>_.q,
	dur:p.impossibleCurve.mapBeats(  "e eee e exx e e q ee e ".asBeats).q,
	out: Effect( SineShaper.ar(_,limit:0.05) * 2, inputChannels:2).bus.index,
	legato: [1,1,1,1,1,1,1,1,1.5].q
	].pp//.findur(b.sum)
	//.play
});
//["But I don't suppose there'd be any harm in looking over diagrams on it. ","r"].addLine;
["KIRK: Bones? You could stop all this by saying no. ",[7].dm(\b,4,\mixolydian) ++ [3,4,7,4,3,2,3,4].dm(\c,5,\mixolydian) ++ [5].dm(\a,4)].addLine;
P.tune('stop all this');
P(\double,start:'stop all this',syl:0,music:{|p b e| 
	p.tune[e.start].list[1..].dropLast
	=> { |i| [
		midinote: i.q - [ 12, 24 ],
		dur: b.drop(1).q,
		rel: [2,2,2,2,2,2,2,4].q,
		legato: [1,1,1,1,1,1,1.1,1.1] - 0.1 =>_.q,
		instrument:\sawSynthSustain,
		amp:0.065


	].pma(\sawSynthSustain).play } 

});
P(\chord,start:'stop all this',music:{|p b e| 
	[
		//freq: [1,3,5,7].df(\b,4,\mixolydian),
		//freq: [ [1,3,4.5,7].df(\b,4,\mixolydian), \r, [1,3,5,11].df(\a,4,\minor) ].q,
		freq: [ [-1 ,1,3,5,7].df(\b,4,\mixolydian), \r, [-1, -7, 1,3,5].df(\a,4,\minor) ].q,
		dur: b.parse([1, 8, 1]).q,
		strum: [ 0.055, 0, 0.04 ].q
	].pp
});
["That's why-- I called you all here together. ","2  2 3  -6  3 4  4 5 2 5  5 6 6 7 6".dm('e-',5,\lydian)].addLine;
P.tune('here together');
P(\bass,start:'here together',music:{
	|p b e| 
	[
		freq: [ \r, 1, 2, 3, -7, 1, -1 ].df('e-',[3,4],\lydian).q,
		dur: b.parse([1, 3, 2, 2, 1, [ 4,0.67 ], [0.33, 1 ]]).q
	].pp
}
);	
["(boom) We'll all be deeply involved. It must be unanimous. ","-1 12 13 12 12 11 7 6".dm(\c) ++ "2 6 5 4 3 4 1 -6".dm('f#')].addLine; //p11
P.tune(\involved, Pmul(\freq,[1,2],_));
Song.quarters[\involved] = Song.parseBeats(\involved,[1, 1/2, 1, 1/2, 2/3, 2/3, 1/3, 1/3, 3/2, 1/2, 2/3, 2/3, 2/3, 1/2,1/2,1]);
Song.setTempoMap(\involved,[1, 1/2, 1, 1/2, 2/3, 2/3, 1/3, 1/3, 3/2, 1/2, 2/3, 2/3, 2/3, 1/2,1/2,1] );
//P.click(\involved);
P(\hat,start:\involved,music:{|p b e| 
	[
		dur: e.tempoMap.mapBeats("ee e x x q e e x x x x q q q e x x ee e".asBeats).q,
		instrument: \hat_808,
		out: Effect.bus({|i|  EchoNone.ar(i,1, delaytime:0.5) + WhiteNoise.ar(0.00011)    })
	].pp;
});
P(\bass,start:\involved,music:{|p b e|  // passing tone right before end please
	[
		freq: [1, 1,1, 1.5, 2.5, 4.5].df(\c,3).q,
		dur: b.parse([ [1, 1, 0.5],[0.5, 1],[ 1,1,1,1],  [1,1,1, 1/3],[2/3,1], 3 ]).q,
		out: Effect({ |i| SineShaper.ar(i, 0.2) *5 * Env.linen(0.001,b.sum,1).kr(2,gate:1) }, out:[0,1]).bus.index ,
	].pp; 
	
});



P(\chords,start:\involved,music:{|p b e| 
	var oneM7 = [3,5,7];
	var four6 = [-6, 1, 4];
	var six = [-6, 1, 3];
	[
		freq: [\r, oneM7, oneM7, oneM7, \r, oneM7, four6, six].df(\c) ++ 
		[ [1,3,5,-7], [ -7,2,4,7 ]].df('c#',5,\mixolydian) => _.q,
		curve:-9,
		t_trig:1,
		legato: [1,1,1,1,0,1,1,0.9,1].q(inf),
		//dur: b.parse([1, [1, 1/2], [1/2, 1], 4, 5,3]).q,
		dur: p.quarters[e.start].parse([1,1,1,1, 1,1, 2, 2, 8, 3]/2).q,
		out: Effect(PlateReverb.ar(_,mix:0.5,decayTime: 0.3,damping:0.7)).bus.index
	].pma(\defaultRetrig).play
	
});
["MCCOY: Then I'll still want one question answered to my satisfaction.", "1 2 -8 1 3 4 2 5 1".dm(\f, 5, \diminished) ++ "3 4 5 1 6.5 6".dm(\c, 5, \mixolydian) ].addLine;//p13
P(\dimchords,start:\answered,music:{|p b e| 
[
	freq: [ [1,3,5,7].df(\d,5,\diminished),[1,3,5,7].df('c#',5,\diminished) ].q,
	dur: b.parse([9,5]).q,
	legato:1,
	instrument:\wash,
	att:b[0..8].sum,
	rel:b[9..14].sum * 4,
	freqLag:1,
	amp:0.05

].pm(\wash).play
});
P.tune(\answered);
P.tune('answered to', {|i| Pbindf(i,\legato,0.9, \instrument,\stringyy,\wet,0.3,\release,2,\amp,0.2) => Pmul(\freq,1/[2,4],_)});
["Why? Not a list of possible miracles, (boom) but a ","6 3 1 5 3".dm(\f) ++ "6.5 6 3 5 4 -7".dm('c#',5) ++ "-5 3 4".dm('e-')].addLine;
P.tune('possible miracles');
P(\bass,start:'possible miracles',music:{|p b e| 
	[
		//freq: [1, 2, 1.5, 4, 1, -5].df('e-',3,\mixolydian).q,
		freq: [1, 2, 1.5, 2.5, 1, -5].df('e-',3,\mixolydian).q,
		dur: b.parse([1,2,2,3,3,3]).q,
		//instrument:\sawSynthSustain
		out: Effect( { |i|  SineShaper.ar(i*10,limit:0.1) => FreeVerb.ar(_,0.5,0.9) }  ).bus.index
	].pp
});
P(\strum,start:'possible miracles',music:{|p b e| 
	(
		freq: "-1 1 3 5 7".df('e-'),
		strum: 0.06
	).play
});
["simple basic understandable","5 5 6 6 7 11 7 6 4".dm('e-',5,\mixolydian)].addLine;
Song.setQuarters(\understandable,"q q q q q e q e e ".asBeats);
//Song.quarters[\understandable].list
	P(\chords,start:\understandable,music:{|p b e| 
		var one, four, seven;
		# one, four, seven = [[1,3,5],[1,4,6],[2,4,7]].df('e-',scale:\mixolydian);
		\one.post;one.postln;
		MegaBind(
			[one, one, four, four, seven, seven, four, four ].flop,
			p.quarters[e.start].list.gaussian(dev:0.005),
			//1,
			[
				pan:[ -1,0,1 ],
				limit:[ 0.5,0.1,0.005 ],
				lag: { 0.01 dup: 8 => _.put(0,0) => _.dq => _.demand(p.quarters[e.start].list) }
			],
			{|i|
				SinOsc.ar( i.freqSeq.lag(i.lag), 0, 0.1 )
				* 
				(
					Env.asr(0.01,1,0.001).kr(gate:i.gateSeq)
					+
					Env.perc(0.05,1).kr(0,gate: i.trigSeq)
				)
				=> SineShaper.ar(_, i.limit)
				=> Pan2.ar(_,i.pan).fold2(0.01)
				=> AnalogPhaser.ar(_, SinOsc.ar(rrand(0.2,0.3)), feedback: 0.8)
				=> LPF.ar(_,6000)
			},
			{|i|
				Mix.ar(i)
				=>HPF.ar(_,200)
				/2
				=> PlateReverb.ar(_,decayTime:0.2, mix:0.25)
				/2

			}
		).play

	});
P.tune(\understandable);
P(\bass,start:\understandable,music:{|p b e| 
	[
		freq: "1 1 4 4 7 7 4 4".df('e-',3,\mixolydian).q,
		dur: p.quarters[\understandable],
		//instrument:\sawSynth

		out: Effect( { |i|  SineShaper.ar(i*10,limit:0.1) => FreeVerb.ar(_,0.5,0.9) }  ).bus.index
	].pp
});
[" why that overrides all danger. And let's not ", "6 5 12 11 7.5 6.5  12 13 11 3 4 5".dm(\d,5,\minor)].addLine;
P(\bass,start:\override,music:{|p b e| 
	[
		freq: [1, 1.5, 2, -5, -4].df(\g,3,\minor).q,
		dur: b.parse([3,1,3,4, 1]).q,
		instrument: \sawSynthSustain
	].pp
});
P.tune(\overrides);
["kid ourselves that there is no potential danger in this. ", "5 4 2 -6 -7 1 1.5 1.5 2 3 4 2 -7 -5".dm(\f)].addLine;
P(\bass,start:\kid,music:{|p b e| 
	[
		freq: [1, 6, -6].df('b-',2).q,
		dur: b.parse([6,4, 3]).q,
		instrument:\sawSynthSustain
	].pp
});
P.tune(\kid);
}
)
