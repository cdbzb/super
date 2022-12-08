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
["/*SARGON [OC]*/: Your probes have touched me, Mister Spock.","r"].addLine;
["/*SPOCK:*/ Reading energy only, Captain. No life forms.","r"].addLine;
[" I have locked your transporter device on my co-ordinates.","5 5 5 6 5 4 3 2 4 3 2 1 3 2 2".dm(\a,4)].addLine;/*SARGON [OC]*/
Song.setTempoMap('co-ordinates',"q e eq e eq e eq e eq e eq e eq e eq");
P(\bass, music: { |p b e|
	[
		freq: [6, 5, 4, 5, 6, 7, 11, 5].df(\a,2).q,
		dur: [4,4,1,1,1,1,2,2].warpTo(e.tempoMap).q
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
		freq: [\r,1,-7,6,7.5].df('f#',[3,2],\minor).q,
		dur: b.parse([1,3, 2,3, 3]).q
	].pp
});
["/*SPOCK:*/ Coming from deep under the planet's surface, Captain. Under at least one hundred miles of solid rock.","r"].addLine;
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
