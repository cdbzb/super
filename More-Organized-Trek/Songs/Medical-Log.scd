(
// line 380
var guitar,guitar2,piano;

//re-connect if vst exists
try{ ( Song.currentSong == \medical).not.if{ 
	guitar = Song.guitar;
	// guitar2 = Song.guitar2;
	// piano = Song.piano;
} };

Song(\medical,[]).current;
Song.resources.condition=Condition.new;

// initialize if none
guitar.isNil.if{Song.guitar=AAS_Strum()}{Song.guitar=guitar}; 
// guitar2.isNil.if{Song.guitar2=AAS_Strum()}{Song.guitar2=guitar2};
// piano.isNil.if{Song.piano = PF()};

Song.resources.vstis = [Song.guitar, Song.guitar2, Song.piano];

Song.resources.infrastructure=FunctionList.new([
	{
		 fork {
			Song.guitar.condition.wait{Song.guitar.controller.loaded};
			// Song.guitar2.condition.wait{Song.guitar2.controller.loaded};
			// Song.piano.condition.wait{Song.piano.controller.loaded};
			Song.resources.condition.test_(true).signal;
			Song.guitar.setPlayMode(\strum);
			Song.allNotesOff;
			0.05.wait;
		}

	}
]);
// ~stills ? ~stills = Stills.new("/Users/michael/tank/Trek/video for stills etc/media/return to tomorrow.mov");
Stills().current;
// Stills.current=~stills;
Song.synthVTracks = EventWithDefault(
		\default, {
			DWGReverbC1C3.ar(_, len:2000, c1:1, c3:10, mix:0.1)
			/ 5
		},
		\mo, { |dur|

			{|i|
				DWGReverbC1C3.ar(i , len:2000, c1:1, c3:10, mix:0.1)
				// => MoogFF.ar(_,1300,3)
				// => MoogLadder.ar(_, ffreq:1100, res:0.0, mul:1.0, add:0.0)
				// => {|i| DetectSilence.ar(i,doneAction:2); i}
				=> CrossoverDistortion.ar(_, amp:1, smooth:0.99, mul:0.2, add:0)
				* EnvGen.cutoff(dur,5)
				/ 1
			}
			
		} 
	);
["Medical Log. (boom) Stardate 4770.3. ",[4,3,2,1,-5, 1,-7,-4, -7,1,2,3, 1, -7,3].dm(\f,transpose: 6)].addLine;
P.still(\clear,timecode:0,music:{|p b e|
	e.still.(
		wait:b.sum,
		text:[ "Medical Log","Stardate 4770.3" ]
	)
});
P.synthV(\mo, filter: (midinote: _ - 12),  params: {|p b| [
	lyrics: "medical + + - log star date four seven + seven + oh point three",
	vocalMode: \Open,
	paramToneShift: 295,
	paramTension: 1,
	paramBreathiness: 0.27,
	paramGender: 0.1,
	// phonemes: [ "m E d","@" ,"k @ l","","","","","","","","","","" ,""],
	language: \english,
	phoneset: \arpabet
] }, music:{|p b e|
	e.key.asString.split($_)[0].asSymbol.postln;
	p.synthVTracks.at(e.key.asString.split($_)[0].asSymbol).cs.postln;
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).(b.sum)
	}.play
});
P.double(\mo, filter: (midinote: _ - 12),  music:{ |p b e|
	{
		e.playbuf
		/ 5
	}.play
});
// ~doubleME = {|i| P.synthV{i, double:true, filter } };
// // P.synthV(\mo,double:true,take:\double,filter:Song.an_0.filter,params:Song.an_0.params,music:{|p b e|
// 	{
// 		e.playbuf
// 		=> p.synthVTracks.at(e.key.asString.split($_)[0].asSymbol).()
// 	}.play
// });

// ~justTheTune.('Stardate');
P.tune( _ <> [
	instrument: \harp,
	amp:0.02, decaytime:[ 10 ],
	coef:0.15,
	out: Effect.bus( Phaser2.ar(_,rate:0.21,fb:-0.5), inputChannels:2 )
].p);
[ "Do I list one death or two? " , [1,2,1,5,5,6,4.5].dm(\g,transpose: 6)].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["Do I list","one death or two?"],
	)
});
P.still(\controls, timecode:4105.05.seconds, music: { |p b e|
	e.still.value(
		wait: b.sum,
		fadeIn: b[0..1].sum,
		fade: Song.durTill(4)
	);
});
P(\guitar, music: { |p b e|
	\strum => Song.guitar.setPlayMode( _ ) ;
	[
		midinote: [ [1,3], [2, 4.5] ].dm(\g,4,\minor, transpose: 6).q ,
		dur: b.parse([6,1]).q,
		legato: 0.96,
	].p
	+=
	[
		dur: b.parse([1,1,1,[1,2/3],[1/3,1],1]).q,
		switch: [\muffleD,\muffleU,\muffleD,\down,\up,\down].q(inf) ,
		amp:[0.2,0.2,0.1,0.2].q(inf) / 2
	].p 
	<> (
		\out: Effect.bus(FreeVerb.ar(_,0.4,1)),
		type: \strum,
		instance: p.guitar
	) => _.play;

});
// P.tune('one death',Pmul(\freq,0.5,_));

P.synthV(\mo, 
	// take: \monotone, 
	filter: (midinote: _ - 24),
	params: {|p b| [
		lyrics: "do I list one death or two",
		leegato: [1, 1, 1, 1, 0.8, 1, 1],
		vocalMode: \Open,
		// gender: Env([0.4,0.4],2)
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).(b.sum)
			=> MoogFF.ar(_,2500) * 3
		}.play
});
P.double(\mo,
	pbind:{|p b| [ dur:b.q, midinote:[ 1, 1, 1, 1, 1, -5, 2 ].dm(\g,4,transpose: 6).q].p},  
	filter: (midinote: _ - 12), 
	music:{|p b e|
		{
			e.playbuf
			/5
		}.play

	}
);
P(\chords, music: { |p b e|
	MegaBind(
		[
			[\r,7,6],
			[\r,5,4.5],
			[\r,12.5, 12 ]
		].df(\g, 4,\mixolydian, transpose: 6)
		,
		b.parse([4,2,1]).push(2,1.05),
		[],
		{|i|  
			Pulse.ar(i.freqSeq.lag2([0,0.2].dq.demand(b.parse(4,3))),0.1,0.1)
			* Env.asr(0.5,1,3).kr(2,gate:i.gateSeq)
			=> Convolution.ar( _,Dust.ar(1000) => LPF.ar(_,1600) )
			/4

		},
		{|i|Splay.ar(i)}
	).play
});
P(\bassUp,syl:2,start:'one death',music:{|p b e| 
	[
		freq: [1,1,-5,2].df(\g,octave:3,transpose: 6).q,
		dur:b.drop(1).parse([1,2/3,[1/3,1],1]).q,
		instrument: \stringyy,
		amp:0.3
	].pp
});

SynthDef(\convoDust, {
	[ Dust.ar(100) => FreeVerb.ar(_, 0.6, 0.8), Saw.ar(\freq.kr(333)) ]
	=> Convolution.ar( *_ )
	=> MoogFF.ar(_,2400)
	* Env.perc(0.05,5).kr(2,gate:1)
	* \amp.kr(0.1)
	=> Out.ar(\out.kr(0),_)
}).add;
P(\chord,start:'one death',syl:2,music:
	{ |p b e|
		(
			instrument: \convoDust,
			strum:0.06,midinote:[1,3,5,11].dm(\g,scale:\minor,transpose: 6),
			out: {[0,1,[0,1]].choose}!4,
			amp:0.2
		).play
	}
);
//[" When Kirk's body died, ","r"].addLine;
//["Sargon was too far /*distant*/ ","r"].addLine;
//["from his receptacle to transfer back. ","r"].addLine;
["Sargon is dead. But is captain Kirk dead? (boom) ",[2,3,-5,1,-6,-7,1,-6,3.5,-7.5,-7.5].dm(\d,scale:\dorian,transpose: 6)].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["Sargon","is dead.."],
	).sequenceText([
		b.parse(4).sum, ["but is captain Kirk","dead?"]
	])
});
P(\guitar, music: { |p b e|
p.guitar.setPlayMode(\pick);
[
	midinote: [2,3,-5,-3,-2,-1.5].dm(\d,4,\dorian,transpose: 6).q,
	type: \strum,
	legato:[0.9,0.9,1,1,1].q(inf),
	instance: p.guitar,
	dur:b.parse([1,1,1,5,2]) ++ 2 => _.q,
	out: Effect.bus( 
		{ |i| CrossoverDistortion.ar(i, amp:0.5, smooth:0.5, mul:0.1, add:0)
		* Env([1,1,0],[b.sum,4]).kr(2,gate:1)
		/2
}
	)
].p.trace.play
});
// P.tune(\Sargon,{|i| Pfin(10,i) => Pset(\legato,[1,1,1,1,1,1,3,3,3,2].q,_)});

//bass patch
Song.resources.bassUp = (instrument:\sawTw,amp:0.2,out:0);
P.synthV(\mo, params: {|p b| [
	lyrics: "sargon, +,    is, dead, but, is, captain, +, kirk, dead r",
	lag: [0.1,    0.05, 0, 0, 0, 0, 0, 0, 0, 0, ],
	loudness: [0, 0,    0, 3, 3, 0, 0, 0, 0, 3, 0] => Env(_, b),
	legato: [1, 1, 1, 0.7, 1, 1, 1, 1, 0.8, 1, ],

	// gender: Env([0.4,0.4],1),
	vocalMode: \Open,
	tension: Env([-0.3,-0.3],1)
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).(b.sum)
	}.play
});
P.double(\mo, filter: (midinote: _ - 12), music:{|p b e|
	{
		e.playbuf
		/ 5
	}.play
}
);

P(\bassUp,start:\Sargon,syl:2,music:{|p b e| 
	[
		freq: [3,[ 2,6.5 ],[ 1.5,6.5 ]].df(\d,scale:\minor,octave:3,transpose: 6).q,
		dur: b.drop(1).parse([5,2,1])+[0,0,p.durs['His body'].list[0]]=>_.flat=>_.q,
		legato: [1,1,1].q
	].asEvent =>
	{|e|
		VoiceLeading([
			// [3,2  ,1.5],
			// [\r,6.5,\_ ]
			[3,6.5,\_]
		],
			e.dur.list
	).df('a-',scale:\minor,octave:3).p =>Pbindf(_,\legato,1) 
	=> {|i| i<>p.bassUp }  => _.play
	}
});
["His body is, but his ",[2.5,3, 1,-5.5, -6.5,1].dm(\c,transpose: 6)].addLine;

P.still( \kirk,  timecode:4122.seconds, music: { |p b e|
	e.still.value(
		wait: b.sum ,
		text: ["his body is","but his"],
		fade:5
	).sequenceText([
			b.sum, ["",""],
	]) 	
});
P.synthV(\mo, params: {|p b| [
	lyrics: "his body + is but his",
	vocalMode: \Open,
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).(b.sum)
	}.play
});
P.double(\mo, filter: (midinote: _ - 12), music:{|p b e| 
	{
		e.playbuf
		/5
	}.play
} );
// P.tune('His body');
P(\bassUp,syl:0,start:'His body',music:{|p b e|
	[
		//freq: [5.5,4.5].df(\c,octave:3,transpose: 6).q,
		freq: [[11, 1 ],\r].df(\c,octave:3,transpose: 6).q,
		//dur:b.drop(1).parse([[1,1,1/2],[1/2,1,1]]).q,
		dur:b.sum;
	].p
	<> p.bassUp => _.play
	
});
["consciousness is still in the receptacle ",[2,1,-7,2,4,2,3,4,3,1,-5].dm(\c,scale:\mixolydian,transpose: 6)].addLine;

P.still( \receptacle, start: \consciousness, syl:4, timecode:4127.seconds, music: { |p b e|
	e.still.value(
		wait: b.sum + Song.durs[e.start+1].list.sum ,
		fadeIn: b.parse([4])
	);
});
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["consciousness is still","in the receptacle"],
	)
});
P.synthV(\mo, params: {|p b| [
	lyrics: "consciousness + + is still in the receptacle + + +",
	vocalMode: \Open,
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key.asString.split($_)[0].asSymbol).()
		=> p.synthVTracks.at(e.key).(b.sum)
	}.play
});

P.double(\mo, filter: (midinote: _ - 12), music:{|p b e| 
	{
		e.playbuf
		/5
	}.play
} );
// P.tune(\consciousness);
P(\bassUp,start:\consciousness,music:{|p b e| 
	[
		freq: [[-1, 1 ],[-3, 3 ]].df(\f,octave:3,transpose: 6).q,
		dur:b.parse([8,3]) + [0,p.durs[\earlier].list[(0..3)].sum] =>_.q
	].p
	<> p.bassUp => _.play
});
P(\lick,start:\consciousness,music:{|p b e| 
	[5,4,3,2,1].df(\g,scale:\minor,transpose: 6).q
	=>
	{|i|
		[
			freq:i,
			amp:0.02,
			dur: b.q,
			instrument:\sparkTriangle
		].pp;
		[

			freq: i/2,
			dur: b.q,
			instrument:\pulse,
			out:1
		].pp
	}
});
["// it had been transferred into earlier.",[2,3,4,5,3,4,2,4,3,2].dm(\g,octave:4,transpose: 6)].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["it had been","transferred into earlier"],
	)
});
P.synthV(\mo, params: {|p b| [
	lyrics: "it had been transferred + into + earlier + +",
	vocalMode: \Open,
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).(b.sum)
	}.play
});
P.double(\mo, filter: (midinote: _ - 12), music:{|p b e|
	{
		e.playbuf
		/ 5
	}.play
} );
// P.tune(\earlier);
P(\lick,start:\earlier,syl:4,music:{|p b e| 
		[7,5,3].df(\d,scale:\mixolydian,transpose: 6).q
	=>{|i|
		[
			freq:i,
			amp:0.02,
			dur: b.drop(1).q,
			instrument:\sparkTriangle
		].pp;
		[

			freq: i/2,
			dur: b.drop(1).q,
			instrument:\pulse,
			out:1
		].pp
	}

});
P(\bassUp,syl:2,start:\earlier,music:{|p b e| 
	(
		//(freq:[1].df(\e),transpose: 6).play
		//instrument:\sawSynthSustain,
		//amp:[0.05,0.004,0.003,0.002,0.001],
		freq: [3,13].df(\c,octave:[3,4],transpose: 6),
		dur:b.sum
	)
	++ p.bassUp => _.play
});
[ "[SickBay] (The medical team hook Kirk's body up to a life support machine.) ","r",[6] ].addLine;
P.still( \looking,  timecode:4131.5.seconds, music: { |p b e|
	e.still.value(
		wait: 3 ,
		fade:2
		//text: ["all his vital organs","are now working, Doctor"]

	);
});
P.still( \console, lag:3, timecode:4138.seconds, music: { |p b e|
	e.still.value(
		wait: b.sum - 2 ,
		fadeIn:2,
		// text: ["all his vital organs","are now working, Doctor"]

	);
});
P(\machines,start:\SickBay,music:{|p b e| 
	var chord=[1,3,5,7].df(\b,scale:\locrian,transpose: 6);
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
		* Env([0,1,1,0],[5,5,10],[ \sin, 0 ]).kr(2,1)
	}.play
});
[ "NURSE: All his vital organs are now working, Doctor. ",[3,4,5,3,7,6,5,4,11,5,4,3].dm(\b,scale:\mixolydian,transpose: 6) ].addLine;

P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["all his vital organs","are now working, Doctor"],
	)
});
P.synthV(\feng, filter: (midinote: _ - 12),  params: {|p b| [
	lyrics: "all his vital + organs + are now working + doctor +",
	vocalMode: \Opera

] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key.asString.split($_)[0].asSymbol).()
		 => p.synthVTracks.at(\default).()
	}.play
});
// P.tune(\vital);
P(\tuneTest,start:\vital,music:{|p b e| 
	{
		Duty.kr(
			b.dq,
			0,
			[3,4,5,3,7,6,5,4,11,5,4,3].df(\b,scale:\mixolydian,transpose: 6).dq
		) => 
		Pulse.ar(_ ,0.2,0.1) => Phaser2.ar(_,rate:0.1)
		* 
		(
			Env([0.1,0.2,0.1,0],b.parse([ 3,5,4 ])).kr(0)
			+
			Env.perc().kr(0,gate: TDuty.kr(b.dropLast.dq))
		)
		=> FreeVerb.ar(_,0.8,0.8)

	}.play
});
P(\bass,start:\vital,music:{|p b e| 
	{
		var freq = [
			[1,4,2].df(\b,scale:\mixolydian,transpose: 6).dq ,
			b.parse([4,4,4]).dq,
			1
		].duty / [4,8] * [1.01,1,1.0033];
  		Saw.ar(freq,0.1)

	 * ( (Env.perc(0.2,2).kr(0,gate: TDuty.kr(b.dropLast.dq))) /1.5+0.3  ) 
	 * Env([1,1,0],[b.sum,3]).kr(2,gate:1)
	}.play
});
[ "(boom) Yes, we can keep them going for a few weeks, or a month. For all the good it'll do ","-1 1 3 2 1 -7 2 1 -7 1 2 3.5 2 1 -7.5 ".dm(\g,\minor) ++ "1 -7 -5 -3 -4 -5 -4".dm(\a,\mixolydian) ].addLine;
// P.tune();
P.still(\mccoy, timecode: 4112.03.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum/2,
		fade:b.sum/2,
		// text: ["yes, we can keep them","going"],
	)
	// .sequenceText([
	// 		b.parse([7]).sum, ["for a few weeks","or a month"],
	// 		b[7..13].sum, ["for all the good","it'll do.."]
	// ])
});
P.still(\clear,syl:0, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["yes, we can keep them","going"],
	)
	.sequenceText([
			b.parse([7]).sum, ["for a few weeks","or a month"],
			b[7..13].sum, ["for all the good","it'll do.."]
	])
});
P.synthV(\mo, take: \lead, params: {|p b| [
	lyrics: "r Yes, we can keep them going + for a few weeks, or a month for all the good it'll + do",
	legato: [1, 1, 1, 1, 1, 1, 1, 0.8, 1, 1, 1, 0.8, 1, 1, 0.8, 1, 1, 1, 1, 1, 1, 1, ],
	pitchTake: 1,
	// vocalMode: \Open,
	paramTension: -0.1

] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).(b.sum+5)
	}.play

});
P.double(\mo, take: \lead,
	filter: (midinote: _ - 12), 
	params: {|p b| [
	pitchTake: 1,
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).(b.sum)
	}.play

});
P(\chords, music: { |p b e|
	[
		freq: [\r, 
			[1, 3, 5, 11],
			[-7, 4, 7],
			[-6.5, 4, 6.5],
			[5.5, 1, 3.5], 
			[5.5, 6.5, 12, 14.5],
			[-5,-2,2,7]
		].df(\g, \minor).q,
		instrument: \stringyy,
		dur: b.parse([1, 1, 4, 5, 3, 4,4]).q
	].pp
});
P(\bassline, music: { |p b e|
	[
		freq: [1, -4, 5.5, 6.5].df(\g,[3,4],\minor).q,
		dur: b.parse([2, 9, 3, 8]).q,
		instrument: \sawSynthSustain,
		att: 1,
		out: Effect.bus(
			{|i| i
				=> HPF.ar(_,100)
				=> {| i| CombN.ar(i, 0.4,0.4) /2 +i}
				* -3.dbamp
			}
		)
	].ppm
});

// P.still( \plasticPerson, start: \weeks, timecode:4148.5.seconds, music: { |p b e|
// 	e.still.value(
// 		wait: b.sum ,
// 	);
// });
// P.still( \nurse, start: \vital, timecode:4139.seconds, music: { |p b e|
// 	e.still.value(
// 		wait: b.sum ,
// 		text: ["all his vital organs","are now working, Doctor"]
//
// 	);
// });
)

