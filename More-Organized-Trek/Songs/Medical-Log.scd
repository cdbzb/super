(
// line 380
Song(\medical,[]).current;
["Medical Log. (boom) Stardate 4770.3. ",[4,3,2,1,-5, 1,-7,-4, -7,1,2,3, 1, -7,3].dm(\f)].addLine;
~justTheTune.('Stardate');
[ "Do I list one death or two? " , [1,2,1,5,5,6,4.5].dm(\g)].addLine;
P.tune('one death',Pmul(\freq,0.5,_));
P(\bassUp,syl:2,start:'one death',music:{|p b e| 
	[
		freq: [1,1,-5,2].df(\g,octave:3).q,
		dur:b.drop(1).parse([1,2/3,[1/3,1],1]).q
	].pp
});
P(\chord,start:'one death',syl:2,music:
	{ |p b e|
		(strum:0.05,midinote:[1,3,5,11].dm(\g,scale:\minor)).play
	}
);
//[" When Kirk's body died, ","r"].addLine;
//["Sargon was too far /*distant*/ ","r"].addLine;
//["from his receptacle to transfer back. ","r"].addLine;
["Sargon is dead. But is captain Kirk dead? (boom) ",[2,3,-5,1,-6,-7,1,-6,3.5,-7.5,-7.5].dm(\d,scale:\dorian)].addLine;
P.tune(\Sargon,{|i| Pfin(10,i) => Pset(\legato,[1,1,1,1,1,1,3,3,3,2].q,_)});

//bass patch
Song.resources.bassUp = (\instrument:\sawTw,amp:0.2,out:0);

P(\bassUp,start:\Sargon,syl:2,music:{|p b e| 
	[
		freq: [3,[ 2,6.5 ],[ 1.5,6.5 ]].df(\d,scale:\minor,octave:3).q,
		dur: b.drop(1).parse([5,2,1])+[0,0,p.durs['His body'].list[0]]=>_.flat=>_.q,
		legato: [1,1,1].q
	].asEvent =>
	{|e|
		VoiceLeading([
			[3,2  ,1.5],
			[\r,6.5,\_ ]
		],
			e.dur.list
	).df(\d,scale:\minor,octave:3).p =>Pbindf(_,\legato,1) 
	=> {|i| i<>p.bassUp }  => _.play
	}
});
["His body is, but his ",[2.5,3, 1,-5.5, -6.5,1].dm(\c)].addLine;
P.tune('His body');
P(\bassUp,syl:0,start:'His body',music:{|p b e| 
	[
		//freq: [5.5,4.5].df(\c,octave:3).q,
		freq: [[11, 1 ],\r].df(\c,octave:3).q,
		//dur:b.drop(1).parse([[1,1,1/2],[1/2,1,1]]).q,
		dur:b.sum;
	].p
	<> p.bassUp => _.play
	
});
["consciousness is still in the receptacle ",[2,1,-7,2,4,2,3,4,3,1,-5].dm(\c,scale:\mixolydian)].addLine;
P.tune(\consciousness);
P(\bassUp,start:\consciousness,music:{|p b e| 
	[
		freq: [[-1, 1 ],[-3, 3 ]].df(\f,octave:3).q,
		dur:b.parse([8,3]) + [0,p.durs[\earlier].list[(0..3)].sum] =>_.q
	].p
	<> p.bassUp => _.play
});
P(\lick,start:\consciousness,music:{|p b e| 
	[
		freq: [5,4,3,2,1].df(\g,scale:\minor).q,
		amp:0.01,
		dur: b.q,
		instrument:\sparkTriangle
	].pp
});
["// it had been transferred into earlier.",[2,3,4,5,3,4,2,4,3,2].dm(\g,octave:4)].addLine;
P.tune(\earlier);
P(\lick,start:\earlier,syl:4,music:{|p b e| 
	[
		freq: [7,5,3].df(\d,scale:\mixolydian).q,
		amp:0.02,
		dur:b.drop(1).q,
		instrument:\sparkTriangle
	].pp
	
});
P(\bassUp,syl:2,start:\earlier,music:{|p b e| 
	(
		//(freq:[1].df(\e)).play
		//instrument:\sawSynthSustain,
		//amp:[0.05,0.004,0.003,0.002,0.001],
		freq: [3,13].df(\c,octave:[3,4]),
		dur:b.sum
	)
	++ p.bassUp => _.play
});
[ "[SickBay] (The medical team hook Kirk's body up to a life support machine.) ","r" ].addLine;
P(\machines,start:\SickBay,music:{|p b e| 
	var chord=[1,3,5,7].df(\b,scale:\locrian);
	{
		{
			var pitchClasses = Dseq(chord,inf);
			var octaves = Dseq([1,2,4,8]/2,inf);
			octaves = Demand.kr(Dust.kr(5),1,octaves);
			pitchClasses = Demand.kr(Dust.kr(15),1,pitchClasses);
			Saw.ar(pitchClasses * octaves,0.01) 
		}!4
		//=> FreeVerb.ar(_,1,1)
		=> DWGReverbC1C3.ar(_)
		*Env([0,1,1,0],[5,5,10],\sin).kr(1,2)
	}.play
});
[ "NURSE: All his vital organs are now working, Doctor. ","r" ].addLine;
[ "MCCOY: Yes, we can keep them going for a few ","r" ].addLine;
[ "weeks, or a month. For all the good it'll do.","r" ].addLine;
)

//next up: Plastic person

//~recorder.(Song.currentSong,1)
//Song.pbind[0].play
//Song.writeLyricDurationFile
//Song.save

/*
*/
)
