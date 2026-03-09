MPV {
	*play {|path start end audio=true fullscreen=false|
		var endArg = end.isNil.if { "" } { "--end=% ".format(end) };
		"mpv" + audio.if{""}{"--no-audio"} + fullscreen.if{"--fs "}{" "} ++ "--start=% %%".format(start, endArg, path) => _.unixCmd
	}
}



// from Claude

Yoeminrak {
    classvar <video;
    classvar <sections, <secDur;
    // classvar <>particleVidOffset = 20;
     classvar <>particleVidOffset = 25.7;

    classvar <>env;
    classvar <>song;
    classvar <>muted;
    classvar <>dir = "/Users/michael/tank/super/Yoeminrak";

    *loadSongs {
        ^(PathName(dir) +/+ "songs").files.do { |e| e.fullPath.load };
    }

    *editSong { |songName|
        var songPath = PathName(dir) +/+ "songs" +/+ (songName.asString ++ ".scd");
        Nvim.e(songPath.fullPath);
    }

    *initClass {
        Class.initClassTree(aClass:Bus);
        Class.initClassTree(aClass:Env);
        Class.initClassTree(aClass:SinOsc);
        env = Environment.new;
        song = ();
        ServerTree.add({"pkill mpv".unixCmd});
        video = (
            particles: "'/Users/michael/tank/Hyojin/Video Sync/Media/여민락_2025__yeomillak-2025 (720p).mp4'",
            live: "'/Users/michael/tank/Hyojin/Video Sync/Media/1015_여민락_실연_full (720p).mp4'";
        );
        // sections = [
        //     -2.7,   // 0  forward arms up and down
        //     -1.3,   // 1  the same
        //     0,      // 2  to the right - crouch
        //     -3,     // 3  to the left and crouch
        //     -2.75,  // 4  to the rear
        //     -3.5,   // 5  spin and to the front
        //     -4,     // 6
        //     -8,     // 7
        //     -14,    // 8
        //     -23,    // 9
        //     -34,    // 10
        //     -44,    // 11
        //     -56,    // 12
        //     -67,    // 13
        //     -81,    // 14
        //     -94,    // 15
        //     -107,    // 16
        // ].collect{|i x| x * 52 + 6 + i };

        // corrected from frame_marks.json (secs 0-13); 14-16 unchanged
        sections = [
            -2.6633,  // 0  forward arms up and down
            -1.2432,  // 1  the same
            -0.2903,  // 2  to the right - crouch
            -3.8752,  // 3  to the left and crouch
            -2.8222,  // 4  to the rear
            -4.1381,  // 5  spin and to the front
            -5.5876,  // 6
            -7.0704,  // 7
            -14.2256, // 8
            -22.7487, // 9
            -33.4074, // 10
            -44.7668, // 11
            -56.6266, // 12
            -67.5189, // 13
            -81,      // 14
            -94,      // 15
            -107,     // 16
        ].collect{|i x| x * 52 + 6 + i };
        secDur = sections.differentiate.drop(1);
        this.loadEventTypes;
		this.filenameSymbol.asString.dirname +/+ "ornaments/ornaments.scd" => _.load;
        this.makeNoteEventType;
        
        Server.default.waitForBoot {
            env.use {
                // CmdPeriod.add({ env.use { ~instances = () } });
                CmdPeriod.add({ env.use { ~instances = (); ~currentInstance = nil } });
                ~know = true;
                ~instances = ();  // Stores active synth instances with their busses
                ~instanceCounter = 0;
                
                ~func = {
                    var s = Server.default;
                    var instance = Environment.new;
                    var synth;
                    
                    // Create busses for this instance
					instance.use{
						~root = Bus.control(s, 1).set(0);
						~ornament = Bus.control(s, 5).set(0);
						~chord = Bus.control(s, 5).setn([261.6255653006, 293.66476791741, 329.62755691287, 391.99543598175, 440.0]);
						~width = Bus.control(s, 5).setn(1.015 ! 5);
						~knum = Bus.control(s, 5).setn(2 ! 5);
						~select = Bus.control(s, 1).set(0.0);
						~ampDist = Bus.control(s, 5).set(0 ! 5);
						~durDist = Bus.control(s, 5).setn(1 ! 5);
						~ampDistParam = Bus.control(s, 5).setn(1 ! 5);
						~durDistParam = Bus.control(s, 5).setn(1 ! 5);
						~ampScale = Bus.control(s, 5).setn(0.5 ! 5);
						~durScale = Bus.control(s, 5).setn(0.5 ! 5);
						~amp = Bus.control(s, 5).setn([2, 2, 2, 1, 0.5]);
						~running = ();

						synth = {
							var freqLag = \freqLag.kr(3);
							[Gendy1, Gendy2, Gendy3].collect { |i|
								i.arWidth(
									ampdist: In.kr(~ampDist.index, 5),
									adparam: In.kr(~ampDistParam.index, 5),
									durdist: In.kr(~durDist.index, 5),
									ddparam: In.kr(~durDistParam.index, 5),
									durscale: In.kr(~durScale.index, 5),
									ampscale: In.kr(~ampScale.index, 5),
									freq: (In.kr(~root.index, 1).lag2(freqLag) + In.kr(~ornament.index, 5)).midiratio
									* In.kr(~chord.index, 5),
									width: In.kr(~width.index, 5),
									knum: In.kr(~knum.index, 5),
								) / 3
								* In.kr(~amp.index, 5)
							}
							=> SelectX.ar(In.kr(~select.index, 1), _)
							* Env.asr(0.5, 1, \release.kr(2)).kr(0, gate: NamedControl.kr(\gates, [1, 1, 1, 1, 1]))
							=> Splay.ar(_)
						}.play;

						~synth = synth;

						~ornamentZero.isNil.if {
							~ornamentZero = { DC.kr(0) ! 5 => Out.kr(~ornament.index, _) }.play(target: synth, addAction: \addBefore);
						};

						// Clean up busses when synth is freed
						synth.onFree {
							instance.use {
								~ornamentZero.free;
								~running.do { |r| try { r.free } };
								~root.free;
								~ornament.free;
								~chord.free;
								~width.free;
								~knum.free;
								~select.free;
								~ampDist.free;
								~durDist.free;
								~ampDistParam.free;
								~durDistParam.free;
								~ampScale.free;
								~durScale.free;
								~amp.free;
								"Instance busses freed".postln;
							};
						};
					};
					instance  // Return the whole instance
                };
                
                ~go = { |bus newPitch time=1 curve freqLag=0|
                    {
                        Env([In.kr(bus.index, bus.numChannels) => Latch.kr(_, 1) , newPitch], time, curve).kr(2, gate: 1).lag2(freqLag)
                        => Out.kr(bus.index, _)
                    }.play
                };
            }
        }
    }

    *playVid { |vid sec audio=false fullscreen=false length=1 start=0 end=5 syncBeats=false|
        var path = (vid == 0).if { video.at(\live) } { video.at(\particles) };
        sec.notNil.if {
            var vidOffset = vid * particleVidOffset;
            start = syncBeats.if {
                var marks = JSONlib.parseFile("/Users/michael/tank/Hyojin/Video Sync/frame_marks.json");
                var markIdx = (sec * 20) + start + 1;
                (marks[markIdx.asSymbol][\frame] / 29.97) + vidOffset
            } {
                sections[sec] + vidOffset
            };
            end = sections[sec + length] + vidOffset;
        };
        MPV.play(path, start, end, audio, fullscreen)
    }

    *addEventType { |name func|
        Event.addEventType(name, { ~dur = ~dur * secDur[~section ? 0] / 20 => _.postln } ++ func)
    }

    *loadEventTypes {
        var eventTypesPath = this.filenameSymbol.asString.dirname +/+ "eventTypes";
        var eventTypeFiles = PathName(eventTypesPath).files.select { |file|
            file.extension == "scd"
        };
        
        eventTypeFiles.do { |file|
            var fullPath = file.fullPath;
            if (File.exists(fullPath)) {
                fullPath.load;
                ("Loaded event type: " ++ file.fileName).postln;
            } {
                ("EventType file not found: " ++ fullPath).warn;
            };
        };
    }

    *initSong { |song, section, tempoEvents=true|
        (currentEnvironment[\yoeminrak] ? false).not.if{Yoeminrak.env.push};
        song = song ?? { env[\addMeSong] };
        section = section ?? { env[\addMeSection] ? 0 };
        this.song[song] = List[];
        env[\addMeSong]    = song;
        env[\addMeSection] = section;
        env[\preview]      = nil;
        (tempoEvents).if {this.addTempoEvents(section)};
    }

    *addTempoEvents { |section|
        var fps = 29.97;
        var marks = JSONlib.parseFile("/Users/michael/tank/Hyojin/Video Sync/frame_marks.json");
        var sec = section ?? { currentEnvironment[\addMeSection] ? 0 };
        var startMark = (sec * 20) + 1;
        var frameNums, deltas, expectedFrames, tempi;
        (marks[startMark.asSymbol].isNil or: { marks[(startMark + 20).asSymbol].isNil }).if {
            "addTempoEvents: incomplete marks for section % (marks %–%). Playing without tempo events.".format(sec, startMark, startMark + 20).warn;
        } {
            frameNums = (startMark .. startMark + 20).collect { |i| marks[i.asSymbol][\frame] };
            deltas = (0..19).collect { |i| frameNums[i+1] - frameNums[i] };
            expectedFrames = secDur[sec] / 20 * fps;
            tempi = (deltas / expectedFrames).reciprocal;
            tempi.do { |tempo beat|
                (beat: beat, extra: { TempoClock.tempo_(tempo); "TEMPO: %".format(tempo).postln }, type: \addMe).play;
            };
        };
    }

    *makeNoteEventType {
        Event.addEventType(type: \yoeNote, func: {
            ~dur = (~dur ? 1) * Yoeminrak.secDur[~section ? 0] / 20;
            ~type = ~freq.isKindOf(Number).if { \note.postln } { \rest.postln };
            currentEnvironment.play;
        }, parentEvent: nil)
    }

    *drumPbind { |start=0 end=15|
        ^[
            type: [0, 1, 0, 1, 2, 3].collect { |i| "yoeDrum" ++ i => _.asSymbol } => _.q(16),
            dur: [1, 5, 4, 4, 1, 5].q(16),
            section: (start..end).stutter(6).q
        ].p
    }

    *addDrum { |name params section|
        var inferredSection;
        song[name].isNil.if { song[name] = List[] };
        inferredSection = section ?? {
            song[name].collect { |i| i.section ? 0 } => { |x| x.maxItem { |item| x.occurrencesOf(item) } } ? 0
        };
        [
            section: inferredSection,
            type: [0, 1, 0, 1, 2, 3].collect { |i| "yoeDrum" ++ i => _.asSymbol },
            beat: [0, 1, 6, 10, 14, 15],
        ] ++ params
        => _.flop
        => _.collect { |i| i.asEvent }
        => _.do { |i| Yoeminrak.song[name].add(i) }
    }

    *drumArray { |section|
        ^[
            type: [
                [0, 1, 0, 1, 2, 3].collect { |i| "yoeDrum" ++ i => _.asSymbol },
                [\remove, \yoeRest ! 4, \yoeRest ! 3, \yoeRest ! 3, \remove, \yoeRest ! 5]
            ].lace(12).reject(_ == \remove).flat,
            dur: 1,
            section: section ? 0
        ]
    }

    *playSection { |sec=0|
        Yoeminrak.song[sec].keys.reject { |key| 
            (muted ? []).any { |i| key.asString.contains(i) }
        }.do { |i| Yoeminrak.song.at(sec, i).q.play }
    }

    *playSong { |sec=0|
        song[sec].keys.do { |key|
            song[sec][key].q.play
        }
    }
	*garland { |totalDur=5, initDur=0.5, numDivisions=7, curve = \exp|
		var durations;

		durations = switch(curve,
			\exp, {
				// We need: initDur * (r^0 + r^1 + r^2 + ... + r^(n-1)) = totalDur
				// Sum of geometric series: initDur * (r^n - 1) / (r - 1) = totalDur
				// Solve for r numerically
				var r, sum, target, n;
				n = numDivisions;
				target = totalDur / initDur;

				// Newton-Raphson to solve: (r^n - 1) / (r - 1) = target
				r = 1.5; // initial guess
				10.do {
					var f, fPrime;
					if(r == 1) { r = 1.001 }; // avoid division by zero
					f = ((r.pow(n) - 1) / (r - 1)) - target;
					// derivative of (r^n - 1)/(r - 1)
					fPrime = ((n * r.pow(n-1) * (r - 1)) - (r.pow(n) - 1)) / (r - 1).squared;
					r = r - (f / fPrime);
				};

				(0..n-1).collect { |i| initDur * r.pow(i) }
			},

			\linear, {
				// durations: initDur, initDur + d, initDur + 2d, ...
				// sum = n * initDur + d * (0 + 1 + 2 + ... + (n-1))
				// sum = n * initDur + d * n * (n-1) / 2 = totalDur
				// solve for d:
				var d, n;
				n = numDivisions;
				d = (totalDur - (n * initDur)) / (n * (n - 1) / 2);

				(0..n-1).collect { |i| initDur + (i * d) }
			},

			\sin, {
				// Approximate by scaling a sine curve
				// More complex to solve exactly, so we iterate
				var rawShape, scale, offset, result;
				var n = numDivisions;

				rawShape = (0..n-1).collect { |i|
					sin(i / (n-1) * 0.5pi)
				};

				// We want: offset + scale * rawShape[i] for each i
				// Constraints: offset = initDur (since sin(0) = 0)
				//              sum of all = totalDur
				// sum = n * offset + scale * rawShape.sum = totalDur

				offset = initDur;
				scale = (totalDur - (n * offset)) / rawShape.sum;

				(0..n-1).collect { |i| offset + (scale * rawShape[i]) }
			}
		);

		^durations
	}

	*terminalState { |eventList|
		var defaults = (
			root: 0,
			ornament: 0 ! 5,
			chord: [261.6255653006, 293.66476791741, 329.62755691287, 391.99543598175, 440.0],
			width: 1.015 ! 5,
			knum: 2 ! 5,
			select: 0.0,
			ampDist: 0 ! 5,
			durDist: 1 ! 5,
			ampDistParam: 1 ! 5,
			durDistParam: 1 ! 5,
			ampScale: 0.5 ! 5,
			durScale: 0.5 ! 5,
			amp: [2, 2, 2, 1, 0.5]
		);
		var busKeys = defaults.keys;
		var state = defaults.copy;
		var sorted = eventList.select { |e|
			e[\type] == \yoeString3
		}.sort { |a, b| (a[\beat] ? 0) <= (b[\beat] ? 0) };

		sorted.do { |event|
			// gates [0,0,0,0,0] kills the instance; next event creates fresh defaults
			(event[\gates] == [0, 0, 0, 0, 0]).if {
				state = defaults.copy;
			};

			busKeys.do { |key|
				event.includesKey(key).if { var value = event[key];
					case
					{ value.isNumber } {
						state[key] = value
					}
					{ value.isKindOf(Array) } {
						state[key] = value
					}
					{ value.isKindOf(Tuple3) } {
						// ~go envelope: current -> at1 over at2 with curve at3
						state[key] = value.at1
					}
					{ value.isKindOf(Tuple2) } {
						// setAt: partial update
						state[key] = state[key].copy;
						state[key][value.at1] = value.at2
					}
					// Functions (e.g. default Event's ~amp) are silently skipped
				};
			};

			event[\extra].notNil.if {
				("terminalState: extra function at beat " ++ (event[\beat] ? "?") ++ " may modify busses").warn
			};
		};

		^state
	}

	*chaseState { |eventList instance|
		var cursor = env[\cursor] ? 0;
		var eventsUpToCursor = eventList.select { |e| (e[\beat] ? 0) <= cursor };
		var state = this.terminalState(eventsUpToCursor);
		var inst = instance ?? { env[\currentInstance] };

		inst.notNil.if {
			inst.use {
				state.keysValuesDo { |key, value|
					var bus = inst[key];
					bus.notNil.if {
						value.isKindOf(Array).if {
							bus.setn(value)
						} {
							bus.set(value)
						}
					}
				}
			}
		} {
			"chaseState: no instance found in env[\\currentInstance]".warn
		}
	}
}


+ Array {
	addType { |type|
		^this.collect{
			|i| i.isKindOf(Event).if{
				i.put(\type, type)
			}{
				i.collect{|j| j.put(\type, type)}
			}
		}
	}
    jgb_slots { |section key|
        var slots = (type:\yoeRest) ! 20;
        this.flop.collect(_.asEvent).do {|e| slots.put(e.beat, e)};
        Yoeminrak.song.put(section ? 0, (key ? \current), slots);
        ^slots
    }

    jgb {
		var events = this.flop.collect { |i| 
			(i.flop.size > 1).if {
				i.flop.collect { |subArray x|
					var event = subArray.asEvent;
					event.put(\dur,1/3);
					event.asKeyValuePairs;
				}
			} {
				i ++ [dur:1] =>_.bubble
			}}.flatten
			.deepCollect(2, {|i| i.isKindOf(Ref).if{i.value}{i}})
			// .collect {|i x| i ++ [beat: x] => _.asEvent};
			.collect (_.asEvent);

			// Now add beat positions by accumulating durations
			var beat = 0;
			^ events.collect { |event|
				var thisEvent = event.put(\beat, beat);
				beat = beat + event[\dur];
				thisEvent
			};

    }
	add20 { |section|
		var counter=0;
		this.do{|i|
			if (i.isKindOf(Array)) {
                var size = i.size;
                "ADD 1/3".postln;
				i.do {|j x|
					j.put(\beat, counter);
					counter = counter + size.reciprocal
				}
			} {
                "ADD 1".postln;
				i.put(\beat, counter);
				counter = counter + 1;
			}
		};
		Yoeminrak.song[section].debug("SECTION").isNil.if{ Yoeminrak.song[section]=List[]};
        Yoeminrak.song[section].addAll(this.flat)
	}
    jgbq {
        ^this.jgb.q
    }
    jgbp { |section key|
		Yoeminrak.song[section].isNil.if {Yoeminrak.song[section] = List[]};
        this.jgb.do {|i| Yoeminrak.song[section].add(i)};
		^Yoeminrak.song[section]
    }
    tracker {
        var columns = this[0].size;
        ^[this[0],this[1].clump(columns).flop].lace
    }
}
+ SequenceableCollection {
	yPlay { |cursor=0 section=0 solo continue=false|
        // CmdPeriod.run;
		// Yoeminrak.env[\synth].free;
		fork{
            Server.default.sync;
			solo.notNil.if{
				this.select{ |i| i.type.isNil.if{false}{i.type.contains(solo.asString) }}
			}{
				this
			}
			.do {|i|
                if (i.beat >= cursor) {
                    TempoClock.sched(Yoeminrak.secDur[section] / 20 * (i.beat - cursor), {i.copy.play})
                }
            }
        }
	}
}
+ SequenceableCollection{
	play { |cursor=0 section solo continue=false|
        // CmdPeriod.run;
		// Yoeminrak.env[\synth].free;
		// fork{
            // Server.default.sync;
			solo.notNil.if{
				this.select{ |i| i.type.isNil.if{false}{i.type.contains(solo.asString) }}
			}{
				this
			}
			.do {|i|
                var copy = i.copy;
                if (i.beat >= cursor) {
                    TempoClock.sched(Yoeminrak.secDur[section ? i.section ? 0] / 20 * (i.beat - cursor), {copy.play})
                }
            }
        // }
	}
}
+ Pattern {
    jgb {
        ^Prout({ |ev|
            var stream = this.asStream;
            var event;
            while {
                event = stream.next(ev);
                event.notNil;
            } {
                var freq = event[\freq];
                var originalDur = event[\dur] ? 1;
                if(freq.isArray and: { freq.isKindOf(Ref).not }) {
                    var n = freq.size;
                    n.do { |i|
                        var newEvent = event.copy;
                        newEvent.keysValuesDo { |k, v|
                            if(v.isArray and: { v.size == n } and: { v.isKindOf(Ref).not }) {
                                newEvent[k] = v[i];
                            };
                        };
                        newEvent[\dur] = originalDur / n;
                        ev = newEvent.yield;
                    };
                } {
                    if(freq.isKindOf(Ref)) { event[\freq] = freq.value };
                    ev = event.yield;
                };
            };
        });
    }
}
+ Pbind {
    eventsWithBeats { |n=10, protoEvent|
        var stream = this.asStream;
        var events = List.new;
        var beat = 0;
        var event;
        
        protoEvent = protoEvent ?? Event.default;
        
        n.do {
            event = stream.next(protoEvent.copy);
            if(event.isNil) { 
                ^events.asArray 
            };
            event.put(\beat, beat);
            beat = beat + (event[\dur] ?? 1);
            events.add(event);
        };
        
        ^events.asArray
    }
    fmtValue { |v| //make Tuples display right
        ^case
            { v.isKindOf(Symbol) } { "\\" ++ v }
            { v.class.name.asString.beginsWith("Tuple") } {
                "T(" ++ v.storeArgs.collect({ |a| this.fmtValue(a) }).join(", ") ++ ")"
            }
            { v }
    }
    insertEventsWithBeats { |n=10, protoEvent|
        this.eventsWithBeats(n, protoEvent).do { |event|
            var sorted = event.collect({ |v| this.fmtValue(v) });
            var pairs = sorted.asSortedArray;
            var beatPair = pairs.detect({ |p| p[0] == \beat });
            var rest = pairs.reject({ |p| p[0] == \beat });
            var str = "(" ++ ([beatPair] ++ rest).collect({ |p|
                p[0] ++ ": " ++ p[1]
            }).join(", ") ++ ")";
            Nvim.insert(str);
            Nvim.nextLine;
        }
    }
    asEvents { |max = 100|
        var stream = this.asStream;
        var events = [];
        var time = 0;
        
        max.do {
            var ev = stream.next(Event.default);
            if(ev.isNil) { ^events };
            ev[\beat] = time;
            time = time + (ev[\dur] ?? 1);
            events = events.add(ev);
        };
        
        ^events
}

dropTime { | beats=2, section=0 |
    var scale = Yoeminrak.secDur[section] / 20;
    ^Prout { |inval|
        var stream = this.asStream;
        var totalDur = 0;
        var event;

        while { totalDur < ( beats * scale ) } {
            event = stream.next(inval);
            if (event.isNil) { nil.yield };
            totalDur = totalDur + (event[\dur] ?? 1) ;
        };

        // if we overshot, insert a rest for the overlap (in pattern time)
        if (totalDur > ( beats * scale )) {
            (type: \rest, dur: (totalDur - (beats * scale)) , latency: 0).yield;
        };

        loop {
            event = stream.next(inval);
            if (event.isNil) { nil.yield };
            event.yield;
        }
    }
}
}


