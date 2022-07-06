(
s.waitForBoot{
	Song(\warpTest,[]).current;
	["first line",[1,3,5,4,3,4,2,3].dm(\c)].addLine;
	P.tune(\first);
	Song.setTempoMap(\first,"qe e qe e q q q q ".asBeats);
	Song.firstTempoMap2=TempoMap("qe e qe e qe e qe e".asBeats,Song.durs[\first].list);
	P(\hat,start:\first,music:
		{ |p b e|
			"e x x e x x".asBeats.dup(6).flat
			=> _.warpTo( 
				Song.firstTempoMap2..quantizeWindow(0.5,3)
			)
			 =>_.q(1)=>[dur:_,instrument:\hihat]=>_.pp;
		}
	);
	P(\,start:\first,music:{|p b e| 
		[
			//dur: 0.5.dup(16).warpTo(e.tempoMap).q
			dur: 


//[ 1.807 - 0.3, 0.499, 1.472, 0.481, 1.013, 1.023, 0.95, 1.536 ]
[ 1.824-0.3/4!4, 0.54 -0.12, 1.47 +0.02, 0.462 +0.1, 1.051, 0.973, 0.983,1 ].flat
//[ 1.824-0.3/4!4, 0.54, 1.47, 0.462, 1.051, 0.973, 0.983, 1 ].flat

//[0.5,0.5,0.5,0.5,0.5] => e.tempoMap.mapBeatsInverse(_) =>_.postln


			//=> e.tempoMap.mapRecordedDurs(_) =>
			=>_ .warpTo(e.tempoMap)
			=>_.q,
			freq:[11!4,7,6,5,4,4,5, 5].flat.df(\c,3).q,
			instrument:\sawSynth,
			att:0.1,rel:0.2

		].pp
	});
	P(\clap,start:\first,music:{|p b e| 
		[
			instrument:\rimshot_808,
			//dur: [ 1.23-0.2, 2.081, 1.381+0.2, 2.012, 1.597 ].warpTo(e.tempoMap).q,
			dur: "q qq qEE EqQ E " .asBeats.warpTo(e.tempoMap).postln.q,
			amp:[0,1,1,1,1].q /10,
			out:Effect( { |i| TwoTube.ar(i,loss:0.96,d2length:SinOsc.ar(0.3).range(60,500),d1length:666) +i * [0.4,1]/2 },inputChannels:2  ).bus.index
		].pp;
	});

	["second line","r"].addLine;

}
)
