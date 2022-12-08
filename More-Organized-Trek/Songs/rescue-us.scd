(
//[Bridge]
Song(\rescue,[]).current;

// Captain's Log. Stardate 4768.3.
// The Enterprise is in orbit above a planet whose 
// surface, our sensors tell us, 
// is devoid of all life, 
// a world destroyed and dead for at least a half million years. 
// Yet from it comes a voice, 
// the energy of pure thought, 
// telling us something has survived here 
// for those thousands of centuries.

["/*KIRK:*/ (dictating log) Since exploration and contact with alien intelligences is our primary mission, I've decided to risk the potential dangers and resume contact. Log entry out. How long before Starfleet receives that?","r"].addLine;
["/*UHURA:*/ Over three weeks at this distance, sir.","r"].addLine;
["/*SPOCK:*/ Captain.","r"].addLine;
["/*KIRK:*/ Got something?","r"].addLine;
["Sensors registering some form of energy deep inside the planet.","3 1 4 3 1 3 4 5 7 6 4  2 1 -7 -6 -6 -5".dm(\e,\mixolydian)].addLine; /*SPOCK:*/ 
P.tune();
["/*SARGON [OC]*/(boom) Your probes have touched me, Mister Spock.",[\r, 4, 4, 4, 4, 3, 2, 1, 2, 3].dm(\c,\minor)].addLine;
P.tune();
P(\bass, music: { |p b e|
	[
		freq:[1, 7, 4].df(\f, [2,3],\mixolydian).q,
		dur:b.parse([4,4,2]).q
	].pp
});
["/*SPOCK:*/ Reading energy only, Captain. No life forms.", "1 2 3 2 1 4 2 1 -6 4 5.5 2".dm('f#',\lydian)].addLine;
P.tune;
[" I have locked your transporter device on my co-ordinates.","5 5 5 6 5 4 3 2 4 3 2 1 3 2 2".dm(\a,4)].addLine;/*SARGON [OC]*/
Song.setTempoMap('co-ordinates',"q e eq e eq e eq e eq e eq e eq e eq");
P(\bass, music: { |p b e|
	[
		freq: [6, 5, 4, 5, 6, 7, 11, 5].df(\a,2).q,
		dur: [4,4,1,1,1,1,2,2].warpTo(e.tempoMap).q
	].pp
});
P(\chords, music: { |p b e|
	[
		freq: [ -12,-2,1,3,5,11 ].dup(4) ++ [ -1,1,3,5,11 ] =>_.df(\e) =>_.q,
		dur: "q e eq e eqq".asBeats.warpTo(e.tempoMap).q,
		instrument:\sawSynth,
		out: Effect.bus( _ * Env([1,0.2,0],b.parse([4,8])).kr(2,gate:1) )
	].pp
});
P.tune();

["Please come to us. Rescue us from oblivion."," 3 3 2 2 4 3 -6 1".dm('f#',\minor) ++ "4 4 3 1".dm(\f)].addLine;
P.tune();
P(\laMerChords, music: { |p b e|
	[\A, \c].collect{|i| [1,3,5,6].df(i)}
	=> {|i| 
		[
			freq: [\r] ++ i => _.q,
			dur: b.parse([1, 3, 4]).q,
			instrument:\stringyy
		].pp
	}
});
P(\bass, music: { |p b e|
	[
		freq: [\r,1,-7,6,].df('f#',[3,2],\minor) ++ [5,11].dup.df('f',[3,2]) =>_.q,
		dur: b.parse([1,3, 2,2,  1,3]).q
	].pp
});
P(\answer, syl: 10,music: { |p b e|
	[
		freq: [4,3,1,-6,1,2,3].df(\f).q,
		dur:0.5,
		instrument:\ooh,
		amp:Pseries(0.1,-0.018,inf) / 6
	].pp
});
["/*SPOCK:*/ Coming from deep under the planet's surface, Captain. ","11 12 13 7 12 11 7 5 7 5 4 3 2".dm(\c,\mixolydian)].addLine;
["Under at least one hundred miles of "," 1 2 3 4 5 4".dm(\c,\lydian) ++ "1 2 3 4 5 4 3".dm(\d,\lydian)].addLine;
["(boom boom) solid rock.","-7 1 7 6 7 11".dm(\f)].addLine;
P(\harmony, music: { |p b e|
	[
		freq:"r 11 11 6 5 6".df(\c).q,
		dur: "qq q e eqq q q".asBeats.warpTo(e.tempoMap).q
	].pp
});
Song.setTempoMap(\solid,"q q q e e qq".asBeats);
P.tune;
P(\bass, music: { |p b e|
	[
		freq: "3 4 7 11 3 4 3 4 7 11 12 5 2 2".df(\c,3).q,
		dur: "e e e e x x x x e x x ex x q".asBeats * 2 =>_.warpTo(e.tempoMap) =>_.q
	].pp
});
["I will make it possible for your transporter to beam you"," 5 5 5 6 5 4 3 1 2 3 3  2 2 1 2 3".dm(\b)].addLine;/*SARGON [OC]*/
P.tune();
["(boom) that deep (that deep that deep) beneath the surface. Have no fear."," -5 3 2 3 2 3 2 1 2 3 2 1 -7 1".dm(\b)].addLine;
P.tune();
["/*SPOCK:*/ Reading a chamber now. Oxygen-nitrogen atmosphere, suitable for human life support.","r"].addLine;
["/*KIRK:*/ Lieutenant Uhura, have Doctor McCoy report to the transporter room in ten minutes with standard landing party equipment.","r"].addLine;
["/*UHURA:*/ Yes, sir.","r"].addLine;
["/*KIRK:*/ Spock.","r"].addLine;
["/*SPOCK:*/ Captain, I do wish to inspect whatever this is that lived that long ago.","r"].addLine;
["/*KIRK:*/ And I would like to have my science officer with me on something as unusual as this, but it is full of unknowns and we can't risk both of us being off the ship.","r"].addLine;
// (The lights go out.)
["SULU: All power gone, sir.","r"].addLine;
["KIRK: On the other hand, perhaps this Sargon would like you to come with us.","r"].addLine;
// (Power is restored.)
["SPOCK: Fascinating.","r"].addLine;
["SULU: All normal. No damage at all.","r"].addLine;
["KIRK: I see. Will you transport down with us, Mister Spock?","r"].addLine;
["SPOCK: Evidently, Captain.","r"].addLine;
["KIRK: Mister Sulu, you have the conn.","r"].addLine;
)
