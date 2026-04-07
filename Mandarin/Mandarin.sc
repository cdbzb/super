Mandarin {
    classvar path = "/Users/michael/tank/super/scd/Mandarin";
    classvar event, <>env;
    *initClass {
        Class.initClassTree(Event);
        env = ();
        event = (
            path: "/Users/michael/tank/super/scd/Mandarin",
            load: {|self file|  self.path +/+ self[file] => _.load },
            edit: {|self name | self.path +/+ (name !? self[name] ? self[Song.current]) => Nvim.e(_)},
            Wind: "windArrange.scd",
            automobile: "automobile.scd",
            automobile2: "automobile2.scd",
            automobile3: "automobile3.scd",
            another: "another.scd",
            beautiful: "beautiful-day.scd",
            neon2: "Neon-with-beat.scd",
            mandarin1: "new mandarin song.scd",
            'c#': "C-sharp-song.scd",
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
    }
    *setup {
        (topEnvironment != env).if { env.push };
        env[\current] = List[];
        env[\preview] = nil;
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

