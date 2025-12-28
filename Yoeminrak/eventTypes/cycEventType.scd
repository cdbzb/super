// Cycle EventType
Event.addEventType(\cyc, {
	var song = Yoeminrak.song[~song];
	
	// Apply solo filtering if solo is specified
	~solo.notNil.if {
		song = song.select { |event|
			var eventTypeStr = event.type.asString;
			~solo.asArray.any { |soloItem|
				eventTypeStr.contains(soloItem.asString)
			}
		}
	};
	
	// Apply mute filtering if mute is specified
	~mute.notNil.if {
		song = song.reject { |event|
			var eventTypeStr = event.type.asString;
			~mute.asArray.any { |muteItem|
				eventTypeStr.contains(muteItem.asString)
			}
		}
	};
	
	~dur = Yoeminrak.secDur[~sec ? 0] / 20 * (20 - ~start);
	song.play(~start ? 0);
	Yoeminrak.env.put(\lastCyc, currentEnvironment)
});
