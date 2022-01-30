
/*
[Bridge]

(Uhura is screaming in terror before collapsing across her console. Chapel is standing rigid by the Captain's chair.) ,
[4,3,2.5,2,1,\_]

SPOCK: Must I make an example of you, too, Helm? 
(Kirk, Mulhall and McCoy enter.) SPOCK: Pain, Captain. And you, my dear? 
(As Kirk and Mulhall double over, McCoy dashes to Spock's side, ready to inject him.) 
SPOCK: Fortunately, Doctor, I know every thought of every mind around me. See? (to Chapel) Take the hypo from him. And inject him with it. 
(But she injects Spock/Henoch instead! He leaps from his seat.) 
SPOCK: Fools. I'll simply transfer to another place, another body. 
(He whirls around.) 
*/
( s.waitForBoot( {
	Song(\ending,[]).current;
	~stills.isNil.if{~stills=Stills("/Users/michael/trek/BySection/media/return to tomorrow.mov").current};
	Song.currentSong.synful1 = ~synful1 = Synful();
	Song.currentSong.synful2 = ~synful2 = Synful();
	Song.resources.condition=Condition();
	Song.resources.infrastructure=
	{
		FunctionList.new.array_([
			{ Song.currentSong.synful1 = ~synful1 = Synful()},
			{  Song.currentSong.synful2 = ~synful2 = Synful()},
			{ fork {
				while( {
					~synful2.controller.loaded.not;

				},{0.05.wait});
				Song.resources.condition.test_(true).signal
			}}
		]).value
	}.inEnvir;
	["SPOCK: Sargon! No, Sargon, please. Let me. Let me transfer. ",[1,2,3].dm(\c)].addLine;
	["(He falls to the floor and his victims are freed from their pain.) ","r"].addLine;
	["KIRK: Spock. My friend Spock. If there'd only been another way. ",[5,3,11,7, 5,6,7,5,13, 7,11,3,12].dm(\e)].addLine;
	P.still( \friend, start: \friend, timecode:4926.seconds, music: { |p b e|
		e.still.value(
			wait: b.sum-1,
			text:["Spock","my friend Spock"]
		);
		fork{
			b[(0..3)].sum.wait;
			e.still.setText(["If there'd only been","another way"])
		}
	});
	P.tune(\friend);
	P(\chords,start:\friend,music:{|p b e| 
		[
			freq: [3,\r,[2,5]].df(\e).q,
			dur: b.parse([1,2,1]).q,
			instrument:\wash
		].pp
	});
	P(\bass,start:\friend,music:{|p b e| 
		[
			freq: [[5,-5],11,-6,-2].df(\e,octave:[4]).q,
			dur: b.parse([8,2,2,1]).q,
			instrument:\stringyy
		].pp
	});
	["SARGON [OC]: (boom) I could not allow your sacrifice of one so close to you. ",[1,13,12,14,13,12,11,7,6,5,4,3,2,4,3,2].dm(\c)].addLine;
( //Vocoder resources
	Song.carrierBus = Bus.audio(s,2);
	Song.modulatorBus = Bus.audio(s,2);
	Song.sargonCarrier = {|p b e att=3 sus=5 rel=6 chord=#[1,2,4,5,6,8] aTune| 
	{  
		var tune = aTune ? p.tune[e.start].list;
		var freqs = Demand.ar(
			TDuty.ar(b.dq,1,1),
			1,
			tune.asArray.midicps /.t chord => _.dq
		);
		var car = Gendy1.arWidth( freq: freqs , width:1.10) => Mix.ar(_)
		* Env.linen(att,sus,rel).kr(2,gate:1);
		var saw = Saw.ar(freqs) * 0.1
		=> Splay.ar(_)
		=> RLPF.ar(_,100,2)
		* Env.linen(3,5,6).kr(2,gate:1);
		car => FreeVerb.ar(_,1,0.8)
		+saw
		/10
	}.play(s,Song.carrierBus.index)
}	;

	Song.sargonModulator = {|rpp dur modGain=1| 
		{ 
			Line.kr(dur:dur,doneAction:2);
			rpp=Song.resources.at(rpp);
			PlayBuf.ar( 1,rpp.buffer) 
			=> EchoNone.ar(_,1,0.4,2) * 2
			//=> MoogFF.ar(_,8000,1)
			=> LPF.ar(_,6000)
			* modGain
			*5	 => SafetyLimiter.ar(_) /5
			//+ ( In.ar(carrierBus.index,1) )
	}.play(s,Song.modulatorBus.index)
};
	Song.vocodeTune = { |p b e rppName amp=0.2 att=3 sus=1 rel=5 dur=10 chord=#[1,2,4,5,6,8] tune out=0 modGain=1|
		Synth(\soundInMorph,[
			modulator: Song.modulatorBus.index,
			carrier: Song.carrierBus.index,
			amp:0.32,
			amp:0.2, // WHEN buses are set to 1 channel otherwise comment out!
			amp:amp, 
			dur:dur,
			out:out
		]);
		Song.sargonCarrier.(p,b,e,att, sus, rel, chord,tune);
		Song.sargonModulator.(rppName,dur,modGain)
	}
);
	Song.voxSacrifice=VocalRPP(\sacrifice,\test);
	P.still( \kirk, start: \sacrifice, timecode:4942.582.seconds, music: { |p b e|
		e.still.value(
			wait: b.sum,
			fadeIn: 2
		);
	});
	P(\boom,start:\sacrifice,music:{|p b e| 
		(instrument:\cymbalsDS,amp:0.003,att:1).play
	});
	P(\vox,start:\sacrifice,music:{|p b e| 
		// TODO now make the relevant guide check to see if they should mute this!!
		p.vocodeTune.(p,b,e,
			\voxSacrifice,
			amp:0.8,
			out:4,
			dur:b.sum+5,
			att:3,
			sus:b.sum-5,
			rel:3
		)
	});
		P(\bass,start:\sacrifice,music:{|p b e| 
			[
				instrument:\stringyy,
				freq: [11,6,4,2,5].df(\c,octave:3).q,
				dur: b.parse([[ 1,1/3 ],[2/3,1,1,1],2,4,2,1,1]).q,
				out:2,amp:0.2
			].pp

		});
["(Lights dim and glow, then Chapel wobbles., MCCOY: Jim. ) ","r",[8]].addLine;
		P.still( \spock, start: \wobbles, lag:2, timecode:4948.seconds, music: { |p b e|
			e.still.value(
				wait: b.sum-e.lag,
				fadeIn:0.5
			);
		});
		P(\transform,start:\wobbles,music:{ |p b e| 
			Synths(\transLinen,\sustain,b.sum,\freq,[1,3,11,13].df(\c),\amp,0.1,\out,1);
			Synths(\transLinen,\sustain,b.sum,\freq,[1,3,11,13].df(\g,scale:\minor),\amp,0.1,\out,2);
			Synths(\transLinen,\sustain,b.sum,\freq,[1,3,11,13].df('c#',scale:\minor),\amp,0.1,\out,3);
			Synths(\transLinen,\sustain,b.sum,\freq,[1,3,11,13].df('f#'),\amp,0.1,\out,4);
			//////////strings
			p.synful1.patch(\violas,\tremsulpont,0);
			p.synful2.patch(\violins2,\tremsulpont,0);
			(expression:100,freq:[3,5,6.5,11,13].df(\c),type:\synful,instance:p.synful1,dur:b.sum,legato:1,amp:1).play;
			[ 
				expression:100,
				freq:[1,1].df(\c).q,
				type:\synful,
				instance:p.synful1,
				dur:[ b.sum, p.durs[e.start+1].list.sum ].q,
				legato:1,amp:1 
			].p.play;
			(expression:200,note:[3,5,6.5,11,13].df('f#'),type:\synful,instance:p.synful2,
			dur:b.sum,
			legato:1,amp:2).play;
			[ expression:100,freq:[[ 1 ],[ -7,-17 ]].df('f#').q,type:\synful,instance:p.synful1,
				dur:[ b.sum, p.durs[e.start+1].list.sum ].q,
			legato:1,amp:1 ].p.play;
			p.synful1.syn.set(\out,Effect(FreeVerb.ar(_,0.75,0.55)).bus.index);
			p.synful2.syn.set(\out,Effect(PlateReverb.ar(_,mix:0.55),out:0).bus.index);
			////////timpani
			s.bind{{ |pitchScale=1.15 loss=0.99998 |
				var env=Env.linen(0,b.sum-5,8).kr(2,gate:1)*0.175;
				var numChannels=4;
				var exc = Dust.ar(2!numChannels)+Impulse.ar(0);
				var sig;
				exc = Decay.ar(exc,0.02);
				exc=Integrator.ar(exc,0.8,0.1);
				exc=PinkNoise.ar(exc);
				sig=MembraneCircle.ar(exc,[0.007,0.0073]*pitchScale,loss)*env;
				sig
			}.play;}

		});
		["(Spock stands up.) KIRK: You're alive.  ",[-1,1,1,7].dm(\f,scale:\mixolydian)].addLine;
		P.tune('stands up');
		P.still( \wide, start: \stands, timecode:4956.5.seconds, music: { |p b e|
			e.still.value(
				wait: b.sum,
				fade:4,
				//text:["you're","alive!"]
			);
			fork{
				b[0].wait;
				e.still.setText( ["you're","alive!"])
			}
		});
		

		P(\bassPad,start:'stands up',music:{|p b e| 
			[
				dur:[b.sum, p.durs[e.start+1].list.parse([8,3])].flat.q,
				amp:0.2,
				freqLag:1,
				instrument:\stringyy,
				freq:[[1,11],[-7,7]].df(\f).q,
				octave:[3,2]
				,legato:1
			].pm(\stringyy).play;
		});
		P(\sparkle,start:'stands up',music:{|p b e| 
			//p.synful1.syn.set(\out,Effect(FreeVerb.ar(_,0.75,0.55)).bus.index);
			MegaBind(
				[

					[-1,  1, 3,  5,  7,  11, 13, 15, 17].df(\f, scale:\mixolydian),
					[ -1, 1, \r, \r, 11, 11, \r, \r, \_ ].df(\e),
					[ -1, 1, \r, \r, 11, 11, \r, \r, \r ].df('d#'),
				].flop,
				//b.parse([3,1])+[1,0.5],
				[b.sum-0.1, p.durs[e.start+1].list.parse([8,3])].flat,
				[lag:{[0,b[3]+0.1].dq.demand(i.dur)}],
				{|i|
					Impulse.ar( i.freqSeq.lag({[0,b[3]+0.1].dq.demand(i.dur)}) )
				},
				{ |i v|
					Convolution.ar(i,Dust.ar((LFBrownNoise2.kr({2.0.rand}!9).range(10,100)))=>FreeVerb.ar(_,0.5,0.5),2048)
					=> SplayAz.ar(2,_)
					* Env.linen(3,b.sum-6,p.secDur[ e.start+1 ]).kr(0,gate:1)
					=> {|i| DWGReverbC1C3.ar(i,c1:Line.kr(0.2,1,b.sum+2))/2 + i }
					* 0.4
				}

			).play
		});
["MCCOY: There was enough poison in that hypo to kill ten Vulcans. ",
			//[3,2,1,-7].dm(\c,scale:\mixolydian) ++ [5,3,2,1,4,3,4,5,12,5,4].dm('e-')

			[4,3,4,2,1,-7,1,2].dm(\b,octave:4) ++ [3,2,3,4, 6.5,5,2].dm('e-')
		].addLine;
		P.tune(\poison);
		P(\bass,start:\poison,music:{|p b e| 
			MegaBind(
				[
					[4,3,\r]
				].df(\b),
				b.parse([8,4,3]),
				[],
				//{|i| 
				//	Gendy1.arWidth(freq:i.freqSeq/[ 2,3,4 ])
				//	/2
				//	+ Gendy2.arWidth(freq:i.freqSeq/[ 2,3,4 ])
				//	*0.1
				//	* Env.asr(1,1,4).kr(0,gate:i.gateSeq)
				//},
				{|i|
					VarSaw.ar(i.freqSeq/4,0,0.1)
					=> Convolution.ar(_,Dust.ar((LFBrownNoise2.kr({2.0.rand}!9).range(10,100)))=>FreeVerb.ar(_,0.5,0.5),2048)
					=> Splay.ar(_)
					//* Env.linen(3,b.sum-3,5).kr(0,gate:1)
					* Env.asr(3,1,3).kr(0,gate:i.gateSeq)
					//=> {|i| DWGReverbC1C3.ar(i,1000,c1:0.9) + i }
				},
				{|i v|
					Splay.ar(i)
					* 0.1
					/3
					//=>DWGReverbC1C3.ar(_,2000,1,5)
					//*0.1
				}

			).play
		});
		P.still( \mccoy, start: \poison, timecode:5001.5.seconds, music: { |p b e|
			e.still.value(
				wait: b.sum,
				text: ["There was enough poison","in that hypo"]
			);
			e.still.sequenceText([
				b.parse([10]).sum,[ "to kill ten","Vulcans!" ]
			])
		});
		P(\chord,start:\poison,music:{|p b e| 
			//Muted
			MegaBind(
				[
					[1,\_,1.5,2,2.5,\_]
				].df(\c,octave:3),
				b,
				[],
				{|i|
					Saw.ar( i.freqSeq, 0.1)
					* Env.asr(0.2,1,4).kr(0,gate: i.gateSeq)
				}
			)
			//.play
		});
		["SARGON [OC]: No, Doctor. (Boom)",[1,-5,-3, -17].dm(\a,scale:\minor,octave:4)].addLine;
		Song.voxNo=VocalRPP('Doctor.',\test);
		P(\vox,start:'Doctor.',music:{|p b e|
			p.vocodeTune.(p,b,e,\voxNo,amp:0.3,dur:b.sum+3,att:1,sus:b.sum-1,rel:2)
		});
		P(\test,start:'No, Doc',music:{|p b e| 
			{
				PlayBuf.ar(1,p.voxNo.buffer)
				=> DelayN.ar(_,0.05,0.5)
				=> PitchShift.ar(_,pitchRatio:[1,0.5],pitchDispersion: 0.0)
				*0.4
			}
		});
		P(\bass,start:'No, Doc',music:{|p b e| 
			MegaBind(
				[
					[1,\_,\_,2.5],
					[1,-5,-3,-17]
				].df(\a,octave:3,scale:\minor),
				b,//.parse([3,1]),
				[
					lag: { [0,0.4].dq.demand(b.parse([3,1])) }
				],
				{|i|
					Pulse.ar( i.freqSeq.lag2(i.lag) 
					//*.t [1,2,3].reciprocal
					, 
					0.3,0.1)
					=> Mix.ar(_)
					* Env.asr(0.2,1,2).kr(0,gate:i.gateSeq)
				},
				{|i v|

					 TwoTube.ar(i, 0.1, 0.99, [ 1111, 1222 ],[ 762, 674 ],  mul: 1.0,  add: 0.0)
					*0.2
					//=> {|i| Out.ar(carrier.index,i[1]); 
					//Out.ar(1,i[0])
				//}

				}
			).play
		});
		P.still( \wide, start: 'No, Doctor', timecode:5006.seconds, music: { |p b e|
			e.still.value(
				wait: 1,
				fade:5,
				text:[ "No Doctor!","" ]
			);
		});
		P.tune('No, Doc');

		[" I allowed you to believe that to be true so that ",[3,2,4,3,1,-5,-7,-6,-4,-1,2,-6,-5].dm(\c,scale:\mixolydian,octave:6)].addLine;
		Song.voxAllow=VocalRPP(\allowed,\tune);
		P(\vox,start:\allowed,music:{|p b e|
			p.vocodeTune.(p,b,e,\voxAllow,0.2,att:1,sus:b.sum-3,rel:2,dur:b.sum+2)
		});
		P.still( \clear, start: \allowed, timecode:0, music: { |p b e|
			e.still.value(
				wait: b.sum,
				text:["I allowed you to","believe that to be"]
			);
			e.still.sequenceText(
				[b[(0..9)].sum,[ "true","so that" ]]
			)
		});
		//P.tune(\allowed);
		Song.allowedInner= {|i x| 
			Saw.ar( i.freqSeq.lag(0.01) + i.width, 0.1)
			//* Env.perc(0.05,3).kr(0,gate:i.trigSeq * i.gateSeq)
			* Env.asr(0,1,3).kr(0,gate:i.gateSeq)
		};
		Song.allowedFx = {|i v|
			i[[1,0,2]]	
			* 0.4
			=>Splay.ar(_)
		};
		P(\keys,start:\allowed,music:{|p b e| 
			MegaBind(
				[
					[3,  2,  4, 3,  1,  -5, -7, -6, -4, -1, 2,    -6, -5],
					[\r, \r, 1, \_, \r, \r, -4, \_, \r, \r, -4.5, \_, \r ],
					[\r, \r, 5, \_, \_, \r, 1, \_, \_, \r, -6,   \r, \r]
				].df(\c,scale:\mixolydian),
				b,
				[
					width: [0,{SinOsc.ar(3,0,3/2)},{ SinOsc.ar(5,0.2,2) }],
				],
				p.allowedInner,
				p.allowedFx
			).play
		});
		P(\bass,start:\allowed,music:{|p b e| 
			[
				freq: [\r,1,4,2,5,4,3,6,5].df(\c,octave:[3,4]).q,
				dur: b ++ Song.durs[\read].list => _.parse([2,4,4,3,3,3,3,2,2]) => _.q,
				amp: 0.1
			].pp
		});
		["Henoch would (boom) read your thoughts and believe it also. ",[11,7,5,-4,13,12,15,13,12,11,7,14,13].dm(\c,octave:4)].addLine;
		Song.voxRead=VocalRPP(\read,\tune);
			P(\vox,start:\read,music:{|p b e|
			p.vocodeTune.(p,b,e,\voxRead,
				amp:0.35,
				att:1,
				sus:b.sum-3,
				rel:2,
				dur:b.sum+2,
				chord:#[1,2,4,6,8],
				modGain:1
			)
		});	//P.tune(\read);
		P.still( \clear, start: \read, timecode:0, music: { |p b e|
			e.still.value(
				wait: b.sum,
				text:["Henoch would","read your thoughts"]
			);
			fork{
				b[(0..5)].sum.wait;
				e.still.setText(["and believe it ","also"])
			}
		});
		P(\line,start:\read,music:{|p b e| 
			MegaBind(
				[
					[11, 7,  5,  \r, 13, 12, 15, 13, 12, 11, 7, 14, 13],
					[\r, \r, \r, -4, -5, -6, -7,\r,\r,-6,\_,-5],

				].df(\c,octave:4),
				b,
				[

					width:[0],

				],
				p.allowedInner,
				{|i| i * 0.4
					=> Splay.ar(_)
				}

			).play
		});

		[ "MCCOY: Sargon. ",[5.5, 1].dm(\g)].addLine;
		P.tune('MCCOY: Sargon',Pbindf(_,\instrument,\sawSynthSustain));
		P(\chord,start:'MCCOY: S',music:{|p b e| 
			[
				freq: [1,3,5.5].df(\g),
				dur:b.sum.q,
				strum:0.05,
				out: Effect( { |i| 
					EchoCubic.ar(
						i,
						0.5,
						Array.fill(4,{rrand(0.2,0.4) })
						=>{|i| LFBrownNoise2.kr({rrand(1.0,2)}!4).range(i,i*0.9) }
						 ,
						5
					)+i/2} ,inputChannels:1).bus.index
			].pp

		});
["SPOCK: It seems, Doctor, the injection was (boom) only enough to cause unconsciousness. ",[5,11,5,3,11,7,6,4,1,-3,4,3,2,5,6,5,6,5.5,6,5.5].dm('b-',octave:4)].addLine;
Song.quarters[\injection]= Song.durs[\injection].list.asArray.parseBeats([1,2,1,1,1,1, 2,1,1,1, 2,1,1, 1,1,2,1,1,1,2]);
P(\phrase1,start:\injection,music:{|p b e| 
	MegaBind(
		[
			[\r, 1,  1,  1,  1,  1,  1,  4,  4,  4,  4,  \r, 4,  4,  4,  4,  5, 5, 5, 5, 5, 3, 3, 3],
			[\r, \r, \r, \r, \r, \r, \r, \r, \r, \r, \r, \r, \r, \r, \r, \r, 5, 4, 3, 3, 2, 3, 2, 1.5 ]
		].df('b-',octave:2),
		//b,
		p.quarters[e.start],
		[cutoff: { Dwhite(800,8000).demand(i.trigSeq) }],
		{|i x|
			case {x < 1}{Blip.ar( i.freqSeq,30 )
			=> MoogFF.ar(_,Demand.kr(i.trigSeq,1,Dwhite(400,4000)),3)
			* Env.perc().kr(0,gate:i.trigSeq*i.gateSeq)
			* Env.asr().kr(0,gate:i.gateSeq)
			//			=> EchoNone.ar(_,1,p.durs[e.start].list[0]/2,5)
		}		{
			Impulse.ar( i.freqSeq )
			* Env.asr().kr(0,gate:i.gateSeq)
		}
	},
		{ |i v|
			i * 0.2
		}
	).play
});
P.tune(\unconsciousness);
["SARGON [OC]: But Henoch believed and fled the body. ",[5,11,5,3,6.5].dm('c#',scale:\dorian)++[5,11,5,4,3].dm('e-')].addLine;
//P.tune(\believed);
Song.voxBelieve = VocalRPP(\believed,\vox);
		P.still( \clear, start: \believed, timecode:0, music: { |p b e|
			e.still.value(
				wait: b.sum,
				text:["but Henoch","believed"]
			);
			fork{
				b[(0..4)].sum.wait;
				e.still.setText(["and fled","the body"])
			}
		});
P(\vox,start:\believed,music:{|p b e| 
			p.vocodeTune.(p,b,e,\voxBelieve,0.3,1,b.sum-3,2)
});
P(\bass,start:\believed,music:{|p b e| 
	MegaBind(
		[
			[\r,1,2]
		].df('c#'),
		b.parse([1,5,4]),
		[
			lag: {[0,1,1,1,1,1,1,1,1,1,1].dq.demand(b)}
		],
		{|i|
			Saw.ar( 
				i.freqSeq.lag2( i.lag ) / 2 
				* [1,0.5]
				* LFBrownNoise2.kr([2,2.2,2.3,2.4]).range(0.99,1.01),
				0.1
			)
			* Env.asr(0.1,1,4).kr(2,gate:i.gateSeq)
		},
		{|i|
			Splay.ar(i)
			=> FreeVerb.ar(_,0.7,0.7)
		}

	).play
});
		["(boom) He is (boom) destroyed. ",[-5,5,5,-5,5,5].dm(\g)].addLine;
		P.tune(\destroyed);
		P(\chord,start:\destroyed,music:{|p b e| 
			MegaBind(

				[5,\_,\_,\r,\r,-1].bubble ++ 
				[\r,\r,\r,5,\r,[1,3,5]].flop 
				=> _.df(\c,scale:\minor)
				,
				b,
				[],
				{|i|
					Saw.ar( 
						Gendy1.krWidth(freq:5)*10+
						i.freqSeq / [2,4] 
						, 0.1
					)
					* Env.asr(release:4).kr(0,gate:i.gateSeq)
				},
				{|i v|
					Env([0.5,1,1],b.parse([5,1])).kr(0,gate:1) *
					Splay.ar(i)
					=>FreeVerb.ar(_,0.7,1) * 1.3
				}

			).play
		});
		["KIRK: But your vessel was destroyed, too. Where was your consciousness kept? ",[7,13,11,7,5,4,3,4,5,-7].dm(\g,scale:\mixolydian)++[7,11,14,13,11,7,5].dm(\d,scale:\mixolydian)].addLine;
		P.tune(\kept);
		["SPOCK: The place Henoch would least suspect, Captain. ",[2,3,4,3,1,5,4,6, 4,3].dm(\e,scale:\whole)].addLine;
		P.tune(\suspect);
		Song.suspectInner_(
			{|i|
				Gendy1.arWidth(freq:i.freqSeq+[1,2,3,4])//Dust.ar(50)
				=> { 
					|j| Convolution.ar(
						Saw.ar(i.freqSeq.lag(0.5)*[1,2]/8 ),
						j => FreeVerb.ar(_,0.8,0.9)
					)
					* Env.asr(release:6).kr(2,gate:i.gateSeq)
					*0.005
					*  i.amp 

				} 			
			}
		);
		P(\bass,start:\suspect,music:{|p b e| 
			MegaBind(
				[
					//[2,  3,  4,  3,  1,  5,  4,  6, 4, 3],
					[\r, 3, 4, \_, \_, 5, \_, 6,\_,\_,\_]
				].df(\e,scale:\whole),
				b[(0..(b.size-2))]++( b.last+p.durs[e.start+1].list[(0..8)].sum ),
				[
					amp:[
						{ Env([1,1,0.5],b.parse([6,3])).kr(0,gate:1) }		
					]
				],
				p.suspectInner,
			).play
		});
		["CHAPEL: (boom) That is why I was summoned into Sickbay, Doctor. ",[-5,5,4,3,2,1, 1,-7,1,2, 1,-7,-6,-5].dm(\a,scale:\melodicMinor)].addLine;
		P.tune(\summoned);
		P(\bass,start:\summoned,music:{|p b e| 
			MegaBind(

				[
					[4,5]
				].df(\a) ,
				b.parse([10,4]),
				[
					amp:[{ Env([0,1],b.parse([10])).kr(0,gate:1)}]
				],
				p.suspectInner,
				{|i| i};

			).play

		});
		["Mister Spock's consciousness was placed in me. ",[1,2,3,4,3,2,1,6,6,5].dm(\g,octave:4)].addLine;
		P.tune(\placed);
		P(\bass,start:\placed,music:{|p b e| 
			MegaBind(
				[
					[1,4,5,1, 6,5,4,1, 4,1,4,3]
				].df(\g),
				b.parse([
					1,1,0.5,0.5,
					1,1,1,1,
					0.5,0.5,1,1]),
					[
						amp:0.06,
					],
					{|i|
						var sig=Formant.ar(
							i.freqSeq * [1,0.491],  
							//formfreq: Line.kr(3060,00,i.dur),  
							formfreq: Env.perc(level:3600).kr(0,gate:i.trigSeq),
							bwfreq: 880
						).distort;
						var env=Env.asr(0,1,1,1.5).kr(0,gate:i.gateSeq);
						sig*env*i.amp //=> DelayN.ar(_,1,0.2)
					},
					{|i v| FreeVerb.ar(i,0.5,1)}
				).play
			});
			["(boom boom) We shared consciousness (we shared consciousness... ) to",[-5,-5,3,2,4,3,2,1].dm('e-')++[3,2,4,3,2,1].dm( 'a-' )++[3,2,4,3,2,1].dm('e-') ].addLine;
			Song.quarters[\shared]=Song.parseBeats(\shared,[1,1,1,1,1,1,1,3,1,1,1,1,1,3,1,1,1,1,1,1]/2);
			P.tune(\shared,Pset(\dur,Song.quarters[\shared].mean/2 * [1,1,1,1,1,1,1,3,1,1,1,1,1,3,1,1,1,1,1,1].q,_));
			Song.sharedClock=TempoClock.new().permanent_(true);
			P(\newVersion,start:\shared,music:{|p b e| 
				var tracks;
				var group = p.sharedGroup=Group.new;
				var clock = p.sharedClock.tempo_(p.quarters[\shared].mean.reciprocal/2);
				var shaker =	[time:[0.05,1,0.1].q(inf),amp:0.2,resonantFreq:60,dur:1/8,up:[1,0].q(inf),down:[0,1],q(inf),inst:13.rand].pm(\shakeEnv);
				var bd =[instrument:\bd_808,amp:0.15].p;
				var hat =[instrument:\hat_808,amp:[[1].q([3,5,6].q(1)),0].q(inf)/10,dur:1/16,out:Pwhite(0,5,inf)].p;
				var bass = [freq:[1,4,6.5,12.5].df(\c,octave:[3,2]).q(inf).stutter(4),dur:0.25,legato:0.3,amp:0.15,out:Effect(DelayC.ar(_,0.1,SinOsc.ar(6).range(0,0.001)).tanh).bus.index].p;
				var yow = [instrument:\yowbass,freq:[1,4,6.5,12.5].df(\c,octave:[3,2]).q(inf).stutter(4),dur:0.25,legato:0.3,amp:0.015,out:2].p;
				var stringyy1 = [freq:[\r,3,2,4,3,2,1].df([\c,\f])++[3,2,4,3,2,1].df([\f,'b-'],octave:6)=>_.q(inf),dur:[2,1,1,1,1,1,3,1,1,1,1,1,1].q(inf)/4,instrument:\stringyy,out:[0,2]].p;
				var saw1 = [amp:0.05,freq:[\r,5,13,12,\r].df(\c).q(inf),dur:[15,1,3,6,7].q(inf)/4,instrument:\sawSynthSustain,legato:1.1].p;
				//there's a better way to write these echoing lines!
				//var saw2 = [freq:[\r,12,11,\r].df(\c).q(inf),out:3,amp:0.07,dur:[24,3,6,7].q(inf)/4,instrument:\sawSynthSustain,legato:1.1].p;
				//var saw3 = [freq:[\r,11,6.5,\r].df(\c).q(inf),out:2,amp:0.06,dur:[32,3,6,7].q(inf)/4,instrument:\sawSynthSustain,legato:1.1].p;
				//var saw4 = [freq:[\r,6.5,6,\r].df(\c).q(inf),out:2,amp:0.05,dur:[40,3,6,7].q(inf)/4,instrument:\sawSynthSustain,legato:1.1].p;
				var sn = [dur:"..xx..x.".asDrumPat(4,inf),amp:0.1,instrument:\sn_808].p;

				[shaker,bd,hat,yow].par.findur(6)
				+= saw1.fin(4) 
				=> Pmul(\freq,midiratio(-2),_) 
				+= [6,[ shaker,bd,hat,yow=>Pmul(\freq,(midiratio(9)),_) ].par.findur(4)]
				=>_.postln
				=>Pbindf(_,\group,p.sharedGroup) 
				=> _.play(p.sharedClock);

				//fork{ 
				//	b.sum*4 => _.wait;
				//	p.sharedClock.clear(releaseNodes:true);
				//	0.01.wait;
				//	p.sharedGroup.release;
				//	1.wait;
				//	p.sharedClock.clear()}
			});
			//MUTED P(\lick,start:\shared,music:{|p b e| 
			//MUTED 	[2,1, 6.5,5].dm(\c)
			//MUTED });
			//MUTED P(\kick,start:\shared,music:{|p b e| 
			//MUTED 	{
			//MUTED 		AnalogBassDrum.ar(
			//MUTED 			trig: TDuty.kr(Song.quarters[\shared].mean/2*[1,1,1,1,1,1,1,1].dq(inf),0,[1,1,0,1,1,1,0,1].dq(2)) ,  
			//MUTED 			infsustain: 0.0,  
			//MUTED 			accent: Demand.kr(Impulse.kr(Song.quarters[\shared].mean/2),0,[0,1,0].dq(inf)),
			//MUTED 			freq: 40,  
			//MUTED 		tone: 0.2,  
			//MUTED 			decay: 0.5,  
			//MUTED 			attackfm: 0.5,  
			//MUTED 			selffm: 0.25
			//MUTED 		)
			//MUTED 		=> {|i| [i,CombC.ar(i,1,Song.quarters[\shared].mean/4.02,3)] }
			//MUTED 		*10
			//MUTED 		++ ( AnalogSnareDrum.ar(
			//MUTED 
			//MUTED 			trig: TDuty.kr(Song.quarters[\shared].mean/2*[1,1,1,1,1,1,1,1].dq(inf),0,[0,0,1,1,0,0,1,0].dq(2),0) ,  
			//MUTED 			infsustain:0,
			//MUTED 			freq:166,
			//MUTED 			decay:0.3,
			//MUTED 			snappy:0.8
			//MUTED 		) => FreeVerb.ar(_,0.5,0.8) )
			//MUTED 
			//MUTED 		=> Splay.ar(_)
			//MUTED 		/2
			//MUTED 	}.play;
			//MUTED 	fork{
			//MUTED 		var a;
			//MUTED 		0.2.wait;
			//MUTED 		a = Synth(\shake,[\out,2]);
			//MUTED 		b.sum.wait;
			//MUTED 		a.free
			//MUTED 	}
			//MUTED 
			//MUTED });
			//MUTED 	SynthDef(\shake,{
			//MUTED 	StkInst.ar(Stk.at("Shakers"),3.midicps,
			//MUTED 		VarSaw.ar(Song.quarters[\shared].mean.reciprocal*4,iphase:pi/2) => Decay.ar(_,0.5),1,0.5)
			//MUTED 		=> Out.ar(\out.kr(0),_)
			//MUTED 	}
			//MUTED 	).add;
			//MUTED P(\bass,start:\shared,lag:-0.01,music:{|p b e| 
			//MUTED 	[
			//MUTED 		dur:p.quarters[e.start].mean/2,
			//MUTED 		freq:[-5,1,4,6.5].df('e-',octave:3).stutter(4).q,
			//MUTED 		instrument:\sawSynth
			//MUTED 
			//MUTED 	].//pm(\sawSynthSustain).play
			//MUTED 	pp
			//MUTED });
			["gether.(1) ",[12,11,11,7,7,6].dm(\d)].addLine;
			Song.getherLines=
			[
				[12, 11, \_,  \r, \r, \r],
				[\r, \r, 11,  7,  \_, \r],
				[\r, \r, \r,  \r, 7,  6],
				[6,  5,  \_,  \_, 3,  \_],
				[4,  3,  2.5, 2,  1,  \_],
			].df(\d);
			P(\echos,start:'gether.(1) ',music:{|p b e| 
				MegaBind(
					p.getherLines[(0..2)],
					b,
					[
						out:[0,1,0]
					],
					{|i| 
						Saw.ar(i.freqSeq) 
						* Env.asr(0.01,1.0,4.0,  curve: -4.0).kr(2,gate:i.gateSeq)
						*0.1
						*0.5
						* Env([1,1,0.3],b.sum*[0.4,0.6]).kr(0,gate:1)
						=> Out.ar(i.out,_)
					}
				).play	;
				MegaBind(
					p.getherLines[(3..4)],
					b,
					[
						width:[0.1,0.5]
					],
					{|i|
						//Pulse.ar(i.freqSeq/[1,2],i.width,0.1)
						Impulse.ar(i.freqSeq/[1,2])
						* Env.asr(0,1,2).kr(0,gate:i.gateSeq)
						* 0.4
						*0.5
					},
					{|i v|
						FreeVerb.ar(i,0.5,1)
						* Env([1,1,0.3],b.sum*[0.4,0.6]).kr(0,gate:1)
					}
				).play
			});
			P(\bassPad,start:'gether.(1)',music:{|p b e| 
				MegaBind(
					[
						[1,2],
						[-1,-2]
					].df(\a,octave:[3,4]),
					[ b.sum+Song.durs[\cannot].list[[0,1]].sum,5 ],
					[a:9],
					{|i|
						Saw.ar(i.freqSeq*[0.995,1,1.0031],0.03)
						//* Env.asr(0.1,1,6).kr(0,gate:i.gateSeq)
						* Env.asr(1,2).kr(0,gate:1)
						=>Splay.ar(_)
						* Env.perc(0.1,12).kr(0,gate:i.trigSeq)
					},
					{ |i|
						FreeVerb.ar(i,0.5,0.8)
					}
				).play
			});
			["SARGON [OC]: We now know we cannot permit ourselves (boom) to exist in your world, my children. ",[5,4,3,-7,4,3,2,1,-7,-5,-3,-7,1].dm(\b,scale:\mixolydian) ++ [2.5,2,6,5,1,4,3].dm(\g)].addLine;
			(
				Song.weNowKnowLines= [
					[6, 5, 4.5, 1,  5,  4.5, 3,  2,  1,  -6, \_],
					[3, 3, 2,   \_, \_, \_,  \_, \r, \r, \r, -4.5],
					[1, 1, -6,  \_, \_, \_,  \_, \r, \r, \r, -14.5],
					[6, 5, 4.5, 1,  5,  4.5, 3,  2,  1,  16, \_]*(-1)
				].df(\a);
			);
			P(\bass,start:\cannot,syl:12,music:{|p b e| 
				[
					freq: [2,1.5,-5,-4.5,-1,-13].df(\f,octave:[3,4]).q,
					dur:b.drop(1).parse([2/3,[ 1/3,1 ],[1,2/3],[1/3,1],1,1, ])++3 =>_.q,
					legato:1
				].pp

			});
			P(\lines,start:\cannot,music:{|p b e| 
				a=MegaBind(
					p.weNowKnowLines,
					b[ 0..9 ],
					[amp:[1,1,1,1]],
					{|i x| Pulse.ar(i.freqDq.demand(i.dur + Array.fill( i.size,{0.04.rand} ))
					//*[rrand(0.995,1.005),1]
					,width:0.1) 
					* (
						Env.asr(0.5,1,4).kr(0,gate:i.gateSeq)
						+ {0.1*Env.perc(0.2,1).kr(0,gate:i.trigSeq)} 
					)
					* 0.1
				},
				{|i| 
					Splay.ar(i)
					=>FreeVerb.ar(_,0.5,1)}

				).play
			});
			P.tune(\cannot);
			["(boom) Thalassa and I must now (boom) also depart",[-1,1,2,3,1,4,2,5, 5,4.5, 4.5,7].dm(\d)].addLine;
			P(\bass,start:\depart,music:{|p b e| 
				[
					freq: [1,[12, 2 ],11.5].df(\d,octave:[3,2]).q,
					
					dur: b.parse([8,4]) ++ 1 =>_.q,
					freqLag: [0,0,2].q,
					instrument: \stringyy,
					legato:[0.9,1,1].q,
					amp:[ 0.3,0.2,0.15 ].q
				].pma(\stringyy).play

			});
			P(\bass,start:\depart,music:{|p b e| 
				MegaBind(
					[
						[1,2,\r],
						[\r,12,11.5]
					].df(\d),
					b.parse([8,4])++1,
					[
						amp:[0.5,0.3],
						attack:[1,2.5]
					],
					{|i|
						var freq=i.freqSeq/[2,4];	
						var width=6;
						//var gate=\gate.kr(0);
						Gendy2.ar(minfreq:freq-width,maxfreq:freq+width)
						=>Mix.ar(_) *0.5
						+Gendy1.ar(minfreq:freq-width,maxfreq:freq+width)
						* 0.1 * i.amp
						=> PlateReverb.ar(_,10,mix:0.5) 
						* Env.asr(i.attack,1,8).kr(0,gate:i.gateSeq)
						//=>Out.ar(\out.kr(0),_)
				},
				{|i| 
					Mix.ar(i)
					 /
					 2
					},
					release:b.sum+3
				).play
			});
			P.tune(\depart);
			["(boom) into oblivion. ",[-2,-7,1,2,1,-5,-4].dm('c#',octave:6)].addLine;
			P.tune('into oblivion',Pbindf(_,\amp,0.06,\out,Effect( { |i| EchoNone.ar(i,2,[1.3, 2 ]*0.6,9)*0.6=> { |i| i+( 0.5*PitchShift.ar(i,pitchRatio:[1.5,2]) ) }  } ).bus.index,inputChannels:2));
			P(\counter,start:'into oblivion',music:{|p b e| 
				[
					freq: [5,4,3,2,1].df('a-',octave:4).q,
					dur: b.parse([2,1,1,[ 2,0.5 ],0.5]) => _.q,
					legato:1.1,
					amp:0.07
					//out:Effect(EchoNone.ar(_,b.sum+b.last,b.sum+b.last,9)).bus.index
				].pp

			});

			["(echo)","r", Song.durs['into oblivion'].list.asArray ].addLine;
			P(\counterEcho,start:'echo',music:{|p b e| 
				[
					instrument:\stringyy,
					freq: [5,4,3,2,1].df('a-',octave:4).q,
					dur: b.parse([2,1,1,[ 2,0.5 ],0.5]) => _.q,
					amp:0.2,
					legato:1,
					//out:Effect(EchoNone.ar(_,b.sum+b.last,b.sum+b.last,9)).bus.index
				].pp

			});

			P(\echo,start:'echo',music:{|p b e| 
				[
					freq:[\r,-7,1,2,1,-5,-4].df('c#',octave:6).q,
					dur:b.q,
					instrument:\sawSynthSustain,amp:0.02,
				].pp
			});
			["KIRK: Is there any way we can help you, Sargon? ",[12,11,13,11,7,6,5,11,7,7,6].dm(\c)].addLine;
			P.tune(\help,Pbindf(_,\legato,1.5));

			["SARGON: Yes, my son. ",[1,-7,-5].dm('a-',scale:\mixolydian)].addLine;
			P.tune('my son');
			P(\bass,start:'my son',music:{|p b e| 
				(
					instrument:\sawSynthSustain,
					dur:b.sum,
					rel:5,
					amp:0.03,
					freq:[1,-1,-11].df('a-')).play
			});
			["You can allow Thalassa and me to ",[1,2,4,5,6,5,6,4,12,11].dm('a-')].addLine;
			P.tune('Thalassa and me');
			P(\harpy,start:'Thalassa and me',music:{|p b e| 
				MegaBind(
					[
						[1,  \_, \_, \_, \_, \_, \_, \_, \_],
						[\r, 2,  \_, \_, \_, \_, \_, \_, \_],
						[\r, \r, 4,  \_, \_, \_, \r, 4,  \_],
						[\r, \r, \r, 5,  \r, 5,  \_, \_, \_],
						[\r, \r, \r, \r, 6,  \r, 6,  \_, 12],
					].df('a-'),
					b,
					[],
					{|i| 
						Pulse.ar( i.freqSeq , 0.2)
						* Env.asr(0,1,2).kr(0,gate: i.gateSeq)
						* 0.1
					},
					{ |i| 
						Splay.ar(i) 
						*0.2
						=> Phaser2.ar(_,rate:0.15)
					} 


				).play;
			});
			P(\bass,start:'Thalassa and me',music:{|p b e| 
				[
					freq: [11,7,5].df('a-',octave:3,scale:\mixolydian).q,
					dur: b.parse([3,5,2]).q,
					legato:[1,0.90,1.3].q
				].pma(\sawSynthSustain).play

			});
["(boom boom) share your bodies again. ",[1,1,13,12, 13,14,13,12,11].dm(\f)].addLine;
//P.tune(\bodies,_.drop(2),syl:1);
Song.shareVox=VocalRPP(\bodies,\share);
P(\vox,start:\bodies,music:{|p b e| 
	p.vocodeTune.(p,b,e,\shareVox,0.2,0,b.sum,2,dur:b.sum+2,tune:[\r,\r]++p.tune[e.start].list=>_.drop(2))
});
Song.setQuarters(\bodies,[1,1,1,1/4,1/4,1,1/2,1/2,1/2]);

			P(\drums,start:\bodies,music:{|p b e| 
				[
					freq:[\r,\r,1].q,
					dur:p.quarters[\bodies],
					instrument:\sn_808,
					out: Effect(EchoNone.ar(_,0.5,[ b[0]/3,b[0]/4 ],3)).bus.index
				].pp
			});
			P(\shake,start:\bodies,music:{|p b e| 
				[
					time:[0.05,0.1].q(inf),
					amp:0.2,
					resonantFreq:60,
					//dur:b[[0,1]].stutter(4)/4 => _.q(3),
					dur:p.quarters[\bodies].list.stutter(4).q/4,
					//dur:p.quarters[\bodies],
					up:[1,0].q(inf),
					down:[0,1],q(inf),
					inst:13.rand
				].pm(\shakeEnv).play
			});
			P(\chord,start:\bodies,music:{|p b e| 
				[
					freq:[\r,[-5,1,3].df(\f),[1,3].df('b-')].q,
					dur:b.parse([2,5,2]).q	,out:2
				].pp;
				[
					freq: [
						[-5,1,3].df(\f),
						[-5,1,3].df('b-')
					].q,
					dur:b.parse([4,3]).q,
					instrument:\stringyy,out:1
				].pp
			});
			P(\boomboom,start:\bodies,music:{|p b e| 
				[
					instrument:\bd_808,
					dur:b.q.fin(2)
				].pp;

				[
					instrument:\harp,
					amp:0.03,
					freq: [-7,1,-5,-2.5,-4,-1].df(\f,octave:[3,4],scale:\mixolydian).q,
					dur:b.parse([1/2,1/2,[2, 2, 1/2 ], 1/2,1 ,1]).q,
					out: Effect({|i| MoogVCF.ar(i,2000,0.5)*2 },out:2).bus.index
				].pp;
				[
					instrument:\sawSynth,
					freq: [1,1,-7,-4,-4].df(\f,octave:[3,4]).q,
					dur:b.parse([1,2,[ 2, 1/2 ],[ 1/2,1 ],1]).q
				].p//p
			});
["A last moment together. ",[1,11,7,6,4,3,-7].dm('f#')].addLine;
P.tune(\last);
P.still( \clear, start: \last, timecode:0, music: { |p b e|
	e.still.value(
		wait: b.sum-3,
		fade:3,
		text: ["a last moment","together"]
	);
});
Song.lastMoment=VocalRPP(\last,\tune);
P(\vox,start:\last,music:{|p b e|
	p.vocodeTune.(p,b,e,\lastMoment,0.3,1,b.sum+5,2,dur:b.sum+2,chord:#[1,2,0.33])
});
P(\chord,start:\last,music:{|p b e| 
	MegaBind(
			[
				[\r,  11,  7, 6, 4, 3, -7],
				[\r,  3,  \_, \_,\r],
				[\r,  5,  \_, \_,\r],
				[1, \_, -7, -6,\_],
				[\r,-11,-14,\_,\_,-11,\_],
				[\r,-11,-24,\_,\_,-22,\_],
			].df('f#')
			,
			b.dropLast ++ (b.last * 1/2),
			//b.drop(1).parse([1,3,2]),
			[ finalRel: [10,1,1,1,1,1]],
			{|i x|

	 Saw.ar(i.freqSeq*({rrand(1.01,0.99)}!4),0.1)  
	* Env.asr(releaseTime:i.finalRel).kr(0,gate:i.gateSeq)
	* 0.05
			},
			{|i|
				i.collect(Mix.ar(i))
			=> DWGReverbC1C3.ar(_)
			
			},
			release:12
		).play
});
["(Mulhall nods, and they go over to the science station for the light trick and voice change.) ","g r r" ].addLine;
P.tune(\nods);
P(\nod,start:\nods,music:{|p b e| 
	[
		freq:[ [1,3,5].df(\g),\r ].q,
		dur:b.q/2 ,
		rel:2,
		amp:0.05,
		out: Effect(EchoNone.ar(_,1,0.35,5,mul:0.2)).bus.index
	].p.play
});
P.still( \down, start: \nods, timecode:5105.58.seconds, music: { |p b e|
	e.still.value(
		wait: 1,
		fade:1
	);
});
P.still( \walking, start: \nods, syl:0, timecode:5110.5.seconds, music: { |p b e|
	e.still.value(
		wait: 1,
		fade:1
	);
});
P(\transform,start:\nods,syl:1,music:{|p b e| 
	//(
	//	dur:b.sum,
	//	freq:[1,3,4,6].df(\e,scale:\whole),
	//	instrument:\stringyy,
	//	width:13,
	//	wet:0.2
	//).play;
	var synths,bus;
			Synths(\transLinen,\sustain,b.sum,\freq,[1,3,4,6].df(\e,scale:\whole),\amp,0.1,\out,1);
			Synths(\transLinen,\sustain,b.sum,\freq,[1,3,4,6].df(\e,scale:\whole),\amp,0.1,\out,2);
			
				synths= Synths(\trem2 ,\amp,0.05,\scale,2,\freq,[1,3,4,6,11,13,14,16,21,23].df(\e,scale:\whole),\out,[0,1,2,3,0,1,2,3,0,1]);
				bus = Bus.control;
				{Env.linen(0,b.sum-5,5).kr(2,gate:1)*0.05}.play(s,bus.index);
				synths.map(\amp,bus);

			s.bind{{ |pitchScale=1.15 loss=0.99998 |
				var env=Env.linen(0,b.sum-8,8).kr(2,gate:1)*0.175;
				var numChannels=4;
				var exc = Dust.ar(2!numChannels)+Impulse.ar(0);
				var sig;
				exc = Decay.ar(exc,0.02);
				exc=Integrator.ar(exc,0.8,0.1);
				exc=PinkNoise.ar(exc);
				sig=MembraneCircle.ar(exc,[0.007,0.0073]*pitchScale,loss)*env;
				sig * 0.5
			}.play};
			fork{b.sum+5=>_.wait;synths.free}
});
P.still( \purple, start: \nods,syl:1, timecode:5116.5.seconds, music: { |p b e|
	e.still.value(
		wait: 6,
		fadeIn: 2,
		fade:2
	);
});
["MULHALL: Oblivion together",[2,1,2,1].dm(\c)].addLine;
P(\tune,start:'Oblivion together',music:{|p b e| 
	MegaBind(
			[
				[2,1,2,1]
			].df(\c),
			b,
			[],
			{|i|
				Blip.ar(i.freqSeq * [1,1.01],20)
				* Env.asr().kr(0,gate: i.gateSeq)
			},
			{|i|
				Mix.ar(i)
				=> EchoCubic.ar(_,1,0.3,7)
				=> Phaser2.ar(_,rate:0.1)
				*0.05
			
			}
		).play
});
P.still( \oblivion, start: 'Oblivion together', timecode:5125.5.seconds, music: { |p b e|
	e.still.value(
		wait: b.sum+6 ,
		fadeIn:8,
		text: [ "","" ]
	);
	fork{
		6.wait;
		e.still.setText(["oblivion",""])
	}
});
[" does not frighten me, beloved.","r"].addLine;
[" Promise we'll be together. ","r"].addLine;
["KIRK: I promise, beloved. ","r"].addLine;
["MULHALL: Together forever. ","r"].addLine;
["KIRK: Forever beloved. Forever. ","r"].addLine;
["(They embrace and kiss, and the light thing happens again during it.) ","r"].addLine;
["KIRK: Well, I'm sure that Sargon appreciated your co-operation, Doctor Mulhall. ","r"].addLine;
["MULHALL: Yes. I was happy to co-operate, Captain. ","r"].addLine;
			["CHAPEL: It was beautiful.","r"].addLine;
		}
	)
)
