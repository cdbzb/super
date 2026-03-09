// Cycle EventType
Event.addEventType(\cyc, {
	Yoeminrak.song[~song].notNil.if
	{
		var song = Yoeminrak.song[~song];
		var section = (~sec ? (song.collect{|i| i.section ? 0 } => {|x| x.maxItem { |item| x.occurrencesOf(item) }})) ? 0;
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
		(~chase ? false).if { Yoeminrak.chaseState(song) };
		(Yoeminrak.env[\silent] ? false).not.if {song.play(start)};
		((Yoeminrak.env[\vid] ? false) and: { (Yoeminrak.env[\silent] ? false).not }).if {
			(~skipVid ? false).not.if {
				var vidNum = ~vid ? 1;
				var vidOffset = vidNum * Yoeminrak.particleVidOffset;
				var vidStart = Yoeminrak.sections[section] + vidOffset + (Yoeminrak.secDur[section] / 20 * start);
				var vidEnd = (~keepPlaying ? false).if { nil } { Yoeminrak.sections[section + (~length ? 0 + 1)] + vidOffset };
				Yoeminrak.playVid(vidNum, start: vidStart, end: vidEnd, audio:(~audio ? false))
			}
		};
		Yoeminrak.env.put(\lastCyc, currentEnvironment)
	}
});

Event.addEventType(\cycs, {
	var skipVidPat = (~keepPlaying ? false).if {
		[false].q ++ Pn(true, inf)
	} { false };
	[type:\cyc, song:~songs.q, start:[~start ? Yoeminrak.env[\cursor] ? 0].q ++ [0].q(inf), skipVid:skipVidPat, keepPlaying:(~keepPlaying ? false), audio:(~audio ? false), fullscreen:(~fullscreen ? false), vid:(~vid ? 1)].pp;
	Yoeminrak.env.put(\lastCyc, currentEnvironment)
});
