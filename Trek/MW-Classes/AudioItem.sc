AudioItem {
	classvar <>all, <folder, <buffers, <recorders;
	classvar <recordedMaps; // (item, take) -> record-time clock stamp (§9a step 2)
	/*
	 Measured input+output round trip of the current audio-device configuration.
	 Mic overdubs land this LATE in the file relative to the grid — latencies ADD.
	 Captured into each record-time stamp and applied by stamp-based playback resolution
	 \raw convention: the file is never trimmed; compensation is a read-side offset.

	 The measurement is per-rig and lives on AudioInterface. The two accessors below
	 read through AudioInterface.current and fall back to these globals when the
	 booted device is unregistered or unmeasured. Measure with
	 AudioInterface.current.measure.
	 */
	classvar <>fallbackRoundTrip = 0;
	classvar <>fallbackOutputLatency = 0;
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
			/* `name` belongs to EventList's label/voice namespace (and Symbol.add
			   always writes it). `item` is the audio asset; fall back to name so old
			   event lists continue to play. */
			var itemName = AudioItem.eventItemName(currentEnvironment);
			var directory = folder +/+ itemName;
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
			var buffer = buffers.at(itemName.asSymbol, takeNum);
			var recorder = Recorder(Server.default);
			// dur the user actually set, ignoring the (dur: 5) parent default —
			// own keys don't consult the parent chain
			var userDur = currentEnvironment.keys.includes(\dur).if { ~dur };

			// Create buffer if it doesn't exist
			buffer = buffer ?? {
				buffers.put(itemName.asSymbol, takeNum, Buffer());
				buffers.at(itemName.asSymbol, takeNum);
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
					// the round trip is per-rig (pinned in startup.scd, in no repo) and
					// the stamp written below freezes it forever. Recording on an
					// unmeasured rig therefore stamps 0 and the take plays uncompensated
					// for the rest of its life
					(AudioItem.roundTripLatency == 0).if {
						"AudioItem: round trip is 0 — % will be stamped with no latency "
						"compensation. Measure this rig first: %.measure"
						.format(itemName,
							AudioInterface.current ?? "AudioInterface(\\yourRig)").warn
					};
					// restarting an item that is still recording closes the old take first
					recorders[itemName.asSymbol] !? {|r| r.isRecording.if { r.stopRecording } };
					recorders[itemName.asSymbol] = recorder;
					~recorder.recHeaderFormat_(format).recSampleFormat_(AudioItem.sampleFormatFor(format));
					~recorder.prepareForRecord(~path, nc);
					Server.default.bind{
						// no dur given -> record until AudioItem.stopRecording(item) or Cmd-.
						// dur given -> record recTail (default 5s) beyond it in case a tail is needed
						~recorder.record(~path, ~in ? Server.default.options.numOutputBusChannels, nc,
							duration: userDur !? (_ + (~recTail ? 5)))
					};
					// invalidate cached buffer so next playback reloads from disk
					buffers.put(itemName.asSymbol, takeNum, Buffer());
					// record-time clock stamp from EventList.prEmit (§9a step 2):
					// remembers what this take was recorded against, so playback
					// can resolve the true source clock even if the list's map
					// changes (e.g. destructive quantize)
					~recordedAgainst !? { |stamp|
						AudioItem.recordedMaps.put(itemName.asSymbol, takeNum, stamp);
						// persist as a v2 retune-archive version (anchors +
						// recordedAgainst) so the stamp survives sclang restarts;
						// a write failure only warns — never aborts the recording
						TakeArchive.writeStamp(itemName, takeNum, stamp);
					};
				}
            } {
                File.exists(path).if {
                    // build the effect (if ~out is a thunk) BEFORE the bundle — Effect.bus
                    // allocates a Bus, sends its own SynthDef and spawns a synth, none of
                    // which can happen during this graph's compilation inside makeBundle.
                    var outBus = (~out ? 0).value;
                    // \raw latency convention — the SAME origin the tempo-follow path
                    // now applies on every branch of prSrcOffset: a mic take is never
                    // trimmed on disk, so its content sits t0 LATE in the file
                    // relative to the grid the record event fired on. Compensation is a
                    // READ-side offset, added to the user's ~start. Only takes carrying
                    // a record-time stamp are shifted — imported / hand-placed files
                    // have no stamp and stay at face value. t0 reads through
                    // recordedMap, which caches, so the archive read happens once per
                    // take; it must not build a Take (Buffer.read inside this send is
                    // exactly the late-bundle bug that caching fixed).
                    // prEventT0, not t0: honours sourceMapIsPhysical like the
                    // follow path, so the two paths agree on every event.
                    var t0 = AudioItem.prEventT0(currentEnvironment, takeNum);
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
                                    startPos: ((~startPos ? 0) + t0) * Server.default.sampleRate
                                )
                                * (~amp ? 1)
                                => Out.ar(outBus, _)
                            }.play
                        }
                    )
                } {
                    "AudioItem: no file for item % at %".format(itemName, path).warn
                }
            }
		}, (dur:5)
	);
	}
	*cmdPeriod {
		armed = false
	}

	/* Preferred AudioItem event identity. `name` remains a compatibility fallback
	   for saved lists written before `item` separated the asset from the label. */
	*eventItemName { |ev|
		^ev[\item] ?? {
			ev[\name] ?? { Error("AudioItem event requires item (or legacy name)").throw }
		}
	}

	/* The booted rig's measured round trip, or the legacy global when the device is
	   unregistered / unmeasured. Read by the record path and by EventList.prEmit,
	   which freezes it into each take's record-time stamp. */
	*roundTripLatency {
		^(AudioInterface.current !? { |i| i.roundTrip }) ?? { fallbackRoundTrip }
	}
	/* Old startup.scd pins assign this. Keeps them working as a machine-wide default;
	   a per-device AudioInterface pin takes precedence over it. */
	*roundTripLatency_ { |rt| fallbackRoundTrip = rt }

	/* The OUTPUT leg alone (seconds) — what MIDI capture needs. A performer aims at
	   what reached their ears, which is roundTrip's output half beyond the server
	   sound domain EventList's play epoch is expressed in; the press itself carries
	   no AUDIO input latency (no ADC, no input buffer), so MIDI must not use the full
	   round trip. Audio capture is the opposite case and correctly uses the whole
	   trip: the voice lands L_in late in the file AND referenced monitoring that was
	   L_out late, and those add.
	   MIDI does have an input latency of its own — key scan, USB polling, CoreMIDI
	   delivery — but it is small, controller-specific, unmeasurable by loopback, and
	   partly trained out by the performer, so it is left uncompensated here. */
	*outputLatency {
		^(AudioInterface.current !? { |i| i.outputLatency }) ?? { fallbackOutputLatency }
	}
	*outputLatency_ { |l| fallbackOutputLatency = l }

	/* Deprecated: latency is per-device now. Forwards to the booted interface so the
	   old call keeps doing the right thing, and names the replacement. */
	*measureRoundTrip { |in = 0, out = 0, amp = 0.5, dur = 0.5, write = true, action,
		outputShare|
		var i = AudioInterface.current;
		i.isNil.if {
			^"AudioItem.measureRoundTrip: the booted out device (%) is not a registered "
			"AudioInterface. Register it first:\n    AudioInterface(\\myrig, %, nil, 2)"
				.format(Server.default.options.outDevice ? "system default",
					(Server.default.options.outDevice ? "").asCompileString).warn
		};
		"AudioItem.measureRoundTrip is deprecated — use AudioInterface(%).measure"
			.format(i.key.asCompileString).postln;
		^i.measure(in, out, amp, dur, write, action, outputShare)
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
		var found = TakeArchive.latestWhere(name, takeNum, { |d| TakeArchive.isStamp(d) });
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
		v = TakeArchive.write(name, takeNum, d);
		// force the next recordedMap to reload from disk
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
					"AudioItem.takeOnset(%, %): % s   (peak %, round trip %)"
						.format(name, takeNum, t.round(1e-5), peak.round(1e-5),
							AudioItem.roundTripLatency).postln
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
	// consulted (TakeArchive.loadStamp — the anchors-serialized form survives
	// sclang restarts) and cached back here so the disk scan runs once per take.
	*recordedMap { |name, takeNum|
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
				TakeArchive.loadStamp(name, takeNum) !? { |stamp|
					recordedMaps.put(name.asSymbol, takeNum, stamp);
					stamp
				} ?? {
					recordedMaps.put(name.asSymbol, takeNum, \none);
					nil
				}
			}
		}
	}

	/* The file second at which a take's musical ZERO sits — the frame origin every
	   LIST playback path reads from. For a stamped mic take that is the round trip
	   frozen into its stamp: the file is never trimmed (\raw convention), so the
	   content sits roundTrip LATE relative to the grid the record event fired on,
	   and compensation is a read-side offset. 0 for an imported or hand-placed
	   file with no stamp — those keep the face-value rule and are never shifted.

	   Deliberately a CLASS method taking (name, takeNum), NOT Take.t0: the
	   playback path must not construct a Take, because Take.new calls Buffer.read
	   — an async server allocation — whenever the buffer is uncached, and the
	   sealed \audioItem branch runs inside the event's send, which EventList.fire
	   runs only `latency` ahead of the sound. recordedMap caches (negatively
	   too), so after the first call this is a dictionary lookup.

	   Take.roundTripLatency names the same number as the RIG measurement the
	   stamp froze, and stays valid as such; t0 names the take's origin,
	   which is what consumers actually want, and answers 0 rather than nil. */
	*t0 { |name, takeNum|
		^(this.recordedMap(name, takeNum) !? { |st| st[\roundTrip] ? 0 }) ? 0
	}

	/* t0 for an EVENT: 0 when its map already includes the recording latency
	   (sourceMapIncludesLatency: true — a map drawn on the waveform, i.e. in file
	   positions), else the take's origin. `sourceMapIsPhysical:` is the old name,
	   still read. The sealed \audioItem path uses this; the follow path gets the same
	   answer from prResolveSourceMap. */
	*prEventT0 { |ev, takeNum|
		((ev[\sourceMapIncludesLatency] ?? { ev[\sourceMapIsPhysical] } ? false) == true).if { ^0 };
		^this.t0(ev[\item] ?? { ev[\name] }, takeNum)
	}

	/* The ONE place that decides a tempo-follow event's source clock — "which beat
	   is at which file second" (audio-beat-marking-plan.md step 8). Everything
	   downstream (prSrcOffset, prSrcEndBeat, the two tempoFollow builders) reads only
	   what this answers. Order:
	     sourceTempoMap: a map object      as given (a MonoMap is converted once)
	     sourceTempoMap: \marks            the take's marks (TakeGui w / W); newest,
	                                       or marksVersion: N
	     sourceTempoMap: \stamp            the record stamp
	     sourceTempoMap: \eventList        the list's base clock
	     sourceTempoMap: \flat             sourceBeatDur (or 1 s/beat)
	     no sourceTempoMap, sourceBeatDur:  \flat
	     neither                           \stamp if the take has one, else \eventList
	   A named source the take lacks warns and falls through to the default.
	   `marks:` (step 6) is read as sourceTempoMap: \marks + marksVersion, with a
	   warning.

	   Answers a copy of the event with
	     srcMap                an AnchorTempoMap-protocol map (item frame: its first
	                           beat sounds at when:), or nil = the list's base clock
	     srcLatencyIncluded    true when the map's seconds are file positions (marks),
	                           so the take's t0 must not be added
	     srcTrim               seconds after the origin to skip (start: on \marks)
	   plus: start: = the origin (first mark's file second) for \marks, and dur: cut to
	   toBeat - fromBeat. Idempotent (srcResolved). */
	// Event keys that choose or shape the source clock. Any of them on an \audioItem
	// event routes it to the tempo-follow path (EventList.prIsAudioFollow).
	*timingKeys { ^#[\sourceTempoMap, \sourceBeatDur, \marksVersion, \fromBeat, \toBeat, \align, \marks] }

	*prResolveSourceMap { |ev, itemName, takeNum|
		var out, sm, name, m, latIn = false, trimMode = false;
		(ev[\srcResolved] == true).if { ^ev };
		out = ev.copy;
		out[\srcResolved] = true;
		itemName = itemName ?? { this.eventItemName(ev) };
		sm = ev[\sourceTempoMap];
		(ev[\marks].notNil and: { ev[\marks] != false }).if {
			"AudioItem: marks: is replaced by sourceTempoMap: \\marks (and marksVersion: N)".warn;
			sm = sm ? \marks;
			(ev[\marks] != true).if { out[\marksVersion] = out[\marksVersion] ? ev[\marks] };
		};
		// a Function: evaluated with .use in an environment offering the take's
		// sources as file-seconds MonoMaps (prSourceEnvir); it answers the map
		sm.isKindOf(Function).if {
			var fn = sm, envir = this.prSourceEnvir(ev, itemName, takeNum), result;
			result = { envir.use { fn.value } }.try { |err|
				"AudioItem: sourceTempoMap function failed (%) — using the default"
					.format(err.errorString).warn;
				nil
			};
			sm = nil;
			(result.notNil and: { result.respondsTo(\timeAt) }).if {
				m = result.isKindOf(MonoMap).if { result.asAnchorTempoMap } { result };
				name = \function; latIn = true; trimMode = true;
			} {
				result.notNil.if {
					"AudioItem: sourceTempoMap function answered % (not a map) — using the default"
						.format(result.class).warn
				}
			}
		};
		(name == \function).not.if { name = sm.isKindOf(Symbol).if { sm } {
			sm.isNil.if {
				ev[\sourceBeatDur].notNil.if { \flat } {
					this.prStampMap(itemName, takeNum).notNil.if { \stamp } { \eventList }
				}
			}
		};
		name.isNil.if {
			// a map object
			m = sm.isKindOf(MonoMap).if { sm.asAnchorTempoMap } { sm };
			latIn = (ev[\sourceMapIncludesLatency] ?? { ev[\sourceMapIsPhysical] } ? false) == true;
		} {
			switch(name,
				\marks, {
					var mk = TakeArchive.loadMarks(itemName, takeNum, out[\marksVersion]);
					mk.isNil.if {
						"AudioItem: % take % has no marks version % — using the default source"
							.format(itemName, takeNum, out[\marksVersion] ? "").warn;
					} {
						m = AnchorTempoMap(mk[\anchors].collect(_[\src]), mk[\anchors].collect(_[\beat]));
						latIn = true;
						trimMode = true;
					}
				},
				\stamp, {
					m = this.prStampMap(itemName, takeNum);
					m.isNil.if { "AudioItem: % take % has no record stamp — using the list clock"
						.format(itemName, takeNum).warn };
				},
				\flat, { m = this.prFlatMap(ev[\sourceBeatDur] ? 1) },
				\eventList, { m = nil },
				{ "AudioItem: unknown sourceTempoMap: % — using the default".format(name.cs).warn;
					name = \unknown }
			);
			// a named source that isn't there falls through to the default
			(m.isNil and: { name != \eventList }).if {
				ev[\sourceBeatDur].notNil.if {
					m = this.prFlatMap(ev[\sourceBeatDur]); name = \flat
				} {
					m = this.prStampMap(itemName, takeNum);
					name = m.notNil.if { \stamp } { \eventList }
				};
				latIn = false; trimMode = false;
			};
		};
		};   // end: not a function
		out[\srcMap] = m;
		out[\srcLatencyIncluded] = latIn;
		out[\srcName] = name ? \map;   // what actually resolved (for warnings and tests)
		trimMode.if {
			// start: trims (seconds after the origin), never shifts the source against
			// the beats; the origin is the first mark's file second
			(ev[\start] ? ev[\startPos] ? 0) !? { |s| (s != 0).if { out[\srcTrim] = s } };
			out[\start] = m.t0;
			out[\startPos] = nil;
		};
		ev[\toBeat] !? { |t|
			var d = t - (ev[\fromBeat] ? 0);
			out[\dur] = ev[\dur].notNil.if { ev[\dur].min(d) } { d };
		};
		(ev[\fromBeat].notNil and: { out[\srcTrim].notNil }).if {
			"AudioItem: both fromBeat: and start: on % — the later start point wins".format(itemName).warn
		};
		^out
	}

	/* The environment a Function sourceTempoMap: runs in (plan step 10). Every
	   candidate is a MonoMap in ONE frame — beat -> FILE seconds — so the whole
	   MapEditor vocabulary works on it (quantize(amount, from, to), curve,
	   ritardSpan, setBpm(bpm, from, to), transformSpan) and whatever the function
	   answers is already in file seconds:
	     ~marks   the marks version (newest, or marksVersion:), beats from 0 at the
	              first mark; nil when the take has none
	     ~stamp   the record stamp, beats from 0 at the record event's fire beat,
	              seconds plus the take's t0 (the stamp is stored without the
	              recording latency, \raw); nil when unstamped
	   The event's own keys (~item, ~take, ~when, ...) read through the proto.
	   The two beat axes start at different places until marks on stamped takes
	   are written in list beats (step 11) — combine them with that in mind. */
	*prSourceEnvir { |ev, itemName, takeNum|
		var envir = (), mk, st, mono;
		mk = TakeArchive.loadMarks(itemName, takeNum, ev[\marksVersion]);
		mk !? {
			envir[\marks] = AnchorMap.fromAnchors(mk[\anchors].collect(_[\beat]),
				mk[\anchors].collect(_[\src]), fromFrame: \beat, toFrame: \sec)
		};
		st = this.prStampMap(itemName, takeNum);
		st !? {
			mono = st.asMonoMap(origin: \absolute);
			envir[\stamp] = AnchorMap.fromAnchors(mono.xs, mono.ys + this.t0(itemName, takeNum),
				fromFrame: \beat, toFrame: \sec)
		};
		envir.proto = ev;
		^envir
	}

	// The take's record stamp as a map (item frame: beat 0 = the record event's
	// fire beat, seconds from there, latency NOT included). Disk stamps already
	// carry one; an in-memory stamp (this session's recording) is sampled once
	// through the same serializer the disk form was written with
	// (TakeArchive.prStampAnchors) and cached on the stamp, so both forms answer
	// the same map.
	*prStampMap { |itemName, takeNum|
		var st = this.recordedMap(itemName, takeNum), a;
		st.isNil.if { ^nil };
		st[\map].isNil.if {
			a = TakeArchive.prStampAnchors(st);
			st[\map] = AnchorTempoMap(a.collect(_[\src]), a.collect(_[\beat]));
		};
		^st[\map]
	}

	// d seconds per beat, as a two-anchor map (\carry extrapolates it forever)
	*prFlatMap { |d| ^AnchorTempoMap([0, d], [0, 1]) }

	// Ideal beat -> elapsed seconds into the source recording, for a tempo-follow
	// event (quantize-tempomap-project.md §9b). The CLOCK comes from
	// prResolveSourceMap — this only reads it. The take's frame origin (t0) is
	// applied uniformly inside the returned closure unless the map includes the
	// latency, so every consumer (tempoFollowActions' endSec, fromSec and its in-loop
	// sourceBFull; the env twin) inherits it with no call-site edit. fromBeat: shifts
	// the source's beat axis so source beat fromBeat sounds at when: (b0) — trim and
	// rebase, as MIDI's player.fromBeat. prSrcEndBeat is the exact inverse.
	*prSrcOffset { |ev, list, b0, takeNum|
		var r = this.prResolveSourceMap(ev, nil, takeNum);
		var sm = r[\srcMap], fb = r[\fromBeat] ? 0;
		var t0 = r[\srcLatencyIncluded].if { 0 } { this.t0(this.eventItemName(r), takeNum) };
		sm.notNil.if {
			var bd = sm.beatDomain.first, mapT0 = sm.timeDomain.first;
			^{ |bt| t0 + (sm.timeAt(bd + fb + (bt - b0)) - mapT0) }
		};
		// the list's base clock (no stamp, so t0 is 0 here by construction)
		^{ |bt| t0 + list.baseWallDelta(b0, bt + fb) }
	}
	// Inverse of prSrcOffset for the no-\dur case: the beat at which the source
	// position reaches endSec. The origin comes off the target ONCE, here, mirroring
	// prSrcOffset adding it once inside the closure — so
	//     startSec + prSrcOffset.(prSrcEndBeat.(..., endSec)) == endSec.
	*prSrcEndBeat { |ev, list, b0, startSec, endSec, takeNum|
		var r = this.prResolveSourceMap(ev, nil, takeNum);
		var sm = r[\srcMap], fb = r[\fromBeat] ? 0;
		var t0 = r[\srcLatencyIncluded].if { 0 } { this.t0(this.eventItemName(r), takeNum) };
		var rel = endSec - startSec - t0;
		sm.notNil.if {
			^b0 + (sm.beatAt(sm.timeDomain.first + rel) - sm.beatDomain.first) - fb
		};
		list.tempoMap.notNil.if {
			^list.tempoMap.beatAt(list.tempoMap.timeAt(b0) + rel) - fb
		};
		^b0 + (rel / (list.beatDur ? TempoClock.default.beatDur)) - fb
	}

	// wallAt: optional { |beat| -> wall-seconds } overriding list.beatToWall — the §10
	// `place` seam. Returned delays stay relative to wallAt(from), so absolute-time
	// callers (EventList.prEmit) add place.(from) back on.
	*tempoFollowActions { |ev, list, tempoEnv, from = 0, wallAt|
		var itemName = this.eventItemName(ev);
		var directory = folder +/+ itemName;
		var takeNum = ev[\take] ?? { AudioItem.latestTake(directory) };
		var path = AudioItem.takePath(directory, takeNum);
		var buffer, sf, sourceDur, srcOffset, b0, startSec, endSec;
		var segBeats, fade, fromBeat, fromSec, actions, beat, lastBeat;
		var wallFrom, srcCarry, wallCarry, align, baseWallAt;

		File.exists(path).not.if {
			"AudioItem tempoFollow: no file at %".format(path).warn;
			^List[]
		};

		buffer = buffers.at(itemName.asSymbol, takeNum) ?? {
			buffers.put(itemName.asSymbol, takeNum, Buffer());
			buffers.at(itemName.asSymbol, takeNum)
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
		ev = this.prResolveSourceMap(ev, itemName, takeNum);

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
		wallFrom = wallAt.(from);
		/* align: 0..1 (audio-beat-marking-plan.md step 9) — the quantize strength.
		   1 = every beat of the source map on its list beat (plain follow), 0 = the
		   take as performed (source at rate 1 from the anchor), in between a blend.
		   Same sense as prExpandBlended's align on nested lists: the WALL time of each
		   source beat is blended — (anchor + its performed offset).blend(its list
		   beat's wall time) — never the source position at a fixed list beat. */
		align = ev[\align];
		align.notNil.if {
			var anchorW = wallAt.(b0), s0 = srcOffset.(b0), lo, hi;
			baseWallAt = wallAt;
			wallAt = { |bt| (anchorW + (srcOffset.(bt) - s0)).blend(baseWallAt.(bt), align) };
			// mid-list start: the source beat whose BLENDED time is list beat `from`'s
			// wall time — bisected, as prBisectBeat does (the blend has no closed form)
			(from > b0).if {
				lo = b0; hi = b0 + 1;
				while { (wallAt.(hi) < wallFrom) and: { (hi - b0) < 1e6 } } { lo = hi; hi = b0 + ((hi - b0) * 2) };
				40.do { var mid = (lo + hi) * 0.5; (wallAt.(mid) < wallFrom).if { lo = mid } { hi = mid } };
				fromBeat = hi;
			};
		};
		// start: on a trim-mode source (\marks): skip the audio before origin + start,
		// every beat staying where the map puts it
		ev[\srcTrim] !? { |s|
			fromBeat = fromBeat.max(AudioItem.prSrcEndBeat(ev, list, b0, startSec, startSec + s, takeNum))
		};
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
		// wallFrom = the real wall time of list beat `from` (set above, before any
		// align blend), so delays stay relative to where the list actually is
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
		var itemName = this.eventItemName(ev);
		var directory = folder +/+ itemName;
		var takeNum = ev[\take] ?? { AudioItem.latestTake(directory) };
		var path = AudioItem.takePath(directory, takeNum);
		var buffer, sf, sourceDur, srcOffset, b0, startSec, endSec;
		var fromBeat, fromSec, lastBeat, points, levels, times, curves;
		var totalSourceDur, wallDur, tempoPoints, curBeat, segEnds, actions;

		File.exists(path).not.if {
			"AudioItem tempoFollow env: no file at %".format(path).warn;
			^List[]
		};

		buffer = buffers.at(itemName.asSymbol, takeNum) ?? {
			buffers.put(itemName.asSymbol, takeNum, Buffer());
			buffers.at(itemName.asSymbol, takeNum)
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
		ev = this.prResolveSourceMap(ev, itemName, takeNum);
		// the env path uses the source map only at its two endpoints and takes its
		// rate from tempoEnv, so a marked take's beat-to-beat corrections are lost
		ev[\align].notNil.if {
			"AudioItem: align: is ignored on tempoFollowMode: \\env — use the default segment mode".warn
		};
		(ev[\srcName] == \marks).if {
			"AudioItem: sourceTempoMap: \\marks is ignored between its endpoints on "
			"tempoFollowMode: \\env — use the default segment mode".warn
		};

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
		// start: on a trim-mode source (\marks): skip the audio before origin + start,
		// every beat staying where the map puts it
		ev[\srcTrim] !? { |s|
			fromBeat = fromBeat.max(AudioItem.prSrcEndBeat(ev, list, b0, startSec, startSec + s, takeNum))
		};
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
		Nvim.replace( "(type: \\audioItem, item: \"%\")".format(name ++ "_" ++  Date.getDate.stamp) )
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
	/* `name` and `buffer` belong to AudioItem (`var <>name, <>buffer, ...`).
	   Re-declaring them here allocated SECOND storage slots: Take.instVarNames
	   answered ten names with `name` at 0 and 7 and `buffer` at 1 and 9. sclang
	   resolves a bare instance-variable read to the FIRST match, so every read and
	   write in the tree — including playbuf's bare `buffer` — already went to the
	   inherited slots, and 7/9 were dead storage that only newCopyArgs, instVarAt,
	   .copy and archiving could ever reach. Dropped: one name, one buffer. */
	var <>num;
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
	/* The take's beat-marked tempo map: an AnchorTempoMap (beat -> FILE seconds)
	   over the newest marks version (TakeGui w / W), or version `version`; nil when
	   the take has none. Like every AnchorTempoMap it is rebased to 0 on both axes
	   with the first anchor's file second kept as t0 — so a consumer reading the
	   file must start at map.t0, not at timeDomain.first (always 0). */
	tempoMap { |version|
		var m = TakeArchive.loadMarks(this.name, num, version);
		^m !? { AnchorTempoMap(m[\anchors].collect(_[\src]), m[\anchors].collect(_[\beat])) }
	}
	/* A Take is its own player, so EventList.addItem's opening `player.player`
	   accepts it — mirrors MIDIItemPlayer.player. Deliberately NO recordWall:
	   EventList.prItemBeat calls recordPlayEpoch unconditionally once recordWall
	   answers, so a scalar here would break itemStartBeat. Recorded placement
	   (at: nil, at: \original) stays deferred — see
	   audioitem-placement-proposal.md §3. */
	player { ^this }
	// The round trip this take was recorded against — what playback compensates by
	// (\raw convention). nil when the take carries no record stamp, e.g. an
	// imported file: those are read at face value and never shifted.
	roundTripLatency {
		^AudioItem.recordedMap(this.name, num) !? { |st| st[\roundTrip] ? 0 }
	}
	/* The file second at which this take's musical zero sits — the origin every
	   list playback path reads from. Same number as roundTripLatency for a stamped
	   mic take, but 0 (not nil) for an unstamped one, and named for what it means
	   to a consumer rather than for how it was measured. The playback path calls
	   AudioItem.t0 directly: building a Take there would hit Buffer.read. */
	t0 { ^AudioItem.t0(this.name, num) }
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
