Mandarin {
    classvar path;
    classvar event, <>env;
    *initClass {
        Class.initClassTree(Event);
        path = PathName(Mandarin.filenameSymbol.asString).pathOnly +/+ "Songs";
        env = ();
        event = (
            path: path,
            load: {|self file|  self.path +/+ self[file] => _.load },
            edit: {|self name | self.path +/+ (name !? self[name] ? self[Song.current]) => Nvim.e(_)},
            Wind: "windArrange.scd",
            automobile: "automobile.scd",
            automobile2: "automobile2.scd",
            automobile3: "automobile3.scd",
            heartbeat: "Heartbeat.scd",
            beautiful: "beautiful-day.scd",
            neon2: "Neon-with-beat.scd",
            mandarin1: "new mandarin song.scd",
            'c#': "C-sharp-song.scd",
            notGoodEnough: "Not_Good_Enough.scd",
            songs: {|self| self.keys.reject{|i| [\path].includes(i) }.do {|key| self[key].isKindOf(String).if{key.postln} }}
        );
        Event.addEventType(\add, {
            var ev = (type: \seg);
            currentEnvironment.keys.reject({|i| [\dur, \type].includes(i) }).do {|i|
                ev.put(i, currentEnvironment[i])
            };
            Mandarin.env[\current].add(ev);
            Mandarin.env[\preview].notNil.if { ev.play }
        });
        Event.addEventType(\segList, {
            var ev = ();
            currentEnvironment.keys.reject({|i| [\dur, \type, \when].includes(i) }).do {|i|
                ev.put(i, currentEnvironment[i])
            };
            EventList(\mandarin).add(ev);
        });
    }
    *setupEventList {
        var list = EventList(\mandarin, \seg);
        (topEnvironment != env).if { env.push };
        list.clear;
        list.preview = nil;
        list.beatDur = Song.clock.notNil.if { Song.clock.beatDur } { Song.quarter ? 1 };
        list.addFunc = { |ev, l|
            ev[\section].notNil.if {
                var explicit = ev[\when].notNil;
                explicit.if {
                    var prev = l.events.last;
                    ev[\when] = (prev !? { prev[\when] } ? 0) + ev[\when];
                } {
                    ev[\when] = Mandarin.env[\nextWhen] ? 0;
                    Mandarin.env[\nextWhen] = ev[\when] + (Seg.durOf(ev) / (l.beatDur ? 1));
                };
                "  @ % beats : %".format(ev[\when].round(0.001), ev[\section]).postln;
            }
        };
        env[\nextWhen] = 0;
        ^list
    }
    *doesNotUnderstand { |selector ...args|
        ^Message(event, selector).(*args)
    }
}
Seg {
	*initClass {
		Class.initClassTree(Event);
		Event.addEventType(\seg, {
			var sections, firstSection;
			//expand Pseqs
			var expand = { |event parent|
				parent = parent ? ();
				event.section.list.collect {|i|
					(i.isKindOf(Event) and: try{ i[\section].isKindOf(Pseq) } {false}).if{
						expand.(i, event)
					} {
						parent ++ event.deepCopy.put(\section, i).asEvent
					}
				}
			};
			//if section is event merge
			currentEnvironment.debug("THIS");
			// Check if ~section is a Pseq
			if (~section.isKindOf(Pseq)) {
				// Create a Pseq of Events from the Pseq sections
				expand.(currentEnvironment).flat.q.play;
				// Don't use ^nil here - just end the function naturally
			} {
				// Move all the rest of the logic into the else block
				sections = ~section.isKindOf(Event).if {
					~section.bubble
				} {
					~section.asArray
				}; 
				// Handle the first section for duration (whether it's an Event or section name)
				firstSection = sections[0];
				(firstSection.isKindOf(Event)).if {
					// If it's an Event, use its duration or calculate from its data
						firstSection[\dur].debug("DUR");
					~dur = 
					firstSection[\dur] ? 
						if (firstSection[\section].notNil) {
							Song.secDur[Song.section(firstSection[\section])] + ( firstSection[\extend]?0 ).debug("EXTEND")
						} {
							1 // Default duration
						// }
					};
				} {
					~dur = Song.secDur[Song.section(firstSection)];
				};
				sections.do { |sectionItem|
					var cursor, parts;
					var currentEnv = currentEnvironment.copy; // Create a copy of the environment
					[\solo, \mute,\extra].do {|i| currentEnv[i] = currentEnv[i] ? []};
					if (sectionItem.isKindOf(Event)) {
						if (sectionItem[\type] == \seg) {
							sectionItem = sectionItem.copy;
							// If it's another seg Event, recursively process it
							// Merge the seg Event's data into current environment
							sectionItem.keysValuesDo { |key, value|
								case
								{ [\mute, \solo, \extra].includes(key) } {
									sectionItem.put(key, currentEnv[key].asArray ++ value)
								}
								{ key != \type } { // Don't override the type
									currentEnv.put(key, value);
								};
							};
							// Play the seg Event with merged environment
							(currentEnv ++ sectionItem).play;
						} {
							var sectionName = sectionItem[\section];
							if (sectionName.notNil) {
								cursor = Song.section(sectionName);
								currentEnv.put(\section, sectionName);
								parts = Song.at(sectionName);
								// Apply solo filtering first, if solo exists ignore mute
								(~solo.asArray.size > 0).if {
									parts.select{|i| 
										~solo.asArray.any{|j| i.asString.contains(j.asString) } 
									}
									.do(_.prEventPlay(cursor, currentEnv));
								} {
									parts.reject{|i|
										~mute.asArray.any{|j| i.asString.contains(j.asString) }
									}
									.do(_.prEventPlay(cursor, currentEnv));
								};
							} {
								// If Event has no section, just play it directly
								sectionItem.play;
							}
						}
					} {
						// if not an Event (String or Symbol)
						var sectionName = sectionItem;
						cursor = Song.section(sectionName);
						currentEnv.put(\section, sectionName);
						parts = Song.at(sectionName);
						// Apply solo filtering first, if solo exists ignore mute
						(~solo.asArray.size > 0).if {
							parts.select { |i|
								~solo.asArray.any { |j| i.asString.contains(j.asString) }
							}
							.do(_.prEventPlay(cursor, currentEnv));
						} {
							parts.reject { |i|
								~mute.asArray.any { |j| i.asString.contains(j.asString) }
							}
							.do(_.prEventPlay(cursor, currentEnv));
						};
					}
				};
				Server.default.bind { fork{0.2.wait; ~extra.asArray.do(_.valueEnvir )} };
			};
		});
	}
    *durOf { |event|
        var sections, firstSection, expand;
        (event[\section].isKindOf(Pseq)).if {
            expand = { |ev, parent|
                parent = parent ? ();
                ev[\section].list.collect { |i|
                    (i.isKindOf(Event) and: { try { i[\section].isKindOf(Pseq) } { false } }).if {
                        expand.(i, ev)
                    } {
                        parent ++ ev.deepCopy.put(\section, i).asEvent
                    }
                }
            };
            ^expand.(event).flat.sum { |e| Seg.durOf(e) }
        };
        sections = event[\section].isKindOf(Event).if { event[\section].bubble } { event[\section].asArray };
        firstSection = sections[0];
        ^(firstSection.isKindOf(Event)).if {
            firstSection[\dur] ??
            {
                firstSection[\section].notNil.if {
                    Song.secDur[Song.section(firstSection[\section])] + (firstSection[\extend] ? 0)
                } {
                    1
                }
            }
        } {
            Song.secDur[Song.section(firstSection)]
        }
    }
    *new {|section ...args, kwargs|
        ^(type:\seg, section:section) ++ kwargs.asEvent ++ (record:{|self path head=0.2 tail|
            var newSectionList = [
                (play: { Server.default.record(path) }, dur:head),
                self.section.list, 
                (play: { fork{ tail.wait; Server.default.stopRecording } })
            ].flatten;
			Seg(section:newSectionList.q).play
		})
    }
}

PatternScheduler {
	*new { |pattern transport=0 clock latency=0.2|
		^super.new.init(pattern, transport, clock, latency)
    }
    
	init { |pattern transport clock, latency|
        var stream = pattern.asStream;
        var event, nextTime = 0, startTime;
        var allEvents = [];
        
        // Collect all events and their timings
        while { (event = stream.next(())).notNil } {
            allEvents = allEvents.add([event, nextTime]);
            nextTime = nextTime + (event[\dur] ? 1);
        };
        
        // Schedule all events immediately
		startTime = clock.beats + latency;
        allEvents.do { |item|
            var ev = item[0];
            var time = item[1];
			((time = time - transport) >= 0).if {
				clock.schedAbs(startTime + time, {
					ev.play;
					nil // don't reschedule
				});
			}
        };
    }
}
+ Array {
	ps {
		^this ++ [
				type: \seg, 
				dur: Pfunc({ |event|
					var sections, firstSection;
					var section = event[\section];

					// Same logic as in your event type for calculating duration
					sections = section.isKindOf(Event).if {
						section.bubble
					} {
						section.asArray
					};

					firstSection = sections[0];
					(firstSection.isKindOf(Event)).if {
						// firstSection[\dur] ?? { 
							if (firstSection[\section].notNil) {
								Song.secDur[Song.section(firstSection[\section])]
							} {
								1
							// }
						};
					} {
						Song.secDur[Song.section(firstSection)];
					};
				})
			]
	}
}
+ Part {
	prEventPlay { |cursor=0, segParams|
		// calculate time
		var when;
		lag.isNil.if { lag = 0 };
		when = parent.secLoc[start]-parent.secLoc[cursor];
		when = when + lag + parent.preroll; // per song setting to allow for negative lags
		syl !? { when = when + parent.durTill(start, syl) };

		segParams = segParams ? ();
		// (start >= parent.cursor).if {
			this.sched(when + Server.default.latency, segParams);
		// }
	}
}

