VelocityRecorder {
	var <>tune,<>durs,<>velocities;
	*new {|tune durs| ^super.newCopyArgs(tune,durs).init }
	init { 
		var currentNote;
		velocities=List.new;
		tune = tune.q.asStream;
		//preview pbind
		MIDIdef.noteOn(\veloRecorder, {|vel num| 
			var nextNote = tune.next;
			velocities.add(vel);
			nextNote.notNil.if {
				currentNote.notNil.if {
						currentNote.release
				}
			};
			nextNote.notNil.if {
				currentNote=Synth(\default,[freq:nextNote,amp:vel/127]);
				vel.asArray.postln;
			}{
				MIDIdef(\veloRecorder).free;
				currentNote.release;
				velocities.asArray.postln;
			}
		})
		//do over?
	}

}
/*
a=VelocityRecorder.new([1,6,5,4,5,4,2,1,-6].df(\c),[1,1,1])
MIDIClient.init;
MIDIIn.connectAll;
a.tune
*/
