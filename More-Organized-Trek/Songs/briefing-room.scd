

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
[ "SPOCK: Once inside their mechanical bodies, engineer, they can leave this planet, travel back with us.","r" ].addLine;
[ "With their knowledge, mankind could leap ahead ten thousand years. ","r" ].addLine;
[ "KIRK: Bones, they'll show us medical advances,","r" ].addLine;
[ "miracles you never dreamed possible.","r" ].addLine;
[ "Scotty, engineering advances.","r" ].addLine;
[ "Vessels this size with engines the size of walnuts. ","r" ].addLine;
[ "SCOTT: Ach! You're joking. ","r" ].addLine;
[ "SPOCK: No, he's not. ","r" ].addLine;
[ "MCCOY: They're giants, and we're insects beside them. ","r" ].addLine;
[ "They could destroy us without meaning to. ","r" ].addLine;
[ "And all he wants is the body of our captain and our second in command, too. Coincidence? ","r" ].addLine;
[ "KIRK: They selected us as the most compatible bodies. ","r" ].addLine;
[ "MCCOY: What's your attitude on that, Doctor? ","r" ].addLine;
["MULHALL: Well, if we all agree, I'm willing to host Thalassa's mind.","r"].addLine;
/*
Well .. if we all agree.....
Im a scientist - and I'm willing
to host Thalassa's mind
The opportunity is an extraordinary one. for experimentation, observation.
*/
["I'm a scientist. (and I'm willing)","r"].addLine;
["The opportunity is an extraordinary one for experimentation, observation. ","r"].addLine;//p14
["SCOTT: A starship engine the size of a walnut? ","r"].addLine;
["Thats impossible","5 5 11 5 1".dm('a-')].addLine;
//["But I don't suppose there'd be any harm in looking over diagrams on it. ","r"].addLine;
["KIRK: Bones? You could stop all this by saying no. ",[7].dm(\b,4,\mixolydian) ++ [3,4,7,4,3,2,3,4].dm(\c,5,\mixolydian) ++ [5].dm(\a,4)].addLine;
P.tune('stop all this');
P(\chord,start:'stop all this',music:{|p b e| 
	[
		//freq: [1,3,5,7].df(\b,4,\mixolydian),
		freq: [ [1,3,4.5,7].df(\b,4,\mixolydian), \r, [1,3,5,11].df(\a,4,\minor) ].q,
		dur: b.parse([1, 8, 1]).q
	].pp
});
["That's why-- I called you all here together. ","r"].addLine;
["(boom) We'll all be deeply involved. It must be unanimous. ","-1 12 13 12 12 11 7 6".dm(\c) ++ "2 6 5 4 3 4 1 -6".dm('f#')].addLine; //p11
P.tune(\involved);
P(\bass,start:\involved,music:{|p b e|  // passing tone right before end please
	[
		freq: [1, 1, 4, 1.5, 2.5, 4.5].df(\c,3).q,
		dur: b.parse([ [1, 1, 0.5],[0.5, 1], 4, [1,1,1, 2/3],[1/3,1], 3 ]).q
	].pp; 
	
});
P(\chords,start:\involved,music:{|p b e| 
	[
		freq: [\r, [3,5,7],[3,5,7], [-6, 1, 4]].df(\c).q,
		dur: b.parse([1, [1, 1/2], [1/2, 1], 1]).q
	].pp
	
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
P(\strum,start:'possible miracles',music:{|p b e| 
	(
		freq: "-1 1 3 5 7".df('e-'),
		strum: 0.06
	).play
});
["simple basic understandable","5 5 6 6 7 11 7 6 5".dm('e-',5,\mixolydian)].addLine;
P.tune(\understandable);
Song.quarters[\understandable] = Song.parseBeats(\understandable,"q q q q q e ee e q".asBeats);
P(\bass,start:\understandable,music:{|p b e| 
	[
		freq: "1 1 4 4 7 7 4 4".df('e-',3,\mixolydian).q,
		dur: p.quarters[\understandable].q,
		instrument:\sawSynth
	].pp
});
[" why that overrides all danger. And let's not ", "6 5 12 11 7.5 6.5  12 13 11 3 4 5".dm(\d,5,\minor)].addLine;
P(\bass,start:\override,music:{|p b e| 
	[
		freq: [1, 1.5, 2, -5].df(\g,3,\minor).q,
		dur: b.parse([3,1,3,2]).q,
		instrument: \sawSynthSustain
	].pp
});
P.tune(\overrides);
["kid ourselves that there is no potential danger in this. ", "5 4 2 -6 -7 1 1.5 1.5 2 3 4 2 -7 -5".dm(\f)].addLine;
P.tune(\kid);
}
)
