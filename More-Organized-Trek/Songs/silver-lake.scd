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
	
[ "(Sargon and Thalassa are working...","r"].addLine;
Song.durs['working']=[6].q;
[1,3,5,1,4,6,5,4].df(\g).q(2)=>[dur:0.5,freq:_,legato:1]=>_.p => _.fin(13) => {|i| P(\lick,start:\working,music:{|p b e| i.play})};
[ "when their hands touch.","r",4 ].addLine; 
P.tune(\touch);
P(\arpeggio,\touch,music:
		{
				[7,6,4.5,3,2,1] => {|i| [i,(-1)*i]} => _.flat => {|i| 
						[ 
								freq:i.df(\d,scale:\dorian,octave:6).q,
								dur:1/2/3,
								legato:3.05,
								out:Effect({ |i| 
										EchoNone.ar(i,0.5,{0.5.rand}!4,18)
										=>FreeVerb.ar(_,0.9,0.9) 
										=>Resonator.ar(_,SinOsc.ar(0.01).range(1400,1000),damping:0.2) 
										* 0.3
								},inputChannels:4,out:[0,1,2,3]).bus.index
						].pp;
						(
								instrument:\stringyy,
								freq:[1,3,4.5,7].df(\d,scale:\dorian),
								dur:6
						).play
				}
});


//~chordIdea = [ [-1,3,4.5,7], [-3.5,2,5,7] ].df(\d,scale:\minor).q => {|i| [freq:i,legato:1,dur:2.5].p};

["/*MULHALL:*/ Sargon, I remember a day long a- ",[2,1, 3,2,-6,1,-7,-7,-6,-5].dm(\d,scale:\dorian,octave:6)].addLine;

P(\bassnote,start:'long a',music: { |p b e|
		b.postln;
		b.sum.postln;
		(
				instrument:\sawSynthSustain,
				freq:[11,21].df(\d,octave:3),
				att:9,
				dur:3,
				rel: b.sum
		).play
});
P.tune('long a');
["go. (ta da da boom da) We ", [3, 5,5,5,-4,4].dm(\e)++[3].dm(\a)].addLine;
P.tune('go.', {|i| Pbindf(i,\amp,[0.1,\r,\r,\r,\r,\r,0.1].q,\legato,[5,1,1,1,1,1,1].q)});
P(\bass,start:'go.',music:{|p b e|
	Routine{

		//b[0]*2/3=>_.wait;
		(freq:[1,11].df(\e,octave:4),dur:3).play;
		b[0..3].sum.wait;
		(freq:[4,14].df(\e,octave:4),dur:3).play
	}.play
});
P(\chords,'go.',syl:0,music: {|p b e|
		[
				freq:
				[3,5].df(\e)!3++\r++[[1,3].df(\a)]
				=>_.q
				,
				instrument:\sparkTriangle,
				legato:0.1,
				dur:b[1..6].q
		].pp
});
["sat beside a si -- lve --r ",[1,-7,-6,-7,-5,3,4,1,3].dm(\d,octave:6)].addLine;
P(\bass,start:'sat',music:{|p b e|
	Routine{
		b[0]*2/3=>_.wait;
		[
			(freq:[3,13].df(\e,octave:4),dur:b[0] * 1/3 + b[1..4].sum),
			(freq:[1,11].df(\g,octave:4),dur:3)
		].q.play
	}.play
});
P.tune(\sat);
["lake. (boom boom) The air (boom boom) was scented with the ",[11,-7,2,3,6].dm('f#',scale:\mixolydian)++[-7,2,3,5,4,3,4].dm(\g,scale:\mixolydian)].addLine;
P(\bass,start:\lake,music:{|p b e|
	(freq:[3,13].df(\d,octave:3),dur:b[0..3].sum).play
});
P.tune('scented',{|e| Pbindf(e,\legato,2)});
["flowers of our planet. ",[1,-7,1].dm(\g,scale:\mixolydian)++[6,5,4,3,6,5,4,3].dm(\d)+12].addLine;
Song.quarters[\planet]= Song.parseBeats(\planet,[1.5,1.5,0.5,0.5,1.5,0.5,1.5,0.5,1.5,0.5,1.5]);
//Song.quarters[\planet]

P(\arpeggio,start: \flowers,music:{|p b e|
	[1,2,3,5,7,11,7].dm('a-')
	=> {|i| [
		instrument:\sparkTriangle,
		amp:0.02,
		midinote:i.q,
		ctranspose:[0,-12],
		dur:1/2,
		out:1,
		legato:2.1
	].p
	//.play(clock:Song.quarters[\planet].asTempoClock)
}});
//Song.quarters[\planet]
P(\ride,\flowers, //syl:3, 
		music:{|p b e|
		[
				//instrument:\claves_808,
				instrument:\openhihat_808,
				dur: Rest(1)!4++{  1!7  }.value => _.q,
				out:Effect(EchoNone.ar(_,0.2,0.1,6),out:3).bus.index
		].p.play(clock: Song.quarters[\planet] .asTempoClock)
});
P.tune(\flowers);
P(\bass,start:\flowers,music:{|p b e|
	var effect=Effect(DWGReverbC1C3.ar(_,len:2000,c1:1,c3:10,mix:1),inputChannels:2);
	(freq:[1,-1].df('a-',octave:[3,4]),rel:5,dur:2,out:effect.bus.index).play
});
P(\chord,start:\flowers,music:{|p b e|
	(freq:[1,3,5,7].df('a-'),strum:0.05).play
});

P(\planet,start:\flowers,syl:2,music: { |p b e |
	~quarters = b.drop(1).asArray++[1,1];~quarters=~quarters.parseBeats([1,3,1,3,1,3,1,1,2]/2);
	~vars = (); ~pbinds = ();
	~vars.bass = [6,5,4,11].dup.flat;
	~vars.inner = [6,5,-6,1, 4,3,-5,-7, 6,5,-6,3, 4, 3,-5,1/*3*/].reject({|i x| x % 4 == 0 or: (x % 4 == 1)}).clump(2);
	~vars.arp = [\r] 
		++ [ ~vars.bass.df(\d,octave:3) , ~vars.inner.df(\d,octave:5)].flop.flat; 
	~pbinds.arpLow=[
		freq:~vars.arp.q,
		dur: [1].q ++ [1,1,2].q(4) / 2,
		//amp: [\r].q++[\r,1,2].q(4) /10,
		//amp:0.2,
		out:1,
		instrument:\sparkTriangle,
		//amp:0.01
	].p;
	~pbinds.tune=[6,5, 4,3].dup.flat=>_.df(\d)=>{|i| 
		[
			dur:[1,3].q(4)/2,
			freq:i.q,
			instrument:\sawSynthSustain
		].p
	};
	~pbinds.rh = [6,5,-6,1, 4,3,-5,-7, 6,5,-6,3, 4, 3,-5,1/*3*/].df(\d)
		=>{|i| [dur:0.5,freq:i.q].p};
	~pbinds.bass = [
		dur:[1].q++[4].q(inf) / 2,
		freq:[\r,6,5,4,11].df(\d,octave:[2,3]).q,
		instrument:\stringyy,amp:0.5
	].p;
	//TODO PUT in a Ppar and clock to durs
	~pbinds.asKeyValuePairs.select{|i x| x.odd} 
		=> Ppar(_) 
		=> _.play(~quarters.asTempoClock);
	'b '.post;b.postln
 });
["/*KIRK:*/ I remember. You held my han-- -- -- -- -- -- -- -- -- -- -- -- -- d like ",[4,3,3,2].dm(\c)++[-4,-5,-6,-7,1,-7,-6,-7,1,2,3,2,1,2,3, 4,5].dm(\g)].addLine;
P.tune('I remember.',  { |i| Pmul(\freq,0.5,i) <> (instrument:\twang,amp:0.05)});
P('tune',start:\held,music: {|p b e|
	[
		midinote: Song.tune[Song.section(\held)].list 
		=> {|i| i ++ i.last} 
		//+.t [0,-12] 
		=> _.q,
		dur: b ++ b.last => _.q ,
		instrument: \harp,
		amp: 0.05

	].pp
});
//P.tune('I remember.',{|i| Pmul(\freq,0.5,i) });
P(\bass,'I remember.',music: {|p b e|
		[
				freq:[[4,14],[3,13], [15, 5 ] ,-5].df(\c,octave:3).q,
				instrument:\sawSynth,
				rel:2.5,
				dur:b.q,
				legato:1,
				amp:[1,1,1,2].q/10

		].pp
});
P(\chords,'I remember.',music: {|p b e|
		[
				freq:[ [6,11], [5,11], [5,7]].df(\c).q,
				instrument:\sparkTriangle,
				dur: b.parse([1,1,2]).q,
				amp:0.05
		].pp
});
P(\doubling,'I remember.',syl:12,music: {|p b e|
		[
				freq:[7,11,7,6,7,11,12,13].df(\g,octave:4).q,
				dur:b.q
		].pp
});
["this.  (He kisses it, as Spock comes in.) ",[5,4,4,3,3 ].dm(\c,octave:6)].addLine;
P.tune(\this);
P.tune('this', 
	{ |i| Pmul(\freq,[1],i) <> [
		instrument:\sawSynthSustain,
		lagTime:0.01,
		amp:0.04,
		att: [1,0,0.1,0,0.1].q,
		legato: [1,0.5,1,0.3,1].q
	].pma(\sawSynthSustain)
	}

);
P(\chords,start:'kisses',music: {|p b e|
	b.postln;
	VoiceLeading([
		[3,\_,2 ,\_,\_,],
		//[1,\_,-7,\_,\_,]
		[1,\_,-7.5,\_,-7,]
	],b.asArray
	).df('b-',scale:\mixolydian,octave:5)
	.array.do {|i| i <> [
		instrument:\trem2,
		scale:1,
		legato:1,
		rel:3,
		amp:0.05

	].pm(\trem2) => _.play } 
});
["I think it is best not to remember so well. (boom) ",[3,2,3,1,-5,2,1,-7,-6,-7,-5,-2.5,-4.5].dm(\d)].addLine;
P.tune('best',_ <> [amp: 0.1 * [1,1,1,1,1,1,1,1,1,1,1,1,0].q].p);
P('arrangement',start:\think,music: {|p b e|
	[
		freq: [\r,11, 5, 4, 2.5].df(\d,3).q,
		dur: b.parse([ 1, 3, 4, 3, 2 ]).q,
		instrument: \sawSynth

	].pp;
	[
		instrument:\wash,
		freq: [\r,2,1,\r,-6,-5].df(\d).q,
		dur: b.parse([1,2,1,4,2,1]).q,
		legato: [1,1,1,0.1,1,1].q


	].pma(\wash).play;
	[
		freq:[\r,5, \r,12].df(\d).q,
		dur:b.parse([1,3,4,3]).q,
		legato:5,
		instrument:\wash
	].pp;
	[
		freq:[\r,5,12,\r,2.5].df(\d,[4,5],tuning:\pythagorean).q,
		legato:[4,4,4,4,1].q,
		dur: b.parse([4,1,1,5,1]).q
	].pp
});
Song.bassSoundTwoDays = (instrument:\stringyy,amp:0.35,attack:0.1);
P('bassNote',start:\think, syl:11, music: {|p b e|
	[dur: b[0].q,freq:1.df('a-',4)].p <> p.bassSoundTwoDays => _.postln => _.play
});
["/*SPOCK:*/ In two days, you'll have your own hands, Thalassa. ",[3,2,4,3,4,3,3,2,4,1,-7].dm('a-')].addLine;
P.tune('two days');
//~twoDaysQuarters= Song.durs['two days'].list.asArray.parseBeats([0.5,0.5,1,1/3,1/3,1/3,3/4,(1/4+(3/4)), 1/4,3/4,(1/4+1)]);
//Song.durs['two days'].list.postcs
Song.durs['two days'].list[10]=(1.33);
P(\bass,start:'two days',syl:1,music:{|p b e|
	var quarters = b.drop(1).asArray.parseBeats([1,1/3,1/3,1/3,2/3,(1/3+(3/4)), 1/4,3/4,(1/4+1)]);


	[dur:1,freq: [-4,-6,-5].df('a-',octave:[  4 ]).q]
	=>_.p
	<> p.bassSoundTwoDays
	=> Pmul(\dur,2,_)
	=>_.trace=>_.play(quarters.asTempoClock)
});


["(intro)","r",[ (104/60).reciprocal*16 ]].addLine;
//Song.durs['intro'] = Song.durs['intro'].list*0.98=>_.q;
//Song.resources.introClock=TempoClock.new(104/60 * 0.98);
Song.resources.introClock=TempoClock.new(104/60);
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
	).play(clock:p.resources.introClock) };
} );

P(\808,start:'intro',music: {|p b e|
	\intro.post;t.postln;
	[
		"x.x...x.x.x...x.".asDrumPat(4,4)=>[instrument:\bd_808,dur:_,amp:0.5]=>_.p  ,
		"xxxxxxxxxxxxxxxx".asDrumPat(4,4)=>[amp:0.08,instrument:\hat_808,dur:_]=>_.p,
		"....x.......x...".asDrumPat(4,4)=>[amp:0.10,instrument:\sn_808,dur:_]=>_.p ,
	] => Ppar(_) => _.play(clock:Song.resources.introClock)
	
});
P(\lick,start:'intro',music: {|p b e|
	[\r,[5,4],6,`6,\r,[5,4],4,`4].asMelody.df('b-',octave:4)
	++ [
		rawLegato: [1,1,1,1,0.8, 1,1,1,0.8]=>_.flat=>_.q,
		detune: [0, 0.1,0.201 ],
		amp:0.45,
		legato: Pfunc({|e| (e.rawLegato==1).if{1}{0.6}}),
		out:Effect({|i| MoogFF.ar(i,1500)=>FreeVerb.ar(_,0.5,0.9) }).bus.index


	]
	=>_.pma(\sawSynthSustain)=>Pmul(\dur,2,_)=>Ptrace(_)=>_.play (Song.resources.introClock)
});
["Mechanically efficient and ",[\r,2, 1, 2,  4, 3].dm('e-'),"qq Q Q Q qe eqe eqe e".asBeats*60/104].addLine;
//needs to start on beat 3
P.tune(\efficient);
P(\bass,start:'efficient',music: {|p b e|
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
	).play(clock:p.resources.introClock) };
} );

P(\808,start:'efficient',music: {|p b e|
	\intro.post;t.postln;
	[
		"x.x...x.x.x...x.".asDrumPat(4,4)=>[instrument:\bd_808,dur:_,amp:0.5]=>_.p  ,
		"xxxxxxxxxxxxxxxx".asDrumPat(4,4)=>[amp:0.08,instrument:\hat_808,dur:_]=>_.p,
		"....x.......x...".asDrumPat(4,4)=>[amp:0.10,instrument:\sn_808,dur:_]=>_.p ,
	] => Ppar(_) => _.play(clock:Song.resources.introClock)
	
});
P(\keys,syl:0,start:\efficient,music: {
	\gotHere.postln;
	~lick1=VoiceLeading(
		[
			[2, 1, 2,  4, 3, \r,\r],
			[\r,\_,\_, 1,\_, \r,\r],
			[-5,\_,\_,-4,-3, \r,-2]
		] ,  
		"Q Q Q qe eqe eqe e".asBeats
	).df('e-').pma

	//tune3

	++ VoiceLeading(
		[
			[2, 1, 2, -6, -5, \r,\r],
			[-5,\_,\_, -4, -3, \r,-2]
		],
		"Q Q Q qe eqe eqe e".asBeats
	).df('e-').pma;
	[instrument:\sawSynthSustain].p<>~lick1=>_.play(clock:Song.resources.introClock) ;
} );


["quite human-looking. ","r"].addLine;
["Android robot hands, of course. ","r"].addLine;
["Hands without feeling. ","r"].addLine;
["Enjoy the taste of life while you can. ","r"].addLine;
["/*KIRK:*/ (boom But.. boom) our minds will have survived. ",[-2,2,-3,3,7,6,5,3,2.5].dm(\f)].addLine;
Song.durs[\survived].list .put(8,Song.durs[\survived].list[8]*1.5);
P.tune(\survived);
P(\mindChord,syl:3,lag:-0.06, start:\survived, music: {
	[-11,-15,-1,1,3,5,7].df(\f)
	=> 
	{|i| (amp:0.02,freq:i,strum:0.06,dur:2,instrument:\sawSynthSustain).play}
});
P(\bassNote,start:\survived,syl:7,music:{
	[
		freq:[[1,11,-1]].df('a-',octave:2).q(1),
		dur:3,
		out:Effect(FreeVerb.ar(_,1,1),out:[0,1]).bus.index,
		release:4
	].pp
});
P(\extra,syl:7,start:\survived,music:{|p b e|
	b.postln;
		[
				freq: [-1,[-4,-5]].df('a-').q,
				amp:0.025,
				dur:[b[1]/2,b[1]/2].q,
				legato:[3,2].q
		].pp
}
);
["And as androids, we can move among the people who do live ",[1,-5,1,-7,1,2].dm('b-')++[7,5,3,5,7,11,7,7,6].dm(\d)].addLine;
P.tune(\people);
P(\moveChord,start:\move,syl:5,music:{ |p b e|
	b.postln;
	[
		freq:[ [-1,1,3,5,7,13,17].df(\d),[-2.2,5,7,15].df(\d),[-2,2,4.5,7,14.5].df(\d) ].q,
		instrument:\sawSynthSustain,
		att:[ 4.5, 1.5,1.5 ].q,
		legato:1.1,
		amp:0.03,
		//dur:[b[0..2].sum,b[3..6].sum,b[7..8].sum].q
		dur:b.parse([3,[1,1,1,1,0.5],[0.5,1,0.5]]).q
	].p.play
});
["tea -- ching them (ba da da da da), ",[3,4,3,1,-5,-4,-3,-4,-5].dm(\b)].addLine;
P.tune('tea -- ching');

P(\bassnote,start:'tea -- ching',syl:0,music:{|p b e|
	//b[0].postln;
	[
		lag: b[0]/2 + 0.025,
		amp: 0.3,
		freq:[[1,11,-1]].df('b',octave:2).q(1),
		dur:3,
		out:Effect(FreeVerb.ar(_,0.8,1),out:[0,1]).bus.index,
		release:4
	].pp
});
["helping them (boom) not to make the errors we -- did. (pain) ",[4,3,1,-7,1,2,3,1,4,5,5,6,5,-7.5].dm(\a,scale:\mixolydian)].addLine;
Song.durs[\pain].list.put(13,4); //'pain' length
P.tune('helping');
//Song.durs[\helping].list.postln
P(\answer,start:'helping',syl:2,music:{|p b e|
	[
		instrument:\stringyy,
		amp:0.2,
		freq:[-7,1,2,-5].df(\a,scale:\mixolydian).q / 1 ,
		dur:b.drop(1).parse([1,1,1,7]).q,

	].pp
});
P(\doubling,start:'helping',syl:2,music: {|p b e|
	\b.post;b.postln;
	[
		midinote:p.tune.at(p.section('helping')).list[3..].q-12,
		ctranspose: 0!9++3 => _.flat => _.q,
		dur:b.drop(1).q,
		instrument:\sparkTriangle,
		out:[0,1]

	].pp

});
P(\extraNote,start:'helping',syl:10,music: {| p, b, e|
	(freq:1.df(\a),dur:3,lag:b[1]/2).play
 
});
P(\pain,start:'helping', syl:12,music: {| p, b, e|
	(
		instrument:\stringyy,
		mix:0.3,
		width: [6,6,6,20,1],
		freq: [-11,1,-1,21,21.3].df('a-',octave:3),
		amp:0.2,
		dur:3

	).play
});

["/*MULHALL:*/ What is it, Sargon? ",[1,5,4,1,-7].dm(\c)].addLine;
P.tune('What');
["/*KIRK:*/ Nothing. Our next injection will renovate me. (boom) ",[1,1].dm('e-')++[2,3,1,3,-7,1,2,1,-7,-5,-3].dm('d',scale:\mixolydian,)].addLine;
Song.resources.renovateKey='e-';
Song.resources.renovateKey='b-';
Song.resources.renovateKey='d';
~justTheTune.('renovate',({|i| 
	i.fin(12)=>
	Pmul(\freq,midiratio(-13),_) //'e- to b-'
}));
P(\dyad,start:'renovate',music:{|p b e|
	[
		freq:
		 [-5,-7]!2=>_.unbubble ++ [-17.5,-7.5] 
		=>_.df(p.renovateKey,octave:4,scale:\mixolydian )=>_.q,
		dur:b.parse([1,2,5]).q,
		instrument:\stringyy,
		amp:0.25,
	].pp
}
);
P(\chord,start:'renovate',lag:-1.5,syl:7,music:{|p b e|
	( 
		freq:[-5,-7,1,3].df(p.renovateKey,scale:\mixolydian) * midiratio(-1) ,
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
		freq:[1,11].df(p.renovateKey,octave:2 ) * midiratio(5),
		amp:0.25,
	).play
}
);
["Do not be concerned.",[3,4,2,3,-7].dm('c',octave:5,scale:\minor )].addLine;
["(Chapel is holding the hypos and trying to remember something very important.)","r"].addLine;
["MCCOY: Nurse, how are the last metabolic readings on our patients?","r"].addLine;
["CHAPEL: You'll find them excellent, Doctor. Well within normal.","r"].addLine;
["MCCOY: Is something wrong, Miss Chapel?","r"].addLine;
["CHAPEL: Er, yes. I, er, I had something to say. I can't seem to remember.","r"].addLine;
["MCCOY: Regarding our patients?","r"].addLine;
["CHAPEL: Yes. That must be it. I am so pleased the way they are responding, Doctor. The formula's working perfectly.","r"].addLine;
["MCCOY: You look tired, Miss Chapel. Perhaps you'd care for me to administer the last few injections.","r"].addLine;
["CHAPEL: Tired? Well, not at all, Doctor. Thank you for asking.","r"].addLine;
["(Leaves a puzzled McCoy.)","r"].addLine;
)
