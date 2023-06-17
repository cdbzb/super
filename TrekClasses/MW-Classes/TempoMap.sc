
TempoMap { 
  var <beats,<durs,<timesInBeats,<>timesInDurs;
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
	timesInBeats = [ 0 ] ++ beats ++ beats.last => _.integrate;
	timesInDurs = [ 0 ] ++ durs ++ durs.last => _.integrate;
        ^this;
  }
  beats_{|i| 
	  beats = i;  
	  timesInBeats = [ 0 ] ++ beats ++ beats.last => _.integrate;
  }
  durs_{|i| 
	  durs= i;  
	  timesInDurs = [ 0 ] ++ durs++durs.last => _.integrate;
  }
  mapBeatsPoly { | beats |
	beats = beats.integrate;
	^beats.collect{|i| polynomial.eval(i)}.differentiate;
  }
  quarter {
	  ^ durs.sum / beats.sum
  }
  interpolateBeat { |beat|
	  var prev = timesInBeats.select{|i| i <= beat}.maxIndex;
	  [[ prev, prev + 1 ],[ timesInBeats[prev], timesInBeats[prev + 1] ]].postln;
	  ^beat-timesInBeats[prev] / ( timesInBeats.clipAt(prev + 1) - timesInBeats[prev] ) * ( timesInDurs.clipAt( prev + 1 ) - timesInDurs[prev] ) + timesInDurs[prev]
  }
  interpolateBeatInverse { |beat|
	  //simply swtched timesInBeats and timesInDurs !!
	  var timesInDurz = timesInBeats;
	  var timesInBeatz = timesInDurs;
	  var prev = timesInBeatz.select{|i| i <= beat}.maxIndex;
	  [[ prev, prev + 1 ],[ timesInBeatz[prev], timesInBeatz[prev + 1] ]].postln;
	  ^beat-timesInBeatz[prev] / ( timesInBeatz.clipAt(prev + 1) - timesInBeatz[prev] ) * ( timesInDurz.clipAt( prev + 1 ) - timesInDurz[prev] ) + timesInDurz[prev]

  }
  dursToBeats { | array |
	  ^array.integrate.collect{|i| this.interpolateBeatInverse(i)}.differentiate
  }
  mapBeats { | b |
	  b.collect{|i| 0.000001 max: i};
	  ^b.integrate.collect{|i| this.interpolateBeat(i)}.differentiate.select(_.isStrictlyPositive)
  }
  mapRecordedDurs { | durs |
	  ^this.mapBeats( durs/this.quarters.mean )
	  //^this.mapBeats( durs/durs.sum )
  }
  at { |time|
    ^this.eval(time)
  }
  quarters {
      ^this.mapBeats( 1.dup(beats.sum.floor) )
  }
  quantize { |amount = 1 start end|
	  start.isNil.if {
		  var quantized = durs.sum/beats.sum * beats * amount 
		  + (durs * (1 - amount));
		  ^TempoMap.new( beats.copy, quantized)
	  }{
		  end.isNil.if{ end = this.durs.size };
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
	  (start..end).do{|i|
		  dursCopy.put(start+i,quantized[i])
	  };
	  ^TempoMap.new(beats.copy,dursCopy)

  }
  quantizeRange { |amount range| // returns new durs
	  range = range ? [0,durs.size];
	  range = (range[0]..range[1]);
		  ^durs[range].sum/beats[range].sum * beats[range] * amount 
		  + (durs[range]*(1-amount)) 
  }
  quantizeWindow { |amount=1 window=3|
	        var result = TempoMap(beats.copy,durs.copy);
		(result.durs.size-window).postln;
		result.durs[0..(result.durs.size-window-1)].do{|i x|
			//var chunk = this[x..(x +windowSize)];
			var range = [x,(x + window)];
			var chunk =result.quantizeRange(amount,range);
			chunk.do{|it in|result.durs.put(in+x,it)}
		};

		result.timesInDurs = [ 0 ] ++ result.durs ++ result.durs.last => _.integrate;

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

