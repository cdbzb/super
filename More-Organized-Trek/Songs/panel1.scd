(
s.waitForBoot{ 
Song(\panel1,[]).current;
//(A panel slides back to reveal a much larger area, with rock walls, and a glowing sphere elegantly poised on an angled support.) 
/*SARGON: (the glowing sphere)*/[" Welcome. I am Sargon. ","r",].addLine; 
/*SPOCK:*/[" Sargon, would it harm you if I ","r",].addLine; 
/*SARGON:*/[" You may use your tricorder, Mister Spock.","r"].addLine;
["Your readings will show energy but no substance. ","r"].addLine;
["Sealed in this receptacle is the essence of my mind. ","r",].addLine; 
/*SPOCK:*/[" Pure energy. Matter without form. ","r",].addLine; 
/*KIRK:*/[" Impossible. ","r",].addLine; 
/*MCCOY:*/[" But you once had a body of some type? ","r",].addLine; 
/*SARGON:*/[" A body much as yours, my children, although our minds were infinitely greater. ","-5 1 2 2 1 3".dm(\g) ++ "4 3 2 -6 -7 1 ".dm('a-') ++ "11 7 12 11 7 6 6 5".dm(\e)].addLine; 
P.tune(\much);
P.tune('much ', { |i| Pmul(\freq,0.5,i) => Pbindf(_,\instrument, \sawSynthSustain,\amp,0.04)});
P('dyad',start:\much,syl:17,music: {|p b e|
	(
		freq: [ -1,1, 3 ].df(\a),
		instrument:\sawSynthSustain,
		att:1.5,
		amp:0.05,
		rel:3
	).play
});
P('chords',start:\much,syl:5,music: {|p b e|
	v = VoiceLeading(
		[
			[ 4,  3,  \_, 2 ],
			[ 1,  1,  -7, \_ ],
			[ -6, -5, \_, \_ ]
		],
		b.drop(1).parse([1, 0.66,0.34,1  ])
	).df('a-').p
	=> {|i| i<> (instrument: \visual_pad,amp:0.2) => _.play; i<>(instrument:\harp, amp:0.03) => _.play}
	//=> _.play
});
P('bass',start:\much,syl:8,music: {|p b e|
	[
		freq: [ [-6, 6 ], [-5.5, 5.5 ]  ].df('a-',3) ++ "7 12 11 7 6 4".df(\e,3) =>_.q,
		dur: b.drop(1).parse([3,1, 1, 1, 1, 1, 1, 2]).q,
		depth:0,
		freqLag:0.15,
		legato: [0.9,0.9,1,1,1,1,1,1].q
		
	].pma(\sparkTriangle).play
});
["(infinitely)","4 3 2 1".dm(\e,\whole)].addLine;
P.tune('(infinitely)', Pmul(\freq, [1,0.5],_));
/*KIRK:*/[" That's twice you've referred to us as my children. ","1 6 2 3 2 3 7 6 6 7.5 2".dm(\f,\mixolydian) ].addLine; 
P.tune(\That);

/*SARGON:*/[" Because it is possible you are our descendants, Captain Kirk. ","1 3 5 7 12 7 5 3 2 4.5 6 11.5 13 12 14.5 12".dm(\f,4)].addLine; 
P.tune(\Because);
["Six thousand centuries ago, our vessels were ","r"].addLine;
["colonising this galaxy, just as your own starships have now ","r"].addLine;
["begun to explore that vastness... ","r"].addLine;
["As you now leave your own seed on distant planets, ","r"].addLine;
["so we left our seed behind us.","r",].addLine; 

///*MULHALL:*/[" Our studies indicate that life on our planet, Earth, evolved independently. ","r",].addLine; 
///*SPOCK:*/[" That would tend, however, to explain certain elements of Vulcan prehistory. ","r",].addLine; 

/*SARGON:*/[" In any case, I do not know. (baby) It was","5 11 5 3 7 6 5 5 6 5 4 3 4 3 2 1 6".dm(\d)].addLine;
P.tune(\In);
["so long ago, and the records of our travels were","r"].addLine;
["lost in the cataclysm which we unleashed upon ourselves. ","r",].addLine; 
/*KIRK:*/[" A war? ","r",].addLine; 
/*SARGON:*/[" A struggle for such goals and the unleashing of such power that you could not comprehend. ","r",].addLine; 

///*KIRK:*/[" Then perhaps your intelligence wasn't so great, Sargon. We faced a similar crisis in our early nuclear age. We found the wisdom not to destroy ourselves. ","r",].addLine; 
///*SARGON:*/[" And we survived our primitive nuclear era, my son. But there comes to all races an ultimate crisis which you have yet to face.","r",].addLine; 
///*KIRK:*/[" I don't understand. ","r",].addLine; 

/*SARGON:*/[" One day our minds became so powerful, we dared think of ourselves as gods. ","r",].addLine; 
/*KIRK:*/[" You said you wanted our help. What is it you wish? ","r",].addLine; 
})
