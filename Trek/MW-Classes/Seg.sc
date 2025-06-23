
Seg {
	*initClass {
		Class.initClassTree(Event);
		Event.addEventType(\seg, {
			var sections, firstSection;
			sections = ~section.isKindOf(Event).if {
				~section.bubble
			} {
				~section.asArray
			}; 

			// Handle the first section for duration (whether it's an Event or section name)
			firstSection = sections[0];
			(firstSection.isKindOf(Event)).if {
				// If it's an Event, use its duration or calculate from its data
				~dur = firstSection[\dur] ?? { 
					// Fallback: if the Event doesn't have dur, try to get it from Song
					if (firstSection[\section].notNil) {
						Song.secDur[Song.section(firstSection[\section])]
					} {
						1 // Default duration
					}
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
								sectionItem.put(key, currentEnv[key].asArray ++ value);
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
					// if not an Event
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
			Server.default.bind { fork{ ~extra.valueEnvir } };
		});

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
