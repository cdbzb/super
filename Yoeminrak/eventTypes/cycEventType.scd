// Cycle EventType
Event.addEventType(\cyc, {
	var song = Yoeminrak.song[~song];
	var section = ~sec ? song.collect{|i| i.section ? 0 } => {|x| x.maxItem { |item| x.occurrencesOf(item) }};
	var start = ~start ? Yoeminrak.env[\cursor] ? 0;
	
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
	
	~dur = Yoeminrak.secDur[section] / 20 * (20 - (start));
	(Yoeminrak.env[\silent] ? false).not.if {song.play(start)};
	(Yoeminrak.env[\vid] ? false).if {
		var vidNum = ~vid ? 1;
		var vidOffset = vidNum * Yoeminrak.particleVidOffset;
		var vidStart = Yoeminrak.sections[section] + vidOffset + (Yoeminrak.secDur[section] / 20 * start);
		var vidEnd = (~playTilEnd ? false).if { nil } { Yoeminrak.sections[section + (~length ? 0 + 1)] + vidOffset };
		Yoeminrak.playVid(vidNum, start: vidStart, end: vidEnd)
	};
	Yoeminrak.env.put(\lastCyc, currentEnvironment)
});

Event.addEventType(\cycs, {
	// var song = Yoeminrak.song[~song];
	
	[type:\cyc, song:~songs.q, start:[~start].q ++ [0].q(inf), section:~sections.q].pp;
	// (Yoeminrak.env[\silent] ? false).not.if {song.play(~start ? 0)};
	Yoeminrak.env.put(\lastCyc, currentEnvironment)
});
