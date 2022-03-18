
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
	Song(\trashme,[]).current;
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
	["SPOCK: Sargon! No, Sargon, please. Lett me. Let me transfer. ",[1,2,3,2,1, 4, 5, 4, 6, 5, 6, 7].dm(\c),].addLine;
	Song.testRPP=
	VocalRPP('Lett','test');
	P.tune('Lett');
	P(\vox,start:'Lett',music:{|p b e| 
		{
			PlayBuf.ar(2, p.testRPP.buffer.bufnum )
		}.play
	});
	P(\mega2,start:'Lett',music:{|p b e| 
		5.do{|i|
			MegaBind(
				[
					Song.tune[0].list
				],
				Song.durs[0].list,
				[],
				{|i|
					Pulse.ar( i.freqSeq.midicps*8.rrand(9.0),0.3 ) 
					* 0.1
					* Env.asr().kr(2,gate:i.gateSeq)
				},
				{|i|
					Mix.ar(i) * [0,1]
				}
			).play;
			Synth(\soundInMorph)
		}
	});
	P(\mega,start:'Lett',music:{|p b e| 
		MegaBind(
			[
				Song.tune[0].list
			],
			Song.durs[0].list,
			[],
			{|i|
				Pulse.ar( i.freqSeq.midicps,0.3 ) 
				* 0.1
				* Env.asr().kr(2,gate:i.gateSeq)
			},
			{|i|
				Mix.ar(i) * [0,1]
			}
		).play
	});
	P(\voxTest,start:'Lett me',music:{|p b e| 
		{
			p.testRPP.buffer.bufnum
			=> PlayBuf.ar(1,_)
		}//.play
	});
})
)
