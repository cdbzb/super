TempoMap {
  var <beats,<durs,<timesInBeats,<>timesInDurs, <env, <invEnv;
  var polynomial;
  *new { |beats = #[1,1,1,1,1,1,1] durs = #[1,1,1,1,1,1,1,1]|
    ^super.new.init(beats ,durs )
  }
  *fromDurs{ | dur | ^TempoMap( 1!dur.list.size,dur.list.array) } //expects a Pseq
  *fromB { | b| ^TempoMap( 1!b.size,b) }
  init { |b d|
	beats = b; durs = d;
	( durs.size != beats.size ).if{
		var newSize = ( beats.size min: durs.size ) - 1;
		beats = beats[(0..newSize)];
		durs = durs[(0..newSize)];
	};
	this.prRebuild;
	^this;
  }
  // rebuild every derived cache (timesIn*, env) from beats/durs. Shared by init
  // and both setters so env can't go stale after a mutation — env is read by
  // at()/mapBeats, so a stale env made e.g. a quantizeWindow result MAP LIKE THE
  // UNQUANTIZED ORIGINAL (quantize-tempomap-project.md §5).
  prRebuild {
	  timesInBeats = [ 0 ] ++ beats ++ beats.last => _.integrate;
	  timesInDurs = [ 0 ] ++ durs ++ durs.last => _.integrate;
	  env = Env(([0] ++ durs).integrate, beats);
	  invEnv = env.invert;   // performed time -> beat (plusEnv.sc)
  }
  beats_{|i|
	  beats = i;
	  this.prRebuild;
  }
  durs_{|i|
	  durs= i;
	  this.prRebuild;
  }
  mapBeatsPoly { | beats |
	beats = beats.integrate;
	^beats.collect{|i| polynomial.eval(i)}.differentiate;
  }
  quarter {
	  ^ durs.sum / beats.sum
  }

  at { |beat|
	  ^env[beat]
  }
  // Direction-explicit tempo-map protocol. Keep `at` for compatibility, but
  // new consumers should use timeAt/beatAt so the direction is not
  // inverted when switching between TempoMap and MIDIItemTempoMap.
  // TempoMap retains Env's endpoint-clamping policy in both scalar directions.
  timeAt { |beat|
	  ^this.at(beat)
  }
  // performed time -> ideal beat. Was `Env(beats, ([0] ++ durs).integrate)[t]`,
  // rebuilt per call AND malformed (levels = per-span beat counts, not
  // cumulative; times one LONGER than levels instead of one shorter) — it
  // returned a constant, so dursToBeats gave [x, 0, 0, ...]. Now the cached
  // inverse map (quantize-tempomap-project.md §5).
  interpolateBeatInverse { |time|
	  ^invEnv[time]
  }
  beatAt { |time|
	  ^this.interpolateBeatInverse(time)
  }
  dursToBeats { | array |
	  ^array.integrate.collect{|i| this.interpolateBeatInverse(i)}.differentiate
  }
  mapBeats { | b |
	  // Clamp non-positive spans to epsilon instead of .select-dropping them:
	  // dropping silently shortened the array and desynced a Pbind's \dur from
	  // its \midinote from that point on (quantize-tempomap-project.md §5).
	  ^b.integrate.collect{|i| this[i]}.differentiate.collect{|i| 1e-9 max: i}
  }
  // Naming convention: `beats` are musical spans; `durs` are elapsed seconds.
  // Therefore mapDurs maps second durations -> beat spans (the inverse of
  // mapBeats, which maps beat spans -> second durations).
  mapDurs { |durs|
	  ^this.dursToBeats(durs)
  }
  mapRecordedDurs { | durs |
	  ^this.mapBeats( durs/this.quarters.mean )
  }
  // at { |time|
  //   ^this.eval(time)
  // }
  quarters {
      ^this.mapBeats( 1.dup(beats.sum.floor) )
  }
  quantize { |amount = 1 start end|
	  start.isNil.if {
		  var quantized = durs.sum/beats.sum * beats * amount 
		  + (durs * (1 - amount));
		  ^TempoMap.new( beats.copy, quantized)
	  }{
		  end.isNil.if{ end = this.durs.size - 1 };  // last index, not one past
		  ^this.quantizeRangeInPlace( amount, start, end )
	  }
  }
  quantizeDft{ |amt = 0.78| 
	  //var beats = 0.25!64 warpTo: this;
	  var real;
	  var size = this.quarters.size;
	  //var size = beats.size;
	  var imag = Signal.newClear(size);
	  var complex = Signal.newFrom(this.quarters).dft(imag);
	  var mask = amt * size => _.floor;
	  var filtered = complex.real * Signal.rectWindow(size,mask).postln;
	  var filtered2 = complex.imag * Signal.hammingWindow(size,mask).postln; //why ?
	  complex = Complex(filtered,filtered2);
	  real = complex.real.idft(complex.imag).real; //quarters
	  ^TempoMap(this.beats,this.beats.warpTo(real))

  }
  quantizeRangeInPlace { |amount start end|
	  var quantized = this.quantizeRange(amount,[start,end]);
	  var dursCopy = durs.copy;
	  // iterate the quantized VALUES (loop index 0..size-1). The old
	  // (start..end).do yielded start,start+1,.. as the index, writing at
	  // start+start.. and reading past `quantized` (size end-start+1) —
	  // only correct when start == 0 (quantize-tempomap-project.md §5).
	  quantized.do{|v i|
		  dursCopy.put(start+i,v)
	  };
	  ^TempoMap.new(beats.copy,dursCopy)

  }
  quantizeRange { |amount range| // returns new durs
	  range = range ? [0,durs.size-1];  // last index, not one past
	  range = (range[0]..range[1]);
		  ^durs[range].sum/beats[range].sum * beats[range] * amount 
		  + (durs[range]*(1-amount)) 
  }
  quantizeWindow { |amount=1 window=3|
	        var result = TempoMap(beats.copy,durs.copy);
		result.durs[0..(result.durs.size-window-1)].do{|i x|
			//var chunk = this[x..(x +windowSize)];
			var range = [x,(x + window)];
			var chunk =result.quantizeRange(amount,range);
			chunk.do{|it in|result.durs.put(in+x,it)}
		};

		// durs were mutated in place; rebuild timesInDurs AND env (the old code
		// patched only timesInDurs, leaving env — read by at()/mapBeats — stale).
		result.prRebuild;

		^result;
  }
  bpm {
	 ^ durs.sum / beats.sum => _.reciprocal * 60
  }
  goodBeats {|amount ...args|
	  args = [0] ++ args => _.flat => _.postln;
	  ^(args.size-1 ) 
	  .collect {|i|args[[i,i+1]] - [0,1]}.postln
	  .collect {|i|this.quantizeRange(amount,i)}
	  .flat ++ durs[( args.last..( durs.size-1 ))]
  }
  ++ {|that|
	  ^TempoMap.new(this.beats ++ that.beats, this.durs ++ that.durs)
  }
}
+Array{
	goodBeats { |array|
		^this.reshapeLike(array.differentiate.collect({|i| 1.dup(i)}))
	}
}
