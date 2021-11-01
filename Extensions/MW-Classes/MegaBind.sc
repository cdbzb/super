MegaBind {
	var <>pitches,<>durs,<>inner;
        var <>voices,fx,<>bind,<>release = 5;

	*new {|pitches durs bind inner fx release| ^super.new.init(pitches,durs,bind,inner,fx,release)}
	init{|p d b i f r| 
		pitches = p; durs = d; bind = ( b ? [] ) ; inner = i ? I.d; fx = f ? I.d; release = r ? release;
		voices = VoiceLeading(pitches,durs) => {|i| [i.valuesArray,i.durationArray]} ;//=> _.flop;
		voices = [freq: voices[0],dur: voices[1]] ++ bind;
		voices = voices.flop.collect{|i| Event.newFrom(i)};
		voices.do({|e| e.freqSeq={e.freq.asDemandFreqs.dq.demand(e.dur)}});
		voices.do({|e| e.gateSeq={e.freq.asDemandGate.dq.demand(e.dur)}})
	}
	play{
		^{
                  fx.
                  (
                    Line.kr(0,1,release + voices[0].dur.sum,gate:1,doneAction: 2); //to free synth
                    voices.collect( inner ),
                    this
                  )
		//	=> fx
		}.play
	}

}

