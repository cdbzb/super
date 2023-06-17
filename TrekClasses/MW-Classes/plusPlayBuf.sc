+ PlayBuf { 
	*auto {	arg numChannels, bufnum=0, rate=1.0, trigger=1.0, startPos=0.0, loop = 0.0, doneAction=0;
		

		^this.multiNew('audio', numChannels, bufnum, rate * BufRateScale.new(bufnum), trigger, startPos, loop, doneAction)
}
}
