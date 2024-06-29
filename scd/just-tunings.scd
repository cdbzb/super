Quar

Tuning.names.do(_.postln)
(
~tuning = '12et';
~tuning = \just;
~tuning = \valotti;
[
	freq: [
		[ 1, 3, 5, 7 ].df(\c, tuning: ~tuning)
		,

		[-5, 1, 3, 5].df(\f, tuning: ~tuning),
		[-5, 1, 3.05, 5].df(\g, tuning: ~tuning),
		[-5, 1, 3, 7].df(\f, tuning: ~tuning),
		[ 1, 3, 5, \r].df(\c, tuning: ~tuning),

		[-5, 1, 3, 5].df(\f, tuning: ~tuning),
		[-5, 1, 3, 5].df(\g, tuning: ~tuning),
		[-5, 1, 3, 7].df(\f, tuning: ~tuning)
	].dupEach(1).q(5),
	instrument: \sawSynthSustain,
	lagTime: 0.2,
	out: (0..4),
	legato: [1, 1, 1, [1, 1, 1, 2], ].q(inf),

].ppm
)
(

Event.addEventType(\md, {|server|
	~octave= ~md / 10 => _.floor  + 5;
	~degree= ~md.abs % 10 -1;
	~type= \note;
	~scale = Scale.at(~scale).copy.tuning_(~tuning);
	currentEnvironment.play
})
)
[ type: \md, md: [ 1, 3, 5 ], scale: \major, tuning: [ \mean4, \just ].q(inf) ].pm(\default).play
( freq: -12.df ).play
Event
(
[
	freq: [
		[1, 3, 5].df(\c, tuning: \mean4),
		[1, 3, 5].df(\c, tuning: \just),
		[1, 3, 5].df(\c, tuning: \valotti),
	].q(inf) ,
	depth:0,
	// out: (0..4)
	out: 4.rand
].pm(\sparkTriangle).trace.play
)
(
[
	freq: [1, 3, 5, 7].df(\f, tuning: \mean4).bubble
		++ [-5, -7, 1, 3].df('b-', tuning: \just).bubble
		=> _.q(inf),
	out: (0..3),
	amp: [0.1,0.1, 0.1, 0.1]
].ppm
)


