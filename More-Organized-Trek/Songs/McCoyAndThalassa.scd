(
Song('MandT',[]).current;

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
[ "I wish only to exist in peace as a living woman. ","r" ].addLine;
[ "MCCOY: If you're asking my approval ","r" ].addLine;
[ "MULHALL: I require only your silence.","r"].addLine; 
["Only you and I will know that Doctor Mulhall has not returned to her body. ",[1,2,3,1,4.5,2,-6].dm('e-') ++ [2,3,1,4.5,2].dm(\c) ++ [1,2,3,4].dm(\e,scale:\whole) ].addLine;
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
	(freq:[5,7,11,13].df(\f,scale:\mixolydian)/2,strum:0.07,amp:0.16,out:Effect(FreeVerb.ar(_,1,1),inputChannels:2).bus.index).play
});
[ "Isn't that worth your captain's life? ","r" ].addLine;
[ "MCCOY: Neither Jim nor I can trade a body we don't own. It happens to belong to a young woman. ","r" ].addLine;
[ "MULHALL: Who you hardly know. Almost a stranger to you. ","r" ].addLine;
[ "MCCOY: I will not peddle flesh. I'm a physician. ","r" ].addLine;
[ "MULHALL: A physician? ","r" ].addLine;
//[ "In contrast to what we are, you are a prancing, savage medicine man. ","r" ].addLine;
[ "You dare defy one you should be on your knees worshipping? ","r" ].addLine;
[ "I could destroy you with a single thought. ","r" ].addLine;
[ "(McCoy is suddenly writhing in pain as he is surrounded by flames.) ","r" ].addLine;
[ "MULHALL: Stop! (the flames are gone) Sargon was right. ","r" ].addLine;
[ "The temptations within a living body are too great. ","r" ].addLine;
[ "Forgive me. ","r" ].addLine;
[ "SARGON [OC]: I am pleased, my beloved. It is good you have found the truth (yourself) ","r" ].addLine;
[ "MULHALL: Sargon? Where are you? I thought you were destroyed by Henoch. ","r" ].addLine;
[ "SARGON: I have power even Henoch does not suspect, beloved. ","r" ].addLine;
[ "MULHALL: Yes. Yes, I see. I understand. ","r" ].addLine;
//[ "Just as we would have placed our consciousness within robots, ","r" ].addLine;
[ "Sargon has placed his (consciousness) into the Enterprise. ","r" ].addLine;
[ "CHAPEL: Doctor. ","r" ].addLine;
[ "MULHALL: Doctor, leave us. Sargon has a plan. We have much work to do.","r" ].addLine;
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
			[1,1,1,1]/2 => _.warpTo(p.quarters[e.start][[5,6,7]]),
			[],
			{|i|
				LFTri.ar( i.freqSeq ) 
				* Env.asr().kr(gate:i.gateSeq)
			},
			{|i|
				Mix.ar(i) /30 
				=> EchoNone.ar(_,0.2,0.2,5)
				=> Pan2.ar(_,SinOsc.kr(0.7))
				=> CrossoverDistortion.ar(_).wet(0.09) / 3
				* Env.linen(0,2,3).kr(2,gate:1)
			}
		).play
});
["(Then we see the three blackened and broken spheres.) ","r"].addLine;
["MCCOY: Jim, the receptacles. Spock's consciousness was in one of them. ","r"].addLine;
["KIRK: It was necessary. ","r"].addLine;
["MCCOY: What are you talking about? There is no ","r"].addLine;
["Spock to return to his body. You've ","r"].addLine;
["killed a loyal officer, your best friend. ","r"].addLine;
["KIRK: Bones, prepare a hypo. The fastest, deadliest poison to Vulcans. ","r"].addLine;
["Spock's consciousness is gone. We must kill his body, the thing in it.","r"].addLine;
)
