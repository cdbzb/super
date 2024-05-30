( //setup
~sequence = List.new;
~midinotes = (..144);
~notesInProgress = Order.new(144);

MIDIFunc.noteOn({|vel num|  ~notesInProgress.put(num, (num:num, vel: vel, start: SystemClock.seconds)) });
MIDIFunc.noteOff({|vel num|  ~sequence.add( ~notesInProgress.at(num) ++ (dur: SystemClock.seconds - ~notesInProgress.at(num).start)); ~notesInProgress.removeAt(num) });

MIDIFunc.noteOff({|vel num| [vel, num].postln})
)

PF();
//test
~sequence.do{|e| SystemClock.sched(e.start - ~sequence[0].start, { (midinote:e.num, amp: e.vel/128/10, dur:e.dur ).play })};

(
~sorted = ~sequence.sort{|e f| e.start < f.start};
~extractTune = { |tune = ("3 1 1 -7".dm(\g, 4))| //array
	var counter=0;
	var result = List.new;
	//extract the tune
	tune.do{|i| var el = ~sorted[counter..].select{|e| e.num == i}[0]; result.add(el ++ (counter: counter)); counter = ~sorted.indexOf(el) + 1};
	result;
};
a = ~extractTune.( "3 2 3 4 3".dm(\c, 5) );
~flop = {|array|
	(
		dur: array.collect{|i| i.start}.differentiate.drop(1) ++ array.last.dur,
		amp: array.collect{|i| i.vel},
		midinote: array.collect{|i| i.num}
	)
};
~pbind = {|event|
	[
		dur: event.dur.q,
		amp: event.amp.q / 128 / 10,
		midinote: event.midinote.q
	].p
};
a => ~flop.(_) => ~pbind.(_) => _.play;
~pbindD = {|e|
	"
	[\n
		dur: %.q,\n
		amp: %.q,\n
		midinote: %.q,\n
	].p
	".format(e.dur.round(0.001), e.amp, e.midinote)
};
~pbindD.(~flop.(a))


)

// inspect sequence
~sorted.do(_.postln);

//play sequence
a.do{|e| SystemClock.sched(e.start - ~sequence[0].start, { (midinote:e.num, amp: e.vel/128/10, dur:e.dur ).play })};


(
Song(\trashme,[]).current;
// ~durs.round(0.001).registerD
[ "all around me", "5 4 4 3 1 2".dm(\g), [1.212, 0.468, 0.519, 0.468, 0.426, 0.514] ].addLine;
Song.setTempoMap(\around,"eee e e e e e");
P.tune(_ <> [ amp: [45, 32, 43, 42, 39, 41] .q / [350, 128], instrument: [\harp, \default]].p);
P(\bass, music: { |p b e|
	[
		freq: [1, 3, 4, 6].df(\g, 3).q,
		instrument: \sawSynthSustain,
		dur: "q q q q".asBeats.warpTo( e.tempoMap ).q
	].ppm
});
[ "I see sunlight", "3 1 1 -7".dm(\g), [1.204, 0.51, 0.895, 0.95] ].addLine;
Song.setTempoMap(\sunl,"eee e ee ee");
P.tune( _ <> [ amp: [35, 30, 27, 26].q / [350, 128], instrument: [\harp, \default]  ].p );
P(\bass, music: { |p b e|
	[
		freq: [-5, 3, -6].df(\g, 3).q,
		instrument: \sawSynthSustain,
		dur: "q q q ".asBeats.warpTo( e.tempoMap ).q
	].ppm
});
)
