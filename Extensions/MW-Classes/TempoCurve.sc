
TempoMap { 
  var <storebeats,<storedurs;
  var polynomial;
  *new { |beats = #[1,1,1,1,1,1,1] durs = #[1,1,1,1,1,1,1,1]|
    ^super.new.init(beats ,durs )
  }
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
  interpolateBeatInverse { |beat|
	  //I simply swtched timesInBeats and timesInDurs !!
	  var timesInDurs = [ 0 ] ++ storebeats ++ storebeats.last => _.integrate;
	  var timesInBeats = [ 0 ] ++ storedurs ++ storedurs.last => _.integrate;
	  var prev = timesInBeats.select{|i| i <= beat}.maxIndex;
	  [[ prev, prev + 1 ],[ timesInBeats[prev], timesInBeats[prev + 1] ]].postln;
	  ^beat-timesInBeats[prev] / ( timesInBeats.clipAt(prev + 1) - timesInBeats[prev] ) * ( timesInDurs.clipAt( prev + 1 ) - timesInDurs[prev] ) + timesInDurs[prev]

  }

  dursToBeats { | array |
	  ^array.integrate.collect{|i| this.interpolateBeatInverse(i)}.differentiate
  }

  mapBeats { | beats |
	  ^beats.integrate.collect{|i| this.interpolateBeat(i)}.differentiate
  }

  mapRecordedDurs { | durs |
	  ^this.mapBeats( durs/this.quarters.mean )
	  //^this.mapBeats( durs/storedurs.sum )
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
  quantizeRange { | amount start end|
	  var sections = [(0..(start-1)),(start..end),(end+1..128)];
	  var newStoredurs = storedurs[sections[0]]
	  ++ (
		  storedurs[sections[1]].sum/storebeats[sections[1]].sum * storebeats[sections[1]] * amount 
		  + (storedurs[sections[1]]*(1-amount)) 
	  )
	  ++ storedurs[sections[2]]
	  => _.select(_.notNil)
	  ;
	  ^TempoMap(storebeats,newStoredurs)
	  
  }
  quantizeWindow { |amount=1 window=3|
	  var new = this.quarters.quantizeWindow(amount, window);
	  new = storebeats.warpTo(new );
	  ^TempoMap(storebeats,new)
	  
  }
}

