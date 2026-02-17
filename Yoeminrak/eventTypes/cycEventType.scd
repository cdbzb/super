// Cycle EventType
Event.addEventType(\cyc, {
	var song = Yoeminrak.song[~song];
	var section = ~sec ? song.collect{|i| i.section ? 0 } => {|x| x.maxItem { |item| x.occurrencesOf(item) }};
	
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
	
	~dur = Yoeminrak.secDur[section] / 20 * (20 - ( ~start ? 0 ));
	(Yoeminrak.env[\silent] ? false).not.if {song.play(~start ? 0)};
	Yoeminrak.env.put(\lastCyc, currentEnvironment)
});

Event.addEventType(\cycs, {
	// var song = Yoeminrak.song[~song];
	
	[type:\cyc, song:~songs.q, start:[~start].q ++ [0].q(inf), section:~sections.q].pp;
	// (Yoeminrak.env[\silent] ? false).not.if {song.play(~start ? 0)};
	Yoeminrak.env.put(\lastCyc, currentEnvironment)
});
