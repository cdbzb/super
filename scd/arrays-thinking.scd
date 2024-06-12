~tracks = [\bass, \chords, \hat];
~sections = [\verse, \chorus];
~song = [
	[\verse, [\bass, \chords, \hat]],
	[\chorus, [\bass, \kick, \hat]]
];
~section = (key: \verse, durs: [1, 2, 1], amp: 3.dbamp)
Event.addEventType(\verse, ( durs: [1, 2, 1], amp: 3.dbamp ))
~part = (key: \bass, parent: ~section, amp: 1.dbamp, play: {~parent.postln}).play
Event.addEventType(\part, {  })
Event.addParentType()

~song.flat.removeDuplicates
(verse: 0, bass: 0, chords: 0, hat: 3, chorus:3, kick:0)
~song.slice[1]
~amp = [[0, [0, 1, 0]], 0, []];




(
~amps = (
	bass: 3,
	1: -2,
	2: 1,
	chords: 0
);
~song = (
	1: (
		amp: 2,
		bass: (
			play: {
				( freq: 100 ).play;
			}
		),
		chords: (
			play: {
				[
					freq: [1, 3, 5].df(\c).q,
				].pp
			}
		),
	play: {
		~bass.play;
		~chords.play
	}
	),
);
)
~song.at(1).play
(
a= {
	var amp = 5;
	var one = {
			amp.postln
	};
	one.()
}.()

)
a=(
a:1,
b:{|e| ( e.a )}
)
p = (amp:1)
e = (section:p, amp: 4, play: { ~amp + ~section.amp => _.postln } );
e.play
e.plaee..y
Event.addEventType(\foo, {})
()
e.amp

AmpMatrix => associate an amp with any section and any number of strings
usage:

P(\foo, music: { |p b e|
	Amps.set(4)// sets AmpMatrix value for to 4
	[
		amp: Amps.get // on playback the AmpMatrix value at the section is summed with the value at the
		// section and \foo or any substring of \foo
		
		//how can I accomplish this with perhaps an event type?
	].pp
});

// what about perhaps
Event.addParentType(\note, (freq: Song.amp))
().freq
Song.amp = 0.1
a =(type:\note, freq: 888, amp: Pfunc{|e| e.sectionAmp})
a.sectionAmp
.play
Song(\trashme,[]).current
1

