Wrapper {
	*new {|contents| ^{contents}}
}

SynthOut : Synth {
	var <>bus;
	*new {|...args|  ^super.new(*args).init }
	*newFrom {|synth| synth.init }
	init {
		bus = Bus.audio();
		this.set(\out,bus.index)
	}

}
+Synth {
	out {^SynthOut.newFrom(this)}
}


/*
SynthOut(\default)
a=SynthOut(\default,[\freq,499])
a=Synth(\default,[\freq,400]).out;
b={SinOsc.ar(\freq.kr(0,0.001)*10000+\base.ar(300),0,0.1)}.play(s,1,addAction:\addToTail)
b.map(\freq,a.bus)
[type:\set,params:#[\freq],id:a.nodeID,freq:Pwhite(100,900)].pp;
b.nodeID
s.plotTree
a.nodeID
a.bus.index
*/

