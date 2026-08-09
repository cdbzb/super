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
  // Public protocol metadata. Domains use the map's relative coordinate frame.
  // `\clamp` documents the legacy Env.at boundary behavior; it is retained for
  // Trek/Songs compatibility rather than recommended for new composed maps.
  beatDomain { ^[0, beats.sum] }
  timeDomain { ^[0, durs.sum] }
  extrapolation { ^\clamp }
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
  dursToBeats { | array, fromTime = 0 |
	  ^this.mapDurs(array, fromTime)
  }
  mapBeats { | b, fromBeat = 0 |
	  ^b.mapSpansFrom(fromBeat, { |beat| this.timeAt(beat) })
  }
  // Naming convention: `beats` are musical spans; `durs` are elapsed seconds.
  // Therefore mapDurs maps second durations -> beat spans (the inverse of
  // mapBeats, which maps beat spans -> second durations).
  mapDurs { |durs, fromTime = 0|
	  ^durs.mapSpansFrom(fromTime, { |t| this.beatAt(t) })
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

// Place any protocol-compatible relative tempo map into an external beat/time
// coordinate frame. `beatOrigin` and `timeOrigin` are the external coordinates
// corresponding to the wrapped map's domain starts. The wrapped map is never
// mutated; placement can itself be wrapped or composed later.
PlacedTempoMap {
  var <map, <beatOrigin, <timeOrigin;

  *new { |map, beatOrigin = 0, timeOrigin = 0|
	  ^super.new.init(map, beatOrigin, timeOrigin)
  }
  init { |aMap, aBeatOrigin, aTimeOrigin|
	  [\timeAt, \beatAt, \mapBeats, \mapDurs, \beatDomain, \timeDomain,
		  \extrapolation].do { |selector|
		  aMap.respondsTo(selector).not.if {
			  Error("PlacedTempoMap: wrapped map does not implement %".format(selector)).throw
		  }
	  };
	  map = aMap;
	  beatOrigin = aBeatOrigin;
	  timeOrigin = aTimeOrigin;
	  ^this
  }
  timeAt { |beat|
	  var bd = map.beatDomain, td = map.timeDomain;
	  ^timeOrigin + (map.timeAt(bd.first + (beat - beatOrigin)) - td.first)
  }
  beatAt { |time|
	  var bd = map.beatDomain, td = map.timeDomain;
	  ^beatOrigin + (map.beatAt(td.first + (time - timeOrigin)) - bd.first)
  }
  mapBeats { |beats, fromBeat|
	  ^beats.mapSpansFrom(fromBeat ? beatOrigin, { |beat| this.timeAt(beat) })
  }
  mapDurs { |durs, fromTime|
	  ^durs.mapSpansFrom(fromTime ? timeOrigin, { |t| this.beatAt(t) })
  }
  // Legacy protocol alias — TempoMap and MIDIItemTempoMap both answer it, so a
  // placed map must too or old callers get doesNotUnderstand.
  dursToBeats { |durs, fromTime|
	  ^this.mapDurs(durs, fromTime)
  }
  beatDomain {
	  var d = map.beatDomain;
	  ^[beatOrigin, beatOrigin + (d.last - d.first)]
  }
  timeDomain {
	  var d = map.timeDomain;
	  ^[timeOrigin, timeOrigin + (d.last - d.first)]
  }
  extrapolation { ^map.extrapolation }
}

// A directional time->time transform between two tempo maps which share the
// same beat coordinate system. Placement is deliberately NOT inferred: place
// either side first with PlacedTempoMap when their beat origins differ.
TempoWarp {
  var <sourceMap, <targetMap;

  *new { |sourceMap, targetMap|
	  ^super.new.init(sourceMap, targetMap)
  }
  init { |source, target|
	  [source, target].do { |map|
		  [\timeAt, \beatAt, \beatDomain, \timeDomain, \extrapolation].do { |selector|
			  map.respondsTo(selector).not.if {
				  Error("TempoWarp: map does not implement %".format(selector)).throw
			  }
		  }
	  };
	  sourceMap = source;
	  targetMap = target;
	  ^this
  }
  // Source seconds -> shared beat coordinate -> target seconds.
  mapTime { |sourceTime|
	  ^targetMap.timeAt(sourceMap.beatAt(sourceTime))
  }
  // Target seconds -> shared beat coordinate -> source seconds.
  unmapTime { |targetTime|
	  ^sourceMap.timeAt(targetMap.beatAt(targetTime))
  }
  // Both inputs and outputs are `durs` (elapsed seconds), but in different
  // media clocks. Deliberately NOT named mapDurs: on every tempo map that
  // selector returns beat spans, while a warp's output stays in seconds.
  // Origins are required for position-dependent tempo changes.
  warpDurs { |sourceDurs, fromTime|
	  ^sourceDurs.mapSpansFrom(fromTime ? sourceMap.timeDomain.first,
		  { |t| this.mapTime(t) })
  }
  unwarpDurs { |targetDurs, fromTime|
	  ^targetDurs.mapSpansFrom(fromTime ? targetMap.timeDomain.first,
		  { |t| this.unmapTime(t) })
  }
  sourceTimeDomain { ^sourceMap.timeDomain }
  targetTimeDomain { ^targetMap.timeDomain }
  mappedTimeDomain {
	  var d = sourceMap.timeDomain;
	  ^[this.mapTime(d.first), this.mapTime(d.last)]
  }
  sharedBeatDomain {
	  var a = sourceMap.beatDomain, b = targetMap.beatDomain;
	  var lo = a.first max: b.first, hi = a.last min: b.last;
	  ^(hi >= lo).if { [lo, hi] } { nil }
  }
  extrapolation {
	  ^[sourceMap.extrapolation, targetMap.extrapolation]
  }
}

+Array{
	goodBeats { |array|
		^this.reshapeLike(array.differentiate.collect({|i| 1.dup(i)}))
	}
}

// mapSpansFrom (the shared span-mapping helper) lives in plusArray.sc alongside
// the other SequenceableCollection extensions — MonoMap and Groove use it too.
