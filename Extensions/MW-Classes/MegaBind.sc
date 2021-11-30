MegaBind {
	var <pitches,<durs,<>inner;
        var <>voices,fx,<bind,<>release = 5;
	var <>names;

	*new {|pitches durs bind inner fx release| ^super.new.init(pitches,durs,bind,inner,fx,release)}
	init{|p d b i f r| 
		pitches = p; durs = d; bind = ( b ? [] ) ; inner = i ? I.d; fx = f ? I.d; release = r ? release;
		names=pitches.select(_.isSymbol);
		//TODO associate names with tracks correctly so
		names = pitches.collect{|i x| [i,x]}.select{|i| i[0].isSymbol}.collect{|i x| i[0]->(i[1]-x)}.asEvent;

		//pitches=pitches.split({|i| i.isSymbol}).collect(_.tail).flatten;
		pitches = pitches.reject({|i| i.isSymbol});
		voices = VoiceLeading(pitches,durs) => {|i| [i.valuesArray,i.durationArray]} ;//=> _.flop;
		voices = [freq: voices[0],dur: voices[1]] ++ bind;
		voices = voices.flop.collect{|i| Event.newFrom(i)};
		voices.do({|e| e.freqSeq={e.freq.asDemandFreqs.dq.demand(e.dur)}});
		voices.do({|e| e.freqDq={e.freq.asDemandFreqs.dq}}); // i.freqDq.demand(i.dur);
		voices.do({|e| e.gateSeq={e.freq.asDemandGate.dq.demand(e.dur)}});
		voices.do({|e| e.trigSeq={TDuty.kr(e.dur.dropLast.dq,0,1)}})
	}
        pitches_{ |p|
          pitches = p;
          this.reinit;
          ^this
        }
        update{ |p d|
          pitches = p; durs = d;
          this.reinit;
          ^this
        }
        bind_{ |b|
          bind=(bind++b => _.asEvent =>_.asPairs);
          this.reinit;
          ^this
        }
	reinit{ 
		voices = VoiceLeading(pitches,durs) => {|i| [i.valuesArray,i.durationArray]} ;//=> _.flop;
		voices = [freq: voices[0],dur: voices[1]] ++ bind;
		voices = voices.flop.collect{|i| Event.newFrom(i)};
		voices.do({|e| e.freqSeq={e.freq.asDemandFreqs.dq.demand(e.dur)}});
		voices.do({|e| e.gateSeq={e.freq.asDemandGate.dq.demand(e.dur)}});
		voices.do({|e| e.trigSeq={TDuty.kr(e.dur.dropLast.dq,0,1)}})
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

+DUGen {

	zeroPad{
		^[0,this].dq
	}

}

