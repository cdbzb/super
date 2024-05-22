(
// Monitor.new().play(2,2,0,2); ///AAAAAAAAK

Stills().current;
// ~stills.isNil.if{~stills=Stills("/Users/michael/trek/BySection/media/return to tomorrow.mov").current};
// ~stills = Stills().current;
//Song.dursFile_("/Users/michael/tank/super/theExtreme_Sep18");
~sickBay=Song(\sickBay,[]).current;
Song.speaker =Library.at(\functions,\prep).("/Users/michael/tank/IR/Saane/Speakers_&_Telephones/Very_small_speaker_mono.wav");
Song.synthVTracks=EventWithDefault();
Song.synthVTracks.aiko = { |preGain=1 ratio=2 amp = (1/8) len=2000 mix=0.1 |
	{ |i|

		i.() * preGain
		=> SoftKneeCompressor.rms(_,  thresh:-10, ratio: ratio, knee:6, attack:0, release:0.05, makeUp:0, rms:40) 
		* amp
		=> DWGReverbC1C3.ar(_,len:len,mix:mix)
		=>.first DetectSilence.ar(_,doneAction:2)
	}
};
Song.synthVTracks.default = Song.synthVTracks.aiko;

Song.synthVTracks.genbuTop = { |preGain=1 ratio=2 amp = (1/8) len=2000 mix=0.1 |
	{ |i|

		i.() * preGain
		=> SoftKneeCompressor.rms(_,  thresh:-10, ratio: ratio, knee:6, attack:0, release:0.05, makeUp:0, rms:40) 
		* amp
		=> DWGReverbC1C3.ar(_,len:len,mix:mix)
		=>.first DetectSilence.ar(_,doneAction:2)
	}
};
Song.synthVTracks.xuan= {
	{|i|
		PartConv.ar(i,2048,Song.speaker)
		/8
		/4
	}
};
// P(\filter,start:0,music:{|p b e| 
// 		p.pts.select{|i| i.still.notNil}.select{|i| i.name.asString.contains("halass") }.do{|i|i.monitor.postln}
// });
["Sick Bay.. Sick Bay, Mc- Coy","e c f# d e g#"].addLine; //0
Trek.cast.mccoy=\xuan;

P.synthV(\genbu, take: \lead, params: {|p b| [
	lyrics: "Sick Bay r r r r",
	phonemes:["s i k", "b e i"],
	filter: (midinote: _ - 12), 
	legato: [1,0.3,1,1,1,1, ],
	lag: [0.1, 0, 0, 0, 0, 0],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(\genbuTop).(mix:0.1)
	}.play

});
// P(\guide0,start:0,music:~sickBay.pbind[0]=>Pfin(2,_));
P(\pad, music: { |p b e|
	[
		instrument: \visual_pad, rel: 3,
		freq: [
			[1, 3].df(\c),
			[1, 3].df(\d),
			[1, 3].df(\e),
			[1, 3].df('f#')
		].q,
		amp:0.2 * -4.dbamp,
		// instrument: \stringyy, mix: 0, amp: 0.1,
		lag: [0.1, 0, 0, 0].q,
		out: 4,
		dur: e.bAll.parse([2, 3, 1, 2]).q
	].pm.play;
	[
		instrument: \visual_pad,
		freq: [
			[1, 3].df(\c),
			[1, 3].df(\d),
			[1, 3].df(\e),
			[1, 3].df('f#')
		].q,
		amp:0.3,
		instrument: \stringyy, mix: 0, amp: 0.1 * -4.dbamp,
		lag: [0.1, 0, 0, 0].q,
		dur: e.bAll.parse([2, 3, 1, 2]).q
	].pm.play
});
P.still( \kirk, start:0 , timecode:3758.61.seconds, music: { |p b e|
		e.still.value(

				wait: b.parse([2]).unbubble,
				// fade: e.bNext.parse([3]).flat,
				fade: 0.1,
				monitor: 0,
				text:["Sickbay",""]
		)
});
P.still(\clear, timecode: 0.seconds,syl:1, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum,
		text: ["","SickBay, McCoy"],
	)
});
P.synthV(role: \mccoy, take: nil, params: {|p b| [
	lyrics: "r r Sick bay, mccoy +",
	filter: (midinote: _ - 12), 
	legato: [1, 1, 1, 0.6, 1, 0.5 ],
	paramExpression: 0.3,
	paramTension: 0.8

	// pitchTake: 1
] }, music:{|p b e|
	Trek.cast.mccoy=\xuan;
	{
		e.playbuf

		=> PartConv.ar(_,2048,p.speaker)
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0.3)
	}.play

});
P(\mcCoy3,music: { |p b e|
		Song.currentSong.pbind[e.start]<>[instrument:\mcCoy,
				//out:~sickBay.mcCoyBus,
				out:Effect({|i| PartConv.ar(i,2048,p.speaker) / 2},out:[ 0, 1 ]).bus.index,
				rest: [\r,\r,1,1,1,1].q,
				amp:0.015,
			].p => _.play  
});
P(\static,music: 
	{ |p b e|
		(lag: b[..1].sum, instrument:\crackle,dur:b[2..],out:p.mcCoyBus,amp:0.3).play
	}
);
P(\bendy,start:0,syl:1,music: { |p b e|
		[
			freq: [[3,1],[3,2],[4,2],[3,5.5]].df(\d,\lydian).q,
			dur: b.drop(1).parse([2,1,1]) ++ e.bNext[0] =>_.q,
			pan: [-1,1],
			instrument: \default,
			instrument: \wash, freqLag:0.1,
			amp: 0.03,
			// out:Effect.bus({|i| PartConv.ar(i,2048,p.speaker)},out:0, inputChannels:2)
		].ppm
}); 
//TODO Sargon should sound sick!
["Sar- gon here, i'm in your deck six brief- ing room","b- g- c  e- f g- a- b- b g# d "].addLine; //1
P(\pad, music: { |p b e|
	[
		freq: [ [1,3,4.5,7,17].df(\c,\minor), [-5,-7, 3, 5,7].df(\e,\mixolydian) ].q,
		dur: b.parse([8,3]).q,
		instrument: \visual_pad,amp:0.1 * -4.dbamp,freqLag:0.5,
		att:0.25
	].ppm;
	[
		freq: [ [1,3,4.5,7,17].df(\c,\minor), [-5,-7, 3, 5,7].df(\e,\mixolydian) ].q,
		dur: b.parse([8,3]).q,
		instrument: \stringyy,amp:0.08 * -4.dbamp,mix: 0,freqLag:0.5, release: 3,
		att:0.25,
		out: 3
	].ppm
});
P.still(\kirk, timecode: 3759.61.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		// text: ["",""],
	)
});
P.still(\clear,lag:0.05, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["Sargon","here"],
	).sequenceText2(
			b.parse([3]), [ 
			["I'm in your","deck six briefing-room"],
			],
	)
});
P.synthV(\genbu, take:"low", params: [ 
		lyrics: "Sa gon hi aim in yur dek siks bri fin rum",
		legato: [1, 1, 0.7, 1, 1, 1, 1, 1, 1, 1, 1, ],
		phonemes: ["","","h i r","","","","","s i k s","","",""],
		lag: [0.05,0,0,0,0,0,0,0,0,0,0,]
	],
	filter:{|e| e.midinote = e.midinote - 12},
	music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(\genbuTop).()
		}.play
	}
);
// P.tune('Sar- gon here');
["(enter Thalassa)","e5"].addLine; //f maj 7 //2
// P.tune('enter Thalassa');
P(\doorOpen,start:2,music: 
		//~stills.set('enter-Thalassa',(37*60+54.30));

		{|p b e|
			Prout({
				var vol=0.26;
				var thalassaBus=Bus.audio(s,1).index;
				p.thalassaVerb=Synth(\verbb,[\in,thalassaBus]);
				s.bind{Synth(\door,[\amp,vol])};
				1.05.wait;
				0.01.wait;
				(
					out:thalassaBus,
					amp:vol,
					instrument:\sawTw,
					degree:[4-7,6-7,8-7,10-7,4,6,8,10]-1,
					strum:0.1,octave:[5],sustain:4
				).play;
			}).play
		}

); 
P.still(\thalassaEnters, timecode: 3803.75.seconds, music: { |p b e|
	fork{
		1.wait;
		e.still.( 
			fadeIn: 0.1,
			wait: b[0] - 1,
			wait: 0, fade:b[0]
			// text: ["",""],
		)
	}
});
P(\padBass5,start:5,music: {|p b e|
		[
			degree:[\r,[1,5+7,3+14],[6-7,6,6+4,6+7]].q-1, //idea write 1 5' 3''
			root:6,
			octave:[2,3],
			instrument:\wash,
			out:[1,1,2].q,
			amp:0.2,
			att:2,
			dur: b.parse([[1,1,1,1],[1,1,1],[1,1]]).q
		].pp
	}
);
( /*glissChord*/ {Saw.ar(
	(\freq.kr(400,\freqLag.kr(2))
	+(LFBrownNoise1.ar(2!5))*rrand(0.99,1.01!5)
	=> Vibrato.kr(_,3,depth:0.004,delay:4,onset:4)))
	+ WhiteNoise.ar(0.001)
	* Env.asr(\att.kr(1),\amp.kr(1),\rel.kr(3)).kr(0,gate:\gate.kr(1))
	//=>MoogFF.ar(_,2800)
	=>RHPF.ar(_,Line.kr(0.1,2,17)*\cutoff.kr(1000),\q.kr(1))
	=>MoogFF.ar(_,6666,1,mul:2)
	=>Splay.ar(_)
	//=>FreeVerb.ar(_,1,\wet.kr(0.7)) *3
	=>( JPverb.ar(_,3,mix:\wet.kr(0.7))<!DetectSilence.ar(_,time:1,doneAction:2) ) 
	=>Out.ar(\out.ir(2),_)
}=>SynthDef(\glissChord,_)=>_.add; 
);
["You sound ter- ri- ble wait there for me","c4 d e c g3 e-4 d b-3 f"].addLine;  //3
P(\chords, music: { |p b e|
	MegaBind(
		[
			[\r, 3, 2.5, 2],
			[\r, 1, -6.5, \_],
			[\r, -5, -4, \_]
		].df(\c)
		,
		b.parse([2, 3, 2, 2]),
		[ ],
		{|i|  
			SinOsc.ar(i.freqSeq,0,0.1).tanh.tanh
			* 
			(
				Env.asr().kr(2,gate:i.gateSeq)
				+ Env.perc(0.1,0.1).kr(0,gate:( i.trigSeq * i.gateSeq ))
			)
			* -5.dbamp
		},
		{|i| Splay.ar(i)}
	).play
});
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["you sound terrible","wait there for me"],
	)
});
P.synthV(role: \mccoy, take: nil, params: {|p b| [
	lyrics: "you sound terrible + + wait there for me",
	legato: [1, 1, 1, 1, 0.5, 1, 1, 1, 1, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> PartConv.ar(_,2048,p.speaker)
		=> p.synthVTracks.at(e.key).()
		/2
		=> Pan2.ar(_,0.3)
	}.play

});
P.tune('ter- ri', _ <> [instrument: \sawSynthSustain, lagTime: 0.1, amp: 0.03].pm);
P(\mcCoy3,start:3,music: { |p b e|
		Song.currentSong.pbind[3]<>(instrument:\mcCoy,
				//out:p.mcCoyBus,
				out:Effect({|i| PartConv.ar(i,2048,p.speaker)},out:0).bus.index,
				amp:0.015
		) => _.play  
});
P(\static3,start:3,music: {|p b e|
		(instrument:\crackle,dur:5,out:p.mcCoyBus,amp:0.3/2).play
	}
);
["Sar- gon what's wrong?","b4 g b e5"].addLine;  //4
P.still(\medium_shot, timecode: 3807.9.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["Sargon","what's wrong?"],
	)
});
P.synthV(\aiko,params:
	[
		lyrics: "sar gan wats rong?",
		lag: [0.1,0,0,0],
	],music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	}
);
P(\whatsWrong4,music: {|p b e|
			Song.currentSong.tune[4]<>(instrument:\sawTw,\amp:0.5);

			[		instrument:\sawTw,
				dur:b.parse([[1,0.5],[0.5,1,1]]).q,
				spead:3,
				degree:[\r,4].q,
				// out:[0,1,2],
				root:0,
				octave:[3,2],
				amp:0.5  * -3.dbamp
			].pp;
			[
				degree: [5,7,10]+[0,0,0,7,7,7]-1 ,
				out: Effect.bus({
					|i| i => HPF.ar(_,300)
					* SinOsc.ar([2,3.33])
					=> {|i| 
						i + CombN.ar(i,0.3,0.3,3)} 
				},inputChannels:2,out:2),
				octave:4,
				strum:0.1,
				amp:0.1,
				sustain:[1].q(1)
			].pp
	}
); 
P(\verbFade4,start:4,music:{~sickBay.thalassaVerb.release(5)});
["no- thing of im- portance, Fa- tigue per- haps","f g- a- g- b- g- b- a- g- e-"].addLine;  //5
P(\plucks,music:{ |p b e|
		[ 
				degree:[Rest(),3,1,5-7,[3,6]-7].q-1,
				root:6,
				dur: b.parse([[1,1,1,1],1,0.66,[0.34,1],[1,1]]).q,
				octave:4,
				amp:0.07 * Song.fatiguePadAmp,
				instrument: \harp, coef:0.8
		].pp 
});
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["nothing of importance","fatigue, perhaps"],
	)
});
P.synthV(\genbu, take: "low", params:
	[
		lyrics: "neu zing af im po tans fa tig peu haps",
		phonemes: [ "n a"," s i N"," a v"," i m ","p o r ","t e n s"," f e ","t i g", "p a r ","h a p s" ],
		legato: [1, 1, 1, 1, 1, 0.8, 1, 1, 1, 1, ],
	],
	filter: {|e| e.midinote = e.midinote - 12},
	music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).(preGain:3.dbamp)
		}.play
	}
);
// P.tune('Fa- tigue');
Song.fatiguePadAmp = -3.dbamp;
P(\padBass5,start:5,music: { |p b e|
	var durs = b;
		Prout({
			var b, p = (out:2,root:6, instrument:\wash, amp:0.2 * Song.fatiguePadAmp, att:2,); //proto
			var a=durs.parse([[1,1,1,1],[1,1,1],[1,1,1]]);
			a[0].wait;
			(dur:a[0],octave:[2,3],degree:[1,5+7,3+14]-1,proto:p).play;//chord1
			a[1].wait;
			b=(proto:p,type:\note,octave:[2,3],degree:[6-7,6,6+4,6+7]-1,freqLag:10).play;//chord2
			b.postln;
			a[2].wait;
			(type:\set,id:b[\id],degree:[5.1-7,5.1,5.1+4,5.1+7]-1,amp: 0.2 * Song.fatiguePadAmp, root:6,octave:[2,3]).play//bend
		}).play;
	}
); 
P(\gliss,syl:6,music:{ |p b e|
				var a= (
						octave:4,q:2,cutoff:1900,
						degree:[6-7,3,6,8,9]-1,freqLag:10,root:6,
						instrument:\glissChord,
						out:2,dur:7,\rel:5,\att:9,
						amp: 0.03
				).play;
				// Song.durs[5].list[6..9].sum.wait;
				(
					type:\set, lag: b.drop(1).sum,
					id:a[\id],
					degree:[1,5,8,11,12]-1,
					octave:4,
					root:2
				).play
	});
["(beat) (formula) Sar- gon's for- mu- la...","d d5 e f# a f# c"].addLine;  //6
P.still(\looking, timecode: 3811.8.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.still(\ThalassaSpeaks,syl:1, timecode: 3812.seconds, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum,
		fade:1,
		text: ["",""],
	)
});
P(\strings, music: { |p b e|
	{
		var swell = Env([0,1,1,0],[b[0],b[1]]).kr(2,gate:1)
		  * WhiteNoise.ar(0.1)
		  => CombN.ar(_, 0.1,0.1,8);
		Gendy1.arWidth(freq:[1,-21].df(\d,\mixolydian))
		* Env([0,0,1,0],[b[0]-0.01,0.01,3]).kr(2,gate:1)
		* Song.fatiguePadAmp
		+ swell
		/10
	}.play
});
P(\moreChords, music: { |p b e|
	{
		var freq = [ [1, 3, 5, 7],[1, 3, 4, 6] ].df(\a, \dorian);
		Gendy1.arWidth(
			ampdist:2,
			durdist:5,
			adparam:0.0001,
			ddparam:1.0,
			freq:freq.dq.demand(b.parse([4,3])),
			width:1.01,
			ampscale:0.02,
			durscale:0.5,
			initCPs:2,
			knum:nil,
		)
		/25
		* Env([0,1,1,0],b.parse([1, 6, ] ++ [0.2])).kr(2,gate:1)
		=> Out.ar(\out.kr(0),_)
	}.play
});
P.still(\clear,syl:0, timecode: 0.seconds, music: { |p b e|
	var mon = 
	Stills.current.monitors[0];
	 e.still.( 
		fade: b[0],
		wait: 0.1,
		text: ["ß∂çøß","çç≈√øπ"],
		shrink: 0.5, 
		onTop: true,
		bounds: Rect(mon.left, mon.top, mon.width / 2, mon.height / 2).scale(Stills.scale)
		// fadeIn: b[0]
	)
});
P.still(\clearTwo, timecode: 0.seconds,syl:1, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum,
		text: ["Henoch's","formula"],
		// onTop:true
	)
});
// P.tune('(formula)');
P.synthV(\aiko, params: [
	lyrics: "r r hen nocks for mu la",
	filter: (midinote: _ - 12), 
	// phonemes: ["","","s A r\\`","k o n ts","f o r `","m j u","l @" ],

],music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
}
);
["yes, I wan- ted to be cer- tain there was no","3 1 -7 1 3 1 -7 -6".dm('c#') ++ "4 5 11 7 5".dm('e-',4)].addLine;  //7
Song.setTempoMap('wan- ted',"qe e e e e e q e e e e");
P(\cymbal, music: { |p b e|
	(
		instrument: \cymbalsDS,
		amp: 0.02,
		att:0.1
	).play
});
P(\Drums, music: { |p b e|
	["qe e qe e qqq q", \bd_808, \out, 2 ].dmx2(8, e.tempoMap)
	=> Ppar(_)
	=> _.play
});
P(\chord, music: { |p b e|
	[
		freq: [ [5, 11, 13], [5,7,13], [5,6,13],[ 5,6,12 ],[11.5,6,13] ].df('c#').q,
		instrument: \sawSynthSustain,
		lofreq:5000,
		hifreq:9000,
		// dur: p.quarters[e.start ] ++ Song.durs[\rrect].list[0..2] => _.parse([2, 3, 1, 1, 1]) => _.q,
			dur: "qq qqq q q  " .asBeats.warpTo( e.tempoMap.quantizeDft(0.3) ) ++ e.bNext[0].sum =>_.q,

		amp:0.02,
		att:1,
		// pan: 0.89,
		spread: 0.5, center: 0.5,
		rel:4
	].ppm
});
// P.still(\kirk, timecode: 3819.5.seconds, music: { |p b e|
// 	 e.still.( 
// 		wait: b.sum,
// 		text:["",""]
// 	)
// });
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["yes",""],
		fade: e.bNext[ 0..1 ].sum,
		onTop:true

		// fadeIn: b[0]
	).sequenceText2(
			b.parse([1,7]), [ 
			["I wanted","to be certain"],
			["there was no","error"]
			],
	)
});
P.synthV(\genbu, pbind: Song.enlarge(2), params:
	[
		lyrics: "yes ai won ted tu bi sur ten zer was no error +",
		phonemes: [" y e s", "","","","","","",""," z e r", "w a z"," n o w","e r"," o r" ],
		legato:[ 0.5,1,1,1,1,0.8,1,1,1,1,1,1,1 ],
	],music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	}
);
Song.quarters['cer- tain']=Song.parseBeats('cer- tain',[1.5,0.5,0.5,0.5,0.5,0.5,1,0.5,0.5,0.5,0.5,]);
P(\chords,start:'cer- tain',music:{|p b e| 
	fork{
		var inst = Barrier.collect(
			// {OteyPiano.ar(\freq.kr(400),rho:0.2)}.asDefName;
			{ 
				// arg trig=0;
				var freq = \freq.kr(220, 0.1) / 2;

			Pluck.ar(
				SinOsc.ar(
					Env.perc(0.001,0.1).ar(0,1).linexp(0,1,8000,16000),

				),
				\trig.tr(1),
				freq.reciprocal,
				freq.reciprocal,
				5,
				coef: \coef.kr(0.1)
			) 
			// /10
			=> MoogFF.ar(_,3000,1.5)
			=> _.tanh
			* Env.asr(0.005,1,1).kr(2,gate:\gate.kr(1))
			// => Out.ar(\out.kr(0), _)
		}.asDefName
		);
		inst = inst.value[0];
		[
			freq: [[1,3,5], [1,3,5], [-7,3,5], [-7,3,5], [-7,3,5], [-6,3,5], [-6,2,5]] .df('c#') ++ [[1,3,5]].df('b-',octave:4) => _.q,
			// dur: p.quarters[e.start] ++ Song.durs[\rrect].list[0..2] => _.q,
			dur: "q q q q q q q" .asBeats.warpTo( e.tempoMap.quantizeDft(0.3) ) ++ e.bNext[..2].sum =>_.q,
			// instrument:  inst,
			instrument: \defaultPiano,
			pan: -0.5,
			trig: 1,
			out: Effect(
				{|i|

					CrossoverDistortion.ar(i,0.01,0.9,0.4) 
					=> LeakDC.ar(_)
					=> DelayC.ar(_,0.2,SinOsc.ar(5).range(0,0.001)) 
					=> MoogVCF.ar(_,SinOsc.ar([0.11,0.1,0.13]).range(900,2000),0.8) * 2
				},inputChannels:3
			).bus.index
		].pp
	}
});
P.still(\kirkClose, timecode: 3412.2.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text:["",""],
		fadeIn:1.5,
		fade:2
		// text: ["what is it","Sargon"],
	)
});
P(\bass,start:'cer- tain',music:{|p b e| 
	[
		freq: [1,1,-7,-7,-4,  -5,-6].df('c#',octave:3).q,
	// 	dur: [3,1,3,1,4].q/2
	// ].p.play(p.quarters[e.start].asTempoClock);
	dur: "qe e qe e qee q q".asBeats.warpTo( e.tempoMap.quantizeDft(0.3) ++ p.tempoMap[e.start + 1]).q
].pp
});
["er- ror. For- mu- la is co- ",[5, -7, 1, 2, 3, 1, 3].dm(\g,\mixolydian)].addLine; //8
Song.setTempoMap('er- ror.',"e e e x x ex x");
P.still(\standingUp,syl:1, timecode: 3827.8.seconds, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum,
		text: ["formula is","correct"],
		fade:1
	).sequenceText2(
			b.drop(1).sum.bubble, [ 
			["",""]
			],
	);
});
P(\chord,syl:1, music: { |p b e|
	{
		Gendy2.arWidth(ampdist:4, durdist:4, adparam:1.0, ddparam:1.0, freq: [1, 2, 3, 1, 2, 3, -5].df(\g).dq.demand("e x x e x x".asBeats.warpTo(e.tempoMap) ++ 1), width:1.015, ampscale:0.05, durscale:0.005, initCPs:12, knum:nil, a:1.17, c:0.31, mul:1.0, add:0.0)
		/10
		* EnvGen.cutoff(wait:b.drop(1).sum+e.bNext[0], release:1, curve:nil, doneAction:2)
	}.play
});
// P.tune('For- mu- la');
P.synthV(\genbu,
	pbind: Song.enlarge(7),
	params:
	[
		lyrics: "r r for mu la is ko rekt dont bi kan ser - nd ",
		phonemes: ["","","","m y u","","i z","","","","","k o n","s a a","",""],
		lag:[0,0,0,0,0,0,0,  0,0,0.005,0,0,0],
		legato:[1, 1, 1, 1, 1, 0.8, 1,   0.7, 0.85,1, 1, 1, 1, 0.85, ]
	],music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	}
);
P(\bass,syl:1,start:'For- mu- la',music:{|p b e| 
		{
			b.postln;
			[1,-7].df(\g).dq.demand 
			(b.parse([[1,1,1,1/2],[1/2,1]]))
			//						,
			=> { |i| 
				Saw.ar(i * [0.99,1,1.013]/[4,8] , 0.1) 
				+SinOsc.ar(Vibrato.kr(i*[ 2,4 ] + [0,2]),0,0.005)
			} 
			=> MoogFF.ar(_,3000,1)
			=> Phaser2.ar(_,rate:0.09)
			* Env.perc(Line.kr(0.01,0.05,1),Line.kr(3,5,1)).kr(2,gate:TDuty.kr(b.parse([ [1,1,1,1/2],[1/2,1] ].dropLast).dq))
			=> EchoNone.ar(_,0.444,0.444,2.5) * 0.5
		}.play

});
// P.tune();
P(\pedalTones, music: { |p b e|
	fork{
		var inst = Barrier.collect(
			{
				var a = SinOsc.ar(\freq.kr(300), LocalIn.ar(2) * LFNoise1.ar(0.1,3), LFNoise1.ar(3,6)).tanh;
				9.do{a= AllpassL.ar(a,0.3,0.1.rrand(0.3!2),5).tanh };
				a.tanh
				* Env.asr(0,1,2).kr(2,\gate.kr(1))
				=> Pan2.ar(_,\pan.kr(-0.3))
				=> { |i| 
					Out.ar(\out.kr(0),i * \amp.kr(0.1));
					// LocalOut.ar(i)
				}		 
		}.asDefName
	);
		inst = inst.()[0];
		[
			freq: [15, 11,  [1,13]].df(\g,4).q,
			dur: b.parse([2,3,0]) + [0, e.bNext[..3].sum,e.bNext[4..7].sum] => _.q,
			amp:0.04, pan: -0.7,
			// legato: [0.8,1,1].q,
			instrument: inst
		].pp
	}
});
["rrect. Don't be concer -- ned, this is an","d4 c# e d f# g f# d e f# "].addLine;  //9
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum + e.bNext.sum => _.postln,
		text: ["don't be","concerned"],
	).sequenceText2(
			b.parse([7]), [ 
			["this is an","excellent body"],
			],
	)
});
P.synthV(\genbu,
	pbind: Song.enlarge(6),
	params:
[
	lyrics: "r r r r r r r  this is an excellent + + body+",
	phonemes: ["","","","k o n","s a a","","","d i s","i s","a n","e k","s e r","r e n t","b a","d i"],
	lag: [0,    0,    0.05, 0, 0, 0, 0,    0.05, 0, 0,0,0,0,0,0,0],
	legato: [1, 0.85, 1,    1, 1, 1, 0.85, 1,    1, 1, 1,1,1,1,1]
],music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
}
);
//P.tune('rrect.');
P(\lick,start:\rrect,music:{|p b e| 
		{|i|
				
				[5,4,3,2,1].df(\e,scale:\minor).dq.demand(b.parse([1,1,1,1,3]))
				=> {|freq|
						Pulse.ar( freq / [2,4,8], 0.2 ,0.1)
						// AAAARh
						* Env.perc( 0.3, [ [3,3,3,3,6].dq.demand(b),b[0..4].dq.demand(b),1 ]).kr(0,gate:b.parse([1,1,1,1,3]).dropLast.tduty)
                             //.kr( 0, gate:TDuty.kr(b[0..4].dq))
						*0.2
						=> FreeVerb.ar(_,0.2,1)
						=>.first DetectSilence.ar(_, amp:0.0001, time:0.1, doneAction:2)

				}
		}.play
				//legato:1!4++5 =>_.q
});
["ex- cel- lent bo- dy. "," g#4 e d d c#"].addLine; //10
//P.tune('ex- cel');
P.synthV(\genbu, params:
[
	lyrics: "ek se lent ba di",
	legato: [1, 1,   1, 1, 0.75]
],music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
}
);
P(\strum,start:'ex- cel',music:{|p b e| 
		[ [5,-5,-7,1,3,5,7,11,13],[5,-5,-6,1,3,5,6,11,13],[5,-5.5, -5.5,1,3,5.5,5.5,11,13] ].df(\e,scale:\mixolydian).flop.do({|freq x| [ freq: freq.q, instrument: \harp, coef: 0.1,
			dur: b.parse([5,1]) ++ e.bNext[0] => _.q,
			out:Effect.bus(MoogFF.ar(_,SinOsc.ar({ 2.0.rand }.dup(4)).range(580,2000)*0.5
		=> DelayN.ar(_,0.065,0.065.rand)
	), out: x % 4),
		].ppm})
});

P.tune('bo- dy', _ <> [instrument: \sawSynthSustain,pulse:0.5,amp:0.02].pm);
["There I feel be- tter al- rea- dy","c4 g3 a b c4 b3 a b d4 c"].addLine; //11
P(\note, music: { |p b e|
	(
		freq: 1.df(\c),
		lag: 0.1,
		instrument: \defaultPiano
	).play
});
P.still(\twoShot, timecode: 3834.1.seconds, music: { |p b e|
	 e.still.( 
		wait: b.parse([[1,1,1,1,1,1,1,1,1,0.5]]).unbubble,
		text: ["There",""],
	).sequenceText2(
			b.parse([1]), [ 
			["I feel better","already"],
			],
	)
});
	SynthDef( \synth_simpleSine, {
			arg freq=220, rate=0.1, pan=0.0, amp=1.0, dur=1.0, lfor1=0.08, lfor2=0.05, nl=0.5, filt=5000;
			var sig, sub, lfo1, lfo2, env, noise;
			lfo1  = SinOsc.kr(lfor1, 0.5, 1, 0);
			lfo2  = SinOsc.kr(lfor2, 0, 1, 0);
			sig   = SinOscFB.ar(freq, lfo1, 1, 0);
			sub   = SinOscFB.ar(freq*0.25, lfo2, 1, 0);
			env   = Line.kr(1, 0, dur*4.0, doneAction: 2);
			noise = PinkNoise.ar(nl, 0);
			sig   = (sig + sub + noise) * env;
		  //sig   = BLowPass4.ar(sig, filt);
			sig   = MoogFF.ar(sig, filt * 0.5, 0, 0, 1, 0);
			sig   = Pan2.ar(sig, pan, amp);
			sig   = FreeVerb2.ar(sig[0], sig[1], 0.5, 0.99, 0.9);
			sig = LeakDC.ar(sig);
			Out.ar(0, sig * 0.6);
	}).add;
P(\middleVoice, music: { |p b e|
	[
		freq: [\r, 4, 4, 3].df(\c).q,
		dur: b.parse([3,5, 1, 1]).q,
		instrument: \help_oteypiano
	].pp
});
P(\bassnotes, music: { |p b e|
	fork{
		var inst = Barrier.collect({
			var freq = \freq.kr(300);
			Pluck.ar(
				SinOsc.ar( Env.perc(0.001,0.1).ar(0,1).linexp(0,1,100,200),),
				\trig.tr(1),
				freq.reciprocal, freq.reciprocal,
				5,
				coef: \coef.kr(0.4)
			) 
			=> MoogFF.ar(_,3000,1.5)
			=> _.tanh
			/10
			// => LeakDC.ar(_)
			=>.first DetectSilence.ar(_, amp:0.0001, time:0.1, doneAction:2)
		}.asDefName);
		inst = inst.()[0];
		[
			freq: [\r, [-5,-2], 1].df(\c,4).q,
			dur: b.parse([ 3, 5, 2 ]).q,
			// instrument: \harp, coef:0.9
			instrument: inst
		].pp
	}
});
P.synthV(\genbu, params:
[
	lyrics: "zer ai fir be - - ta al re di",
	legato: [9, 10, 10, 10, 10, 10, 10, 10, 10, 8]/10,
	lag: [0.1,  0,  0,  0,  0,  0,  0,  0,  0,  0]
],music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
}
);
P(\note, syl: 7, music: { |p b e|
	(
		instrument: \stringyy,
		freq: [ 1,11 ].df(\c),
		out: Effect.bus( _ * Env([0,1,0],[2.5, 2.5],[0,-2]).kr(2,gate:1), inputChannels:2 ),
		amp:0.3
	).play
});
//P.tune('be- tter');
//in Time
P(\ting,lag:0.07, music: { |p b e|
		Synth(\synth_simpleSine, [\freq: 61.df(\c),\amp,0.1])
});
["in Time a host  -- body will become...  ",[-1,1,-7,1,2,1,-7,-6,-7,1].dm(\b,scale:\minor)].addLine; //12
Song.quarters[ \Time ]=Song.parseBeats(\Time,[1,3,3/4,1/4,2,1,1,1.5,0.5,1]);
P.still(\reverse, timecode: 3838.333.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["in","time"],
	).sequenceText2(
			b.parse([2]), [ 
			["a host body","will become"],
			],
	)
});
P.synthV(\aiko, params: [
	lyrics:"in taim a ho ost ba di will bi kum ",
	phonemes:["","","","","","","","","","k @ m"]
], music:{ |p b e|
		{
			e.playbuf  =>
			p.synthVTracks.at(e.key).()   
		}.play
});
P(\chords,start:\Time,music:{|p b e| 
	fork{
		var bar = Barrier.collect({
			var freq = \freq.kr(300);
			Pluck.ar(
				SinOsc.ar( Env.perc(0.001,0.1).ar(0,1).linexp(0,1,500 + LFNoise1.kr(1).range(-100,100),8000),),
				1,
				freq.reciprocal, freq.reciprocal,
				8,
				coef: 0.1
			)
			=> MoogFF.ar(_,3000)
			* \amp.kr(0.1)
			* EnvGen.cutoff(\length.kr(1), 2)
			=> FreeVerb.ar(_,0.2,1)
			* -8.dbamp
			+ 
			(
				VarSaw.ar(freq * Rand(0.99,1.01) ,SinOsc.ar(1.1),SinOsc.ar(0.2,pi.rand).range(0.2,0.8),mul:0.1)
				+ VarSaw.ar(freq/2 * Rand(0.99,1.01) ,SinOsc.ar(1),SinOsc.ar(0.2,pi.rand).range(0.2,0.8),mul:0.1)
				+ VarSaw.ar(freq/2 * Rand(0.99,1.01) ,SinOsc.ar(2),mul:0.1)
				+ VarSaw.ar(freq * Rand(0.99,1.01) ,mul:0.1)
				* Env.asr(0.1,1,1).kr(2,gate:\gate.kr(1))
				/20
			)

			=> Monitors.az(_,SinOsc.ar(Rand(0.1,0.2),Rand(0,pi)))
		}.asDefName);
		bar = bar.()[0];
		[
			instrument: bar,
			// instrument:\sawSynthSustain,
			freq:[\r,[1,11,13,15],[-7,12,14,17],[-6,11,13,16]].df(\b,scale:\minor).q,
			length: b, 
			strum:0.05,
			amp:0.04,
			amp: 0.2,
			legato:0.5,
			//	dur:b.drop(1).parse([3,3,3]).q
			dur:[ 3 ,4,4,2].q,
		].p.play(clock:p.quarters[\Time].asTempoClock);
	}
});
P(\bass,start:\Time,music:{|p b e| 
	[
		freq: [\r,1,-7,-6,-7,1] ++ ([2,3,4,5]*.t[1,-1])
		++ [\r,\r,\r,[5,-5]]
		=>_ .df(\b,scale:\minor,octave:[3]) 
		=>_.q,
		instrument:\sawSynth,
		dur: [2,8,8,2,2,2,2,2,2,2, 2,2,2,2,2].q/2
	].p.play(clock:p.quarters[e.start] ++ p.quarters[\accustomed] =>_.asTempoClock)
});
["(cis d a fis) accustomed to us (fis)",[-7,1,2,3,7,12,11,7,11,3].dm(\d)].addLine;
P.still(\clear,syl:3, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum,
		text: ["accustomed","to us"],
	).sequenceText2(
			b.drop(1).parse([5]), [ 
			["",""],
			],
	)
});
P.synthV(\aiko,params:[
	lyrics:"r r r r u ku stum too us r",
	phonemes:[ "","","","","A","kh A s","th @ m t","","","","" ]
], music: { |p b e|
		{
			e.playbuf  =>
			p.synthVTracks.at(e.key).()   
		}.play

});
Song.quarters[\accustomed]=Song.parseBeats(\accustomed,[1,1,1,1,1,0.5,0.5,0.5,0.5]);
P.tune(\accustomed);
P(\extraNote,start:\accustomed,syl:4,music:{|p b e| 
	(
		freq: [-12,-5,1].df(\a),
		dur:b.drop(-2).sum
	).play
});
//P(\bass,start:\accustomed,music:{|p b e| 
//
//	[
//		freq: []		instrument:\sawSynth,
//		dur: [2,4,2,2,4,2,2,2,2,2,2,2,2,2].q/2
//	].p.play(clock:p.quarters[e.start] ++ p.quarters[\accustomed] =>_.asTempoClock)
//});
["injections will no longer be necessary",[6,5,4,3,4,5,6,2,5,3,2,1].dm(\d)].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["injections will","no longer be"],
	).sequenceText2(
			b.parse([8]), [ 
			["necessary",""],
			],
	)
});
P(\bass,start:\injections,syl:0,music:{|p b e| 
	[
		instrument:\sawSynthSustain,
		freq: [[-4,12,-2],-5,-1].df(\d,octave:[5]).q,
		amp:[[0.07,0.03,0.02],0.05,0.05].q,
		legato:0.8,
		dur:b.drop(1).parse([4,3,4]).q,
		out:(-1)+[[5,4,3],2,1].q
	].pp;
});
P(\lick,start:\injections,syl:1,music:{|p b e| 
	[
		freq: [6,5,4,3,4,\r,5,4,3].df(\d,octave:4).q,
		dur: b.drop(1).parse([1,1,1,1,1,2,1,1,1]).q,
		att:0.1,
		out:Effect(MoogFF.ar(_,1100,2.6),out:3).bus.index,
		freqLag:0.01,
		legato:[1,1,1,1,0.5,0,1,1,1].q
	].pma(\sawSynthSustain).play;
});
P.synthV(\aiko, params:
	[
		lyrics:"in jek shuns will no lan gur bi ne se sse ri"
	],
	// legato:,
	music:{|p b e|
	
		{
			e.playbuf  =>
			p.synthVTracks[e.key].()   
		}.play
});
P(\lick2,start:\injections,syl:0,music:{|p b e| 
	[
		freq: [5,4,3,2,1,2].df(\d).q,
		instrument:\sparkTriangle,
		out:Effect(MoogFF.ar(_,1100,2.6),out:2).bus.index,
		amp:0.04,
		dur:b.drop(1).q,
		legato:1,
		freqLag:0.05
	].pma(\sparkTriangle).play;
});
["/*KIRK:*/ That will take months, perhaps years. We haven't that choice, Thalassa. ",[1,-7,1,3, 2,1,5,2,5,4.5,5,6,11,7,6,5].dm(\c,4)].addLine;
P.still(\twoShot, timecode: 3847.9.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		// text: ["that will take", "months"]
		text: ["",""]
		// fadeIn: b.sum
	)
});
P.tune(\months, _ <> [ instrument: \sawSynthSustain, amp: 0.02 ].pm);
P.still(\clear,\months,music:{|p b e|
	e.still.(
		text:["that will take months","perhaps years"],
		wait:b.sum,
		onTop:true
	);
	e.still.sequenceText(
		[
			b.parse([7]).sum,["we haven't that choice", "Thalassa"]
		]
	)
});
P.synthV(\genbu, params: [
	lyrics:"that will teik mons perhaps + yirs wi hafent + da at choisu tha la ssa",
	phonemes:["","","","m a n s s","p a r","h a p s","y i r z","","","","","","","",""],
	lag: [0.09, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,],
	legato: [1, 1, 1, 0.9, 1, 1, 0.8, 1, 1, 1, 1, 1, 1, 1, 1, 1, ],
	loudness: Env([-2, 0,0,1.5,1,2,1.5,0,1,1,1,1,4,3,2,1],Song.durs[\months].list)

],music:{|p b e|
	{
		e.playbuf 
		* Env([1.7,1.5,1],b.parse([3,4])).kr(0,gate:1)
		=> p.synthVTracks.at(e.key).(1.2)
	}.play
});
P(\extraNotes,start:\months,syl:2,music:{|p b e| 
	[
		freq: [[7,3].df(\e,scale:\mixolydian),[7,3].df(\a,scale:\mixolydian),[5,7].df(\d,scale:\mixolydian),[4,6,12].df(\d),[3,5].df(\d)].q,
		dur:b.drop(1).parse([3,6,1,1,1,1]).q,
		legato:[3,6,1,2,2].reciprocal.q,
		instrument:\wash,
		amp:0.05
		
	].pp;
});
P(\bass,start:\months,music:{|p b e| 
		[
				freq:[11,7,6,5.5,11.5,12,[6]].df(\c,octave:3).q,
				dur:b.parse([1,1,1,3,1,5,2]).q,
				legato: [1,1,1,0.9, 1,0.1, 1].q
		].pma(\sawSynthSustain).play
});
["/*MULHALL:*/ Husband. Feel the touch of my hand, husband. ", [3,2, 7,6,6,5,4,6, 5,4].dm('a-',scale:\minor)].addLine;
P.synthV(\aiko, params:
	[
		lyrics:"Heus band feel the teuch of my hand heus band",
		phonemes: ["x A ts","p @ n t","f i l","","","","","","x A ts","p @ n t",],
		legato:[1,0.95,1,1,1,1,1,0.9,1,1] 
	],
	music:{|p b e|
		
		{
			e.playbuf  =>
			p.synthVTracks.at(e.key).()   
		}.play
});
P.still( \thalassa, start: \Feel, timecode:3854.seconds, music: { |p b e|
		fork{
				e.still.text_(["husband..."]).wait_(b.sum).monitor_(0).fade_(2).play;
				b[0..1].sum.wait;
				e.still.setText(["feel the touch","of my hand"]);
				b[2..7].sum.wait;
				e.still.setText(["husband"])
		}
});
P.tune(\Feel, _ <> [instrument: \stringyy, ].pm);
Song.setQuarters(\Feel,[3/8,7/8,1/8,1/8,1/4,1/8,1/8,1,1/4,1/4]);
P(\bass,start:\Feel,music:{|p b e| 
		[
				instrument:\stringyy,
				amp:0.34,
				freq:[1,-7,-4].df('a-',scale:\minor,octave:[3,4]).q,
				dur:Song.quarters[\Feel],
				amp:1,
				// release: [8, 6, 4].q,
				out: Effect.bus({|i| i * EnvGen.cutoff(
					wait:b.sum -1.5,
					release:5,
					curve:nil,
					doneAction:2
				) },inputChannels:2)
		].pp;
});
["/*KIRK:*/ No, beloved. (boom) If we torment ourselves ",[6,5,3,1,-1, 4,5,11,7,6,5].dm(\f,4)].addLine;
P.synthV(\genbu, params: [
	lyrics:"no bilaved + + r if wi tarment +  ar selvs",
	phonemes:["","b i","l a","v e d","","","","t o r","m e n t","a u a r","s e l v z"]
],music: {|p b e|
	{
		e.playbuf.() 
		=> p.synthVTracks.at(e.key).()   
	}.play
}
);
P.tune(\torment, _ <> [instrument: \reedyAmp, amp:0.6].pm);

P.still( \kirk, start: \torment, timecode: 3859.7.seconds, music: { |p b e|
		e.still.value(
				wait: b.sum ,
				text:["No, beloved","if we torment ourselves"]
		);
});
P(\dyads,start:\torment,music:{|p b e| 
		VoiceLeading([
				[2,3, -6,-7],
				[7,\_, -4,-5]
		],b.parse([0.5,[0.5,1],2,4])).df(\c,scale:\mixolydian).pbinds.collect{|i x|
			i
			<> [
				instrument: \sparkTriangle, depth:0.01,
				amp: 0.05,
				freqLag:0.2,
				legato: [ [1, 0.9, 1,1],[0.9, 1, 1] ][x]=>_.q,
				out: Effect.bus({|i| i => Pan2.ar(_, i * 2 - 1) },)
			].pma
			=>_.play
		}
});
// Idea C min or Ab ala Waldstein?
["/*MULHALL:*/ Beloved. What will that word mean to a machine? ",[1,6,5].dm(\a)++[-7,1,5,3,-7,1,2,4,6].dm('c#',octave:6)].addLine;
//P.tune('to a machine');
P(\note, music: { |p b e|


	{
		Gendy1.arWidth(
			ampdist:4,
			durdist:4,
			adparam:1.0,
			ddparam:1.0,
			freq: 6.df(\a,[5,5]),
			width:1.015,
			ampscale:0.05,
			durscale:0.05,
			initCPs:12,
			knum:nil,
			mul:1.0,
			add:0.0
		) /75
		=> Pan2.ar(_,0)
		* Env([0,0,1,0],b.parse([0.8,0.2, 3]) + [0,0,3], [1, 2]).kr(2,gate:1)
	}.play;

	{
		Gendy1.arWidth(
			ampdist:4,
			durdist:5,
			adparam:1.0,
			ddparam:1.0,
			freq: 11.55.df(\a,[5,5]),
			width:1.015,
			ampscale:0.05,
			durscale:0.05,
			initCPs:12,
			knum:nil,
			mul:1.0,
			add:0.0
		) /75
		=> Pan2.ar(_,0)
		* Env([0,0,1,0],b.parse([[ 10, 0.8 ],[0.2,1], 1]) , [1, -3]).kr(2,gate:1)
	}.play;

});
P.synthV(\aiko, params:
	[
		lyrics:" bi lu ved? wat will zat word min tu a ma xin"
	],
	music: { |p b e|

		{
			e.playbuf  =>
			p.synthVTracks.at(e.key).()   
		}.play
});
P.still( \thalassa, start: 'to a machine', timecode: 3903.5.seconds, music: { |p b e|
		fork{
				e.still.value(
						wait: b.sum ,
						text:["beloved!?"]
				);
				b[0..2].sum.wait;
				e.still.setText(["what would that word","mean to a machine?"])
		}
});
P(\bass,start:'to a machine',syl:2,music:{|p b e| 
	[ 
		instrument:\sawSynthSustain,
		freq: [-7,1,5,3,-6,-2].df('c#',octave:[3,4]).q,
		legato:1,
		att:0.7!5++3 =>_.q,
		lag:(-0.03)!5++0 => _.q,
		out:[1,3],
		rel:2!5++4 =>_.q,
		// amp:0.05,
		amp: 0.12,
		dur:b.drop(1).parse([1,1,1,1,4,1]).q
	].p.play
});
P.tune(\mean,{|i|Pbindf(i,\lag, 0.02,\out,Effect( { |i| i => EchoNone.ar(_,0.4,0.3,4) * -3.dbamp} ).bus.index)},range:[0,2]);
P(\chord,start:\machine,syl:10,lag:-0.05,music:{|p b e| 
	(
		freq:[1,3,4.5,7].df(\c,scale:\minor),
		//TODO
		instrument:\stringyy,amp:0.15,
		out:[2,4],
		strum:0.1,
		dur:b.last-0.3,
		out:Effect.bus( { |i| TwoTube.ar(i,0.1,0.95,345,930)
	//	* Env([1,1,0],[b.sum,0.5]).kr(2,gate:1)
	} )


	).play
});
["/*KIRK:*/ Our thoughts boom boom boom boom will intertwine. (boom boom boom boom) ",[1,7,-1,-2,-3,-4,6,7,11,3, 1,2,3,4].dm(\d,4,scale:\dorian)].addLine;
P.synthV(\genbu, params: {|p b| [
	lyrics:" ar tats r r r r wil in ter twan r r r r",
	phonemes:["","s o ts","w i l","","","","","","","t w a e i n"],
	legato:[ 1,2.9, 1,1,1,1,1,  1,1,3 ]
]},music:{|p b e|

	{
		e.playbuf =>
		p.synthVTracks.at(e.key).(preGain: 1.1)
	}.play
});
P.still(\clear,timecode:0,music: {|p b e|
		e.still.value(

			wait:b.sum,
			text:["our thoughts","will intertwine"]
		)
	}
);
P(\chord,syl:0,start:\thoughts,music:{|p b e| 
	[
		freq: [[1,3,5,7],\r,[-4,1,3],[-4,-7,2]].df(\d,scale:\dorian,octave:4).q,
		legato:1,
		dur: b.parse([5,3,2,2]).q,
		out:3,
		attack:0.5,
		instrument:\visual_vowel,
		amp:0.05
	].pp;
});
P.tune(\thoughts, _ <>
	[
		// \amp, [1,1,0,0,0,0,1,1,1,1,0,0,0,0].q/10,
		rest: [1, 1, \r, \r, \r, \r, 1, 1, 1, 1, \r, \r, \r, \r].q,
		\legato, [1,3,0.5,0.5,0.5,0.5,1,1,1,3,0.5,0.5,0.5,0.5].q,
		\instrument, \wash, \amp, 0.02,
		freqLag:0
	].pma
);
//idea - Will they - Will they
P.tune('thoughts boom',{|i| Pmul(\freq,0.5,i) =>Pbindf(
	_,
	\instrument,
	\sawSynth,
	\rel,4,
	\att,0.1,
	\amp,0.5,
	\out, Effect.bus({|i| MoogLadder.ar(i,Line.kr(500,900,3),1)},inputChannels:2),
	//\addAction,\addToTail
)},range:[2,5],syl:1);
P(\lick1,start:\thoughts,syl:8,music:{|p b e| 
	[
		freq: [4,2,3,4,5].df(\c).q,
		dur:b.drop(1).q,
		instrument:\cleanPluck,
		decay: 5,
		damping: 100,
		legato:4
	].pp;

	[
		freq: [4,2,3,4,5].df(\c).q,
		dur:b.drop(1).q,
		amp: 0.02,
		pan: -1
	].ppm(\default)
	
});
P(\lick2,start:\thoughts,syl:10,music:{|p b e| 
	[
		freq: [1,-6,-7].df(\c).q,
		dur:b.drop(1).q,
		amp:0.01,
		out:1,
		instrument:\harp, coef:0.25
	].pp;
	[
		freq: [1,-6,-7].df(\c).q,
		dur:b.drop(1).q,
		pan: 1, amp:0.02
	].pm(\default)
});
["/*MULHALL:*/ Will they, husband?  Will they intertwine like this? ",[4,1,3,2].dm(\b,octave:5) ++ [-7,1,4,2,5,5.5,5,4,7].dm('c#')].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["will they,","husband?"],
	)
});
P.synthV(\aiko, params:
	[
		lyrics: "wil they huz band wil they in ter twa a an laik zis"
	], music: { |p b e|
		
		{
			e.playbuf  =>
			p.synthVTracks.at(e.key).()   
		}.play
});
P(\bass_stab,start:'Will they',music:{|p b e| 
		[ instrument:\sawTw,
				freq:[1].df('c#',octave:[5,6,7]) ++ [1,4].df('b-',octave:[3,4,5]) => _.q,
				amp:0.05,
				dur:b.parse([2,2]).q,
				wet:0,

		].p.play
});
P(\extra_notes,start:'Will they',syl:11,music:{|p b e| 
		[
				freq:[[1,3,7],[2,4,7],[3,5,7],[-7,2,4,7]].df(\d,scale:\mixolydian).q,
				dur: b.drop(1) ++ p.durs[\press].list[ 0..3 ] + [0,0,0,1] =>_.q,
				instrument:\sawSynth,
				rel:[3,3,3,6].q,
				att:[3,3,3,6]/10=>_.q,
				amp:0.08

		].pp;
});
//P.tune('Will they int', {|i| 
//		Pbindf(i,\instrument,\stringyy,\amp,0.2)
//		=>Pmul(\freq,0.5,_)},
//		//TODO Why is syl not set automagically??
//		syl:3,range:[4,13]
//);
P(\this,start:'Will they',syl:11,music:{|p b e| 
		(
				instrument:\wash,
				freq:[1,3,5,7].df(\d,scale:\mixolydian),
				dur:2
		).play
});
P.still(\thalassa,start:'Will they',syl:3,timecode:
	// 3914.542// original
	3915.5
	.seconds,music:{|p b e| 
		e.still.(
				wait:b.sum,
				text:["will they intertwine","like this?"]
		)
});
P(\bass,start:'Will they',syl:11,music:{|p b e| 
		[
				freq:[1,2,3,4].df(\d,octave:3).q,
				amp:0.05,
				instrument:\sawSynthSustain,
				dur: b.drop(1) ++ p.durs[\press].list[ 0..3 ] =>_.q,
				legato:1,
				lagTime:0.1
		].pma(\sawSynthSustain).play;
				
});
P(\xtraBassnote,start:'Will they',syl:7,music:{|p b e| 
	(
		freq: [1].df('a-',octave:[ 2, 3 ]),
		dur: b.drop(1)[0..2].sum 
	).play
});
[ "Can two minds press close like this?",[5,6,7,6.5,6.5,6,11.5].dm(\c)].addLine;
P.synthV(\aiko, params:
	[
		lyrics:" kan tu maindz press klos laik zis"
	],music: { |p b e|
	
		{
			e.playbuf  =>
			p.synthVTracks.at(e.key).()   
		}.play
	}
);
P(\chord,start:\press,syl:2,music:{|p b e| 
	[
		freq: [[1,3,4,7],[1,3,4,7],[1,3,4,6.5], ].df(\c,scale:\minor) 
		++ [[-5, 1, 5, 3]].df(\a) 
		++ [[1, 3, 5, 7]].df(\f) 
		++ [[-11,1,11,13,16,26]].df('c#')
		=> _.q,
		dur:e.bAll.drop(1).parse([1, 1, 1, 6, 1, 1]).q,
		amp: [3, 3, 3, 2, 2, 2]/30 => _.q,
		//instrument:\visual_pad, amp:0.2,
		// out:3,
		out: Effect.bus({|i| i=> DelayN.ar(_,0.03,0.03)=>  Phaser1.ar(_, 0.5, 0.134) }, out: 3),
		instrument: [\default, \default, \default, \defaultPiano, \defaultPiano, \defaultPiano].q
	].pp
});
//P.tune(\press);
P(\this,start:\press,syl:5,music:{|p b e| 
		(
				instrument:\wash,
				freq:[-5,1,5,3].df(\a),
				dur:2
		).play
});
P.still(\thalassa,start:'press close',timecode:3915.542.seconds,music:{|p b e| 
		e.still.value(
				wait: b.sum,
				text:["can two minds press close","like this?"]
		)});
["Can robot lips do this?" , [3,5,4,3,2,11].dm(\e) ].addLine;
//P.tune(\robot);
P.synthV(\aiko, params:
	[ lyrics: "kan ro bot lips do zis" ],
	music:{ |p b e|
		{
			e.playbuf  =>
			p.synthVTracks.at(e.key).()   
		}.play
	}
);
P(\this,start:\robot,syl:4,music:{|p b e| 
		(
				instrument:\wash,
				freq:[1,3,5,7].df(\f),
				dur:b.sum,
				legato:0.8
		).play
});
P.still(\thalassa,start:'robot lips',timecode:3920.5.seconds,music:{|p b e| 
		e.still.value(
				wait:b.sum-2,
				fade:2,
				text:["can robot lips","do this?"]
		)});
[ "(they kiss, then Kirk falls gently to the floor) (boooom boom boom boom boom boom boom boom) Sargon, /*what is it?*/ what's wrong? ",[11,7,6,5,4,3,2,1].dm('b-',scale:\minor)++[3,-7,1,4.5].dm(\f,scale:\mixolydian)].addLine;
P.synthV(\aiko, params:[lyrics:"Sar gon wats rong"],syl:7,range:[8,11],music: { |p b e|
		{
			e.playbuf  =>
			p.synthVTracks.at(e.key).()   
		}.play
		
});
P.still(\kiss,start:'kiss',
		timecode:3926.seconds
		//timecode:3927.5.seconds
		,music:{|p b e| 
			e.still.value(
				wait:b[0..4].sum,
				fade:1
			)
		}
);
P(\chord,start:\kiss,music:{|p b e| 
	(
		freq: [-11,1,11,13,16,26].df('c#'),
		out: [1, 3],
		instrument:\wash,
		amp:0.15,
		rel: 8
	).play
});
P.tune(\kiss,range:[8,12],syl:7);
P(\trem,start:\kiss,music:{|p b e| 
		var verb=Effect(FreeVerb.ar(_,1,Line.kr(0.7,1,5)),inputChannels:2, out:(0..4)).bus.index;
		var a=Synth(\trem2,[\out,verb]);//.dur(b[..17].sum);
		fork{b.sum + e.bNext.sum => _.wait; a.free};
		Synths(\trem2,\freq, [-11,1,11,13,16,26].df('c#'),\amp,0.05,\out,[0, 1, 2, 3, 4, 0]).dur(3,8);
		[
				type:\set,
				freq:[16,15,14,13,12,11,7,6,5.5,5,4.5,4,3,2.5,2,1.5,1].df('c#',octave:[4,5]).q,
				rate:11,
				id:a.nodeID,
				amp:Pseries(1,(-1/17), 17)/10,
				//dur: [3] ++ (1!19) /2 => _.q
				//dur: b.parse([1,1,1,1,1,1,1,1, 1,2/3,[ 1/3,1 ],1]).q
				dur: b[0..7] ++ (b[8..10].mean ! 10) => _.q
		].p.trace.play
});
// Song.durTillEnd(23)
P.still(\falling, start:\kiss, syl:4,  timecode: 3937.5.seconds,  music: {|p b e|
		e.still.value(
				//b.sum.wait
				wait:b[1..3].sum,
				fadeIn:1,
				fade:1
		)
});
P.still(\thalassa, start: \kiss,syl:7, timecode:3939.46.seconds, music: { |p b e|
		e.still.value(
				wait: b.drop(1).[0..3].sum ,
				text:["Sargon!","What's wrong?!"]
		);
});
["(McCoy and Chapel enter.) ","r",[1,3]].addLine;
P(\trill,start:\Chapel,music:{|p b e| 
	var strings = Synths(\stringyy,\freq,[7,11,7,11].df(\d),\out,(0..3), \amp,0);
	var bus = Bus.control(s,3);
	var time = 10;
	var len = b.sum + e.bNext.sum +p.secDur[e.start + 2] + p.secDur[e.start + 3] + 0.2;
	
	{SinOsc.kr(time.reciprocal/4) * EnvGen.cutoff(len, 0.1)}.play(s,bus.index);
	{LFNoise0.kr(0.4).unipolar*30 * EnvGen.cutoff(len, 0.1)}.play(s,bus.index+1);
	//{Line.kr(0,0.3,10,doneAction:2)}.play(s,bus.index+2);
	{Env([0,1,0]/8,[b.sum + e.bNext.sum ,p.secDur[e.start + 2] + p.secDur[e.start + 3] + 0.2]).kr(doneAction:2)}.play(s,bus.index+2);
	fork{ len - 3 => _.wait; strings.do(_.release) };
	fork{
		0.2.wait;
		bus.postln;
		strings.map(\mix,bus.index);
		strings.map(\width,bus.index+1);
		strings.map(\amp,bus.index+2);
		
	};
	//d=Synths(\wash,\freq,[7,1,-7].df(\d),\out,[(0..3)])
});
P.still(\mcCoyEnters, start:\Chapel,timecode: 3940.5.seconds, music:{|p b e|
		e.still.value(wait:b.sum - 2, fade:1);
		Synth(\door,[\amp,0.2])
});
["(wibble) hypo (hypo)",[33,3,-6.5,-16.5].dm(\c)].addLine;
P.tune(\hypo,_<>[instrument: \sparkTriangle, amp: 0.02].pm,range:[1,2],syl:0, );
P.synthV(role: \mccoy, take: \lead, params: {|p b| [
	lyrics: "r hypo + r",
	legato: [1, 1, 0.5, 1, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		/4
		=> Pan2.ar(_,0)
		// => p.synthVTracks.at(e.key).()
	}.play

});
P(\wibble,start:\hypo,music:{|p b e| 
		
	fork{
		{
			SinOsc.ar( LFSaw.ar({rrand(3.0,4)}!4,{rrand(0,1.0)}!5).range(400,1800),0,0.01 )=>Splay.ar(_)
			* Env.linen(0.2, b[0..2].sum-0.2-0.5,  releaseTime: 1.0,  level: 1.0,  curve: \lin).kr(2)
		}.play;
		b[0..2].sum.wait;
		Synth(\hypo,[\amp,0.1,\out,Effect.bus( { |i| BPF.ar(i,1000,7.5) => Pan2.ar(_, -0.2) },out:0, inputChannels: 1) ])
	}
});
P.still(\sensor, start:\hypo, timecode:3947.seconds, music:{ |p b e|
		e.still.value(
				wait:b[0..2].sum,
				text:["",""]
		);
		fork{
				b[0].wait;
				e.still.value(text:["hypo!"])
		}
});
P.still(\hypo, start:\hypo,syl:2, timecode:3949.5.seconds, music:{ |p b e|
		var window = e.still.value(
				wait:b.drop(1).sum
		);
		//fork{
		//		1.wait;
		//		defer{ e.still.text = "hypo" }
		//}
});
["/*MULHALL:*/ Doctor, help him! ",[1,-7,3,-7].dm(\e,scale:\mixolydian)].addLine;
P.synthV(\aiko,params:[ lyrics:" dak tar help him" ], music:{|p b e |
		{
			e.playbuf  =>
			p.synthVTracks.at(e.key).(preGain: 1.5)   
		}.play
});
//P.tune(\Doctor);
P.still(\mulhall, start:'help him', timecode:3953.0.seconds, music:{ |p b e|
		e.still.value(
				wait:b.sum,
				text:["Doctor","help him!"]
		)
});
P(\noise,syl: 1,  music: { |p b e|
	{
		Gendy3.ar(
			ampdist:1,
			durdist:1,
			adparam:1.0,
			ddparam:1.0,
			freq:[7].df(\d,6),
			ampscale:Line.kr(0,1,b.drop(1).sum),
			durscale:0.5,
			initCPs:[12, 11, 10, 2],
			knum:nil,
			mul:1.0,
			add:0.0
		)
		/180
		=> LPF.ar(_,1000)
		=> HPF.ar(_, 300)
		* Env([0, 1, 0],b.parse([2, 1]) + [0,3], [0, -6]).kr(2,gate:1)
	}.play
});
P(\setMccoy, music: { |p b e|
	Trek.cast.mccoy=\xuan;
});
["/*MCCOY:*/ (boom) He's dead.",[-7,-5,1].dm(\d)].addLine;
Trek.cast.mccoy = \xuan;

P.synthV(role: \mccoy, take: \lead, params: {|p b| [
	lyrics: "r he's dead",
	legato: [1, 1, 0.55, ],
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	Trek.cast.mccoy = \xuan;
	{
		e.playbuf
		/4
		// => p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
	}.play

});
P(\dead, music: { |p b e|
	// (
	// 	freq: [1, 21].df(\d,4),
	// 	instrument: \harp,
	// 	out: 1,
	// 	lag: b[..1].sum,
	// 	out: Effect.bus({|i| FreeVerb.ar(i, 1, 1)/10 },)
	// ).play
});
P.tune(\dead, _ <> [freq: [\r, -5, 1].df(\d).q,instrument: \wash, rel:3, att: 1, freqLag: 0.2, amp: 0.02].pm);
// P.tune(\dead,range:[1,2],syl:0);
P(\boom, music: { |p b e|
	// (
	// 	freq: -7.df(\d, 4),
	// 	out: Effect.bus({|i| DWGReverbC1C3.ar(i) },),
	// 	amp: 0.05
	// ).play
});
P.still(\mcCoy,syl:0, start:\dead, timecode:4003.0.seconds, music:{ |p b e|
		e.still.value(
				wait:b.sum,
				text:["He's","dead"]
		)
});
)
//Stills   ! {{{
// ~stills.isNil.if{~stills=Stills("/Users/michael/tank/Trek/video for stills etc/media/return to tomorrow.mov")}; 
// ~stills.set('whatsWrong?',2288.6);
// ~stills.set('kirk-face',(38*60+2.81));
// ~stills.set('enter-Thalassa',(37*60+54.30));     
// ~stills.set('sargonsFormula',2291.43); 
