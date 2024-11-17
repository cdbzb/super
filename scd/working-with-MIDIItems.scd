(
m = MIDIItem("bassline_241112_104447");
[0.54, 0.72, 0.61, 0.7,  0.72, 0.73, 0.72, 0.62, 0.73, 0.66, 0.62, 0.72, 0.65,  0.72, 0.66, 0.66, 0.63, 0.6,  0.72, 0.45]
// [50.0, 50.0, 49.0, 49.0, 43.0, 47.0, 52.0, 52.0, 50.0, 50.0, 49.0, 49.0, 41.0, 41.0, 44.0, 53.0, 44.0, 43.0, 43.0, 36.0]

=> m.player.filterNotesKey( \amp, _) => _.play(MicroKeys().synth_(
{ |gate=1 ampLag=0| 
        var freq=\freq.kr(400,\freqLag.kr(0.05)) * ( \poly.kr /120  ).midiratio;
        var width=\width.kr(6);
        //var gate=\gate.kr(0);
        Gendy2.ar(minfreq:freq-width,maxfreq:freq+width)
        =>Mix.ar(_) *0.5
        +Gendy1.ar(minfreq:freq-width,maxfreq:freq+width)
        * 0.1 * \amp.kr(0.5,ampLag)
        => (PlateReverb.ar(_,10,mix:\mix.kr(1)) ++ (_*0.5)) => Mix.ar(_)
        * Env.asr(\attack.kr(0.5),1,\release.kr(8)).kr(2,gate:gate)
		=> LeakDC.ar(_)
        =>Out.ar(\out.kr(0),_)
    }.asDefName
	, [width:[2,60, 120],mix: [ 1, 1 ], release:[ 3, 0 ] , attack:[0, 1 ]]))
// m.pasteKey(\midinote)
)

