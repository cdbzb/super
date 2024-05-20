(
	(
		amp: -10.rand.dbamp,
		freq: 7.rrand(1.0),
		section: (
			dur: 3,
			bass: (
				amp: 0.2, 
				instrument: \sawSynth,
				freq: [1, 3, 5].df(\d),
				out: Effect.bus({|i| FreeVerb.ar(i, 1, 1) },)		
			),
			chord: (
				amp:0.1,
				freq: 1.df(\B)
			)
		),
		chorus: (
			gendy: (
				amp:0.01,
				freq: 400,
				play: {
					{
						Gendy1.ar(initCPs: [12,11], minfreq: ~freq)
						* Env.linen(1, 1, 8).kr(2,gate:1)
						* ~amp
					}.play
				},
			)
		),
		play: {

			~section.do{|i| i.isKindOf(Event).if{
				i.put(\amp,~amp * i.amp);
				i.put(\freq,~freq * i.freq => _.postln );
			}};
			~chorus.do{|i| i.isKindOf(Event).if{
				i.put(\amp,~amp * i.amp);
				i.put(\freq,~freq * i.freq => _.postln );
			}};
			fork{
				~section.do({|i| i.isKindOf( Event ).if{ i.play }});
				~section.dur - 1 => _.wait;
				~chorus.do({|i| i.play})
			}
		}
	).play;
	// a.section.do{|i| i.isKindOf(Event).if{i.put(\amp,a.amp*i.amp)}};
	// a.chorus.do{|i| i.isKindOf(Event).if{i.put(\amp,a.amp*i.amp)}};
	// fork{
	// 	a.section.do({|i| i.isKindOf( Event ).if{ i.play }});
	// 	a.section.dur.wait;
	// 	a.chorus.do({|i| i.play})
	// }
)
a.chorus.bass.play

