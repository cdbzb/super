( // ~complete lyric and tune	{{{1
	//~syn1.controller.loaded.not.if({~syn1.init});
	~test=Song( //{{{
		\trashme, [
			"the tran - fer is com-"," f5 c a-4 e c#", //0
			"plete. metabolic rate is","c#4 c5 b-4 c5 a-4 d4 c5",//1
			"double and rising, Doctor...r  Hel- ","d5 b-4 c#5 g c# a-4 g r b",//2
			"lo. r r r"," c#5 d2 d d",//3
			"you are a lovely female, r a","e5 d c# b4 a f# e e2 c#4",//4
			"pleasant sight to wake up to after","e4 d c# d e b a f# a ", //5
			"half a million years- r r ","f5 g f e  e d c# c#",//6
			"r r you're welcome","d5 f4  g5 f ",//7
			"I've forgotten what it fee-","g#4 e b f# a# b c#5",//8
			"ls like even to brea-","d#5 a#4 c#5 d# e f# ",//9
			"th again, Sargon?"," g#5 f# b4 g g",//10
			"Here, in this body","f e g f c"//11
		]
	).setupDurs;
); //}}}
(
	s.latency=2;
~test.function=(start:0,music:{{WhiteNoise.ar(0.1)}.play});
~test.function2=(start:0,music:(note:1));
~test.function3=(start:0,music:{Synth(\default,[\freq,888])});
~test.function4=(start:0,music:[note:1,dur:[1,2,4].q].p);
~test.func5=(start:0,music:{});
~test.infrastructure={~test.condition.test_(true).signal};
~test.condition=Condition.new;
)
~test.function.play;
~test.func5.play
~test.play
~test.rout=(start:0,music:{{s.latency.wait;Synth(\default,[\freq,rrand(400,500!8)]);2.wait; {PinkNoise.ar(0.1)}.play(s,rrand(2,3))}.fork})
~test.rout.play
~test.rout.music.class
SystemClock.sched(0,[note:1].p)
~test.play

~test.function2.music
~test.function2.music.play
~test.play
~test.cursor_0.play
~test.condition=Condition.new
~test.condition.test_(true).signal
SystemClock.sched(1,{{WhiteNoise.ar(0.1)}.play})
s.bind{~test.function.music.play}
{WhiteNoise.ar(0.06)}.awake
Function
Routine
~test.function.play
~test.function.music.play
~test.cursor_(0)
~test.play
~test.condition=Condition.new
);


