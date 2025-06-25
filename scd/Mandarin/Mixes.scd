~dir =PathName("~/tank/super/scd/Mandarin/".standardizePath);
~songs.entries.collect(_.fileNameWithoutExtension).do(_.postln)
~load = {|i| ~dir +/+ i ++ ".scd" => _.load};
~dir +/+ "another.scd" => _.load
(type:\seg, section:0).play

	"~/tank/super/scd/Mandarin/WindArrange.scd".standardizePath.load;
( //
//  sections:
//  _________
//	"countoff"
//	"V1L1"
//	"newBridge"
//	"G chorus line 1"
//	"repeat"
//	"V1L12"

~shortChorus = [\chorus, \repeat].q;
~extendedChorus = [\chorus, \chorus, \chorus, \repeat].q;
[type: \seg, section: [ ~extendedChorus, \V1L12 ].q, extra: {
	(instrument:\sawSynthSustain,att:2,amp:0.2, freq:[-25,-15].df(\c),dur:16*Song.quarter).play
}
].pp

)
