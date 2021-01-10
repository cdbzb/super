(
//bassline
b=[5,5,14,5]++( 5!4 )++( 11!7 ) ++ 7=>_.df('b-',octave:2)=>{|i| [out:1,freq:i.q,dur:0.5,instrument:\sawSynth,].p };
//tune1
[2,1,3,\r,2,1,1,\r];
//tune2

c=VoiceLeading(
	[
		[2, 1, 2,  4, 3, \r,\r],
		[\r,\_,\_, 1,\_, \r,\r],
		[-5,\_,\_,-4,-3, \r,-2]
	] ,  
	"Q Q Q qe eqe eqe e".asBeats
).df('b-');

//tune3

a=VoiceLeading(
	[
		[2, 1, 2, -6, -5, \r,\r],
		[-5,\_,\_, -4, -3, \r,-2]
	],
	"Q Q Q qe eqe eqe e".asBeats
).df('b-');

//drum pattern

Ptpar([
	2,[ [instrument:\sawSynthSustain].p<>( c.pma++a.pma ) ].q(2),
	0,Pseq([b],4),
	0,"xx.x".asDrumPat(2,16)=>{|i| [dur:i,instrument:\kick1].p },
	0,"..x.".asDrumPat(2,16)=>{|i| [dur:i,instrument:\snare].p },
	0,"xxxx".asDrumPat(2,16)=>{|i| [dur:i,instrument:\hihat].p },
]).play(TempoClock.new().tempo_(104/60))
)
(

~modulator = Buffer.read(s,Platform.resourceDir +/+ "sounds/a11wlk01.wav");
~carrier = Buffer.alloc(s, 2048);
~carrier.loadCollection((({ 0.3.bilinrand.sin.sum3rand}!1024) ++ ({ 0.05.sum3rand}!1024))); //some custom noise
~carrier.allocReadChannel('/Users/michael/tank/super/samples/La_Mer_clean.aif',channels:0);
~cepbufc = Buffer.alloc(s, 1024);
~cepbufm = Buffer.alloc(s, 1024);
~envc = Buffer.alloc(s, 2048);
~envm = Buffer.alloc(s, 2048);
~bus=Bus.audio()
)

(

//	var pattern = [[instrument:\sawSynthSustain,out:~bus.index,amp:1].p<>(c.pma++ a.pma)].q(2);

	var pattern = [[instrument:\sawSynthSustain,out:~bus.index,amp:1].p<>(c.p++ a.p)].q(2);
	{RecordBuf.ar(In.ar(~bus.index,1),~carrier.bufnum);0}.play;
//	x = Synth.new(\morphintime, [
	x = Synth.new(\localBufferMorph, [
//	x = Synth.new(\soundInMorph, [
		\out,0,
		\modBuf, Item(\order).buffer , 
		\carBuf, ~carrier,
		//default for smooth is *negative* 0.92
		//positive numbers and zero are both interesting
		\smoothCarrier,-0.98 ,
		\pan,[ 1,0,-1 ].choose,
		\amp,1,
	]);
Ptpar([
//	2,[ [instrument:\sawSynthSustain].p<>( c.pma++a.pma ) ].q(2),
	2,pattern,
 	1,[amp:0.01,dev:Pfunc({x.set(\trigger,1)}),dur:8].p,
	0,Pseq([b],4),
	0,"xx.x".asDrumPat(2,16)=>{|i| [dur:i,instrument:\kick1].p },
	0,"..x.".asDrumPat(2,16)=>{|i| [dur:i,instrument:\snare].p },
	0,"xxxx".asDrumPat(2,16)=>{|i| [dur:i,instrument:\hihat].p },
]).play(TempoClock.new().tempo_(104/60))
)
x.set(\trigger,1)
Item(\order).play
(note:1)
(

	[[instrument:\sawSynthSustain,amp:1].p<>(c.p++ a.p)].q(2)
	=> ~vocoderPattern.(_,\feeelingz,rate:0.91.reciprocal);
	Ptpar([
	0,"xx.x".asDrumPat(2,16)=>{|i| [dur:i,instrument:\kick1].p },
	0,"..x.".asDrumPat(2,16)=>{|i| [dur:i,instrument:\snare].p },
	0,"xxxx".asDrumPat(2,16)=>{|i| [dur:i,instrument:\hihat].p },
	]).play;
//Item(\feeelingz).play

)
Item(\feeelingz).arm(s,0)
Item(\feEelingz).play
Item(\feeelingz).play
Item.refrese
u8
