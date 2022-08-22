(
s.waitForBoot{ Song(\chamber1,[]).current;
	//[ Chamber ] 
["SPOCK: Captain, the security guards. ","r"].addLine;
["KIRK: Kirk here. ","r"].addLine;
["SCOTT [OC]: Can you read me, Captain? ","r"].addLine;
["KIRK: Yes, Scotty, and I shouldn't be able to this deep inside the planet, but perhaps this has been arranged for us, too. Is the security guard up there?","r"].addLine;
//[ Transporter Room ]
["SCOTT: They're fine. They Just didn't dematerialise.","r"].addLine;
//[ Chamber ]
["SCOTT [OC]: I don't like it, sir. ","r"].addLine;
["KIRK: No problem yet. Maintain alert. Kirk out. ","r"].addLine;
["MULHALL: Atmosphere report, Captain. ",[11,7,5,4,3,2,3].dm(\b,5,\mixolydian)].addLine;
P.tune(\Atmosphere, {|i| Pmul(\freq,[1,0.5],i) <> [out: Effect(FreeVerb.ar(_,0.8,0.8), inputChannels:2).bus.index, \legato:[6,2,5,2,4,2,3].q ].p });
Pdefn(\lower,7.df.bubble.q(inf)); ///NOW WHAT?
( Song.trillStart = { |lowerNoteDegree p b e octave=5 amp=0.03|
	Song.trillFreq=lowerNoteDegree;
	3.do{
		[
			freq:Pswitch1([ Pdefn(\lower),11.df],[0,1].q(inf)),
			dur: Pwhite(0.05,0.16,inf),
			legato:Prand([0.8,1.1],inf),
			pan:(-1).rrand(1.0),
			amp:amp*3,
			out: 
			Effect({|i| i =>FreeVerb.ar(_,0.8,0.8)}).bus.index// * Env.linen(0,[9,8].sum,4).kr(2,gate:1) },inputChannels:2).bus.index

		].pm(\default) //=> 
		//Pfindur(b.sum,_) 
		=> _.play
	}
};
);
( Song.trillFunc={|freq, time|
	Pdefn(\lower, Penv([Song.trillFreq,freq,freq],[ time, inf ]));
	Song.trillFreq=freq;
};
);
(
Song.triller = { 
	VarSaw.ar( LFPulse.ar(
		LFBrownNoise1.kr(1).range(5.5,7)
	).range(\lower.kr(7.df,\portamentoRate.kr(1)),\higher.kr(11.df,6)
	),0,0.5.rand, 0.05 )
	=> Pan2.ar(_,Rand(-1,1.0))
	=> LPF.ar(_,4000)
	//=> TwoTube.ar(_, k:0.01, loss:0.997, d1length:[333,456], d2length:[543,611], mul:1.0, add:0.0)
	=> { |i| DWGReverbC1C3.ar(i, len:100, c1:1, c3:10, mix:0.1, coefs:nil, perm:nil, doprime:0) => Pan2.ar(_,0.9)+i}
	=> Disintegrator.ar(_, probability:\noise.kr(0), multiplier:WhiteNoise.kr().range(0,-1))
	* \amp.kr(0.1)
	* Env.asr(0.05).kr(2,gate:1)
}.asSynthDef.add.name;
Song.trillSynthFunc = {|note| 
	Song.trillBus = Song.trillBus ? Bus.control; 
	Song.trillBus.set(0.1);
	(1..3).collect{Synth(Song.triller,[\lower,note.df]).register.map(\amp,Song.trillBus)}
	
};
Song.changeTrill = { |note|
	( try{ Song.trillSynth[0].isRunning }==true ).if{
		fork{ Song.trillSynth.do( { |i| i.set(\lower,note.df);0.4.rand.wait} )}
	}{Song.trillSynth = Song.trillSynthFunc.(note)}
};
);
P(\trill,start:\Atmos,music:{|p b e| 
	Song.trillSynth = Song.trillSynthFunc.(7)
});

["A fraction richer in oxygen than usual for us, but otherwise normal. "," 3 4 5 7 11 6 13 12 5 6 12 11.5 6, 4.5 5.5 4 5 6 7 12 11".dm(\c)].addLine;
P.tune(\oxygen,{|i| Pmul(\freq,[1,0.5],i) => Pset(\legato,4,_) });
["SPOCK: This vault was constructed about a half a million years ago.", "5 7 6 5 4 3 2 3 4 6 5 4 3 2 1".dm(\c,5,\mixolydian)].addLine;
P.tune(\vault);
P(\trill,start:\vault,music:{|p b e| 
	p.changeTrill.(6.5)
});
["About the same time the planet surface was destroyed, if our sensor readings are accurate. ","5 6 7 11 3".dm(\f,4,\minor) ++ "6 7 11 13 12 11 7 6".dm('f#',4) ++ [ 1,2,3,4,-5,4,3,2 ].dm(\d,5,\diminished)].addLine;
P.tune(\surface);
P(\bass,start:\surface,music:{|p b e| 
	[
		freq: 
		\r.bubble ++ [1,-7,3].df('a-',3,\mixolydian) => _.flat => _.q,
		dur: b.parse([4,4,3,5]).q,
		instrument:\sawSynthSustain,
		att:2,
		amp:0.07
	].pp;
});
["KIRK:(boom) Composition of walls? ","-4 4 5 4 3 4 7".dm(\c)].addLine;
P.tune(\Composition,Pdrop(1,_),syl:0);
P('wall',start:'KIRK:(boom)',syl:5,music: {|p b e|
	{
		[3,3,5,7].df(\g,\mixolydian)
		=> Saw.ar(_,0.1)
		=>MoogFF.ar(_, 
			freq: Env.triangle(b[0] + 6, 9000).kr(0,gate:1) +100 ,
			rq:3.0
		)
	}.play
});
P(\triller,start:\Composition,music:{|p b e| 
	var envBus=Bus.control;
	var envBus2=Bus.control;

	p.changeTrill.(6);
	{Line.kr (0,0.5,9)}.play(s,envBus);
	{Line.kr (0.1,0,12)}.play(s,envBus2);


	fork{
		0.3.wait;
		p.trillSynth[0].register;
		p.trillSynth[0].onFree({envBus.free;envBus2.free});
		p.trillSynth.do({
			|i|
			i.map(\noise,envBus);
			i.map(\amp,envBus2);
		});
	}
});
["SPOCK: They're an alloy or substance completely unknown to me.","5 6 11 6 5 11.5 6 4 12 11.5 12 12 13 11.5 6".dm('e-',4)].addLine;
P.tune(\alloy);
P('lick',start:\alloy,music: {|p b e|
	MegaBind(
		[
			[ 5, 6,  11, \_, \r, 11.5, \_, \_, 6, \_, \_, \r, 5 ],
			[-5, -6, 1,  -6, -5, -4,   \_, \_, -3, \_]
		].df('e-')
		,
		b,
		[
			amp:[0.7, { Env.linen(0,b.parse([5]),b[6..10].sum +3).kr(0,gate:1) }]
		],
		{|i| 
			Saw.ar(i.freqSeq * [1, LFBrownNoise1.kr([ 1,1.01 ]).range(0.99,1.005)] ,0.1)
			* Env.asr(0,1,8).kr(2,gate:i.gateSeq)
			/8
			* i.amp
		},
		{|i|  Mix.ar(i)
		=> DWGReverbC1C3.ar(_, len:3000, c1:1, c3:10, mix:1, coefs:nil, perm:nil, doprime:0)
	}
	).play
});
P(\triller,start:\alloy,music:{|p b e| 
	p.changeTrill.(6.5,2, p,b/0.8,e);
	{ Env([0.1,0.1,0.0001],[1,9],\sin).kr(2) }.play(s,Song.trillBus)
});
["Much stronger and harder than-- ","2 6 5 4 3 7 6 5 4".dm('c#',5)].addLine;
P.tune(\harder);
P('guitar',start:\Much, music: {|p b e|
	MegaBind(
		[
			[5,5,5,5,5],
			[1,-5,1,-5,1]
		].df('c#')
		,
		b.parse([1,2,2,2,2]),
		[],
		{|i|  
			//SinOsc.ar(i.freqSeq,0,0.1)
			Gendy2.ar([ 3,2,1 ], [ 4,5,6 ], 1.0, 1.0, i.freqSeq *0.98, i.freqSeq * 1.02, ampscale:0.9, durscale:0.9, initCPs:[ 12,2 ], knum:[2,12])
			/2 + Gendy1.ar([ 3,2,1 ], [ 4,5,6 ], 1.0, 1.0, i.freqSeq *0.98, i.freqSeq * 1.02, ampscale:0.9, durscale:0.9, initCPs:[ 12,2 ], knum:[2,12])
			=> HPF.ar(_,150)
			* Env.asr(0,b.sum,2).kr(2,gate:i.gateSeq) /50
	},
		{|i|  Mix.ar(i) 
		/3 

		=> Out.ar(2,_) 
		
	}
	).play
});


P(\bass,start:\harder,music:{|p b e| 
	[
		freq: "2 5 1 5".df('c#',[3]).q,
		dur: b.parse([1,2,2,4]).q,
		instrument: \sawSynthSustain
	].pp

});
P('kerRecorde',start:\harder,music: {|p b e|
	[
		dur: [ 1.136, 1.005, 0.547, 2.382, 1.457, 2.081 ].push(1,0.85).push(4,0.93).push(5,0.95).warpTo( b ).q,
		amp: [0,5,4,3,5,4,3]/10 => _.q,
		rest: [\r,1,1,1,1,1,1].q,
		instrument:\cymbal_808,
		out:Effect( { |i| SineShaper.ar(i,0.2,5) * [0.8,0.2] =< CombN.ar(_,0.1,0.3,decaytime:2,mul:0.4) *0.7  } ).bus.index ,
		CombN.ar()
	].pp
});

["anything I've measured before. ","3 2 1 -7 -6 -5 -4 1 2 ".dm('b-',5,\mixolydian)].addLine;
Song.durs[\measured] =  Song.durs[\measured].list.dropLast ++ (Song.durs[\measured].list.last  * 0.66 ) => _.q;
P.tune(\measured);
Song.setTempoMap(\measured, 
	"e e ee|q e | e x x x xeq".asBeats
);
P(\crash,start:\measured,music:{|p b e| 
	(
		instrument:\cymbalsDS,
		amp:0.05,
		out: Effect.new(Decimator.ar(_,20000),  out: 0,  inputChannels: 1,  target: nil).bus.index
	).play
});
P('guitar',start:\anything,music: {|p b e|
	MegaBind(
		[
			[5, 7, 11,12, 4, 6, 7].df('b-',\minor),
			[1,3,4,\_, -7, 1.5, 3].df('b-',\minor)
		]
		,
		[ 1.675, 0.838, ( 0.989 * [3,1]/4 ), 0.686,	0.345,	 1.388 ] => _.flat
		+ [0,     0,     0, 0,     (0.25-0.188) + 0.05, -0.7 * (0.25-0.188), 0]
		=> _.warpTo(e.tempoMap),
		[],
		{|i|  
			//SinOsc.ar(i.freqSeq,0,0.1)
			Pluck.ar( PinkNoise.ar(0.1),i.trigSeq,1,   ( i.freqSeq + 0.0001 ).reciprocal* [4,8] ,decaytime:10)
			=> CrossoverDistortion.ar(_,amp:0.20,smooth:0.9)
			+ VarSaw.ar(i.freqSeq + SinOsc.ar([5,6]).range(0,5),0,0,mul:0.01)
			* ( Env.asr().kr(2,gate:(i.gateSeq))  
			//+ Env.perc(0.01,1).kr(0,gate:i.trigSeq)
		)
			//* Env.perc(i.gate).kr(2,gate:1)

		},
		{|i|  Mix.ar(i)}
	).play
});
["MULHALL: All readings are off the scale, Captain. (ooh) "," 6 5 4 3 2 1 7 6 5 4.5".dm(\d,5,\mixolydian)].addLine;
Song.setTempoMap(\scale,"q Q Q Qq Q E q e e q".asBeats);
P('bass',start:\All,music: {|p b e|
	[
		instrument: \pulse_gentle,
		pw:Pwhite(0.1,0.4,inf),
		pitch:1.df(\d,octave:2),
		envAmount:2,
		filterfreq:Pwhite(400,1200,inf),
		dec:1,
		dur:0.25! 26 => _.warpTo(e.tempoMap.quantize(1,0,7)) => _.q(2) => _.fin(28),
		rest: \r!4 ++ (1!32) => _.flat => _.q,
		amp:0.15
		//vol:0.08
	].p.play
});
P(\chords,start:\scale,music:{|p b e| 
	[
		instrument:\pluckDVerb,
		freq: [[1,3],[1,3], -7,1,1,1].df(\d,5,\mixolydian).q,
		//dur:b.parse([1,3]).q
		dur: "q qq x x x xq".asBeats.warpTo(e.tempoMap.quantize(1,0,7)).q,
		amp:0.03
	].pp
});
P.tune(\scale, { |i| Pmul(\freq,[1,2],i).fin(9) => Pset(\dur, Song.tempoMap[\scale].quantize(1,0,7).durs.q ,_)  } );

P(\triller,start:\scale,syl:8,music:{|p b e| 
	p.changeTrill.(5.5,p,b,e,octave:4);
	(
		instrument:\stringyy,
		attack:5,
		freq:[1,3].df('a-',[4,5]),
		dur:b.sum+e.bNext.sum,
		amp:0.2
	).play;
	Song.trillBus.set(0.05)
});
P('click',start:\All,music: {|p b e|
	[
		instrument:\sn_808,
		dur:1.dup(7).warpTo(e.tempoMap.quantize(1,0,7)).q
	].p//p
	//=>  { |i| Ptpar( [ [1].warpTo(e.tempoMap.quantize(1,0,7)).unbubble, i ] ).play} 
});
P('cymbal',start:\All,music: {|p b e| 
	var dur,pat = "k k s ks ks kk s k k k s " ; 
	dur = pat.split(Char.space).collect{  // function to make "words" into subarrays
		|i| 
		( i.size == 1 ).if{
			i.asSymbol 
		}{
			i.asList.collect({|j|j.asSymbol})
		}
	}.deepCollect(2,{1}).subdivide;
	[ 
		inst: [1] ++ pat.replace(Char.space).asArray => _.q,
		instrument: [\r, Pfunc({|e| ( e.inst == $k ).if{\kick_gentle}{\sn_808}})].q(2),
		vol:0.1,
		dur:  [2] ++ dur /2 => _.warpTo(e.tempoMap.quantize(1,0,7)) => _.q(2) ,
	].p.play;
	[
		instrument:\cymbal,
		amp:0.7,
		dur: [1,1].warpTo(e.tempoMap.quantize(1,0,7)).q,
		rests: [\r,1].q].pp
});
["MCCOY: The air seems fresh. It must be re-circulated somehow. ","4 3 2 5 ".dm(\c) ++ "4 5 6 7 6 5 4 2 4 3.5".dm(\c,5,\minor)].addLine;
P('trill',start:\MCCOY,music: {|p b e|
	p.changeTrill(5.5,p,b,e);
	p.trillBus.set(0.05)
});
P(\chord,start:\circulated,music:{|p b e| 
	var a = [
		freq:"16 15 14 13 12 11 5.5 4 5.5 11 12 14 16 21".df(\c,3).q,
		dur:b.q,
		out:3
	].p;
	a <> [instrument:\sparkTriangle,amp:0.06].p => _.play;
	a <> [instrument:\wash,amp:0.02,out:1].p => _.play;
	[
		freq:"16 15 14 13 ".df(\c,3).q,
		dur:b.q,
		out:2
	].pp;
	[
		freq:"1 1 1 1".df(\c,4).q,
		dur:b.q,
		out:2
	].pp;
});
P.tune(\circulated);
["KIRK: Is that for us, or does it need fresh air? ","1 2 3 5 4 5 6 4 3 1.5 ".dm(\g,4,\whole)].addLine;
P('tril',start:\that,music: {|p b e|
	//p.changeTrill.(5);
	
	Song.trillSynth.do(_.set(\higher,7.df))
});
P.tune('Is that for us');
P(\pad,start:'fresh air',music:{|p b e| 
	(
		freq: [-1,1,3,5].df(\g,5,\whole),
		instrument: \wash,
		att: 3,
		rel:7,
		amp:0.03
	).play;
	fork{
		b.parse([6]).unbubble.wait;
		(
			freq:[1,11].df(\f,4),
			instrument:\sawSynthSustain,
			att:5,
			rel:7,
			dur: b.parse([6,4]).tail.unbubble,
			amp:0.03
		).play
	}
});
["(door opens and...)","f#"].addLine;
P(\door,start:\opens,music:{|p b e| 

	(instrument:\stringyy,dur:b.sum,amp:0.4,freq:[-1,-11].df('f#'),attack:5).play;

});
P(\crunch,start:\opens,music: { |p b e|

	{
		SinOsc.ar(
			0,
			LFBrownNoise2.ar(
				Env([100,2000,2000,100],[4,b-8,6],\sin).kr(2,gate:1)
			), 
			0.1
		) 
		=> {|i| i + BPF.ar(i, freq:[-1,-11].df('f#'), rq:0.15)}

	}.play
});
["I am Sargon!","1 2 1 -7 -7".dm('b',5,\harmonicMinor)].addLine;
P.tune(\Sargon);
P('tril',start:\Sargon,music: { |p b e|
	Song.changeTrill.(4.5);
	{Env([0.1,0],3).kr(2,gate:1)}.play(s,p.trillBus)
});
P(\chords,start:\Sargon,music: { |p b e|
	[
		freq: [[1, 2, 1, -7, -7],[11, 12, 11, 7, 7], 3, 5].flop.df(\b,\harmonicMinor) *.t [0.5,1] => _.q,
		dur: b.q,
		out: Effect( TwoTube.ar(_, k:0.01, loss:0.98, d1length:666, d2length:[ 412, 513 ], mul:1.0, add:0.0), inputChannels:4 ).bus.index
	].pp
});
}
)
