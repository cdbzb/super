XTouch {
	*initClass {
		fork{ 	MIDIClient.init;
			MIDIIn.connectAll;
			MIDIFunc.noteOn({ |vel num| 
				Server.default.freeMyDefaultGroup;
				TempoClock.all.do(_.clear);
			},93,
			srcID:1779843049
		); 
			MIDIFunc.noteOn({ 
				Song.play
			},94,
			srcID:1779843049
		);
			MIDIFunc.noteOn({ |vel num| 
				Part.play;
			},47
			,srcID:1779843049
		); 
			StageLimiter.activate;
		}
	}
	*new {
		^super.new.init()
	}
	init {
		111.postln;
		MIDIFunc.noteOn({ |vel num| vel.postln; num.postln;}
	)

	}
}


