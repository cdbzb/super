(
MIDIIn.connectAll;
a = MicroKeys();
a.setSynth(\sawSynth);
a.tuning_(\partch);
b = MIDIItem2(\test);
)

b.record;
b.stop
b.reset
b.play

(
~on = b.notes.select({|e| e.midicmd == \noteOn}).copy;
~off = b.notes.select({|e| e.midicmd == \noteOff}).copy;
~findMatch = {|midinote| ~off.collect{|e| e.midinote}.indexOf(midinote)}; //returns index
~on.do{|e| var match = ~off.removeAt(~findMatch.(e.midinote)).postln; e.sustain = match.timestamp - e.timestamp; };
~on.collect(_.timestamp).differentiate.drop(1) ++ 1 => _.do{|i x|
	~on[x].dur = i
};
~on.q.play
)
~on[0].play
