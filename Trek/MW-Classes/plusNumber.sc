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
