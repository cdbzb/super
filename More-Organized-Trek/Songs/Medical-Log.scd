
(
// line 380
Song(\medical,[]).current;
~stills ? ~stills = Stills.new("/Users/michael/tank/Trek/video for stills etc/media/return to tomorrow.mov");
Stills.current=~stills;
Song.synthVTracks = EventWithDefault(
		\default, {
			DWGReverbC1C3.ar(_, len:2000, c1:1, c3:10, mix:0.1)
			/ 5
		}
);
["Medical Log. (boom) Stardate 4770.3. ",[4,3,2,1,-5, 1,-7,-4, -7,1,2,3, 1, -7,3].dm(\f)].addLine;
P.synthV(\xuan, filter: (midinote: _ - 12),  params: {|p b| [
	lyrics: "medical + + - log star date four seven + seven + oh point three",
	language: \english,
	phoneset: \arpabet
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});

P.double(\xuan, filter: (midinote: _ - 12),  music:{ |p b e|
	{
		e.playbuf
		/ 2
	}.play
});

// ~doubleME = {|i| P.synthV{i, double:true, filter } };

// // P.synthV(\xuan,double:true,take:\double,filter:Song.xuan_0.filter,params:Song.xuan_0.params,music:{|p b e|
// 	{
// 		e.playbuf
// 		=> p.synthVTracks.at(e.key).()
// 	}.play
// });

~justTheTune.('Stardate');
[ "Do I list one death or two? " , [1,2,1,5,5,6,4.5].dm(\g)].addLine;
P.tune('one death',Pmul(\freq,0.5,_));

P.synthV(\xuan, 
	// take: \monotone, 
	filter: (midinote: _ - 24),
	params: {|p b| [
		lyrics: "do I list one death or two",
		legato: [1, 1, 1, 1, 0.8, 1, 1],
		gender: Env([0.4,0.4],2)
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
P.double(\xuan,
	pbind:{|p b| [ dur:b.q, midinote:[ 1, 1, 1, 1, 1, -5, 2 ].dm(\g,4).q].p},  
	filter: (midinote: _ - 12), 
	music:{|p b e|
		{
			e.playbuf
			/5
		}.play

	}
);
P(\bassUp,syl:2,start:'one death',music:{|p b e| 
	[
		freq: [1,1,-5,2].df(\g,octave:3).q,
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
			strum:0.06,midinote:[1,3,5,11].dm(\g,scale:\minor),
			out: {[0,1,[0,1]].choose}!4,
			amp:0.2
		).play
	}
);
//[" When Kirk's body died, ","r"].addLine;
//["Sargon was too far /*distant*/ ","r"].addLine;
//["from his receptacle to transfer back. ","r"].addLine;
["Sargon is dead. But is captain Kirk dead? (boom) ",[2,3,-5,1,-6,-7,1,-6,3.5,-7.5,-7.5].dm(\d,scale:\dorian)].addLine;
P.tune(\Sargon,{|i| Pfin(10,i) => Pset(\legato,[1,1,1,1,1,1,3,3,3,2].q,_)});

//bass patch
Song.resources.bassUp = (instrument:\sawTw,amp:0.2,out:0);
P.synthV(\xuan, params: {|p b| [
	lyrics: "sargon, +, is, dead, but, is, captain, +, kirk, dead r",
	lag: [0.1,    0.05, 0,  0,    0,   0,  0,       0, 0,    0,      ],
	gender: Env([0.4,0.4],1),
	vocalMode: \light,
	tension: Env([-0.3,-0.3],1)
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(\xuan, filter: (midinote: _ - 12), music:{|p b e|
	{
		e.playbuf
		/ 5
	}.play
}
)

 
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
[ "[SickBay] (The medical team hook Kirk's body up to a life support machine.) ","r",[6] ].addLine;
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
[ "NURSE: All his vital organs are now working, Doctor. ",[3,4,5,3,7,6,5,4,11,5,4,3].dm(\b,scale:\mixolydian) ].addLine;
P.tune(\vital);
P(\tuneTest,start:\vital,music:{|p b e| 
	{
		Duty.kr(
			b.dq,
			0,
			[3,4,5,3,7,6,5,4,11,5,4,3].df(\b,scale:\mixolydian).dq
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
			[1,4,2].df(\b,scale:\mixolydian).dq ,
			b.parse([4,4,4]).dq,
			1
		].duty / [4,8] * [1.01,1,1.0033];
  		Saw.ar(freq,0.1)

	 * ( (Env.perc(0.2,2).kr(0,gate: TDuty.kr(b.dropLast.dq))) /1.5+0.3  ) 
	 * Env([1,1,0],[b.sum,3]).kr(2,gate:1)
	}.play
});
	
[ "MCCOY: Yes, we can keep them going for a few ","r" ].addLine;
[ "weeks, or a month. For all the good it'll do.","r" ].addLine;

P.still(\controls, start: 1, timecode:4105.05.seconds, music: { |p b e|
	e.still.value(
		wait: b.sum,
		fade: 
		Song.durTill(4)
	);
});
P.still( \plasticPerson, start: \weeks, timecode:4148.5.seconds, music: { |p b e|
	e.still.value(
		wait: b.sum ,
	);
});
P.still( \receptacle, start: \consciousness, syl:4, timecode:4127.seconds, music: { |p b e|
	e.still.value(
		wait: b.sum + Song.durs[e.start+1].list[0..8].sum ,
		text: [ "still in the","receptacle" ],
		fadeIn: b.parse([4])
	);
});
P.still( \kirk, start: 'His body', timecode:4122.seconds, music: { |p b e|
	e.still.value(
		wait: b.sum ,
		text: ["his body is","but his consciousness"],
		fade:5
	);
});
P.still( \looking, start: \machine, timecode:4131.5.seconds, music: { |p b e|
	e.still.value(
		wait: 3 ,
		fade:2
		//text: ["all his vital organs","are now working, Doctor"]

	);
});
P.still( \console, start: \machine,lag:3, timecode:4138.seconds, music: { |p b e|
	e.still.value(
		wait: b.sum - 2 ,
		fadeIn:2
		//text: ["all his vital organs","are now working, Doctor"]

	);
});
P.still( \nurse, start: \vital, timecode:4139.seconds, music: { |p b e|
	e.still.value(
		wait: b.sum ,
		text: ["all his vital organs","are now working, Doctor"]

	);
});
)

