AudioItem {
	classvar <>all, <folder, <buffers, <recorders;
	classvar <recordedMaps; // (name, take) -> record-time clock stamp (§9a step 2)
	// Measured input+output round trip of the current audio-device configuration
	// (seconds; set after a loopback measurement, re-measure on buffer-size or
	// interface change). Mic overdubs land this LATE in the file relative to the
	// grid — the latencies ADD, they never cancel. Captured into each record-time
	// stamp and applied by stamp-based playback resolution (\raw convention: the
	// file is never trimmed; compensation is a read-side offset).
	classvar <>roundTripLatency = 0;
	// The OUTPUT leg alone (seconds) — what MIDI capture needs. A performer aims at
	// what reached their ears, which is roundTrip's output half beyond the server
	// sound domain EventList's play epoch is expressed in; the press itself carries
	// no input latency, so MIDI must not use the full round trip. Audio capture is
	// the opposite case and correctly uses the whole trip: the voice lands L_in late
	// in the file AND referenced monitoring that was L_out late, and those add.
	// Set by measureRoundTrip from the loopback total x the OS-reported split.
	classvar <>outputLatency = 0;
    classvar <>armed = false;
	var <>name, <>buffer, <>path, <>recorder;
	var <>directory, <>takes, stopFunc;

	*initClass {
		all = Dictionary.new(512);
		buffers = MultiLevelIdentityDictionary.new;
		recordedMaps = MultiLevelIdentityDictionary.new;
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
			var recording = ~record ? false;
			// recording always writes a fresh take — a specified ~take selects which
			// take to PLAY, it never overwrites an existing recording
			var takeNum = recording.if
				{ AudioItem.nextTake(directory) }
				{ ~take ?? { AudioItem.latestTake(directory) } };
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
				// start: is the documented read-offset knob; keep a user-supplied
				// startPos: working too rather than silently overwriting it with 0.
				startPos: ~start ?? { ~startPos ? 0 },

			));
            ~record.if{
				armed.not.if {
					"AudioItem not armed! not recording".warn;
					~record = false;
					currentEnvironment.play
				} {
					var nc = ~numChannels ? 1;
					// roundTripLatency is per-machine (pinned in startup.scd, in no
					// repo) and the stamp written below freezes it forever. Recording
					// on an unmeasured machine therefore stamps 0 and the take plays
					// uncompensated for the rest of its life, with nothing to show
					// for it at record time. Say so once, while it is still cheap.
					(roundTripLatency == 0).if {
						"AudioItem: roundTripLatency is 0 — % will be stamped with no "
						"latency compensation. Run AudioItem.measureRoundTrip on this "
						"machine first.".format(name).warn
					};
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
					// record-time clock stamp from EventList.prEmit (§9a step 2):
					// remembers what this take was recorded against, so playback
					// can resolve the true source clock even after the list's map
					// changes (e.g. destructive quantize)
					~recordedAgainst !? { |stamp|
						AudioItem.recordedMaps.put(name.asSymbol, takeNum, stamp);
						// persist as a v2 retune-archive version (anchors +
						// recordedAgainst) so the stamp survives sclang restarts;
						// a write failure only warns — never aborts the recording
						RetuneArchive.writeStamp(name, takeNum, stamp);
					};
				}
            } {
                // build the effect (if ~out is a thunk) BEFORE the bundle — Effect.bus
                // allocates a Bus, sends its own SynthDef and spawns a synth, none of
                // which can happen during this graph's compilation inside makeBundle.
                var outBus = (~out ? 0).value;
                // \raw latency convention (same as the tempoFollow path's `+ rt` in
                // prSrcOffset): a mic take is never trimmed on disk, so its content
                // sits roundTrip LATE in the file relative to the grid the record
                // event fired on. Compensation is a READ-side offset, added to the
                // user's ~start. Only takes carrying a record-time stamp are shifted
                // — imported / hand-placed files have no stamp and stay at face value.
                // recordedMapAt caches, so the archive read happens once per take.
                var rt = (AudioItem.recordedMapAt(name, takeNum) !? { |st|
                    st[\roundTrip] ? 0
                }) ? 0;
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
                                startPos: ((~startPos ? 0) + rt) * Server.default.sampleRate
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

	// Measure the device's input+output round trip by loopback and persist it.
	// Physically route output channel `out` back into input channel `in` (cable,
	// or mic close to the speaker), then: AudioItem.measureRoundTrip.
	// One synth emits a 2 kHz ping and records the input FROM THE SAME BUNDLE, so
	// the ping's position in the buffer IS the full hardware round trip. The
	// result is set on roundTripLatency and (write: true) written to startup.scd
	// — the right home: per-machine, so it doesn't belong in a shared repo.
	// Re-measure after buffer-size or interface changes.
	// outputLatency is set at the same time: the ping traverses BOTH legs, so the
	// loopback can only ever yield their sum, and the split comes from CoreAudio
	// via prQueryOutputShare (0.5 if the helper is unavailable — correct only for
	// symmetric legs, which is common on a single interface but false for built-in
	// mic + speakers). Pass outputShare: to override.
	// Route the cable through the REAL path — the monitoring output you listen to
	// into the input you record through. An internal TotalMix-style loopback never
	// reaches a converter and measures the driver, not the rig.
	*measureRoundTrip { |in = 0, out = 0, amp = 0.5, dur = 0.5, write = true, action,
		outputShare|
		var server = Server.default;
		server.serverRunning.not.if {
			^"AudioItem.measureRoundTrip: server not running".warn
		};
		fork {
			var frames = (dur * server.sampleRate).asInteger;
			var buf = Buffer.alloc(server, frames, 1);
			server.sync;
			SynthDef(\audioItemLoopbackPing, { |out = 0, in = 0, amp = 0.5, buf|
				var ping = Decay.ar(Impulse.ar(0), 0.005) * SinOsc.ar(2000) * amp;
				Out.ar(out, ping);
				RecordBuf.ar(SoundIn.ar(in), buf, loop: 0, doneAction: 2);
			}).add;
			server.sync;
			server.bind {
				Synth(\audioItemLoopbackPing, [\out, out, \in, in, \amp, amp, \buf, buf])
			};
			(dur + 0.2).wait;
			buf.loadToFloatArray(action: { |data|
				var peak = data.abs.maxItem;
				var idx, rt, share;
				(peak < 0.01).if {
					"measureRoundTrip: no signal (peak %) — is the loopback connected?"
						.format(peak.round(1e-4)).warn
				} {
					// leading edge (first half-peak crossing), not the peak itself
					idx = data.detectIndex { |x| x.abs > (peak * 0.5) };
					rt = idx / server.sampleRate;
					share = outputShare ?? { this.prQueryOutputShare ? 0.5 };
					roundTripLatency = rt;
					outputLatency = rt * share;
					"measureRoundTrip: % ms round trip (peak %)"
						.format((rt * 1000).round(0.01), peak.round(0.01)).postln;
					"  output leg % ms (share %) — set on AudioItem.outputLatency"
						.format((outputLatency * 1000).round(0.01), share.round(0.001)).postln;
					write.if { AudioItem.writeStartupLatency(rt, outLatency: outputLatency) };
					action.(rt);
				};
				buf.free;
			});
		}
	}

	// Ask CoreAudio for the output leg's share of the round trip. The loopback only
	// ever measures the SUM (the ping traverses both legs), so the split has to come
	// from the driver: device latency + safety offset + buffer frames + stream
	// latency, per direction. Returns nil when the helper is missing or silent —
	// callers fall back to 0.5. Note the driver reports only what it can see: on an
	// ADAT front end the outboard converters are invisible, so trust this for the
	// RATIO and the loopback for the TOTAL.
	*prQueryOutputShare { |helper|
		var line;
		helper = helper ?? { "~/tank/super/bin/audio-latency.swift".standardizePath };
		File.exists(helper).not.if { ^nil };
		line = "% 2>/dev/null".format(helper.shellQuote).unixCmdGetStdOut
			.split(Char.nl).detect { |l| l.beginsWith("L_out share") };
		^line !? { line.split($ ).reject(_.isEmpty)[2].asFloat }
	}

	// Idempotently pin `AudioItem.<name> = <value>;` into a startup.scd line array:
	// replaces the existing assignment if present, else appends.
	*prPinLine { |lines, name, value, stamp|
		var line = "AudioItem.% = %; // loopback-measured %".format(name, value, stamp);
		var closeIdx;
		// drop any previous pin first, wherever in the file it happens to sit —
		// the insertion point below decides where the new one belongs
		lines = lines.reject { |l| l.contains("AudioItem." ++ name) };
		closeIdx = this.prTrailingBlockClose(lines);
		closeIdx.notNil.if { ^lines.keep(closeIdx) ++ [line] ++ lines.drop(closeIdx) };
		(lines.last.size == 0).if { lines = lines.drop(-1) }; // keep single trailing \n
		^lines ++ [line]
	}

	// A startup.scd that is one `( var ...; ... )` block is sclang's WHOLE-PROGRAM
	// form (the cmdlinecode grammar): nothing may follow the closing paren — not
	// another statement, not even a `;`. Appending our pin after it produced
	//   ERROR: syntax error, unexpected CLASSNAME, expecting end of file
	// and sclang then ran NONE of the startup file, silently, since startup output
	// scrolls past. So when the file ends in such a block, the pin goes INSIDE it.
	// Returns the index of that closing paren, or nil when the file is a plain
	// sequence of statements (where appending at the end is correct).
	*prTrailingBlockClose { |lines|
		var lastCode, code, cut;
		lines.do { |l, i|
			var t = l.stripWhiteSpace;
			(t.notEmpty and: { t.beginsWith("//").not }).if { lastCode = i }
		};
		lastCode.isNil.if { ^nil };
		// a trailing line comment is whitespace to the parser, so `) // note`
		// closes the block just as `)` does
		code = lines[lastCode];
		cut = code.find("//");
		cut.notNil.if { code = code.keep(cut) };
		^(code.stripWhiteSpace == ")").if { lastCode } { nil }
	}

	// Pin the measured latencies in startup.scd — per-machine state, deliberately
	// outside version control. outLatency nil pins only the round trip (the pre-
	// outputLatency call shape).
	*writeStartupLatency { |rt, path, outLatency|
		var lines, stamp;
		path = path ?? { Platform.userConfigDir +/+ "startup.scd" };
		File.exists(path).not.if {
			^"writeStartupLatency: no startup file at %".format(path).warn
		};
		stamp = Date.getDate.stamp;
		lines = File.readAllString(path).split(Char.nl);
		lines = this.prPinLine(lines, "roundTripLatency", rt, stamp);
		outLatency.notNil.if {
			lines = this.prPinLine(lines, "outputLatency", outLatency, stamp)
		};
		File.use(path, "w", { |f| f.write(lines.join(Char.nl) ++ Char.nl) });
		"writeStartupLatency: pinned roundTripLatency = % in %".format(rt, path).postln;
		outLatency.notNil.if {
			"writeStartupLatency: pinned outputLatency = %".format(outLatency).postln
		};
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

	// latest existing take index (highest numbered file, same rule as nextTake).
	// Playback defaults used PathName.entries.size - 1, which counts strays
	// (.DS_Store, sidecars) and pointed past the real take.
	*latestTake { |directory|
		^(this.nextTake(directory) - 1).max(0)
	}

	// resolve an existing take file regardless of AUDIO extension; fall back to
	// .wav. Non-audio siblings (future metadata sidecars) must not shadow the take.
	*takePath { |directory, takeNum|
		var matches = (directory +/+ takeNum ++ ".*").pathMatch.select { |p|
			#["wav", "aif", "aiff", "flac", "caf"].includesEqual(p.splitext.last.asString.toLower)
		};
		^matches.notEmpty.if { matches.first } { directory +/+ takeNum ++ ".wav" }
	}

	// Correct the round trip baked into an already-recorded take. The \raw
	// compensation reads roundTrip from the take's own record-time stamp, not from
	// the current classvar — that is the point (a take recorded on one rig must
	// keep playing right after the rig changes). So when roundTripLatency was WRONG
	// at record time, the fix belongs in the stamp. Appends a new archive version
	// with the anchors and every other recordedAgainst field carried over, and
	// drops the in-memory cache so the next playback reloads. ^the new version id.
	*repinRoundTrip { |name, takeNum, rt|
		var found = RetuneArchive.latestWhere(name, takeNum, { |d|
			d[\recordedAgainst].notNil and: { (d[\anchors] ? []).size >= 2 }
		});
		var d, ra, v;
		found.isNil.if {
			^"AudioItem.repinRoundTrip(%, %): no record stamp on disk"
				.format(name, takeNum).warn
		};
		d = found[1].copy;
		ra = d[\recordedAgainst].copy;
		ra[\roundTrip] = rt;
		d[\recordedAgainst] = ra;
		d[\saved] = Date.getDate.stamp;
		v = RetuneArchive.write(name, takeNum, d);
		// force the next recordedMapAt to reload from disk
		recordedMaps.put(name.asSymbol, takeNum, nil);
		"AudioItem.repinRoundTrip(%, %): % -> % s (archive version %)"
			.format(name, takeNum, found[1][\recordedAgainst][\roundTrip], rt, v).postln;
		^v
	}

	// Empirical grid offset of a take: seconds from file start to its first
	// transient. Record a take whose event list fires ONE click at the record
	// event's own beat, then AudioItem.takeOnset(\latTest) — with the \raw
	// convention the answer IS the device round trip, so it should agree with
	// roundTripLatency. When it doesn't, roundTripLatency is stale (buffer size or
	// interface changed) or was measured on a path other than the real monitoring
	// chain. thresh is a fraction of the peak inside the scanned window; keep it
	// low so the LEADING edge is found, not the reverberant build-up.
	*takeOnset { |name, takeNum, thresh = 0.05, window = 1, action|
		var dir = folder +/+ name.asString;
		var server = Server.default;
		var path;
		takeNum = takeNum ?? { this.latestTake(dir) };
		path = this.takePath(dir, takeNum);
		File.exists(path).not.if {
			^"AudioItem.takeOnset: no file at %".format(path).warn
		};
		Buffer.read(server, path, 0, (window * server.sampleRate).asInteger, { |b|
			b.loadToFloatArray(action: { |d|
				var peak = d.abs.maxItem;
				var idx = d.detectIndex { |x| x.abs > (peak * thresh) };
				var t = idx !? { idx / b.numChannels / server.sampleRate };
				t.isNil.if {
					"AudioItem.takeOnset(%, %): nothing above % of peak % in the first % s"
						.format(name, takeNum, thresh, peak, window).warn
				} {
					"AudioItem.takeOnset(%, %): % s   (peak %, roundTripLatency %)"
						.format(name, takeNum, t.round(1e-5), peak.round(1e-5),
							roundTripLatency).postln
				};
				b.free;
				action.value(t);
			})
		})
	}

	// flac caps at 24-bit int; otherwise keep the server's float32
	*sampleFormatFor { |format|
		^(format.asString == "flac").if { "int24" } { "float" }
	}

	// Record-time clock stamp for (name, take), or nil (§9a step 2). In-memory
	// stamps (this session's recordings) win; on a miss the persisted archive is
	// consulted (RetuneArchive.loadStamp — the anchors-serialized form survives
	// sclang restarts) and cached back here so the disk scan runs once per take.
	*recordedMapAt { |name, takeNum|
		^name !? {
			var hit = recordedMaps.at(name.asSymbol, takeNum);
			// \none is the negative cache. loadStamp deserializes EVERY .retune
			// version of the take newest-first looking for a \recordedAgainst, so a
			// take with a long retune history and no stamp (recorded before stamping
			// existed, 2026-07-13) costs hundreds of ms and answers nil. Caching only
			// the hit meant that scan re-ran on every playback — and \audioItem calls
			// this from inside its send, which EventList.fire runs only `latency`
			// ahead of the sound, so the bundle went out late and the take played late.
			(hit == \none).if { ^nil };
			hit ?? {
				RetuneArchive.loadStamp(name, takeNum) !? { |stamp|
					recordedMaps.put(name.asSymbol, takeNum, stamp);
					stamp
				} ?? {
					recordedMaps.put(name.asSymbol, takeNum, \none);
					nil
				}
			}
		}
	}

	// Source-position seam shared by tempoFollowActions/tempoFollowEnvActions
	// (quantize-tempomap-project.md §9b, same convention as \mi2): ideal beat ->
	// elapsed seconds into the source recording. Priority: \sourceTempoMap map
	// object (the take's own map, item-frame coordinates — beat b0 == map domain
	// start == ev[\start] seconds into the file), then flat \sourceBeatDur, then
	// the take's record-time stamp (what it was ACTUALLY recorded against — beats
	// identified across lists, so this survives a destructive quantize), then
	// the list's base clock (recorded tempoMap, else flat beatDur).
	*prSrcOffset { |ev, list, b0, takeNum|
		var sm = ev[\sourceTempoMap];
		var stamp;
		(sm.notNil and: { sm.respondsTo(\timeAt) }).if {
			var bd = sm.beatDomain.first, t0 = sm.timeDomain.first;
			^{ |bt| sm.timeAt(bd + (bt - b0)) - t0 }
		};
		ev[\sourceBeatDur].notNil.if {
			^{ |bt| (bt - b0) * ev[\sourceBeatDur] }
		};
		stamp = this.recordedMapAt(ev[\name], takeNum);
		stamp.notNil.if {
			var rt = stamp[\roundTrip] ? 0; // mic content sits rt LATE in the file
			var m = stamp[\map], sl, sEnv, sb0, w0;
			// disk-loaded form: an AnchorTempoMap over the serialized anchors, whose
			// relative frame starts at the record-fire beat (src there == 0)
			m.notNil.if { ^{ |bt| m.timeAt(bt - b0) + rt } };
			sl = stamp[\list]; sEnv = stamp[\tempoEnv]; sb0 = stamp[\when];
			w0 = sl.beatToWall(sb0, sEnv);
			^{ |bt| sl.beatToWall(sb0 + (bt - b0), sEnv) - w0 + rt }
		};
		^{ |bt| list.baseWallDelta(b0, bt) }
	}
	// Inverse of prSrcOffset for the no-\dur case: the beat at which the source
	// position reaches endSec.
	*prSrcEndBeat { |ev, list, b0, startSec, endSec, takeNum|
		var sm = ev[\sourceTempoMap];
		var rel = endSec - startSec;
		var stamp;
		(sm.notNil and: { sm.respondsTo(\beatAt) }).if {
			^b0 + (sm.beatAt(sm.timeDomain.first + rel) - sm.beatDomain.first)
		};
		ev[\sourceBeatDur].notNil.if {
			^b0 + (rel / ev[\sourceBeatDur])
		};
		stamp = this.recordedMapAt(ev[\name], takeNum);
		stamp.notNil.if {
			var rt = stamp[\roundTrip] ? 0;
			var m = stamp[\map], sl, sEnv, sb0, w0;
			m.notNil.if { ^b0 + m.beatAt(rel - rt) };
			sl = stamp[\list]; sEnv = stamp[\tempoEnv]; sb0 = stamp[\when];
			w0 = sl.beatToWall(sb0, sEnv);
			^b0 + (sl.wallToBeat(w0 + (rel - rt), sEnv) - sb0)
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
		var takeNum = ev[\take] ?? { AudioItem.latestTake(directory) };
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
		srcOffset = AudioItem.prSrcOffset(ev, list, b0, takeNum);
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
		var takeNum = ev[\take] ?? { AudioItem.latestTake(directory) };
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
		srcOffset = AudioItem.prSrcOffset(ev, list, b0, takeNum);
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
			AudioItem.prSrcEndBeat(ev, list, b0, startSec, endSec, takeNum)
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
			// one past the highest numbered take (entries.size counted strays)
			ret.takes = AudioItem.nextTake(ret.directory);
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
		// multi-key at: buffers[name][num] threw whenever `name` had no entry yet
		// (the outer [] returns nil, and nil[num] is not a message) — i.e. every
		// Take() in a fresh session, before anything had cached a buffer.
        newTake.buffer = AudioItem.buffers.at(name.asSymbol, num) ?? {
			 AudioItem.buffers.put(name.asSymbol, num, Buffer.read(Server.default, AudioItem.takePath(directory, num)));
			 AudioItem.buffers.at(name.asSymbol, num)
		} 
        ^newTake
    }
	retune { ^RetuneItem(this) }   // -> RetuneItem (load-or-analyze-and-save)
	// The round trip this take was recorded against — what playback compensates by
	// (\raw convention). nil when the take carries no record stamp, e.g. an
	// imported file: those are read at face value and never shifted.
	roundTripLatency {
		^AudioItem.recordedMapAt(this.name, num) !? { |st| st[\roundTrip] ? 0 }
	}
	// Correct it. Needed when AudioItem.roundTripLatency was wrong (unmeasured, or
	// stale after a buffer-size/interface change) at the moment this take was cut:
	// the stamp froze that value, and the stamp is what playback reads. Appends a
	// new archive version, anchors untouched; ^the version id.
	//   Take(\pf_260825_110649, 0).setRoundTripLatency(0.0514)
	setRoundTripLatency { |rt|
		^AudioItem.repinRoundTrip(this.name, num, rt)
	}
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
