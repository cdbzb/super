//[Laboratory]
(
Song(\thousand,[]).current;

~stills = Stills.new("/Users/michael/tank/Trek/video for stills etc/media/return to tomorrow.mov");
Stills.current=~stills;

Song.synthVTracks = EventWithDefault(
	\default, {| mix = 0.1|
		{|i|
			i
			=> DWGReverbC1C3.ar(_,mix:mix)
			* -10.dbamp
			=> HPF.ar(_,200)
			=> BPF.ar(_,1900,2)
		}
	},\cheng,{|e|
		{|i|
			i
			=> FreeVerb.ar(_,0.02,1)
			=> Pan2.ar(_,e.key.asString.contains("dbl").if{1}{0})
		}
	},\ninezero,{|mix = 0.1|
		{|i|
			i
			=> DWGReverbC1C3.ar(_,mix:mix)
			* -10.dbamp

		}
	}
);
["(Thalassa is looking at her reflection in a metallic surface) (Scott comes in with a small doo-dad.)","r",[ 8,6,1 ]].addLine;
P.still(\thalassa,start:\reflection,timecode:35*60+34.5,syl:0,music:{|p b e| 
	e.still.value(wait:6,fade:3,monitor:0,fadeIn:2)
});
P(\door,start:\reflection,syl:1,music:{|p b e| 
	Synth(\door,[\amp,0.1,\out,0])
});
P.still(\scotty_enters,timecode:35*60+43.3,start:\reflection,syl:1,music:{|p b e| 
	e.still.value(wait:3,monitor:0)

});
P(\reflection,start:\reflection,music:{|p b e|
	{
		var line = LFBrownNoise1.kr(LFBrownNoise1.kr((3..6)/4.5).range(13,16)).range(700,900);
	([line,1200-line]*.x ( (11..14) / 12 ))//.postln
		.collect{|i|
			SinOsc.ar(i) 
			=> CombC.ar(_,3,SinOsc.ar(0.1).range(1,3),15)
			=> CombC.ar(_,3,SinOsc.ar(0.1.rand).range(0.1,3),15)
		} => Splay.ar(_)
		=> FreeVerb.ar(_,0.8,0.5)
		
		*0.02
		*Env([0,0,1,1,0],[7,7,5,8]).kr(gate:1,doneAction:2)
	}.play(s,0)
});
//P(\door,start:\reflection,music:{Synth(\door)})
["/*MULHALL:*/ Thank you. ","r"].addLine;

["Have you prepared the negaton hydracoils for the drawing Sargon supplied?",[5,4,3,2,1,3,4,-7,3,2,-6,-7,1,2,-7,1,-6,-3,-1].dm(\g)].addLine;
// Trek.cast.thalassa = \aiko;

P.synthV(role: \thalassa, take:\lead, params: {|p b| [
	lyrics: "Have you prepared + the negaton + + hydra + coils for the drawing + Sargon + supplied? +",
	phonemes: 
	[ "x a w", "j u", "ph z` 7"," ph a z` 7 t", "t @","","",""," x a :\\i t ","d r\\` A ","kh o :\\i l s ","f o r\`", "t @", "t r\\` o ","i \\N g","s A r\\`", "k o n","s @ ","ph l a :\\i t" ]
	,
	language: \english,
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		// /5
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \thalassa, take:\lead, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).(e)
		}.play
	});

P.tune(\prepared);
P(\bass,start:\prepared,music:{|p b e| 
	[
		freq:[\r,11,5.5,[4.5, 6 ],4,[-6,3]].df(\g,octave:3).q,
		dur:b.parse([0.5,[0.5,4],3,3,4,4]).q,
		legato:1
	].pp;
	(amp:0.06,att:1,freq:[-11,-1].df(\g),dur:b.sum,instrument:\sawSynth,rel:b.sum).play
});
["/*SCOTT:*/ For all the good it'll do you. It's a fa -- -- ncy name, but",[5,6,7,12,11,7,12,11].dm('b-',octave:4) ++ [-7,1,4,3,2,1,5,3].dm('g')].addLine;
Trek.cast.scott = \kevin;
P.synthV(role: \scott,start:Song.section(\name), take:\lead, params: {|p b| [
	lyrics: " For all the good it'll + do you. It's a fan - see -  name, but",

	legato:[ 1, 1, 1, 1, 1, 1, 1, 0.5, 1, 1, 1, 0.85, 1, 1,    1, 1 ],
	lag:[0,     0, 0, 0, 0, 0, 0, 0,   0, 0, 0, 0,    0.03, 0, 0,  0],
	pitchTake: 1,
	filter: (midinote: _ - 12), 
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \scott, take:\lead, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	}
);
P.tune(\name);
P(\bass,start:\name,music:{|p b e| 
	{
		var freq = [5,4, [ 1,3 ] ].df('b-',octave:3).dq => Demand.kr(TDuty.kr(b.parse([2,1,5]).dq),0,_);
		var cutoff = [500,2000,1000].dq(2).duty(b.dq(2));
		Pulse.ar(freq,0.5,0.1)
		=> MoogFF.ar(_,cutoff,2.5)
		* Env.linen(0, b[0..7].sum, 7,  level: 1.0,  curve: -4).kr(2,gate:1)
		=> EchoNone.ar(_,0.4,0.231,5)
	}.play
});
["how will something that looks like a drop of jelly make this thing work?",[3,4, 3,4,5, 3, 3,4,5,3, 6,4, 7,7,4.5,2].dm('g',scale:\mixolydian,octave:5)].addLine;
P.synthV(role: \scott,
	filter: (midinote: _ - 12), 
	take:\lead, params: {|p b| [
	lyrics: "how will something + that looks like a drop of jelly + make this thing work?",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.tune(\jelly);
P(\accent,start:\jelly,music:{|p b e| 
	[
		instrument:\cymbal_808,
		dur:b.parse([2,3,1,4,2]).q,
		amp:0.3
	].pp;
	[
		instrument:\stringyy,
		mix:0.3,
		attack:0.05,
		release:1.5,

		dur:b.parse([2,3,1,4,2]).q,
		octave: Ptuple( [ Prand([4,5],inf),3 ] ),
		degree:-1 //b 

	].p.trace.play;
});
["You'll need microgears and a pulley that work like a muscle does.",[2,2,4,3,1].dm('d',octave:6)++ [4,3,2,1,-6,-7,-6,-5,-4,-3,-17].dm(\e,scale:\mixolydian,octave:6)].addLine;
P.synthV(role: \scott, take:\lead,
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: "You'll need microgears + + and a pulley  + that work like a muscle +  does.",
	pitchTake: 1,
	vocalMode: \Belt,
	paramGender: 0.1,
	paramToneShift: 100
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \scott, take: \lead, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			=>Pan2.ar(_,1)
		}.play

});
P.tune(\microgears);
P(\chords,start:\microgears,music:{|p b e| 
	[
		freq:[
			[-5,-7,2],[-5,-7,2], [1,4,6],[1,3,5],[-5,1,3],
			[-6, 2, 5], [ -6, 2, 4.5], [-5,1,3], [-5,-7,2]
		
		].df(\d).q,
		dur:b.q
	].pp;
	[
		instrument:\sawSynthSustain,
		freq:[-5,1, 2, -5].df(\d,octave:3).q,
		dur:b.parse([2,3, 2, 2]).q
	].pp;

});
P(\moreChords,start:\microgears,syl:4,music:{|p b e| 
	
	MegaBind(
		[
			[1, \_, \r, 4, 5],
			[-5, -6, \r,2, 1]
		].df(\e),
		b.drop(1).parse([2,2,1, 3, 3]),
		[
				lag:{[0,0.6].dq.demand(b)},
		],
		{|i|
			Saw.ar( i.freqSeq.lag(i.lag)/2 => Vibrato.ar(_,4.5,0.01, delay:b.parse([2]).unbubble) )
			* (
				Env.asr().kr(gate:i.gateSeq)
				* 0.04
			)
		},
		{
			|i|
			i = Mix.ar(i);
			DWGReverbC1C3.ar(i,mix:0.1)
		}
	).play;
});
["/*MULHALL:*/ That would be highly inefficient.",[7,5,2,11,7,5,2,6,4.5].dm(\d,scale:\mixolydian)].addLine;
P.synthV(role: \thalassa, take:\lead, params: {|p b k| [
	lyrics: " That would be highly + inefficient + + +",
	phonemes: (k==\aiko).if{["t a th","w U t", "p i","x a :\\i","l i", "\\i n","i\\ ","f \\i s` "," e n th"]  },
	legato:[1, 1, 1, 1, 0.9, 1, 1, 1, 1],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \thalassa, take: \lead, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			// => p.synthVTracks.at(e.key).()
		}.play
	});

P.tune(_ <> (instrument:\wash));
["/*SCOTT:*/ I tell you, lady, this thing won't work.",[7,13,11,7,5].dm('b',scale:\mixolydian) ++ [5,6,7,11].dm('d')].addLine;
P.synthV(role: \scott, take:\lead,
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: " I tell you, lady + this thing won't work.",
	legato: [1, 1, 1, 1, 0.6, 1, 1, 1, 1],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		/2
	}.play
});
P.double(role: \scott, take: \lead, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		/2
		}.play
	});
P.tune('lady');
P(\bass,start:\lady,syl:3, music:{|p b e| 
	[
		instrument:\stringyy,
		freq: [\r,3,2,1].df('b-',octave:4 ).q,
		amp:0.2,
		legato:1,	
		dur:b.drop(1).parse([0.5,[0.5,1,1],1,1]).q
	].pp;
});
["/*SPOCK:*/ It will have twice the strength and agility of",[2,3,1].dm(\c)++[3,1].dm(\e)++[-7,1,2].dm(\f,scale:\mixolydian)++[3,5,4,3,4,2,1].dm(\g)].addLine;
P.synthV(role: \henoch, take:\lead,
	// filter: (midinote: _ - 12), 
	pbind: Song.enlarge(9),
	params: {|p b| [
	lyrics: "It will have twice the strength and agility  + - - - + + of your - - body - engineer + + -",
	pitchTake: 1,
	vocalMode: \Muted
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \henoch, params: {|p b| [
	
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
// P.tune(\twice);
P(\bass,syl:2,start:\twice,music:{|p b e|
	[
		instrument:\sparkTriangle,
		amp:0.02,
		freq: [11,7,[6.5,15]].df('e',octave:3).q,
		dur:b.parse([2,3,6]).q,
	].pp
});
P(\chord,start:\twice,syl:2,music:{|p b e|
	[
		strum:0.05,
		freq:[ 
			[5,7,11,13].df(\e,scale:\mixolydian),
			[5,7,11,13].df(\f,scale:\mixolydian),
			[5,3,5,13].df(\g,scale:\mixolydian),
		].q,
		dur:b.parse([2,3,6]).q,
		out:Effect(FreeVerb.ar(_,0.9,0.9),inputChannels:2).bus.index,

	].pp
});
P.tune(_<>(instrument:\pluckD,amp:0.01));
P(\chord2,start:\twice,syl:7,music:{ |p b e|
	(
		instrument:\sawSynthSustain,
		freq:[1,11].df(\b,octave:4),
		att:3,
		dur:b.sum-0.5,
		amp:0.02,
		rel:5
	).play
});
	~stills.set(\twice,36*60+18);
P(\still,start:\twice, 
	music: {|p b e| 
		defer{ 
			
			~stills.preview(\twice,b.sum,3,0,[ "It will have twice","the strength" ]) 
		}

} );
["your body, engineer, and it will",[11,12,11,7,6,5,4,5,6, 3,4,5].dm('c#',scale:\mixolydian)].addLine;
P.synthV(role: \henoch, take:\lead,
	pbind: Song.enlarge(7),
	filter: (
		midinote: _ - 12,
		dur: _ + [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], 

	),

	params: {|p b| [
	lyrics: "r r r r r r r r r and it will last a thousand - - + years",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \henoch, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
Song.quarters[\engineer]=Song.parseBeats(\engineer,[3,1,2,4,2,2,1,1,2,2,2,2]/4)
//	.quantizeWindow
;
P(\bass,start:\engineer,music:{
	[
		instrument:\sawSynth,
		freq:[[1,11],11,1,[-7,7],7,-7,-4,-3,-4,-5].df('c#',scale:\mixolydian,octave:4).q,
		amp:0.15,
		dur:[1,0.5,0.5,1,0.5,0.5,0.5,0.5,0.5,0.5].q
	].p.play(Song.quarters[\engineer].asTempoClock)
});
P.tune(\engineer);

["last a thousand years.",[2,1,2,3,1,2, 5.5].dm(\c,octave:6)].addLine;
P.synthV(role: \henoch, take:\lead,
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: "last a thousand - - + years.",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}//.play
});
P.double(role: \henoch, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}//.play
	});
Song.quarters['last a thousand']=Song.parseBeats('last a thousand',[1.5,0.5,0.5,0.5,0.5,0.5,1]);
P.tune(\last);
P(\chord,start:'last a thousand',music:{
	[
		freq: [[1,3,5,7].df('b-'),[15,7,11,13].df('e',octave:5,scale:\mixolydian)].q,
		freqLag:1.5,
		instrument: \stringyy,
		dur:Song.parse('last a thousand',[6,1]) + [-0.2,0.5] =>_.q
	].pm(\stringyy).play
});
P(\bass,start:'last a thousand',music:{
	[
		instrument:\sawSynth,
		midinote:[1,-7,-6,4.5].dm('b-',octave:[2, 3 ]).q,
		dur:[1,1,2,1].q,
	].p.play(Song.quarters['last a thousand'].asTempoClock);
	[
		instrument:\sawSynth,
		midinote:[3,2,1,6.5].dm('b-',octave:[4, 3 ]).q,
		rel:4,
		dur:[1,1,2,1].q,
	].p.play(Song.quarters['last a thousand'].asTempoClock)
});
["That is, assuming you'll stop wasting your time and allow us to complete it.", [6,5,4,2.5,4,2,5.5].dm(\a,)++[7,6,5, 4,5,4 ,3,4, 4,5].dm(\f,scale:\melodicMinor)++[6,7,7,11].dm(\c) ].addLine;
Song.quarters[\assuming]= Song.parseBeats(\assuming,[[1,1,1]/3,[1,1,1,1]/2,[2,1,1]/2,[1,1,1]/3,[1,1,1,1,1,1,3,1]/2].flat/1);
//P.tune(\assuming);
~path="/tmp/media/subproject.rpp-PROX";
P.synthV(role: \henoch, take:\lead,
	filter: (midinote: _ - 24), 
	params: {|p b| [
	lyrics: "That is, assuming +  + you'll stop wasting + your time - - and allow + us to complete +  it.",
	pitchTake: 1,
	vocalMode:\Muted
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.synthV( \clear,
	filter: (midinote: _ - 12), 
	params: {|p b| [
		
	lyrics: "That is, assuming +  + you'll stop wasting + your time - - and allow + us to complete +  it.",
	] }, music:{|p b e|
		{
			e.playbuf
			=> AnalogVintageDistortion.ar(_,0.8,bias:0.5)
			/7
			=> FreeVerb.ar(_,0.5,0.9)
			=>Pan2.ar(_,1)
			// => p.synthVTracks.at(e.key).()
			/4
		}.play
	});
P.double(role: \henoch,
	filter: (midinote: _ - 24), 
	params: {|p b| [
		
	// lyrics: "That is, assuming +  + you'll stop wasting + your time - - and allow + us to complete +  it.",
	] }, music:{|p b e|
		{
			e.playbuf
			// => AnalogVintageDistortion.ar(_,0.8)
			// /7
			// => FreeVerb.ar(_,0.5,0.9)
			// =>Pan2.ar(_,1)
			// => p.synthVTracks.at(e.key).()
		}.play
	});
~test=Buffer.read(s,~path);
//~Song.reaperSection(\assuming) makes subproject initially...
//"rpr /tmp/test3.RPP" opens this file
//need to handle the naming etc
P(\vox,start:\assuming,music:{|p b e| 
	{PlayBuf.ar(2,~test.bufnum)=>TwoTube.ar(_,0.01,0.9,500,666)*0.01}.play
});
P(\bass_next_next,start:'last a thousand',syl:5,music:{
	[
		[ [3,4,2,-7].dm(\c), [4,2,1,1]/2 ],
		[ [7,11,6,4].dm(\g,octave:3), [4,2,1,1]/2 ],
		[ [1.5,12,5,1].dm(\c,octave:3), [2,1,1,2]/2 ]
	] 
	=> _.collect{ |i| 
		[
			instrument:\sawSynthSustain,
			dur:i[1].q,
			amp:0.03,
			midinote:i[0].q,
			legato:[0.5,0.5,0.5,3]
		].p
	}
	=> _.q => _.play(Song.durs['last a thousand'].list.last.bubble ++ Song.quarters[\assuming] => _.flat=> _.asTempoClock)
});
P(\chords,start:\assuming,syl:6,music:{ |p b e|
	[
		instrument:\stringyy,
		amp:0.3,
		dur:b.drop(1).parse([3,2]).q,
		freq:[ [1,3].df('f#',scale:\minor),[1,3].df('g',scale:\minor) ].q,
	].pp
});
P(\chords2,start:\assuming,syl:14,music:{ |p b e|
	[
		instrument:\stringyy,
		amp:0.3,
		dur:b.drop(1).parse([2,2,2]).q,
		freq: [ [4, 6.5],[4,6], 3].df('c') .q,
	].pp
});

//P(\bass,start:\assuming,music:{
//	[
//		instrument:\sawSynthSustain,
//		freq:[3,4,-4.5,-5,-3,-1,1.5].df(\c,octave:4).q,
//		amp:0.025,
//		dur:Song.parse(\assuming,[3,4,3,3,1,1,2]).q,
//		legato:1
//	].p.play(Song.quarters(\assuming).asTempoClock)
//});
["(Scott leaves as 'Spock' laughs.)",[11,7,6,5,7,6,5,4,3,2,4,3,2,1,0].dm(\c)].addLine;
//set pause between sections
Song.durs[\laugh]=Song.durs[\laugh].list.put(Song.durs[\laugh].list.size - 1, 3).q;
P.tune(\laughs,_.fin(14));
P(\door,start:\laughs,syl:6,music:{|p b e| 
	Synth(\door,[\out,0,\amp,0.1])
});

["/*SPOCK:*/ (boom) A thousand-year prison, Thalassa.",[1,2,3,1,6,3,1,-7,-6].dm(\c)].addLine;
P.synthV(role:\henoch, take:\lead,
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: "  A thousand + year prison + Thalassa + +",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role:\henoch, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
// P.tune(\prison);
P(\arpeggio,start:\prison,syl:3,lag:-0.15,music:{
	(
		instrument:\default,
		degree: Arpeggio([1,3,5]-1,8),
		scale:Scale.minor,
		root:-3,
		strum:0.04
	).play;
});
P(\stab,start:\prison,syl:3,music:{
	(instrument:\cymbalsDS,amp:0.03,
		out:Effect({|i| CrossoverDistortion.ar(i)*0.01})
	).play;
	(
		instrument:\stringyy,
		freq: [1].df('a')/[8, 4,16 ],
		amp:0.2

	).play
});
["And when it wears out we'll build another one, ",[5,4,3,2,3,4,-7,1,4,3,2,-5].dm(\c)].addLine;
P.synthV(role: \henoch, take:\lead,
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: "And when it wears - out we'll build another + + one, ",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \henoch, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
P(\bass,start:\wears,music:{|p b e| 
	
	{
		{
			var dur = b.parse([5,4,3]),
			freq = [[-4, 11 ],7,[11,11.01]].df('g',scale:\mixolydian,octave:3).dq.demand(dur);
			Pulse.ar(
				freq + Select.ar(PulseCount.kr(TDuty.kr(dur.dq))-1%2,[SinOsc.ar(3),Pulse.ar(5,0.5,2)]),
				[0.3,0.4,0.5].dq.duty(dur.dq)
				,0.02)  
			* Env.linen(0.01, b.sum, 2).kr(2)
		} 
		
	}.play
});
P.tune(\wears);
["and we'll lock ourselves into it for another thousand years. And another, and another.", [1,2,3,4,2,3,2,1.5,2,3].dm(\a) ++ [1,-6, 2,3,1,2,4].dm('e-',scale:\whole,octave:6) ++[2,2,3,2,2,2,3,2].dm('a-',scale:\minor,octave: 6) ].addLine;
P.synthV(role: \henoch, take:\lead, params: {|p b| [
	lyrics: "and we'll lock ours elves  into  + it for another + +  thousand - - + years. And another + + and another + +",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \henoch, 
	filter: (midinote: _ - 12), 	
	params: {|p b| [
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
P.tune('And another',Pmul(\freq,0.5,_));
P(\bass,start:'And another',syl:1,music:{|p b e| 
	
	var 
	freq = [3,4,5].df(\a,octave:2),
	dur = b.drop(1).parse([1,2,1]);
	p.twangBass = { |freq dur out amp=0.1|
		{
			Pulse.ar(freq.dq.duty(dur.dq) * [1,2,3,14,21],0.3,0.1)
			*[21,5,3,2,1]/11
			=>Mix.ar(_)
			* Env([0,1,0],[0.03, [ 1.5,2.2 ] ]).kr(0,gate: TDuty.kr(dur.dropLast.dq,0))
			* Dseries(1,-0.1).demand(dur)
			* amp * 10
			=> FreeVerb.ar(_,0.5,1)
			* 0.4
		}.play(s,out)
	};
	p.twangBass.(
		freq:freq,dur:dur
	)
});
P(\chord,syl:15,start:'And another',music:{|p b e| 
	var freq = [5,7,11,13].df('f',scale: \mixolydian),
	dur = b.drop(1).sum ;
	{
		Gendy2.arWidth(freq:freq/2,width:1.001) ++
		Gendy1.arWidth(freq:freq,width:1.001) * 0.5 
		* Env.linen(0,1,4).kr(0,gate:1)
		=> DelayN.ar(_,1,( 0,0.02..0.8 ))
		//=> Phaser2.ar(_,rate:0.1)
		=> Splay.ar(_)
		=> Phaser2.ar(_,rate:0.1)
		* 0.05
		* Env.linen(0,5,1).kr(2,gate:1)
	}.play
});
P(\chords,start:'And another',syl:16,music:{|p b e| 
	
	b.postln;
		VoiceLeading(
			[
				[5,5,6, 5].dup.flat,
				[3,3,4, 3 ].dup.flat,
				[1,1,1,1].dup.flat
			],b[(1..8)].asArray
		).dm('e-',scale:\minor).p
		=> Pset(\instrument,\sparkTriangle,_)
		=> _.play
});

P(\pad,start:'And another',syl:9,music:{|p b e| 
	(
		freq:[1].df('e-',octave:3),
	dur: b.parse([1]).sum,
	instrument:\sawSynth,
		rel:6,
		att:2,
		lofreq:5000,
		hifreq:7000,
		amp:0.03,
	).pp
});
P(\sizzle,syl:9,start:'And another',music:{|p b e| 
	(
		instrument:\sawSynthSustain,
		freq:[1].dm('e-'),
		att:2.5,
		out:Effect( {|i| Phaser2.ar(i,rate:0.12) => TwoTube.ar(_,loss:0.8,d1length:410)} ).bus.index
	).play
});
P(\threeNoteFigure,start: 'And another',syl: 9,music:{|p b e|
	p.twangBass.
	(
		freq: [1,-6,-4].df('e-',scale:\whole)/2,
		dur:b.drop(1) + [0,0,1] => {|i| i[0..2]} ,
		out:1,
		amp:0.06
	)
});
P(\threeNoteFigure2,start: 'And another',syl: 15,music:{|p b e|
	//b[1].bubble++b[2..3].sum++b[3];
		var freq= [3,2,2,1].df('a-')/4,
		dur=b.drop(1) + [0,0,0,1];
		p.twangBass.(
			freq:freq,
			dur:dur[0..3],
			amp:0.04,
			out:0
		);
		p.twangBass.(
			freq:freq*2,
			dur:dur[0..3],
			amp:0.04,
			out:0
		)

});
["Sargon has closed his mind to a better way.",[11,5,3,6,5,5,4,3,2,3].dm(\c,scale:\minor)++[3,4,2,3,3].dm(\g)].addLine;
P.synthV(role: \henoch, take:\lead, params: {|p b| [
	lyrics: "Sargon + has closed his mind - - to a better - - + way.",
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \henoch, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
P.still(\spock,start:\mind,timecode:3648.5.seconds,music:{ |p b e|
	e.still.value(wait:b.sum,fade:1,text:["Sargon has closed his mind","to a better way"])
});
P.tune(\closed);

P(\bass,start:\closed,music:{|p b e| 
	[
		freq:[1,-5,-5,-5].df(\c,octave:4).q,
		dur:b.parse([10,3,1,1]).q,
		instrument:\sawSynth
	].pp;
});
P(\figure,start:\closed,syl:2,music:{|p b e|
[
	freq: [[4,6],[3,5],[3,5],\r,[2,5]].df(\c,scale:\minor).q,
	dur: b.parse([1,1,1,4,5]).q,
	lag: [0,0,0,0,-0.1].q,
	legato: [0.95,0.85,1.5,2,0,1].q,
	instrument: \sawSynthSustain,
	rel:[1,0.8,1,1,1].q,att:[0.5,0.5,0.3,0.5,0.5].q,hifreq:2000
].pp
});
P(\strum,start:\closed,music:{|p b e|
	(
		freq:[1,3,5,11].df(\c,scale:\minor,octave:4),
		strum:0.05,
		dur:b[0..9].sum
	).play
});

["(boom) With these bodies. (la la la la la la  with the-- ese bodies)",[1,5,5.5,3,2,1,-7,1,2,1,-7,-6, ].dm(\d) ++ [7,11,5,5,4].dm(\c)].addLine;
P.synthV(role: \henoch, take: \lead, params: {|p b| [
	lyrics: "r with these - bodies + ",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(\feng, take:\lead, params: {|p b| [
	lyrics: "r with these - bodies + la la la la la la  with these - bodies +",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
			/3
	}.play
});
P.double(\feng, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> Pan2.ar(_,1)
			=> p.synthVTracks.at(e.key).()
			/3
		}.play
	});
P.synthV(role: \henoch, take:\lead, params: {|p b| [
	lyrics: "r With these - bodies + ",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \henoch, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
//Reaper.new;Reaper.saveas("/Users/michael/tank/super/More-Organized-Trek/Songs/with-these-bodies");
P.tune('With these bodies',Pbindf(_,\instrument,\stringyy,\wet,0.0,\release,2,\amp,0.2));
//P(\vox,start:'With these bodies', music:{
//	Reaper.go(0);
	//Reaper.play
//});
Song.quarters['With these bodies']=Song.parseBeats('With these bodies',[1, 1,1, 1/2, 1 , 1, 1/2, 1/2, 1/2, 1/2,1/2, 1,1,1,1/2,1,1/2  ]);
P(\extraChords,start:'With these bodies',syl:11,music:{|p b e| 
	[
		freq:[[5,7,12],[5,11,13],[3,5,11],[3,5,11],[1,4,6]].df(\c).q,
		dur:b.drop(1).q,
		out:Effect({|i| i.distort=>MoogLadder.ar(_,1800,1.0)*4=>DWGReverbC1C3.ar(_,mix:0.2)=>AnalogPhaserMod.ar(_).tanh/2}).bus.index,
	].pp
});
P(\bass, music: { |p b e|
	  [
		    dur:"qe e e eq e qe e e q e qq ".asBeats.warpTo(p.quarters[e.start]).q,
		    // freq: 1.df(\d,3),
		    freq: [11, 11, 7, 7, 6, 6, 5, 5, 5, 4  ].df(\d,2).q,
		    amp:0.2,
		    out: Effect.bus( { |i|  AnalogVintageDistortion.ar(i) => HPF.ar(_,185) => Pan2.ar(_)  } )

	  ].pp
});
P(\chords,start:'With these bodies',music:{
	[
		[
			freq:[
				[1,3,5],[-7,3,5.5],[1,3,6],[1,3,6]
			].stutter(2).df(\d).q,
			out:Effect({|i| i.distort=>MoogLadder.ar(_,1800,1.0)*4=>DWGReverbC1C3.ar(_,mix:0.2)=>AnalogPhaserMod.ar(_).tanh/2}).bus.index,
			lag:Ptuple([0,Pwhite(0.00,0.02)!2].flat,inf),
		].p.trace,
		[
			freq:[ 1,-7,-6,-5 ].stutter(2).df(\d,octave:3).q,
			dur:[3,1]/2=>_.q(4),
			//instrument:\sawSynth,amp:0.06
			out:Effect(CrossoverDistortion.ar(_,amp:0.01,smooth:0.1)/4).bus.index,
		].p,

		"x.x.x.x.".asDrumPat(2,3)=>[dur:_,instrument:\sn_808]=>_.p,
		"x.x..x.x".asDrumPat(2,3)=>[dur:_,instrument:\bd_808,amp:0.06]=>_.p
	] => Ppar(_) => _.play(clock:Song.quarters['With these bodies']
	.quantizeWindow
	.asTempoClock);

		[
			instrument:\hat_808,
			dur:1/4,
			lag:[0,0.01].q(inf),
			amp:0.01
		].p.fin(32).play(clock:Song.quarters['With these bodies'].quantizeWindow.asTempoClock);
		(instrument:\cymbalsDS,amp:0.01).play
});
["/*MULHALL:*/ They're not ours, Henoch.",[3,1,7,6,4.5].dm(\d,scale:\dorian)].addLine;
P.synthV( \aiko, take:\lead,start:Song.section('not ours'), params: {|p b| [
	lyrics: "they're not ours hen nok ",
	
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.tune(\Henoch);
P(\chord,start:\Henoch,syl:1,music:{|p b e|
	(
		strum: 0.05,
		freq:[1,3,4.5,7].df(\d,scale:\dorian),
		pan:1
	).play
});

P.still(\thalassa,start:'not ours',timecode:3657.seconds,music:{|p b e|
	e.still.value(wait:b.sum,text:["they`re not ours,","Henoch!"],fade:2)
});
["/*SPOCK:*/ (boom) When you awoke in this body, Thalassa,",[-1,1,2,3,6].dm('f#')++[1,3,5].dm(\a)++[3,1,3,2].dm(\b)].addLine;
Trek.presets.put(\henoch,\ninezero,
	  [
		    paramBreathiness: 0.7,
		    paramTension: 0.5,
	  ]
);
P.synthV(role: \henoch, take:\lead, params: {|p b| [
	lyrics: " r When you awoke + in this body + Thalassa  + +",
	legato: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.6],

	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \henoch, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
P.tune(\awoke,range:[ 1 ],syl:0);
P(\bass,start:'awoke',music: {|p b e|

	[ instrument:\stringyy,
		freq:[[-21,-11],[-22,-12]].df('f#').q,
		dur:b.parse([7,3]).q
	].pp
});
P.still(\embrace,start:\awoke,timecode:3702.seconds,music:{|p b e|
		e.still.value(fadeIn:1,wait:b.sum-1).postln;
});
P.still(\embraceTitle,syl:1,start:\awoke,timecode:3702.5.seconds,music:{|p b e|
	e.still.value(wait:b.sum,fadeIn:1,text:["when you awoke","in this body"])
});
["you said how go--od it was _. to breathe again,",[1,2,3, 3,4, 3, 3,2, 1, 4, 3, 2].dm('c#',octave:6),].addLine;
Song.quarters[\breathe]= Song.parseBeats(\breathe,[1,1,1/2,1/4,3/4,1/2,1/2,11/2,1/2,1,1/2, 5/2]);
Song.setTempoMap(\breathe,"q q e x xe e e eeeqqqq e q e eqq");

P(\shaker, music: { |p b e|
	
	{
		var tightness = 0.9;
		// var env = DemandEnvGen.ar([1,0,4,0,2,0,4,0].dq(inf)*10,1/4!16 warpTo: e.tempoMap.quantizeDft(0.3) => _.dq(inf));
		var env = DemandEnvGen.ar([1,0,0,1,0,0,1,0,0,1,0,0].dq(inf) + 0.01,1/4!16 
		warpTo: e.tempoMap.quantizeDft
		*.x [1-tightness/2,tightness,1-tightness/2] => _.postln => _.flat => _.dq(inf));
		Shakers.ar([3],energy:env.min(0.99).max(0.0),
			resonantFreq:SinOsc.ar(0.2).range(0.3,0.5),decay:SinOsc.ar(0.13).range(0.2,0.8)
		)
		// => DelayN.ar(_,delaytime:b[0]/( 6 ))
		// / 20 
		// /8
		* EnvGen.cutoff(b.sum,0)
		* Env([0,0,1,1], "qqq".asBeats.warpTo(e.tempoMap) ++ [0],\step).kr(0)

	}.play;
	(lag: "qqq".asBeats.warpTo(e.tempoMap),instrument:\cymbalsDS,amp:0.02,out:Effect.bus(_*[0.1,0.8])).play
});
P.synthV(role: \henoch, take:\lead, params: {|p b| [
	lyrics: "you said how good - it was - to breathe again +",
	pitchTake: 1,
	filter: (midinote: _ - 12), 
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \henoch, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
P.tune(\breathe);
P(\bass,start:\breathe,music:{|p b e|
	[
		freq:[\r,1,4,5,4,1,4,5].df('c#',octave:3).q,
		dur:[Rest(3),3,1,3,1,3].q
	].p.play(Song.quarters[\breathe].asTempoClock)
});
//
//["to have eyes and to see* again*. To feel.","r"].addLine;
//["To live and feel again,.","r"].addLine;

[" Thalassa, (boom) just think how much (go--od) we can do for mankind.",[5,4,3].dm(\c,octave:6) ++ [-4,3,4,1,3,2,1,-7,2,-6,-5].dm('e-',octave:6)].addLine;
P.tune();
P.synthV(role: \henoch, take:\lead, params: {|p b| [
	lyrics: " Thalassa + + r just think how much we can do for mankind +",
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \henoch, take: \lead, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			=> Pan2.ar(_,1)
		}.play
	});
P.tune(\mankind);
P(\chords,start:\mankind,music:{|p b e|
	[
		instrument:\sawSynth,
		freq:[ [3,5,11,13,15],[2,4,11,12,14],[1,3,5,11,13] ].df('c').q,
		dur:b.q,
		legato:1.1,
		rel:3,
		att:[ 0.5,0.5,0.2 ].q
	].pp
});
P(\bass,start:\mankind,syl:2,music:{|p b e|
	[		instrument:\sawSynthSustain,
		freq:[ [1,11], [-5,5] ].df('a-',octave:3).q,
		dur: b.parse([[1,1,1,1/3],[2/3,1,1,1]]).q
	].pp
});
["Are these bodies too much to ask for in return? (or) Would you prefer this?",[1,3,4,3,1,2,3,2,1,-7,-6,1.5].dm(\e) ++ [1,2,3,2,3,6.5].dm(\c) ].addLine;
P.synthV(role: \henoch, take:\lead, params: {|p b| [
	lyrics: "Are these bodies + too much to ask for in return? + (or) Would you prefer + this?",
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \henoch, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
P.tune( _ <> (instrument: \sparkTriangle, out: Effect.bus( _ *[1,1]/3 )) );
P(\lick,start:\return,syl:3,music:{|p b e| 
	[
		freq:[1,2,3,[1.5, 11.5 ]].df(\c).q,
		dur: b.q,
		instrument:\sparkTriangle

	].pp;
});
P(\bass,start:\return,music:{|p b e| 
	[		
		instrument:\sawSynth,
		spread:0.25,
		center:[-0.75,0.75].q,
		out:Effect(EchoNone.ar(_,1,b[0]/2,5),inputChannels:2).bus.index,
		freq:[1,11].df(\e,octave:3).q,
		dur:b.parse([2,2]).q
	].pp
});
P(\chord,start:\return,syl:16,music:{|p b e|
	(
		strum: 0.05,
		midinote:
		([1,2.5,4.5,6.5] +.t [0,10,20] => _.flop =>_.flat)
		.dm(\c,octave:4),
		instrument:\sawSynthSustain, amp:0.05,
		out:Effect({|i| Phaser2.ar(i) => EchoNone.ar(_,1,0.8,9) /8}).bus.index

	).play
});
 ["/*MULHALL:*/ No. I'm beginning to hate it.",[1].dm(\b)].addLine;
 P(\bass,start:\hate,music:{|p b e|
	 (
		 instrument:\stringyy,
		 freq:[1,11].df(b) / 4
	 ).play
 });
["(She rushes out, and 'Spock' smirks.)","r"].addLine;
)
/*
a=Buffer.read(s,"/Users/michael/reaper-subproject/media/01-210826_1331.rpp-PROX")
a{ PlayBuf.ar(2,a.bufnum) =>TwoTube.ar(_,0.7,0.8,678,876) }.play(s,1)
P(\test,start:\rushes,resources:(impulse:{Impulse.ar(5)}.asDefName),music:{|p b e|
	(
		instrument: e.impulse,
		dur: b.sum
 ).play
});
*/


