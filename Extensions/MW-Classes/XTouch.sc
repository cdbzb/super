XTouch {
	*initClass {
		fork{ 	MIDIClient.init;
			MIDIIn.connectAll;
			MIDIFunc.noteOn({ |vel num| 
				Item.stop;
				Server.default.freeMyDefaultGroup;
				TempoClock.all.do(_.clear);
				Pipe.new("pressf1.sh","w");

			},93,
			srcID:1779843049
		); 
			MIDIFunc.noteOn({ 
				defer{Window.closeAll}
			},51,
			srcID:1779843049
		);
			MIDIFunc.noteOn({ 
				defer{Server.default.meter};
			},63,
			srcID:1779843049
		);
			MIDIFunc.noteOn({ 
				defer{Server.default.plotTreeL};
			},62,
			srcID:1779843049
		);
			MIDIFunc.noteOn({ 
				Item.arm;
			},95,
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


