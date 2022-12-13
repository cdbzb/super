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
["(boom boom) Sensors registering some form of energy deep inside the planet.","-1 -1 3 1 4 3 1 3 4 5 7 6 4  2 1 -7 -6 -6 -5".dm(\e,\mixolydian)].addLine; /*SPOCK:*/ 
Song.setTempoMap(\Sensors, "e e e e | E E E E E E | e x xq | Q E Q E e e");
P.tune();
P(\bass, music: { |p b e| //check last note
	[
		freq: [ 1,1,\r,1,1,\r,4,4,\r, 7, 6, 5, 4, 2.5 ].df(\e,[ 3,4 ],\mixolydian).q,
		dur: "e e q | e e q | e e q | e e e e | e".asBeats.warpTo(e.tempoMap).q
	].pp
});
["/*SARGON [OC]*/(boom) Your probes have touched me, Mister Spock.",[\r, 4, 4, 4, 4, 3, 2, 1, 2, 3].dm(\c,\minor)].addLine;
P(\chord, music: { |p b e|
	[
		freq: [-1, 1, 3, 5].df(\f).bubble.q,
		strum: 0.05,
		instrument: \sawSynth,
		out: Effect.bus( FreeVerb.ar(_, mix:1, room:1, damp:[ 0.5,0.6 ]) )
	].pp
});
P.tune();
P(\bass, music: { |p b e|
	[
		freq:[1, 7, 4].df(\f, [2,3],\mixolydian).q,
		dur:b.parse([4,4,2]).q
	].pp
});
["/*SPOCK:*/ Reading energy only, Captain. No life forms.", "1 2 3 2 1 4 2 1 -6 4 5.5 2".dm('f#',\lydian)].addLine;
P.tune();
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
		out: Effect.bus( 
			{|i|
				i * Env([1,0.3,0.1],b.parse([4,8])).kr(2,gate:1)
				=> DWGReverbC1C3.ar(_)
				=> LPF.ar(_,800)
				/6
			}
		)
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
P(\answer, syl: 10, music: { |p b e|
	[
		freq: [4,3,1,-6,1,2,3].df(\f).q,
		dur:0.5,
		instrument:\ooh,
		amp:Pseries(0.1,-0.018,inf) / 6
	].pp
});
["/*SPOCK:*/ Coming from deep under the planet's surface, Captain. ","11 12 13 7 12 11 7 5 7 5 4 3 2".dm(\c,\mixolydian)].addLine;
P.tune();
["Under at least one hundred miles of "," 1 2 3 4 5 4".dm(\f,\lydian) ++ "1 2 3 4 5 4 3".dm(\g,\lydian)].addLine;
P.tune();
["(boom boom) solid rock.","-7 1 7 6 7 11  12 12 7".dm(\f)].addLine;
Song.setTempoMap(\solid,"e e e x x qqq e x xq".asBeats);

P.tune();
P(\click, music: { |p b e|
	[
		dur:1!8 warpTo: e.tempoMap => _.postln => _.q,
	]//.pp
});
P(\harmony, music: { |p b e|
	[
		freq:"r 11 11 6 5 6".df(\c).q,
		dur: 0.5 * "qq q e eqq q q".asBeats warpTo: e.tempoMap q: 1
	].pp
});
P(\bass, music: { |p b e|
	[
		freq: "3 4 7 11 3 4 3 4 7 11 12 5 2 2".df(\c,[2,3]).q,
		dur: "e e e e x x x x e x x ex x q".asBeats  =>_.warpTo(e.tempoMap) =>_.q,
		instrument:\pluckDEnv,
		amp:0.006
	].ppm
});
["I will make it possible for your transporter to beam you"," 5 5 5 6 5 4 3 2 3 4 4 3 3 1 2 3".dm(\d)].addLine;/*SARGON [OC]*/
Song.setTempoMap(\possible,"q e eq e eq e eqqq e eq q q q qqq q q q");
P(\chord, music: { |p b e|
	[
		instrument: \sawSynth,
		freq: [-1,1,3,5].df(\a)
		.bubble
		.q
		,
		strum:0.05,
		out: Effect.bus( FreeVerb.ar(_, mix:1, room:1, damp:0.5), out:0, inputChannels:1, target:nil)
	].pp
});
P(\bass, music: { |p b e|
	[
		freq: "1 1 -7 -7 1 -4 -6 -7 -17 -1 -1".df(\a,[3,4],\mixolydian).q,
		dur: "qe e q e e qe e qe e qe e".asBeats *2 =>_.warpTo(e.tempoMap)=>_.q
	].pp

});
P.tune();
["(boom) that deep (that deep that deep) beneath the surface. Have no fear."," -5 3 2 3 2 3 2 1 2 3 2 1 -7 1".dm(\d)].addLine;
P.tune();
P(\chords, music: { |p b e|
	[
		freq: [\r, [ 5, 7, 13 ], [4, 6, 12]].df(\d).q,
		dur: b.q
	].pp
});
P(\bass, music: { |p b e|
	[
		freq: [1, 4, 5,  1, 4, 5].df(\d,3).q,
		dur: b.parse([2, 3/6,1/6,[2/6,1],3/6,1/6,[ 2/6,1 ]]).q
	].pp
});
["/*SPOCK:*/ Reading a chamber now. Oxygen-nitrogen atmosphere, suitable for human life support.","r"].addLine;
["/*KIRK:*/ Lieutenant Uhura, have Doctor McCoy report to the transporter room in ten minutes with standard landing party equipment.","r"].addLine;
["/*UHURA:*/ Yes, sir.","r"].addLine;
["/*KIRK:*/ Spock.","r"].addLine;
["/*SPOCK:*/ Captain, I do wish to inspect whatever this is that lived that long ago.","7 4 7 7.5 5 6.5 7.5 11 5 3 4 2 3 5 11 12 11 7.5 7.5".dm('e',\minor)].addLine;
P.tune();
P(\bass, music: { |p b e|
	[
		freq: [-1.5,-7,-7.5,-1.5,1,-3,-2,-3, [-4,-5]] .df(\e,[5],\minor).postln.q,
		dur:b.parse([[1, 0.34], [0.66,1], [1,0.34], [0.66,1,  1], 2, 2, 1, 4, 3]).postln.q,
		legato: [2,1,2,1,1,1,1,1,1].q
	].p.trace.play

});
["/*KIRK:*/ And I would like to have my--","-7 3 2 3 1 4 5 4".dm(\g)].addLine;
P.tune();
P(\bass, music: { |p b e|
	[
		freq: [-7, 1].df(\g,[ 3,4 ]).q,
		dur: b.parse([4,4]).q
	].pp
});
["(boom) science officer with me on something as unusual as this, but it i--s","-1 3 2 3 2 3 2 1 -7 1 -6  2 3 4 5 4 3 2 -7 1 2 1".dm(\c,6)].addLine;
Song.setTempoMap(\unusual,"q %x x x x x% e ee e e e e e e x xe x xe e e x xq".rhythm);
P(\click, music: { |p b e|
	[instrument: \hihat,dur:1.dup(10).warpTo(e.tempoMap).q]//.pp
});
P(\bass, music: { |p b e|
	[
		freq: "11 6 13 11 4 14 6 2 12 2 5 15 5".df(\c,3).q,
		dur: b.parse([6, [1,0.5],0.5,1, 2, 1,1, [2,0.34],0.66,[1,0.34],[ 0.66,1 ],1,2]).q
	].pp
});
P.tune();
["(boom) full of unknowns","-1 3 2 2 2".dm('f#',6,\minor)].addLine;
Song.setTempoMap(\unknowns,"q qq Q E q ");
P.tune();
P(\click, music: { |p b e|
	[dur: 1.dup(4).warpTo(e.tempoMap).q,instrument:\hihat].pp
});
P(\bass, music: { |p b e|
	[
		freq: "1 1 -7 -7 -6".df('f#',[3,4],\mixolydian).q,
		dur: "qe e qe e ee".asBeats/1 warpTo: e.tempoMap q: 1
	].pp
});
P(\dyad, music: { |p b e|
	(
		instrument: \stringyy,
		freq: [5,1].df('f#',4),
		dur: b.parse([4])
	).play
});
["and we can't risk both of us being off the ship.","5 6 5 4 3 2 1 -7 -6 -7 -5 1".dm(\e)].addLine;
P.tune();
// (The lights go out.)
["SULU: All power gone, sir.","r"].addLine;
["KIRK: On the other hand, perhaps this Sargon would like you to come with us.","r"].addLine;
// (Power is restored.)
["SPOCK: Fascinating.","r"].addLine;
["SULU: All normal. No damage at all.","r"].addLine;
["KIRK: I see.","r"].addLine;
[" Will you transport down with us, Mister Spo--ck?","1 -5 1 2 3 2 1 -5 -4 -4 -3".dm('f#')].addLine;
Song.setTempoMap(\Will," e e e e| e e q|q ex x | e e");
P.tune();
P(\horns, music: { |p b e|
	[
		[
			freq: [\r] ++ "13 12 11 7 7 6 5 4 4 3 2 -7".df('f#',4) q: 1,
			dur: "qq e e e e  e e e e  e e e e".asBeats.warpTo(e.tempoMap).q,
		].p 
		, [
			freq: [\r] ++ "11 7 6 5 4 3 2 1 -7 -5 ".df('f#',4) q: 1,
			dur: "qq e e e e ee e e  ee e e".asBeats.warpTo(e.tempoMap).q,
		].p
	]
	=> Ppar(_)
	<> [ instrument: \sawSynth,amp:0.05 ].p
	=> _.play
});
P(\bass, music: { |p b e|
	[
		freq: "1 -4 -5 -5".df('f#',[3,4]).q,
		dur: "qqqq qq q ".asBeats.warpTo(e.tempoMap).q
	].pp
});
["SPOCK: Evidently, Captain."," 4 3 2 1 -7 1".dm('f#')].addLine;
P.tune();
Song.setTempoMap(\Evidently, "qe e qe e qe e");
P(\line, music: { |p b e|
	[
		freq: "4 3 2 1 -7 1".df('f#',4).q,
		dur: "q q q q q q q".asBeats.warpTo(e.tempoMap).q 
	].pp
});
P(\bass, music: { |p b e|
	[
		freq: [\r, [-6,6] ].df('f#',3) q: 1,
		dur: b.parse([ 2, 4 ]).q
	].pp
});
["KIRK: Mister Sulu, you have the conn.","r"].addLine;
)
