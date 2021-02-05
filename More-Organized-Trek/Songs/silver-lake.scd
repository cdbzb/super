// [Laboratory]

(
Song(\silverLake,[]).current;
	 Song.currentSong.infrastructure={
		FunctionList.new.array_([
			~synthsLoaded.isNil.if{"/Users/michael/tank/super/song-Synthdefs.scd".load},
		]).value
	}.inEnvir;
[ "(Sargon and Thalassa are working...","r",~test].addLine;
P(\figure,'working',music:
{|p b e|
	[
		freq:[1,3,5,1,4,6,5,4].df('a',octave:4 ).q
	].pp
});
Song.durs['working']=[8].q;
[ "when their hands touch.","r" ].addLine; 
~justTheTune.(\hands);
["/*MULHALL:*/ Sargon, I remember a day long a-- ","r"].addLine;
["go. We ","r"].addLine;
["sat beside a silver ","r"].addLine;
["lake. The air was scented with the ","r"].addLine;
["flowers of our planet. ","r"].addLine;
["/*KIRK:*/ I remember. You held my hand like ","r"].addLine;
["this.  (He kisses it, as Spock comes in.) I think it ","r"].addLine;
["best not to remember so well. ","r"].addLine;
["/*SPOCK:*/ In two days, you'll have your own hands, Thalassa. ","r"].addLine;
["(intro)","r",(104/60),16].addLine;
P(\bass,start:'two days',music: {|p b e|
	[5,5,14,5]++( 5!4 )++( 11!7 ) ++ 7
	=>_.df('b-',octave:2)
	=>{|i| [
		amp:0.4,
		out:0,
		freq:i.q,
		dur:0.5,
		rel:0.9,
		trigger:1,
		instrument:\sawSynth
	].pma(
//		\sawSynthTrigger
		\sawSynthSustain
	).play(clock:TempoClock.new(104/60)) };
} );

["Mechanically efficient and ","r"].addLine;
["quite human-looking. ","r"].addLine;
["Android robot hands, of course. ","r"].addLine;
["Hands without feeling. ","r"].addLine;
["Enjoy the taste of life while you can. ","r"].addLine;
["/*KIRK:*/ Our minds will have survived. ","r"].addLine;
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
