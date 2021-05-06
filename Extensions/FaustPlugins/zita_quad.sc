ZitaQuad : MultiOutUGen
{
  *ar { | in1, in2, in3, in4, in5, in6, in7, in8, low_rt60(3.0), lf_x(200.0), mid_rt60(2.0), hf_damping(6000.0) |
      ^this.multiNew('audio', in1, in2, in3, in4, in5, in6, in7, in8, low_rt60, lf_x, mid_rt60, hf_damping)
  }

  *kr { | in1, in2, in3, in4, in5, in6, in7, in8, low_rt60(3.0), lf_x(200.0), mid_rt60(2.0), hf_damping(6000.0) |
      ^this.multiNew('control', in1, in2, in3, in4, in5, in6, in7, in8, low_rt60, lf_x, mid_rt60, hf_damping)
  } 

  checkInputs {
    if (rate == 'audio', {
      8.do({|i|
        if (inputs.at(i).rate != 'audio', {
          ^(" input at index " + i + "(" + inputs.at(i) + 
            ") is not audio rate");
        });
      });
    });
    ^this.checkValidInputs
  }

  init { | ... theInputs |
      inputs = theInputs
      ^this.initOutputs(8, rate)
  }

  name { ^"ZitaQuad" }


  info { ^"Generated with Faust" }
}

