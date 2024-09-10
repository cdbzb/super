(
~synths = (0..128);
~notes = List.new;
~partialNotes = (0..128);
MIDIdef.new(key:\keyStage, func:{|v n c s| 
	~synths.put(n, Synth(\stringyy, [\amp,v/128, \freq, n.midicps]));
	~partialNotes.put(n, (midinote: n, amp: v/128, start: SystemClock.seconds ));
}, msgNum:nil, chan:nil, msgType:\noteOn, srcID:KeyStage.id, argTemplate:nil, dispatcher:nil);
MIDIdef.new(key:\keyStageOff, func:{|v n c s|
	n.postln;
	~synths[n].postln;
	~synths[66];
	~synths[n].release;
	~partialNotes[n].dur = SystemClock.seconds - ~partialNotes[n].start;
	~notes.add(~partialNotes[n]);
	~partialNotes[n] = nil;
}, msgNum:nil, chan:nil, msgType:\noteOff, srcID:nil, argTemplate:nil, dispatcher:nil);
~notes.do(_.postln)

)
MIDIClient.init
(
~notes = ~notes.sort({|i j| i.start < j.start});
~notes.do({|i x| 
	var delta = ~notes.clipAt(x+1).start - i.start;
	(delta == 0).not.if {i.legato = i.dur/delta; i.dur = delta}{i.legato = 1};
});
~notes.q.play
)
a = [\midinote, \dur, \legato].collect{|key| [key, ~notes.collect(_.at(key)).q]}.flatten
(
~insertPbind = {|array| 
	array = array.clump(2); 
	Nvim.insert("[");
	array.do{|pair| " %: %.q, ".format(pair[0], pair[1].list.asArray.round(0.01)) => Nvim.insert(_)};
	Nvim.insert("]");
}
	)
~insertPbind.(a) 

[
 freq: [329.63, 196.0, 130.81, 220.0, 349.23, 174.61, 293.66, 196.0, 392.0, 246.94, 440.0, 261.63, 220.0, 246.94, 493.88, 293.66, 392.0, 261.63, 523.25, 329.63].q, 
 dur: [0.02, 0.02, 1.05, 0.0, 0.02, 0.58, 0.66, 0.01, 0.02, 3.75, 0.07, 0.02, 1.06, 0.03, 0.01, 0.6, 0.68, 0.04, 0.02, 0.91].q, 
 legato: [50.3, 47.84, 0.89, 1092.85, 35.61, 1.62, 1.03, 96.45, 62.42, 0.33, 16.74, 71.49, 0.67, 35.43, 98.06, 2.15, 2.08, 21.54, 41.51, 1.0].q, 
].pp
[
 midinote: [76.0, 67.0, 60.0, 77.0, 65.0, 69.0, 74.0, 67.0, 72.0, 71.0, 55.0, 83.0, 84.0, 57.0, 81.0, 59.0, 86.0].q, 
 dur: [0.01, 0.02, 1.12, 0.01, 0.01, 0.55, 0.58, 0.02, 1.35, 1.52, 0.02, 1.27, 0.03, 0.65, 0.71, 0.0, 1.22].q, 
 legato: [121.15, 44.35, 0.78, 40.1, 117.19, 2.03, 1.03, 117.47, 1.05, 0.35, 73.98, 1.01, 20.76, 1.99, 1.05, 372.79, 1.0].q, 
].pp
( // clump chords together
var res = List.new;
var counter = 0;
var deltas = 
~notes.collect{|i| i.start}.differentiate.drop(1)++~notes.last.dur;

while {counter < (~notes.size )}

{
	var clump = List.new;
	if ( deltas[counter] < 0.1) {
		clump.add(~notes[counter]);
		while {deltas[counter] < 0.1} {
			clump.add(~notes[counter + 1]);
			counter = counter + 1
		};
		res.add(clump.asArray.q);
		counter = counter + 1
	}{
		res.add(~notes[counter].bubble.q);
		counter = counter + 1
	}
};
r = res
)
~notes.q.play
r.q.play;
