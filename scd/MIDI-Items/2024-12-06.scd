(
a=MicroKeys(\dd);
a.split( [
	[\sn_808, {|x| [62, 64].includes(x)}, (tone: 200)],
	[\bd_808, {|x| [60, 48].includes(x)}, (tone: 100)],
	[\hat_808, {|x| [67, 69].includes(x)},(tone: 100)],
	// [\default, nil, (pan:1)]
]);
m = MIDIItem("drumset_241119_155106")
.reject{|e| [67, 69].includes(e.midinote)}
.fromNoteTo(18, 23);
// fork{
// 	loop{
// 		m.setParams([tone: 500]).play(a).dur.wait;
// 		m.play(a).dur.wait;
// 	}
// }
Song(\trashMe, []).current;
["one","r", m.dur.dup(4)].addLine;
P(\beat, music: { |p b e|
	fork{
		8.do{
			m.setParams([tone: 500]).play(a).dur.wait;
			m.play(a).dur.wait;
		}
	}
});
["two","r", m.dur.dup(4)].addLine;
// t = MIDIItemTempoMap(m, beats: "ex x q ex x q".beats);
t = m.tempomap("ex x q ex x q");
P(\crash, music: { |p b e|
	(instrument: \cymbalsDS, amp: 0.02).play
});
P(\tamb, music: { |p b e|
	{
	var levels = [5,1,2,1] /5 => _.dq(inf);
	var durs =  
	 (1/4 ! 4) 
	+ ( [1, -1] /80 => _.dup(80) ) //swing amt
	=> _.flat 
	=> _.warpTo(t.tempoMap.quantize(0.5))
	=> _.dq(inf);
	var triggers = TDuty.kr( durs, 0,1,gapFirst:0 );
	var energy = EnvGen.ar( Env.linen(0, 0.00, 0.015), triggers, doneAction:0   ) 
		* Demand.kr(triggers,0,levels 
			// * 40
			// *8
		);
	Shakers.ar(3, energy:energy   , decay: 1).tanh
	
	// /5
	* 2
	=> Pan2.ar(_, 0.8)
	// * EnvGen.cutoff(b.parse([4]).unbubble,3)
	=> DWGReverbC1C3.ar(_,mix:0.05)
	// /6
	=> Pan2.ar(_,0.75)

}.play;
});
Song.preroll = 1;
P(\keys, lag: -0.5, music: { |p b e|
	var a = MicroKeys(\keys).synth_(
		{
			Saw.ar(\freq.kr(50) + \poly.kr)
			* Env.perc().kr
			/10
		}.asDefName
	);
	fork{
		MIDIItem("keys_241206_102133")
		.end_(m.dur*4)
		// .record(a, latencyCompensation: s.latency)
		.play(a);
		m.dur * 4 => _.wait;
		MIDIItem("keys_241206_102133")
		// .record(a, latencyCompensation: s.latency)
		.play(a);
		m.dur * 4 => _.wait;
		MIDIItem("keys_241206_102133")
		// .record(a, latencyCompensation: s.latency)
		.play(a)
	}

	

// MIDIdef.noteOn(\test,{|v n| [v, n].postln})	;

});
P(\beatTwo, music: { |p b e|
	[
		dur: "e e e e e e e e ".beats.warpTo(t.tempoMap.quantize).q(inf),
		freq: [1, -5, -6, -7.1, ].df(\c, tuning: \valotti).q(inf),
		rest: [[1].q(8),[\r].q(8)].q(inf),
		// rest: [1, 1, 1, 1, 1, 1, 1, 1, \r].q(inf),
		instrument: \harpGendy,
		out: (0..4).q(inf)
		
	].pp
});
P(\beat, music: { |p b e|
	fork{
		8.do{
			m.setParams([tone: 200]).play(a).dur.wait;
			m.setParams([tone: 800]).play(a).dur.wait;
		}
	}
});
P(\hat, music: { |p b e|
	var n;
	n =
	MIDIItem("drumset_241119_155106")
	.select({|e| [67, 69].includes(e.midinote)})
	.copyBounds(m);
	fork{
		8.do{
			n.play(a).dur.wait
		}
		
	}
	
});
P(\connector, music: { |p b e|

	var a = 
	MicroKeys.mono(\lead)
	.synth_({
		Saw.ar( \num.kr(400).midicps.lag(\lag.kr(0.5))
		* (\poly.kr(1) / 127 => _.midiratio))
		/2
		* Env.asr().kr(2,gate:\gate.kr(1))
		=> {|i| DelayN.ar(i) / 2 + i}
		=> MoogFF.ar(_, CC(24, \freq.asSpec).bus.kr)
		=> PanAz.ar(5, _,Sweep.ar(1, 0.5))
	}.asDefName);
	a.activate;
	// MIDIItem("lead_241206_112010");
	MIDIItem("lead_241206_125437")
	// .record(a, latencyCompensation: s.latency)
	.play(a)
	// [
	// 	freq: 
	// ].ppm
});
)
().play
