Wah4 : UGen
{
  *ar { | in1, amp(0.1), cutoff(500.0) |
      ^this.multiNew('audio', in1, amp, cutoff)
  }

  *kr { | in1, amp(0.1), cutoff(500.0) |
      ^this.multiNew('control', in1, amp, cutoff)
  } 

  checkInputs {
    if (rate == 'audio', {
      1.do({|i|
        if (inputs.at(i).rate != 'audio', {
          ^(" input at index " + i + "(" + inputs.at(i) + 
            ") is not audio rate");
        });
      });
    });
    ^this.checkValidInputs
  }

  name { ^"Wah4" }


  info { ^"Generated with Faust" }
}

