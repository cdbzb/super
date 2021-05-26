// NOTE about Cepstral Vocoders!!!
// ~vocoderPattern uses SynthDef \busVersion
// ~vocoderPattern is in Library/functions

// [Laboratory]

(
Song(\silverLake,[]).current;
	 Song.currentSong.infrastructure={
		FunctionList.new.array_([
			~synthsLoaded.isNil.if{"/Users/michael/tank/super/song-Synthdefs.scd".load},
		]).value
	}.inEnvir;
[ "(Sargon and Thalassa are working...","r",~test].addLine;
Song.durs['working']=[8].q;
[ "when their hands touch.","r" ].addLine; 
~justTheTune.(\hands);
["/*MULHALL:*/ Sargon, I remember a day long a-- ","r"].addLine;
["go. (ta da da boom da) We ", [3, 5,5,5,5,5].dm(\e)++[3].dm(\a)].addLine;
~justTheTune.('go.');
["sat beside a si -- lve --r ",[1,-7,-6,-7,3,4,1,3].dm(\d,octave:6)].addLine;
~justTheTune.(\sat);
["lake. The air was scented with the ","r"].addLine;
["flowers of our planet. ",[1,-7,1].dm(\g,scale:\mixolydian)++[6,5,4,3,6,5,4,3].dm(\d)+12].addLine;
~justTheTune.(\flowers);
(
	~planetArpeggio = [6,5,-6,1, 4,3,-5,-7, 6,5,-6,3, 4, 3,-5,1].df(\d)=>{|i| [dur:0.5,freq:i.q].p};
	~planetBass = [dur:[1].q++[4].q(inf) / 2,freq:[\r,6,5,4,11].df(\d,octave:3).q].p;
);
["/*KIRK:*/ I remember. You held my han-- -- -- -- -- -- -- -- -- -- -- d like ",[4,3,3,2].dm(\c)++[-4,-5,-6,-7,1,-7,-6,-7,1,2,3,2,1,2,3,4,5].dm(\g)].addLine;
~justTheTune.('I remember.');
["this.  (He kisses it, as Spock comes in.) ",[5,4,4,3,3 ].dm(\c,octave:6)].addLine;
~justTheTune.('this');
P(\chords,start:'kisses',music: {|p b e|
	b.postln;
	VoiceLeading([
		[3,\_,2 ,\_,\_,],
		[1,\_,-7,\_,\_,]
	],b.asArray
	).dm('b-',scale:\mixolydian,octave:6).pp
});
["I think it is best not to remember so well. (boom) ",[3,2,3,1,-5,2,1,-7,-6,-7,-5,-2.5,-4.5].dm(\d)].addLine;
~justTheTune.('best');
P(\bassNote,start:'best not',syl:11,music: {|p b e|
	(instrument:\stringyy,freq:[1].df('a-',octave:4)).play
});
["/*SPOCK:*/ In two days, you'll have your own hands, Thalassa. ",[3,2,4,3,4,3,3,2,4,1,-7].dm('a-')].addLine;
~justTheTune.('two days');
//~twoDaysQuarters= Song.durs['two days'].list.asArray.parseBeats([0.5,0.5,1,1/3,1/3,1/3,3/4,(1/4+(3/4)), 1/4,3/4,(1/4+1)]);
P(\bass,start:'two days',syl:1,music:{|p b e|
	var quarters = b.drop(1).asArray.parseBeats([1,1/3,1/3,1/3,2/3,(1/3+(3/4)), 1/4,3/4,(1/4+1)]);


	[dur:1,freq: [-4,-6,-5].df('a-',octave:[  4 ]).q,instrument: \stringyy, amp:0.35]
	=>_.p
	=>Pmul(\dur,2,_)
	=>_.trace=>_.play(quarters.asTempoClock)
});
["(intro)","r",(104/60),16].addLine;
P(\bass,start:'intro',music: {|p b e|
	[5,5,14,5]++( 5!4 )++( 11!7 ) ++ 7
	=>_.df('e-',octave:2)
	=>{|i| [
		amp:0.2,
		out:0,
		freq:i.q(2),
		dur:0.5,
		rel:0.9,
		trigger:1,
		instrument:\sawSynth
	].pma(
//		\sawSynthTrigger
		\sawSynthSustain
	).play(clock:{ t=TempoClock.new(104/60);t }.value) };
} );
P(\808,start:'intro',music: {|p b e|
	"x.x...x.x.x...x.".asDrumPat(4,4)=>[instrument:\bd_808,dur:_,amp:0.5]=>_.p=>_.play(clock:t);
	"xxxxxxxxxxxxxxxx".asDrumPat(4,4)=>[amp:0.08,instrument:\hat_808,dur:_]=>_.p=>_.play(clock:t);
	"....x.......x...".asDrumPat(4,4)=>[amp:0.10,instrument:\sn_808,dur:_]=>_.p=>_.play(clock:t)
	
});
P(\lick,start:'intro',music: {|p b e|
	[\r,[5,4],6,`6,\r,[5,4],4,`4].asMelody.df('b-',octave:4)=>_.pm(\sawSynthSustain)=>Pmul(\dur,2,_)=>_.play(t)
});

["Mechanically efficient and ","r"].addLine;
["quite human-looking. ","r"].addLine;
["Android robot hands, of course. ","r"].addLine;
["Hands without feeling. ","r"].addLine;
["Enjoy the taste of life while you can. ","r"].addLine;
["/*KIRK:*/ (But.. ) our minds will have survived. ","r"].addLine;
["And as androids, we can move among the ","r"].addLine;
["people who do live, teaching them, ","r"].addLine;
["helping them not to make the errors we did. (pain) ","r"].addLine;
["/*MULHALL:*/ What is it, Sargon? ","r"].addLine;
["/*KIRK:*/ Nothing. Our next injection will renovate me. (boom) ",[1,1].dm('e-')++[2,3,1,3,-7,1,2,1,-7,-5,-3].dm('d',scale:\mixolydian,)].addLine;
~justTheTune.('renovate',(_.fin(12)));
P(\dyad,start:'renovate',music:{|p b e|
	[
		freq:
		 [-5,-7]!2=>_.unbubble ++ [-17.5,-7.5] 
		=>_.df('e-',octave:4,scale:\mixolydian )=>_.q,
		dur:b.parse([1,2,5]).q,
		instrument:\stringyy,
		amp:0.25,
	].pp
}
);
P(\cord,start:'renovate',lag:-1.5,syl:7,music:{|p b e|
	( 
		freq:[-5,-7,1,3].df('d',scale:\mixolydian),
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
		freq:[1,11].df('a-',octave:2 ),
		amp:0.25,
	).play
}
);
["Do not be concerned.",[3,4,2,3,-7].dm('c',octave:5,scale:\minor )].addLine;
)
