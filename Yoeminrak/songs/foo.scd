(
var song = Yoeminrak.song;
var events;
song.foo = List[];
Yoeminrak.resetBusses;

events = [
	type:\yoeString3,
	knum:4,
	// knum:Pseries(4,0.51,15),
	select:0.5,
	freqLag:2.6,
	chord: [
		[-4, -6, 1, 5, 11].df(\c),
		[-4, -6, 2, 5, 12].df(\c),
		T( [-5, -7, 2, 6, 13].df(\c), 1,\lin ),
		[-5, -7, 3, 6, 13].df(\c),
		T( [-6, 1, 3].df(\c, ), 1,\lin ),
		[-6, 1, 4].df(),
		T( [-7, 2, 4, 11, 12].df(), 1, \lin ),
		[-7, 2, 5].df(),
		T( [-5, 1, 4, 6.5, 14].df(), 2, \lin ),
		[-5, 1, 3, 13].df(),
		T( [-4, -5, 2, 6, 12].df(), 2, \lin ),
		[-3, -5, 1, 12, 11].df(),
	].q,
	width:1.03,
	// ampDistParam:Pwhite(0,6,inf),
	// durDistParam:Pwhite(0,6,inf),
	// ampScale:Pwhite(0,1.0,inf),
	// durScale:Pwhite(0,1.0, inf),
	// ampDist:Pwhite(0,1.0, inf),
	// durDist:Pwhite(0,1.0, inf)
	// dur: Yoeminrak.secDur[3] / 20 / 3
].p
.eventsWithBeats(10);
events[3] .put(\ampScale, {SinOsc.ar(0.34)*2 * Env([0,1],6).kr(2,gate:1)});
events[5] .put(\durScale, {SinOsc.ar(0.34, (..4))*8});
events[5] .put(\durDistParam, {SinOsc.ar(0.34, (..4)).abs});
events[5] .put(\ampDistParam, {SinOsc.ar(0.34)*8});
song.foo.addAll(events);
Yoeminrak.drumPbind.patternpairs ++ [freq:[ 99 * -2.midiratio, 99, 99 * -7.midiratio ].q(inf)] => _.p =>_.eventsWithBeats(6) => song.foo.addAll(_);
)
