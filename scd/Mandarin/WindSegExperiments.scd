(
	"/Users/michael/tank/super/scd/Mandarin/WindArrange.scd".load;
)

( 
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
	(type:\seg,extra: {TempoClock.tempo_(1)}, section: 1)
].q.play
// nice fadeout idea is zz
)
(
// Song.altGuit_1.play;Song.arrangement_1.play;
(type: \seg, section: \1, mute:[\keys, \bass]).play
//get lowbass out of arrangement
)

// Multiple sections (multi-channel expansion)
(type:\seg, section:[\V1,\newB], amp:[ 0, 0.2 ], denominator:1).play;
[ type:\seg, section:[\V1,\newB].q, amp:[ 0, 0.2 ], denominator:1 ].p.play;

// This is now equivalent to:
// (type:\seg, section:\V1, amp:2, denominator:0.8).play;
// (type:\seg, section:\newB, amp:2, denominator:0.8).play;
)


//mute is non-destructive
(type: \seg, section:~bridgeNoBass, mute:\traps).play

(type: \seg, section:[~bridgeNoBass, (lag:0.2,freq:900), \V1 ], mute:\chords ).play

Song.secDur[~bridgeNoBass.section]
('mute': \bass, 'section': \new, 'type': \seg)
.play
[section: [~bridgeNoBass, \V1L12].q, \type:\seg].pp
[type:\seg, section: [\new, \V1L12].q].pp

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
