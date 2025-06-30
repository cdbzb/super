
Seg {
	*initClass {
		Class.initClassTree(Event);
		Event.addEventType(\seg, {
			var sections, firstSection;
			//expand Pseqs
			var expand = { |event parent|
				parent = parent ? ();
				event.section.list.collect {|i|
					i.isKindOf(Event).if{
						expand.(i, event)
					} {
						parent ++ event.deepCopy.put(\section, i).asEvent
					}
				}
			};
			
			// Check if ~section is a Pseq
			if (~section.isKindOf(Pseq)) {
				// Create a Pseq of Events from the Pseq sections
				expand.(currentEnvironment).flat.q.play;
				^nil; // Exit early since we've handled the Pseq case
			};
			
			sections = ~section.isKindOf(Event).if {
				~section.bubble
			} {
				~section.asArray
			}; 

			// Handle the first section for duration (whether it's an Event or section name)
			firstSection = sections[0];
			(firstSection.isKindOf(Event)).if {
				// If it's an Event, use its duration or calculate from its data
					firstSection[\section].debug("SECOND");
					firstSection[\dur].debug("DUR");
				~dur = 
				// firstSection[\dur] ?? { 
                    // Fallback: if the Event doesn't have dur, try to get it from Song
					if (firstSection[\section].notNil) {
						Song.secDur[Song.section(firstSection[\section])]
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
				~solo = ~solo ? [];
				~mute = ~mute ? [];
				~extra = ~extra ? [];

				if (sectionItem.isKindOf(Event)) {
					if (sectionItem[\type] == \seg) {
						sectionItem = sectionItem.copy;
						// If it's another seg Event, recursively process it
						// Merge the seg Event's data into current environment
						sectionItem.keysValuesDo { |key, value|

							case
							{ [\mute, \solo, \extra].includes(key) } {
								sectionItem.put(key, currentEnv[key].asArray ++ value
							}
							{ key != \type } { // Don't override the type
								currentEnv.put(key, value);
							};
						};
						// Play the seg Event with merged environment
						sectionItem.play;
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
		});

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

