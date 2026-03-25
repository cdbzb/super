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
				var eventInstrStr = event.instrument !? _.asString;
				~solo.asArray.any { |soloItem|
					var s = soloItem.asString;
					eventTypeStr.contains(s)
					or: { eventInstrStr.notNil and: { eventInstrStr.contains(s) } }
				}
			}
		};

		// Apply mute filtering if mute is specified
		~mute.notNil.if {
			song = song.reject { |event|
				var eventTypeStr = event.type.asString;
				var eventInstrStr = event.instrument !? _.asString;
				~mute.asArray.any { |muteItem|
					var s = muteItem.asString;
					eventTypeStr.contains(s)
					or: { eventInstrStr.notNil and: { eventInstrStr.contains(s) } }
				}
			}
		};

		// Strip tempo events at playback time (steady tempo)
		(~steadyTempo ? false).if {
			song = song.reject { |event| event.newType == \yoeRest }
		};

		// Mute string sound but keep events for state (chord, etc.)
		(~muteStrings ? false).if {
			song = song.collect { |event|
				(event.type == \yoeString3 or: { event.newType == \yoeString3 }).if {
					event.copy.put(\amp, 0)
				} { event }
			}
		};

		// Attenuate fractional beats (emphasizeBeats: 1 = silent, 0.5 = half amp)
		~emphasizeBeats.notNil.if {
			var amt = ~emphasizeBeats.clip(0, 1);
			song = song.collect { |event|
				((event.beat ? 0) % 1 > 0.05).if {
					event.copy.put(\amp, (event.amp ? 0.1) * (1 - amt))
				} { event }
			}
		};

		// Add claves on beats: true = missing only, \all = every beat
		~addBeats.notNil.if {
			var coveredBeats = (~addBeats == \all).if { Set[] } {
				song.reject { |e| e.newType == \yoeRest }.collect { |e| (e.beat ? 0).round.asInteger }.as(Set)
			};
			20.do { |beat|
				coveredBeats.includes(beat).not.if {
					song = song.add((beat: beat, section: section, type: \note, instrument: \claves_808, amp: (~claveVol ? 0.5), latency: 0.1))
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
					var markIdx = (section * 20) + start + 1;
					(Yoeminrak.markFrame(markIdx) / 29.97) + vidOffset
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
	(Yoeminrak.env[\silent] ? false).not.if {
		var skipVidPat, songs, start, keepPlaying, audio, fullscreen, vid, lag;
		var solo, mute, muteStrings, steadyTempo, emphasizeBeats, addBeats, claveVol, record, recordPath, recordTail, pbindArray, playFunc;
		skipVidPat = (~keepPlaying ? false).if {
			[false].q ++ Pn(true, inf)
		} { false };
		songs = ~songs;
		start = ~start;
		keepPlaying = ~keepPlaying ? false;
		audio = ~audio ? false;
		fullscreen = ~fullscreen ? false;
		vid = ~vid ? 1;
		lag = ~lag ? 0;
		solo = ~solo;
		mute = ~mute;
		emphasizeBeats = ~emphasizeBeats;
		addBeats = ~addBeats;
		claveVol = ~claveVol;
		muteStrings = ~muteStrings;
		steadyTempo = ~steadyTempo;
		record = ~record ? false;
		recordPath = ~recordPath ? "/tmp/yoeminrak_guide.wav";
		recordTail = ~recordTail ? 5;

		pbindArray = [
			type:\cyc, song:songs.q,
			start:[start ? Yoeminrak.env[\cursor] ? 0].q ++ [0].q(inf),
			skipVid:skipVidPat, keepPlaying:keepPlaying,
			audio:audio, fullscreen:fullscreen, vid:vid, lag:lag
		];
		solo.notNil.if { pbindArray = pbindArray ++ [solo:solo] };
		mute.notNil.if { pbindArray = pbindArray ++ [mute:mute] };
		emphasizeBeats.notNil.if { pbindArray = pbindArray ++ [emphasizeBeats:emphasizeBeats] };
		addBeats.notNil.if { pbindArray = pbindArray ++ [addBeats:addBeats] };
		claveVol.notNil.if { pbindArray = pbindArray ++ [claveVol:claveVol] };
		muteStrings.notNil.if { pbindArray = pbindArray ++ [muteStrings:muteStrings] };
		steadyTempo.notNil.if { pbindArray = pbindArray ++ [steadyTempo:steadyTempo] };
		playFunc = { pbindArray.pp };

		record.if {
			var totalDur = songs.sum { |s|
				var sg = Yoeminrak.songAt(s);
				var sec = (sg.collect{|i| i.section ? 0 } => {|x| x.maxItem { |item| x.occurrencesOf(item) }}) ? 0;
				Yoeminrak.secDur.wrapAt(sec)
			};
			Server.default.prepareForRecord(recordPath);
			fork {
				Server.default.sync;
				"Recording to: %".format(recordPath).postln;
				Server.default.record;
				playFunc.value;
				(totalDur + recordTail).wait;
				Server.default.stopRecording;
				"Recording complete: %".format(recordPath).postln;
			};
		} {
			playFunc.value;
		};
		Yoeminrak.env.put(\lastCyc, currentEnvironment)
	}
});
