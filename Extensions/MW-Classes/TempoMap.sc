
TempoMap { 
  var <>beats,<>durs;
  var polynomial;
  *new { |beats = #[1,1,1,1,1,1,1] durs = #[1,1,1,1,1,1,1,1]|
    ^super.newCopyArgs(beats ,durs )
  }
  *fromDurs{ | dur | ^TempoMap( 1!dur.list.size,dur.list) }
  *fromB { | b| ^TempoMap( 1!b.size,b) }
  init { |beats durs|

	//var points = [beats,durs].collect{|i| [0] ++ i => _.integrate => _.drop(1)}.flop;
	//var binomials = points.collect{|i| Polynomial.newFrom([ i[0]*(-1), 1 ])};
	//var expandTheOthers = {|element| binomials.reject{|i| i == element}};
	//var polynomials = points.size.collect { |i|
	//	Polynomial.expandBinomialFactors( expandTheOthers.(binomials[i]))
	//};
	//var coefficients = polynomials.collect{|i x| 
	//	i.eval(points[x][0])/points[x][1] => _.reciprocal
	//};
	//polynomial = polynomials * coefficients => _.sum ;
	//storebeats = beats; storedurs = durs;
	beats = beats;durs = durs;
        ^this;
  }

  mapBeatsPoly { | beats |
	beats = beats.integrate;
	^beats.collect{|i| polynomial.eval(i)}.differentiate;
  }
  quarter {
	  ^ durs.sum / beats.sum
  }
   
  interpolateBeat { |beat|
	  var timesInBeats = [ 0 ] ++ beats ++ beats.last => _.integrate;
	  var timesInDurs = [ 0 ] ++ durs ++ durs.last => _.integrate;
	  var prev = timesInBeats.select{|i| i <= beat}.maxIndex;
	  [[ prev, prev + 1 ],[ timesInBeats[prev], timesInBeats[prev + 1] ]].postln;
	  ^beat-timesInBeats[prev] / ( timesInBeats.clipAt(prev + 1) - timesInBeats[prev] ) * ( timesInDurs.clipAt( prev + 1 ) - timesInDurs[prev] ) + timesInDurs[prev]
  }
  interpolateBeatInverse { |beat|
	  //I simply swtched timesInBeats and timesInDurs !!
	  var timesInDurs = [ 0 ] ++ beats ++ beats.last => _.integrate;
	  var timesInBeats = [ 0 ] ++ durs ++ durs.last => _.integrate;
	  var prev = timesInBeats.select{|i| i <= beat}.maxIndex;
	  [[ prev, prev + 1 ],[ timesInBeats[prev], timesInBeats[prev + 1] ]].postln;
	  ^beat-timesInBeats[prev] / ( timesInBeats.clipAt(prev + 1) - timesInBeats[prev] ) * ( timesInDurs.clipAt( prev + 1 ) - timesInDurs[prev] ) + timesInDurs[prev]

  }

  dursToBeats { | array |
	  ^array.integrate.collect{|i| this.interpolateBeatInverse(i)}.differentiate
  }

  mapBeats { | beats |
	  beats.collect{|i| ( i==0 ).if{0.000001}{i}};
	  ^beats.integrate.collect{|i| this.interpolateBeat(i)}.differentiate.select(_.isStrictlyPositive)
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

		^result;
  }
}

