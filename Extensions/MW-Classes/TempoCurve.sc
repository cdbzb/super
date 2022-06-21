
TempoMap { 
  var <storebeats,<storedurs;
  var polynomial;
  *new { |beats durs|
    ^super.new.init(beats,durs)
  }
  init { |beats durs|

	var points = [beats,durs].collect{|i| [0] ++ i => _.integrate => _.drop(1)}.flop;
	var binomials = points.collect{|i| Polynomial.newFrom([ i[0]*(-1), 1 ])};
	var expandTheOthers = {|element| binomials.reject{|i| i == element}};
	var polynomials = points.size.collect { |i|
		Polynomial.expandBinomialFactors( expandTheOthers.(binomials[i]))
	};
	var coefficients = polynomials.collect{|i x| 
		i.eval(points[x][0])/points[x][1] => _.reciprocal
	};
	polynomial = polynomials * coefficients => _.sum ;
	storebeats = beats; storedurs = durs;
        ^this;
  }

  mapBeatsPoly { | beats |
	beats = beats.integrate;
	^beats.collect{|i| polynomial.eval(i)}.differentiate;
  }
  quarter {
	  ^ storedurs.sum / storebeats.sum
  }
   
  interpolateBeat { |beat|
	  var timesInBeats = [ 0 ] ++ storebeats ++ storebeats.last => _.integrate;
	  var timesInDurs = [ 0 ] ++ storedurs ++ storedurs.last => _.integrate;
	  var prev = timesInBeats.select{|i| i <= beat}.maxIndex;
	  [[ prev, prev + 1 ],[ timesInBeats[prev], timesInBeats[prev + 1] ]].postln;
	  ^beat-timesInBeats[prev] / ( timesInBeats.clipAt(prev + 1) - timesInBeats[prev] ) * ( timesInDurs.clipAt( prev + 1 ) - timesInDurs[prev] ) + timesInDurs[prev]
  }

  mapBeats { | beats |
	  ^beats.integrate.collect{|i| this.interpolateBeat(i)}.differentiate
  }

  mapRecordedDurs { | durs |
	  ^this.mapBeats( durs/this.quarters )
  }

  at { |time|
    ^this.eval(time)
  }
  quarters {
      ^this.mapBeats( 1.dup(storedurs.sum.floor) )
  }
  quantize { |amount = 1|
var quantized = storedurs.sum/storebeats.sum * storebeats * amount 
		+ (storedurs * (1 - amount));
	  ^TempoMap.new( storebeats, quantized)
  }
}

