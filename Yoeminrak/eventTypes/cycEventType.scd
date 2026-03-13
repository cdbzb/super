// Cycle EventType
Event.addEventType(\cyc, {
	Yoeminrak.songAt(~song).notNil.if
	{
		var song = Yoeminrak.songAt(~song);
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

		~dur = Yoeminrak.secDur.wrapAt(section) / 20 * (20 - (start));
		(~chase ? false).if { Yoeminrak.chaseState(song) };

		// Launch video paused first, then start music + unpause together
		((Yoeminrak.env[\vid] ? false) and: { (Yoeminrak.env[\silent] ? false).not }).if {
			(~skipVid ? false).not.if {
				var vidNum = ~vid ? 1;
				var vidOffset = vidNum * Yoeminrak.particleVidOffset;
				var vidStart = {
					var marks = JSONlib.parseFile("/Users/michael/tank/Hyojin/Video Sync/frame_marks.json");
					var markIdx = (section * 20) + start + 1;
					(marks[markIdx.asSymbol][\frame] / 29.97) + vidOffset
				}.try ? (Yoeminrak.sections.wrapAt(section) + vidOffset + (Yoeminrak.secDur.wrapAt(section) / 20 * start));
				var vidLag = ~vidLag ? 1;
				var vidEnd = (~keepPlaying ? false).if { nil } { Yoeminrak.sections.wrapAt(section + (~length ? 0 + 1)) + vidOffset };
				~dur = ~dur + vidLag;
				Yoeminrak.playVid(vidNum, start: vidStart, end: vidEnd, audio:(~audio ? false), paused: true);
				fork {
					vidLag.wait;
					(Yoeminrak.env[\silent] ? false).not.if { song.play(start, lag:~lag) };
					MPV.unpause;
				}
			} {
				// skipVid but vid enabled (e.g. keepPlaying continuation) — play music without launching new video
				(Yoeminrak.env[\silent] ? false).not.if { song.play(start, lag:~lag) };
			}
		} {
			(Yoeminrak.env[\silent] ? false).not.if { song.play(start, lag:~lag) };
		};
		Yoeminrak.env.put(\lastCyc, currentEnvironment)
	}
});

Event.addEventType(\cycs, {
	var skipVidPat = (~keepPlaying ? false).if {
		[false].q ++ Pn(true, inf)
	} { false };
	[
		type:\cyc,
		song:~songs.q,
		start:[~start ? Yoeminrak.env[\cursor] ? 0].q ++ [0].q(inf),
		skipVid:skipVidPat,
		keepPlaying:(~keepPlaying ? false),
		audio:(~audio ? false),
		fullscreen:(~fullscreen ? false),
		vid:(~vid ? 1),
		lag: ~lag ? 0
	].pp;
	Yoeminrak.env.put(\lastCyc, currentEnvironment)
});
