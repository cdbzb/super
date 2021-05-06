VocalFOF : MultiOutUGen
{
  *ar { | freq(440.0), gain(0.9), voicetype(0.0), vowel(0.0), vibratofreq(6.0), vibratogain(0.5) |
      ^this.multiNew('audio', freq, gain, voicetype, vowel, vibratofreq, vibratogain)
  }

  *kr { | freq(440.0), gain(0.9), voicetype(0.0), vowel(0.0), vibratofreq(6.0), vibratogain(0.5) |
      ^this.multiNew('control', freq, gain, voicetype, vowel, vibratofreq, vibratogain)
  } 

  init { | ... theInputs |
      inputs = theInputs
      ^this.initOutputs(2, rate)
  }

  name { ^"VocalFOF" }


  info { ^"Generated with Faust" }
}

