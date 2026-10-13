+ Integer {
	f { |frames=0| ^(this + (frames/24))  }


        //flat { 
        //  ^this - 0.5
        //}


        sharp { 
          ^this + 0.5
        }
        seconds {
          ^this.asFloat.seconds
        }

}

+Float {
  seconds {
    var minutes = this / 100 => _.floor;
    var seconds = this % 100;
    ^(minutes * 60 + seconds)
  }
}

+ Number { sum{^this} }
/*
301f:20
*/

+ Magnitude {
	/* interval test; bounds: '[]' '[)' '(]' '()' — default '[)' (half-open, suits time windows) */
	isBetween { |lo, hi, bounds = '[)'|
		^switch(bounds,
			'[)', { (lo <= this) and: { this < hi } },
			'[]', { (lo <= this) and: { this <= hi } },
			'(]', { (lo < this) and: { this <= hi } },
			'()', { (lo < this) and: { this < hi } },
			{ Error("isBetween: bounds must be one of '[]' '[)' '(]' '()', got %".format(bounds.cs)).throw }
		)
	}
}
