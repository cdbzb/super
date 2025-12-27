MPV {
	*play {|path start end audio=true fullscreen=false|
		"mpv" + audio.if{""}{"--no-audio"} + fullscreen.if{"--fs "}{" "} ++ "--start=% --end=% %".format(start, end, path) => _.unixCmd
	}
}

Yoeminrak {
    classvar <video;
    classvar <sections, <secDur;
    classvar <>particleVidOffset = 20;
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
        sections = [
            -2.7,   // 0  forward arms up and down
            -1.3,   // 1  the same
            0,      // 2  to the right - crouch
            -3,     // 3  to the left and crouch
            -2.75,  // 4  to the rear
            -3.5,   // 5  spin and to the front
            -4,     // 6
            -8,     // 7
            -14,    // 8
            -23,    // 9
            -34,    // 10
            -44,    // 11
            -56,    // 12
            -67,    // 13
            -81,    // 14
            -94,    // 15
            -76,    // 16
        ].collect{|i x| x * 52 + 6 + i };
        secDur = sections.differentiate.drop(1);
        this.loadEventTypes;
        this.makeNoteEventType;
        
        Server.default.waitForBoot {
            env.use {
                CmdPeriod.add({ env.use { ~instances = (); ~currentInstance = nil; ~releasing = List[] } });
                ~know = true;
                ~instances = ();  // Stores active synth instances with their busses
                ~instanceCounter = 0;
                
                ~func = {
                    var s = Server.default;
                    var instance = ();
                    var synth;
                    
                    // Ensure server is booted
                    if(s.serverRunning.not) {
                        "Server not running - boot server first!".error;
                        nil
                    } {
                        // Create busses for this instance
                        instance[\root] = Bus.control(s, 1).set(0);
                        instance[\ornament] = Bus.control(s, 5).set(0);
                        instance[\chord] = Bus.control(s, 5).setn([261.6255653006, 293.66476791741, 329.62755691287, 391.99543598175, 440.0]);
                        instance[\width] = Bus.control(s, 5).setn(1.015 ! 5);
                        instance[\knum] = Bus.control(s, 5).setn(2 ! 5);
                        instance[\select] = Bus.control(s, 1).set(0.0);
                        instance[\ampDist] = Bus.control(s, 5).set(0 ! 5);
                        instance[\durDist] = Bus.control(s, 5).setn(1 ! 5);
                        instance[\ampDistParam] = Bus.control(s, 5).setn(1 ! 5);
                        instance[\durDistParam] = Bus.control(s, 5).setn(1 ! 5);
                        instance[\ampScale] = Bus.control(s, 5).setn(0.5 ! 5);
                        instance[\durScale] = Bus.control(s, 5).setn(0.5 ! 5);
                        instance[\amp] = Bus.control(s, 5).setn([2, 2, 2, 1, 0.5]);
                        instance[\running] = ();
                        
                        // Debug: check bus allocation
                        ("Root bus index: " ++ instance[\root].index).postln;
                        
                        synth = {
                            var freqLag = \freqLag.kr(3);
                            [Gendy1, Gendy2, Gendy3].collect { |i|
                                i.arWidth(
                                    ampdist: In.kr(instance[\ampDist].index, 5),
                                    adparam: In.kr(instance[\ampDistParam].index, 5),
                                    durdist: In.kr(instance[\durDist].index, 5),
                                    ddparam: In.kr(instance[\durDistParam].index, 5),
                                    durscale: In.kr(instance[\durScale].index, 5),
                                    ampscale: In.kr(instance[\ampScale].index, 5),
                                    freq: (In.kr(instance[\root].index, 1).lag2(freqLag) + In.kr(instance[\ornament].index, 5)).midiratio
                                        * In.kr(instance[\chord].index, 5),
                                    width: In.kr(instance[\width].index, 5),
                                    knum: In.kr(instance[\knum].index, 5),
                                ) / 3
                                * In.kr(instance[\amp].index, 5)
                            }
                            => SelectX.ar(In.kr(instance[\select].index, 1), _)
                            * Env.asr(0.5, 1, \release.kr(2)).kr(0, gate: NamedControl.kr(\gates, [1, 1, 1, 1, 1]))
                            => Splay.ar(_)
                        }.play;
                        
                        instance[\synth] = synth;
                        instance[\freed] = false;
                        
                        // Clean up busses when synth is freed (e.g., CmdPeriod or after release)
                        synth.onFree {
                            instance[\freed].not.if {
                                instance[\freed] = true;
                                Yoeminrak.env.use { ~releasing !? { |r| r.remove(instance) } };
                                instance[\running].do { |r| try { r.free } };
                                instance[\root].free;
                                instance[\ornament].free;
                                instance[\chord].free;
                                instance[\width].free;
                                instance[\knum].free;
                                instance[\select].free;
                                instance[\ampDist].free;
                                instance[\durDist].free;
                                instance[\ampDistParam].free;
                                instance[\durDistParam].free;
                                instance[\ampScale].free;
                                instance[\durScale].free;
                                instance[\amp].free;
                                "Instance busses freed".postln;
                            };
                        };
                        
                        instance  // Return the whole instance
                    }
                };
                
                ~go = { |bus newPitch time=1 curve freqLag=0|
                    var numChannels = bus.numChannels;
                    {
                        Env([In.kr(bus.index, numChannels) => Latch.kr(_, 1), newPitch], time, curve).kr(2, gate: 1).lag2(freqLag)
                        => Out.kr(bus.index, _)
                    }.play
                };
            }
        }
    }

    *playVid { |vid sec audio=true fullscreen=false length=1 start=0 end=5|
        var path = (vid == 0).if { video.at(\live) } { video.at(\particles) };
        sec.notNil.if {
            start = sections[sec] + (vid * particleVidOffset);
            end = sections[sec + length] + (vid * particleVidOffset)
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

    *addDrum { |section params|
        song[section].isNil.if { song[section] = List[] };
        [
            type: [0, 1, 0, 1, 2, 3].collect { |i| "yoeDrum" ++ i => _.asSymbol },
            beat: [0, 1, 6, 10, 14, 15],
        ] ++ params
        => _.flop
        => _.collect { |i| i.asEvent }
        => _.do { |i| Yoeminrak.song[section].add(i) }
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
                "ADD 1/3".postln;
				i.do {|j x|
					j.put(\beat, counter);
					counter = counter + (1/3)
				}
			} {
                "ADD 1".postln;
				i.put(\beat, counter);
				counter = counter + 1;
			}
		};
		Yoeminrak.song[section].isNil.if{ Yoeminrak.song[section]=Set[]};
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
	play { |cursor=0 section=0 solo continue=false|
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
}
