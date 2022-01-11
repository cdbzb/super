a = "../Cheng/arirang/*.wav".standardizePath.pathMatch
b=a.collect{|i x| Buffer.read(s,i)}
b.size
~playOne = {var buf = b.choose; {PlayBuf.ar(buf.numChannels,buf.bufnum)}.play};
~playOne.()
