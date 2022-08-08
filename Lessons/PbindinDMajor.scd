//start the audio bus
a = Bus.audio(s,2);

(
SynthDef(\filter,{
	var sig = In.ar(\bus.kr(a),2);
	sig = BPF.ar(sig,280, 2.0);
	sig = FreeVerb.ar(sig, 0.5,0.2,0.5);
	Out.ar(0,sig);
}).add;
)


//load the looping program
(
~runProg = {
var octave = 2; //start on the second octave
var noteArray = List.new; //create the array where notes will be stored
var noteSel, leadNotes, runNotes, durations, hDurations, finalNotes; //initialize all other variables

~noteD = (2,14..122); //create an array containing all midi numbers associated with each note in the D maj scale
~noteE = (4,16..124);
~noteFs = (6,18..126);
~noteG = (7,19..127);
~noteA = (9,21..117);
~noteB = (11,23..119);
~noteCs = (1,13..121);

octave = 4; // set the octave to 4

noteArray = [~noteD,~noteE,~noteFs,~noteG,~noteA,~noteB,~noteCs]; //build the note array containing all possible midi values

noteSel = Pbrown(0,6,2,20).asStream.nextN(8); // Use Brownian Motion to determine random numbers to choose notes

leadNotes = noteSel.collect({ //collect all chosen notes into an array and build them into chords
	arg num, i;
	[[0,3,5],[0,2,4]].choose.collect({arg cstep;
		num+cstep;
	});
});

leadNotes.postln; //post all chosen chords to the window

finalNotes = leadNotes.collect({arg notes, i; //turn chords into midivalues based on the D maj scale
	notes.collect({arg num;
		var step;
		if(num>5){
			step = 1
		}{
			step = 0
		};
		noteArray.wrapAt(num).at(octave+step);
	});

});

finalNotes.postln; // post the midivalues to the window

runNotes = leadNotes.collect({ // create an array of the melodic notes that contend with the chords
	arg group, i;
	var wiggle, jump, silent, chosen, migrate, step;
	wiggle = [0,1,0,1,0]; //move note up and down a half tone
	migrate = [0,2,3]; //move up a whole tone and then a half
	step = [0,2,2]; //move up a whole tone and then repeat it
	jump = [4]; //jump up an octave
	silent = [0]; //play a member of the chord
	chosen = [wiggle, jump, silent, migrate, step].choose; //randomly choose between any of the previous actions
	(group[2]+chosen).collect({ //put the chosen action into midinotes and store it
		arg num, i;
		var step;
		if(num>5){
			if(num>12){
				step = 2
			}
			{step = 1}
		}{
			step = 0
		};
		noteArray.wrapAt(num).at(octave+step)
	});
});
runNotes.postln; //post the chosen notes for the melody
durations = 8.collect({[3,2,1,1/2].choose}); //create a random series of note lengths that are either 3, 2, 1, 1/2 second long
hDurations = durations.collect({arg dur, i; //create a series of durations that are divisions of the longer durations
	runNotes[i].collect({
		dur/runNotes[i].size;
	})
});

runNotes = runNotes.flatten; //make the arrays of notes and durations readable to a sequence
hDurations = hDurations.flatten;
durations.postln; //inspect durations and notes arrays
hDurations.postln;
runNotes.postln;
//run the synths
defer{
	w.fade(3);
	w = Window(nil,Rect(0,0,300,300),border:false).front.alwaysOnTop_(true);
	t = StaticText(w,w.bounds)
		.font_(Font(\helvetica,90,bold:true))
	;
};
Ppar([
	Pbind(
		\instrument, \default,
		\freq, Pseq(runNotes,2).midicps, //repeat each segment 2 times
		\dur, Pseq(hDurations,2),
		\amp, 0.1,
		\out, a
	),
	Pbind(
		\instrument, \default,
//		\freq, Pseq(finalNotes, 2).midicps, //repeat 2 times
		\midinote, Pseq(finalNotes, 2), //repeat 2 times
		\index, Pseries(),
		\display, Pfunc({|e| defer{t.string= e.midinote}}),

		\dur, Pseq(durations,2),
		\out, a
	)
]).play; //play all of the chosen notes and durations in a stream
durations; //return the length of this segment
};
//x.free;
)

//start the synth filter
(
x = Synth(\filter);
fork{ //run a segment, wait the length of the segment and then run another one.
	10.do{
		var dur = ~runProg.();
		var tot = 0;
		dur.postln;
		dur.do({arg num;
			tot = tot + num;
		});
		tot.postln;
		(2*tot).wait;
	};
}
)

(
x.free //free the filter
)






