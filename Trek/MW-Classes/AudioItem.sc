AudioItem {
	classvar <>all, <folder, <buffers, <recorders;
    classvar <>armed = false;
	var <>name, <>buffer, <>path, <>recorder;
	var <>directory, <>takes, stopFunc;

	*initClass {
		all = Dictionary.new(512);
		buffers = MultiLevelIdentityDictionary.new;
		recorders = Dictionary.new;
		Class.initClassTree(Event);
		folder = "~/tank/SC_audiofiles".standardizePath;
		File.exists(folder).not.if{ "mkdir %".format(folder).unixCmd };
		CmdPeriod.add(this);
		Class.initClassTree(MyFree);
		MyFree.add({ this.stopRecording; armed = false });

		SynthDef(\audioItemTempoFollowRB, {
			|out=0, bufnum=0, amp=1, rate=1, startPos=0, sustain=1, fade=0.02,
			 pitchShift=1, formant=1, pan=0|
			var sig, env, safeFade;
			safeFade = fade.min(sustain * 0.45);
			sig = RubberBand.ar(1, bufnum,
				rate: rate,
				pitchShift: pitchShift,
				trig: 1,
				startPos: startPos * BufSampleRate.kr(bufnum),
				loop: 0,
				doneAction: 0,
				formant: formant
			);
			env = EnvGen.kr(
				Env.linen(safeFade, (sustain - (safeFade * 2)).max(0), safeFade),
				doneAction: 2
			);
			Out.ar(out, Pan2.ar(sig * env, pan) * amp)
		}).add;

		Event.addEventType(\audioItemTempoFollow, {
			"\\audioItemTempoFollow needs EventList playback; use EventList.add(... newType: \\audioItemTempoFollow ...)".warn
		});

		Event.addEventType(\audioItem, {
			var name = ~name ?? { Error("AudioItem requires a name").throw };
			var directory = folder +/+ name;
			var entryCount = File.exists(directory).if {
				PathName(directory).entries.size
			} { 0 };
			var recording = ~record ? false;
			// recording always writes a fresh take — a specified ~take selects which
			// take to PLAY, it never overwrites an existing recording
			var takeNum = recording.if
				{ AudioItem.nextTake(directory) }
				{ ~take ?? (entryCount - 1).max(0) };
			var format = (~format ? \wav).asString;
			var path = recording.if
				{ directory +/+ takeNum ++ "." ++ format }
				{ AudioItem.takePath(directory, takeNum) };
			var buffer = buffers.at(name.asSymbol, takeNum);
			var recorder = Recorder(Server.default);
			// dur the user actually set, ignoring the (dur: 5) parent default —
			// own keys don't consult the parent chain
			var userDur = currentEnvironment.keys.includes(\dur).if { ~dur };

			// Create buffer if it doesn't exist
			buffer = buffer ?? {
				buffers.put(name.asSymbol, takeNum, Buffer());
				buffers.at(name.asSymbol, takeNum);
			};

			// Load audio file if it exists
			File.exists(path).if {
				(buffer.numFrames.isNil or: (buffer.numFrames == 0)).if {
					buffer.allocRead(path).updateInfo;
				}
			};
			
			// Set up the event with all the functionality
			currentEnvironment.putAll((
				path: path,
				recorder: recorder,
				buffer: buffer,
				dur: ~dur ? 5,
                record: ~record ? false,
				startPos: ~start ? 0,

			));
            ~record.if{
				armed.not.if {
					"AudioItem not armed! not recording".warn;
					~record = false;
					currentEnvironment.play
				} {
					var nc = ~numChannels ? 1;
					// restarting a name that is still recording closes the old take first
					recorders[name.asSymbol] !? {|r| r.isRecording.if { r.stopRecording } };
					recorders[name.asSymbol] = recorder;
					~recorder.recHeaderFormat_(format).recSampleFormat_(AudioItem.sampleFormatFor(format));
					~recorder.prepareForRecord(~path, nc);
					Server.default.bind{
						// no dur given -> record until AudioItem.stopRecording(name) or Cmd-.
						// dur given -> record recTail (default 5s) beyond it in case a tail is needed
						~recorder.record(~path, ~in ? Server.default.options.numOutputBusChannels, nc,
							duration: userDur !? (_ + (~recTail ? 5)))
					};
					// invalidate cached buffer so next playback reloads from disk
					buffers.put(name.asSymbol, takeNum, Buffer());
				}
            } {
                // build the effect (if ~out is a thunk) BEFORE the bundle — Effect.bus
                // allocates a Bus, sends its own SynthDef and spawns a synth, none of
                // which can happen during this graph's compilation inside makeBundle.
                var outBus = (~out ? 0).value;
                // match \audioItemTempoFollow / Server.bind / note events: default the
                // playback bundle to the real server latency, not a hardcoded 0.2, so
                // audioItems stay aligned with voices under any s.latency setting.
                Server.default.makeBundle(
                    (~latency ? Server.default.latency) + (~lag ? 0),
                    {
                        {
                            PlayBuf.ar(
                                ~numChannels ? 1,
                                buffer.bufnum,
                                rate: ~rate ? 1,
                                startPos: ~startPos !? (_ * Server.default.sampleRate) ? 0
                            )
                            * (~amp ? 1)
                            => Out.ar(outBus, _)
                        }.play
                    }
                )
            }
		}, (dur:5)
	);
	}
*cmdPeriod {
	armed = false
}
	// next free take index: one past the highest numbered file, so gaps or
	// strays (.DS_Store etc.) never cause an existing take to be overwritten
	*nextTake { |directory|
		var nums;
		File.exists(directory).not.if { ^0 };
		nums = PathName(directory).files
			.collect { |p| p.fileNameWithoutExtension }
			.select { |stem| stem.notEmpty and: { stem.every(_.isDecDigit) } }
			.collect(_.asInteger);
		^nums.isEmpty.if { 0 } { nums.maxItem + 1 }
	}

	// resolve an existing take file regardless of extension (wav/flac); fall back to .wav
	*takePath { |directory, takeNum|
		var matches = (directory +/+ takeNum ++ ".*").pathMatch;
		^matches.notEmpty.if { matches.first } { directory +/+ takeNum ++ ".wav" }
	}

	// flac caps at 24-bit int; otherwise keep the server's float32
	*sampleFormatFor { |format|
		^(format.asString == "flac").if { "int24" } { "float" }
	}

	// Source-position seam shared by tempoFollowActions/tempoFollowEnvActions
	// (quantize-tempomap-project.md §9b, same convention as \mi2): ideal beat ->
	// elapsed seconds into the source recording. Priority: \sourceTempoMap map
	// object (the take's own map, item-frame coordinates — beat b0 == map domain
	// start == ev[\start] seconds into the file), then flat \sourceBeatDur, then
	// the list's base clock (recorded tempoMap, else flat beatDur).
	*prSrcOffset { |ev, list, b0|
		var sm = ev[\sourceTempoMap];
		(sm.notNil and: { sm.respondsTo(\timeAt) }).if {
			var bd = sm.beatDomain.first, t0 = sm.timeDomain.first;
			^{ |bt| sm.timeAt(bd + (bt - b0)) - t0 }
		};
		ev[\sourceBeatDur].notNil.if {
			^{ |bt| (bt - b0) * ev[\sourceBeatDur] }
		};
		^{ |bt| list.baseWallDelta(b0, bt) }
	}
	// Inverse of prSrcOffset for the no-\dur case: the beat at which the source
	// position reaches endSec.
	*prSrcEndBeat { |ev, list, b0, startSec, endSec|
		var sm = ev[\sourceTempoMap];
		var rel = endSec - startSec;
		(sm.notNil and: { sm.respondsTo(\beatAt) }).if {
			^b0 + (sm.beatAt(sm.timeDomain.first + rel) - sm.beatDomain.first)
		};
		ev[\sourceBeatDur].notNil.if {
			^b0 + (rel / ev[\sourceBeatDur])
		};
		list.tempoMap.notNil.if {
			^list.tempoMap.beatAt(list.tempoMap.timeAt(b0) + rel)
		};
		^b0 + (rel / (list.beatDur ? TempoClock.default.beatDur))
	}

	// wallAt: optional { |beat| -> wall-seconds } overriding list.beatToWall — the §10
	// `place` seam. Returned delays stay relative to wallAt(from), so absolute-time
	// callers (EventList.prEmit) add place.(from) back on.
	*tempoFollowActions { |ev, list, tempoEnv, from = 0, wallAt|
		var name = ev[\name] ?? { Error("AudioItem tempoFollow requires a name").throw };
		var directory = folder +/+ name;
		var entryCount = File.exists(directory).if { PathName(directory).entries.size } { 0 };
		var takeNum = ev[\take] ?? { (entryCount - 1).max(0) };
		var path = AudioItem.takePath(directory, takeNum);
		var buffer, sf, sourceDur, srcOffset, b0, startSec, endSec;
		var segBeats, fade, fromBeat, fromSec, actions, beat, lastBeat;
		var wallFrom, srcCarry, wallCarry;

		File.exists(path).not.if {
			"AudioItem tempoFollow: no file at %".format(path).warn;
			^List[]
		};

		buffer = buffers.at(name.asSymbol, takeNum) ?? {
			buffers.put(name.asSymbol, takeNum, Buffer());
			buffers.at(name.asSymbol, takeNum)
		};
		(buffer.numFrames.isNil or: { buffer.numFrames == 0 }).if {
			buffer.allocRead(path).updateInfo
		};

		sf = SoundFile.openRead(path);
		sf.isNil.if {
			"AudioItem tempoFollow: cannot read %".format(path).warn;
			^List[]
		};
		sourceDur = sf.numFrames / sf.sampleRate;
		sf.close;

		wallAt = wallAt ?? { { |bt| list.beatToWall(bt, tempoEnv) } };
		b0 = ev[\when] ? 0;
		startSec = ev[\start] ? ev[\startPos] ? 0;
		// Map an ideal beat to elapsed seconds into the SOURCE recording. The default
		// assumes the take was recorded on the list's base clock (recorded tempoMap,
		// else flat beatDur), so source position advances with baseWallDelta — NOT a
		// flat 1-beat-per-second grid. A \sourceTempoMap map object overrides with the
		// take's own map (item-frame coordinates, for takes whose map the list doesn't
		// own); \sourceBeatDur is the flat override for takes recorded off any clock.
		srcOffset = AudioItem.prSrcOffset(ev, list, b0);
		endSec = ev[\dur].notNil.if {
			(startSec + srcOffset.(b0 + ev[\dur])).min(sourceDur)
		} {
			sourceDur
		};
		fromBeat = from.max(b0);
		fromSec = startSec + srcOffset.(fromBeat);
		(fromSec >= endSec).if { ^List[] };

		segBeats = ev[\tempoFollowSegBeats] ? 0.25;
		fade = ev[\tempoFollowFade] ? 0.03;
		actions = List[];
		beat = fromBeat;
		// With \dur the end beat is exact; otherwise iterate until the source position
		// reaches the file end (avoids inverting the tempoMap to find the last beat).
		lastBeat = ev[\dur].notNil.if { b0 + ev[\dur] } { inf };

		// Loop-invariant / carried values: wallAt.(from) is fixed, and each iteration's
		// (sourceA, wallA) is the previous one's (sourceBFull, wallB) — recomputing them
		// tripled the beatToWall cost of this loop.
		wallFrom  = wallAt.(from);
		srcCarry  = fromSec; // == startSec + srcOffset.(fromBeat)
		wallCarry = wallAt.(beat);
		while { (beat < lastBeat) and: { srcCarry < endSec } } {
			var nextBeat = (beat + segBeats).min(lastBeat);
			var sourceA = srcCarry;
			var sourceBFull = startSec + srcOffset.(nextBeat);
			var sourceB = sourceBFull.min(endSec);
			var wallA = wallCarry;
			var wallB = wallAt.(nextBeat);
			// rate from the full segment (local source-secs per wall-sec); the wall span
			// is truncated by the same fraction when the final chunk hits the file end.
			var rate = (sourceBFull - sourceA) / (wallB - wallA).max(0.001);
			var wallDur = (wallB - wallA) * ((sourceB - sourceA) / (sourceBFull - sourceA).max(1e-9));
			var delay = wallA - wallFrom;
			(wallDur > 0).if {
				actions.add([delay.max(0), {
					Server.default.makeBundle((ev[\latency] ? Server.default.latency) + (ev[\lag] ? 0), {
						Synth(\audioItemTempoFollowRB, [
							\bufnum, buffer.bufnum,
							\out, (ev[\out] ? 0).value,
							\amp, ev[\amp] ? 1,
							\rate, rate * (ev[\rate] ? 1),
							\startPos, sourceA,
							\sustain, wallDur + (fade * 2),
							\fade, fade,
							\pitchShift, ev[\pitchShift] ? 1,
							\formant, ev[\formant] ? 1,
							\pan, ev[\pan] ? 0
						])
					})
				}])
			};
			beat = nextBeat;
			srcCarry = sourceBFull;
			wallCarry = wallB;
		};
		^actions
	}

	// wallAt: same seam as tempoFollowActions. NB under nested followTrack placement the
	// EnvGen's tempo-multiplier LEVELS still come from this list's own tempoEnv, so
	// within-segment rates are approximate there; segment boundaries stay exact.
	*tempoFollowEnvActions { |ev, list, tempoEnv, from = 0, wallAt|
		var name = ev[\name] ?? { Error("AudioItem tempoFollow env mode requires a name").throw };
		var directory = folder +/+ name;
		var entryCount = File.exists(directory).if { PathName(directory).entries.size } { 0 };
		var takeNum = ev[\take] ?? { (entryCount - 1).max(0) };
		var path = AudioItem.takePath(directory, takeNum);
		var buffer, sf, sourceDur, srcOffset, b0, startSec, endSec;
		var fromBeat, fromSec, lastBeat, points, levels, times, curves;
		var totalSourceDur, wallDur, tempoPoints, curBeat, segEnds, actions;

		File.exists(path).not.if {
			"AudioItem tempoFollow env: no file at %".format(path).warn;
			^List[]
		};

		buffer = buffers.at(name.asSymbol, takeNum) ?? {
			buffers.put(name.asSymbol, takeNum, Buffer());
			buffers.at(name.asSymbol, takeNum)
		};
		(buffer.numFrames.isNil or: { buffer.numFrames == 0 }).if {
			buffer.allocRead(path).updateInfo
		};

		sf = SoundFile.openRead(path);
		sf.isNil.if {
			"AudioItem tempoFollow env: cannot read %".format(path).warn;
			^List[]
		};
		sourceDur = sf.numFrames / sf.sampleRate;
		sf.close;

		wallAt = wallAt ?? { { |bt| list.beatToWall(bt, tempoEnv) } };
		b0 = ev[\when] ? 0;
		startSec = ev[\start] ? ev[\startPos] ? 0;
		// beat -> elapsed seconds into the SOURCE recording; see prSrcOffset. Same
		// rationale as the non-env tempoFollowActions.
		srcOffset = AudioItem.prSrcOffset(ev, list, b0);
		endSec = ev[\dur].notNil.if {
			(startSec + srcOffset.(b0 + ev[\dur])).min(sourceDur)
		} {
			sourceDur
		};
		fromBeat = from.max(b0);
		fromSec = startSec + srcOffset.(fromBeat);
		(fromSec >= endSec).if { ^List[] };

		// Beat at which the source position reaches endSec. With \dur it's exact;
		// otherwise invert the source clock (see prSrcEndBeat).
		lastBeat = ev[\dur].notNil.if { b0 + ev[\dur] } {
			AudioItem.prSrcEndBeat(ev, list, b0, startSec, endSec)
		};
		totalSourceDur = endSec - fromSec;
		wallDur = wallAt.(lastBeat) - wallAt.(fromBeat);

		points = List[fromBeat];
		curves = List[];
		tempoEnv.notNil.if {
			curBeat = 0;
			tempoEnv.times.do { |dt, i|
				var nextBeat = curBeat + dt;
				((nextBeat > fromBeat) and: { nextBeat < lastBeat }).if {
					points.add(nextBeat)
				};
				curBeat = nextBeat;
			}
		};
		points.add(lastBeat);
		points = points.asArray.sort;

		levels = tempoEnv.notNil.if {
			points.collect { |beat| tempoEnv.at(beat) }
		} {
			points.collect { 1 }
		};
		// EnvGen advances in WALL time, so the tempo-multiplier breakpoints are spaced
		// by each segment's MODIFIED wall duration (their sum == wallDur), not source
		// seconds — otherwise the multiplier ramp races ahead of the audio.
		times = points.drop(-1).collect { |beat, i|
			wallAt.(points[i + 1]) - wallAt.(beat)
		};
		tempoEnv.notNil.if {
			segEnds = tempoEnv.times.integrate;
			curves = points.drop(-1).collect { |beat|
				var idx = segEnds.detectIndex { |end| beat < end };
				idx.isNil.if { tempoEnv.curves.asArray.last ? \linear } {
					tempoEnv.curves.isArray.if { tempoEnv.curves.wrapAt(idx) } { tempoEnv.curves }
				}
			}
		} {
			curves = times.collect { \linear }
		};

		actions = List[];
		actions.add([wallAt.(fromBeat) - wallAt.(from), {
			Server.default.makeBundle((ev[\latency] ? Server.default.latency) + (ev[\lag] ? 0), {
				{
					var tempoMult = EnvGen.kr(Env(levels, times, curves));
						var rate = tempoMult.reciprocal * (ev[\rate] ? 1);
						var sig = RubberBand.ar(1, buffer.bufnum,
							rate: rate,
							pitchShift: ev[\pitchShift] ? 1,
							trig: 1,
							startPos: fromSec * BufSampleRate.kr(buffer.bufnum),
							loop: 0,
							doneAction: 0,
							formant: ev[\formant] ? 1
						);
						var ampEnv = EnvGen.kr(
							Env.linen(ev[\tempoFollowFade] ? 0.03,
								(wallDur - ((ev[\tempoFollowFade] ? 0.03) * 2)).max(0),
								ev[\tempoFollowFade] ? 0.03),
							doneAction: 2
						);
						Out.ar((ev[\out] ? 0).value, Pan2.ar(sig * ampEnv, ev[\pan] ? 0) * (ev[\amp] ? 1))
					}.play
				})
		}]);
		^actions
	}

    *new {|name|
        var ret = super.new;

        ret.recorder = Recorder(Server.default);
		ret.name = name;
		//takes version
		ret.directory = folder +/+ name;
		File.exists(ret.directory).if{
			ret.takes = PathName(ret.directory).entries.size;  // Count of existing files
		} {
			File.mkdir(ret.directory);
			ret.takes = 0;  // No files yet, so count is 0
		};

		// Set path to most recent take (takes-1, or 0 if no files exist)
		ret.path = AudioItem.takePath(ret.directory, (ret.takes - 1).max(0));
		
        // Create buffer for the most recent take if it exists
        ret.buffer = buffers[name.asSymbol, (ret.takes - 1).max(0)] ?? {
			var newBuf = Buffer();
            buffers.put(name.asSymbol, (ret.takes - 1).max(0), newBuf);  // Store at correct index
			newBuf;
        };
        // Load audio file if it exists
        File.exists(ret.path).if{
            (ret.buffer.numFrames.isNil or: (ret.buffer.numFrames == 0)).if {
                ret.buffer.allocRead(ret.path).updateInfo;
            };
        };
		^ret
    }
	*insertNew {|name|
		Nvim.replace("AudioItem(\"%\")".format(name ++ "_" ++ Date.getDate.stamp))
	}
	*insertEvent {|name|
		Nvim.replace( "(type: \\audioItem, name: \"%\")".format(name ++ "_" ++  Date.getDate.stamp) )
	}
	// stop an event-started open-ended recording; no name stops all of them
	*stopRecording { |name|
		name.isNil.if {
			recorders.copy.keysDo{ |k| this.stopRecording(k) }
		} {
			recorders.removeAt(name.asSymbol) !? { |r|
				r.isRecording.if { r.stopRecording }
			}
		}
	}
	record {
		|length, format = \wav, tail = 5|
		var take, path, finished = false, finish;
		// restarting while a take is still recording closes it first (bumps takes synchronously)
		recorders[name.asSymbol] !? {|r| r.isRecording.if { r.stopRecording } };
		recorders[name.asSymbol] = this;
		take = takes;
		path = directory +/+ take ++ "." ++ format;  // New file at index 'takes'
		finish = {
			finished.not.if {
				finished = true;
				stopFunc = nil;
				takes = take + 1;  // Increment after successful recording
				fork{
					0.05.wait;  // time for file to write?
					buffers.put(name.asSymbol, take, Buffer.read(Server.default, path).debug("BUFFER"));
				}
			}
		};
		recorder.recHeaderFormat_(format.asString).recSampleFormat_(AudioItem.sampleFormatFor(format));
		recorder.prepareForRecord(path);
		Server.default.bind{
			recorder.record(
				path,
				Server.default.options.numOutputBusChannels,
				// nil -> record until .stopRecording or Cmd-.; else add tail for safety
				duration: length !? (_ + tail)
			)
		};
		stopFunc = {
			recorder.stopRecording;
			finish.();
		};
		length !? { fork{ (length + tail + 0.05).wait; finish.() } };
		CmdPeriod.doOnce{ finish.() };  // Recorder's node onFree already closes the file
	}
	stopRecording {
		stopFunc !? _.();
	}
	isRecording {
		^stopFunc.notNil
	}
	take { |num|
        ^Take(name, num)
	}

    play { 
        ^Take(name, takes - 1).play  // Play the most recent take
    }
}
Take : AudioItem {
    var name, <>num, buffer;
    *new { |name, num|
        var newTake = super.newCopyArgs;
		var directory = folder +/+ name;
        newTake.name = name; newTake.num = num;   // store identity (needed by .retune)
        newTake.buffer = AudioItem.buffers[name.asSymbol][num].notNil.if {
			 AudioItem.buffers[name.asSymbol][num] 
		} {
			 AudioItem.buffers.put(name.asSymbol, num, Buffer.read(Server.default, AudioItem.takePath(directory, num)));
			 AudioItem.buffers[name.asSymbol][num]
		} 
        ^newTake
    }
	retune { ^RetuneItem(this) }   // -> RetuneItem (load-or-analyze-and-save)
	playbuf {| amp out rate startPos dur |
		^ 
			PlayBuf.ar(
				buffer.numChannels max: 1,
				buffer.bufnum,
				rate: rate ? 1,
				startPos: (startPos ? 0) * SampleRate.ir,
				doneAction:2
			)
			* (amp ? 1)
            * EnvGen.cutoff(dur ? 1000, 0.0)
			=> Out.ar(out ? 0, _);
		
	}
	play { |amp out rate, startPos, latency, lag, dur|
		// take.notNil.if { buffer = buffers[name][playTake] };

		fork{
			// get time to sync Server for buffer info
			var syncTime = SystemClock.seconds;
			buffer.updateInfo;Server.default.sync;

			Server.default.makeBundle(
				(latency ? 0.2) + (lag ? 0) - (SystemClock.seconds - syncTime),
				{
					{this.playbuf(amp, out, rate, startPos, dur )}.play

				}
			)
		}
	}
}
