(
	"/Users/michael/tank/super/scd/Mandarin/WindArrange.scd".load;
	a = Seg(\2, \Bridge, \chor,\repeat,\V1L12, setParams:(amp:8, denominator:3), extras: [
		P(\tempo, start:2, music:{|p b e| 

		TempoClock.tempo_(TempoClock.tempo/~denominator)
 });
 P(\porto, start: Song.section(\new), music:
 {|p b e | [
			instrument:\defaultPorto, amp:~amp ? 1,
			freq: [2, 1].df('b-').q,
			dur: 4 * Song.quarter
		].p.play}
	)
	]);
	a.segParams;
	// a.setParams((amp:0.8, denominator:3));
	a.play;
)

Seg(\muteTest, \V1, \V1, mute:[ \guitar, \bass ]).play
(
Event.addEventType(\seg, {
	var parts = Song.at(~section);
	Song.cursor_(Song.section(~section));

	// ( ~mute ? [] ).do{|mute|
	// 	parts = parts.reject {|i| i.name.asString.contains(mute.asString)}
	// };
	parts.do(_.p(currentEnvironment))
});

	// (type:\seg, section:\V1, mute:\bass).play
	// [ type:\seg, section: [\countoff, \V1, \newB].q,dur:[1, 5,5].q, mute:\bass].pp
	(type:\seg, section:[\V1,\newB], amp:2, denominator:0.8).play
)
(
Event.addEventType(\seg, {
	var sections = ~section.asArray; // Convert to array to handle both single values and arrays
	
	// Song.cursor_(Song.section(sections[0]));
	~dur = Song.secDur[Song.section(sections[0])];
	~dur.postln;
	sections.do { |sectionName|
		var cursor;
		var parts = Song.at(sectionName);
		// var secNumber = Song.section(sectionName);
		var currentEnv = currentEnvironment.copy; // Create a copy of the environment
		// currentEnv.put(\dur, Song.secDur[ secNumber ]);
		
		cursor = (Song.section(sectionName));

		
		// Update the section in the copied environment to the current single section
		currentEnv.put(\section, sectionName);
		
		// ( ~mute ? [] ).do{|mute|
		// 	parts = parts.reject {|i| i.name.asString.contains(mute.asString)}
		// };
		
		parts.reject {|i|
			~mute.asArray.any{|j| i.asString.contains(j.asString)}
		}
		.do(_.prEventPlay(cursor, currentEnv));
	};
	s.bind{ ~extra.valueEnvir }
});
)
// Usage examples:
// Single section (works as before)
(
[
	type:\seg,
	section:[ \new, \chor, \repeat ].q,
	mute:[ \bass, \none, \none ].q,
	extra: {{|p b e | [
		instrument:\defaultPorto, amp: 0.2 ? 1,
		freq: [2, 1].df('b-').q,
		dur: 4 * Song.quarter
	].p.play;
	// (instrument:\harp, amp:1).play
}}
].p.play;
)
(
~bridgeNoBass = (
	type:\seg,
	mute:\bass,
	section:\new,
	extra: {|p b e | [instrument:\defaultPorto, amp: ~amp ? 0.2, freq: [2, 1].df('b-').q, dur: 4 * Song.quarter ].p.play;  }
);
[
	~bridgeNoBass
	,
	[ type:\seg, section:[\chor,\repeat].q, ].p
	,
	(type:\seg,extra: {TempoClock.tempo_(1)}, section: 1).play
].q.play
// nice fadeout idea is zz
Song.altGuit_1.play;Song.arrangement_1.play
(type: \seg, section: \1, mute:[\keys, \bass]).play
Song.at(1)
)
Song.secDur[\V1]
TempoClock.tempo_(1)
( type:\seg, section:\countoff).

// Multiple sections (multi-channel expansion)
(type:\seg, section:[\V1,\newB], amp:[ 0, 0.2 ], denominator:1).play;
[ type:\seg, section:[\V1,\newB].q, amp:[ 0, 0.2 ], denominator:1 ].p.play;
TempoClock.tempo_(1)

// This is now equivalent to:
// (type:\seg, section:\V1, amp:2, denominator:0.8).play;
// (type:\seg, section:\newB, amp:2, denominator:0.8).play;
)
( // GOOD ONE
Event.addEventType(\seg, {
	var sections, firstSection;
	sections = ~section.isKindOf(Event).if {
		~section.bubble
	} {
		~section.asArray
	}; // Convert to array to handle both single values and arrays
	
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
		// Original behavior for section names
		~dur = Song.secDur[Song.section(firstSection)];
	};
	
	sections.do { |sectionItem|
		var cursor, parts;
		var currentEnv = currentEnvironment.copy; // Create a copy of the environment
		~solo = ~solo ? []; ~mute = ~mute ? []; ~extra = ~extra ? [];
		
		if (sectionItem.isKindOf(Event)) {
			if (sectionItem[\type] == \seg) {
				sectionItem = sectionItem.copy;
				// If it's another seg Event, recursively process it
				// Merge the seg Event's data into current environment
				sectionItem.keysValuesDo { |key, value|

					case
					{ [\mute, \solo, \extra].includes(key) } {
						sectionItem.put(key, currentEnv[key].asArray ++ value);
					} { key != \type } { // Don't override the type
						currentEnv.put(key, value); /////// HMMMMMMM
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
					
					// Apply muting and play parts
					parts.reject {|i|
						~mute.asArray.any{|j| i.asString.contains(j.asString)}
					}
					.do(_.prEventPlay(cursor, currentEnv));
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
			
			parts.reject {|i|
				~mute.asArray.any{|j| i.asString.contains(j.asString)}
			}
			.do(_.prEventPlay(cursor, currentEnv));
		}
	};
	s.bind{ fork{ ~extra.valueEnvir } }
});
)


(type: \seg, section:~bridgeNoBass, mute:\traps).play
.play
~bridgeNoBass.mute_(\bass).play
~bridgeNoBass.play
Song.at(2)
(type: \seg, section:[~bridgeNoBass, (lag:0.2,freq:900), \V1 ], mute:\chords ).play

Song.secDur[~bridgeNoBass.section]
('mute': \bass, 'section': \new, 'type': \seg)
.play
[section: [~bridgeNoBass, \V1L12].q, \type:\seg].pp
[type:\seg, section: [\new, \V1L12].q].pp

