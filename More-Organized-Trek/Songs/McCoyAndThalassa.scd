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
	Song.quarters[\exist] = Song.parseBeats(\exist,[
		1,
		2,1/2, 1/2, 1/2,1/2,
		1, 1/2, 3/2, 1, 
		2, 1/2, 5/2, 
		1/2,1, 1/2, 1/4, 3/4, 1
	]);
	P.tune(\exist);
	
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
			freq: [\r, 3, 2, 5, 4, 4, 5, 1, -7 ].df('e', octave:3).q,
			//dur: b.parse([1,5,4, 2, ]).q
			dur: [1/2, 2, 2, 3/2, 1/2, 1/2, 1, 1, 1].q*2
		].p.play(clock:TempoClock.newFromQuarters(p.quarters[\exist]));
	});
	[ "MCCOY: If you're asking my approval ","r" ].addLine;
	[ "MULHALL: I require only your silence.","r"].addLine; 
	[ "Only you and I will know that Doctor Mulhall has not returned to her body. ",[1,2,3,1,4.5,2,-6].dm('e-') ++ [2,3,1,4.5,2].dm(\c) ++ [1,2,3,4].dm(\e,scale: \whole) ].addLine;
	P.tune(\returned);
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
	[ "Isn't that worth your captain's life? ","r" ].addLine;
	//[ "Doctor, we can take what we wish. ",[11, 5, 3, 5, 12, 11, 7, 6].dm(\e,4) ].addLine; //?????
	[ "Doctor, we can take what we wish--. ",[3, 2, 6, 6, 6, 5, 6, 6, 7].dm(\a) ].addLine; //?????
	P.tune('we can take');
	P(\chords,start:'we can take',music:{|p b e| 
		var fs=[-6,1,3,6].df(\a);
		var a = [-5,1,3,5].df(\a);
		[
			freq: [\r,\r,fs,fs,fs,a,fs,fs,[-7,7].df(\a)].q,
			dur: b.q
		].pp;
	});
//	P(\bass,start:'we can take what we wish',music:{|p b e| 
//		[
//			freq: [11, 7, 6, 5, 4].df(\e).q /4 + 2,
//			dur: b.parse([4,1,1,1,1]).q,
//			width: [2,2,2,2,2]/2 
//		].pma(\defaultPorto).play
	//});
	[ "Neither you, this ship, nor worlds have the power to stop us." ,[5, 5, 6, 5, 6, 5].dm('c#',5,\minor) ++ [7, 6, 11, 7, 6, 5, 4 ].dm(\c,5,\mixolydian) ++ [7, 11, 7, 7, 6].dm(\d,5,\mixolydian) ].addLine;
	P.tune(\worlds);
	P(\bassNotes,start:\worlds,music:{|p b e| 
		[
			freq: [1, 1, 4, 1, 2, 1, -7, 2, 3,  1.5, 4.5].df('c#',[3,4]).q,
			dur: b.parse([1,1,1, 1, 1, 1, 3, 1, 4, [1,1,0.5],[0.5,1]]).q
		].pp
	});
	// ????????
	[ "MCCOY: Neither Jim nor I can trade a body we don't own",[1, 2, 3, 1, 4, 2, 3, 4, 5, 4, 3, 2, 6].dm(\g,4,scale:\lydian)].addLine;
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
	P(\chords,start:\happens,music:{|p b e| 
		[
			freq: [\r, [1,5,1], [-4], [-5, 2, 4] ].df(\f).q / [1,2],
			dur: b.parse([1,7,2,2 ]).q,
			instrument:\wash
		].pp;
	});
	P.tune(\happens);
	[ "MULHALL: Who you hardly know. Almost a stranger to you. (boom) ",[3, 1, 5, 4, 3.5].dm(\b,5,\whole) ++ [-7, 1, 2, 2.5, -7, -6, -4.5, -2.5].dm(\c,6) ].addLine;
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
	[ "MULHALL: A physician? ",[1, 1, 11, 1].dm(Song.physicianKey) ].addLine;
	P(\chord,start:'physician?',syl:1,music:{|p b e| 
		(
		freq: [1,3,5,7,11].df(p.physicianKey,4,\diminished)
		).play
	});
	P.tune('physician?');
	[ "In contrast to what we are, you are a ", [-7, 1, 2, 3, 4.5, 5, 2, 6, 7 ,4].dm(\g,scale:\mixolydian) ].addLine;
	P.tune(\contrast, { |i| Pmul(\freq,[0.5,1],i) => Pbindf(_,\instrument,\stringyy,\amp,0.2,\release,4) } );
	
	["prancing, savage, monkey ",[-1, -1, 3, 1, -4, -4, 4, 1, -7, -7, -7, -7, -7, -7, 2, 1 ].dm(\g, scale:\mixolydian)].addLine;
	Song.quarters[\prancing] = Song.parseBeats(\prancing,[1,1,1,1, 1,1,1,1, 1,1,1,1, 1,1,1.5,0.5]).quantize(0.5)  ;
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
	P.tune(\defy, {|i| Pset(\out,Effect(CrossoverDistortion.ar(_,drive:0.9,smooth:0.1) * 0.04).bus.index,i) => Pmul(\freq,[1,1.33]!5 => _.q ++ [1].q(inf),_)});
	P.tune(\knees,{|i| Pfin(6,i) => Pmul(\freq,[4/3,4/3,4/3,4/3,4/3,1].q/2,_) => Pset(\legato,[1,1,1,1,1,6].q,_)});
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
	[ "MULHALL: Stop! (the flames are gone) ~Sargon was right.~ ",[1].dm(\e) ].addLine;
	P(\muteFire,start:\Stop,music:{|p b e| 
		p.fireGroup.release(0.1)
	});
	P.tune(\Stop);
	[ "The temptations (boom boom) in a living body are too great. ",[-6, -6, 3, 2, 1, -6, -7, -5, 5, 3, 2, 1, -7, -5, 4  ].dm(\c) ].addLine;
	P.tune(\temptations);
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
				
			).play
		
	});
	[ "MULHALL: Sargon? Where are you? I thought you destroyed by Henoch. ",[3, 1, 5, 7, 4.5].dm('b-') ++ [7, 5, 6, 7, 13, 13, 15, 14.5].dm(\g, scale:\mixolydian ) ].addLine;
	P.tune(\destroyed);
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

		).play

	});
	[ "MULHALL: Yec. Yes, I see. I understand. ",[4, 4, 3].dm(\f) ++ [4, 3, 6 ,4, 3].dm(\g) ].addLine;
	P.tune(\understand);
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
	P.tune(\Enterprise);
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
	P.tune('CHAPEL: Doctor.');
	P(\chord,start:'CHAPEL: Doctor.',music:{|p b e| 

		(
			freq:[1,3,5,11].df(\e,scale:\whole),
			instrument:\stringyy,
			amp:0.05
		).play

	});
	[ "MULHALL: Doctor, leave us. Sargon has a pla--n. We have much work to do. (boom)",[-5, -5, 1, -1,  5, 4, 3, 2, 3,4, 2,3,4.5, 4.5, 5.5, 3,-7, -6 ].dm(\f) ].addLine;
	P.tune('work');
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
	["I'm Ann Mulhall, back in my own body. ",[-5, 3, 3, 2, 3, 2, 3, 4, 3, 2].dm(\g)].addLine;
	P.tune('own body');
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
	["KIRK: (boom ba boom ba) Bones, prepare a hypo. The fastest, deadliest poison to Vulcans. ",[-5, -5, -5, -5, 5, 5, 5, 5, 11, 5, 11].dm(\b,octave:4) ++ [5, 4, 2].dm(\f)++[5,4,2].dm('f#') ++ [5,4,2].dm('g') ++ [4, 3].dm(\e)].addLine;
	P(\lick,start:\fastest,syl:10,music:{|p b e| 
		[
			freq: [\f,'f#',\g].collect( [2,4,7].df(_) ) => _.flat => _.q / 2,
			dur: b.drop(1).q
		].pp
	});
	P.tune(\prepare);
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
